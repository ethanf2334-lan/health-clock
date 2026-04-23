from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class EventBase(BaseModel):
    member_id: str
    title: str = Field(..., min_length=1, max_length=200)
    description: str | None = None
    event_type: Literal["follow_up", "revisit", "checkup", "medication", "monitoring", "custom"]
    scheduled_at: datetime
    is_all_day: bool = False
    repeat_rule: dict | None = None
    notify_offsets: list[int] | None = None
    source_type: Literal["ai_text", "ai_voice", "ai_document", "manual"] = "manual"
    source_text: str | None = None
    ai_confidence: float | None = Field(None, ge=0, le=1)


class EventCreate(EventBase):
    pass


class EventUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    description: str | None = None
    event_type: Literal["follow_up", "revisit", "checkup", "medication", "monitoring", "custom"] | None = None
    scheduled_at: datetime | None = None
    is_all_day: bool | None = None
    repeat_rule: dict | None = None
    notify_offsets: list[int] | None = None
    status: Literal["pending", "completed", "cancelled"] | None = None


class Event(EventBase):
    id: str
    status: Literal["pending", "completed", "cancelled"]
    created_at: datetime
    updated_at: datetime
    completed_at: datetime | None = None

    class Config:
        from_attributes = True


class EventListQuery(BaseModel):
    member_id: str | None = None
    start_date: datetime | None = None
    end_date: datetime | None = None
    status: Literal["pending", "completed", "cancelled"] | None = None
    event_type: str | None = None
