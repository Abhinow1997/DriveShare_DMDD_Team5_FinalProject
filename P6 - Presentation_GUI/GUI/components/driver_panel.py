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

    # ⛔ LOGOUT
    st.sidebar.title("👤 Driver Menu")
    if st.sidebar.button("🔓 Logout"):
        del st.session_state.driver_id
        st.success("Logged out successfully.")
        st.rerun()

    with engine.begin() as conn:
        # Driver info
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

    # 🚗 View assigned trips
    st.subheader("🧾 Your Active Trip")

    with engine.begin() as conn:
        # Get driver's current geohash from DriverLocation
        driver_geo = conn.execute(text("""
            SELECT GeohashID FROM DriverLocation WHERE DriverID = :did
        """), {"did": driver_id}).scalar()

        # Find the trip assigned (pickup matches driver's location and is In-Process)
        assigned_trip = conn.execute(text("""
            SELECT TripRequestID, PickupLatitude, PickupLongitude, DropoffLatitude, DropoffLongitude, Status
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

    st.markdown("---")

    # 🗺️ Available pending trips in driver's state (optional)
    st.subheader("🛎️ Available Pending Trips Nearby")
    with engine.begin() as conn:
        nearby = conn.execute(text("""
            SELECT TR.TripRequestID, TR.PickupLatitude, TR.PickupLongitude,
                TR.DropoffLatitude, TR.DropoffLongitude, TR.State, TR.EstimatedCost, TR.EstimatedDistance
            FROM TripRequest TR
            WHERE TR.Status = 'Pending'
        """)).fetchall()

    if nearby:
        for trip in nearby:
            with st.container(border=True):
                st.markdown(f"**Trip ID:** `{trip.TripRequestID}` | State: `{trip.State}`")
                st.markdown(f"📍 Pickup: `{trip.PickupLatitude:.5f}, {trip.PickupLongitude:.5f}`")
                st.markdown(f"🏁 Dropoff: `{trip.DropoffLatitude:.5f}, {trip.DropoffLongitude:.5f}`")
                st.markdown(f"**$US** Trip Cost : `{trip.EstimatedCost}`")
                st.markdown(f"Travel Distance : `{trip.EstimatedDistance}` km")
                if st.button(f"🛠 Assign Trip {trip.TripRequestID}", key=f"assign_{trip.TripRequestID}"):
                    assign_trip_to_driver(trip.TripRequestID, driver_id)

    else:
        st.info("📭 No available trips to assign.")


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

        # Advance to the result set containing the OUTPUT
        while cursor.nextset():
            if cursor.description:  # We've found a result set
                break

        result = cursor.fetchone()
        cursor.close()
        raw_conn.commit()
        raw_conn.close()

        if result and result[0]:
            st.success(f"🚀 {result[0]}")
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
            st.success(f"✅ {result[0]}")
        else:
            st.warning("Trip completed, but no message returned.")

    except Exception as e:
        st.error(f"❌ Could not complete trip: {e}")