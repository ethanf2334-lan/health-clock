"""Supabase `auth.users` 用户同步。

阿里云验证码通过后，需要在 Supabase 里确保对应手机号的用户存在，
以便业务表（profile_members 等）外键 `auth.users(id)` 能成立，
也让 `auth.uid()` 在 RLS 中有值。
"""

from __future__ import annotations

import logging
from typing import Optional

import httpx
from supabase import Client, create_client

from app.core.config import settings

logger = logging.getLogger(__name__)


def _require_admin_client() -> Client:
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        raise RuntimeError(
            "Supabase 未配置：缺少 SUPABASE_URL 或 SUPABASE_SERVICE_ROLE_KEY"
        )
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)


def _normalize_phone(phone: str) -> str:
    """Supabase auth.users.phone 存储时会去掉 + 号。

    这里统一去前导 +，方便比对。上层调用可以传 "+86..." 或 "86..."。
    """
    p = phone.strip()
    if p.startswith("+"):
        p = p[1:]
    return p


def _search_user_by_phone_via_rest(phone_no_plus: str) -> Optional[dict]:
    """走 Admin REST 的 filter，避免 list_users 全量分页。

    GET /auth/v1/admin/users?phone=<phone> 目前不是官方文档化接口，
    所以用 filter 参数语法。失败返回 None。
    """
    url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/admin/users"
    headers = {
        "apikey": settings.SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}",
    }
    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(url, headers=headers, params={"phone": phone_no_plus})
            if resp.status_code != 200:
                return None
            data = resp.json()
            users = data.get("users") if isinstance(data, dict) else data
            if not users:
                return None
            for u in users:
                if _normalize_phone(u.get("phone") or "") == phone_no_plus:
                    return u
            return None
    except Exception:
        logger.exception("查询 Supabase 用户失败（REST fallback）")
        return None


def ensure_user_by_phone(phone: str) -> dict:
    """按手机号查找或创建一个 Supabase 用户。

    Returns:
        {"id": "<uuid>", "phone": "<no_plus>"}
    """
    phone_no_plus = _normalize_phone(phone)
    admin = _require_admin_client()

    # 1) 先尝试创建 —— 最常见路径
    try:
        resp = admin.auth.admin.create_user(
            {
                "phone": phone_no_plus,
                "phone_confirm": True,
            }
        )
        user = getattr(resp, "user", None) or (resp if isinstance(resp, dict) else None)
        if user:
            uid = getattr(user, "id", None) or (user.get("id") if isinstance(user, dict) else None)
            if uid:
                return {"id": uid, "phone": phone_no_plus}
    except Exception as exc:
        err_text = str(exc).lower()
        # 已注册：phone_exists / user_already_exists / "A User with this ... already exists"
        if "exist" not in err_text and "register" not in err_text and "already" not in err_text:
            logger.warning("create_user 未知错误，尝试 fallback 查找: %s", exc)

    # 2) 尝试走 REST filter 直接按 phone 查
    found = _search_user_by_phone_via_rest(phone_no_plus)
    if found and found.get("id"):
        return {"id": found["id"], "phone": phone_no_plus}

    # 3) fallback：分页遍历 admin.list_users，最多翻 5 页
    try:
        for page in range(1, 6):
            result = admin.auth.admin.list_users(page=page, per_page=1000)
            users = result if isinstance(result, list) else getattr(result, "users", []) or []
            if not users:
                break
            for u in users:
                u_phone = getattr(u, "phone", None)
                if u_phone is None and isinstance(u, dict):
                    u_phone = u.get("phone")
                if _normalize_phone(u_phone or "") == phone_no_plus:
                    uid = getattr(u, "id", None) or (u.get("id") if isinstance(u, dict) else None)
                    if uid:
                        return {"id": uid, "phone": phone_no_plus}
            if len(users) < 1000:
                break
    except Exception:
        logger.exception("list_users fallback 失败")

    raise RuntimeError(f"无法创建或查找手机号 {phone} 对应的 Supabase 用户")
