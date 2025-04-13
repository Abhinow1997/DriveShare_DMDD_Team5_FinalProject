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


def request_trip(user_id, pickup_lat, pickup_lon, dropoff_lat, dropoff_lon):
    try:
        with engine.begin() as conn:
            # Get actual RiderID from Rider table
            rider_row = conn.execute(text("SELECT RiderID FROM Rider WHERE UserID = :uid"), {"uid": user_id}).fetchone()

            if not rider_row:
                return False, f"⚠️ RiderID not found for UserID: {user_id}"

            rider_id = rider_row.RiderID

            # Calculate geohashes
            pickup_geohash = conn.execute(text("SELECT dbo.CalculateGeohash(:lat, :lon, 8) AS gh"),
                                          {"lat": pickup_lat, "lon": pickup_lon}).scalar()
            dropoff_geohash = conn.execute(text("SELECT dbo.CalculateGeohash(:lat, :lon, 8) AS gh"),
                                           {"lat": dropoff_lat, "lon": dropoff_lon}).scalar()

            # Ensure pickup location exists
            conn.execute(text("""
                IF NOT EXISTS (SELECT 1 FROM Location WHERE GeohashID = :geohash)
                INSERT INTO Location (Latitude, Longitude, Region, County, City, State)
                VALUES (:lat, :lon, NULL, NULL, 'Unknown', dbo.GetStateFromCoordinates(:lat, :lon))
            """), {"geohash": pickup_geohash, "lat": pickup_lat, "lon": pickup_lon})

            # Ensure dropoff location exists
            conn.execute(text("""
                IF NOT EXISTS (SELECT 1 FROM Location WHERE GeohashID = :geohash)
                INSERT INTO Location (Latitude, Longitude, Region, County, City, State)
                VALUES (:lat, :lon, NULL, NULL, 'Unknown', dbo.GetStateFromCoordinates(:lat, :lon))
            """), {"geohash": dropoff_geohash, "lat": dropoff_lat, "lon": dropoff_lon})

            # Insert TripRequest and get TripRequestID
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


def show():
    if "user_id" not in st.session_state:
        rider_login()
        st.stop()

    st.title("🚕 Rider Panel")
    st.write("Welcome! Select your pickup and dropoff points below to request a ride.")

    if "pickup_coords" not in st.session_state:
        st.session_state.pickup_coords = ""
    if "dropoff_coords" not in st.session_state:
        st.session_state.dropoff_coords = ""
    if "click_stage" not in st.session_state:
        st.session_state.click_stage = "pickup"

    st.header("🗺️ Select Pickup and Dropoff")
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

    st.markdown("## 📌 Selected Coordinates")
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

            user_id = st.session_state.get("user_id")

            success, trip_id = request_trip(user_id, pickup_lat, pickup_lon, dropoff_lat, dropoff_lon)

            if success:
                st.session_state.latest_trip_id = trip_id
                st.session_state.pickup_coords = ""
                st.session_state.dropoff_coords = ""
                st.session_state.click_stage = "pickup"
                st.success("✅ Trip successfully requested!")


    # 🎫 Show confirmation ticket if available
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
