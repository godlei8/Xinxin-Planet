import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/utils/streak_calculator.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../../habits/domain/check_record.dart';
import '../../habits/domain/habit.dart';

final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final calendarFormatProvider =
    StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  static const Map<String, String> _holidayLabels = {
    '01-01': '\u5143\u65e6\u8282',
    '02-14': '\u60c5\u4eba\u8282',
    '03-08': '\u5987\u5973\u8282',
    '05-01': '\u52b3\u52a8\u8282',
    '05-04': '\u9752\u5e74\u8282',
    '06-01': '\u513f\u7ae5\u8282',
    '07-01': '\u5efa\u515a\u8282',
    '08-01': '\u5efa\u519b\u8282',
    '09-10': '\u6559\u5e08\u8282',
    '10-01': '\u56fd\u5e86\u8282',
    '12-25': '\u5723\u8bde\u8282',
  };

  Map<String, List<CheckRecord>> _recordsByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repository = ref.read(checkRecordRepositoryProvider);
    try {
      final records = await repository.getAllRecords();
      final map = <String, List<CheckRecord>>{};
      for (final record in records) {
        map.putIfAbsent(record.checkDate, () => []).add(record);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _recordsByDate = map;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);
    final records =
        _recordsByDate[selectedDayKey(selectedDay)] ?? const <CheckRecord>[];
    final allDates = _recordsByDate.keys.toList();
    final totalCheckIns =
        _recordsByDate.values.fold<int>(0, (sum, items) => sum + items.length);
    final currentStreak = StreakCalculator.calculateCurrentStreak(allDates);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.calendarTab),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadData();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SanrioBackground(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StatsRow(
                  currentStreak: currentStreak,
                  totalCheckIns: totalCheckIns,
                  activeDays: _recordsByDate.length,
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TableCalendar<CheckRecord>(
                      firstDay: DateTime(2024, 1, 1),
                      lastDay: DateTime(2030, 12, 31),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, selectedDay),
                      calendarFormat: calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.month: '\u6708',
                        CalendarFormat.twoWeeks: '\u4e24\u5468',
                        CalendarFormat.week: '\u5468',
                      },
                      eventLoader: (day) =>
                          _recordsByDate[selectedDayKey(day)] ?? const [],
                      onFormatChanged: (format) {
                        ref.read(calendarFormatProvider.notifier).state =
                            format;
                      },
                      onDaySelected: (selected, focused) {
                        if (!app_date.DateUtils.isValidDate(
                            selected.year, selected.month, selected.day)) {
                          return;
                        }
                        if (!isSameDay(selected, selectedDay)) {
                          ref.read(selectedDayProvider.notifier).state =
                              selected;
                        }
                        ref.read(focusedDayProvider.notifier).state = focused;
                      },
                      onPageChanged: (focused) {
                        ref.read(focusedDayProvider.notifier).state = focused;
                      },
                      daysOfWeekHeight: 34,
                      rowHeight: 62,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonDecoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        formatButtonTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left_rounded),
                        rightChevronIcon:
                            const Icon(Icons.chevron_right_rounded),
                        titleTextStyle:
                            Theme.of(context).textTheme.titleMedium!,
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        defaultTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                        outsideTextStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        todayTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        defaultDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.successColor,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                      ),
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, day, focusedDay) =>
                            _buildDayCell(
                          context,
                          day,
                          selected: true,
                          today: false,
                          outside: false,
                        ),
                        todayBuilder: (context, day, focusedDay) =>
                            _buildDayCell(
                          context,
                          day,
                          selected: false,
                          today: true,
                          outside: false,
                        ),
                        defaultBuilder: (context, day, focusedDay) =>
                            _buildDayCell(
                          context,
                          day,
                          selected: false,
                          today: false,
                          outside: false,
                        ),
                        outsideBuilder: (context, day, focusedDay) =>
                            _buildDayCell(
                          context,
                          day,
                          selected: false,
                          today: false,
                          outside: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SelectedDayHeader(
                  selectedDay: selectedDay,
                  count: records.length,
                ),
                const SizedBox(height: AppSpacing.sm),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _SelectedDayRecords(
                        records: records,
                        habitsAsync: ref.watch(habitsProvider),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    required bool selected,
    required bool today,
    required bool outside,
  }) {
    final hasRecords = _recordsByDate[selectedDayKey(day)]?.isNotEmpty ?? false;
    final holiday = _holidayLabels[_holidayKey(day)];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fallbackTextColor =
        theme.textTheme.bodyMedium?.color ?? scheme.onSurface;
    final dayTextColor = selected
        ? Colors.white
        : outside
            ? fallbackTextColor.withValues(alpha: 0.45)
            : hasRecords
                ? scheme.primary
                : today
                    ? scheme.primary
                    : fallbackTextColor;
    final holidayColor =
        selected ? Colors.white.withValues(alpha: 0.95) : scheme.secondary;
    final background = selected
        ? scheme.primary.withValues(alpha: 0.9)
        : today
            ? scheme.primary.withValues(alpha: 0.14)
            : hasRecords
                ? scheme.primary.withValues(alpha: 0.1)
                : holiday != null
                    ? scheme.secondary.withValues(alpha: 0.1)
                    : Colors.transparent;
    final borderColor = selected
        ? scheme.primary
        : hasRecords
            ? scheme.primary.withValues(alpha: 0.35)
            : holiday != null
                ? scheme.secondary.withValues(alpha: 0.3)
                : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: dayTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (holiday != null) ...[
            const SizedBox(height: 1),
            Text(
              holiday,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: holidayColor,
                fontWeight: FontWeight.w800,
                fontSize: 9,
              ),
            ),
          ] else
            const SizedBox(height: 11),
          if (hasRecords)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: selected ? Colors.white : AppColors.successColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _holidayKey(DateTime day) =>
      '${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  String selectedDayKey(DateTime day) => app_date.DateUtils.formatDate(day);
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.currentStreak,
    required this.totalCheckIns,
    required this.activeDays,
  });

  final int currentStreak;
  final int totalCheckIns;
  final int activeDays;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.local_fire_department_rounded,
        label: '\u8fde\u80dc',
        value: '$currentStreak \u5929',
        color: Colors.orange,
      ),
      _StatCard(
        icon: Icons.check_circle_rounded,
        label: '\u603b\u6253\u5361',
        value: '$totalCheckIns \u6b21',
        color: AppColors.successColor,
      ),
      _StatCard(
        icon: Icons.calendar_month_rounded,
        label: '\u6d3b\u8dc3\u65e5',
        value: '$activeDays \u5929',
        color: AppColors.primaryColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        if (compact) {
          final itemWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: cards
                .map((card) => SizedBox(width: itemWidth, child: card))
                .toList(),
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cards[1]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 106,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.selectedDay,
    required this.count,
  });

  final DateTime selectedDay;
  final int count;

  @override
  Widget build(BuildContext context) {
    final title = app_date.DateUtils.isToday(selectedDay)
        ? '\u4eca\u5929'
        : app_date.DateUtils.formatDateCN(selectedDay);

    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (count > 0)
          Text(
            '\u5171 $count \u6761\u8bb0\u5f55',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _SelectedDayRecords extends StatelessWidget {
  const _SelectedDayRecords({
    required this.records,
    required this.habitsAsync,
  });

  final List<CheckRecord> records;
  final AsyncValue<List<Habit>> habitsAsync;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.event_note_rounded, size: 40),
              const SizedBox(height: 10),
              Text(
                AppStrings.emptyRecords,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.emptyRecordsHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        final habit = habitsAsync.whenOrNull(
          data: (habits) =>
              habits.where((item) => item.id == record.habitId).firstOrNull,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _RecordCard(record: record, habit: habit),
        );
      }).toList(),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.habit,
  });

  final CheckRecord record;
  final Habit? habit;

  @override
  Widget build(BuildContext context) {
    final habitColor = habit == null
        ? AppColors.primaryColor
        : AppColors.fromHex(habit!.colorCode);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(record.checkTime);
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      habit?.iconCode ?? '\uD83D\uDCDD',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit?.name ?? '\u672a\u77e5\u4e60\u60ef',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\u6253\u5361\u65f6\u95f4 $time',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (record.focusMinutes > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${record.focusMinutes} \u5206\u949f',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
              ],
            ),
            if (record.note?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  record.note!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            if (record.mood != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    AppStrings.moodEmojis[(record.mood! - 1)
                        .clamp(0, AppStrings.moodEmojis.length - 1)],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.moodLabels[(record.mood! - 1)
                        .clamp(0, AppStrings.moodLabels.length - 1)],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (record.imagePath != null && record.imagePath!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(record.imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 88,
                    alignment: Alignment.center,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    child: const Text('图片加载失败'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
