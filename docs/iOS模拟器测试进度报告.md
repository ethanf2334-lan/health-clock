# iOS 模拟器测试进度报告

**更新时间：2026-04-24（第三轮联调完成）**

---

## 当前状态总览

| 项目 | 状态 |
|------|------|
| iOS 模拟器（iPhone 17 / iOS 26.4）运行 | ✅ 正常 |
| Supabase 初始化（dart-define 注入） | ✅ 正常 |
| 阿里云短信验证码登录 | ✅ 正常 |
| 后端 JWT 鉴权（本地验证） | ✅ 正常 |
| 数据库表已创建 | ✅ 正常 |
| 成员 / 提醒 / 文档 / 指标接口返回 200 | ✅ 正常 |
| 成员新增（前端表单 → 后端保存） | ⚠️ snake_case 映射已修，待完整验证 |
| 提醒列表 / 创建 / 详情 | ⚠️ 前端已实现，联调中 |
| 文档上传 / OCR | ⚠️ 前端已实现，未测 |
| 健康指标录入 / 历史 | ⚠️ 前端已实现，未测 |

---

## 已解决的问题

### 1. Supabase URL 未注入（首次启动报"未配置"）
**原因**：Flutter 用 `String.fromEnvironment()` 读配置，不会自动读后端的 `.env`。  
**解决**：
- 新增 `health-clock-app/.vscode/launch.json`，写入 `--dart-define=SUPABASE_URL=...` 等参数
- 新增 `health-clock-app/run-app.sh`，命令行一键带参启动
- 后续启动命令：`cd health-clock-app && ./run-app.sh <simulator-udid>`

### 2. 登录后所有接口 403
**原因**：点击"跳过登录（测试模式）"进入 guest 模式，没有 JWT token，后端全部拒绝。  
**解决**：接入阿里云短信验证码登录，登录后下发真实 token（见下文）。

### 3. 登录页无手机号 OTP 支持（Supabase 无阿里云 SMS provider）
**解决方案**：完全绕过 Supabase Phone Provider，自建短信登录链路：
- **后端** `POST /auth/send-sms-code` → 调阿里云 Dypnsapi `SendSmsVerifyCode`
- **后端** `POST /auth/verify-sms-code` → 调阿里云 `CheckSmsVerifyCode`，验证通过后：
  1. 用 `SUPABASE_SERVICE_ROLE_KEY` 在 `auth.users` 创建/查找该手机号用户
  2. 用 `SUPABASE_JWT_SECRET` 签发 HS256 JWT（payload 格式与 Supabase GoTrue 一致）
  3. 返回 `{access_token, expires_at, user}`

### 4. 登录成功后接口 401
**原因**：旧 `security.py` 调用 `supabase.auth.get_user(token)` 验证，GoTrue 不认识我们自签的 token。  
**解决**：`security.py` 改为本地 JWT 解码（`jose.jwt.decode` + `SUPABASE_JWT_SECRET`），不走远程 API。

### 5. 数据库表不存在（PGRST205 错误）
**原因**：Supabase 数据库未执行 migration。  
**解决**：在 Supabase Dashboard → SQL Editor 执行 `migrations/001_initial_schema.sql`，全部表已建立。

### 6. 成员新增报 `type 'Null' is not a subtype of type 'String'`
**原因**：后端返回 snake_case 字段（`user_id`, `created_at` 等），前端 Freezed 生成的 `.g.dart` 按 camelCase 取值，导致 `null as String` 崩溃。  
**解决**：在四个 Repository 分别添加 normalize helper，在传入 `fromJson` 之前统一做 snake_case → camelCase 映射：
- `member_repository.dart` → `_normalizeMember()`
- `event_repository.dart` → `_normalizeEvent()`
- `document_repository.dart` → `_normalizeDoc()` / `_normalizeSig()`
- `metric_repository.dart` → `_normalizeMetric()`

### 7. 验证码 422（空格导致 `isdigit()` 失败）
**原因**：SMS 短信在部分机型上把验证码格式化成 `123 456`（中间有空格），后端 validator 调 `isdigit()` 失败。  
**解决**：
- 后端 `schemas/auth.py` 的 `_v_code` 改成 `re.sub(r"\D", "", v)` 提取纯数字
- 前端 `login_screen.dart` 的 `_verify()` 在发送前调 `replaceAll(' ', '')`

---

## 已知待修复问题（下次启动优先处理）

