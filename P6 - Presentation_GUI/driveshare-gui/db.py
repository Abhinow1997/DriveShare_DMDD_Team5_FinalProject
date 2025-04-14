from sqlalchemy import create_engine

# Update with your server and DB name
engine = create_engine(
    "mssql+pyodbc://NOVA/Team2_FinalProject_DMDD?trusted_connection=yes&driver=SQL+Server"
)