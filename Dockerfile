# Use the official Streamlit image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire app into the container
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Run the Streamlit app
ENTRYPOINT ["streamlit", "run"]
CMD ["app.py"]
