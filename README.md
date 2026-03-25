# 馨馨星球 (Xinxin Planet) v3.0

一个基于 Flutter 的自自律打卡应用，帮助用户养成良好习惯，提高生活质量。

## 📱 功能特性

### 1. 习惯管理
- ✅ 添加新习惯，设置名称、图标、颜色
- ✅ 编辑和删除现有习惯
- ✅ 按类别管理习惯
- ✅ 习惯详情查看

### 2. 每日打卡
- ✅ 一键打卡功能
- ✅ 打卡状态实时更新
- ✅ 打卡历史记录
- ✅ 打卡成功率统计

### 3. 连胜计算
- ✅ 当前连胜天数 (currentStreak)
- ✅ 最佳连胜记录 (bestStreak)
- ✅ 连胜中断提醒
- ✅ 连胜数据可视化

### 4. 日历视图
- ✅ 集成 TableCalendar 组件
- ✅ 打卡记录日历标记
- ✅ 月份视图和周视图切换
- ✅ 打卡历史快速查看

### 5. 专注计时器
- ✅ 番茄钟功能（25分钟工作 + 5分钟休息）
- ✅ 状态机控制（空闲/运行/暂停/完成）
- ✅ 计时声音提醒
- ✅ 专注时间统计

### 6. 主题系统
- ✅ 亮色/暗色模式切换
- ✅ 10种主题色可选
- ✅ 响应式设计
- ✅ 系统主题自动适配

### 7. 数据持久化
- ✅ SQLite 本地数据库
- ✅ 数据备份功能
- ✅ 本地存储设置
- ✅ 数据迁移支持

### 8. 通知服务
- ✅ 习惯提醒通知
- ✅ 专注计时结束提醒
- ✅ 连胜中断预警
- ✅ 自定义通知设置

## 🛠 技术栈

### 核心技术
- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言
- **SQLite** - 本地数据库（sqflite）
- **Riverpod** - 状态管理
- **TableCalendar** - 日历组件
- **FlChart** - 图表库
- **Google Fonts** - 字体库

### 架构设计
- **Feature-First + Clean Architecture**
- **Repository Pattern** 数据访问
- **State Machine** 状态管理
- **Dependency Injection** 依赖注入

## 📁 项目结构

```
lib/
├── core/              # 核心功能
│   ├── constants/     # 常量定义
│   ├── database/      # 数据库操作
│   ├── theme/         # 主题配置
│   └── utils/         # 工具函数
├── features/          # 功能模块
│   ├── habits/        # 习惯管理
│   ├── home/          # 首页
│   ├── calendar/      # 日历
│   ├── focus/         # 专注计时
│   └── settings/      # 设置
├── services/          # 服务层
│   ├── notification_service.dart
│   └── providers.dart
├── routes/            # 路由配置
│   └── main_navigation.dart
└── main.dart          # 应用入口
```

## 🚀 快速开始

### 环境要求
- Flutter 3.0+ 
- Dart 2.17+ 
- Android SDK 21+ 
- iOS 11+ 

### 安装步骤
1. 克隆项目
   ```bash
   git clone <repository_url>
   cd just_light
   ```

2. 安装依赖
   ```bash
   flutter pub get
   ```

3. 运行应用
   ```bash
   # Android
   flutter run
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   ```

### 构建 APK
```bash
# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release
```

## 📊 数据结构

### 数据库表
- **habits** - 习惯信息
- **check_records** - 打卡记录
- **categories** - 习惯分类
- **achievements** - 成就系统
- **user_progress** - 用户进度

## 🔧 配置说明

### 主题配置
- 在 `core/theme/app_theme.dart` 中修改主题设置
- 支持自定义主题色和字体

### 通知配置
- 在 `services/notification_service.dart` 中配置通知设置
- 需要在 Android/iOS 中添加相应权限

## 📱 界面预览

### 首页
- 习惯列表展示
- 一键打卡功能
- 连胜数据显示
- 快捷操作按钮

### 日历页
- 月视图打卡记录
- 历史数据查看
- 打卡状态标记
- 日期范围选择

### 专注页
- 番茄钟计时器
- 状态显示
- 统计数据
- 自定义时长

### 设置页
- 主题切换
- 通知设置
- 数据管理
- 关于应用

## 🌟 特色功能

1. **智能连胜计算** - 自动计算当前和最佳连胜
2. **状态机计时器** - 稳定可靠的状态管理
3. **响应式主题** - 适配不同设备和系统
4. **数据可视化** - 直观的统计图表
5. **本地数据安全** - 数据存储在本地，保护隐私

## 🎯 使用场景

- **学生**：养成学习习惯，提高学习效率
- **职场人士**：培养工作习惯，提升工作质量
- **健身爱好者**：坚持运动打卡，保持健康
- **生活达人**：培养良好生活习惯，提升生活品质

## 🔮 未来规划

- [ ] 云同步功能
- [ ] 社交分享
- [ ] 成就系统
- [ ] 数据分析报告
- [ ] 多语言支持

## 📞 联系方式

- **开发者**：Xinxin Team
- **版本**：v3.0.0
- **更新日期**：2026-03-24

---

**馨馨星球，让好习惯成为生活的一部分！** 🎉