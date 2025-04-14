import streamlit as st
from components import admin_panel ,rider_panel, driver_panel

st.set_page_config(page_title="DriveShare Admin Portal", layout="wide")

st.sidebar.title("🚦 Select Role")
role = st.sidebar.selectbox("Login as", ["Select", "Admin", "Driver", "Rider"])

if role == "Admin":
    admin_panel.show()
elif role == "Driver":
    driver_panel.show()
elif role == "Rider":
    rider_panel.show()
