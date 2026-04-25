from fastapi import APIRouter, Query, status

from app.core.response import error_response, success_response
from app.core.security import CurrentUser, SupabaseClient
from app.repositories.document_repository import DocumentRepository
from app.schemas.document import (
    DocumentCreate,
    DocumentUpdate,
    OCRRequest,
    UploadSignatureRequest,
)
from app.services.ocr_service import ocr_service
from app.services.r2_storage import r2_storage_service

router = APIRouter()


@router.post("/upload-signature", response_model=dict)
def get_upload_signature(
    request: UploadSignatureRequest,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """
    获取 R2 预签名上传 URL

    用于客户端直传文件到 R2，避免文件经过后端服务器。
    """
    repo = DocumentRepository(supabase)

    # 验证成员归属
    if not repo.verify_member_ownership(request.member_id, current_user["id"]):
        return error_response(code=1004, message="无权访问该成员数据")

    # 验证文件类型
    allowed_types = ["image/jpeg", "image/png", "application/pdf"]
    if request.mime_type not in allowed_types:
        return error_response(code=1002, message="不支持的文件类型，仅支持 JPG/PNG/PDF")

    # 验证文件大小（最大 10MB）
    if request.file_size > 10 * 1024 * 1024:
        return error_response(code=1002, message="文件大小超过限制（最大 10MB）")

    try:
        signature = r2_storage_service.generate_upload_signature(
            member_id=request.member_id,
            file_name=request.file_name,
            mime_type=request.mime_type,
        )
        return success_response(signature)
    except Exception as e:
        return error_response(code=3001, message=f"生成上传签名失败: {str(e)}")


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_document(
    document_data: DocumentCreate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """保存文档元数据"""
    repo = DocumentRepository(supabase)

    # 验证成员归属
    if not repo.verify_member_ownership(document_data.member_id, current_user["id"]):
        return error_response(code=1004, message="无权访问该成员数据")

    try:
        document = repo.create(document_data)
        return success_response(document)
    except Exception as e:
        return error_response(code=1002, message=f"保存文档失败: {str(e)}")


@router.get("", response_model=dict)
def list_documents(
    current_user: CurrentUser,
    supabase: SupabaseClient,
    member_id: str | None = Query(None),
    category: str | None = Query(None),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
):
    """
    获取文档列表

    支持筛选：
    - member_id: 成员 ID
    - category: 文档分类
    - start_date: 开始日期（ISO8601）
    - end_date: 结束日期（ISO8601）
    """
    from datetime import datetime

    repo = DocumentRepository(supabase)

    start = datetime.fromisoformat(start_date) if start_date else None
    end = datetime.fromisoformat(end_date) if end_date else None

    documents = repo.list_by_user(
        user_id=current_user["id"],
        member_id=member_id,
        category=category,
        start_date=start,
        end_date=end,
    )

    return success_response(documents)


@router.get("/{document_id}", response_model=dict)
def get_document(document_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """获取文档详情"""
    repo = DocumentRepository(supabase)
    document = repo.get_by_id(document_id, current_user["id"])

    if not document:
        return error_response(code=1001, message="文档不存在或无权访问")

    # 生成临时下载链接
    try:
        download_url = r2_storage_service.generate_download_url(document["storage_key"])
        document["download_url"] = download_url
    except Exception:
        pass

    return success_response(document)


@router.put("/{document_id}", response_model=dict)
def update_document(
    document_id: str,
    document_data: DocumentUpdate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """更新文档信息"""
    repo = DocumentRepository(supabase)
    document = repo.update(document_id, current_user["id"], document_data)

    if not document:
        return error_response(code=1001, message="文档不存在或无权访问")

    return success_response(document)


@router.delete("/{document_id}", response_model=dict)
def delete_document(document_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """删除文档（软删除 + 删除 R2 文件）"""
    repo = DocumentRepository(supabase)

    # 先获取文档信息
    document = repo.get_by_id(document_id, current_user["id"])
    if not document:
        return error_response(code=1001, message="文档不存在或无权访问")

    # 软删除数据库记录
    success = repo.soft_delete(document_id, current_user["id"])
    if not success:
        return error_response(code=1001, message="文档不存在或无权访问")

    # 异步删除 R2 文件（失败不影响主流程）
    try:
        r2_storage_service.delete_file(document["storage_key"])
    except Exception:
        pass

    return success_response({"deleted": True})


@router.post("/ocr", response_model=dict)
def process_ocr(
    request: OCRRequest,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """
    处理文档 OCR 识别和 AI 二次解析

    流程：
    1. 获取文档信息
    2. 调用腾讯云 OCR 提取文本
    3. 调用 AI 提取结构化信息
    4. 更新文档记录
    5. 返回 OCR 结果和候选提醒
    """
    repo = DocumentRepository(supabase)

    # 获取文档
    document = repo.get_by_id(request.document_id, current_user["id"])
    if not document:
        return error_response(code=1001, message="文档不存在或无权访问")

    try:
        # 生成预签名下载 URL（R2 私有桶，外部 OCR 服务需要可访问的公网链接）
        try:
            ocr_image_url = r2_storage_service.generate_download_url(document["storage_key"])
        except Exception:
            ocr_image_url = document["file_url"]

        # 调用 OCR 完整流程：优先 health_report，失败降级到 accurate_basic + AI
        result = ocr_service.process_document(ocr_image_url)

        ocr_text = result["ocr_text"]
        ai_summary = result["ai_summary"]
        candidate_events = result["candidate_events"]

        # 更新文档记录
        update_data = DocumentUpdate(
            ocr_text=ocr_text,
            ai_summary={**ai_summary, "candidate_events": candidate_events},
        )
        repo.update(request.document_id, current_user["id"], update_data)

        return success_response(
            {
                "document_id": request.document_id,
                "ocr_text": ocr_text,
                "ai_summary": ai_summary,
                "candidate_events": candidate_events,
            }
        )

    except Exception as e:
        return error_response(code=2002, message=f"OCR 处理失败: {str(e)}")
