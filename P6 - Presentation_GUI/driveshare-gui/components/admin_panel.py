import streamlit as st
import pandas as pd
from sqlalchemy import text
from time import sleep
from db import engine
import re

def is_valid_email(email):
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

def is_valid_phone(phone):
    return re.match(r"^\d{10}$", phone)

def is_strong_password(password):
    return len(password) >= 6

def reports_viewer():
    import streamlit as st

    st.title("Invoices Logging 📊")

    st.image("P6 - Presentation_GUI/driveshare-gui/visualization_report/RiderandInvoices.png")
    st.image("P6 - Presentation_GUI/driveshare-gui/visualization_report/DriverEarningsvsCompletedRides.png")
    st.markdown("[🔗 Open Full Dashboard](https://public.tableau.com/views/DMDD_Assignment/RiderandInvoices)")

def show():
    if "admin_logged_in" not in st.session_state:
        st.session_state.admin_logged_in = False
        st.session_state.admin_data = None

    if not st.session_state.admin_logged_in:
        st.title("🔐 Admin Login")
        admin_id = st.text_input("Admin ID")
        admin_pass = st.text_input("Password", type="password")

        if st.button("Login"):
            with engine.begin() as conn:
                conn.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))
                result = conn.execute(text("""
                    SELECT 
                        AdminID,
                        CONVERT(VARCHAR(40), DecryptByKey([Password])) AS DecryptedPassword,
                        CONVERT(VARCHAR(40), DecryptByKey([FirstName])) AS FirstName,
                        CONVERT(VARCHAR(40), DecryptByKey([LastName])) AS LastName
                    FROM Admin
                    WHERE AdminID = :id
                """), {"id": admin_id}).fetchone()

                if result and result.DecryptedPassword == admin_pass:
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

        st.sidebar.title("👤 Admin Menu")
        st.sidebar.markdown(f"**Logged in as:** `{admin['FirstName']} {admin['LastName']}`")
        if st.sidebar.button("🔓 Logout"):
            st.session_state.admin_logged_in = False
            st.session_state.admin_data = None
            st.success("Logged out successfully.")
            st.rerun()

        st.header("📋 Admin Dashboard")
        tab1, tab2, tab3, tab4 = st.tabs(["Registered Users", "Admin Summary", "Add New User", "Reports"])

        # TAB 1 - Show Decrypted Registered Users
        with tab1:
            st.subheader("👥 All Registered Users")
            with engine.begin() as conn:
                conn.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))
                df_users = pd.read_sql(text("""
                    SELECT 
                        UserID,
                        CONVERT(VARCHAR(50), DecryptByKey(EmailID)) AS EmailID,
                        CONVERT(VARCHAR(15), DecryptByKey(PhoneNumber)) AS PhoneNumber,
                        Type,
                        AdminID
                    FROM RegisteredUsers
                    WHERE AdminID = :id
                """), conn, params={"id": admin["AdminID"]})
                st.dataframe(df_users)

        # TAB 2 - Admin User Summary with Decryption
        with tab2:
            st.subheader("📊 Admin User Count")
            with engine.begin() as conn:
                conn.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))
                df_summary = pd.read_sql(text("""
                    SELECT 
                        A.AdminID,
                        CONVERT(VARCHAR(40), DecryptByKey(A.FirstName)) AS FirstName,
                        CONVERT(VARCHAR(40), DecryptByKey(A.LastName)) AS LastName,
                        COUNT(RU.UserID) AS UserCount
                    FROM Admin A
                    LEFT JOIN RegisteredUsers RU ON A.AdminID = RU.AdminID
                    GROUP BY A.AdminID, A.FirstName, A.LastName
                """), conn)
                st.dataframe(df_summary)

        with tab4:
            reports_viewer()


        with tab3:
            st.subheader("➕ Add New Registered User")

            # Common Fields
            new_firstname = st.text_input("First Name", key="new_fname")
            new_lastname = st.text_input("Last Name", key="new_lname")
            new_password = st.text_input("Password", type="password", key="new_pass")
            new_email = st.text_input("Email", key="new_email")
            new_phone = st.text_input("Phone Number", key="new_phone")
            new_type = st.selectbox("User Type", ["Renter", "Driver", "Rider"], key="new_type")

            # Role-specific Fields
            new_license = None
            new_company = None

            if new_type == "Driver":
                new_license = st.text_input("License Number", key="driver_license")
            elif new_type == "Renter":
                new_company = st.text_input("Company Name", key="renter_company")

            if st.button("Add User", key="add_user_btn"):
                # Clean inputs
                new_firstname = new_firstname.strip()
                new_lastname = new_lastname.strip()
                new_password = new_password.strip()
                new_email = new_email.strip()
                new_phone = new_phone.strip()
                if new_license:
                    new_license = new_license.strip()
                if new_company:
                    new_company = new_company.strip()

                # Collect validation issues
                errors = []

                if not new_firstname:
                    errors.append("First name is required.")
                if not new_lastname:
                    errors.append("Last name is required.")
                if not new_email or not is_valid_email(new_email):
                    errors.append("A valid email is required.")
                if not new_phone or not is_valid_phone(new_phone):
                    errors.append("Phone number must be 10 digits.")
                if not new_password or not is_strong_password(new_password):
                    errors.append("Password must be at least 6 characters long.")
                if new_type == "Driver" and not new_license:
                    errors.append("License number is required for drivers.")
                if new_type == "Renter" and not new_company:
                    errors.append("Company name is required for renters.")

                if errors:
                    for err in errors:
                        st.warning(f"⚠️ {err}")
                else:
                    try:
                        with engine.begin() as trans:
                            trans.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))

                            # Check if email already exists
                            existing = trans.execute(text("""
                                SELECT COUNT(*) FROM RegisteredUsers
                                WHERE CONVERT(VARCHAR(100), DecryptByKey(EmailID)) = :email
                            """), {"email": new_email}).scalar()

                            if existing > 0:
                                st.error("❌ Email is already registered.")
                            else:
                                # Insert into RegisteredUsers
                                trans.execute(text("""
                                    INSERT INTO RegisteredUsers (
                                        AdminID, FirstName, LastName, Password, EmailID, PhoneNumber, Type
                                    )
                                    VALUES (
                                        :admin_id,
                                        :fname,
                                        :lname,
                                        EncryptByKey(Key_GUID('DriveShareSymmetricKey'), CAST(:pwd AS VARCHAR(100))),
                                        EncryptByKey(Key_GUID('DriveShareSymmetricKey'), CAST(:email AS VARCHAR(100))),
                                        EncryptByKey(Key_GUID('DriveShareSymmetricKey'), CAST(:phone AS VARCHAR(20))),
                                        :utype
                                    )
                                """), {
                                    "admin_id": admin["AdminID"],
                                    "fname": new_firstname,
                                    "lname": new_lastname,
                                    "pwd": new_password,
                                    "email": new_email,
                                    "phone": new_phone,
                                    "utype": new_type
                                })

                                # Get new UserID
                                new_user = trans.execute(text("SELECT TOP 1 UserID FROM RegisteredUsers ORDER BY ID DESC")).fetchone()
                                new_user_id = new_user.UserID

                                # Role-specific Inserts
                                if new_type == "Renter":
                                    trans.execute(text("""
                                        INSERT INTO Renter (UserID, TotalRentedCars, TotalEarnings, TotalRentalTime, CompanyName)
                                        VALUES (:uid, 0, 0.00, 0, :company)
                                    """), {"uid": new_user_id, "company": new_company})
                                    new_renter = trans.execute(text("""
                                        SELECT TOP 1 RenterID FROM Renter WHERE UserID = :uid ORDER BY ID DESC
                                    """), {"uid": new_user_id}).fetchone()
                                    st.info(f"🆕 Renter created with RenterID: {new_renter.RenterID}")

                                elif new_type == "Driver":
                                    trans.execute(text("""
                                        INSERT INTO Driver (UserID, LicenseNo, AvailabilityStatus, TotalCompletedRides, TotalEarnings, Rating)
                                        VALUES (:uid, :license, 'Available', 0, 0.00, 0.0)
                                    """), {"uid": new_user_id, "license": new_license})

                                    new_driver = trans.execute(text("""
                                        SELECT TOP 1 DriverID FROM Driver WHERE UserID = :uid ORDER BY ID DESC
                                    """), {"uid": new_user_id}).fetchone()

                                    if new_driver:
                                        st.info(f"🆕 Driver created with DriverID: {new_driver.DriverID}")

                                        geo = trans.execute(text("""
                                            SELECT TOP 1 GeohashID
                                            FROM Location
                                            WHERE State = 'New York'
                                            ORDER BY NEWID()
                                        """)).scalar()

                                        if geo:
                                            trans.execute(text("""
                                                INSERT INTO DriverLocation (DriverID, GeohashID)
                                                VALUES (:did, :geo)
                                            """), {"did": new_driver.DriverID, "geo": geo})
                                            st.info(f"📍 Driver location initialized in NY (Geohash: {geo})")
                                        else:
                                            st.warning("⚠️ No available location in NY to assign.")
                                    else:
                                        st.warning("⚠️ Driver insert attempted but not found in table.")

                                elif new_type == "Rider":
                                    trans.execute(text("""
                                        INSERT INTO Rider (UserID, TotalPreviousRides, AmountDue)
                                        VALUES (:uid, 0, 0.00)
                                    """), {"uid": new_user_id})
                                    new_rider = trans.execute(text("""
                                        SELECT TOP 1 RiderID FROM Rider WHERE UserID = :uid ORDER BY ID DESC
                                    """), {"uid": new_user_id}).fetchone()
                                    st.info(f"🆕 Rider created with RiderID: {new_rider.RiderID}")

                        st.success(f"✅ User added successfully! UserID: {new_user_id}")
                        sleep(5)
                        st.rerun()

                    except Exception as e:
                        st.error(f"❌ Error: {e}")