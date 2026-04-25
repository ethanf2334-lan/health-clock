"""Apple 登录 identity token 验证。"""

from __future__ import annotations

import time

import httpx
from jose import JWTError, jwt

from app.core.config import settings

APPLE_ISSUER = "https://appleid.apple.com"
APPLE_KEYS_URL = "https://appleid.apple.com/auth/keys"


def verify_apple_identity_token(identity_token: str) -> dict:
    """验证 Apple identity token 并返回 claims。

    需要在 `.env` 配置 `APPLE_CLIENT_ID`，iOS App 通常填写 Bundle ID。
    """
    if not settings.APPLE_CLIENT_ID:
        raise RuntimeError("APPLE_CLIENT_ID 未配置，请填写 iOS Bundle ID 或 Apple Service ID")

    try:
        header = jwt.get_unverified_header(identity_token)
    except JWTError as exc:
        raise ValueError("Apple identity token 格式无效") from exc

    kid = header.get("kid")
    if not kid:
        raise ValueError("Apple identity token 缺少 kid")

    with httpx.Client(timeout=10.0) as client:
        jwks = client.get(APPLE_KEYS_URL).json()

    keys = jwks.get("keys", [])
    key = next((item for item in keys if item.get("kid") == kid), None)
    if not key:
        raise ValueError("未找到匹配的 Apple 公钥")

    try:
        claims = jwt.decode(
            identity_token,
            key,
            algorithms=["RS256"],
            audience=settings.APPLE_CLIENT_ID,
            issuer=APPLE_ISSUER,
        )
    except JWTError as exc:
        raise ValueError("Apple identity token 验证失败") from exc

    if int(claims.get("exp", 0)) <= int(time.time()):
        raise ValueError("Apple identity token 已过期")
    if not claims.get("sub"):
        raise ValueError("Apple identity token 缺少用户标识")

    return claims
