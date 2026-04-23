#!/bin/bash

# 健康时钟项目状态检查脚本

echo "================================"
echo "健康时钟项目状态检查"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装"
        return 1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 存在"
        return 0
    else
        echo -e "${RED}✗${NC} $1 不存在"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 存在"
        return 0
    else
        echo -e "${RED}✗${NC} $1 不存在"
        return 1
    fi
}

# 1. 检查开发工具
echo "1. 检查开发工具"
echo "----------------"
check_command python3
check_command pip
check_command flutter
check_command git
check_command docker
echo ""

# 2. 检查项目结构
echo "2. 检查项目结构"
echo "----------------"
check_dir "health-clock-backend"
check_dir "health-clock-app"
check_dir "docs"
check_dir "health-clock-backend/app"
check_dir "health-clock-app/lib"
echo ""

# 3. 检查后端文件
echo "3. 检查后端核心文件"
echo "-------------------"
check_file "health-clock-backend/requirements.txt"
check_file "health-clock-backend/.env.example"
check_file "health-clock-backend/app/main.py"
check_file "health-clock-backend/app/core/config.py"
check_file "health-clock-backend/app/core/security.py"
check_file "health-clock-backend/migrations/001_initial_schema.sql"
echo ""

# 4. 检查前端文件
echo "4. 检查前端核心文件"
echo "-------------------"
check_file "health-clock-app/pubspec.yaml"
check_file "health-clock-app/lib/main.dart"
check_file "health-clock-app/lib/app/router/app_router.dart"
check_file "health-clock-app/lib/app/theme/app_theme.dart"
echo ""

# 5. 检查文档
echo "5. 检查项目文档"
echo "---------------"
check_file "docs/健康时钟-需求文档.md"
check_file "docs/健康时钟-技术架构文档.md"
check_file "docs/健康时钟-数据库设计文档.md"
check_file "docs/健康时钟-API接口文档.md"
check_file "docs/健康时钟-开发指南.md"
echo ""

# 6. 检查环境配置
echo "6. 检查环境配置"
echo "---------------"
if [ -f "health-clock-backend/.env" ]; then
    echo -e "${GREEN}✓${NC} 后端 .env 文件存在"

    # 检查关键配置项
    if grep -q "SUPABASE_URL=" health-clock-backend/.env && \
       [ "$(grep "SUPABASE_URL=" health-clock-backend/.env | cut -d'=' -f2)" != "" ]; then
        echo -e "${GREEN}  ✓${NC} SUPABASE_URL 已配置"
    else
        echo -e "${YELLOW}  !${NC} SUPABASE_URL 未配置"
    fi

    if grep -q "AI_API_KEY=" health-clock-backend/.env && \
       [ "$(grep "AI_API_KEY=" health-clock-backend/.env | cut -d'=' -f2)" != "" ]; then
        echo -e "${GREEN}  ✓${NC} AI_API_KEY 已配置"
    else
        echo -e "${YELLOW}  !${NC} AI_API_KEY 未配置"
    fi

    if grep -q "R2_ACCESS_KEY_ID=" health-clock-backend/.env && \
       [ "$(grep "R2_ACCESS_KEY_ID=" health-clock-backend/.env | cut -d'=' -f2)" != "" ]; then
        echo -e "${GREEN}  ✓${NC} R2_ACCESS_KEY_ID 已配置"
    else
        echo -e "${YELLOW}  !${NC} R2_ACCESS_KEY_ID 未配置"
    fi
else
    echo -e "${YELLOW}!${NC} 后端 .env 文件不存在（请从 .env.example 复制）"
fi
echo ""

# 7. 检查 Python 依赖
echo "7. 检查 Python 依赖"
echo "-------------------"
if [ -d "health-clock-backend/venv" ]; then
    echo -e "${GREEN}✓${NC} Python 虚拟环境存在"
else
    echo -e "${YELLOW}!${NC} Python 虚拟环境不存在（运行: python3 -m venv venv）"
fi
echo ""

# 8. 统计代码
echo "8. 代码统计"
echo "-----------"
if command -v find &> /dev/null && command -v wc &> /dev/null; then
    backend_py=$(find health-clock-backend/app -name "*.py" 2>/dev/null | wc -l)
    frontend_dart=$(find health-clock-app/lib -name "*.dart" 2>/dev/null | wc -l)
    echo "后端 Python 文件: $backend_py"
    echo "前端 Dart 文件: $frontend_dart"
fi
echo ""

# 9. Git 状态
echo "9. Git 状态"
echo "-----------"
if [ -d ".git" ]; then
    echo -e "${GREEN}✓${NC} Git 仓库已初始化"
    echo "当前分支: $(git branch --show-current)"
    echo "最近提交: $(git log -1 --oneline)"

    # 检查未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}!${NC} 有未提交的更改"
    else
        echo -e "${GREEN}✓${NC} 工作区干净"
    fi
else
    echo -e "${RED}✗${NC} Git 仓库未初始化"
fi
echo ""

# 10. 总结
echo "================================"
echo "检查完成"
echo "================================"
echo ""
echo "下一步操作建议："
echo "1. 如果 .env 未配置，请复制 .env.example 并填写配置"
echo "2. 如果虚拟环境不存在，运行: cd health-clock-backend && python3 -m venv venv"
echo "3. 安装后端依赖: source venv/bin/activate && pip install -r requirements.txt"
echo "4. 如果 Flutter 未安装，运行: brew install --cask flutter"
echo "5. 初始化 Flutter 项目: ./init-flutter.sh"
echo "6. 启动后端服务: cd health-clock-backend && uvicorn app.main:app --reload"
echo "7. 访问 API 文档: http://localhost:8000/docs"
