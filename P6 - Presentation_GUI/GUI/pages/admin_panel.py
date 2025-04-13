# pages/admin_panel.py

import streamlit as st
import pandas as pd
from sqlalchemy import text
from db import engine

def show():
    if "admin_logged_in" not in st.session_state:
        st.session_state.admin_logged_in = False
        st.session_state.admin_data = None

    if not st.session_state.admin_logged_in:
        st.title("🔐 Admin Login")
        admin_id = st.text_input("Admin ID")
        admin_pass = st.text_input("Password", type="password")

        if st.button("Login"):
            with engine.connect() as conn:
                result = conn.execute(
                    text("SELECT AdminID, FirstName, LastName FROM Admin WHERE AdminID = :id AND Password = :pwd"),
                    {"id": admin_id, "pwd": admin_pass}
                ).fetchone()

                if result:
                    st.session_state.admin_logged_in = True
                    st.session_state.admin_data = {
                        "AdminID": result.AdminID,
                        "FirstName": result.FirstName,
                        "LastName": result.LastName
                    }
                    st.rerun()
                else:
                    st.error("Invalid credentials ❌")

    else:
        admin = st.session_state.admin_data
        st.success(f"Welcome, {admin['FirstName']} {admin['LastName']} 👋")
        if st.button("Logout"):
            st.session_state.admin_logged_in = False
            st.session_state.admin_data = None
            st.rerun()

        st.header("📋 Admin Dashboard")
        tab1, tab2, tab3 = st.tabs(["Registered Users", "Admin Summary", "Add New User"])

        with tab1:
            st.subheader("👥 All Registered Users")
            df_users = pd.read_sql(
                text("SELECT * FROM RegisteredUsers WHERE AdminID = :id"),
                engine,
                params={"id": admin["AdminID"]}
            )
            st.dataframe(df_users)

        with tab2:
            st.subheader("📊 Admin User Count")
            df_summary = pd.read_sql("SELECT * FROM vw_AdminUserCount", engine)
            st.dataframe(df_summary)

        with tab3:
            st.subheader("➕ Add New Registered User")
            new_firstname = st.text_input("First Name", key="new_fname")
            new_lastname = st.text_input("Last Name", key="new_lname")
            new_password = st.text_input("Password", type="password", key="new_pass")
            new_email = st.text_input("Email", key="new_email")
            new_phone = st.text_input("Phone Number", key="new_phone")
            new_type = st.selectbox("User Type", ["Renter", "Driver", "Rider"], key="new_type")

            if st.button("Add User", key="add_user_btn"):
                if all([new_firstname, new_password, new_email, new_phone, new_type]):
                    try:
                        with engine.begin() as trans:
                            trans.execute(text("""
                                INSERT INTO RegisteredUsers (AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type)
                                VALUES (:admin_id, :fname, :lname, :pwd, :email, :phone, :utype)
                            """), {
                                "admin_id": admin["AdminID"],
                                "fname": new_firstname,
                                "lname": new_lastname,
                                "pwd": new_password,
                                "email": new_email,
                                "phone": new_phone,
                                "utype": new_type
                            })

                            new_user = trans.execute(text("SELECT TOP 1 UserID FROM RegisteredUsers ORDER BY ID DESC")).fetchone()
                            new_user_id = new_user.UserID

                            if new_type == "Renter":
                                trans.execute(text("""
                                    INSERT INTO Renter (UserID, TotalRentedCars, TotalEarnings, TotalRentalTime, CompanyName)
                                    VALUES (:uid, 0, 0.00, 0, NULL)
                                """), {"uid": new_user_id})
                            elif new_type == "Driver":
                                trans.execute(text("""
                                    INSERT INTO Driver (UserID, LicenseNo, AvailabilityStatus, TotalCompletedRides, TotalEarnings, Rating)
                                    VALUES (:uid, 'AUTO1234', 'Available', 0, 0.00, 0.0)
                                """), {"uid": new_user_id})
                            elif new_type == "Rider":
                                trans.execute(text("""
                                    INSERT INTO Rider (UserID, TotalPreviousRides, AmountDue)
                                    VALUES (:uid, 0, 0.00)
                                """), {"uid": new_user_id})

                        st.success(f"✅ User added successfully! UserID: {new_user_id}")
                    except Exception as e:
                        st.error(f"❌ Error: {e}")
                else:
                    st.warning("Please fill in all required fields.")
