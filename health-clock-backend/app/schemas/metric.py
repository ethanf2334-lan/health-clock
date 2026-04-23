from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class MetricRecordBase(BaseModel):
    member_id: str
    metric_type: Literal["blood_pressure", "blood_sugar", "weight", "height", "heart_rate", "temperature", "blood_oxygen"]
    value: float = Field(..., ge=0)
    value_extra: dict | None = None  # 用于血压等需要多个值的指标
    unit: str = Field(..., max_length=20)
    recorded_at: datetime
    note: str | None = None


class MetricRecordCreate(MetricRecordBase):
    pass


class MetricRecord(MetricRecordBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True


class MetricRecordListQuery(BaseModel):
    member_id: str | None = None
    metric_type: str | None = None
    start_date: datetime | None = None
    end_date: datetime | None = None
