import streamlit as st
import pandas as pd
from sqlalchemy import text
from db import engine


# 🔐 DRIVER LOGIN
def driver_login():
    st.title("🔐 Driver Login")

    email = st.text_input("Email")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        
        try:
            with engine.begin() as conn:
                conn.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))
                result = conn.execute(text("""
                    SELECT 
                        RU.UserID,
                        D.DriverID,
                        CONVERT(VARCHAR(100), DecryptByKey(RU.EmailID)) AS EmailID,
                        CONVERT(VARCHAR(100), DecryptByKey(RU.Password)) AS PasswordPlain
                    FROM RegisteredUsers RU
                    JOIN Driver D ON RU.UserID = D.UserID
                    WHERE RU.Type = 'Driver'
                """)).fetchall()

            matched = next((r for r in result if r.EmailID == email and r.PasswordPlain == password), None)

            if matched:
                st.session_state.driver_id = matched.DriverID
                st.success("✅ Login successful!")
                st.rerun()
            else:
                st.error("❌ Invalid credentials")
        except Exception as e:
            st.error(f"❌ Error: {e}")


# 🛠️ DRIVER PANEL
def show():
    if "driver_id" not in st.session_state:
        driver_login()
        st.stop()

    driver_id = st.session_state.driver_id
    st.title("🚙 Driver Dashboard")

    # Sidebar
    st.sidebar.title("👤 Driver Menu")
    if st.sidebar.button("🔓 Logout"):
        del st.session_state.driver_id
        st.success("Logged out successfully.")
        st.rerun()

    tab1, tab2, tab3 = st.tabs(["📋 Dashboard", "🛎️ Available Trips", "🚗 Use Renter Car"])

    # ------------------------ TAB 1: DASHBOARD ------------------------ #
    with tab1:
        with engine.begin() as conn:
            driver_info = conn.execute(text("""
                SELECT D.DriverID, RU.FirstName, RU.LastName, D.AvailabilityStatus,
                    D.TotalEarnings, D.Rating
                FROM Driver D
                JOIN RegisteredUsers RU ON D.UserID = RU.UserID
                WHERE D.DriverID = :did
            """), {"did": driver_id}).fetchone()

        if driver_info:
            st.markdown(f"### 👋 Welcome, {driver_info.FirstName} {driver_info.LastName}")
            st.markdown(f"**🆔 Driver ID:** `{driver_info.DriverID}`")
            st.markdown(f"**🟢 Status:** `{driver_info.AvailabilityStatus}`")
            st.markdown(f"**⭐ Rating:** `{driver_info.Rating}/5`")
            st.markdown(f"**💰 Total Earnings:** `₹{driver_info.TotalEarnings}`")

        st.markdown("---")
        st.subheader("🧾 Your Active Trip")

        with engine.begin() as conn:
            assigned_trip = None
            if "active_trip_id" in st.session_state:
                assigned_trip = conn.execute(text("""
                    SELECT TripRequestID, PickupLatitude, PickupLongitude,
                           DropoffLatitude, DropoffLongitude, Status
                    FROM TripRequest
                    WHERE TripRequestID = :tid AND Status = 'Ride-In-Process'
                """), {"tid": st.session_state.active_trip_id}).fetchone()
            else:
                driver_geo = conn.execute(text("""
                    SELECT GeohashID FROM DriverLocation WHERE DriverID = :did
                """), {"did": driver_id}).scalar()

                assigned_trip = conn.execute(text("""
                    SELECT TripRequestID, PickupLatitude, PickupLongitude,
                           DropoffLatitude, DropoffLongitude, Status
                    FROM TripRequest
                    WHERE PickupGeohashID = :geo AND Status = 'Ride-In-Process'
                """), {"geo": driver_geo}).fetchone()

        if assigned_trip:
            with st.container(border=True):
                st.markdown(f"**🆔 Trip ID:** `{assigned_trip.TripRequestID}`")
                st.markdown(f"**📍 Pickup:** `{assigned_trip.PickupLatitude:.5f}, {assigned_trip.PickupLongitude:.5f}`")
                st.markdown(f"**🏁 Dropoff:** `{assigned_trip.DropoffLatitude:.5f}, {assigned_trip.DropoffLongitude:.5f}`")
                st.markdown(f"**📌 Status:** `{assigned_trip.Status}`")

                if st.button(f"✅ Complete Trip {assigned_trip.TripRequestID}", key=f"complete_{assigned_trip.TripRequestID}"):
                    complete_trip(assigned_trip.TripRequestID)
        else:
            st.info("🛑 No active trip assigned to you.")

    # ------------------------ TAB 2: AVAILABLE TRIPS ------------------------ #
    with tab2:
        st.subheader("🛎️ Available Pending Trips Nearby")

        with engine.begin() as conn:
            trips = conn.execute(text("""
                SELECT 
                    TR.TripRequestID, 
                    TR.EstimatedCost, 
                    TR.EstimatedDistance,
                    PU.City AS PickupCity, PU.State AS PickupState,
                    DO.City AS DropoffCity, DO.State AS DropoffState,
                    TR.PickupLatitude, TR.PickupLongitude,
                    TR.DropoffLatitude, TR.DropoffLongitude
                FROM TripRequest TR
                LEFT JOIN Location PU ON PU.GeohashID = TR.PickupGeohashID
                LEFT JOIN Location DO ON DO.GeohashID = TR.DropoffGeohashID
                WHERE TR.Status = 'Pending'
            """)).fetchall()

        if trips:
            for trip in trips:
                pickup_loc = f"{trip.PickupCity}, {trip.PickupState}" if trip.PickupCity else f"{trip.PickupLatitude:.5f}, {trip.PickupLongitude:.5f}"
                dropoff_loc = f"{trip.DropoffCity}, {trip.DropoffState}" if trip.DropoffCity else f"{trip.DropoffLatitude:.5f}, {trip.DropoffLongitude:.5f}"

                with st.container(border=True):
                    st.markdown(f"**🆔 Trip ID:** `{trip.TripRequestID}`")
                    st.markdown(f"📍 **Pickup:** `{pickup_loc}`")
                    st.markdown(f"🏁 **Dropoff:** `{dropoff_loc}`")
                    st.markdown(f"📏 **Distance:** `{trip.EstimatedDistance} km`")
                    st.markdown(f"💰 **Estimated Cost:** `₹{trip.EstimatedCost}`")

                    if st.button(f"🛠 Assign Trip {trip.TripRequestID}", key=f"assign_{trip.TripRequestID}"):
                        assign_trip_to_driver(trip.TripRequestID, driver_id)
        else:
            st.info("📭 No available trips to assign.")

    # ------------------------ TAB 3: USE RENTER CAR ------------------------ #
    with tab3:
        st.subheader("🚗 Use a Renter's Car")

        with engine.begin() as conn:
            available_cars = conn.execute(text("""
                SELECT C.CarID, C.CarModel, C.CarType, C.CarStatus
                FROM Car C
                WHERE C.CarStatus = 'Available'
                AND NOT EXISTS (
                    SELECT 1 FROM Driver_Car DC WHERE DC.CarID = C.CarID
                )
            """)).fetchall()

        if available_cars:
            car_options = {f"{car.CarID} - {car.CarType} ({car.CarModel})": car.CarID for car in available_cars}
            selected_car_label = st.selectbox("Choose a car to use", list(car_options.keys()))

            if st.button("🚙 Use Selected Car"):
                selected_car_id = car_options[selected_car_label]
                try:
                    with engine.begin() as conn:
                        conn.execute(text("""
                            INSERT INTO Driver_Car (DriverID, CarID)
                            VALUES (:driver_id, :car_id)
                        """), {"driver_id": driver_id, "car_id": selected_car_id})
                    st.success(f"✅ Car `{selected_car_id}` assigned to you!")
                except Exception as e:
                    st.error(f"❌ Could not assign car: {e}")
        else:
            st.info("🚘 No available renter cars at the moment.")

