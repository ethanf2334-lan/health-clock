import base64
import json

from tencentcloud.common import credential
from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.ocr.v20181119 import models, ocr_client

from app.core.config import settings


class OCRService:
    def __init__(self):
        self.secret_id = settings.TENCENT_SECRET_ID
        self.secret_key = settings.TENCENT_SECRET_KEY

    def recognize_general(self, image_url: str) -> str:
        """
        通用文字识别（高精度版）

        Args:
            image_url: 图片 URL

        Returns:
            识别的文本内容
        """
        try:
            cred = credential.Credential(self.secret_id, self.secret_key)
            http_profile = HttpProfile()
            http_profile.endpoint = "ocr.tencentcloudapi.com"

            client_profile = ClientProfile()
            client_profile.httpProfile = http_profile

            client = ocr_client.OcrClient(cred, "ap-guangzhou", client_profile)

            req = models.GeneralAccurateOCRRequest()
            params = {"ImageUrl": image_url}
            req.from_json_string(json.dumps(params))

            resp = client.GeneralAccurateOCR(req)
            result = json.loads(resp.to_json_string())

            # 提取文本
            text_lines = []
            for item in result.get("TextDetections", []):
                text_lines.append(item.get("DetectedText", ""))

            return "\n".join(text_lines)

        except TencentCloudSDKException as e:
            raise Exception(f"OCR 识别失败: {e.message}")

    def recognize_medical(self, image_url: str) -> dict:
        """
        医疗票据识别

        Args:
            image_url: 图片 URL

        Returns:
            结构化的医疗信息
        """
        try:
            cred = credential.Credential(self.secret_id, self.secret_key)
            http_profile = HttpProfile()
            http_profile.endpoint = "ocr.tencentcloudapi.com"

            client_profile = ClientProfile()
            client_profile.httpProfile = http_profile

            client = ocr_client.OcrClient(cred, "ap-guangzhou", client_profile)

            req = models.MedicalInvoiceOCRRequest()
            params = {"ImageUrl": image_url}
            req.from_json_string(json.dumps(params))

            resp = client.MedicalInvoiceOCR(req)
            result = json.loads(resp.to_json_string())

            return result

        except TencentCloudSDKException as e:
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
