# 馨馨星球 Xinxin Planet（Flutter）

## 版本

- 当前版本：`v5.0.0`
- 更新时间：`2026-03-25`

## 本版核心更新

- 星球宠物系统升级为 3D（支持 `大熊猫 / 兔子 / 猫 / 狗 / 狐狸`）
- 宠物交互动作：喂食、玩耍、摸摸头、休息
- 首页大卡片新增宠物展示
- 每日一句区域移除图片展示
- 通知测试链路增强（权限预检查 + 系统设置引导）
- Android 增加 `usesCleartextTraffic` 兼容 3D 模型加载

## 技术栈

- Flutter / Dart
- flutter_riverpod
- sqflite
- shared_preferences
- flutter_local_notifications + timezone
- model_viewer_plus

## 运行

```bash
flutter pub get
flutter run
```

## 质量检查

```bash
dart format lib
flutter analyze
flutter test
```

## 构建 APK

```bash
flutter build apk --debug
# or flutter build apk --release
```

产物：

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/flutter-apk/app-release.apk`

## 文档

- 项目 README：`../readme.md`
- 开发文档：`../XinxinPlanet.md`
- 需求增量：`../update.md`
