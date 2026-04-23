# Health Clock Backend

健康时钟 MVP 后端服务

## 技术栈

- FastAPI
- Supabase (Auth + Postgres)
- Cloudflare R2 (对象存储)
- LangChain + Dashscope Qwen3.6-Plus (AI)
- 百度 OCR

## 安装依赖

```bash
pip install -r requirements.txt
```

## 配置环境变量

复制 `.env.example` 为 `.env` 并填写配置：

```bash
cp .env.example .env
```

## 运行服务

### 开发环境

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Docker 部署

```bash
# 构建镜像
docker build -t health-clock-api .

# 运行容器
docker run -p 8000:8000 --env-file .env health-clock-api

# 或使用 docker-compose
docker-compose up -d
```

## API 文档

启动服务后访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

完整 API 文档：[API 接口文档](../docs/健康时钟-API接口文档.md)

## 项目结构

```
app/
  api/v1/          # API 路由
    auth.py        # 认证接口
    members.py     # 成员管理
    events.py      # 健康提醒
    ai.py          # AI 解析
    documents.py   # 文档管理
    metrics.py     # 健康指标
  core/            # 核心配置
    config.py      # 配置管理
    security.py    # 认证中间件
    response.py    # 统一响应
  models/          # 数据模型（预留）
  schemas/         # Pydantic schemas
    ai.py          # AI 相关
    member.py      # 成员
    event.py       # 提醒
    document.py    # 文档
    metric.py      # 指标
  services/        # 业务服务
    ai_parser.py   # AI 文本解析
    ocr_service.py # OCR 识别
    r2_storage.py  # R2 对象存储
  repositories/    # 数据访问层
    member_repository.py
    event_repository.py
    document_repository.py
    metric_repository.py
```

## 已实现功能

- ✅ Supabase 认证集成（JWT 验证）
- ✅ 成员管理 CRUD
- ✅ 健康提醒 CRUD（支持多维度筛选）
- ✅ AI 文本解析（LangChain + Qwen）
- ✅ 健康指标记录 CRUD
- ✅ 文件上传（R2 预签名 URL）
- ✅ OCR 识别（腾讯云 OCR）
- ✅ AI 二次解析（提取健康信息）
- ✅ 统一错误处理和响应格式
