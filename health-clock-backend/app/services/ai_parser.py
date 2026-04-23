import json
import re
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from app.core.config import settings
from app.schemas.ai import ParsedEvent


class AIParserService:
    def __init__(self) -> None:
        self.timezone = ZoneInfo("Asia/Shanghai")

    def parse_text(self, text: str, member_name: str | None = None, now: datetime | None = None) -> ParsedEvent:
        now = now or datetime.now(self.timezone)
        if now.tzinfo is None:
            now = now.replace(tzinfo=self.timezone)

        if settings.AI_API_KEY:
            try:
                return self._parse_with_llm(text=text, member_name=member_name, now=now)
            except Exception:
                pass

        return self._parse_with_rule(text=text, member_name=member_name, now=now)

    def _parse_with_llm(self, text: str, member_name: str | None, now: datetime) -> ParsedEvent:
        from langchain.output_parsers import StructuredOutputParser, ResponseSchema
        from langchain.prompts import ChatPromptTemplate
        from langchain_community.chat_models import ChatTongyi

        response_schemas = [
            ResponseSchema(name="event_title", description="提醒标题，简洁明确"),
            ResponseSchema(name="event_type", description="follow_up/revisit/checkup/medication/monitoring/custom"),
            ResponseSchema(name="scheduled_at", description="ISO8601 时间，如 2026-07-23T09:00:00+08:00"),
            ResponseSchema(name="is_all_day", description="是否全天，布尔值"),
            ResponseSchema(name="repeat_rule", description="重复规则，JSON 对象或 null"),
            ResponseSchema(name="confidence", description="0-1 之间的小数"),
            ResponseSchema(name="needs_confirmation", description="是否需要用户确认，布尔值"),
        ]
        parser = StructuredOutputParser.from_response_schemas(response_schemas)

        prompt = ChatPromptTemplate.from_template(
            """
你是健康日程解析助手。请把用户输入解析为健康提醒结构化数据。

规则：
1. 只输出 JSON，不要任何解释。
2. event_type 只能是 follow_up/revisit/checkup/medication/monitoring/custom。
3. scheduled_at 必须是 ISO8601，时区 +08:00。
4. 不确定时，提高 needs_confirmation=true，降低 confidence。

当前时间：{now}
成员：{member_name}
用户输入：{text}

{format_instructions}
""".strip()
        )

        llm = ChatTongyi(
            model_name=settings.AI_MODEL_NAME,
            dashscope_api_key=settings.AI_API_KEY,
            temperature=0,
        )

        messages = prompt.format_messages(
            now=now.isoformat(),
            member_name=member_name or "未指定",
            text=text,
            format_instructions=parser.get_format_instructions(),
        )
        result = llm.invoke(messages)
        payload = parser.parse(result.content)

        return ParsedEvent(
            member_name=member_name,
            event_title=payload["event_title"],
            event_type=payload["event_type"],
            scheduled_at=datetime.fromisoformat(payload["scheduled_at"]),
            is_all_day=payload["is_all_day"],
            repeat_rule=payload.get("repeat_rule"),
            source="ai_text",
            confidence=float(payload["confidence"]),
            needs_confirmation=bool(payload["needs_confirmation"]),
        )

    def _parse_with_rule(self, text: str, member_name: str | None, now: datetime) -> ParsedEvent:
        lowered = text.strip()
        event_type = self._guess_event_type(lowered)
        scheduled_at = self._extract_datetime(lowered, now)
        title = self._extract_title(lowered, event_type)

        confidence = 0.75
        if re.search(r"\d+\s*(天|周|个月|月|年)后", lowered):
            confidence = 0.9
        elif any(k in lowered for k in ["明天", "后天", "下周", "下个月"]):
            confidence = 0.85

        return ParsedEvent(
            member_name=member_name,
            event_title=title,
            event_type=event_type,
            scheduled_at=scheduled_at,
            is_all_day=False,
            repeat_rule=self._extract_repeat_rule(lowered),
            source="ai_text",
            confidence=confidence,
            needs_confirmation=True,
        )

    def _guess_event_type(self, text: str) -> str:
        if any(k in text for k in ["复查", "复检"]):
            return "follow_up"
        if any(k in text for k in ["复诊", "看医生", "门诊"]):
            return "revisit"
        if any(k in text for k in ["体检"]):
            return "checkup"
        if any(k in text for k in ["吃药", "用药", "服药"]):
            return "medication"
        if any(k in text for k in ["血压", "血糖", "体重", "测量", "监测"]):
            return "monitoring"
        return "custom"

    def _extract_datetime(self, text: str, now: datetime) -> datetime:
        match = re.search(r"(\d+)\s*(天|周|个月|月|年)后", text)
        if match:
            value = int(match.group(1))
            unit = match.group(2)
            if unit == "天":
                return now + timedelta(days=value)
            if unit == "周":
                return now + timedelta(weeks=value)
            if unit in {"个月", "月"}:
                return now + timedelta(days=value * 30)
            if unit == "年":
                return now + timedelta(days=value * 365)

        if "明天" in text:
            return now + timedelta(days=1)
        if "后天" in text:
            return now + timedelta(days=2)

        week_map = {"一": 0, "二": 1, "三": 2, "四": 3, "五": 4, "六": 5, "日": 6, "天": 6}
        week_match = re.search(r"下周([一二三四五六日天])", text)
        if week_match:
            target_weekday = week_map[week_match.group(1)]
            current_weekday = now.weekday()
            delta_days = 7 - current_weekday + target_weekday
            return now + timedelta(days=delta_days)

        return now + timedelta(days=1)

    def _extract_repeat_rule(self, text: str) -> dict | None:
        if "每天" in text:
            return {"frequency": "daily", "interval": 1}
        if "每周" in text:
            return {"frequency": "weekly", "interval": 1}
        if "每月" in text:
            return {"frequency": "monthly", "interval": 1}
        return None

    def _extract_title(self, text: str, event_type: str) -> str:
        cleaned = re.sub(r"\d+\s*(天|周|个月|月|年)后", "", text).strip()
        cleaned = re.sub(r"(明天|后天|下周[一二三四五六日天])", "", cleaned).strip()
        if cleaned:
            return cleaned[:50]

        defaults = {
            "follow_up": "复查提醒",
            "revisit": "复诊提醒",
            "checkup": "体检提醒",
            "medication": "用药提醒",
            "monitoring": "健康监测提醒",
            "custom": "健康提醒",
        }
        return defaults[event_type]


ai_parser_service = AIParserService()
