# Learning Platform API

This is a simple API for a learning platform built with FastAPI and Uvicorn. It's designed to work with GCP infrastructure including Cloud Run, Cloud SQL, Cloud Memorystore, and Cloud Storage.

## Features

- User authentication with JWT tokens
- User registration and login
- PDF material listing with presigned URLs
- User profile information
- Async database operations with SQLAlchemy
- Redis for session management
- Google Cloud Storage integration for learning materials

## Development

### Prerequisites

- Python 3.11+
- PostgreSQL
- Redis
- Google Cloud SDK

### Environment Variables

The following environment variables are used by the application:

```
DB_HOST=<postgresql-host>
DB_NAME=<database-name>
DB_USER=<database-user>
DB_PASSWORD=<database-password>
REDIS_HOST=<redis-host>
REDIS_PORT=<redis-port>
REDIS_PASSWORD=<redis-password>
JWT_SECRET=<your-jwt-secret>
MATERIALS_BUCKET=<gcs-bucket-name>
```

### Running Locally

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the application:
   ```bash
   uvicorn main:app --reload
   ```

3. Access the API at http://localhost:8000

## Deployment

The application is deployed to Google Cloud Run using Cloud Build. The deployment process is defined in the Terraform configuration in the `iac` directory.

## API Endpoints

- `POST /signup` - Register a new user
- `POST /login` - Authenticate and get JWT token
- `GET /materials` - List available learning materials
- `GET /profile` - Get user profile information
- `GET /health` - Health check endpoint
- `GET /` - API information
