# 馨馨星球 (Xinxin Planet) - Bug 日志

> 记录项目开发过程中遇到的顽固问题和解决方案

---

## Bug #001: Android 构建失败 - 路径包含中文字符

### 问题描述
Android APK 构建持续失败，错误信息显示 `shared_preferences_android` 插件的 Kotlin 编译出错。

### 错误日志
```
exception: error: source file or directory not found: C:\Users\godu78CA\AppData\Local\Pub\Cache\hosted\pub.flutter-io.cn\shared_preferences_android-2.4.21\android\src\main\kotlin\io\flutter\plugins\sharedpreferences\MessagesAsync.g.kt

exception: error: source file or directory not found: C:\Users\godu78CA\AppData\Local\Pub\Cache\hosted\pub.flutter-io.cn\shared_preferences_android-2.4.21\android\src\main\kotlin\io\flutter\plugins\sharedpreferences\SharedPreferencesPlugin.kt

exception: error: source file or directory not found: C:\Users\godu78CA\AppData\Local\Pub\Cache\hosted\pub.flutter-io.cn\shared_preferences_android-2.4.21\android\src\main\kotlin\io\flutter\plugins\sharedpreferences\StringListObjectInputStream.kt
```

### 根本原因
用户名路径中包含中文字符 `god磊`，导致：
1. Flutter Pub Cache 系统缓存路径解析错误
2. Gradle Kotlin 编译器无法正确处理包含中文字符的路径
3. Kotlin 标准库依赖无法正确加载

### 尝试的解决方案

| 方案 | 命令/操作 | 结果 | 原因 |
|------|----------|------|------|
| 1 | `flutter clean` | 部分清理 | build 目录清理但系统缓存仍损坏 |
| 2 | 删除 `C:\Users\godu78CA\.gradle` | 失败 | 权限限制无法删除用户目录 |
| 3 | 删除 `C:\Users\godu78CA\AppData\Local\Pub\Cache` | 失败 | 沙盒环境限制，无法删除系统缓存 |
| 4 | 设置 `PUB_CACHE` 环境变量到纯 ASCII 路径 | 部分成功 | 插件重新下载但 Kotlin 编译仍失败 |
| 5 | 删除 `.pub-cache` 并重新 `flutter pub get` | 失败 | 插件包本身损坏或不完整 |

### 成功解决方案（2026-03-24）

通过重定向所有缓存路径到纯英文目录：

**步骤 1：创建纯英文缓存目录**
```powershell
New-Item -ItemType Directory -Path "C:\flutter_cache\pub" -Force
New-Item -ItemType Directory -Path "C:\flutter_cache\gradle" -Force
New-Item -ItemType Directory -Path "C:\flutter_cache\temp" -Force
```

**步骤 2：设置环境变量（用户级别）**
```powershell
[Environment]::SetEnvironmentVariable("PUB_CACHE", "C:\flutter_cache\pub", "User")
[Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", "C:\flutter_cache\gradle", "User")
[Environment]::SetEnvironmentVariable("TEMP", "C:\flutter_cache\temp", "User")
[Environment]::SetEnvironmentVariable("TMP", "C:\flutter_cache\temp", "User")
```

**步骤 3：在当前 session 设置环境变量并构建**
```powershell
$env:PUB_CACHE = "C:\flutter_cache\pub"
$env:GRADLE_USER_HOME = "C:\flutter_cache\gradle"
$env:TEMP = "C:\flutter_cache\temp"
$env:TMP = "C:\flutter_cache\temp"
flutter clean
flutter pub get
flutter build apk
```

### 状态
**已解决** ✅

### 构建产物
- APK 路径: `build\app\outputs\flutter-apk\app-release.apk`
- APK 大小: 49.7MB

### 注意事项
- 环境变量设置后需要重启终端/IDE 才能完全生效
- 在当前 session 中使用 `$env:` 前缀设置临时环境变量可以立即生效
- 首次构建可能会有很多警告，但只要最终显示 `Built build\app\outputs\flutter-apk\app-release.apk` 即表示成功

---

## Bug #002: Category 模型名称冲突

### 问题描述
编译时报错：`The name 'Category' is defined in the libraries 'package:flutter/src/foundation/annotations.dart' and 'package:xinxin_planet/models/category.dart'`

### 错误原因
Flutter SDK 中存在 `Category` 注解类，与自定义的 `Category` 模型命名冲突。

### 解决方案
使用别名导入避免命名冲突：

```dart
import 'category.dart' as models;

class HabitModel extends ChangeNotifier {
  List<models.Category> _categories = models.DefaultCategories.defaults;

  models.Category get currentCategory => _categories.firstWhere(
    (c) => c.id == _categoryId,
    orElse: () => _categories.last,
  );
}
```

### 状态
**已解决** ✅

---

## Bug #003: variable 'startOfWeek' is final and cannot be shown

### 问题描述
Dart 编译器警告：`startOfWeek` 变量被重复赋值。

### 错误代码
```dart
double get weeklyProgress {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  // ...
}
```

### 解决方案
将 `final` 改为 `var`：

```dart
double get weeklyProgress {
  final now = DateTime.now();
  var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  // ...
}
```

### 状态
**已解决** ✅

---

## Bug #004: Map 类型转换错误

### 问题描述
JSON 导入时类型转换错误。

### 错误代码
```dart
// 错误：decoded['categories'] is List 返回 true，但类型推断为 List<dynamic>
final categoriesJson = decoded['categories'] as List;
_categories = categoriesJson.map((json) => models.Category.fromJson(json)).toList();
```

### 解决方案
明确指定类型：

```dart
final categoriesJson = decoded['categories'] as List;
_categories = categoriesJson
    .whereType<Map<String, dynamic>>()
    .map((json) => models.Category.fromJson(json))
    .toList();
```

### 状态
**已解决** ✅

---

## Bug #005: share_plus 依赖版本问题

### 问题描述
`share_plus: ^7.0.0` 依赖已废弃且与新版本 Flutter 不兼容。

### 解决方案
暂时注释掉该依赖：
```yaml
# share_plus: ^7.0.0
```

### 影响功能
数据分享功能暂时不可用（v3.0 功能）。

### 状态
**已解决** ✅（通过移除依赖）

---

## Bug #006: 测试文件引用旧包名

### 问题描述
测试文件 `widget_test.dart` 引用旧的包名 `just_light`，但项目已重命名为 `xinxin_planet`。

### 错误信息
`Target of URI doesn't exist: 'package:just_light/main.dart'`

### 解决方案
更新导入语句：
```dart
import 'package:xinxin_planet/main.dart';
import 'package:xinxin_planet/models/habit_model.dart';
import 'package:xinxin_planet/services/storage_service.dart';
```

### 状态
**已解决** ✅

---

## 已知环境限制

| 环境 | 状态 | 说明 |
|------|------|------|
| Windows 中文用户名 | ❌ 受限 | 路径包含中文字符导致构建问题 |
| Flutter Web | ✅ 正常 | 无平台特定依赖 |
| Android SDK | ❌ 受限 | 需要修复路径问题 |
| iOS/macOS | ⚠️ 未测试 | 需要 macOS 环境 |

---

*最后更新: 2026-03-24*
