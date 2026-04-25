# Health Clock App

健康时钟 MVP 客户端应用

## 技术栈

- Flutter 3.0+
- Riverpod (状态管理)
- GoRouter (路由)
- Drift (本地数据库)
- Supabase (认证 + 云端数据)

## 安装 Flutter

如果尚未安装 Flutter，请访问：https://flutter.dev/docs/get-started/install

macOS 快速安装：
```bash
# 使用 Homebrew
brew install --cask flutter

# 验证安装
flutter doctor
```

## 初始化项目

```bash
# 进入项目目录
cd health-clock-app

# 获取依赖
flutter pub get

# 生成代码（路由、状态管理等）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行项目（iOS 模拟器）
flutter run
```

## 项目结构

```
lib/
  app/
    router/         # 路由配置
    theme/          # 主题配置
    di/             # 依赖注入
  core/
    constants/      # 常量
    error/          # 错误处理
    utils/          # 工具类
    services/       # 核心服务
  features/
    auth/           # 认证模块
    members/        # 成员管理
    calendar/       # 日历视图
    ai_input/       # AI 输入
    documents/      # 文档管理
    health_records/ # 健康记录
    notifications/  # 通知
    settings/       # 设置
  shared/
    widgets/        # 共享组件
    models/         # 共享模型
```

## 环境配置

创建 `.env` 文件（不要提交到 git）：

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

运行时传入环境变量：
```bash
flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
```

## 开发命令

```bash
# 代码生成（监听模式）
flutter pub run build_runner watch

# 代码格式化
flutter format lib/

# 代码分析
flutter analyze

# 运行测试
flutter test
```

## iOS 配置

1. 打开 `ios/Runner.xcworkspace`
2. 配置 Bundle Identifier
3. 在 Signing & Capabilities 中确认 Sign in with Apple 已启用
4. 确认通知、麦克风、语音识别权限说明已配置
5. 后端 `.env` 配置 `APPLE_CLIENT_ID=<iOS Bundle ID>`

## 下一步

1. 完整端到端回归验证
2. 真机验证 Apple 登录与语音输入
3. 完成通知设置页 / 关于页（可选）
