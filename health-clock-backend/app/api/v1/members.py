from fastapi import APIRouter, HTTPException, status

from app.core.response import error_response, success_response
from app.core.security import CurrentUser, SupabaseClient
from app.repositories.member_repository import MemberRepository
from app.schemas.member import Member, MemberCreate, MemberUpdate

router = APIRouter()


@router.get("", response_model=dict)
def list_members(current_user: CurrentUser, supabase: SupabaseClient):
    """获取当前用户的所有成员"""
    repo = MemberRepository(supabase)
    members = repo.list_by_user(current_user["id"])
    return success_response(members)


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_member(
    member_data: MemberCreate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """创建新成员"""
    try:
        repo = MemberRepository(supabase)
        member = repo.create(current_user["id"], member_data)
        return success_response(member)
    except Exception as e:
        return error_response(code=1002, message=f"创建成员失败: {str(e)}")


@router.get("/{member_id}", response_model=dict)
def get_member(member_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """获取单个成员详情"""
    repo = MemberRepository(supabase)
    member = repo.get_by_id(member_id, current_user["id"])

    if not member:
        return error_response(code=1001, message="成员不存在或无权访问")

    return success_response(member)


@router.put("/{member_id}", response_model=dict)
def update_member(
    member_id: str,
    member_data: MemberUpdate,
    current_user: CurrentUser,
    supabase: SupabaseClient,
):
    """更新成员信息"""
    repo = MemberRepository(supabase)
    member = repo.update(member_id, current_user["id"], member_data)

    if not member:
        return error_response(code=1001, message="成员不存在或无权访问")

    return success_response(member)


@router.delete("/{member_id}", response_model=dict)
def delete_member(member_id: str, current_user: CurrentUser, supabase: SupabaseClient):
    """删除成员（软删除）"""
    repo = MemberRepository(supabase)
    success = repo.soft_delete(member_id, current_user["id"])

    if not success:
        return error_response(code=1001, message="成员不存在或无权访问")

    return success_response({"deleted": True})
