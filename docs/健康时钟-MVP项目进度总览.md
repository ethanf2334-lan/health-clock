# 健康时钟 MVP 项目进度总览

**更新时间：2026-04-25（第十轮通知设置与成员综合档案）**

本文档基于以下资料交叉整理：

- 产品文档：`docs/健康时钟-需求文档.md`
- 项目说明：`docs/健康时钟-项目说明书.md`
- 技术架构：`docs/健康时钟-技术架构文档.md`
- 实际代码：`health-clock-backend/` 与 `health-clock-app/`

---

## 1. 总体判断（第十轮增强后）

| 维度 | 状态 |
|------|------|
| 后端完成度 | **高**（核心 API + 阿里云短信登录 + 自签 JWT + 鉴权链路全通；OCR 链路修复完整） |
| 前端完成度 | **高**（主链路全部可跑通；P0 问题全部修复；通知设置、关于页、成员综合档案已补齐） |
| 整体 MVP 可用性 | **基本可体验**（登录、成员、提醒、文档上传/OCR、指标、通知设置全链路已通） |

一句话总结：P0 三个阻断性问题（文档无法查看、新用户无引导、导航栈不一致）已全部修复；OCR 链路完整修复；AI 摘要展示不再显示英文 key 和空字段；OCR 候选提醒可确认创建；Apple 登录与语音输入已纳入首版；通知设置页、关于页、成员综合档案页已补齐；MVP 核心功能已达可体验状态。

---

## 2. MVP 模块进度

| 模块 | 文档要求 | 当前状态 | 结论 |
|------|----------|----------|------|
| 账户与登录 | 手机号验证码登录、Apple 登录、用户态 | 手机号 OTP（阿里云短信）+ Apple 登录 + 自签 JWT + 本地登录态恢复 + Token 自动续期已实现 | **✅ 已实现** |
| 家庭成员管理 | 成员新增、编辑、删除、切换 | 后端 CRUD 完整；前端列表、新增、编辑、切换、删除、成员综合档案页均有实现；camelCase 映射已修 | **✅ 已实现** |
| 健康提醒 | AI 创建、手动创建、编辑、删除、完成、筛选 | 后端 CRUD + 筛选 + 完成已实现；前端列表、表单、详情页已实现，联调中 | **✅ 基本完成** |
| AI 文本创建提醒 | 自然语言解析、结构化预览、确认保存 | 全链路已实现（AI 解析 → 表单预填 → 保存 → 本地通知） | **✅ 已实现** |
| 语音输入 | 语音转文字后再解析 | 前端已接入系统语音识别，听写文本进入 AI 创建提醒链路 | **✅ 已实现** |
| 文档上传与 OCR | 上传图片/PDF、OCR、AI 结构化、候选提醒 | 前后端完整实现并修复：百度 `health_report` 接口正确调用、`words_result` 格式正确解析、预签名 URL 传给 OCR、AI 摘要字段中文化；候选提醒可确认创建 | **✅ 已实现** |
| 健康指标记录 | 录入、历史记录、趋势展示 | 前后端均已实现，联调待验证 | **⚠️ 待验证** |
| 日历与列表视图 | 今日、未来 7/30 天、月/周/列表 | 已实现列表筛选、周视图、月视图、按天提醒数量与当天提醒清单 | **✅ 基本完成** |
| 通知提醒 | 本地通知、权限、点击跳转 | 本地通知已接入提醒创建/完成/删除流程；点击跳转详情页、通知设置页、测试通知、清空本地提醒、打开系统设置均已实现 | **✅ 已实现** |
| 家庭档案/文件归档 | 按成员查看资料、文件记录 | 文档列表按成员过滤、上传入口、短文件名展示、归属人展示、文档详情、删除均已实现 | **✅ 已实现** |
| 工程质量 | 基础测试与静态检查 | `flutter test`、`flutter analyze`、后端 `compileall` 均已通过 | **✅ 已通过** |

---

## 3. 已完整实现的内容

### 3.1 后端

