import os
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from google.cloud import storage
from datetime import datetime

from ..schemas import Material, MaterialList
from ..utils import get_current_user, generate_presigned_url
from ..models import User

router = APIRouter(
    prefix="/materials",
    tags=["materials"],
    dependencies=[Depends(get_current_user)]
)

# Get bucket name from environment variable
MATERIALS_BUCKET = os.getenv("MATERIALS_BUCKET", "learning-platform-materials")

# Google Cloud Storage client
storage_client = storage.Client()


@router.get("", response_model=MaterialList)
async def list_materials(current_user: User = Depends(get_current_user)):
    """
    List all available PDF materials with presigned URLs.
    """
    try:
        # Get bucket
        bucket = storage_client.bucket(MATERIALS_BUCKET)
        
        # List blobs in the bucket
        blobs = bucket.list_blobs()
        
        # Create list of materials with presigned URLs
        materials = []
        for blob in blobs:
            # Filter for PDF files
            if blob.name.lower().endswith('.pdf'):
                # Generate presigned URL (10 minutes expiration)
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
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving materials: {str(e)}"
        )
