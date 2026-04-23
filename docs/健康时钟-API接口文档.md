# 健康时钟 API 接口文档

## 基础信息

- Base URL: `http://localhost:8000/api/v1`
- 认证方式: Bearer Token (Supabase JWT)
- 请求格式: JSON
- 响应格式: JSON

## 统一响应格式

### 成功响应

```json
{
  "code": 0,
  "message": "ok",
  "data": {}
}
```

### 错误响应

```json
{
  "code": 1001,
  "message": "资源不存在",
  "data": null
}
```

### 错误码

- `0`: 成功
- `1001`: 资源不存在
- `1002`: 参数错误
- `1003`: 未认证或 token 无效
- `1004`: 无权限访问该成员数据
- `2001`: AI 解析失败
- `2002`: OCR 处理失败
- `3001`: 文件上传失败

## 认证

### 获取当前用户信息

```
GET /auth/me
```

**Headers:**
```
Authorization: Bearer <supabase_access_token>
```

**响应:**
```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "phone": "+8613800138000"
  }
}
```

## 成员管理

### 获取成员列表

```
GET /members
```

**响应:**
```json
{
  "code": 0,
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "name": "张三",
      "relation": "self",
      "gender": "male",
      "birth_date": "1990-01-01",
      "height_cm": 175.0,
      "weight_kg": 70.0,
      "blood_type": "A",
      "chronic_conditions": ["高血压"],
      "allergies": ["青霉素"],
      "notes": "备注",
      "created_at": "2026-04-23T10:00:00+08:00",
      "updated_at": "2026-04-23T10:00:00+08:00"
    }
  ]
}
```

### 创建成员

```
POST /members
```

**请求体:**
```json
{
  "name": "张三",
  "relation": "self",
  "gender": "male",
  "birth_date": "1990-01-01",
  "height_cm": 175.0,
  "weight_kg": 70.0,
  "blood_type": "A",
  "chronic_conditions": ["高血压"],
  "allergies": ["青霉素"],
  "notes": "备注"
}
```

### 获取成员详情

```
GET /members/{member_id}
```

### 更新成员

```
PUT /members/{member_id}
```

**请求体:** 同创建成员，所有字段可选

### 删除成员

```
DELETE /members/{member_id}
```

## 健康提醒

### 获取提醒列表

```
GET /events?member_id=xxx&start_date=2026-04-01T00:00:00+08:00&end_date=2026-04-30T23:59:59+08:00&status=pending&event_type=follow_up
```

**查询参数:**
- `member_id`: 成员 ID（可选）
- `start_date`: 开始日期 ISO8601（可选）
- `end_date`: 结束日期 ISO8601（可选）
- `status`: pending/completed/cancelled（可选）
- `event_type`: follow_up/revisit/checkup/medication/monitoring/custom（可选）

**响应:**
```json
{
  "code": 0,
  "data": [
    {
      "id": "uuid",
      "member_id": "uuid",
      "title": "甲状腺复查",
      "description": "3 个月后复查甲状腺功能",
      "event_type": "follow_up",
      "scheduled_at": "2026-07-23T09:00:00+08:00",
      "is_all_day": false,
      "repeat_rule": null,
      "notify_offsets": [0, -1440],
      "status": "pending",
      "source_type": "ai_text",
      "source_text": "甲状腺 3 个月后复查",
      "ai_confidence": 0.92,
      "created_at": "2026-04-23T10:00:00+08:00",
      "updated_at": "2026-04-23T10:00:00+08:00",
      "completed_at": null
    }
  ]
}
```

### 创建提醒

```
POST /events
```

**请求体:**
```json
{
  "member_id": "uuid",
  "title": "甲状腺复查",
  "description": "3 个月后复查甲状腺功能",
  "event_type": "follow_up",
  "scheduled_at": "2026-07-23T09:00:00+08:00",
  "is_all_day": false,
  "repeat_rule": null,
  "notify_offsets": [0, -1440],
  "source_type": "manual",
  "source_text": null,
  "ai_confidence": null
}
```

### 获取提醒详情

```
GET /events/{event_id}
```

### 更新提醒

```
PUT /events/{event_id}
```

**请求体:** 同创建提醒，所有字段可选

### 删除提醒

```
DELETE /events/{event_id}
```

### 标记提醒为已完成

```
POST /events/{event_id}/complete
```

## AI 解析

### 解析自然语言文本

```
POST /ai/parse-text
```

**请求体:**
```json
{
  "text": "甲状腺 3 个月后复查",
  "member_id": "uuid",
  "member_name": "张三",
  "now": "2026-04-23T10:00:00+08:00"
}
```

**响应:**
```json
{
  "code": 0,
  "data": {
    "parsed_event": {
      "member_name": "张三",
      "event_title": "甲状腺复查",
      "event_type": "follow_up",
      "scheduled_at": "2026-07-23T09:00:00+08:00",
      "is_all_day": false,
      "repeat_rule": null,
      "source": "ai_text",
      "confidence": 0.92,
      "needs_confirmation": true
    },
    "raw_text": "甲状腺 3 个月后复查"
  }
}
```

## 健康指标

### 获取指标记录列表

```
GET /metrics?member_id=xxx&metric_type=blood_pressure&start_date=2026-04-01T00:00:00+08:00&end_date=2026-04-30T23:59:59+08:00
```

**查询参数:**
- `member_id`: 成员 ID（可选）
- `metric_type`: blood_pressure/blood_sugar/weight/height/heart_rate/temperature/blood_oxygen（可选）
- `start_date`: 开始日期 ISO8601（可选）
- `end_date`: 结束日期 ISO8601（可选）

**响应:**
```json
{
  "code": 0,
  "data": [
    {
      "id": "uuid",
      "member_id": "uuid",
      "metric_type": "blood_pressure",
      "value": 138.0,
      "value_extra": {
        "systolic": 138,
        "diastolic": 92
      },
      "unit": "mmHg",
      "recorded_at": "2026-04-23T08:00:00+08:00",
      "note": "早晨测量",
      "created_at": "2026-04-23T08:05:00+08:00"
    }
  ]
}
```

### 创建指标记录

```
POST /metrics
```

**请求体:**
```json
{
  "member_id": "uuid",
  "metric_type": "blood_pressure",
  "value": 138.0,
  "value_extra": {
    "systolic": 138,
    "diastolic": 92
  },
  "unit": "mmHg",
  "recorded_at": "2026-04-23T08:00:00+08:00",
  "note": "早晨测量"
}
```

### 获取指标记录详情

```
GET /metrics/{record_id}
```

### 删除指标记录

```
DELETE /metrics/{record_id}
```

## 文档管理

### 获取上传签名

```
POST /documents/upload-signature
```

（待实现）

### 保存文件元数据

```
POST /documents
```

（待实现）

### 获取文件列表

```
GET /documents
```

（待实现）

### 获取文件详情

```
GET /documents/{document_id}
```

（待实现）

## 健康检查

### 服务健康检查

```
GET /health
```

**响应:**
```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "status": "healthy"
  }
}
```
