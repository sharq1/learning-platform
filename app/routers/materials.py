import os
from datetime import datetime
from typing import List
from dataclasses import dataclass

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from schemas import Material, MaterialList
from models import User
from db import get_db
from utils import get_current_user, generate_presigned_url

# Get GCS bucket name from env
MATERIALS_BUCKET = os.getenv("MATERIALS_BUCKET", "learning-platform-materials")

# Check if we should use real GCS or mock
GCS_ENABLED = os.getenv("GCS_ENABLED", "false").lower() == "true"

# Mock storage client for development
storage_client = None

if GCS_ENABLED:
    try:
        from google.cloud import storage
        storage_client = storage.Client()
    except Exception as e:
        print(f"Warning: GCS failed to initialize: {e}")
        GCS_ENABLED = False
else:
    print("Using mock GCS client for development")
    
    # Mock classes for GCS
    @dataclass
    class MockBlob:
        name: str
        size: int
        updated: datetime
        
    class MockBucket:
        def __init__(self, name):
            self.name = name
            
        def list_blobs(self):
            # Return some mock PDFs
            return [
                MockBlob("sample1.pdf", 1024, datetime.utcnow()), 
                MockBlob("sample2.pdf", 2048, datetime.utcnow()),
                MockBlob("course_materials.pdf", 3072, datetime.utcnow()),
                MockBlob("lecture_notes.pdf", 4096, datetime.utcnow())
            ]
            
        def blob(self, name):
            return MockBlob(name, 1024, datetime.utcnow())
    
    class MockStorage:
        def bucket(self, name):
            return MockBucket(name)
            
    storage_client = MockStorage()

router = APIRouter(
    prefix="/materials",
    tags=["materials"],
    dependencies=[Depends(get_current_user)]
)


@router.get("", response_model=MaterialList)
async def list_materials(current_user: User = Depends(get_current_user)):
    """
    List all available PDF materials with presigned URLs.
    Uses mock data in development mode.
    """
    try:
        # Get bucket (real or mock)
        bucket = storage_client.bucket(MATERIALS_BUCKET)
        
        # List blobs in the bucket
        blobs = bucket.list_blobs()
        
        # Create list of materials with URLs
        materials = []
        for blob in blobs:
            # Filter for PDF files
            if blob.name.lower().endswith('.pdf'):
                # Generate URL (presigned for real GCS, static for mock)
                url = generate_presigned_url(MATERIALS_BUCKET, blob.name)
                
                # Add to materials list
                materials.append(
                    Material(
                        name=blob.name,
                        url=url,
                        size=blob.size,
                        uploaded_at=blob.updated
                    )
                )
        
        return MaterialList(materials=materials)
    
    except Exception as e:
        print(f"Error retrieving materials: {str(e)}")
        # Return empty list in development to allow testing
        if not GCS_ENABLED:
            return MaterialList(materials=[])
            
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving materials: {str(e)}"
        )
