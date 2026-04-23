from fastapi import APIRouter, HTTPException

from app.core.response import success_response, error_response
from app.schemas.ai import ParseTextRequest, ParseTextResponse
from app.services.ai_parser import ai_parser_service

router = APIRouter()


@router.post("/parse-text", response_model=dict)
def parse_text(request: ParseTextRequest):
    """
    解析自然语言文本为结构化健康提醒

    示例输入：
    - "甲状腺 3 个月后复查"
    - "明天带妈妈去医院复诊"
    - "每天晚上 8 点提醒吃药"
    """
    try:
        parsed_event = ai_parser_service.parse_text(
            text=request.text,
            member_name=request.member_name,
            now=request.now,
        )

        response = ParseTextResponse(
            parsed_event=parsed_event,
            raw_text=request.text,
        )

        return success_response(response.model_dump(mode="json"))

    except Exception as e:
        return error_response(code=2001, message=f"AI 解析失败: {str(e)}")
