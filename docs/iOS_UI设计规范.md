# 健康时钟 iOS UI 设计规范

本文档是 Flutter 前端页面与弹出框的统一设计约束。后续新增或重构页面必须优先使用 `AppStyles` 与 `AppColors`，不得随意新增字号、间距、圆角和阴影魔法数字。

## 1. 字体与字号

应用依赖 iOS 系统默认字体，不指定字体族，让 Flutter 在 iOS 上使用 San Francisco / SF Pro。

统一字阶：

| 语义 | 样式 | 规格 | 使用场景 |
| --- | --- | --- | --- |
| Large Title | `AppStyles.largeTitle` | 34pt / Bold | 极少数首屏强展示标题；列表型、数据型页面默认不使用 |
| Title 1 | `AppStyles.title1` | 28pt / Regular | 少量强展示标题 |
| Title 2 | `AppStyles.title2` | 22pt / Regular | 卡片内重要标题、详情主标题 |
| Title 3 | `AppStyles.title3` | 20pt / Regular | 指标数值、次级标题 |
| Screen Title | `AppStyles.screenTitle` | 22pt / SemiBold | 标准页面标题，如健康日历、健康指标、成员、文档 |
| Headline | `AppStyles.headline` | 17pt / SemiBold | 页面导航标题、卡片标题、主操作文本 |
| Body | `AppStyles.body` | 17pt / Regular | 正文输入值、主要内容 |
| Subhead | `AppStyles.subhead` | 15pt / Regular | 表单标签、列表标题、按钮文本 |
| Footnote | `AppStyles.footnote` | 13pt / Regular | 说明文字、时间、次级描述 |
| Caption 1 | `AppStyles.caption1` | 12pt / Regular | 标签、状态、辅助计数 |

禁止事项：

- 不在业务组件内直接写 `fontSize`，除非是图表、画布或极特殊图形文字。
- 卡片内标题不得使用 Large Title；标准页面标题优先使用 `screenTitle`，不要因为是一级路由就默认放大到 34pt。
- 从弹出框、列表项、设置页进入的可返回页面，标题使用 `screenTitle` 或 `headline`，返回键采用 44pt 触控区 + 32-36pt 视觉圆形，不与标题一起制造过高顶栏。
- 弹出框内标题使用 `headline` 或 `sheetTitle`，正文使用 `subhead` / `footnote`，避免“老年版”大字号。

## 2. 间距与网格

基础网格使用 8pt：

- 页面左右边距：`AppStyles.screenMargin = 16`
- 卡片内边距：`AppStyles.cardPadding = 16`
- 紧密元素间距：`spacingXs = 4`，`spacingS = 8`
- 模块间距：`spacingM = 16`，`spacingL = 24`
- 大模块间距：`spacingXl = 32`

禁止事项：

- 不使用 10、11、14、18、22、26 等散落间距作为布局主间距。
- 不用多层 `Padding` 堆叠制造间距；优先用 `SizedBox` 控制兄弟元素间距。
- 首屏页面需要检查内容密度，重要操作和第一组列表应尽量在首屏可见。

## 3. 圆角、阴影与边框

统一圆角：

- 小控件：`radiusS = 8`
- 输入框、按钮、标签：`radiusM = 12`
- 卡片：`radiusL = 16`
- 大卡片 / 弹出框：`radiusXl = 20`
- 胶囊：`radiusFull = 999`

统一阴影：

- 普通卡片：`AppStyles.cardShadow`
- 轻量控件：`AppStyles.subtleShadow`

边框：

- 使用 `AppColors.lightOutline`
- 分割线使用 `AppStyles.dividerThin` 或 0.5pt 视觉线
- 避免浓重阴影和大面积纯色块；白底卡片 + 浅边框 + 柔和阴影是默认方案。

## 4. 页面结构

标准页面结构：

1. 白色页面背景。
2. 顶部 `screenTitle` + 一行副标题；只有需要强品牌/情绪表达的首屏才升级为 Large Title。
3. 当前成员、筛选器等作为轻量胶囊控件，不压缩标题区。
4. 内容区使用白色卡片承载，卡片之间 16/24pt 间距。
5. 列表行信息按“时间 / 主值 / 辅助信息 / 状态”横向组织，避免无意义换行。

健康类数据页：

- 最新数据放在状态卡片左侧，趋势图放右侧。
- 数据状态卡应保持首屏密度：卡片圆角优先 `radiusL`，内边距 16pt，状态图标视觉尺寸 32-36pt，图标本体 18-20pt。
- 紧凑状态卡内的指标主值使用 `title1` 或 `title2`；只有独立大数据展示页才允许使用 Large Title 级别的指标数值。
- 迷你趋势图高度控制在 104-120pt；不要让图表撑大卡片，趋势只是辅助信息。
- 指标类型筛选使用 44pt 高度控件，图标 18-20pt，文字 `footnote` / `subhead`，避免做成大按钮。
- 记录预览输入块高度控制在 52-60pt；标签用 `caption1`，值用 `subhead`，两列优先于三列挤压。
- 数值与单位同一行展示，例如 `128 / 78 mmHg`、`65 kg`。
- 近期记录默认最新在前。
- 测量时间按用户输入的墙钟时间显示，不对 `recordedAt` 做 `toLocal()` 二次换算。

## 5. 弹出框规范

底部弹出框：

- 顶部圆角：`radiusXl`
- 标题：`AppStyles.headline`
- 说明：`AppStyles.footnote`
- 行高：输入控件 40-44pt，主要按钮 44-48pt
- 内容高度应优先适配一屏，避免无必要滚动
- 底部按钮不得过大；主次按钮并排时高度 44pt

日期时间选择：

- 使用 `AppCupertinoPickers`，避免 Material 日期/时间选择器。
- 时间选择器必须处理 `minuteInterval` 对齐，防止 Cupertino assertion。

## 6. 交互与状态

- 所有可点击区域最小 44x44pt。
- 切换筛选或视图时保留旧数据，不显示突兀的全屏 loading。
- 不显示 mock 数据；没有真实数据时显示空状态。
- 首页、弹窗、详情页的数据排序要符合用户心智：近期、待办、最新优先。

## 7. 开发审查清单

每次新增或修改 UI 后必须检查：

- 是否还有业务组件内硬编码 `fontSize`。
- 页面主标题是否统一，卡片标题是否过大。
- 可返回页面是否仍误用了 Large Title。
- 图标容器、筛选按钮、指标数值是否超过健康日历首页的视觉密度。
- 间距是否落在 4/8/16/24/32 网格。
- 输入框、列表项和按钮是否不超过必要高度。
- 文字是否在 iPhone 宽度下换行、溢出或遮挡。
- 弹出框是否能在一屏内展示主要内容。
- 真实数据、空状态、加载状态和错误状态是否都可用。
- 运行 `flutter analyze`，并在模拟器上看关键页面截图。
