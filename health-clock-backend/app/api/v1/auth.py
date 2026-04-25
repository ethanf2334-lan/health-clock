"""认证相关接口。

- POST /auth/send-sms-code    发送阿里云短信验证码
- POST /auth/verify-sms-code  校验验证码并签发 Supabase 兼容 JWT
- POST /auth/apple            校验 Apple identity token 并签发 JWT
- POST /auth/refresh          用当前有效 token 续签 access_token
- GET  /auth/me               获取当前登录用户信息（需 Bearer token）
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, status

from app.core.response import success_response
from app.core.security import CurrentUser
from app.schemas.auth import (
    AppleLoginRequest,
    SendSmsCodeRequest,
    SendSmsCodeResponse,
    VerifySmsCodeRequest,
    VerifySmsCodeResponse,
)
from app.services.aliyun_sms import AliyunSmsError, aliyun_sms_service
from app.services.apple_auth import verify_apple_identity_token
from app.services.jwt_service import sign_supabase_access_token
from app.services.user_service import ensure_user_by_apple, ensure_user_by_phone

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/send-sms-code", response_model=None)
def send_sms_code(payload: SendSmsCodeRequest):
    """发送短信验证码到指定手机号（阿里云 Dypnsapi SendSmsVerifyCode）。"""
    try:
        result = aliyun_sms_service.send_verify_code(payload.phone)
    except AliyunSmsError as exc:
        # 业务错误（签名不通过 / 频率限制 等），前端用 400 识别提示
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=exc.message) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    resp = SendSmsCodeResponse(
        phone=payload.phone,
        biz_id=result.get("biz_id"),
        interval_seconds=60,
    )
    return success_response(resp.model_dump())


@router.post("/verify-sms-code", response_model=None)
def verify_sms_code(payload: VerifySmsCodeRequest):
    """校验短信验证码，通过后确保 Supabase 用户存在并下发 access_token。"""
    try:
        passed = aliyun_sms_service.check_verify_code(payload.phone, payload.code)
    except AliyunSmsError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=exc.message) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    if not passed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码错误或已过期",
        )

    # 确保 Supabase auth.users 有对应用户
    try:
        user = ensure_user_by_phone(payload.phone)
    except RuntimeError as exc:
        logger.exception("创建/查找 Supabase 用户失败")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(exc)) from exc

    # 签发 Supabase 兼容 JWT
    try:
        token, exp_at = sign_supabase_access_token(
            user_id=user["id"],
            phone=user["phone"],
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    resp = VerifySmsCodeResponse(
        access_token=token,
        expires_at=exp_at,
        user={"id": user["id"], "phone": user["phone"]},
    )
    return success_response(resp.model_dump())


@router.post("/apple", response_model=None)
def login_with_apple(payload: AppleLoginRequest):
    """校验 Apple identity token，通过后签发 access_token。"""
    try:
        claims = verify_apple_identity_token(payload.identity_token)
        user = ensure_user_by_apple(
            claims["sub"],
            display_name=payload.full_name,
        )
        token, exp_at = sign_supabase_access_token(
            user_id=user["id"],
            email=user.get("email"),
            provider="apple",
        )
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    resp = VerifySmsCodeResponse(
        access_token=token,
        expires_at=exp_at,
        user={
            "id": user["id"],
            "phone": None,
            "email": user.get("email"),
        },
    )
    return success_response(resp.model_dump())


@router.post("/refresh", response_model=None)
def refresh_token(current_user: CurrentUser):
    """使用当前有效 access_token 续签一个新的 access_token。"""
    try:
        token, exp_at = sign_supabase_access_token(
            user_id=current_user["id"],
            phone=current_user.get("phone"),
            email=current_user.get("email"),
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(exc)) from exc

    resp = VerifySmsCodeResponse(
        access_token=token,
        expires_at=exp_at,
        user={
            "id": current_user["id"],
            "phone": current_user.get("phone"),
            "email": current_user.get("email"),
        },
    )
    return success_response(resp.model_dump())


@router.get("/me")
def get_me(current_user: CurrentUser):
    """
    获取当前登录用户信息

    需要在 Header 中携带 Authorization: Bearer <access_token>
    """
    return success_response(current_user)
