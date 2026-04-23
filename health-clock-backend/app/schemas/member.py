from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, Field


class MemberBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    relation: str | None = Field(None, max_length=20)
    gender: Literal["male", "female", "other"] | None = None
    birth_date: date | None = None
    height_cm: float | None = Field(None, ge=0, le=300)
    weight_kg: float | None = Field(None, ge=0, le=500)
    blood_type: str | None = Field(None, max_length=10)
    chronic_conditions: list[str] | None = None
    allergies: list[str] | None = None
    notes: str | None = None


class MemberCreate(MemberBase):
    pass


class MemberUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=50)
    relation: str | None = Field(None, max_length=20)
    gender: Literal["male", "female", "other"] | None = None
    birth_date: date | None = None
    height_cm: float | None = Field(None, ge=0, le=300)
    weight_kg: float | None = Field(None, ge=0, le=500)
    blood_type: str | None = Field(None, max_length=10)
    chronic_conditions: list[str] | None = None
    allergies: list[str] | None = None
    notes: str | None = None


class Member(MemberBase):
    id: str
    user_id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
