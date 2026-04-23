from fastapi import APIRouter

from app.core.response import success_response
from app.core.security import CurrentUser

router = APIRouter()


@router.get("/me")
def get_me(current_user: CurrentUser):
    """
    获取当前登录用户信息

    需要在 Header 中携带 Authorization: Bearer <supabase_access_token>
    """
    return success_response(current_user)
