import streamlit as st
import json
import pandas as pd
import boto3
from io import BytesIO

# AWS S3 Configuration
BUCKET_NAME = 'phonedirectorybucket'
FILE_NAME = 'phone_directory.json'

# Initialize S3 client
s3 = boto3.client('s3')

# Function to load data from S3
def load_data():
    try:
        obj = s3.get_object(Bucket=BUCKET_NAME, Key=FILE_NAME)
        data = json.load(obj['Body'])
    except s3.exceptions.NoSuchKey:
        data = []
    return data

# Function to save data to S3
def save_data(data):
    s3.put_object(Bucket=BUCKET_NAME, Key=FILE_NAME, Body=json.dumps(data, indent=4))

# Load existing data
data = load_data()

# Streamlit app layout
st.title("Phone Directory Web App")

# Input form
st.header("Add New Entry")
name = st.text_input("Employee Name")
email = st.text_input("Email")
mobile = st.text_input("Mobile Number")

if st.button("Add Entry"):
    if name and email and mobile:
        new_entry = {"name": name, "email": email, "mobile": mobile}
        data.append(new_entry)
        save_data(data)
        st.success("Entry added successfully!")
    else:
        st.error("Please fill in all fields.")

# Display data
if st.button("Display Directory"):
    if data:
        df = pd.DataFrame(data)
        st.header("Phone Directory")
        st.table(df)
    else:
        st.warning("No data available.")
