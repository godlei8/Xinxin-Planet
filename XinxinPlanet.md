# XinxinPlanet 开发文档

## 1. 文档目标

用于沉淀馨馨星球的架构约束、模块边界、研发流程和发布规范，确保版本迭代可持续、可维护、可回归。

- 当前文档版本：`v5.1.0`
- 更新日期：`2026-03-25`

## 2. 产品定位

- 关键词：情感化、极简、自律、陪伴
- 核心体验原则：
  - 低认知负担：核心路径控制在 1-2 步
  - 温和反馈：鼓励式文案与积极视觉反馈
  - 本地优先：离线可用，网络能力为增强项

## 3. 架构设计

### 3.1 分层结构

- `core/`：主题、常量、数据库、公共组件、工具方法
- `features/`：按业务拆分（home/habits/calendar/focus/settings/planet）
- `services/`：通知、备份、跨模块 Provider 聚合
- `routes/`：底部导航与页面路由

### 3.2 状态管理

- 统一使用 `flutter_riverpod`
- 约束：
  - 页面仅负责展示与交互分发
  - 业务状态由 Notifier 管理
  - 数据持久化由 Repository 负责

### 3.3 数据存储

- `sqflite`：习惯、打卡、成就、专注等结构化数据
- `shared_preferences`：主题、提醒开关、宠物档案等轻量配置

## 4. 关键模块说明

### 4.1 首页（Home）

- 展示今日任务、完成进度、每日一句
- 本版新增：首页大卡片展示当前 Q版宠物概览
- 每日一句区域已移除图片展示，仅保留文案信息

### 4.2 习惯与成就（Habits / Achievement）

- 习惯 CRUD
- 打卡成功后触发连胜与成长更新
- 成就进度实时计算与奖励发放

### 4.3 日历（Calendar）

- 月/周视图
- 按日期查看打卡记录
- 节日显示与统计卡片展示

### 4.4 专注（Focus）

- 计时状态机：`idle / running / paused / finished`
- 专注森林记录沉淀

### 4.5 设置（Settings）

- 主题色与深色模式
- 通知开关、测试通知、系统设置跳转
- 健康提醒频率配置
- 数据备份/恢复/分享

### 4.6 星球宠物（Planet Pet）

- 本版升级为 Q版 2D 立体风宠物体系
- 物种：`panda / rabbit / cat / dog / fox / hamster / penguin / koala / deer / alpaca`
- 交互动作：`feed / play / pet / rest`
- 成长字段：`level / exp / energy / mood`
- 数据存储：`planet_pet_profile_v1`（SharedPreferences）

## 5. 本版增量开发（v5.0.0）

### 5.1 宠物能力升级

- 新增组件：`CutePetAvatar`
- 新增物种定义：`PlanetPetSpecies`
- 升级页面：`planet_pet_page.dart`（Q版宠物预览、动作交互、外观切换）

### 5.2 首页整合

- `home_page.dart` 读取 `planetPetProvider`
- 大卡片新增宠物信息与 Q版小预览
- 每日一句卡片移除图片布局

### 5.3 安卓兼容优化

- 移除不必要的 `usesCleartextTraffic`，恢复默认安全策略

### 5.4 通知可靠性优化

- 测试通知前显式权限确认
- 权限缺失时给出提示并引导打开系统设置

## 6. 本轮增量修复（v5.1.0）

### 6.1 首页视觉与图标稳定性

- 修复首页蝴蝶装饰乱码（使用 Unicode 转义，避免编码污染）
- 金币图标改为 `Icons.monetization_on_rounded`，规避 emoji 字体兼容问题

### 6.2 Q版宠物与交互逻辑

- 从 3D 模型切换为 Q版 2D 立体风渲染，降低加载开销
- 新增 5 个宠物物种，总数扩展到 10 种
- 宠物名称字号与字重提升，强化识别
- 宠物切换优化：状态先更新、异步持久化，缩短用户感知延迟
- 新增每日互动次数机制：
  - 基础次数：5 次/天
  - 完成 1 个习惯打卡：+1 次当日互动额度
  - 次数耗尽后阻断互动并提示引导

### 6.3 渲染性能优化

- 关键宠物显示区域增加 `RepaintBoundary`，降低重绘影响
- 统一改为本地 Flutter 组件绘制，避免 WebView 渲染抖动

## 7. 工程质量门禁

每次提交至少满足：

```bash
dart format lib
flutter analyze
flutter test
```

本次执行结果：

- `flutter analyze`：通过
- `flutter test`：通过
- `flutter build apk --debug`：通过

## 8. 适配策略

- 页面统一使用 `SafeArea`
- 关键页面使用 `LayoutBuilder` 做窄屏降级
- 高风险场景：小屏设备（<=360dp）、大字体模式、厂商通知限制

## 9. 发布流程（Android）

1. 代码检查 + 自动化测试
2. 构建 APK
3. 真机冒烟（首页/打卡/日历/通知/宠物）
4. 更新 `README.md` 与本开发文档
5. Git 提交并推送

```bash
cd just_light
flutter build apk --debug
# release: flutter build apk --release
```

## 10. 外部规范参考（官方）

- Flutter 自适应最佳实践：<https://docs.flutter.dev/ui/adaptive-responsive/best-practices>
- Flutter 架构指南：<https://docs.flutter.dev/app-architecture/guide>
- Flutter 测试总览：<https://docs.flutter.dev/testing/overview>
- Android 核心质量标准：<https://developer.android.com/docs/quality-guidelines/core-app-quality>
- Android 自适应质量标准：<https://developer.android.com/docs/quality-guidelines/adaptive-app-quality>
- Android 通知权限：<https://developer.android.com/develop/ui/views/notifications/notification-permission>
- Android 闹钟与精确提醒：<https://developer.android.com/develop/background-work/services/alarms>
