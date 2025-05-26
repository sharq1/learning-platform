from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr


class UserCreate(UserBase):
    password: str = Field(..., min_length=8)


class UserLogin(UserBase):
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


class UserProfile(UserBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True


class Material(BaseModel):
    name: str
    url: str
    size: Optional[int] = None
    uploaded_at: Optional[datetime] = None


class MaterialList(BaseModel):
    materials: List[Material]
