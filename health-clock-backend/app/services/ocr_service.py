import base64
import logging

import requests

from app.core.config import settings

logger = logging.getLogger(__name__)


class OCRService:
    """
    百度 OCR 服务。

    调用链：
      1. POST https://aip.baidubce.com/oauth/2.0/token  → 获取 Access Token
      2a. POST .../ocr/v1/health_report                  → 体检报告专用（优先）
      2b. POST .../ocr/v1/accurate_basic                 → 通用高精度（降级）
    """

    BASE = "https://aip.baidubce.com"

    def __init__(self):
        self.api_key = settings.BAIDU_OCR_API_KEY
        self.secret_key = settings.BAIDU_OCR_SECRET_KEY
        self._access_token: str | None = None

    # ------------------------------------------------------------------ #
    #  Token
    # ------------------------------------------------------------------ #

    def _get_access_token(self) -> str:
        """懒加载并缓存 Access Token（进程内缓存，有效期 30 天）。"""
        if self._access_token:
            return self._access_token

        url = f"{self.BASE}/oauth/2.0/token"
        params = {
            "grant_type": "client_credentials",
            "client_id": self.api_key,
            "client_secret": self.secret_key,
        }
        try:
            resp = requests.post(url, params=params, timeout=15)
            data = resp.json()
            if "access_token" not in data:
                raise ValueError(f"Token 响应异常: {data}")
            self._access_token = data["access_token"]
            logger.info("百度 OCR Token 获取成功")
            return self._access_token
        except Exception as e:
            raise RuntimeError(f"获取百度 OCR Token 失败: {e}") from e

    # ------------------------------------------------------------------ #
    #  内部：下载图片 → base64
    # ------------------------------------------------------------------ #

    def _image_to_base64(self, image_url: str) -> str:
        resp = requests.get(image_url, timeout=30)
        resp.raise_for_status()
        return base64.b64encode(resp.content).decode("utf-8")

    # ------------------------------------------------------------------ #
    #  接口 1：体检报告专用 OCR（health_report）
    # ------------------------------------------------------------------ #

    def recognize_health_report(self, image_url: str) -> dict:
        """
        调用百度「体检报告识别」接口。

        百度实际返回格式（words_result）：
            {
              "words_result": [
                {"word": "桐庐县第二人民医院", "word_name": "医院名称"},
                {"word": "消化内科",           "word_name": "科室"},
                {"word": "结肠炎",             "word_name": "检查提示"},
                ...
              ]
            }

        本方法统一返回：
            {
              "ocr_text": "拼接的可读文本",
              "structured": {"医院名称": "xxx", "科室": "xxx", ...}   # word_name → word
            }
        """
        token = self._get_access_token()
        url = f"{self.BASE}/rest/2.0/ocr/v1/health_report?access_token={token}"
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        data = {"image": self._image_to_base64(image_url), "type": "normal"}

        resp = requests.post(url, headers=headers, data=data, timeout=30)
        result = resp.json()
        logger.debug("health_report 原始响应 keys: %s", list(result.keys()))

        if "error_code" in result:
            raise RuntimeError(
                f"health_report 识别失败 [{result.get('error_code')}]: "
                f"{result.get('error_msg', '未知错误')}"
            )

        words: list[dict] = result.get("words_result", [])

        # 兼容旧式 med_result 格式（血项体检单）
        med_results: list[dict] = result.get("med_result", [])

        if not words and not med_results:
            raise RuntimeError("health_report 返回空结果，降级处理")

        # ---- 处理 words_result 格式 ----
        if words:
            structured: dict[str, str] = {}
            for item in words:
                word_name = item.get("word_name", "").strip()
                word = item.get("word", "").strip()
                if word_name and word:
                    structured[word_name] = word

            # 拼接可读文本（过滤空值）
            lines = [f"{k}: {v}" for k, v in structured.items() if v]
            ocr_text = "\n".join(lines)
            return {"ocr_text": ocr_text, "structured": structured, "format": "words"}

        # ---- 处理旧式 med_result 格式（血检指标）----
        lines = []
        for item in med_results:
            name = item.get("org_name", "")
            val = item.get("result", "")
            unit = item.get("unit", "")
            norm = item.get("norm", "")
            flag = item.get("flag", "")
            parts = [name]
            if val:
                parts.append(f": {val} {unit}".strip())
            if norm:
                parts.append(f"(参考范围: {norm})")
            if flag:
                parts.append(f"[{flag}]")
            lines.append(" ".join(parts))

        return {
            "ocr_text": "\n".join(lines),
            "structured": med_results,
            "format": "med",
        }

    # ------------------------------------------------------------------ #
    #  接口 2：通用高精度 OCR（accurate_basic，降级用）
    # ------------------------------------------------------------------ #

    def recognize_general(self, image_url: str) -> str:
        """调用「通用文字识别（高精度）」，返回纯文本。"""
        token = self._get_access_token()
        url = f"{self.BASE}/rest/2.0/ocr/v1/accurate_basic?access_token={token}"
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        data = {
            "image": self._image_to_base64(image_url),
            "detect_direction": "true",
            "paragraph": "true",
        }

        resp = requests.post(url, headers=headers, data=data, timeout=30)
        result = resp.json()

        if "error_code" in result:
            raise RuntimeError(
                f"accurate_basic 识别失败 [{result.get('error_code')}]: "
                f"{result.get('error_msg', '未知错误')}"
            )

        return "\n".join(
            item.get("words", "") for item in result.get("words_result", [])
        )

    # ------------------------------------------------------------------ #
    #  主入口：优先 health_report，失败则降级
    # ------------------------------------------------------------------ #

    def process_document(self, image_url: str) -> dict:
        """
        完整识别流程，返回供 documents.py 直接使用的结构：

            {
              "ocr_text": str,
              "ai_summary": {
                  "examination_items": [...],  # 来自 health_report 结构化数据
                  "abnormal_indicators": [...],
                  ...
              },
              "candidate_events": [...],
            }
        """
        # ---- 中文字段名 → ai_summary 标准字段 的映射 ----
        _WORD_NAME_MAP = {
            "医院名称": "hospital_name",
            "医院":     "hospital_name",
            "科室":     "department",
            "报告日期": "document_date",
            "检查日期": "document_date",
            "报告名称": "report_name",
            "检查方法": "examination_method",
            "检查所见": "examination_findings",
            "检查提示": "diagnosis",
            "临床诊断": "diagnosis",
            "建议":     "follow_up_raw",
            "姓名":     "patient_name",
            "年龄":     "patient_age",
            "性别":     "patient_gender",
        }

        # ---- 尝试体检报告专用接口 ----
        try:
            hr = self.recognize_health_report(image_url)
            ocr_text = hr["ocr_text"]
            structured = hr["structured"]
            fmt = hr.get("format", "words")
            logger.info("health_report 识别成功，format=%s，ocr_text 长度=%d", fmt, len(ocr_text))

            ai_summary: dict = {}

            if fmt == "words" and isinstance(structured, dict):
                # words_result 格式：{中文字段名: 值}
                for cn_key, value in structured.items():
                    en_key = _WORD_NAME_MAP.get(cn_key)
                    if en_key:
                        ai_summary[en_key] = value
                    # 未映射的字段也保留（用中文key直接展示）
                    else:
                        ai_summary[cn_key] = value

                # 日期格式化 20260413 → 2026-04-13
                if "document_date" in ai_summary:
                    raw_date = str(ai_summary["document_date"]).replace("-", "")
                    if len(raw_date) == 8 and raw_date.isdigit():
                        ai_summary["document_date"] = (
                            f"{raw_date[:4]}-{raw_date[4:6]}-{raw_date[6:]}"
                        )

                # 建议字段转成 follow_up_suggestions 格式
                if "follow_up_raw" in ai_summary and ai_summary["follow_up_raw"]:
                    ai_summary["follow_up_suggestions"] = [
                        {"suggestion": ai_summary.pop("follow_up_raw"), "time_expression": None}
                    ]
                else:
                    ai_summary.pop("follow_up_raw", None)

            elif fmt == "med" and isinstance(structured, list):
                # med_result 格式：血检指标列表
                abnormal = [
                    {
                        "name": it.get("org_name", ""),
                        "result": it.get("result", ""),
                        "unit": it.get("unit", ""),
                        "norm": it.get("norm", ""),
                        "flag": it.get("flag", ""),
                    }
                    for it in structured
                    if not it.get("is_match", True) or it.get("flag")
                ]
                all_items = [
                    f"{it.get('org_name','')} {it.get('result','')} {it.get('unit','')}".strip()
                    for it in structured
                ]
                ai_summary["examination_items"] = all_items
                if abnormal:
                    ai_summary["abnormal_indicators"] = abnormal

            # 尝试用 AI 补充复查建议（若 OCR 没有）
            if "follow_up_suggestions" not in ai_summary:
                ai_extra = self._extract_extra_info(ocr_text)
                for k in ("follow_up_suggestions",):
                    if ai_extra.get(k):
                        ai_summary[k] = ai_extra[k]

            return {
                "ocr_text": ocr_text,
                "ai_summary": ai_summary,
                "candidate_events": self._build_candidate_events(ai_summary),
            }

        except Exception as hr_err:
            logger.warning("health_report 失败（%s），降级到 accurate_basic", hr_err)

        # ---- 降级：通用 OCR + AI 解析 ----
        try:
            ocr_text = self.recognize_general(image_url)
            ai_summary = self.extract_health_info(ocr_text)
            return {
                "ocr_text": ocr_text,
                "ai_summary": ai_summary,
                "candidate_events": self._build_candidate_events(ai_summary),
            }
        except Exception as e:
            raise RuntimeError(f"OCR 全流程失败: {e}") from e

    # ------------------------------------------------------------------ #
    #  AI 辅助：补充医院/科室/复查建议
    # ------------------------------------------------------------------ #

    def _extract_extra_info(self, ocr_text: str) -> dict:
        """用通义千问从文本补充提取医院、日期、复查建议。AI 不可用时静默返回 {}。"""
        if not settings.AI_API_KEY:
            return {}
        try:
            from langchain.output_parsers import ResponseSchema, StructuredOutputParser
            from langchain.prompts import ChatPromptTemplate
            from langchain_community.chat_models import ChatTongyi

            schemas = [
                ResponseSchema(name="hospital_name", description="医院名称，无则返回null"),
                ResponseSchema(name="department", description="科室，无则返回null"),
                ResponseSchema(name="document_date", description="报告日期 YYYY-MM-DD，无则返回null"),
                ResponseSchema(
                    name="follow_up_suggestions",
                    description=(
                        "复查建议列表，格式: "
                        '[{"suggestion":"复查血糖","time_expression":"3个月后"}]，无则返回[]'
                    ),
                ),
            ]
            parser = StructuredOutputParser.from_response_schemas(schemas)
            prompt = ChatPromptTemplate.from_template(
                "你是医疗文档解析助手。仅输出 JSON，不加解释。\n\n"
                "OCR 文本：\n{ocr_text}\n\n{format_instructions}"
            )
            llm = ChatTongyi(
                model_name=settings.AI_MODEL_NAME,
                dashscope_api_key=settings.AI_API_KEY,
                temperature=0,
            )
            msgs = prompt.format_messages(
                ocr_text=ocr_text[:2000],  # 避免超 token
                format_instructions=parser.get_format_instructions(),
            )
            result = llm.invoke(msgs)
            return parser.parse(result.content)
        except Exception as e:
            logger.warning("AI 补充解析失败: %s", e)
            return {}

    def extract_health_info(self, ocr_text: str) -> dict:
        """降级路径：从纯文本中 AI 解析所有健康信息。"""
        if not settings.AI_API_KEY:
            return {"raw_text": ocr_text, "candidate_events": []}
        try:
            from langchain.output_parsers import ResponseSchema, StructuredOutputParser
            from langchain.prompts import ChatPromptTemplate
            from langchain_community.chat_models import ChatTongyi

            schemas = [
                ResponseSchema(name="hospital_name", description="医院名称"),
                ResponseSchema(name="department", description="科室"),
                ResponseSchema(name="document_date", description="文档日期 YYYY-MM-DD"),
                ResponseSchema(name="examination_items", description="检查项目列表"),
                ResponseSchema(name="abnormal_indicators", description="异常指标列表"),
                ResponseSchema(
                    name="follow_up_suggestions",
                    description='复查建议列表，格式: [{"suggestion":"...","time_expression":"..."}]',
                ),
            ]
            parser = StructuredOutputParser.from_response_schemas(schemas)
            prompt = ChatPromptTemplate.from_template(
                "你是医疗文档解析助手。仅输出 JSON，不加解释。\n\n"
                "OCR 文本：\n{ocr_text}\n\n{format_instructions}"
            )
            llm = ChatTongyi(
                model_name=settings.AI_MODEL_NAME,
                dashscope_api_key=settings.AI_API_KEY,
                temperature=0,
            )
            msgs = prompt.format_messages(
                ocr_text=ocr_text[:3000],
                format_instructions=parser.get_format_instructions(),
            )
            result = llm.invoke(msgs)
            return parser.parse(result.content)
        except Exception as e:
            err_str = str(e)
            if "InvalidApiKey" in err_str or "401" in err_str:
                return {"ai_error": "AI解析不可用（Dashscope API Key 无效）", "candidate_events": []}
            return {"ai_error": f"AI解析暂时不可用: {err_str[:120]}", "candidate_events": []}

    # ------------------------------------------------------------------ #
    #  构建候选提醒事件
    # ------------------------------------------------------------------ #

    def _build_candidate_events(self, ai_summary: dict) -> list:
        events = []
        for s in ai_summary.get("follow_up_suggestions") or []:
            if isinstance(s, dict):
                events.append({
                    "title": s.get("suggestion", "复查提醒"),
                    "time_expression": s.get("time_expression"),
                    "source": "ai_document",
                    "needs_confirmation": True,
                })
        return events


ocr_service = OCRService()
