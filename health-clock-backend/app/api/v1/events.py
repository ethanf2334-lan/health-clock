from datetime import datetime
import logging

from fastapi import APIRouter, Query, status

from app.core.response import error_response, success_response
from app.core.security import CurrentUser, SupabaseClient
from app.repositories.event_repository import EventRepository
from app.schemas.event import EventCreate, EventListQuery, EventUpdate

router = APIRouter()
logger = logging.getLogger(__name__)


def _parse_iso_datetime(value: str | None) -> datetime | None:
    if not value:
        return None
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


@router.get("", response_model=dict)
def list_events(
    current_user: CurrentUser,
    supabase: SupabaseClient,
    member_id: str | None = Query(None),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    status_filter: str | None = Query(None, alias="status"),
    event_type: str | None = Query(None),
):
    """
    获取提醒列表

    支持筛选：
    - member_id: 成员 ID
    - start_date: 开始日期（ISO8601）
    - end_date: 结束日期（ISO8601）
    - status: pending/completed/cancelled
    - event_type: follow_up/revisit/checkup/medication/monitoring/custom
    """
    repo = EventRepository(supabase)

    try:
        start = _parse_iso_datetime(start_date)
        end = _parse_iso_datetime(end_date)
    except ValueError:
        return error_response(code=1003, message="日期格式无效")

    try:
        events = repo.list_by_user(
            user_id=current_user["id"],
            member_id=member_id,
            start_date=start,
            end_date=end,
            status=status_filter,
            event_type=event_type,
        )
    except Exception as exc:
        logger.exception("List events failed for user_id=%s", current_user["id"])
        return error_response(code=1002, message=f"获取提醒列表失败: {str(exc)}")

    return success_response(events)


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_event(
    event_data: EventCreate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """创建提醒"""
    repo = EventRepository(supabase)

    # 验证成员归属
    if not repo.verify_member_ownership(event_data.member_id, current_user["id"]):
        return error_response(code=1004, message="无权访问该成员数据")

    try:
        event = repo.create(event_data)
        return success_response(event)
    except Exception as e:
        return error_response(code=1002, message=f"创建提醒失败: {str(e)}")


@router.get("/{event_id}", response_model=dict)
def get_event(event_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """获取单个提醒详情"""
    repo = EventRepository(supabase)
    event = repo.get_by_id(event_id, current_user["id"])

    if not event:
        return error_response(code=1001, message="提醒不存在或无权访问")

    return success_response(event)


@router.put("/{event_id}", response_model=dict)
def update_event(
    event_id: str,
    event_data: EventUpdate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """更新提醒"""
    repo = EventRepository(supabase)
    event = repo.update(event_id, current_user["id"], event_data)

    if not event:
        return error_response(code=1001, message="提醒不存在或无权访问")

    return success_response(event)


@router.delete("/{event_id}", response_model=dict)
def delete_event(event_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """删除提醒（软删除）"""
    repo = EventRepository(supabase)
    success = repo.soft_delete(event_id, current_user["id"])

    if not success:
        return error_response(code=1001, message="提醒不存在或无权访问")

    return success_response({"deleted": True})


@router.post("/{event_id}/complete", response_model=dict)
def complete_event(event_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """标记提醒为已完成"""
    repo = EventRepository(supabase)
    event_data = EventUpdate(status="completed")
    event = repo.update(event_id, current_user["id"], event_data)

    if not event:
        return error_response(code=1001, message="提醒不存在或无权访问")

    return success_response(event)
