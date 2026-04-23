from datetime import datetime

from supabase import Client

from app.schemas.member import MemberCreate, MemberUpdate


class MemberRepository:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.table = "profile_members"

    def list_by_user(self, user_id: str) -> list[dict]:
        """获取用户的所有成员（不包括已删除）"""
        response = (
            self.supabase.table(self.table)
            .select("*")
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
            .order("created_at", desc=False)
            .execute()
        )
        return response.data

    def get_by_id(self, member_id: str, user_id: str) -> dict | None:
        """获取单个成员（验证归属）"""
        response = (
            self.supabase.table(self.table)
            .select("*")
            .eq("id", member_id)
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return response.data[0] if response.data else None

    def create(self, user_id: str, member_data: MemberCreate) -> dict:
        """创建成员"""
        data = member_data.model_dump()
        data["user_id"] = user_id

        response = self.supabase.table(self.table).insert(data).execute()
        return response.data[0]

    def update(self, member_id: str, user_id: str, member_data: MemberUpdate) -> dict | None:
        """更新成员"""
        # 只更新非 None 的字段
        update_data = {k: v for k, v in member_data.model_dump().items() if v is not None}

        if not update_data:
            return self.get_by_id(member_id, user_id)

        response = (
            self.supabase.table(self.table)
            .update(update_data)
            .eq("id", member_id)
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return response.data[0] if response.data else None

    def soft_delete(self, member_id: str, user_id: str) -> bool:
        """软删除成员"""
        response = (
            self.supabase.table(self.table)
            .update({"deleted_at": datetime.now().isoformat()})
            .eq("id", member_id)
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return len(response.data) > 0
