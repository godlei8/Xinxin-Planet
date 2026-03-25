import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/interactive_pet_companion.dart';
import '../../../services/backup_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/providers.dart';
import 'pet_studio_page.dart';

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
    final messenger = ScaffoldMessenger.of(context);
    final formattedTime = time.format(context);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('daily_reminder_enabled', enabled);
    await prefs.setInt('daily_reminder_hour', time.hour);
    await prefs.setInt('daily_reminder_minute', time.minute);

    if (enabled) {
      await NotificationService.scheduleDailyReminder(
        id: 9999,
        title: '每日打卡提醒',
        body: '今天也给自己留一点点坚持的光。',
        hour: time.hour,
        minute: time.minute,
      );
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('已设置每天 $formattedTime 提醒')),
        );
      }
    } else {
      await NotificationService.cancelHabitReminder(9999);
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('已关闭每日提醒')));
      }
    }
  }

  Future<void> _reloadData() async {
    await Future.wait([
      ref.read(habitsProvider.notifier).loadHabits(),
      ref.read(checkRecordsProvider.notifier).loadTodayRecords(),
      ref.read(userProgressProvider.notifier).loadProgress(),
    ]);
    ref.invalidate(categoriesProvider);
    ref.invalidate(achievementsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeColorIndex = ref.watch(themeColorIndexProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final petType = ref.watch(petTypeProvider);
    final dailyReminderEnabled = ref.watch(dailyReminderEnabledProvider);
    final dailyReminderTime = ref.watch(dailyReminderTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ProfileCard(isDarkMode: isDarkMode, petType: petType),
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
                      '挑一个最像今天心情的颜色。',
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
                      subtitle: Text(isDarkMode ? '夜晚也很柔和' : '保持明亮轻盈'),
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
            const _SectionTitle(title: '互动宠物'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openPetStudio,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: PetAvatarPreview(
                            type: petType,
                            size: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '宠物陪伴',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '当前是 ${petType.label}，进入独立页面配置。',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
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
                        final messenger = ScaffoldMessenger.of(context);
                        ref.read(dailyReminderEnabledProvider.notifier).state =
                            value;
                        try {
                          await _saveReminderSettings(value, dailyReminderTime);
                        } catch (error) {
                          if (!mounted) {
                            return;
                          }
                          ref
                              .read(dailyReminderEnabledProvider.notifier)
                              .state = false;
                          messenger.showSnackBar(
                            SnackBar(content: Text('提醒设置失败：$error')),
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
                    subtitle: const Text('检查提醒权限和通知展示是否正常'),
                    onTap: _sendTestNotification,
                  ),
                ],
              ),
            ),
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
                    title: const Text('恢复最近一次备份'),
                    subtitle: const Text('用最近导出的文件恢复当前数据'),
                    onTap: _busy ? null : _restoreBackup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('分享最近一次备份'),
                    subtitle: const Text('把最近一次备份文件发送出去'),
                    onTap: _busy ? null : _shareBackup,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_sweep_rounded,
                      color: AppColors.errorColor,
                    ),
                    title: const Text('清空所有数据'),
                    subtitle: const Text('会清除习惯、记录和成长数据'),
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
                    subtitle: Text('极简可爱的习惯、日历、专注与互动小伙伴'),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('版本'),
                    subtitle: Text('3.1.0'),
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

  void _openPetStudio() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetStudioPage(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('修改提醒时间失败：$error')),
      );
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('测试通知已发送')));
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final file = await BackupService.exportBackup();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份已保存到 ${p.basename(file.path)}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$error')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已从 ${p.basename(file.path)} 恢复数据')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('恢复失败：$error')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已分享 ${p.basename(file.path)}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$error')),
      );
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
        content: const Text('这会删除所有习惯、打卡记录和成长进度，且无法撤销。'),
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
      ref.read(petTypeProvider.notifier).state = PetType.bunny;
      ref.read(dailyReminderEnabledProvider.notifier).state = false;
      ref.read(dailyReminderTimeProvider.notifier).state =
          const TimeOfDay(hour: 21, minute: 0);
      await _reloadData();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('所有本地数据已清空')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清空失败：$error')),
      );
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
    required this.petType,
  });

  final bool isDarkMode;
  final PetType petType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            AppColors.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 102,
            height: 102,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            alignment: Alignment.center,
            child: PetAvatarPreview(
              type: petType,
              size: 64,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '把设置调成你喜欢的样子',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDarkMode ? '当前是深色氛围，夜晚更柔和。' : '当前是浅色氛围，整体更轻盈。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.45,
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
