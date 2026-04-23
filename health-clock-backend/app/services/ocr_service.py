import base64
import json

import requests

from app.core.config import settings


class OCRService:
    def __init__(self):
        self.api_key = settings.BAIDU_OCR_API_KEY
        self.secret_key = settings.BAIDU_OCR_SECRET_KEY
        self.access_token = None

    def _get_access_token(self) -> str:
        """
        获取百度 OCR Access Token

        Returns:
            Access Token
        """
        if self.access_token:
            return self.access_token

        url = "https://aip.baidubce.com/oauth/2.0/token"
        params = {
            "grant_type": "client_credentials",
            "client_id": self.api_key,
            "client_secret": self.secret_key,
        }

        try:
            response = requests.post(url, params=params, timeout=10)
            result = response.json()

            if "access_token" in result:
                self.access_token = result["access_token"]
                return self.access_token
            else:
                raise Exception(f"获取 Access Token 失败: {result}")

        except Exception as e:
            raise Exception(f"获取 Access Token 失败: {str(e)}")

    def recognize_general(self, image_url: str) -> str:
        """
        通用文字识别（高精度版）

        Args:
            image_url: 图片 URL

        Returns:
            识别的文本内容
        """
        try:
            access_token = self._get_access_token()
            url = f"https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic?access_token={access_token}"

            # 下载图片并转为 base64
            image_response = requests.get(image_url, timeout=10)
            image_base64 = base64.b64encode(image_response.content).decode("utf-8")

            # 调用百度 OCR
            headers = {"Content-Type": "application/x-www-form-urlencoded"}
            data = {"image": image_base64}

            response = requests.post(url, headers=headers, data=data, timeout=10)
            result = response.json()

            if "error_code" in result:
                raise Exception(f"OCR 识别失败: {result.get('error_msg', '未知错误')}")

            # 提取文本
            text_lines = []
            for item in result.get("words_result", []):
                text_lines.append(item.get("words", ""))

            return "\n".join(text_lines)

        except Exception as e:
            raise Exception(f"OCR 识别失败: {str(e)}")

    def recognize_medical(self, image_url: str) -> dict:
        """
        医疗票据识别

        Args:
            image_url: 图片 URL

        Returns:
            结构化的医疗信息
        """
        try:
            access_token = self._get_access_token()
            url = f"https://aip.baidubce.com/rest/2.0/ocr/v1/medical_record?access_token={access_token}"

            # 下载图片并转为 base64
            image_response = requests.get(image_url, timeout=10)
            image_base64 = base64.b64encode(image_response.content).decode("utf-8")

            # 调用百度医疗票据识别
            headers = {"Content-Type": "application/x-www-form-urlencoded"}
            data = {"image": image_base64}

            response = requests.post(url, headers=headers, data=data, timeout=10)
            result = response.json()

            if "error_code" in result:
                # 如果医疗识别失败，降级到通用识别
                return {"text": self.recognize_general(image_url)}

            return result

        except Exception:
            # 如果医疗识别失败，降级到通用识别
            return {"text": self.recognize_general(image_url)}

    def extract_health_info(self, ocr_text: str) -> dict:
        """
        从 OCR 文本中提取健康信息

        使用 AI 解析 OCR 文本，提取：
        - 复查建议
        - 时间信息
        - 医院/科室
        - 检查项目
        - 异常指标
        """
        if not settings.AI_API_KEY:
            return {"raw_text": ocr_text, "candidate_events": []}

        try:
            from langchain.output_parsers import StructuredOutputParser, ResponseSchema
            from langchain.prompts import ChatPromptTemplate
            from langchain_community.chat_models import ChatTongyi

            response_schemas = [
                ResponseSchema(name="hospital_name", description="医院名称"),
                ResponseSchema(name="department", description="科室"),
                ResponseSchema(name="document_date", description="文档日期 YYYY-MM-DD"),
                ResponseSchema(name="examination_items", description="检查项目列表"),
                ResponseSchema(name="abnormal_indicators", description="异常指标列表"),
                ResponseSchema(name="follow_up_suggestions", description="复查建议列表，每项包含 suggestion 和 time_expression"),
            ]
            parser = StructuredOutputParser.from_response_schemas(response_schemas)

            prompt = ChatPromptTemplate.from_template(
                """
你是医疗文档解析助手。请从 OCR 文本中提取关键健康信息。

规则：
1. 只输出 JSON，不要任何解释。
2. 如果某项信息不存在，返回 null 或空列表。
3. follow_up_suggestions 格式：[{{"suggestion": "复查甲状腺功能", "time_expression": "3个月后"}}]

OCR 文本：
{ocr_text}

{format_instructions}
""".strip()
            )

            llm = ChatTongyi(
                model_name=settings.AI_MODEL_NAME,
                dashscope_api_key=settings.AI_API_KEY,
                temperature=0,
            )

            messages = prompt.format_messages(
                ocr_text=ocr_text,
                format_instructions=parser.get_format_instructions(),
            )
            result = llm.invoke(messages)
            payload = parser.parse(result.content)

            return payload

        except Exception as e:
            return {"raw_text": ocr_text, "error": str(e), "candidate_events": []}


ocr_service = OCRService()
