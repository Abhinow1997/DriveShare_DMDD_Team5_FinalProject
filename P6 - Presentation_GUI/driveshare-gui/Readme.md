# 🚗 DriveShare - Ride & Rental Management System

A Streamlit-based dashboard for managing a ride-sharing and car rental platform, built with SQL Server backend. Supports Admin, Driver, and Rider panels with full encryption for sensitive user data.

---

## 🔧 Features

- **Admin Panel**: Manage users, view summaries, and add Renter/Driver/Rider accounts.
- **Driver Panel**: View and accept nearby trip requests, complete rides, and track earnings.
- **Rider Panel**: Request trips using interactive maps, track ride history and fare estimates.
- **Secure**: Encrypted sensitive information in SQL Server using symmetric key encryption.
- **Interactive Map**: Uses Folium and Streamlit integration to visualize locations.

---

## 🖥️ Tech Stack

- Python 3.10+
- Streamlit
- SQLAlchemy
- SQL Server
- PyODBC
- Folium / streamlit-folium
- Pandas

---

## ⚙️ Setup Instructions

### 1 Clone the Repo

```bash
git clone https://github.com/your-username/driveshare-dmdd.git
cd driveshare-gui
```

### 2 Create Virtual Environment
```
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```
### 3 Install Requirements

```
pip install -r requirements.txt
```

### 4 Setup the DB
Execute the following SQL scripts (in this order):

create_tables.sql

insert_script.sql

indexes_script.sql

encryption_script.sql

psm_script.sql

Update the connection string inside db.py as per your local setup :
```
engine = create_engine("mssql+pyodbc://<SERVER_NAME>/Team2_FinalProject_DMDD?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server")
```
