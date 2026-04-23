from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import auth, members, events, ai, documents, metrics
from app.core.config import settings

app = FastAPI(
    title="Health Clock API",
    description="健康时钟 MVP 后端 API",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # MVP 阶段，生产环境需要限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(members.router, prefix="/api/v1/members", tags=["members"])
app.include_router(events.router, prefix="/api/v1/events", tags=["events"])
app.include_router(ai.router, prefix="/api/v1/ai", tags=["ai"])
app.include_router(documents.router, prefix="/api/v1/documents", tags=["documents"])
app.include_router(metrics.router, prefix="/api/v1/metrics", tags=["metrics"])


@app.get("/")
def root():
    return {"code": 0, "message": "ok", "data": {"service": "health-clock-api"}}


@app.get("/health")
def health_check():
    return {"code": 0, "message": "ok", "data": {"status": "healthy"}}
