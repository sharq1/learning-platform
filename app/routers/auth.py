from fastapi import APIRouter, Depends, HTTPException, status, Request, Response, Security
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer, SecurityScopes
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import timedelta, datetime, timezone
from typing import Optional, Dict, Any, List

from jose import jwt, JWTError
from pydantic import ValidationError

from db import get_db, async_session
from models import User
from schemas import (
    UserCreate, 
    UserResponse, 
    Token, 
    TokenData, 
    UserLogin,
    HTTPError,
    StandardResponse
)
from utils import (
    verify_password, 
    get_password_hash, 
    create_access_token, 
    create_refresh_token,
    SECRET_KEY,
    ALGORITHM,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    REFRESH_TOKEN_EXPIRE_DAYS,
    get_current_user,
    get_current_active_user,
    get_current_admin_user,
    validate_password_strength
)

# Create router
router = APIRouter(prefix="/auth", tags=["auth"])

@router.post(
    "/signup", 
    status_code=status.HTTP_201_CREATED, 
    response_model=UserResponse,
    responses={
        400: {"model": HTTPError, "description": "Bad Request - Invalid input or email already registered"},
        500: {"model": HTTPError, "description": "Internal Server Error"}
    }
)
async def signup(
    user_data: UserCreate, 
    db: AsyncSession = Depends(get_db)
) -> UserResponse:
    """
    Register a new user with email and password.
    
    - **email**: User's email address (must be unique)
    - **password**: User's password (min 8 characters)
    - **password_confirm**: Must match the password field
    
    Returns the created user's information without sensitive data.
    """
    # Check if user already exists
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Validate password strength
    if not validate_password_strength(user_data.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 8 characters long and contain a number, uppercase letter, and special character"
        )
    
    try:
        # Create new user
        hashed_password = get_password_hash(user_data.password)
        new_user = User(
            email=user_data.email, 
            hashed_password=hashed_password,
            is_active=True,
            created_at=datetime.now(timezone.utc),
            is_admin=False  # Default to non-admin
        )
        
        # Add to database
        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)
        
        # Return user data without sensitive information
        return UserResponse(
            id=new_user.id,
            email=new_user.email,
            is_active=new_user.is_active,
            is_admin=new_user.is_admin,
            created_at=new_user.created_at,
            last_login=new_user.last_login
        )
        
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the user"
        ) from e


@router.post(
    "/login", 
    response_model=Token,
    responses={
        400: {"model": HTTPError, "description": "Bad Request - Invalid input or inactive user"},
        401: {"model": HTTPError, "description": "Unauthorized - Incorrect credentials"},
        500: {"model": HTTPError, "description": "Internal Server Error"}
    }
)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
) -> JSONResponse:
    """
    OAuth2 compatible token login, get an access token for future requests.
    
    - **username**: User's email address
    - **password**: User's password
    
    Returns access and refresh tokens in HTTP-only cookies and a JSON response.
    """
    # Find user by email
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalars().first()
    
    # Check if user exists and password is correct
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Check if user is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    try:
        # Update last login time
        user.last_login = datetime.now(timezone.utc)
        db.add(user)
        await db.commit()
        
        # Determine user role(s)
        user_roles = ["user"]
        if user.is_admin:
            user_roles.append("admin")
        
        # Create tokens
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": str(user.id), "email": user.email, "scopes": user_roles},
            expires_delta=access_token_expires
        )
        
        refresh_token_expires = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        refresh_token = create_refresh_token(
            data={"sub": str(user.id), "email": user.email},
            expires_delta=refresh_token_expires
        )
        
        # Create response with basic token info
        response_data = {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": int(access_token_expires.total_seconds())
        }
        
        response = JSONResponse(
            content=response_data,
            status_code=status.HTTP_200_OK
        )
        
        # Set secure, HTTP-only cookies
        response.set_cookie(
            key="access_token",
            value=f"Bearer {access_token}",
            httponly=True,
            max_age=int(access_token_expires.total_seconds()),
            secure=False,  # Set to True in production with HTTPS
            samesite="lax",
            path="/"
        )
        
        response.set_cookie(
            key="refresh_token",
            value=refresh_token,
            httponly=True,
            max_age=int(refresh_token_expires.total_seconds()),
            secure=False,  # Set to True in production with HTTPS
            samesite="lax",
            path="/"
        )
        
        return response
        
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during login"
        ) from e


