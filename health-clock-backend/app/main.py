import logging

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1 import auth, members, events, ai, documents, metrics
from app.core.config import settings

logger = logging.getLogger(__name__)

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

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    body = await request.body()
    # 全部转字符串，绝对安全，不依赖 JSON 序列化
    simplified = [
        {
            "loc": list(e.get("loc", [])),
            "msg": e.get("msg", ""),
            "type": e.get("type", ""),
            "input": str(e.get("input", "")),
        }
        for e in exc.errors()
    ]
    logger.warning(
        "422 ValidationError  path=%s  body=%r  errors=%s",
        request.url.path,
        body.decode("utf-8", errors="replace"),
        simplified,
    )
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": simplified},
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
