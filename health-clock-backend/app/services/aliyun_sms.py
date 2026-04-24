"""阿里云号码认证服务 (Dypnsapi 2017-05-25) 封装。

负责：
1. 调用 SendSmsVerifyCode 发送短信验证码（验证码由阿里云生成与存储）。
2. 调用 CheckSmsVerifyCode 校验验证码。

设计要点：
- 懒加载 Client，未配置 AccessKey 时才在调用时抛 RuntimeError，避免启动崩溃。
- 对外仅暴露 `send_verify_code` / `check_verify_code` 两个函数，返回普通 dict，方便上层处理。
"""

from __future__ import annotations

import json
import logging
from typing import Optional

from alibabacloud_dypnsapi20170525 import models as dy_models
from alibabacloud_dypnsapi20170525.client import Client as DypnsapiClient
from alibabacloud_tea_openapi import models as openapi_models
from Tea.exceptions import TeaException  # 阿里云 SDK 统一异常

from app.core.config import settings

logger = logging.getLogger(__name__)

_ALIYUN_ERROR_MAP: dict[str, str] = {
    "biz.FREQUENCY": "发送太频繁，请稍后再试",
    "isv.INVALID_PARAMETERS": "短信服务参数配置有误，请联系管理员",
    "isv.BUSINESS_LIMIT_CONTROL": "今日发送次数已达上限",
    "isv.SMS_SIGNATURE_ILLEGAL": "短信签名未通过审核",
    "isv.TEMPLATE_ILLEGAL": "短信模板未通过审核",
    "Forbidden.NoPermission": "短信服务暂未开通，请联系管理员",
    "UNKNOWN": "短信服务异常，请稍后重试",
}


class AliyunSmsError(Exception):
    """阿里云 SMS 相关错误，包含 code 与 message 便于前端展示。"""

    def __init__(self, code: str, message: str):
        super().__init__(f"{code}: {message}")
        self.code = code
        self.message = message


class AliyunSmsService:
    def __init__(self) -> None:
        self._client: Optional[DypnsapiClient] = None

    @property
    def client(self) -> DypnsapiClient:
        if self._client is None:
            if not settings.ALIYUN_ACCESS_KEY_ID or not settings.ALIYUN_ACCESS_KEY_SECRET:
                raise RuntimeError(
                    "阿里云未配置：请在 .env 中设置 ALIYUN_ACCESS_KEY_ID / "
                    "ALIYUN_ACCESS_KEY_SECRET / ALIYUN_SMS_SIGN_NAME / "
                    "ALIYUN_SMS_TEMPLATE_CODE"
                )
            config = openapi_models.Config(
                access_key_id=settings.ALIYUN_ACCESS_KEY_ID,
                access_key_secret=settings.ALIYUN_ACCESS_KEY_SECRET,
            )
            config.endpoint = settings.ALIYUN_DYPNSAPI_ENDPOINT or "dypnsapi.aliyuncs.com"
            self._client = DypnsapiClient(config)
        return self._client

    def _require_template(self) -> None:
        if not settings.ALIYUN_SMS_SIGN_NAME or not settings.ALIYUN_SMS_TEMPLATE_CODE:
            raise RuntimeError(
                "阿里云短信模板未配置：请在 .env 中设置 ALIYUN_SMS_SIGN_NAME 与 ALIYUN_SMS_TEMPLATE_CODE"
            )

    def send_verify_code(
        self,
        phone: str,
        *,
        code_length: int = 6,
        valid_time_seconds: int = 300,
        interval_seconds: int = 60,
    ) -> dict:
        """发送短信验证码。

        Args:
            phone: 手机号，纯数字（不含 +86），国内默认。
            code_length: 4-8，默认 6。
            valid_time_seconds: 验证码有效期（秒），默认 300。
            interval_seconds: 同一手机号最小发送间隔（秒），默认 60。

        Returns:
            {"biz_id": "...", "request_id": "..."}

        Raises:
            AliyunSmsError: 阿里云返回非 OK 时抛出。
            RuntimeError: 配置缺失。
        """
        self._require_template()

        request = dy_models.SendSmsVerifyCodeRequest(
            phone_number=phone,
            sign_name=settings.ALIYUN_SMS_SIGN_NAME,
            template_code=settings.ALIYUN_SMS_TEMPLATE_CODE,
            # 让阿里云生成验证码并占位到模板 ${code}，${min} 为有效分钟数
            template_param=json.dumps({"code": "##code##", "min": str(valid_time_seconds // 60)}),
            code_length=code_length,
            code_type=1,  # 1=纯数字
            valid_time=valid_time_seconds,
            interval=interval_seconds,
            return_verify_code=False,
        )
        if settings.ALIYUN_SMS_SCHEME_NAME:
            request.scheme_name = settings.ALIYUN_SMS_SCHEME_NAME

        try:
            response = self.client.send_sms_verify_code(request)
        except TeaException as exc:
            code = exc.code or "UNKNOWN"
            message = exc.message or "短信发送失败"
            logger.warning("SendSmsVerifyCode TeaException: %s - %s", code, message)
            raise AliyunSmsError(code, message) from exc
        except Exception as exc:  # 网络层或其他未知错误
            logger.exception("阿里云 SendSmsVerifyCode 调用失败")
            raise AliyunSmsError("SDK_ERROR", "短信服务调用失败，请稍后重试") from exc

        body = response.body
        code = getattr(body, "code", None)
        message = getattr(body, "message", "") or ""
        if code != "OK":
            logger.warning("SendSmsVerifyCode 失败: code=%s message=%s", code, message)
            friendly = _ALIYUN_ERROR_MAP.get(code, message or "发送失败")
            raise AliyunSmsError(code or "UNKNOWN", friendly)

        model = getattr(body, "model", None)
        return {
            "biz_id": getattr(model, "biz_id", None) if model else None,
            "request_id": getattr(body, "request_id", None),
        }

    def check_verify_code(self, phone: str, code: str) -> bool:
        """校验短信验证码。

        Returns:
            True 表示验证通过，False 表示验证失败。

        Raises:
            AliyunSmsError: 阿里云调用返回非 OK 时抛出（例如签名错误、未开通等）。
            RuntimeError: 配置缺失。
        """
        request = dy_models.CheckSmsVerifyCodeRequest(
            phone_number=phone,
            verify_code=code,
        )
        if settings.ALIYUN_SMS_SCHEME_NAME:
            request.scheme_name = settings.ALIYUN_SMS_SCHEME_NAME

        try:
            response = self.client.check_sms_verify_code(request)
        except TeaException as exc:
            code = exc.code or "UNKNOWN"
            message = exc.message or "校验失败"
            logger.warning("CheckSmsVerifyCode TeaException: %s - %s", code, message)
            raise AliyunSmsError(code, message) from exc
        except Exception as exc:
            logger.exception("阿里云 CheckSmsVerifyCode 调用失败")
            raise AliyunSmsError("SDK_ERROR", "短信服务调用失败，请稍后重试") from exc

        body = response.body
        api_code = getattr(body, "code", None)
        if api_code != "OK":
            message = getattr(body, "message", "") or ""
            logger.warning("CheckSmsVerifyCode 失败: code=%s message=%s", api_code, message)
            raise AliyunSmsError(api_code or "UNKNOWN", message or "校验失败")

        model = getattr(body, "model", None)
        verify_result = getattr(model, "verify_result", None) if model else None
        # PASS 表示验证通过，其他（NO_MATCH/PHONE_NUMBER_VERIFY_CODE_NOT_EXIST 等）都视为失败
        return verify_result == "PASS"


aliyun_sms_service = AliyunSmsService()