@router.post(
    "/refresh-token", 
    response_model=Token,
    responses={
        401: {"model": HTTPError, "description": "Unauthorized - Invalid or missing refresh token"},
        500: {"model": HTTPError, "description": "Internal Server Error"}
    }
)
async def refresh_token(
    request: Request,
    db: AsyncSession = Depends(get_db)
) -> JSONResponse:
    """
    Refresh an access token using a refresh token.
    
    The refresh token should be provided as an HTTP-only cookie.
    Returns a new access token and updates the refresh token in cookies.
    """
    # Get refresh token from cookies
    refresh_token = request.cookies.get("refresh_token")
    if not refresh_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not refresh access token - no refresh token provided",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    try:
        # Verify refresh token
        payload = jwt.decode(
            refresh_token, 
            SECRET_KEY, 
            algorithms=[ALGORITHM],
            options={"verify_aud": False}
        )
        
        # Extract user ID from token
        user_id = payload.get("sub")
        user_email = payload.get("email")
        
        if not user_id or not user_email:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token - missing user information",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Get user from database
        result = await db.execute(select(User).where(User.id == user_id, User.email == user_email))
        user = result.scalars().first()
        
        if user is None or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Determine user role(s)
        user_roles = ["user"]
        if user.is_admin:
            user_roles.append("admin")
        
        # Create new tokens
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": str(user.id), "email": user.email, "scopes": user_roles},
            expires_delta=access_token_expires
        )
        
        refresh_token_expires = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        new_refresh_token = create_refresh_token(
            data={"sub": str(user.id), "email": user.email},
            expires_delta=refresh_token_expires
        )
        
        # Create response with new access token
        response_data = {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": int(access_token_expires.total_seconds())
        }
        
        response = JSONResponse(
            content=response_data,
            status_code=status.HTTP_200_OK
        )
        
        # Update the refresh token in the cookie
        response.set_cookie(
            key="access_token",
            value=f"Bearer {access_token}",
            httponly=True,
            max_age=int(access_token_expires.total_seconds()),
            secure=False,  # Set to True in production with HTTPS
            samesite="lax",
            path="/"
        )
        
        response.set_cookie(
            key="refresh_token",
            value=new_refresh_token,
            httponly=True,
            max_age=int(refresh_token_expires.total_seconds()),
            secure=False,  # Set to True in production with HTTPS
            samesite="lax",
            path="/"
        )
        
        return response
        
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while refreshing the token"
        ) from e


@router.post(
    "/logout",
    response_model=StandardResponse,
    responses={
        200: {"model": StandardResponse, "description": "Successfully logged out"},
        500: {"model": HTTPError, "description": "Internal Server Error"}
    }
)
async def logout() -> JSONResponse:
    """
    Log out the current user by clearing authentication cookies.
    
    Clears both access and refresh token cookies.
    """
    try:
        # Create response
        response = JSONResponse(
            content={"message": "Successfully logged out"},
            status_code=status.HTTP_200_OK
        )
        
        # Clear the access token cookie
        response.delete_cookie(
            key="access_token",
            path="/"
        )
        
        # Clear the refresh token cookie
        response.delete_cookie(
            key="refresh_token",
            path="/"
        )
        
        return response
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during logout"
        ) from e


@router.get(
    "/me",
    response_model=UserResponse,
    responses={
        200: {"model": UserResponse, "description": "Successfully retrieved user information"},
        401: {"model": HTTPError, "description": "Not authenticated"},
        403: {"model": HTTPError, "description": "Inactive user"},
        500: {"model": HTTPError, "description": "Internal Server Error"}
    }
)
async def get_current_user_profile(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
) -> UserResponse:
    """
    Get the current authenticated user's profile information.
    
    Returns the user's details including email, account status, and role.
    Requires a valid access token.
    """
    try:
        # Refresh user data from database to ensure it's current
        result = await db.execute(select(User).where(User.id == current_user.id))
        user = result.scalars().first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
            
        return UserResponse(
            id=user.id,
            email=user.email,
            is_active=user.is_active,
            is_admin=user.is_admin,
            created_at=user.created_at,
            last_login=user.last_login
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching user profile"
        ) from e
