"""JWT 验证与 Supabase 客户端依赖。

自签 JWT 策略：
- 我们的 /auth/verify-sms-code 用 SUPABASE_JWT_SECRET (HS256) 自签 access_token，
  payload 格式与 Supabase GoTrue 原生 token 一致（aud=authenticated, sub=<uuid>）。
- get_current_user 直接本地解码 JWT，不走远程 GoTrue API，
  这样既不依赖 Supabase session，也能兼容 RLS（auth.uid() = sub）。
"""

import logging
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import ExpiredSignatureError, JWTError, jwt
from supabase import Client, create_client

from app.core.config import settings

logger = logging.getLogger(__name__)
security = HTTPBearer()


def get_supabase_client() -> Client:
    """获取 Supabase Admin 客户端（用 service_role_key）。"""
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
) -> dict:
    """
    本地验证 JWT（HS256 / SUPABASE_JWT_SECRET），返回 {id, phone, email}。

    兼容两种 token：
    1. 我们自签的 token（/auth/verify-sms-code 下发）
    2. 如果将来接入 Supabase 原生 OAuth，其 token 也用同一 secret 签发

    Raises:
        HTTPException 401: token 无效或已过期
        HTTPException 503: 未配置 SUPABASE_JWT_SECRET
    """
    if not settings.SUPABASE_JWT_SECRET:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="服务未配置 JWT 密钥，请联系管理员",
        )

    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated",
        )
    except ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="登录已过期，请重新登录",
        )
    except JWTError as exc:
        logger.warning("JWT 验证失败: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的认证凭证",
        )

    user_id: str | None = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的认证凭证",
        )

    return {
        "id": user_id,
        "phone": payload.get("phone"),
        "email": payload.get("email"),
        "role": payload.get("role", "authenticated"),
    }


# 类型别名，方便在路由中使用
CurrentUser = Annotated[dict, Depends(get_current_user)]
SupabaseClient = Annotated[Client, Depends(get_supabase_client)]
