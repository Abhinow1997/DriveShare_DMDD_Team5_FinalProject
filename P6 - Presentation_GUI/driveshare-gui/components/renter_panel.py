
import streamlit as st
import pandas as pd
import datetime
import time
import folium
from streamlit_folium import st_folium
from sqlalchemy import text
from db import engine

def renter_login():
    st.title("🚪 Renter Login")

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
                    WHERE Type = 'Renter'
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

def show():
    if "user_id" not in st.session_state:
        renter_login()
        st.stop()

    st.sidebar.title("👤 Renter Menu")
    if st.sidebar.button("🔓 Logout"):
        del st.session_state.user_id
        st.success("Logged out successfully.")
        st.rerun()

    user_id = st.session_state.user_id

    # Get RiderID
    with engine.begin() as conn:
        renter_id = conn.execute(text("SELECT RenterID FROM Renter WHERE UserID = :uid"), {"uid": user_id}).scalar()

    if not renter_id:
        st.error("❌ Renter ID not found.")
        return

    st.title("🚕 Renter Dashboard")
    tab1, tab2 = st.tabs(["Add New Car", "My Cars"])

    # ----------------------- TAB 1 - Add New Car ----------------------- #
    with tab1:
        st.subheader("➕ Add New Car")

        car_type = st.selectbox("Car Type", ["Compact", "Sedan", "SUV", "Hatchbacks", "Minivans", "Wagon"])
        car_model = st.text_input("Car Model")
        car_year = st.number_input("Car Year", min_value=1990, max_value=datetime.datetime.now().year, value=2022)
        is_electric = st.checkbox("Electric Car")
        car_status = st.selectbox("Car Status", ["Available", "Rented", "In-Service"])
        rental_start = st.date_input("Rental Start Date")
        rental_end = st.date_input("Rental End Date", min_value=rental_start)

        if st.button("🚗 Add Car"):
            try:
                with engine.begin() as conn:
                    # 1. Insert into Car table
                    conn.execute(text("""
                        INSERT INTO Car (CarType, CarStatus, CarModel, CarYear, IsElectric)
                        VALUES (:type, :status, :model, :year, :electric)
                    """), {
                        "type": car_type,
                        "status": car_status,
                        "model": car_model,
                        "year": car_year,
                        "electric": int(is_electric)
                    })

                    # 2. Get the new CarID
                    car_id = conn.execute(text("""
                        SELECT TOP 1 CarID FROM Car ORDER BY ID DESC
                    """)).scalar()

                    # 3. Link to Renter_Car
                    conn.execute(text("""
                        INSERT INTO Renter_Car (RenterID, CarID, RentalStartDate, RentalEndDate)
                        VALUES (:rid, :cid, :start, :end)
                    """), {
                        "rid": renter_id,
                        "cid": car_id,
                        "start": rental_start.strftime("%Y-%m-%d"),
                        "end": rental_end.strftime("%Y-%m-%d")
                    })

                st.success(f"✅ Car added and linked! CarID: {car_id}")

            except Exception as e:
                st.error(f"❌ Error: {e}")

    # ----------------------- TAB 2 - My Cars ----------------------- #
    with tab2:
        st.subheader("🚗 My Cars List")

        with engine.begin() as conn:
            cars = conn.execute(text("""
                SELECT 
                    rc.CarID, c.CarType, c.CarModel, c.CarYear, 
                    c.IsElectric, c.CarStatus, rc.RentalStartDate, rc.RentalEndDate
                FROM Renter_Car rc
                JOIN Car c ON rc.CarID = c.CarID
                WHERE rc.RenterID = :rid
            """), {"rid": renter_id}).fetchall()

        if cars:
            for car in cars:
                with st.container(border=True):
                    st.markdown(f"**🆔 Car ID:** `{car.CarID}`")
                    st.markdown(f"**🚘 Type/Model:** {car.CarType} - {car.CarModel} ({car.CarYear})")
                    st.markdown(f"**🔌 Electric:** {'Yes' if car.IsElectric else 'No'}")
                    st.markdown(f"**📆 Rental Period:** {car.RentalStartDate} → {car.RentalEndDate}")
                    st.markdown(f"**📋 Status:** `{car.CarStatus}`")
                    st.markdown("---")
        else:
            st.info("No cars added yet.")
