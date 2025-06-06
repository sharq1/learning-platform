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
MATERIALS_BUCKET = os.getenv("MATERIALS_BUCKET")
if not MATERIALS_BUCKET:
    raise RuntimeError("MATERIALS_BUCKET environment variable not set.")

# Attempt to initialize Google Cloud Storage client
storage_client = None
try:
    from google.cloud import storage
    storage_client = storage.Client()
    print(f"Successfully initialized GCS client for bucket: {MATERIALS_BUCKET}")
except Exception as e:
    print(f"Critical: GCS client failed to initialize: {e}. Material listing will not work.")
    # Depending on desired behavior, you might raise an error here to prevent app startup
    # or allow it to run but endpoints will fail.

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
    if not storage_client:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="GCS client is not available. Cannot retrieve materials."
        )

    try:
        # Get bucket
        bucket = storage_client.bucket(MATERIALS_BUCKET)
        
        # List blobs in the bucket
        blobs = bucket.list_blobs()
        
        # Create list of materials with URLs
        materials = []
        pdf_blobs = [blob for blob in blobs if blob.name.lower().endswith('.pdf')]
        
        for blob in pdf_blobs:
            # Generate presigned URL
            url = generate_presigned_url(storage_client, MATERIALS_BUCKET, blob.name)
            
            # Add to materials list
            materials.append(
                Material(
                    name=blob.name,
                    url=url,
                    size=blob.size,
                    uploaded_at=blob.updated,
                    uploaded_by=current_user.id
                )
            )
        
        # Return MaterialList with required pagination fields
        return MaterialList(
            materials=materials,
            total=len(materials),
            page=1,  # Default to page 1 since we're not implementing pagination yet
            pages=1   # Only 1 page since we're not implementing pagination yet
        )
    
    except Exception as e:
        print(f"Error retrieving materials: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving materials: {str(e)}"
        )
