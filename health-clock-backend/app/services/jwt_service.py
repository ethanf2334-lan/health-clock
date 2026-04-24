"""Supabase 兼容 JWT 签发。

用 Supabase 控制台的 JWT Secret (HS256) 签发符合 Supabase GoTrue
结构的 access_token，使 Supabase Auth REST (`/auth/v1/user`) 以及
Postgres RLS 的 `auth.uid()` / `auth.jwt()` 都能直接识别。
"""

from __future__ import annotations

import time
import uuid
from typing import Optional

from jose import jwt

from app.core.config import settings

DEFAULT_ACCESS_TOKEN_TTL_SECONDS = 60 * 60 * 24 * 7  # 7 天


def _require_secret() -> str:
    if not settings.SUPABASE_JWT_SECRET:
        raise RuntimeError(
            "SUPABASE_JWT_SECRET 未配置：请从 Supabase Dashboard -> Settings -> API "
            "-> JWT Settings 复制 JWT Secret 并写入 .env"
        )
    return settings.SUPABASE_JWT_SECRET


def sign_supabase_access_token(
    user_id: str,
    *,
    phone: Optional[str] = None,
    email: Optional[str] = None,
    ttl_seconds: int = DEFAULT_ACCESS_TOKEN_TTL_SECONDS,
) -> tuple[str, int]:
    """签发一个 Supabase 格式的 access_token。

    Returns:
        (token, expires_at_unix_seconds)
    """
    secret = _require_secret()

    now = int(time.time())
    exp = now + ttl_seconds

    issuer = settings.SUPABASE_URL.rstrip("/") + "/auth/v1" if settings.SUPABASE_URL else "supabase"

    payload = {
        "aud": "authenticated",
        "iss": issuer,
        "sub": user_id,
        "role": "authenticated",
        "iat": now,
        "exp": exp,
        "session_id": str(uuid.uuid4()),
        "aal": "aal1",
        "amr": [{"method": "otp", "timestamp": now}],
        "app_metadata": {"provider": "phone", "providers": ["phone"]},
        "user_metadata": {},
    }
    if phone:
        payload["phone"] = phone
    if email:
        payload["email"] = email

    token = jwt.encode(payload, secret, algorithm="HS256")
    return token, exp
