# 健康时钟 MVP 项目进度总览

**更新时间：2026-04-24（第三轮联调完成）**

本文档基于以下资料交叉整理：

- 产品文档：`docs/健康时钟-需求文档.md`
- 项目说明：`docs/健康时钟-项目说明书.md`
- 技术架构：`docs/健康时钟-技术架构文档.md`
- 实际代码：`health-clock-backend/` 与 `health-clock-app/`

---

## 1. 总体判断（第三轮收尾后）

| 维度 | 状态 |
|------|------|
| 后端完成度 | **高**（核心 API + 阿里云短信登录 + 自签 JWT + 鉴权链路全通） |
| 前端完成度 | **高**（主链路页面已实现，正在联调） |
| 整体 MVP 可用性 | **接近可体验**（登录已通，数据库已建，主链路待完整联调） |

一句话总结：登录链路已完全打通（手机号 OTP → 阿里云短信 → 自签 JWT → 后端本地验证），数据库表已建立，后端四个业务模块接口均返回 200；前端所有主链路页面已实现，当前进入"联调修 bug"阶段，主要剩余工作是修复 camelCase/snake_case 阻抗、完整验证各模块端到端。

---

## 2. MVP 模块进度

| 模块 | 文档要求 | 当前状态 | 结论 |
|------|----------|----------|------|
| 账户与登录 | 手机号验证码登录、Apple 登录、用户态 | 手机号 OTP（阿里云短信）+ 自签 JWT 已完整实现；Apple 登录未做 | **✅ 核心已实现** |
| 家庭成员管理 | 成员新增、编辑、删除、切换 | 后端 CRUD 完整；前端列表、新增、编辑、切换、删除均有实现；camelCase 映射已修，待验证 | **✅ 基本完成** |
| 健康提醒 | AI 创建、手动创建、编辑、删除、完成、筛选 | 后端 CRUD + 筛选 + 完成已实现；前端列表、表单、详情页已实现，联调中 | **✅ 基本完成** |
| AI 文本创建提醒 | 自然语言解析、结构化预览、确认保存 | 全链路已实现（AI 解析 → 表单预填 → 保存 → 本地通知） | **✅ 已实现** |
| 语音输入 | 语音转文字后再解析 | 前后端均未实现 | ❌ 未实现 |
| 文档上传与 OCR | 上传图片/PDF、OCR、AI 结构化、候选提醒 | 前后端均已实现，端到端联调待验证 | **⚠️ 待验证** |
| 健康指标记录 | 录入、历史记录、趋势展示 | 前后端均已实现，联调待验证 | **⚠️ 待验证** |
| 日历与列表视图 | 今日、未来 7/30 天、月/周/列表 | 已实现时间区间筛选 + 按天分组列表；月/周网格视图未做 | **⚠️ 部分完成** |
| 通知提醒 | 本地通知、权限、点击跳转 | 本地通知已接入提醒创建/完成/删除流程；点击跳转 TODO | **⚠️ 部分完成** |
| 家庭档案/文件归档 | 按成员查看资料、文件记录 | 文档列表按成员过滤已实现，待联调 | **⚠️ 待验证** |

---

## 3. 已完整实现的内容

### 3.1 后端

- FastAPI 服务 + CORS + 路由注册
- **阿里云短信验证码登录**（`/auth/send-sms-code` + `/auth/verify-sms-code`）
- **Supabase 兼容 JWT 自签**（`SUPABASE_JWT_SECRET` + HS256）
- **本地 JWT 验证**（`security.py`，不走 GoTrue 远程 API）
- Supabase `auth.users` 用户创建/同步（`user_service.py`）
- 成员管理 CRUD
- 健康提醒 CRUD、筛选查询、标记完成
- AI 文本解析接口 `/ai/parse-text`（通义千问）
- 文档上传签名接口、文档元数据 CRUD
- 百度 OCR 识别与 OCR 后 AI 二次提取
- 候选提醒抽取
- 健康指标记录新增、查询、删除
- 数据库迁移脚本（已在 Supabase 执行）、RLS 策略

### 3.2 前端

- 应用入口、主题、中文本地化
- **手机号 OTP 登录**（调后端 `/auth/send-sms-code` + `/auth/verify-sms-code`）
- Auth 状态管理 + GoRouter redirect 守卫
- Home 页（4 Tab + MemberSwitcherBar + FAB）
- 成员列表、新增、编辑、删除、切换
- 健康提醒列表（筛选/分组/完成切换）
- 健康提醒表单（手动创建 + AI 预填 + 编辑）
- 健康提醒详情（完成/编辑/删除）
- AI 输入页（解析 → 预填表单）
- 文档上传（拍照/相册/文件 + 直传 R2 + OCR 触发）
- OCR 审核页（展示原文 + AI 摘要 + 候选提醒）
- 文档列表
- 健康指标录入表单
- 健康指标历史 + 折线图
- 个人中心页
- 本地通知调度（创建/完成/删除时联动）
- 全部 Repository snake_case → camelCase normalize 映射

---

## 4. 已知待修复问题（下次开发优先处理）

### P0 - 必须优先修

| 编号 | 问题 | 影响 | 位置 |
|------|------|------|------|
| #1 | `MemberCreate.toJson()` 输出 camelCase（`birthDate`），后端 Pydantic 期望 snake_case（`birth_date`）| 成员出生日期等字段创建时静默丢失 | `member_repository.dart` `createMember` |
| #2 | `EventCreate.toJson()` 同样输出 camelCase | 提醒 `memberId`→`member_id`, `scheduledAt`→`scheduled_at` 等创建时出错 | `event_repository.dart` `createEvent` |
| #3 | 验证 成员新增 端到端（含 normalize 修复后的完整测试）| 确认 member 能正常创建并出现在列表 | — |

**修复方法**：在 createMember / createEvent 调用处，不用 `model.toJson()`，改为手写 snake_case Map，参考 `createMetric` 的做法（已是 snake_case，可作为范例）。

### P1 - 功能联调

| 编号 | 问题 | 说明 |
|------|------|------|
| #4 | 文档上传端到端联调 | R2 预签名、上传、OCR、AI 提取完整链路验证 |
| #5 | 提醒创建完整流程联调 | 手动创建 + AI 预填 + 本地通知调度 |
| #6 | 健康指标录入联调 | 录入后列表刷新、折线图显示 |
| #7 | 成员切换后各 Tab 数据联动 | `currentMemberIdProvider` 变更后 provider filter 是否正常刷新 |
| #8 | 成员编辑字段覆盖验证 | `updateMember` 已手写 snake_case，需确认出生日期等字段正常更新 |

### P2 - 体验优化（MVP 后补齐）

| 编号 | 问题 |
|------|------|
| #9 | 通知点击跳转详情页（payload 已写，handler TODO） |
| #10 | 日历月/周网格视图（当前为列表替代） |
| #11 | 语音输入 |
| #12 | Apple 登录 |
| #13 | Token 过期自动刷新（当前固定 7 天，过期需重新登录） |

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

1. **修 #1 #2**：`createMember` 和 `createEvent` 改用 snake_case Map 发送 → 验证成员和提醒能正常创建
2. **验证 #3 #5**：完整走一遍"添加成员 → 创建提醒 → 列表展示 → 完成提醒"主链路
3. **联调 #4**：文档上传 → OCR → AI 摘要 → 候选提醒 → 创建提醒
4. **联调 #6 #7**：健康指标录入，成员切换数据联动
5. **清理 P2**：按需补充通知跳转、日历视图等

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
