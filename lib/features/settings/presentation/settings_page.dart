import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../features/habits/presentation/achievement_page.dart';
import '../../../features/settings/domain/health_reminder.dart';
import '../../../services/backup_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/providers.dart';

final dailyReminderEnabledProvider = StateProvider<bool>((ref) => false);
final dailyReminderTimeProvider =
    StateProvider<TimeOfDay>((ref) => const TimeOfDay(hour: 21, minute: 0));

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    ref.read(dailyReminderEnabledProvider.notifier).state =
        prefs.getBool('daily_reminder_enabled') ?? false;
    ref.read(dailyReminderTimeProvider.notifier).state = TimeOfDay(
      hour: prefs.getInt('daily_reminder_hour') ?? 21,
      minute: prefs.getInt('daily_reminder_minute') ?? 0,
    );
  }

  Future<void> _saveReminderSettings(bool enabled, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', enabled);
    await prefs.setInt('daily_reminder_hour', time.hour);
    await prefs.setInt('daily_reminder_minute', time.minute);

    if (!enabled) {
      await NotificationService.cancelHabitReminder(9999);
      if (!mounted) {
        return;
      }
      showAppToast(context, '已关闭每日提醒', type: AppToastType.info);
      return;
    }

    await NotificationService.scheduleDailyReminder(
      id: 9999,
      title: '每日打卡提醒',
      body: '今天也给自己留一点坚持的时间。',
      hour: time.hour,
      minute: time.minute,
    );

    if (!mounted) {
      return;
    }
    showAppToast(
      context,
      '提醒时间已更新为 ${time.format(context)}',
      type: AppToastType.success,
    );
  }

  Future<void> _reloadData() async {
    await Future.wait([
      ref.read(habitsProvider.notifier).loadHabits(),
      ref.read(checkRecordsProvider.notifier).loadTodayRecords(),
      ref.read(userProgressProvider.notifier).loadProgress(),
    ]);
    ref.invalidate(categoriesProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(achievementProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeColorIndex = ref.watch(themeColorIndexProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final dailyReminderEnabled = ref.watch(dailyReminderEnabledProvider);
    final dailyReminderTime = ref.watch(dailyReminderTimeProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final healthRemindersAsync = ref.watch(healthRemindersProvider);

    final unlockedCount = achievementsAsync.maybeWhen(
      data: (achievements) =>
          achievements.where((item) => item.isUnlocked).length,
      orElse: () => 0,
    );
    final totalAchievementCount = achievementsAsync.maybeWhen(
      data: (achievements) => achievements.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ProfileCard(isDarkMode: isDarkMode),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle(title: '外观'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题色', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '挑一个最符合你今天心情的颜色。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children:
                          List.generate(AppColors.themeColors.length, (index) {
                        final color = AppColors.themeColors[index];
                        final isSelected = index == themeColorIndex;
                        return GestureDetector(
                          onTap: () => _saveThemeColor(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: isSelected ? 0.42 : 0.18,
                                  ),
                                  blurRadius: isSelected ? 16 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                      title: const Text('深色模式'),
                      subtitle: Text(isDarkMode ? '夜间阅读更舒适' : '保持明亮与轻盈'),
                      trailing: Switch.adaptive(
                        value: isDarkMode,
                        onChanged: _saveDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle(title: '成长'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events_rounded),
                title: const Text('成就系统'),
                subtitle: Text(
                  totalAchievementCount == 0
                      ? '查看你的成长里程碑'
                      : '已解锁 $unlockedCount / $totalAchievementCount',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openAchievementPage,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle(title: '通知'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_rounded),
                    title: const Text('每日提醒'),
                    subtitle: Text(
                      dailyReminderEnabled
                          ? '每天 ${dailyReminderTime.format(context)}'
                          : '当前未开启',
                    ),
                    trailing: Switch.adaptive(
                      value: dailyReminderEnabled,
                      onChanged: (value) async {
                        ref.read(dailyReminderEnabledProvider.notifier).state =
                            value;
                        try {
                          await _saveReminderSettings(value, dailyReminderTime);
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ref
                              .read(dailyReminderEnabledProvider.notifier)
                              .state = false;
                          showAppToast(
                            context,
                            '提醒设置失败：$error',
                            type: AppToastType.error,
                          );
                        }
                      },
                    ),
                  ),
                  if (dailyReminderEnabled)
                    ListTile(
                      leading: const SizedBox(width: 24),
                      title: const Text('提醒时间'),
                      trailing: Text(
                        dailyReminderTime.format(context),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      onTap: () => _pickReminderTime(dailyReminderTime),
                    ),
                  ListTile(
                    leading: const Icon(Icons.mark_chat_unread_rounded),
                    title: const Text('发送测试通知'),
                    subtitle: const Text('检查权限和通知样式是否生效'),
                    onTap: _sendTestNotification,
                  ),
                ],
              ),
            ),
            if (FeatureFlags.enableHealthReminders) ...[
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(title: '健康习惯联动'),
              Card(
                child: healthRemindersAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const ListTile(
                        title: Text('暂无健康提醒配置'),
                      );
                    }
                    return Column(
                      children: items
                          .map((item) => _buildHealthReminderTile(item))
                          .toList(growable: false),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => ListTile(
                    title: const Text('健康提醒加载失败'),
                    subtitle: Text('$error'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle(title: '数据'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.save_alt_rounded),
                    title: const Text('导出备份'),
                    subtitle: const Text('保存当前数据到应用备份目录'),
                    onTap: _busy ? null : _exportBackup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_rounded),
                    title: const Text('恢复最近备份'),
                    subtitle: const Text('使用最近导出的文件恢复当前数据'),
                    onTap: _busy ? null : _restoreBackup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('分享最近备份'),
                    subtitle: const Text('将最近一次备份文件发送出去'),
                    onTap: _busy ? null : _shareBackup,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_sweep_rounded,
                      color: AppColors.errorColor,
                    ),
                    title: const Text('清空所有数据'),
                    subtitle: const Text('会删除习惯、记录、成就和成长数据'),
                    onTap: _busy ? null : _confirmClearAllData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle(title: '关于'),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.auto_awesome_rounded),
                    title: Text('欣欣星球'),
                    subtitle: Text('一个温柔、可爱的习惯养成应用'),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('版本'),
                    subtitle: Text('3.2.1'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveThemeColor(int index) async {
    ref.read(themeColorIndexProvider.notifier).state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color_index', index);
    if (!mounted) {
      return;
    }
    showAppToast(context, '主题色已更新', type: AppToastType.success);
  }

  Future<void> _saveDarkMode(bool value) async {
    ref.read(isDarkModeProvider.notifier).state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  void _openAchievementPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AchievementPage(),
      ),
    );
  }

  Future<void> _pickReminderTime(TimeOfDay current) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (newTime == null) {
      return;
    }

    ref.read(dailyReminderTimeProvider.notifier).state = newTime;
    try {
      await _saveReminderSettings(true, newTime);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '修改提醒时间失败：$error', type: AppToastType.error);
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.showInstantNotification(
      title: '欣欣星球',
      body: '测试通知已送达，提醒功能工作正常。',
    );
    if (!mounted) {
      return;
    }
    showAppToast(context, '测试通知已发送', type: AppToastType.success);
  }

  Widget _buildHealthReminderTile(HealthReminder reminder) {
    const options = [30, 45, 60, 90, 120, 180];

    return ListTile(
      leading: Text(
        _healthEmoji(reminder.reminderType),
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(_healthLabel(reminder.reminderType)),
      subtitle: Text(
        reminder.isEnabled ? '每 ${reminder.intervalMinutes} 分钟提醒一次' : '已关闭',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<int>(
            tooltip: '修改频率',
            onSelected: (value) => _updateHealthInterval(reminder, value),
            itemBuilder: (context) => options
                .map(
                  (item) => PopupMenuItem<int>(
                    value: item,
                    child: Text('每 $item 分钟'),
                  ),
                )
                .toList(growable: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${reminder.intervalMinutes}分钟',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Switch.adaptive(
            value: reminder.isEnabled,
            onChanged: (value) => _toggleHealthReminder(reminder, value),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHealthReminder(
    HealthReminder reminder,
    bool enabled,
  ) async {
    final updated = reminder.copyWith(isEnabled: enabled);
    await ref.read(healthRemindersProvider.notifier).updateReminder(updated);
    await _syncHealthReminder(updated);
    if (!mounted) {
      return;
    }
    showAppToast(
      context,
      enabled
          ? '${_healthLabel(reminder.reminderType)}已开启'
          : '${_healthLabel(reminder.reminderType)}已关闭',
      type: enabled ? AppToastType.success : AppToastType.info,
    );
  }

  Future<void> _updateHealthInterval(
    HealthReminder reminder,
    int intervalMinutes,
  ) async {
    final updated = reminder.copyWith(intervalMinutes: intervalMinutes);
    await ref.read(healthRemindersProvider.notifier).updateReminder(updated);
    if (updated.isEnabled) {
      await _syncHealthReminder(updated);
    }
    if (!mounted) {
      return;
    }
    showAppToast(
      context,
      '${_healthLabel(reminder.reminderType)}频率已更新',
      type: AppToastType.success,
    );
  }

  Future<void> _syncHealthReminder(HealthReminder reminder) async {
    final id = _healthReminderId(reminder.reminderType);
    if (!reminder.isEnabled) {
      await NotificationService.cancelHealthReminder(id);
      return;
    }

    await NotificationService.scheduleHealthReminder(
      id: id,
      title: _healthTitle(reminder.reminderType),
      body: _healthBody(reminder.reminderType),
      intervalMinutes: reminder.intervalMinutes,
    );
  }

  int _healthReminderId(String type) => type.hashCode & 0x7fffffff;

  String _healthEmoji(String type) {
    switch (type) {
      case 'water':
        return '💧';
      case 'stand':
        return '🧍';
      case 'eye':
        return '👀';
      default:
        return '✅';
    }
  }

  String _healthLabel(String type) {
    switch (type) {
      case 'water':
        return '喝水提醒';
      case 'stand':
        return '久坐提醒';
      case 'eye':
        return '护眼提醒';
      default:
        return '健康提醒';
    }
  }

  String _healthTitle(String type) {
    switch (type) {
      case 'water':
        return '💧 喝水时间到';
      case 'stand':
        return '🧍 起身活动一下';
      case 'eye':
        return '👀 让眼睛休息一会';
      default:
        return '健康提醒';
    }
  }

  String _healthBody(String type) {
    switch (type) {
      case 'water':
        return '补充一点水分，保持状态在线。';
      case 'stand':
        return '久坐会累，走动 3-5 分钟更舒服。';
      case 'eye':
        return '看看远处，给眼睛一点放松时间。';
      default:
        return '照顾好自己，稳稳变好。';
    }
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final file = await BackupService.exportBackup();
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '备份已保存到 ${p.basename(file.path)}',
        type: AppToastType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '导出失败：$error', type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _busy = true);
    try {
      final file = await BackupService.restoreLatestBackup();
      await _reloadData();
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '已从 ${p.basename(file.path)} 恢复数据',
        type: AppToastType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '恢复失败：$error', type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _shareBackup() async {
    setState(() => _busy = true);
    try {
      final file = await BackupService.shareLatestBackup();
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '已分享 ${p.basename(file.path)}',
        type: AppToastType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '分享失败：$error', type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _confirmClearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text('这会删除所有习惯、打卡记录和成长数据，且无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await DatabaseHelper.clearAllData();
      await NotificationService.cancelAllReminders();
      ref.read(themeColorIndexProvider.notifier).state = 0;
      ref.read(isDarkModeProvider.notifier).state = false;
      ref.read(dailyReminderEnabledProvider.notifier).state = false;
      ref.read(dailyReminderTimeProvider.notifier).state =
          const TimeOfDay(hour: 21, minute: 0);
      await _reloadData();
      if (!mounted) {
        return;
      }
      showAppToast(context, '所有本地数据已清空', type: AppToastType.warning);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '清空失败：$error', type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '把应用调成你喜欢的样子',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDarkMode ? '当前为深色模式，夜间使用更舒适。' : '当前为浅色模式，页面更明快。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
