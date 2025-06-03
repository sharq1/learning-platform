import os
from fastapi import FastAPI, Depends, HTTPException, Request, status, APIRouter, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, RedirectResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List, Dict, Any

from db import get_db, engine, async_session
from models import Base, User
from routers import auth, materials, users
from schemas import UserResponse, Token
from utils import (
    get_current_user,
    get_password_hash,
    oauth2_scheme,
    get_current_active_user,
    get_current_admin_user
)

# Create FastAPI app
app = FastAPI(
    title="Learning Platform",
    description="Learning Platform with JWT Authentication",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For production, specify the actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers with prefix
api_router = APIRouter(prefix="/api")
api_router.include_router(auth.router)
api_router.include_router(materials.router)
api_router.include_router(users.router)
app.include_router(api_router)

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Serve index.html for the root path
@app.get("/", response_class=FileResponse, include_in_schema=False)
async def read_root():
    return FileResponse("static/index.html")

# Catch-all route for SPA routing
@app.get("/{full_path:path}", include_in_schema=False)
async def catch_all(full_path: str):
    # If the path has an extension, it's probably a static file
    if Path(full_path).suffix:
        return FileResponse(f"static/{full_path}")
    # Otherwise, serve the index.html for SPA routing
    return FileResponse("static/index.html")

# Create database tables on startup
@app.on_event("startup")
async def startup():
    # Create tables if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Create a default admin user if no users exist
    async with get_db() as db:
        result = await db.execute(select(User))
        if not result.scalars().first():
            hashed_password = get_password_hash("admin123")
            admin_user = User(
                email="admin@example.com",
                hashed_password=hashed_password,
                is_admin=True
            )
            db.add(admin_user)
            await db.commit()
            print("Created default admin user: admin@example.com / admin123")

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
