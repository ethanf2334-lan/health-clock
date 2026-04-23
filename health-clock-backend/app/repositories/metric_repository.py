from datetime import datetime

from supabase import Client

from app.schemas.metric import MetricRecordCreate


class MetricRepository:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.table = "health_metric_records"

    def list_by_user(
        self,
        user_id: str,
        member_id: str | None = None,
        metric_type: str | None = None,
        start_date: datetime | None = None,
        end_date: datetime | None = None,
    ) -> list[dict]:
        """获取用户的健康指标记录（支持筛选）"""
        query = (
            self.supabase.table(self.table)
            .select("*, profile_members!inner(user_id)")
            .eq("profile_members.user_id", user_id)
        )

        if member_id:
            query = query.eq("member_id", member_id)
        if metric_type:
            query = query.eq("metric_type", metric_type)
        if start_date:
            query = query.gte("recorded_at", start_date.isoformat())
        if end_date:
            query = query.lte("recorded_at", end_date.isoformat())

        response = query.order("recorded_at", desc=True).execute()
        return response.data

    def get_by_id(self, record_id: str, user_id: str) -> dict | None:
        """获取单个记录（验证归属）"""
        response = (
            self.supabase.table(self.table)
            .select("*, profile_members!inner(user_id)")
            .eq("id", record_id)
            .eq("profile_members.user_id", user_id)
            .execute()
        )
        return response.data[0] if response.data else None

    def create(self, record_data: MetricRecordCreate) -> dict:
        """创建健康指标记录"""
        data = record_data.model_dump(mode="json")
        response = self.supabase.table(self.table).insert(data).execute()
        return response.data[0]

    def delete(self, record_id: str, user_id: str) -> bool:
        """删除记录"""
        # 先验证归属
        record = self.get_by_id(record_id, user_id)
        if not record:
            return False

        response = self.supabase.table(self.table).delete().eq("id", record_id).execute()
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
