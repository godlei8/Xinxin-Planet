import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../services/providers.dart';
import '../../habits/domain/achievement.dart';
import '../../habits/domain/check_record.dart';
import '../../habits/domain/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onTap,
    required this.currentStreak,
  });

  final Habit habit;
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onTap;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final habitColor = AppColors.fromHex(habit.colorCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : habitColor.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        habitColor.withValues(alpha: 0.92),
                        habitColor.withValues(alpha: 0.66),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      habit.iconCode,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(isCheckedIn: isCheckedIn),
                        ],
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.35),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniTag(
                            icon: '🔥',
                            label: '$currentStreak 天连胜',
                            color: const Color(0xFFFFA54C),
                          ),
                          _MiniTag(
                            icon: habit.reminderEnabled ? '⏰' : '🎈',
                            label: habit.reminderEnabled
                                ? (habit.reminderTime ?? '已提醒')
                                : '随时完成',
                            color: habitColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _CheckButton(
                  habitColor: habitColor,
                  isCheckedIn: isCheckedIn,
                  onTap: isCheckedIn ? null : onCheckIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCheckedIn});

  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    final bg = isCheckedIn ? const Color(0xFFE4FAEF) : const Color(0xFFFFF0F8);
    final fg = isCheckedIn ? const Color(0xFF2A8D64) : const Color(0xFFAF4B80);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isCheckedIn ? '今日已完成' : '待打卡',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.habitColor,
    required this.isCheckedIn,
    required this.onTap,
  });

  final Color habitColor;
  final bool isCheckedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final buttonColor = isCheckedIn ? AppColors.successColor : habitColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCheckedIn ? Icons.check_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(height: 2),
              Text(
                isCheckedIn ? '完成' : AppStrings.checkIn,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckInBottomSheet extends ConsumerStatefulWidget {
  const CheckInBottomSheet({
    super.key,
    required this.habit,
    required this.onCheckInComplete,
  });

  final Habit habit;
  final VoidCallback onCheckInComplete;

  @override
  ConsumerState<CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends ConsumerState<CheckInBottomSheet> {
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();
  int _selectedMood = 2;
  int _focusMinutes = 0;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = AppColors.fromHex(widget.habit.colorCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3142) : const Color(0xFFFFDDF0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        habitColor.withValues(alpha: 0.9),
                        habitColor.withValues(alpha: 0.64),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      widget.habit.iconCode,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app_date.DateUtils.formatDateCN(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('现在的心情', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(AppStrings.moodEmojis.length, (index) {
                  final isSelected = _selectedMood == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == AppStrings.moodEmojis.length - 1 ? 0 : 8,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMood = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 64,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? habitColor.withValues(alpha: 0.14)
                              : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? habitColor : Colors.transparent,
                            width: 1.6,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.moodEmojis[index],
                              style: const TextStyle(fontSize: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.moodLabels[index],
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? habitColor
                                        : AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('专注时长（分钟）', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _CircleIconButton(
                  icon: Icons.remove_rounded,
                  onTap: _focusMinutes > 0
                      ? () => setState(() => _focusMinutes -= 5)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _focusMinutes == 0 ? '没有关联专注时长' : '$_focusMinutes 分钟',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: habitColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _CircleIconButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _focusMinutes += 5),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('拍照打卡', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isSaving ? null : () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: const Text('拍照'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('相册'),
                  ),
                ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('随手记一句', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '比如：今天状态不错，完成得比想象中轻松。',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _performCheckIn,
                style: ElevatedButton.styleFrom(backgroundColor: habitColor),
                child: Text(_isSaving ? '打卡中...' : '确认打卡'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performCheckIn() async {
    if (_isSaving) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);

    final record = CheckRecord(
      id: const Uuid().v4(),
      habitId: widget.habit.id,
      checkDate: app_date.DateUtils.getTodayString(),
      checkTime: DateTime.now().millisecondsSinceEpoch,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      mood: _selectedMood + 1,
      focusMinutes: _focusMinutes,
      imagePath: _imagePath,
    );

    try {
      final inserted =
          await ref.read(checkRecordsProvider.notifier).checkIn(record);
      if (!inserted) {
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.checkInAgain)),
        );
        return;
      }

      await ref
          .read(userProgressProvider.notifier)
          .recordCheckIn(widget.habit.id);
      await ref.read(gachaRepositoryProvider).addCoins(3);

      var unlocked = <Achievement>[];
      var achievementBonus = 0;
      if (FeatureFlags.enableAchievementSystem) {
        final achievementService = ref.read(achievementServiceProvider);
        unlocked = await achievementService.evaluateAndUnlock();
        achievementBonus = achievementService.totalRewardCoins(unlocked);
        ref.invalidate(achievementsProvider);
        ref.invalidate(achievementProgressProvider);
      }
      if (achievementBonus > 0) {
        await ref.read(gachaRepositoryProvider).addCoins(achievementBonus);
      }
      ref.invalidate(walletCoinsProvider);

      if (!mounted) {
        return;
      }
      navigator.pop();
      widget.onCheckInComplete();
      final totalCoinGain = 3 + achievementBonus;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            unlocked.isEmpty
                ? '${AppStrings.checkInSuccess}，+$totalCoinGain 金币'
                : '${AppStrings.checkInSuccess}，+$totalCoinGain 金币，解锁成就：${unlocked.first.name}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('打卡失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 82,
      );
      if (file == null || !mounted) {
        return;
      }
      setState(() => _imagePath = file.path);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取图片失败：$error')),
      );
    }
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: enabled ? const Color(0xFFFFECF7) : const Color(0xFFF3EEF5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? const Color(0xFFAA4A80) : const Color(0xFFBDB7C7),
          ),
        ),
      ),
    );
  }
}
