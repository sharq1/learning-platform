import pytest
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
from app.models import User
from app.utils import get_password_hash

# Test user data
TEST_USER_EMAIL = "test@example.com"
TEST_USER_PASSWORD = "TestPass123!"
TEST_USER_HASHED_PASSWORD = get_password_hash(TEST_USER_PASSWORD)

# Fixture to create a test user
@pytest.fixture(scope="function")
async def test_user(db_session):
    async with db_session as session:
        test_user = User(
            email=TEST_USER_EMAIL,
            hashed_password=TEST_USER_HASHED_PASSWORD,
            is_active=True,
            is_admin=False,
            created_at=datetime.utcnow(),
            last_login=datetime.utcnow()
        )
        session.add(test_user)
        await session.commit()
        await session.refresh(test_user)
        return test_user

# Test cases
@pytest.mark.asyncio
async def test_register_user(client, test_user):
    # Test successful registration
    response = await client.post(
        "/api/auth/signup",
        json={
            "email": "newuser@example.com",
            "password": "NewPass123!",
            "password_confirm": "NewPass123!"
        }
    )
    assert response.status_code == 201
    assert "id" in response.json()
    assert response.json()["email"] == "newuser@example.com"
    assert "hashed_password" not in response.json()

    # Test duplicate registration
    response = await client.post(
        "/api/auth/signup",
        json={
            "email": "newuser@example.com",
            "password": "NewPass123!",
            "password_confirm": "NewPass123!"
        }
    )
    assert response.status_code == 400
    assert "Email already registered" in response.json()["detail"]

    # Test invalid password
    response = await client.post(
        "/api/auth/signup",
        json={
            "email": "anotheruser@example.com",
            "password": "weak",
            "password_confirm": "weak"
        }
    )
    assert response.status_code == 400
    assert "Password must be at least 8 characters" in response.json()["detail"]

@pytest.mark.asyncio
async def test_login(client, test_user):
    # Test successful login
    response = await client.post(
        "/api/auth/login",
        data={
            "username": TEST_USER_EMAIL,
            "password": TEST_USER_PASSWORD
        }
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["token_type"] == "bearer"
    
    # Check cookies
    cookies = response.cookies
    assert "access_token" in cookies
    assert "refresh_token" in cookies
    
    # Test invalid credentials
    response = await client.post(
        "/api/auth/login",
        data={
            "username": TEST_USER_EMAIL,
            "password": "wrongpassword"
        }
    )
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

@pytest.mark.asyncio
async def test_refresh_token(client, test_user):
    # First, log in to get a refresh token
    login_response = await client.post(
        "/api/auth/login",
        data={
            "username": TEST_USER_EMAIL,
            "password": TEST_USER_PASSWORD
        }
    )
    refresh_token = login_response.cookies.get("refresh_token")
    
    # Test token refresh
    response = await client.post(
        "/api/auth/refresh-token",
        cookies={"refresh_token": refresh_token}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
    
    # Test invalid refresh token
    response = await client.post(
        "/api/auth/refresh-token",
        cookies={"refresh_token": "invalid_token"}
    )
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_current_user(client, test_user):
    # First, log in to get an access token
    login_response = await client.post(
        "/api/auth/login",
        data={
            "username": TEST_USER_EMAIL,
            "password": TEST_USER_PASSWORD
        }
    )
    access_token = login_response.json()["access_token"]
    
    # Test getting current user
    response = await client.get(
        "/api/auth/me",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 200
    assert response.json()["email"] == TEST_USER_EMAIL
    
    # Test with invalid token
    response = await client.get(
        "/api/auth/me",
        headers={"Authorization": "Bearer invalid_token"}
    )
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_logout(client, test_user):
    # First, log in to get an access token
    login_response = await client.post(
        "/api/auth/login",
        data={
            "username": TEST_USER_EMAIL,
            "password": TEST_USER_PASSWORD
        }
    )
    
    # Test logout
    response = await client.post("/api/auth/logout")
    assert response.status_code == 200
    assert response.json()["message"] == "Successfully logged out"
    
    # Check that cookies are cleared
    cookies = response.cookies
    assert cookies.get("access_token") == ""
    assert cookies.get("refresh_token") == ""
