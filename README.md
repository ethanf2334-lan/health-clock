# 健康时钟 Health Clock

一款基于 AI 的家庭健康提醒与健康档案管理 App。

## 项目概述

健康时钟是一款面向个人与家庭的健康日历提醒与健康档案管理 App，核心特色是通过 AI 理解自然语言、语音和医疗文档内容，自动生成健康提醒和档案记录。

## 技术栈

- **客户端**: Flutter (iOS 首发)
  - Riverpod (状态管理)
  - GoRouter (路由)
  - Drift (本地数据库)
- **后端**: FastAPI
  - LangChain (AI 框架)
  - Dashscope Qwen3.6-Plus (AI 模型)
  - 腾讯云 OCR
- **数据库**: Supabase Postgres
- **认证**: Supabase Auth (手机号 + Apple 登录)
- **存储**: Cloudflare R2

## 项目结构

```
health-clock/
├── docs/                    # 项目文档
├── health-clock-app/        # Flutter 客户端
└── health-clock-backend/    # FastAPI 后端
```

## 文档

- [需求文档](docs/健康时钟-需求文档.md)
- [项目说明书](docs/健康时钟-项目说明书.md)
- [技术架构文档](docs/健康时钟-技术架构文档.md)
- [数据库设计文档](docs/健康时钟-数据库设计文档.md)
- [API 接口文档](docs/健康时钟-API接口文档.md)
- [开发指南](docs/健康时钟-开发指南.md)

## 核心功能

- 🤖 AI 自然语言创建健康提醒
- 👨‍👩‍👧‍👦 家庭成员健康档案管理
- 📄 医疗文档上传与 OCR 识别
- 📊 健康指标记录与趋势展示
- 🔔 智能提醒通知

## 快速开始

### 后端初始化

```bash
cd health-clock-backend

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 填写配置

# 运行服务
uvicorn app.main:app --reload
```

访问 API 文档：http://localhost:8000/docs

### 前端初始化

```bash
# 安装 Flutter（如果未安装）
brew install --cask flutter

# 初始化 Flutter 项目
./init-flutter.sh

# 或手动初始化
cd health-clock-app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# 运行项目
flutter run
```

### 数据库初始化

1. 在 Supabase 创建项目
2. 执行 `health-clock-backend/migrations/001_initial_schema.sql`
3. 配置 RLS 策略

## 开发计划

当前处于 MVP 阶段，预计 8-12 周完成首版。

### 已完成
- ✅ 项目文档编写
- ✅ FastAPI 项目初始化
- ✅ Flutter 项目结构搭建
- ✅ 数据库设计和迁移脚本
- ✅ Supabase 认证集成（JWT 验证）
- ✅ 成员管理功能（CRUD）
- ✅ 健康提醒功能（CRUD + 筛选）
- ✅ AI 文本解析服务（LangChain + Qwen）
- ✅ 健康指标记录功能（CRUD）
- ✅ 文件上传功能（R2 预签名 URL）
- ✅ OCR 识别服务（腾讯云 OCR）
- ✅ AI 二次解析（提取健康信息）
- ✅ iOS 本地通知服务（Flutter）
- ✅ API 接口文档
- ✅ 开发指南文档

### 待开发
- ⏳ Flutter 前端页面实现
- ⏳ 前后端联调测试
- ⏳ iOS 真机测试
- ⏳ App Store 上架准备

## License

待定
