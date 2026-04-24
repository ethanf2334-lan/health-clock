"""手机号短信登录相关 Schema。"""

from __future__ import annotations

import re

from pydantic import BaseModel, Field, field_validator


# 国内手机号：11 位，1 开头；允许前缀 +86 或 86 被前端剥离，这里只管纯 11 位
_CN_PHONE_RE = re.compile(r"^1\d{10}$")


def _normalize_cn_phone(value: str) -> str:
    v = value.strip().replace(" ", "").replace("-", "")
    if v.startswith("+86"):
        v = v[3:]
    elif v.startswith("86") and len(v) == 13:
        v = v[2:]
    if not _CN_PHONE_RE.match(v):
        raise ValueError("手机号格式不正确，请输入 11 位国内手机号")
    return v


class SendSmsCodeRequest(BaseModel):
    phone: str = Field(..., description="国内手机号，支持 +86/86 前缀")

    @field_validator("phone")
    @classmethod
    def _v_phone(cls, v: str) -> str:
        return _normalize_cn_phone(v)


class SendSmsCodeResponse(BaseModel):
    phone: str
    biz_id: str | None = None
    interval_seconds: int = 60


class VerifySmsCodeRequest(BaseModel):
    phone: str
    code: str

    @field_validator("phone")
    @classmethod
    def _v_phone(cls, v: str) -> str:
        return _normalize_cn_phone(v)

    @field_validator("code")
    @classmethod
    def _v_code(cls, v: str) -> str:
        import re as _re
        # 只保留数字字符（兼容短信格式化空格、不可见字符等）
        digits = _re.sub(r"\D", "", v)
        if len(digits) < 4 or len(digits) > 8:
            raise ValueError("验证码长度不正确")
        return digits


class VerifySmsCodeResponse(BaseModel):
    access_token: str
    expires_at: int
    user: dict