### P0 - 必须先修

| 编号 | 问题 | 位置 | 说明 |
|------|------|------|------|
| #1 | 前端 `MemberCreate.toJson()` 输出 camelCase，后端期望 snake_case | `member_repository.dart` createMember | Freezed 生成的 JSON 是 camelCase（`birthDate`），但 Pydantic schema 接收 `birth_date`，导致出生日期等字段静默丢失 |
| #2 | 同上问题在 `EventCreate.toJson()` | `event_repository.dart` createEvent | `memberId` → `member_id`, `scheduledAt` → `scheduled_at` 等 |
| #3 | `MemberCreate.toJson()` 传 `updateMember` 时也有同问题 | `member_form_screen.dart` 编辑模式 | 已手写 snake_case map，但需确认全字段覆盖 |

**修复方案**：在 createMember / createEvent 调用时，手写 toMap 明确用 snake_case，而不是 `model.toJson()`。

### P1 - 功能联调

| 编号 | 问题 | 说明 |
|------|------|------|
| #4 | 文档上传端到端联调 | R2 预签名、OCR、AI 提取链路未实测 |
| #5 | 提醒创建 / AI 预填 完整流程联调 | 表单 → 后端 → 本地通知调度 |
| #6 | 健康指标录入联调 | 录入后列表刷新、折线图数据 |
| #7 | 成员切换后各 tab 数据随 currentMemberId 刷新 | 需要验证 Provider filter 是否正常联动 |

### P2 - 体验优化

| 编号 | 问题 |
|------|------|
| #8 | 通知点击跳转详情页（payload 已写，handler 待实现） |
| #9 | 日历月/周网格视图（当前为列表替代） |
| #10 | 语音输入 |

---

## 环境启动命令（每次开发必备）

```bash
# 1. 启动后端（在 health-clock-backend 目录）
./venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 2. 启动 iOS 模拟器（如果未启动）
xcrun simctl boot 39365EA4-B750-4412-9552-57C7545456D1
open -a Simulator

# 3. 启动 Flutter（在 health-clock-app 目录）
./run-app.sh 39365EA4-B750-4412-9552-57C7545456D1
```

**.env 已配置的服务**：
- Supabase（URL / anon key / service role key / JWT secret）
- 阿里云 Dypnsapi（AccessKey / 签名 / 模板 / 方案名）
- Cloudflare R2（Object Storage）
- 阿里云通义（AI 解析，qwen3.6-plus）
- 百度 OCR

---

## 关键文件索引（本轮新增 / 修改）

### 后端新增
| 文件 | 说明 |
|------|------|
| `app/services/aliyun_sms.py` | 阿里云 Dypnsapi 封装（发送+校验） |
| `app/services/jwt_service.py` | Supabase 兼容 HS256 JWT 签发 |
| `app/services/user_service.py` | Supabase auth.users 创建/查找 |
| `app/schemas/auth.py` | 短信登录请求/响应 Schema |

### 后端修改
| 文件 | 修改内容 |
|------|----------|
| `app/api/v1/auth.py` | 新增 send-sms-code / verify-sms-code 路由 |
| `app/core/security.py` | JWT 改为本地解码，移除 GoTrue 远程验证 |
| `app/core/config.py` | 新增 ALIYUN_* / SUPABASE_JWT_SECRET 配置项 |
| `app/main.py` | 添加 422 ValidationError 详细日志 handler |

### 前端新增
| 文件 | 说明 |
|------|------|
| `.vscode/launch.json` | Supabase dart-define 配置（IDE 启动用） |
| `run-app.sh` | 命令行带参启动脚本 |

### 前端修改
| 文件 | 修改内容 |
|------|----------|
| `lib/core/services/auth_service.dart` | 改为调用后端短信接口，不再直连 Supabase Auth |
| `lib/features/auth/presentation/login_screen.dart` | 移除"未配置 Supabase"分支；验证码输入去空格 |
| `lib/features/members/data/member_repository.dart` | 添加 `_normalizeMember()` snake→camel 映射 |
| `lib/features/calendar/data/event_repository.dart` | 添加 `_normalizeEvent()` 映射 |
| `lib/features/documents/data/document_repository.dart` | 添加 `_normalizeDoc()` / `_normalizeSig()` 映射 |
| `lib/features/health_records/data/metric_repository.dart` | 添加 `_normalizeMetric()` 映射 |
