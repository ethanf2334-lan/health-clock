from datetime import datetime

from supabase import Client

from app.schemas.event import EventCreate, EventUpdate


class EventRepository:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.table = "health_events"

    def list_by_user(
        self,
        user_id: str,
        member_id: str | None = None,
        start_date: datetime | None = None,
        end_date: datetime | None = None,
        status: str | None = None,
        event_type: str | None = None,
    ) -> list[dict]:
        """获取用户的提醒列表（支持筛选）"""
        member_query = (
            self.supabase.table("profile_members")
            .select("id")
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
        )

        if member_id:
            member_query = member_query.eq("id", member_id)

        member_response = member_query.execute()
        member_ids = [member["id"] for member in member_response.data]

        if not member_ids:
            return []

        query = (
            self.supabase.table(self.table)
            .select("*")
            .in_("member_id", member_ids)
            .is_("deleted_at", "null")
        )

        if start_date:
            query = query.gte("scheduled_at", start_date.isoformat())
        if end_date:
            query = query.lte("scheduled_at", end_date.isoformat())
        if status:
            query = query.eq("status", status)
        if event_type:
            query = query.eq("event_type", event_type)

        response = query.order("scheduled_at", desc=False).execute()
        return response.data

    def get_by_id(self, event_id: str, user_id: str) -> dict | None:
        """获取单个提醒（验证归属）"""
        response = (
            self.supabase.table(self.table)
            .select("*, profile_members!inner(user_id)")
            .eq("id", event_id)
            .eq("profile_members.user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return response.data[0] if response.data else None

    def create(self, event_data: EventCreate) -> dict:
        """创建提醒"""
        data = event_data.model_dump(mode="json")
        response = self.supabase.table(self.table).insert(data).execute()
        return response.data[0]

    def update(self, event_id: str, user_id: str, event_data: EventUpdate) -> dict | None:
        """更新提醒"""
        update_data = {k: v for k, v in event_data.model_dump(mode="json").items() if v is not None}

        if not update_data:
            return self.get_by_id(event_id, user_id)

        # 如果状态改为 completed，设置 completed_at
        if update_data.get("status") == "completed":
            update_data["completed_at"] = datetime.now().isoformat()

        response = (
            self.supabase.table(self.table)
            .update(update_data)
            .eq("id", event_id)
            .is_("deleted_at", "null")
            .execute()
        )

        if response.data:
            return self.get_by_id(event_id, user_id)
        return None

    def soft_delete(self, event_id: str, user_id: str) -> bool:
        """软删除提醒"""
        # 先验证归属
        event = self.get_by_id(event_id, user_id)
        if not event:
            return False

        response = (
            self.supabase.table(self.table)
            .update({"deleted_at": datetime.now().isoformat()})
            .eq("id", event_id)
            .execute()
        )
        return len(response.data) > 0

    def verify_member_ownership(self, member_id: str, user_id: str) -> bool:
        """验证成员归属"""
        response = (
            self.supabase.table("profile_members")
            .select("id")
            .eq("id", member_id)
            .eq("user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return len(response.data) > 0
