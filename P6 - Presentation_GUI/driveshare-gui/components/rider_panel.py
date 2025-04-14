import streamlit as st
import pandas as pd
import datetime
import time
import folium
from streamlit_folium import st_folium
from sqlalchemy import text
from db import engine


def rider_login():
    st.title("🚪 Rider Login")

    email = st.text_input("Email")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        try:
            with engine.begin() as conn:
                conn.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))

                result = conn.execute(text("""
                    SELECT 
                        UserID,
                        CONVERT(VARCHAR(100), DecryptByKey(EmailID)) AS EmailID,
                        CONVERT(VARCHAR(100), DecryptByKey(Password)) AS PasswordPlain
                    FROM RegisteredUsers
                    WHERE Type = 'Rider'
                """)).fetchall()

            matched_user = next(
                (row for row in result if row.EmailID == email and row.PasswordPlain == password), None
            )

            if matched_user:
                st.session_state.user_id = matched_user.UserID
                st.success("✅ Login successful!")
                st.rerun()
            else:
                st.error("❌ Invalid credentials")

        except Exception as e:
            st.error(f"❌ Error: {e}")


import random

def request_trip(user_id, pickup_lat, pickup_lon, dropoff_lat, dropoff_lon):
    try:
        with engine.begin() as conn:
            # 🎯 Get actual RiderID
            rider_row = conn.execute(
                text("SELECT RiderID FROM Rider WHERE UserID = :uid"), 
                {"uid": user_id}
            ).fetchone()
            if not rider_row:
                return False, f"⚠️ RiderID not found for UserID: {user_id}"
            rider_id = rider_row.RiderID

            # 🧮 Determine State from Pickup Coordinates
            state = conn.execute(
                text("SELECT dbo.GetStateFromCoordinates(:lat, :lon)"), 
                {"lat": pickup_lat, "lon": pickup_lon}
            ).scalar()

            # 🔍 Get city/county values only from the same state
            existing_values = conn.execute(text("""
                SELECT DISTINCT City, County 
                FROM Location 
                WHERE City IS NOT NULL AND County IS NOT NULL AND State = :state
            """), {"state": state}).fetchall()

            if not existing_values:
                return False, f"❌ No known city/county entries for state '{state}' to populate location."

            if len(existing_values) < 2:
                return False, f"❌ Not enough unique city/county values in state '{state}' to assign pickup and dropoff."

            # Shuffle and pick two distinct cities
            random.shuffle(existing_values)
            pickup_city, pickup_county = existing_values[0]
            dropoff_pair = next((c for c in existing_values[1:] if c != (pickup_city, pickup_county)), None)

            if not dropoff_pair:
                return False, f"❌ Could not find a second distinct city in state '{state}' for dropoff."

            dropoff_city, dropoff_county = dropoff_pair

            # 🧮 Calculate geohashes
            pickup_geohash = conn.execute(text(
                "SELECT dbo.CalculateGeohash(:lat, :lon, 8) AS gh"
            ), {"lat": pickup_lat, "lon": pickup_lon}).scalar()

            dropoff_geohash = conn.execute(text(
                "SELECT dbo.CalculateGeohash(:lat, :lon, 8) AS gh"
            ), {"lat": dropoff_lat, "lon": dropoff_lon}).scalar()

            # 📍 Insert pickup location if it doesn't exist
            conn.execute(text("""
                IF NOT EXISTS (SELECT 1 FROM Location WHERE GeohashID = :geohash)
                INSERT INTO Location (Latitude, Longitude, Region, County, City, State)
                VALUES (:lat, :lon, 'Northeast', :county, :city, :state)
            """), {
                "geohash": pickup_geohash,
                "lat": pickup_lat,
                "lon": pickup_lon,
                "city": pickup_city,
                "county": pickup_county,
                "state": state
            })


            conn.execute(text("""
                IF NOT EXISTS (SELECT 1 FROM Location WHERE GeohashID = :geohash)
                INSERT INTO Location (Latitude, Longitude, Region, County, City, State)
                VALUES (:lat, :lon, 'Northeast', :county, :city, :state)
            """), {
                "geohash": dropoff_geohash,
                "lat": dropoff_lat,
                "lon": dropoff_lon,
                "city": dropoff_city,
                "county": dropoff_county,
                "state": state
            })


            # 🚗 Insert TripRequest
            trip_id = conn.execute(text("""
                INSERT INTO TripRequest (
                    RiderID, PickupLatitude, PickupLongitude,
                    DropoffLatitude, DropoffLongitude, RequestTime, Status
                )
                OUTPUT INSERTED.TripRequestID
                VALUES (
                    :rider_id, :pu_lat, :pu_lon,
                    :do_lat, :do_lon, :req_time, 'Pending'
                )
            """), {
                "rider_id": rider_id,
                "pu_lat": pickup_lat,
                "pu_lon": pickup_lon,
                "do_lat": dropoff_lat,
                "do_lon": dropoff_lon,
                "req_time": datetime.datetime.now()
            }).scalar()

        return True, trip_id

    except Exception as e:
        return False, f"❌ Error: {e}"

