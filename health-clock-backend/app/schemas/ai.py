from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class ParseTextRequest(BaseModel):
    text: str = Field(..., min_length=2, max_length=500, description="用户输入的自然语言")
    member_id: str | None = Field(default=None, description="成员 ID")
    member_name: str | None = Field(default=None, description="成员名称")
    now: datetime | None = Field(default=None, description="当前时间，不传则使用服务端时间")


class ParsedEvent(BaseModel):
    member_name: str | None = None
    event_title: str
    event_type: Literal["follow_up", "revisit", "checkup", "medication", "monitoring", "custom"]
    scheduled_at: datetime
    is_all_day: bool = False
    repeat_rule: dict | None = None
    source: Literal["ai_text"] = "ai_text"
    confidence: float = Field(..., ge=0, le=1)
    needs_confirmation: bool = True


class ParseTextResponse(BaseModel):
    parsed_event: ParsedEvent
    raw_text: str
