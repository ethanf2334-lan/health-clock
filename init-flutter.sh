#!/bin/bash

# Flutter 项目初始化脚本

echo "开始初始化 Flutter 项目..."

# 检查 Flutter 是否已安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装"
    echo "请访问 https://flutter.dev/docs/get-started/install 安装 Flutter"
    echo ""
    echo "macOS 快速安装："
    echo "  brew install --cask flutter"
    exit 1
fi

echo "✅ Flutter 已安装"
flutter --version

# 进入 Flutter 项目目录
cd health-clock-app || exit

# 获取依赖
echo ""
echo "📦 获取依赖..."
flutter pub get

# 生成代码
echo ""
echo "🔨 生成代码（路由、状态管理等）..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Flutter 项目初始化完成！"
echo ""
echo "下一步："
echo "  1. 配置 Supabase 环境变量"
echo "  2. 运行项目: flutter run"
echo "  3. 或在 VS Code/Android Studio 中打开项目"
