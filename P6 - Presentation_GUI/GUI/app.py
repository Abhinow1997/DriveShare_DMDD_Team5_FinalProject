import streamlit as st
from pages import admin_panel  # More panels coming soon

st.set_page_config(page_title="DriveShare Admin Portal", layout="wide")

st.sidebar.title("🚦 Select Role")
role = st.sidebar.selectbox("Login as", ["Select", "Admin", "Driver", "Rider"])

if role == "Admin":
    admin_panel.show()
elif role == "Driver":
    st.warning("🚧 Driver panel coming soon!")
elif role == "Rider":
    st.warning("🚧 Rider panel coming soon!")
