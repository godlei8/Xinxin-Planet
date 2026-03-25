import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/notification_service.dart';
import '../../../services/providers.dart';
import '../domain/category.dart';
import '../domain/habit.dart';

class AddEditHabitPage extends ConsumerStatefulWidget {
  const AddEditHabitPage({super.key, this.habit});

  final Habit? habit;

  @override
  ConsumerState<AddEditHabitPage> createState() => _AddEditHabitPageState();
}

class _AddEditHabitPageState extends ConsumerState<AddEditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategoryId = 'default';
  String _selectedColorCode = AppColors.themeColorCodes.first;
  String _selectedIconCode = AppStrings.habitIcons.first;
  int _selectedFrequency = 0;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  bool _isSaving = false;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit == null) {
      return;
    }

    _nameController.text = habit.name;
    _descriptionController.text = habit.description;
    _selectedCategoryId = habit.categoryId;
    _selectedColorCode = habit.colorCode;
    _selectedIconCode = habit.iconCode;
    _selectedFrequency = habit.frequency;
    _reminderEnabled = habit.reminderEnabled;
    if (habit.reminderTime != null) {
      final parts = habit.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedColor = AppColors.fromHex(_selectedColorCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editHabit : AppStrings.addHabit),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: SanrioBackground(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SectionCard(
                  title: '给这颗小星球起个名字',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: AppStrings.habitName,
                          hintText: '比如：喝水、背单词、早睡 15 分钟',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入习惯名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: AppStrings.habitDescription,
                          hintText: '留一句温柔提醒，会更容易坚持。',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: '外观',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.selectIcon,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: AppStrings.habitIcons.map((icon) {
                          final isSelected = icon == _selectedIconCode;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIconCode = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: 0.18)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : Colors.transparent,
                                  width: 1.8,
                                ),
                              ),
                              child: Center(
                                  child: Text(icon,
                                      style: const TextStyle(fontSize: 24))),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(AppStrings.selectColor,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: AppColors.themeColorCodes.map((colorCode) {
                          final color = AppColors.fromHex(colorCode);
                          final isSelected = colorCode == _selectedColorCode;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColorCode = colorCode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 40,
                              height: 40,
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
                                        alpha: isSelected ? 0.45 : 0.18),
                                    blurRadius: isSelected ? 14 : 8,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: '分类与重复',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoriesAsync.when(
                        data: _buildCategorySelector,
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => Text('分类加载失败：$error'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(AppStrings.selectFrequency,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _FrequencyChip(
                            label: AppStrings.frequencyDaily,
                            selected: _selectedFrequency == 0,
                            onTap: () => setState(() => _selectedFrequency = 0),
                          ),
                          _FrequencyChip(
                            label: AppStrings.frequencyWeekdays,
                            selected: _selectedFrequency == 1,
                            onTap: () => setState(() => _selectedFrequency = 1),
                          ),
                          _FrequencyChip(
                            label: AppStrings.frequencyWeekends,
                            selected: _selectedFrequency == 2,
                            onTap: () => setState(() => _selectedFrequency = 2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: '提醒',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.enableReminder,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _reminderEnabled
                                      ? '会在固定时间轻轻提醒你'
                                      : '不开启也没关系，先把习惯种下来',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _reminderEnabled,
                            onChanged: (value) =>
                                setState(() => _reminderEnabled = value),
                          ),
                        ],
                      ),
                      if (_reminderEnabled) ...[
                        const SizedBox(height: AppSpacing.md),
                        InkWell(
                          onTap: _pickReminderTime,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.alarm_rounded, color: selectedColor),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    _reminderTime == null
                                        ? '选择提醒时间'
                                        : '每天 ${_reminderTime!.format(context)} 提醒',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: selectedColor,
                                        ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveHabit,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: selectedColor),
                  child: Text(_isSaving
                      ? '保存中...'
                      : (_isEditing ? AppStrings.save : AppStrings.addHabit)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.selectCategory,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((category) {
            final isSelected = category.id == _selectedCategoryId;
            final categoryColor = AppColors.fromHex(category.colorCode);
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? categoryColor.withValues(alpha: 0.16)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? categoryColor : Colors.transparent,
                    width: 1.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.iconCode),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? categoryColor : null,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _saveHabit() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }
    if (_reminderEnabled && _reminderTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开启提醒后，请先选择提醒时间。')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
      colorCode: _selectedColorCode,
      iconCode: _selectedIconCode,
      frequency: _selectedFrequency,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderTime == null
          ? null
          : '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
      createdAt:
          widget.habit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      isArchived: widget.habit?.isArchived ?? false,
    );

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        await ref.read(habitsProvider.notifier).updateHabit(habit);
      } else {
        await ref.read(habitsProvider.notifier).addHabit(habit);
        if (FeatureFlags.enableAchievementSystem) {
          await ref.read(achievementServiceProvider).evaluateAndUnlock();
          ref.invalidate(achievementsProvider);
          ref.invalidate(achievementProgressProvider);
        }
      }

      final reminderId = NotificationService.reminderIdForHabit(habit.id);
      await NotificationService.cancelHabitReminder(reminderId);
      if (habit.reminderEnabled && habit.reminderTime != null) {
        await NotificationService.scheduleHabitReminder(
          id: reminderId,
          habitName: habit.name,
          time: habit.reminderTime!,
          habitId: habit.id,
        );
      }

      if (!mounted) {
        return;
      }
      navigator.pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('保存失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final habit = widget.habit;
    if (habit == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteHabit),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await NotificationService.cancelHabitReminder(
        NotificationService.reminderIdForHabit(habit.id),
      );
      await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
      if (!mounted) {
        return;
      }
      navigator.pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('删除失败：$error')));
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
        ),
      ),
    );
  }
}
