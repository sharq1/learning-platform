# FastAPI Authentication System

A secure and scalable authentication system built with FastAPI, SQLAlchemy, and JWT tokens.

## Features

- User registration with email and password
- User login with JWT tokens
- Refresh token mechanism
- Protected routes with role-based access control
- Secure password hashing with bcrypt
- Input validation with Pydantic
- Async database operations with SQLAlchemy
- Comprehensive test suite

## Prerequisites

- Python 3.8+
- PostgreSQL (or SQLite for development)
- pip (Python package manager)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fastapi-auth-system.git
   cd fastapi-auth-system
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   pip install -r requirements-test.txt
   ```

4. Set up environment variables:
   Create a `.env` file in the project root with the following variables:
   ```
   # Database
   DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/dbname
   
   # JWT
   JWT_SECRET=your_jwt_secret_key
   JWT_ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   REFRESH_TOKEN_EXPIRE_DAYS=7
   ```

## Database Setup

1. Create a PostgreSQL database:
   ```bash
   createdb your_database_name
   ```

2. Run database migrations:
   ```bash
   alembic upgrade head
   ```

## Running the Application

1. Start the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

2. The API will be available at `http://localhost:8000`

3. Access the interactive API documentation at `http://localhost:8000/docs`

## Running Tests

1. Run the test suite:
   ```bash
   pytest -v
   ```

2. Run tests with coverage report:
   ```bash
   pytest --cov=app --cov-report=term-missing
   ```

## API Endpoints

### Authentication

- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/login` - Log in and get access token
- `POST /api/auth/refresh-token` - Refresh access token
- `POST /api/auth/logout` - Log out and clear tokens
- `GET /api/auth/me` - Get current user profile

### Users

- `GET /api/users/` - List all users (admin only)
- `GET /api/users/{user_id}` - Get user by ID (admin only)
- `PUT /api/users/{user_id}` - Update user (admin or self)
- `DELETE /api/users/{user_id}` - Delete user (admin only)

## Project Structure

```
.
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration settings
│   ├── db.py                # Database connection and session
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── utils.py             # Utility functions
│   └── routers/
│       ├── __init__.py
│       ├── auth.py          # Authentication routes
│       └── users.py         # User management routes
├── tests/                   # Test files
├── alembic/                 # Database migrations
├── .env.example             # Example environment variables
├── requirements.txt         # Production dependencies
├── requirements-test.txt    # Test dependencies
└── README.md               # This file
```

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
