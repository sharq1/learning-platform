import os
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession

from .db import get_db, engine
from .models import Base
from .routers import auth, materials, users

# Create FastAPI app
app = FastAPI(
    title="Learning Platform API",
    description="API for the Learning Platform application",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For production, specify the actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(materials.router)
app.include_router(users.router)


# Create database tables on startup
@app.on_event("startup")
async def startup():
    # Create tables if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


@app.get("/")
async def root():
    """Root endpoint with API info"""
    return {
        "app": "Learning Platform API",
        "version": "1.0.0",
        "endpoints": [
            {"path": "/signup", "method": "POST", "description": "Register a new user"},
            {"path": "/login", "method": "POST", "description": "Authenticate and get JWT token"},
            {"path": "/materials", "method": "GET", "description": "List available learning materials"},
            {"path": "/profile", "method": "GET", "description": "Get user profile information"},
        ]
    }
