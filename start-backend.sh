#!/bin/bash

# 健康时钟快速启动脚本

echo "================================"
echo "健康时钟快速启动"
echo "================================"
echo ""

# 检查是否在项目根目录
if [ ! -d "health-clock-backend" ] || [ ! -d "health-clock-app" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 检查后端环境
echo "1. 检查后端环境..."
if [ ! -f "health-clock-backend/.env" ]; then
    echo "⚠️  .env 文件不存在，从 .env.example 复制..."
    cp health-clock-backend/.env.example health-clock-backend/.env
    echo "✅ 已创建 .env 文件，请编辑填写配置"
    echo ""
    echo "需要配置的关键项："
    echo "  - SUPABASE_URL"
    echo "  - SUPABASE_ANON_KEY"
    echo "  - SUPABASE_SERVICE_ROLE_KEY"
    echo "  - AI_API_KEY (可选，用于 AI 解析)"
    echo "  - R2_ACCESS_KEY_ID (可选，用于文件上传)"
    echo "  - TENCENT_SECRET_ID (可选，用于 OCR)"
    echo ""
    read -p "按回车继续..."
fi

# 检查虚拟环境
if [ ! -d "health-clock-backend/venv" ]; then
    echo "⚠️  虚拟环境不存在，正在创建..."
    cd health-clock-backend
    python3 -m venv venv
    cd ..
    echo "✅ 虚拟环境已创建"
fi

# 检查依赖
echo ""
echo "2. 检查 Python 依赖..."
cd health-clock-backend
source venv/bin/activate

if ! python -c "import fastapi" 2>/dev/null; then
    echo "⚠️  依赖未安装，正在安装..."
    pip install -q -r requirements.txt
    echo "✅ 依赖安装完成"
else
    echo "✅ 依赖已安装"
fi

# 启动后端
echo ""
echo "3. 启动后端服务..."
echo "================================"
echo ""
echo "后端服务启动中..."
echo "API 文档: http://localhost:8000/docs"
echo "健康检查: http://localhost:8000/health"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
