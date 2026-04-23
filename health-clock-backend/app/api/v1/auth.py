from fastapi import APIRouter

from app.core.response import success_response

router = APIRouter()


@router.get("/me")
def get_me():
    return success_response({"user_id": "mock_user_id"})