- FastAPI 服务 + CORS + 路由注册
- **阿里云短信验证码登录**（`/auth/send-sms-code` + `/auth/verify-sms-code`）
- **Apple 登录**（`/auth/apple` 验证 Apple identity token，签发 Supabase 兼容 JWT）
- **登录续期**（`/auth/refresh` 使用当前有效 token 续签）
- **开发调试模式**：`APP_DEBUG=true` 时固定验证码 `000000`，跳过阿里云 SMS
- **Supabase 兼容 JWT 自签**（`SUPABASE_JWT_SECRET` + HS256）
- **本地 JWT 验证**（`security.py`，不走 GoTrue 远程 API）
- Supabase `auth.users` 用户创建/同步（`user_service.py`）
- 成员管理 CRUD（含 `model_dump(mode="json")` 修复 date 序列化）
- 健康提醒 CRUD、筛选查询、标记完成
- AI 文本解析接口 `/ai/parse-text`（通义千问 `qwen-plus`）
- 文档上传签名接口、文档元数据 CRUD
- **百度 OCR 完整链路**：`health_report` 专用接口（优先）→ `accurate_basic`（降级）→ AI 补充解析
- `words_result` 格式正确解析（`{word, word_name}` → 标准字段映射）
- 预签名下载 URL 传给 OCR（修复私有 R2 403 问题）
- 候选提醒抽取
- 健康指标记录新增、查询、删除
- 数据库迁移脚本（已在 Supabase 执行）、RLS 策略

### 3.2 前端

- 应用入口、主题、中文本地化
- **手机号 OTP 登录**（调后端 `/auth/send-sms-code` + `/auth/verify-sms-code`）
- **Apple 登录入口**（`sign_in_with_apple` + 后端 `/auth/apple`）
- 登录态本地持久化，启动后自动恢复
- Token 临近过期时自动调用 `/auth/refresh` 续签
- Auth 状态管理 + GoRouter redirect 守卫
- **新用户引导**：首次进入成员为空时自动弹底部引导弹层
- Home 页（4 Tab + MemberSwitcherBar + FAB）
- 成员列表、新增、编辑、删除、切换
- 成员综合档案页（基础信息、待办提醒、健康文档、指标记录、最近动态、快捷操作）
- 健康提醒列表（筛选/分组/完成切换）
- 健康提醒周视图 / 月视图（日期网格、提醒数量、当天提醒清单）
- 健康提醒表单（手动创建 + AI 预填 + 编辑）
- 健康提醒详情（完成 / 编辑（GoRouter）/ 删除）
- AI 输入页（文本/语音输入 → 解析 → 预填表单）
- 文档上传（拍照/相册/文件 + 直传 R2 + OCR 触发）
- **文档详情页**：图片预览（手势缩放）、AI 摘要（中文字段、过滤空值）、OCR 原文、删除
- OCR 审核页（中文字段展示、过滤空值、AI 不可用时橙色提示条）
- OCR 候选提醒确认创建（上传审核页 + 文档详情页；支持常见日期表达预填）
- 文档列表（含 `onTap` 跳转详情、独立页面有 AppBar/返回键）
- 健康指标录入表单
- 健康指标历史 + 折线图（含 MemberSwitcherBar）
- 个人中心页
- 通知设置页（权限状态、待发送数量、测试通知、清空本地提醒、打开系统设置）
- 关于页（MVP 版本、项目说明、隐私说明、GitHub 仓库入口）
- 本地通知调度（创建/完成/删除时联动）
- 通知点击跳转事件详情（`GlobalKey<NavigatorState>` + GoRouter）
- 全部 Repository snake_case → camelCase normalize 映射
- `url_launcher` 包：支持在浏览器打开 PDF / 原文件

---

## 4. 已知待修复问题（第五轮收尾状态）

### P0 - ✅ 全部已修复（含第五轮新增）

