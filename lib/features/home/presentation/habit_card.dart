import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../services/providers.dart';
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

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitColor.withValues(alpha: 0.92),
                      habitColor.withValues(alpha: 0.68),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    habit.iconCode,
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
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniTag(
                          icon: '🔥',
                          label: '$currentStreak 天连胜',
                          color: Colors.orange,
                        ),
                        _MiniTag(
                          icon: habit.reminderEnabled ? '⏰' : '🌼',
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isCheckedIn ? AppColors.successColor : habitColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: (isCheckedIn ? AppColors.successColor : habitColor)
                  .withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCheckedIn ? Icons.check_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              isCheckedIn ? '已完成' : AppStrings.checkIn,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
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
  int _selectedMood = 2;
  int _focusMinutes = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = AppColors.fromHex(widget.habit.colorCode);
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                    child: Text(widget.habit.iconCode,
                        style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: Theme.of(context).textTheme.titleLarge,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(AppStrings.moodEmojis.length, (index) {
              final isSelected = _selectedMood == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 60,
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
                      Text(AppStrings.moodEmojis[index],
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.moodLabels[index],
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? habitColor
                                      : AppColors.textSecondary,
                                ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('专注时长（分钟）', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              OutlinedButton(
                onPressed: _focusMinutes > 0
                    ? () => setState(() => _focusMinutes -= 5)
                    : null,
                child: const Icon(Icons.remove_rounded),
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
              OutlinedButton(
                onPressed: () => setState(() => _focusMinutes += 5),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
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
    );

    try {
      final inserted =
          await ref.read(checkRecordsProvider.notifier).checkIn(record);
      if (!inserted) {
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.checkInAgain)));
        return;
      }

      await ref
          .read(userProgressProvider.notifier)
          .recordCheckIn(widget.habit.id);

      if (!mounted) {
        return;
      }
      navigator.pop();
      widget.onCheckInComplete();
      messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.checkInSuccess)));
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
}
