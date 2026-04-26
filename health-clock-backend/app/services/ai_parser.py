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
5. 必须严格按“当前时间”计算相对日期：
   - “N天后”= 当前时间 + N 天。
   - “N周后 / N个星期后”= 当前时间 + N*7 天。
   - “N个月后”= 当前日期月份 + N，若目标月份没有对应日期则取该月最后一天。
   - 中文数字要等同阿拉伯数字，例如“两周后”= 14 天后，“三个月后”= 3 个月后。
   - 用户没有说明具体几点时，使用当前时间的小时和分钟，并设置 needs_confirmation=true。
6. 示例：如果当前时间是 2026-04-26T10:30:00+08:00，“两周后复查”应输出 2026-05-10T10:30:00+08:00。
7. 重复提醒必须输出 repeat_rule：
   - “每天/每日”输出 {{"frequency":"daily","interval":1}}。
   - “每周/每星期”输出 {{"frequency":"weekly","interval":1}}。
   - “每月”输出 {{"frequency":"monthly","interval":1}}。
   - 例如“每天晚上8点提醒妈妈吃药”，scheduled_at 应为下一次晚上 20:00，repeat_rule 为 daily。

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

        llm_event = ParsedEvent(
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
        rule_repeat = self._extract_repeat_rule(text)
        rule_time = self._extract_time_of_day_datetime(text, now, repeat_rule=rule_repeat)
        if rule_repeat is not None or rule_time is not None:
            updates = {"needs_confirmation": True}
            if rule_repeat is not None:
                updates["repeat_rule"] = rule_repeat
            if rule_time is not None:
                updates["scheduled_at"] = rule_time
            return llm_event.model_copy(update=updates)
        rule_time = self._extract_explicit_relative_datetime(text, now)
        if rule_time is not None:
            return llm_event.model_copy(
                update={
                    "scheduled_at": rule_time,
                    "needs_confirmation": True,
                }
            )
        return llm_event

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
        explicit = self._extract_explicit_relative_datetime(text, now)
        if explicit is not None:
            return explicit

        time_of_day = self._extract_time_of_day_datetime(
            text,
            now,
            repeat_rule=self._extract_repeat_rule(text),
        )
        if time_of_day is not None:
            return time_of_day

        match = re.search(r"(\d+)\s*(天|周|星期|个星期|个月|月|年)后", text)
        if match:
            value = int(match.group(1))
            unit = match.group(2)
            if unit == "天":
                return now + timedelta(days=value)
            if unit in {"周", "星期", "个星期"}:
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

    def _extract_explicit_relative_datetime(self, text: str, now: datetime) -> datetime | None:
        match = re.search(r"([0-9一二两三四五六七八九十]+)\s*(天|周|星期|个星期|个月|月|年)后", text)
        if not match:
            return None

        value = self._parse_chinese_number(match.group(1))
        if value is None:
            return None

        unit = match.group(2)
        if unit == "天":
            return now + timedelta(days=value)
        if unit in {"周", "星期", "个星期"}:
            return now + timedelta(weeks=value)
        if unit in {"个月", "月"}:
            return self._add_months(now, value)
        if unit == "年":
            return self._add_months(now, value * 12)
        return None

    def _extract_time_of_day_datetime(
        self,
        text: str,
        now: datetime,
        repeat_rule: dict | None = None,
    ) -> datetime | None:
        pattern = r"(凌晨|早上|上午|中午|下午|晚上|晚间|夜里)?\s*([0-9一二两三四五六七八九十]{1,3})\s*(点|时|:|：)\s*(半|[0-9一二两三四五六七八九十]{1,3}分?)?"
        match = re.search(pattern, text)
        if not match:
            return None

        period = match.group(1) or ""
        hour = self._parse_chinese_number(match.group(2))
        minute_raw = match.group(4)
        if hour is None:
            return None

        minute = 0
        if minute_raw:
            if minute_raw == "半":
                minute = 30
            else:
                minute_text = minute_raw.removesuffix("分")
                parsed_minute = self._parse_chinese_number(minute_text)
                if parsed_minute is None:
                    return None
                minute = parsed_minute

        if period in {"下午", "晚上", "晚间", "夜里"} and hour < 12:
            hour += 12
        if period == "中午" and hour < 11:
            hour += 12
        if hour > 23 or minute > 59:
            return None

        scheduled = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        if repeat_rule and repeat_rule.get("frequency") == "weekly":
            week_match = re.search(r"每周([一二三四五六日天])", text)
            if week_match:
                week_map = {"一": 0, "二": 1, "三": 2, "四": 3, "五": 4, "六": 5, "日": 6, "天": 6}
                target_weekday = week_map[week_match.group(1)]
                delta_days = (target_weekday - scheduled.weekday()) % 7
                scheduled = scheduled + timedelta(days=delta_days)

        if scheduled <= now:
            if repeat_rule and repeat_rule.get("frequency") == "weekly":
                scheduled += timedelta(days=7)
            elif repeat_rule and repeat_rule.get("frequency") == "monthly":
                scheduled = self._add_months(scheduled, 1)
            else:
                scheduled += timedelta(days=1)
        return scheduled

    def _parse_chinese_number(self, value: str) -> int | None:
        if value.isdigit():
            return int(value)

        digits = {
            "一": 1,
            "二": 2,
            "两": 2,
            "三": 3,
            "四": 4,
            "五": 5,
            "六": 6,
            "七": 7,
            "八": 8,
            "九": 9,
        }
        if value in digits:
            return digits[value]
        if value == "十":
            return 10
        if value.startswith("十") and len(value) == 2:
            return 10 + digits.get(value[1], 0)
        if value.endswith("十") and len(value) == 2:
            return digits.get(value[0], 0) * 10
        if "十" in value and len(value) == 3:
            high, low = value.split("十", 1)
            return digits.get(high, 0) * 10 + digits.get(low, 0)
        return None

    def _add_months(self, dt: datetime, months: int) -> datetime:
        month_index = dt.month - 1 + months
        year = dt.year + month_index // 12
        month = month_index % 12 + 1
        day = min(dt.day, self._days_in_month(year, month))
        return dt.replace(year=year, month=month, day=day)

    def _days_in_month(self, year: int, month: int) -> int:
        if month == 12:
            next_month = datetime(year + 1, 1, 1, tzinfo=self.timezone)
        else:
            next_month = datetime(year, month + 1, 1, tzinfo=self.timezone)
        this_month = datetime(year, month, 1, tzinfo=self.timezone)
        return (next_month - this_month).days

    def _extract_repeat_rule(self, text: str) -> dict | None:
        if any(k in text for k in ["每天", "每日"]):
            return {"frequency": "daily", "interval": 1}
        if any(k in text for k in ["每周", "每星期"]):
            return {"frequency": "weekly", "interval": 1}
        if "每月" in text:
            return {"frequency": "monthly", "interval": 1}
        return None

    def _extract_title(self, text: str, event_type: str) -> str:
        cleaned = re.sub(r"[0-9一二两三四五六七八九十]+\s*(天|周|星期|个星期|个月|月|年)后", "", text).strip()
        cleaned = re.sub(r"(明天|后天|下周[一二三四五六日天])", "", cleaned).strip()
        cleaned = re.sub(r"(每天|每日|每周[一二三四五六日天]?|每星期[一二三四五六日天]?|每月)", "", cleaned).strip()
        cleaned = re.sub(r"(凌晨|早上|上午|中午|下午|晚上|晚间|夜里)?\s*[0-9一二两三四五六七八九十]{1,3}\s*(点|时|:|：)\s*(半|[0-9一二两三四五六七八九十]{1,3}分?)?", "", cleaned).strip()
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