# ✅ Call stored procedure to assign trip
def assign_trip_to_driver(trip_id, driver_id):
    try:
        raw_conn = engine.raw_connection()
        cursor = raw_conn.cursor()

        # Execute the stored procedure with OUTPUT parameter
        cursor.execute("""
            DECLARE @msg VARCHAR(255);
            EXEC dbo.AssignDriverToTrip @TripRequestID = ?, @DriverID = ?, @Message = @msg OUTPUT;
            SELECT @msg AS message;
        """, (trip_id, driver_id))

        # Skip to result set containing OUTPUT
        while cursor.nextset():
            if cursor.description:
                break

        result = cursor.fetchone()
        cursor.close()
        raw_conn.commit()
        raw_conn.close()

        if result and result[0]:
            # 🔥 Save assigned trip to session
            st.session_state.active_trip_id = trip_id

            st.success(f"🚀 {result[0]}")
            st.rerun()  # Force rerun so it shows immediately in the active section
        else:
            st.warning("✅ Trip assigned, but no message returned.")

    except Exception as e:
        st.error(f"❌ Failed to assign trip: {e}")


def complete_trip(trip_id):
    try:
        raw_conn = engine.raw_connection()
        cursor = raw_conn.cursor()

        # Execute the stored procedure with OUTPUT parameter
        cursor.execute("""
            DECLARE @msg VARCHAR(255);
            EXEC dbo.CompleteTrip @TripRequestID = ?, @Message = @msg OUTPUT;
            SELECT @msg AS message;
        """, (trip_id,))

        # Skip to result set containing SELECT @msg
        while cursor.nextset():
            if cursor.description:  # we found a result set
                break

        result = cursor.fetchone()
        cursor.close()
        raw_conn.commit()
        raw_conn.close()

        if result and result[0]:
            # ✅ Update driver availability status to 'Available'
            with engine.begin() as conn:
                driver_id = st.session_state.driver_id
                conn.execute(text("""
                    UPDATE Driver
                    SET AvailabilityStatus = 'Available'
                    WHERE DriverID = :did
                """), {"did": driver_id})

                # Optional: Clear active trip session
                if "active_trip_id" in st.session_state:
                    del st.session_state.active_trip_id

            st.success(f"✅ {result[0]}")
            st.rerun()  # Refresh the UI
        else:
            st.warning("Trip completed, but no message returned.")

    except Exception as e:
        st.error(f"❌ Could not complete trip: {e}")