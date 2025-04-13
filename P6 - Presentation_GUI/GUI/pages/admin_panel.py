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

        if st.button("Logout"):
            st.session_state.admin_logged_in = False
            st.session_state.admin_data = None
            st.rerun()

        st.header("📋 Admin Dashboard")
        tab1, tab2, tab3 = st.tabs(["Registered Users", "Admin Summary", "Add New User"])

        # TAB 1 - Show Decrypted Registered Users
        with tab1:
            st.subheader("👥 All Registered Users (Decrypted)")
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

        with tab3:
            st.subheader("➕ Add New Registered User")

            new_firstname = st.text_input("First Name", key="new_fname")
            new_lastname = st.text_input("Last Name", key="new_lname")
            new_password = st.text_input("Password", type="password", key="new_pass")
            new_email = st.text_input("Email", key="new_email")
            new_phone = st.text_input("Phone Number", key="new_phone")
            new_type = st.selectbox("User Type", ["Renter", "Driver", "Rider"], key="new_type")

            if st.button("Add User", key="add_user_btn"):
                new_firstname = new_firstname.strip()
                new_lastname = new_lastname.strip()
                new_password = new_password.strip()
                new_email = new_email.strip()
                new_phone = new_phone.strip()

                if all([new_firstname, new_lastname, new_password, new_email, new_phone, new_type]):
                    try:
                        with engine.begin() as trans:
                            trans.execute(text("OPEN SYMMETRIC KEY DriveShareSymmetricKey DECRYPTION BY CERTIFICATE DriveShareCert"))

                            # 1️⃣ Insert into RegisteredUsers
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

                            # 2️⃣ Get the newly added UserID
                            new_user = trans.execute(text("SELECT TOP 1 UserID FROM RegisteredUsers ORDER BY ID DESC")).fetchone()
                            new_user_id = new_user.UserID

                            # 3️⃣ Insert into the appropriate role table
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

                                # ✅ Confirm Rider insert and retrieve RiderID
                                new_rider = trans.execute(text("""
                                    SELECT TOP 1 RiderID FROM Rider WHERE UserID = :uid ORDER BY ID DESC
                                """), {"uid": new_user_id}).fetchone()

                                if new_rider:
                                    st.info(f"🆕 Rider created with RiderID: {new_rider.RiderID}")
                                else:
                                    st.warning("⚠️ Rider insert attempted but not found in table.")

                        st.success(f"✅ User added successfully! UserID: {new_user_id}")

                    except Exception as e:
                        st.error(f"❌ Error: {e}")
                else:
                    st.warning("Please fill in all required fields.")