# Health Clock Backend

健康时钟 MVP 后端服务

## 技术栈

- FastAPI
- Supabase (Auth + Postgres)
- Cloudflare R2 (对象存储)
- LangChain + Dashscope Qwen3.6-Plus (AI)
- 腾讯云 OCR

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

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API 文档

启动服务后访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 项目结构

```
app/
  api/v1/          # API 路由
  core/            # 核心配置
  models/          # 数据模型
  schemas/         # Pydantic schemas
  services/        # 业务服务
  repositories/    # 数据访问层
```
