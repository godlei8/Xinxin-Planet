class FeatureFlags {
  const FeatureFlags._();

  /// 成就系统总开关，异常时可快速降级为只读展示。
  static const bool enableAchievementSystem = true;

  /// 专注森林可视化总开关。
  static const bool enableFocusForest = true;

  /// 健康习惯提醒总开关。
  static const bool enableHealthReminders = true;

  /// 智能习惯建议总开关。
  static const bool enableHabitSuggestions = true;
}
