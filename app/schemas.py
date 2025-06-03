from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

class UserRole(str, Enum):
    USER = "user"
    ADMIN = "admin"

class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Password must be at least 8 characters long")
    password_confirm: str = Field(..., description="Must match the password field")
    
    @validator('password_confirm')
    def passwords_match(cls, v, values, **kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('passwords do not match')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int = Field(..., description="Token expiration time in seconds")

class TokenData(BaseModel):
    email: Optional[str] = None
    user_id: Optional[int] = None

class UserResponse(UserBase):
    id: int
    is_active: bool
    is_admin: bool
    created_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        orm_mode = True
        schema_extra = {
            "example": {
                "id": 1,
                "email": "user@example.com",
                "is_active": True,
                "is_admin": False,
                "created_at": "2023-01-01T00:00:00",
                "last_login": "2023-01-01T12:00:00"
            }
        }

class UserInDB(UserResponse):
    hashed_password: str

class MaterialBase(BaseModel):
    name: str
    description: Optional[str] = None
    url: str
    size: Optional[int] = None
    content_type: Optional[str] = None

class MaterialCreate(MaterialBase):
    pass

class Material(MaterialBase):
    id: int
    uploaded_at: datetime
    uploaded_by: int
    
    class Config:
        orm_mode = True

class MaterialList(BaseModel):
    materials: List[Material]
    total: int
    page: int
    pages: int

class HTTPError(BaseModel):
    detail: str
    
    class Config:
        schema_extra = {
            "example": {"detail": "Error message"}
        }

class StandardResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Dict[str, Any]] = None
