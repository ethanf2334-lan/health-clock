# 健康时钟项目快速参考

## 快速命令

### 检查项目状态
```bash
./check-status.sh
```

### 启动后端服务
```bash
./start-backend.sh
```

### 测试 API
```bash
python3 test-api.py
```

### 初始化 Flutter 项目
```bash
./init-flutter.sh
```

## 常用开发命令

### 后端开发
```bash
# 进入后端目录
cd health-clock-backend

# 激活虚拟环境
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 启动开发服务器
uvicorn app.main:app --reload

# 运行测试
pytest tests/

# 代码格式化
black app/

# 代码检查
flake8 app/
```

### 前端开发
```bash
# 进入前端目录
cd health-clock-app

# 获取依赖
flutter pub get

# 生成代码
flutter pub run build_runner build --delete-conflicting-outputs

# 运行项目（iOS 模拟器）
flutter run

# 运行测试
flutter test

# 代码格式化
flutter format lib/

# 代码分析
flutter analyze
```

## 环境配置

### 必需配置
- `SUPABASE_URL`: Supabase 项目 URL
- `SUPABASE_ANON_KEY`: Supabase 匿名密钥
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase 服务角色密钥

### 可选配置
- `AI_API_KEY`: Dashscope API Key（用于 AI 解析）
- `R2_ACCESS_KEY_ID`: Cloudflare R2 访问密钥（用于文件上传）
- `R2_SECRET_ACCESS_KEY`: Cloudflare R2 密钥
- `TENCENT_SECRET_ID`: 腾讯云密钥 ID（用于 OCR）
- `TENCENT_SECRET_KEY`: 腾讯云密钥

## API 端点

### 认证
- `GET /api/v1/auth/me` - 获取当前用户信息

### 成员管理
- `GET /api/v1/members` - 获取成员列表
- `POST /api/v1/members` - 创建成员
- `GET /api/v1/members/{id}` - 获取成员详情
- `PUT /api/v1/members/{id}` - 更新成员
- `DELETE /api/v1/members/{id}` - 删除成员

### 健康提醒
- `GET /api/v1/events` - 获取提醒列表
- `POST /api/v1/events` - 创建提醒
- `GET /api/v1/events/{id}` - 获取提醒详情
- `PUT /api/v1/events/{id}` - 更新提醒
- `DELETE /api/v1/events/{id}` - 删除提醒
- `POST /api/v1/events/{id}/complete` - 标记完成

### AI 解析
- `POST /api/v1/ai/parse-text` - 解析自然语言文本

### 文档管理
- `POST /api/v1/documents/upload-signature` - 获取上传签名
- `POST /api/v1/documents` - 保存文档元数据
- `GET /api/v1/documents` - 获取文档列表
- `GET /api/v1/documents/{id}` - 获取文档详情
- `PUT /api/v1/documents/{id}` - 更新文档
- `DELETE /api/v1/documents/{id}` - 删除文档
- `POST /api/v1/documents/ocr` - OCR 识别

### 健康指标
- `GET /api/v1/metrics` - 获取指标列表
- `POST /api/v1/metrics` - 创建指标记录
- `GET /api/v1/metrics/{id}` - 获取指标详情
- `DELETE /api/v1/metrics/{id}` - 删除指标

## 故障排查

### 后端服务无法启动
1. 检查 Python 版本（需要 3.11+）
2. 检查虚拟环境是否激活
3. 检查依赖是否完整安装
4. 检查端口 8000 是否被占用

### API 返回 401 错误
1. 检查 Supabase 配置是否正确
2. 检查 token 是否有效
3. 检查用户是否已登录

### AI 解析失败
1. 检查 AI_API_KEY 是否配置
2. 检查网络连接
3. 查看后端日志

### 文件上传失败
1. 检查 R2 配置是否正确
2. 检查文件大小（最大 10MB）
3. 检查文件类型（仅支持 JPG/PNG/PDF）

## 文档链接

- [需求文档](docs/健康时钟-需求文档.md)
- [技术架构](docs/健康时钟-技术架构文档.md)
- [数据库设计](docs/健康时钟-数据库设计文档.md)
- [API 文档](docs/健康时钟-API接口文档.md)
- [开发指南](docs/健康时钟-开发指南.md)

## 联系方式

如有问题，请查看文档或提交 Issue。
