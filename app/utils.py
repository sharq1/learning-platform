import os
import secrets
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, Union, List, Tuple

from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm, SecurityScopes
from fastapi.security.utils import get_authorization_scheme_param
from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from starlette.status import HTTP_403_FORBIDDEN

from db import get_db

# Import models and schemas
from models import User
from schemas import TokenData, UserRole

# Security configuration
SECRET_KEY = os.getenv("JWT_SECRET", secrets.token_urlsafe(32))
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30  # 30 minutes
REFRESH_TOKEN_EXPIRE_DAYS = 7  # 7 days

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="auth/login",
    auto_error=False
)

# Scopes for different user roles
SCOPES = {
    UserRole.USER: ["read:own_profile", "read:materials"],
    UserRole.ADMIN: ["read:all_profiles", "manage:users", "read:materials", "write:materials"]
}

# Password verification and hashing
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hash a password for storing."""
    return pwd_context.hash(password)

# Token creation
def create_access_token(
    data: Dict[str, Any], 
    expires_delta: Optional[timedelta] = None
) -> str:
    """Create a new JWT access token."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(
    data: Dict[str, Any], 
    expires_delta: Optional[timedelta] = None
) -> str:
    """Create a new JWT refresh token."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Authentication and authorization
async def get_current_user(
    security_scopes: SecurityScopes,
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Get the current user from the JWT token.
    
    Args:
        security_scopes: Security scopes required for the endpoint
        token: JWT token from the request
        db: Database session
        
    Returns:
        User: The authenticated user
        
    Raises:
        HTTPException: If the token is invalid or user not found
    """
    if security_scopes.scopes:
        authenticate_value = f'Bearer scope=\"{security_scopes.scope_str}\"'
    else:
        authenticate_value = "Bearer"
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": authenticate_value},
    )
    
    if not token:
        raise credentials_exception
    
    try:
        # Remove 'Bearer ' prefix if present
        if token.startswith("Bearer "):
            token = token.split(" ")[1]
            
        # Decode JWT token
        payload = jwt.decode(
            token, 
            SECRET_KEY, 
            algorithms=[ALGORITHM],
            options={"verify_aud": False}
        )
        
        # Extract user ID and email from token
        user_id = payload.get("sub")
        email = payload.get("email")
        token_type = payload.get("type")
        
        if not user_id or not email or token_type != "access":
            raise credentials_exception
            
        token_data = TokenData(email=email, user_id=user_id)
    except (JWTError, ValidationError):
        raise credentials_exception
    
    # Get user from database
    result = await db.execute(select(User).where(User.email == token_data.email))
    user = result.scalars().first()
    
    if user is None or not user.is_active:
        raise credentials_exception
    
    # Check scopes if required
    if security_scopes.scopes:
        user_scopes = SCOPES[UserRole.ADMIN] if user.is_admin else SCOPES[UserRole.USER]
        for scope in security_scopes.scopes:
            if scope not in user_scopes:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Not enough permissions",
                    headers={"WWW-Authenticate": authenticate_value},
                )
    
    return user

# Role-based access control
async def get_current_active_user(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Check if the current user is active.
    
    Args:
        current_user: The current authenticated user
        db: Database session
        
    Returns:
        User: The active user
        
    Raises:
        HTTPException: If the user is inactive
    """
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user"
        )
    
    # Refresh user data from database
    result = await db.execute(select(User).where(User.id == current_user.id))
    user = result.scalars().first()
    
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found or inactive"
        )
        
    return user

async def get_current_admin_user(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """
    Check if the current user is an admin.
    
    Args:
        current_user: The current authenticated user
        
    Returns:
        User: The admin user
        
    Raises:
        HTTPException: If the user is not an admin
    """
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions - admin role required",
        )
    return current_user

# Token verification
def verify_token(token: str) -> Dict[str, Any]:
    """
    Verify a JWT token and return the payload.
    
    Args:
        token: JWT token to verify
        
    Returns:
        Dict: The decoded token payload
        
    Raises:
        HTTPException: If the token is invalid or expired
    """
    try:
        # Remove 'Bearer ' prefix if present
        if token.startswith("Bearer "):
            token = token.split(" ")[1]
            
        payload = jwt.decode(
            token, 
            SECRET_KEY, 
            algorithms=[ALGORITHM],
            options={"verify_aud": False}
        )
        return payload
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )

# Password strength validation
def validate_password_strength(password: str) -> bool:
    """
    Check if a password meets the strength requirements.
    
    Requirements:
    - At least 8 characters long
    - At least one uppercase letter
    - At least one digit
    - At least one special character
    
    Args:
        password: The password to validate
        
    Returns:
        bool: True if the password meets the requirements, False otherwise
    """
    if len(password) < 8:
        return False
    if not any(c.isupper() for c in password):
        return False
    if not any(c.isdigit() for c in password):
        return False
    if not any(c in "!@#$%^&*()_+{}[]|\:;'<>,.?/\"" for c in password):
        return False
    return True


def generate_presigned_url(bucket_name: str, blob_name: str, expiration: int = 3600) -> str:
    """
    Generate a presigned URL for accessing a file in GCS.
    In development mode, returns a mock URL.
    
    Args:
        bucket_name: Name of the GCS bucket
        blob_name: Name of the blob (file) in the bucket
        expiration: Expiration time in seconds (default: 1 hour)
        
    Returns:
        str: Presigned URL for accessing the file
    """
    # Check if we're using real GCS or mock storage
    if os.getenv("GCS_ENABLED", "false").lower() == "true":
        try:
            from google.cloud import storage
            from google.cloud.storage import Blob
            
            # Initialize the client
            client = storage.Client()
            bucket = client.bucket(bucket_name)
            blob = bucket.blob(blob_name)
            
            # Generate the signed URL
            url = blob.generate_signed_url(
                version="v4",
                expiration=timedelta(seconds=expiration),
                method="GET"
            )
            return url
            
        except Exception as e:
            print(f"Error generating presigned URL: {e}")
            # Fall back to mock URL if there's an error
            return f"https://storage.googleapis.com/{bucket_name}/{blob_name}?mock=true"
    else:
        # In development, return a mock URL
        return f"http://localhost:8080/static/mock_files/{blob_name}"
