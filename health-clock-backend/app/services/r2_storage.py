import uuid
from datetime import datetime, timedelta

import boto3
from botocore.client import Config

from app.core.config import settings


class R2StorageService:
    def __init__(self):
        self.s3_client = boto3.client(
            "s3",
            endpoint_url=settings.R2_ENDPOINT_URL,
            aws_access_key_id=settings.R2_ACCESS_KEY_ID,
            aws_secret_access_key=settings.R2_SECRET_ACCESS_KEY,
            config=Config(signature_version="s3v4"),
        )
        self.bucket = settings.R2_BUCKET
        self.public_url = settings.R2_PUBLIC_URL

    def generate_upload_signature(
        self,
        member_id: str,
        file_name: str,
        mime_type: str,
        expires_in: int = 3600,
    ) -> dict:
        """
        生成预签名上传 URL

        Returns:
            {
                "upload_url": "预签名上传 URL",
                "object_key": "对象存储 key",
                "file_url": "文件访问 URL",
                "expires_in": 3600
            }
        """
        # 生成唯一的对象 key
        timestamp = datetime.now().strftime("%Y%m%d")
        unique_id = str(uuid.uuid4())
        file_ext = file_name.split(".")[-1] if "." in file_name else ""
        object_key = f"documents/{member_id}/{timestamp}/{unique_id}.{file_ext}"

        # 生成预签名上传 URL
        upload_url = self.s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": self.bucket,
                "Key": object_key,
                "ContentType": mime_type,
            },
            ExpiresIn=expires_in,
        )

        # 生成文件访问 URL
        file_url = f"{self.public_url}/{object_key}"

        return {
            "upload_url": upload_url,
            "object_key": object_key,
            "file_url": file_url,
            "expires_in": expires_in,
        }

    def generate_download_url(self, object_key: str, expires_in: int = 3600) -> str:
        """生成预签名下载 URL"""
        return self.s3_client.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": self.bucket,
                "Key": object_key,
            },
            ExpiresIn=expires_in,
        )

    def delete_file(self, object_key: str) -> bool:
        """删除文件"""
        try:
            self.s3_client.delete_object(Bucket=self.bucket, Key=object_key)
            return True
        except Exception:
            return False


r2_storage_service = R2StorageService()
