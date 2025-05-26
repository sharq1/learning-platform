from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_db
from ..models import User
from ..schemas import UserProfile
from ..utils import get_current_user

router = APIRouter(
    prefix="/profile",
    tags=["users"],
    dependencies=[Depends(get_current_user)]
)


@router.get("", response_model=UserProfile)
async def get_profile(current_user: User = Depends(get_current_user)):
    """
    Get profile information for the currently authenticated user.
    """
    return UserProfile(
        id=current_user.id,
        email=current_user.email,
        created_at=current_user.created_at
    )
