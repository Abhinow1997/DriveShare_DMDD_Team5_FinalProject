import streamlit as st
# import pyodbc     # not needed if login is bypassed
# from db import get_connection   # not needed if login is bypassed

def validate_inputs(username, password):
    return username.strip() != "" and password.strip() != ""

def show():
    st.title("Renter Login Panel")

    st.markdown("### Please enter your credentials below:")

    username = st.text_input("Renter Username")
    password = st.text_input("Renter Password", type="password")

    if st.button("Login"):
        if not validate_inputs(username, password):
            st.warning("❗ All fields are required.")
            return

        # 👇👇👇 COMMENTED BLOCK: Login Authentication Bypassed 👇👇👇
        """
        try:
            conn = get_connection()
            cursor = conn.cursor()

            cursor.execute("OPEN SYMMETRIC KEY DriveShareKey DECRYPTION BY CERTIFICATE DriveShareCert;")

            query = '''
                SELECT r.RenterID,
                       u.FirstName,
                       u.LastName
                FROM RegisteredUsers u
                JOIN Renter r ON r.RegisteredUserID = u.ID
                WHERE u.UserID = ?
                  AND CONVERT(VARCHAR, DecryptByKey(u.Password)) = ?
                  AND u.Type = 'Renter'
            '''

            cursor.execute(query, (username, password))
            result = cursor.fetchone()

            if result:
                renter_id, fname, lname = result
        """
        # 👇👇👇 SIMULATED LOGIN SUCCESS 👇👇👇
        renter_id = 1
        fname = username  # use input username as display name
        lname = "Test"

        st.success(f"✅ Login Successful! Welcome, {fname} {lname} (Renter ID: {renter_id})")
        st.markdown("### 🚗 Renter Dashboard")
        st.info("Dashboard features for renters will appear here.")

        """
            else:
                st.error("❌ Invalid username or password.")

        except Exception as e:
            st.error(f"⚠️ Error during login: {e}")

        finally:
            try:
                cursor.execute("CLOSE SYMMETRIC KEY DriveShareKey;")
                conn.close()
            except:
                pass
        """
