from fastapi import APIRouter, Query, status

from app.core.response import error_response, success_response
from app.core.security import CurrentUser, SupabaseClient
from app.repositories.metric_repository import MetricRepository
from app.schemas.metric import MetricRecordCreate

router = APIRouter()


@router.get("", response_model=dict)
def list_metrics(
    current_user: CurrentUser,
    supabase: SupabaseClient,
    member_id: str | None = Query(None),
    metric_type: str | None = Query(None),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
):
    """
    获取健康指标记录列表

    支持筛选：
    - member_id: 成员 ID
    - metric_type: blood_pressure/blood_sugar/weight/height/heart_rate/temperature/blood_oxygen
    - start_date: 开始日期（ISO8601）
    - end_date: 结束日期（ISO8601）
    """
    from datetime import datetime

    repo = MetricRepository(supabase)

    start = datetime.fromisoformat(start_date) if start_date else None
    end = datetime.fromisoformat(end_date) if end_date else None

    records = repo.list_by_user(
        user_id=current_user["id"],
        member_id=member_id,
        metric_type=metric_type,
        start_date=start,
        end_date=end,
    )

    return success_response(records)


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_metric(
    record_data: MetricRecordCreate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """创建健康指标记录"""
    repo = MetricRepository(supabase)

    # 验证成员归属
    if not repo.verify_member_ownership(record_data.member_id, current_user["id"]):
        return error_response(code=1004, message="无权访问该成员数据")

    try:
        record = repo.create(record_data)
        return success_response(record)
    except Exception as e:
        return error_response(code=1002, message=f"创建记录失败: {str(e)}")


@router.get("/{record_id}", response_model=dict)
def get_metric(record_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """获取单个健康指标记录"""
    repo = MetricRepository(supabase)
    record = repo.get_by_id(record_id, current_user["id"])

    if not record:
        return error_response(code=1001, message="记录不存在或无权访问")

    return success_response(record)


@router.delete("/{record_id}", response_model=dict)
def delete_metric(record_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """删除健康指标记录"""
    repo = MetricRepository(supabase)
    success = repo.delete(record_id, current_user["id"])

    if not success:
        return error_response(code=1001, message="记录不存在或无权访问")

    return success_response({"deleted": True})