| 编号 | 问题 | 状态 | 修复位置 |
|------|------|------|------|
| #1 | `createMember` camelCase → snake_case | ✅ 已修 | `member_repository.dart` |
| #2 | `createEvent` camelCase → snake_case | ✅ 已修 | `event_repository.dart` |
| #3 | 成员新增 + 提醒创建端到端验证 | ✅ 已验证 | — |
| #14 | 文档上传后无法查看（列表无 onTap） | ✅ 已修 | `document_list_screen.dart` + 新增 `document_detail_screen.dart` |
| #15 | 新用户无引导（成员为空时白屏） | ✅ 已修 | `home_screen.dart`（首次进入弹引导底部弹层） |
| #16 | EventDetailScreen 编辑用 Navigator 而非 GoRouter | ✅ 已修 | `event_detail_screen.dart` + 新路由 `/events/:id/edit` |
| #17 | `/documents` 路由无 AppBar / 无返回键 | ✅ 已修 | `app_router.dart`（补 AppBar + FAB） |

**第四轮额外修复**：后端 `member_repository.py` 改 `model_dump(mode="json")`；阿里云 SMS debug bypass；通知跳转 GlobalKey；MemberSwitcherBar 导航修复。

### P1 - ✅ 全部已联调

| 编号 | 问题 | 状态 |
|------|------|------|
| #4 | 文档上传端到端联调 | ✅ 完整验证（上传 → OCR → AI 摘要 → 详情查看） |
| #5 | 提醒创建完整流程联调 | ✅ 已验证 |
| #6 | 健康指标录入联调 | ✅ 已验证 |
| #7 | 成员切换后各 Tab 数据联动 | ✅ 已验证 |
| #8 | 成员编辑字段覆盖验证 | ✅ 已修复 |

### 第五轮新增修复（OCR 链路全面修复）

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #18 | OCR 传私有 R2 URL（403） | ✅ 已修 | 改为先生成预签名 URL 再传给百度 |
| #19 | OCR 超时 10s 不够 | ✅ 已修 | 改为 30s，加 `raise_for_status()` |
| #20 | 使用 `accurate_basic` 而非 `health_report` | ✅ 已修 | 优先调体检报告专用接口，失败降级 |
| #21 | `health_report` 返回 `words_result` 未解析 | ✅ 已修 | 正确解析 `{word, word_name}` 格式并映射中文字段名 |
| #22 | AI 摘要显示英文 key + 空值 | ✅ 已修 | 加中文字段映射表、过滤空值/列表 |
| #23 | Dashscope 模型名 `qwen3.6-plus` 无效 | ✅ 已修 | 改为 `qwen-plus` |
| #24 | AI Key 失效显示原始异常堆栈 | ✅ 已修 | 友好提示 + OCR 审核页橙色提示条 |

### P2 - 体验优化（MVP 后补齐）

| 编号 | 问题 | 状态 |
|------|------|------|
| #9 | 通知点击跳转详情页 | ✅ 已实现 |
| #10 | 日历月/周网格视图 | ✅ 已实现 |
| #11 | 语音输入 | ✅ 已实现 |
| #12 | Apple 登录 | ✅ 已实现 |
| #13 | Token 过期自动刷新 | ✅ 已实现 |

### 第六轮新增修复

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #25 | 日历缺少月/周网格视图 | ✅ 已修 | `EventListScreen` 增加“列表 / 周 / 月”切换、周/月日期网格、每天提醒数量、当天提醒清单 |
| #26 | 文档详情页 Dart 语法错误导致测试无法编译 | ✅ 已修 | AI 摘要过滤逻辑移出 `ListView.children`，`flutter test` 已通过 |

### 第七轮新增修复（登录态续期）

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #27 | App 重启后需要重新登录 | ✅ 已修 | 前端用 `shared_preferences` 保存 token、用户和过期时间，启动后自动恢复 |
| #28 | JWT 固定 7 天过期后只能重新登录 | ✅ 已修 | 后端新增 `/auth/refresh`，前端在 token 临近 24 小时过期时自动续签 |

### 第八轮新增修复（候选提醒确认增强）

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #29 | OCR 候选提醒只在上传后短暂可见 | ✅ 已修 | 抽成 `CandidateEventList`，上传审核页与文档详情页均可创建候选提醒 |
| #30 | OCR 候选提醒时间固定为 30 天后 | ✅ 已优化 | 前端支持“明天 / 后天 / 下周 / 3个月后 / 2026-05-01 / 5月1日”等常见表达预填日期 |
| #31 | OCR 创建提醒来源标记不准确 | ✅ 已修 | 候选提醒创建时 `source_type` 标记为 `ai_document` |
| #32 | `flutter analyze` 剩余 lint/info 未清理 | ✅ 已修 | 排除生成文件，真实源码 lint/info 已清理，`flutter analyze` 已通过 |