def process_payment(invoice_id, rider_id, method, amount):
    try:
        with engine.begin() as conn:
            # 1. Insert PaymentRequest if not already exists
            existing = conn.execute(text("""
                SELECT COUNT(*) FROM PaymentRequest 
                WHERE InvoiceID = :iid AND RiderID = :rid
            """), {"iid": invoice_id, "rid": rider_id}).scalar()

            if existing == 0:
                conn.execute(text("""
                    INSERT INTO PaymentRequest (InvoiceID, RiderID, MethodOfPayment, Amount, Status)
                    VALUES (:iid, :rid, :method, :amount, 'Pending')
                """), {
                    "iid": invoice_id,
                    "rid": rider_id,
                    "method": method,
                    "amount": amount
                })

        # 2. Get the PaymentID
        with engine.begin() as conn:
            payment_id = conn.execute(text("""
                SELECT PaymentID FROM PaymentRequest 
                WHERE InvoiceID = :iid AND RiderID = :rid
            """), {"iid": invoice_id, "rid": rider_id}).scalar()

        # 3. Now process the payment
        raw_conn = engine.raw_connection()
        cursor = raw_conn.cursor()
        cursor.execute("""
            DECLARE @msg VARCHAR(255);
            EXEC dbo.ProcessPayment @PaymentID = ?, @MethodOfPayment = ?, @Message = @msg OUTPUT;
            SELECT @msg AS message;
        """, (payment_id, method))

        while cursor.nextset():
            if cursor.description:
                break

        result = cursor.fetchone()
        cursor.close()
        raw_conn.commit()
        raw_conn.close()

        if result and result[0]:
            st.success(result[0])
        else:
            st.warning("✅ Payment processed, but no message returned.")
        
        st.rerun()

    except Exception as e:
        st.error(f"❌ Payment failed: {e}")


