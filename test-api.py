#!/usr/bin/env python3
"""
健康时钟 API 测试脚本

测试所有核心 API 接口的基本功能
"""

import json
import sys
from datetime import datetime, timedelta

try:
    import requests
except ImportError:
    print("❌ 请先安装 requests: pip install requests")
    sys.exit(1)


class HealthClockAPITester:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.token = None
        self.member_id = None
        self.event_id = None
        self.document_id = None
        self.metric_id = None

    def print_result(self, test_name, success, message=""):
        status = "✅" if success else "❌"
        print(f"{status} {test_name}")
        if message:
            print(f"   {message}")

    def test_health_check(self):
        """测试健康检查接口"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            success = response.status_code == 200 and response.json()["code"] == 0
            self.print_result(
                "健康检查",
                success,
                f"状态码: {response.status_code}" if not success else "",
            )
            return success
        except Exception as e:
            self.print_result("健康检查", False, str(e))
            return False

    def test_ai_parse_text(self):
        """测试 AI 文本解析"""
        try:
            data = {
                "text": "甲状腺 3 个月后复查",
                "member_name": "测试用户",
            }
            response = requests.post(
                f"{self.base_url}/api/v1/ai/parse-text",
                json=data,
                timeout=10,
            )
            result = response.json()
            success = response.status_code == 200 and result["code"] == 0

            if success:
                parsed = result["data"]["parsed_event"]
                self.print_result(
                    "AI 文本解析",
                    True,
                    f"解析结果: {parsed['event_title']} - {parsed['event_type']}",
                )
            else:
                self.print_result("AI 文本解析", False, result.get("message", ""))

            return success
        except Exception as e:
            self.print_result("AI 文本解析", False, str(e))
            return False

    def test_api_docs(self):
        """测试 API 文档可访问性"""
        try:
            response = requests.get(f"{self.base_url}/docs", timeout=5)
            success = response.status_code == 200
            self.print_result(
                "API 文档",
                success,
                f"访问地址: {self.base_url}/docs" if success else "",
            )
            return success
        except Exception as e:
            self.print_result("API 文档", False, str(e))
            return False

    def test_cors(self):
        """测试 CORS 配置"""
        try:
            headers = {"Origin": "http://localhost:3000"}
            response = requests.options(
                f"{self.base_url}/api/v1/ai/parse-text",
                headers=headers,
                timeout=5,
            )
            has_cors = "access-control-allow-origin" in response.headers
            self.print_result("CORS 配置", has_cors)
            return has_cors
        except Exception as e:
            self.print_result("CORS 配置", False, str(e))
            return False

    def run_all_tests(self):
        """运行所有测试"""
        print("=" * 50)
        print("健康时钟 API 测试")
        print("=" * 50)
        print(f"测试地址: {self.base_url}")
        print()

        print("1. 基础功能测试")
        print("-" * 50)
        test1 = self.test_health_check()
        test2 = self.test_api_docs()
        test3 = self.test_cors()
        print()

        print("2. AI 功能测试")
        print("-" * 50)
        test4 = self.test_ai_parse_text()
        print()

        # 统计结果
        total = 4
        passed = sum([test1, test2, test3, test4])

        print("=" * 50)
        print(f"测试完成: {passed}/{total} 通过")
        print("=" * 50)
        print()

        if passed < total:
            print("⚠️  部分测试失败，请检查：")
            print("1. 后端服务是否正常运行")
            print("2. 环境变量是否正确配置")
            print("3. 依赖是否完整安装")
            print()
            print("启动后端服务:")
            print("  cd health-clock-backend")
            print("  source venv/bin/activate")
            print("  uvicorn app.main:app --reload")
        else:
            print("✅ 所有测试通过！")
            print()
            print("下一步:")
            print("1. 配置 Supabase 并测试认证接口")
            print("2. 配置 R2 并测试文件上传")
            print("3. 配置 AI 和 OCR 服务")

        return passed == total


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="健康时钟 API 测试")
    parser.add_argument(
        "--url",
        default="http://localhost:8000",
        help="API 基础 URL (默认: http://localhost:8000)",
    )
    args = parser.parse_args()

    tester = HealthClockAPITester(base_url=args.url)
    success = tester.run_all_tests()

    sys.exit(0 if success else 1)