### 第九轮新增修复（Apple 登录与语音输入）

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #33 | Apple 登录未进入首版 | ✅ 已修 | 前端新增 Apple 登录按钮；后端新增 `/auth/apple`，验证 Apple identity token 后同步 Supabase 用户并签发 JWT |
| #34 | AI 创建提醒缺少语音输入 | ✅ 已修 | AI 输入页接入 `speech_to_text`，支持普通话听写、编辑后再 AI 解析 |
| #35 | iOS 缺少 Apple/语音配置 | ✅ 已修 | 新增 Apple Sign In entitlement、`NSSpeechRecognitionUsageDescription`，保留麦克风权限说明 |

### 第十轮新增修复（通知设置与成员综合档案）

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| #36 | 通知设置页只是占位，无法自查权限或测试通知 | ✅ 已修 | 新增权限状态、待发送数量、请求权限、5 秒后测试通知、清空本地提醒、打开系统设置 |
| #37 | 关于页只是系统弹窗，项目说明不足 | ✅ 已修 | 新增独立关于页，展示 MVP 版本、项目介绍、隐私说明与 GitHub 入口 |
| #38 | 成员缺少综合档案页 | ✅ 已修 | 新增成员综合档案页，聚合基础信息、待办提醒、文档、指标和快捷操作 |

---

## 5. 技术架构关键变更

### 5.1 登录链路

```
旧方案（未完成）：
Flutter → Supabase Phone OTP（无阿里云 provider）→ GoTrue session → JWT

新方案（已完成）：
Flutter → 后端 /auth/send-sms-code → 阿里云 Dypnsapi SendSmsVerifyCode → 手机收短信
Flutter → 后端 /auth/verify-sms-code → 阿里云 CheckSmsVerifyCode → Supabase 创建用户 → 自签 JWT → 返回 token
后端验证：security.py 本地 HS256 解码 JWT，不走 GoTrue 远程验证
```

### 5.2 JWT 结构

```json
{
  "aud": "authenticated",
  "iss": "<SUPABASE_URL>/auth/v1",
  "sub": "<supabase_user_uuid>",
  "role": "authenticated",
  "phone": "13XXXXXXXXX",
  "iat": <now>,
  "exp": <now + 7days>,
  "app_metadata": {"provider": "phone"}
}
```

### 5.3 snake_case / camelCase 约定

- **后端返回**：统一 snake_case（Pydantic 默认）
- **前端接收**：各 Repository 的 normalize helper 做映射，再传给 Freezed 模型
- **前端发送**：手写 snake_case Map（不用 Freezed 的 `toJson()`，因为 Freezed 生成 camelCase）

---

## 6. 下次开发建议顺序

1. **完整端到端回归验证**：
   - 手机号 + 验证码 `000000` 登录
   - 新用户引导 → 创建本人档案
   - 添加提醒（手动 + AI 创建）→ 完成提醒
   - 上传体检报告 → OCR 识别 → 创建候选提醒 → 查看文档详情
   - 录入健康指标 → 查看趋势图

2. **首版上线前配置确认**：
   - Apple Developer 中开启 Sign in with Apple
   - 后端 `.env` 配置 `APPLE_CLIENT_ID`（通常为 iOS Bundle ID）
   - 真机验证语音识别权限与听写体验

3. **可选增强**：
   - 首屏加载骨架屏优化

---

## 7. 开发环境启动

```bash
# 后端
cd health-clock-backend
./venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 模拟器（iPhone 17，UDID: 39365EA4-B750-4412-9552-57C7545456D1）
xcrun simctl boot 39365EA4-B750-4412-9552-57C7545456D1
open -a Simulator

# Flutter（带 Supabase 配置）
cd health-clock-app
./run-app.sh 39365EA4-B750-4412-9552-57C7545456D1
```

**所有必要的 .env 项均已配置**（Supabase / 阿里云 / R2 / AI / OCR），无需修改 `.env` 即可启动。
