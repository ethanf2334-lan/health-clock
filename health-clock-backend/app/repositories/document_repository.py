from datetime import datetime

from supabase import Client

from app.schemas.document import DocumentCreate, DocumentUpdate


class DocumentRepository:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.table = "medical_documents"

    def list_by_user(
        self,
        user_id: str,
        member_id: str | None = None,
        category: str | None = None,
        start_date: datetime | None = None,
        end_date: datetime | None = None,
    ) -> list[dict]:
        """获取用户的文档列表（支持筛选）"""
        query = (
            self.supabase.table(self.table)
            .select("*, profile_members!inner(user_id)")
            .eq("profile_members.user_id", user_id)
            .is_("deleted_at", "null")
        )

        if member_id:
            query = query.eq("member_id", member_id)
        if category:
            query = query.eq("category", category)
        if start_date:
            query = query.gte("document_date", start_date.date().isoformat())
        if end_date:
            query = query.lte("document_date", end_date.date().isoformat())

        response = query.order("created_at", desc=True).execute()
        return response.data

    def get_by_id(self, document_id: str, user_id: str) -> dict | None:
        """获取单个文档（验证归属）"""
        response = (
            self.supabase.table(self.table)
            .select("*, profile_members!inner(user_id)")
            .eq("id", document_id)
            .eq("profile_members.user_id", user_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return response.data[0] if response.data else None

    def create(self, document_data: DocumentCreate) -> dict:
        """创建文档记录"""
        data = document_data.model_dump(mode="json")
        response = self.supabase.table(self.table).insert(data).execute()
        return response.data[0]

    def update(self, document_id: str, user_id: str, document_data: DocumentUpdate) -> dict | None:
        """更新文档信息"""
        update_data = {k: v for k, v in document_data.model_dump(mode="json").items() if v is not None}

        if not update_data:
            return self.get_by_id(document_id, user_id)

        # 先验证归属
        doc = self.get_by_id(document_id, user_id)
        if not doc:
            return None

        response = (
            self.supabase.table(self.table)
            .update(update_data)
            .eq("id", document_id)
            .execute()
        )
        return response.data[0] if response.data else None

    def soft_delete(self, document_id: str, user_id: str) -> bool:
        """软删除文档"""
        # 先验证归属
        doc = self.get_by_id(document_id, user_id)
        if not doc:
            return False

        response = (
            self.supabase.table(self.table)
            .update({"deleted_at": datetime.now().isoformat()})
            .eq("id", document_id)
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