def show():
    if "user_id" not in st.session_state:
        rider_login()
        st.stop()

    st.sidebar.title("👤 Rider Menu")
    if st.sidebar.button("🔓 Logout"):
        del st.session_state.user_id
        st.success("Logged out successfully.")
        st.rerun()

    user_id = st.session_state.user_id

    # Get RiderID
    with engine.begin() as conn:
        rider_id = conn.execute(text("SELECT RiderID FROM Rider WHERE UserID = :uid"), {"uid": user_id}).scalar()

    if not rider_id:
        st.error("❌ Rider ID not found.")
        return

    st.title("🚕 Rider Dashboard")

    tab1, tab2, tab3 = st.tabs(["🚗 Request Trip", "📚 Trip History", "💳 Pending Payments"])

    with tab1:
        st.write("Welcome! Select your pickup and dropoff points below to request a ride.")
        if "pickup_coords" not in st.session_state:
            st.session_state.pickup_coords = ""
        if "dropoff_coords" not in st.session_state:
            st.session_state.dropoff_coords = ""
        if "click_stage" not in st.session_state:
            st.session_state.click_stage = "pickup"

        m = folium.Map(location=[40.7128, -74.0060], zoom_start=11)

        if st.session_state.pickup_coords:
            lat, lon = map(float, st.session_state.pickup_coords.split(","))
            folium.Marker([lat, lon], tooltip="Pickup", icon=folium.Icon(color="green")).add_to(m)

        if st.session_state.dropoff_coords:
            lat, lon = map(float, st.session_state.dropoff_coords.split(","))
            folium.Marker([lat, lon], tooltip="Dropoff", icon=folium.Icon(color="red")).add_to(m)

        map_result = st_folium(m, height=500, width=700)
        time.sleep(0.1)

        if map_result and map_result.get("last_clicked"):
            latlng = map_result["last_clicked"]
            coords = f"{latlng['lat']:.6f}, {latlng['lng']:.6f}"

            if st.session_state.click_stage == "pickup":
                st.session_state.pickup_coords = coords
                st.session_state.click_stage = "dropoff"
            elif st.session_state.click_stage == "dropoff":
                st.session_state.dropoff_coords = coords
                st.session_state.click_stage = "done"
            st.rerun()

        col1, col2 = st.columns(2)
        with col1:
            st.text_input("Pickup Coordinates", value=st.session_state.pickup_coords, disabled=True)
        with col2:
            st.text_input("Dropoff Coordinates", value=st.session_state.dropoff_coords, disabled=True)

        st.markdown("---")
        if st.button("🔄 Reset"):
            st.session_state.pickup_coords = ""
            st.session_state.dropoff_coords = ""
            st.session_state.click_stage = "pickup"
            st.rerun()

        if st.session_state.pickup_coords and st.session_state.dropoff_coords:
            if st.button("🚗 Request Trip"):
                pickup_lat, pickup_lon = map(float, st.session_state.pickup_coords.split(","))
                dropoff_lat, dropoff_lon = map(float, st.session_state.dropoff_coords.split(","))
                success, trip_id = request_trip(user_id, pickup_lat, pickup_lon, dropoff_lat, dropoff_lon)

                if success:
                    st.session_state.latest_trip_id = trip_id
                    st.session_state.pickup_coords = ""
                    st.session_state.dropoff_coords = ""
                    st.session_state.click_stage = "pickup"
                    st.success("✅ Trip successfully requested!")
                else:
                    st.error(trip_id)

        if "latest_trip_id" in st.session_state:
            trip_id = st.session_state.latest_trip_id
            with engine.begin() as conn:
                trip = conn.execute(text("""
                    SELECT TripRequestID, RequestTime, Status,
                        PickupLatitude, PickupLongitude,
                        DropoffLatitude, DropoffLongitude,
                        EstimatedDistance, EstimatedCost
                    FROM TripRequest
                    WHERE TripRequestID = :tid
                """), {"tid": trip_id}).fetchone()

            if trip:
                st.markdown("## 🎫 Trip Confirmation Ticket")
                with st.container(border=True):
                    st.markdown(f"**🆔 Trip ID:** `{trip.TripRequestID}`")
                    st.markdown(f"**📍 Pickup:** `{trip.PickupLatitude:.5f}, {trip.PickupLongitude:.5f}`")
                    st.markdown(f"**🏁 Dropoff:** `{trip.DropoffLatitude:.5f}, {trip.DropoffLongitude:.5f}`")
                    st.markdown(f"**🕒 Requested at:** `{trip.RequestTime}`")
                    st.markdown(f"**📌 Status:** `{trip.Status}`")
                    st.markdown(f"**📏 Distance:** `{trip.EstimatedDistance:.2f} km`")
                    st.markdown(f"**💰 Estimated Cost:** `₹{trip.EstimatedCost:.2f}`")

    with tab2:
        st.markdown("### 📚 Your Trip History")
        with engine.begin() as conn:
            trips = conn.execute(text("""
                SELECT TripRequestID, RequestTime, Status,
                    PickupLatitude, PickupLongitude,
                    DropoffLatitude, DropoffLongitude,
                    EstimatedDistance, EstimatedCost
                FROM TripRequest
                WHERE RiderID = :rid
                ORDER BY RequestTime DESC
            """), {"rid": rider_id}).fetchall()

        if trips:
            for trip in trips:
                with st.container(border=True):
                    st.markdown(f"**🆔 Trip ID:** `{trip.TripRequestID}`")
                    st.markdown(f"**📍 Pickup:** `{trip.PickupLatitude:.5f}, {trip.PickupLongitude:.5f}`")
                    st.markdown(f"**🏁 Dropoff:** `{trip.DropoffLatitude:.5f}, {trip.DropoffLongitude:.5f}`")
                    st.markdown(f"**🕒 Requested at:** `{trip.RequestTime}`")
                    st.markdown(f"**📌 Status:** `{trip.Status}`")
                    st.markdown(f"**📏 Distance:** `{trip.EstimatedDistance:.2f} km`")
                    st.markdown(f"**💰 Estimated Cost:** `₹{trip.EstimatedCost:.2f}`")
                    st.markdown("---")
        else:
            st.info("🛑 No trips found yet.")

    with tab3:
        st.markdown("### 💳 Pending Payments")

        with engine.begin() as conn:
            unpaid = conn.execute(text("""
                SELECT 
                    i.InvoiceID, tr.TripRequestID, i.Price
                FROM Invoice i
                JOIN TripRequest tr ON i.TripRequestID = tr.TripRequestID
                WHERE tr.RiderID = :rid AND tr.Status = 'Completed'
                AND NOT EXISTS (
                    SELECT 1 FROM PaymentRequest pr
                    WHERE pr.InvoiceID = i.InvoiceID AND pr.RiderID = :rid
                )
            """), {"rid": rider_id}).fetchall()

        if unpaid:
            for row in unpaid:
                with st.container(border=True):
                    st.markdown(f"**🧾 Invoice ID:** `{row.InvoiceID}`")
                    st.markdown(f"**🚗 Trip:** `{row.TripRequestID}` | 💰 Amount: ₹{row.Price}")
                    payment_method = st.selectbox(
                        f"Choose Payment Method for `{row.InvoiceID}`",
                        ["Cash", "Card", "OnlineWallet"],
                        key=f"method_{row.InvoiceID}"
                    )
                    if st.button(f"💸 Pay Now for Invoice `{row.InvoiceID}`", key=f"pay_{row.InvoiceID}"):
                        process_payment(
                            invoice_id=row.InvoiceID,
                            rider_id=rider_id,
                            method=payment_method,
                            amount=row.Price
                        )
        else:
            st.info("✅ No pending payments.")
