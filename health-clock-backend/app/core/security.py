from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from supabase import Client, create_client

from app.core.config import settings

security = HTTPBearer()


def get_supabase_client() -> Client:
    """获取 Supabase 客户端"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    supabase: Annotated[Client, Depends(get_supabase_client)],
) -> dict:
    """
    验证 Supabase JWT token 并返回当前用户信息

    Raises:
        HTTPException: 401 如果 token 无效或过期
    """
    token = credentials.credentials

    try:
        # 验证 token 并获取用户信息
        user_response = supabase.auth.get_user(token)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
            )

        return {
            "id": user_response.user.id,
            "email": user_response.user.email,
            "phone": user_response.user.phone,
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication failed: {str(e)}",
        )


# 类型别名，方便在路由中使用
CurrentUser = Annotated[dict, Depends(get_current_user)]
SupabaseClient = Annotated[Client, Depends(get_supabase_client)]
