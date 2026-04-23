from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class DocumentBase(BaseModel):
    member_id: str
    file_name: str = Field(..., max_length=255)
    file_size: int = Field(..., ge=0)
    mime_type: str = Field(..., max_length=100)
    category: Literal["checkup_report", "examination_result", "outpatient_record", "lab_report", "prescription", "hospitalization_record", "other"]
    title: str | None = Field(None, max_length=200)
    document_date: datetime | None = None
    hospital_name: str | None = Field(None, max_length=200)


class DocumentCreate(DocumentBase):
    file_url: str
    storage_bucket: str = Field(..., max_length=100)
    storage_key: str = Field(..., max_length=500)
    ocr_text: str | None = None
    ai_summary: dict | None = None


class DocumentUpdate(BaseModel):
    title: str | None = Field(None, max_length=200)
    document_date: datetime | None = None
    hospital_name: str | None = Field(None, max_length=200)
    category: str | None = None
    ocr_text: str | None = None
    ai_summary: dict | None = None


class Document(DocumentBase):
    id: str
    file_url: str
    storage_bucket: str
    storage_key: str
    ocr_text: str | None = None
    ai_summary: dict | None = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class UploadSignatureRequest(BaseModel):
    member_id: str
    file_name: str = Field(..., max_length=255)
    file_size: int = Field(..., ge=0, le=10 * 1024 * 1024)  # 最大 10MB
    mime_type: str = Field(..., max_length=100)


class UploadSignatureResponse(BaseModel):
    upload_url: str
    object_key: str
    file_url: str
    expires_in: int = 3600  # 签名有效期（秒）


class OCRRequest(BaseModel):
    document_id: str


class OCRResponse(BaseModel):
    document_id: str
    ocr_text: str
    ai_summary: dict | None = None
    candidate_events: list[dict] | None = None
