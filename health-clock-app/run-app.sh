#!/usr/bin/env bash
# 一键启动 Flutter 应用并注入 Supabase 配置
# 用法:
#   ./run-app.sh                          # 自动选择已启动的设备
#   ./run-app.sh <device-id>              # 指定设备 (如 iPhone 17 模拟器 UDID)
#   SUPABASE_URL=xxx SUPABASE_ANON_KEY=yy ./run-app.sh   # 覆盖默认 Supabase 配置
#   API_BASE_URL=http://192.168.1.10:8000/api/v1 ./run-app.sh  # 真机连接 Mac 后端

set -euo pipefail

cd "$(dirname "$0")"

# 默认 Supabase 配置（与 health-clock-backend/.env 保持一致）
: "${API_BASE_URL:=http://localhost:8000/api/v1}"
: "${SUPABASE_URL:=https://hqayoyneholqbjdlwvcp.supabase.co}"
: "${SUPABASE_ANON_KEY:=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxYXlveW5laG9scWJqZGx3dmNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4OTcxMTcsImV4cCI6MjA5MjQ3MzExN30.0gwdfeBTIK8tw1-bZirE2W_wbxDtPMMep0XEp-bpckU}"

DEVICE_ARGS=()
if [[ $# -gt 0 ]]; then
  DEVICE_ARGS=(-d "$1")
fi

exec flutter run \
  "${DEVICE_ARGS[@]}" \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
