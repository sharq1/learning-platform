import os
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, HTMLResponse
from pathlib import Path
from sqlalchemy.ext.asyncio import AsyncSession

from db import get_db, engine
from models import Base
from routers.auth import router as auth_router
from routers.materials import router as materials_router
from routers.users import router as users_router

# Create FastAPI app
app = FastAPI(
    title="Learning Platform API",
    description="API for the Learning Platform application",
    version="1.0.0"
)

# # Mount static files
# app.mount("/static", StaticFiles(directory="static"), name="static")

# # Serve index.html for the root path
# @app.get("/", response_class=HTMLResponse, include_in_schema=False)
# async def read_root():
#     return FileResponse('static/index.html')

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For production, specify the actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
app.include_router(materials_router)
app.include_router(users_router)

# Catch-all route for SPA routing
@app.get("/{full_path:path}", include_in_schema=False)
async def catch_all(full_path: str):
    # If the path has an extension, it's probably a static file
    if Path(full_path).suffix:
        return FileResponse(f"static/{full_path}")
    # Otherwise, serve the index.html for SPA routing
    return FileResponse('static/index.html')


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
