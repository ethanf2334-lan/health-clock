from fastapi import APIRouter

from app.core.response import success_response

router = APIRouter()


@router.post("/upload-signature")
def get_upload_signature():
    return success_response({"upload_url": "", "object_key": ""})
