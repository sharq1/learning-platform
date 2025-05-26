FROM python:3.11-slim

WORKDIR /app

# Copy requirements file
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Expose port 8080
EXPOSE 8080

# Run the application with uvicorn server
ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
