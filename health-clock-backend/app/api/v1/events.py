from fastapi import APIRouter

from app.core.response import success_response

router = APIRouter()


@router.get("")
def list_events():
    return success_response([])
