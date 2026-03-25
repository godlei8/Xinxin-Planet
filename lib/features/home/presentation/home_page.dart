import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/interactive_pet_companion.dart';
import '../../../services/providers.dart';
import '../../habits/domain/habit.dart';
import '../../habits/presentation/add_edit_habit_page.dart';
import '../data/daily_quote_service.dart';
import '../domain/user_progress.dart';
import 'habit_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final recordsAsync = ref.watch(checkRecordsProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final quoteAsync = ref.watch(dailyQuoteProvider);
    final petType = ref.watch(petTypeProvider);

    Future<void> refreshAll() async {
      await Future.wait([
        ref.read(habitsProvider.notifier).loadHabits(),
        ref.read(checkRecordsProvider.notifier).loadTodayRecords(),
        ref.read(userProgressProvider.notifier).loadProgress(),
      ]);
      final _ = await ref.refresh(dailyQuoteProvider.future);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openHabitEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addHabit),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              progressAsync.when(
                data: (progress) => recordsAsync.when(
                  data: (records) => habitsAsync.when(
                    data: (habits) => _HeroCard(
                      progress: progress,
                      completedCount: records.length,
                      totalCount: habits.length,
                      petType: petType,
                      quoteAsync: quoteAsync,
                      onRefreshQuote: () async {
                        final _ = await ref.refresh(dailyQuoteProvider.future);
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Data load failed: $error'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '\u4eca\u5929\u7684\u5c0f\u4e60\u60ef',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '\u628a\u4eca\u5929\u62c6\u6210\u51e0\u4e2a\u8f7b\u677e\u7684\u5c0f\u52a8\u4f5c\uff0c\u5b8c\u6210\u8d77\u6765\u4f1a\u66f4\u8212\u670d\u3002',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              habitsAsync.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return _EmptyHabitsCard(
                      petType: petType,
                      onAddPressed: () => _openHabitEditor(context),
                    );
                  }

                  return recordsAsync.when(
                    data: (recordsMap) => Column(
                      children: habits.map((habit) {
                        final isCheckedIn = recordsMap.containsKey(habit.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _HabitCardWithStreak(
                            habit: habit,
                            isCheckedIn: isCheckedIn,
                            onCheckIn: () =>
                                _showCheckInSheet(context, ref, habit),
                            onTap: () =>
                                _openHabitEditor(context, habit: habit),
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Records load failed: $error'),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text('Habits load failed: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckInSheet(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckInBottomSheet(
        habit: habit,
        onCheckInComplete: () async {
          await Future.wait([
            ref.read(checkRecordsProvider.notifier).loadTodayRecords(),
            ref.read(userProgressProvider.notifier).loadProgress(),
          ]);
        },
      ),
    );
  }

  void _openHabitEditor(BuildContext context, {Habit? habit}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditHabitPage(habit: habit),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.petType,
    required this.quoteAsync,
    required this.onRefreshQuote,
  });

  final UserProgress progress;
  final int completedCount;
  final int totalCount;
  final PetType petType;
  final AsyncValue<DailyQuote> quoteAsync;
  final Future<void> Function() onRefreshQuote;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final completionRate = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -26,
            right: -18,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _HeroHeadline(now: now)),
                  const SizedBox(width: 12),
                  _HeroPetAccent(type: petType),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _QuotePanel(
                quoteAsync: quoteAsync,
                onRefreshQuote: onRefreshQuote,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroMetric(
                    label: '\u5df2\u5b8c\u6210',
                    value: '$completedCount/$totalCount',
                  ),
                  _HeroMetric(
                    label: AppStrings.currentStreak,
                    value: '${progress.currentStreak}${AppStrings.days}',
                  ),
                  _HeroMetric(
                    label: '\u661f\u7403\u7b49\u7ea7',
                    value: 'Lv.${progress.planetLevel}',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProgressPrompt(
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPetAccent extends StatelessWidget {
  const _HeroPetAccent({
    required this.type,
  });

  final PetType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          InteractivePetCompanion(
            type: type,
            size: 52,
          ),
          const SizedBox(height: 2),
          Text(
            type.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline({
    required this.now,
  });

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${app_date.DateUtils.getWeekdayName(now.weekday)} · ${app_date.DateUtils.formatDateCN(now)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '\u4eca\u5929\u4e5f\u548c\u5c0f\u4f19\u4f34\u4e00\u8d77\uff0c\u628a\u8ba1\u5212\u8fc7\u5f97\u8f7b\u4e00\u70b9\u3001\u7a33\u4e00\u70b9\u3002',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                height: 1.45,
              ),
        ),
      ],
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '\u591c\u6df1\u4e86\uff0c\u4e5f\u8f9b\u82e6\u5566';
    if (hour < 11) return '\u65e9\u5b89\uff0c\u51c6\u5907\u51fa\u53d1';
    if (hour < 14) {
      return '\u4e2d\u5348\u597d\uff0c\u7ee7\u7eed\u6162\u6162\u6765';
    }
    if (hour < 18) {
      return '\u4e0b\u5348\u597d\uff0c\u4eca\u5929\u4e5f\u5728\u8fdb\u6b65';
    }
    return '\u665a\u4e0a\u597d\uff0c\u6536\u96c6\u4e00\u70b9\u5c0f\u6210\u5c31';
  }
}

class _QuotePanel extends StatefulWidget {
  const _QuotePanel({
    required this.quoteAsync,
    required this.onRefreshQuote,
  });

  final AsyncValue<DailyQuote> quoteAsync;
  final Future<void> Function() onRefreshQuote;

  @override
  State<_QuotePanel> createState() => _QuotePanelState();
}

class _QuotePanelState extends State<_QuotePanel> {
  bool _isRefreshing = false;
  DateTime? _lastRefreshAt;
  double _refreshTurns = 0;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _refreshTurns += 1;
    });
    showAppToast(
      context,
      '\u6b63\u5728\u5237\u65b0\u6bcf\u65e5\u4e00\u53e5...',
      type: AppToastType.info,
      duration: const Duration(milliseconds: 900),
    );

    try {
      await widget.onRefreshQuote();
      if (!mounted) {
        return;
      }
      _lastRefreshAt = DateTime.now();
      showAppToast(
        context,
        '\u6bcf\u65e5\u4e00\u53e5\u5df2\u5237\u65b0',
        type: AppToastType.success,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '\u5237\u65b0\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: widget.quoteAsync.when(
        data: (quote) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '\u6bcf\u65e5\u4e00\u53e5 · Daily Spark',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (_lastRefreshAt != null && !_isRefreshing)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '\u521a\u521a\u66f4\u65b0',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                IconButton(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  tooltip: '\u5237\u65b0\u6bcf\u65e5\u4e00\u53e5',
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : AnimatedRotation(
                          turns: _refreshTurns,
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.easeOutCubic,
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 430;

                final textSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.english,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quote.chinese,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.94),
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuoteMetaChip(
                          label:
                              quote.date.isEmpty ? '\u4eca\u5929' : quote.date,
                          icon: Icons.calendar_today_rounded,
                        ),
                        _QuoteMetaChip(
                          label: quote.isFallback
                              ? '\u79bb\u7ebf\u5907\u7528\u6587\u6848'
                              : quote.source,
                          icon: quote.isFallback
                              ? Icons.offline_bolt_rounded
                              : Icons.public_rounded,
                        ),
                      ],
                    ),
                  ],
                );

                final image = ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: vertical ? double.infinity : 84,
                    height: vertical ? 132 : 104,
                    child: quote.imageUrl.isEmpty
                        ? _QuoteImageFallback(vertical: vertical)
                        : Image.network(
                            quote.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _QuoteImageFallback(vertical: vertical),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return _QuoteImageFallback(vertical: vertical);
                            },
                          ),
                  ),
                );

                if (vertical) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      image,
                      const SizedBox(height: 14),
                      textSection,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: textSection),
                    const SizedBox(width: 12),
                    image,
                  ],
                );
              },
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 138,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u6bcf\u65e5\u4e00\u53e5\u52a0\u8f7d\u5931\u8d25',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteMetaChip extends StatelessWidget {
  const _QuoteMetaChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuoteImageFallback extends StatelessWidget {
  const _QuoteImageFallback({
    required this.vertical,
  });

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          vertical ? Icons.auto_stories_rounded : Icons.menu_book_rounded,
          color: Colors.white.withValues(alpha: 0.82),
          size: vertical ? 36 : 30,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 104),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPrompt extends StatelessWidget {
  const _ProgressPrompt({
    required this.totalCount,
    required this.completedCount,
    required this.completionRate,
  });

  final int totalCount;
  final int completedCount;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final message = totalCount == 0
        ? '\u5148\u521b\u5efa\u4e00\u4e2a\u5c0f\u4e60\u60ef\uff0c\u8ba9\u4eca\u5929\u6709\u4e00\u4e2a\u8f7b\u677e\u7684\u5f00\u59cb\u3002'
        : completionRate >= 1
            ? '\u4eca\u5929\u7684\u4e60\u60ef\u5df2\u7ecf\u5168\u90e8\u5b8c\u6210\uff0c\u72b6\u6001\u8d85\u68d2\u3002'
            : '\u518d\u5b8c\u6210 ${totalCount - completedCount} \u4e2a\uff0c\u4eca\u5929\u5c31\u4f1a\u66f4\u5706\u6ee1\u3002';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  const _EmptyHabitsCard({
    required this.petType,
    required this.onAddPressed,
  });

  final PetType petType;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 132,
              child: PetCompanionCard(
                type: petType,
                size: 80,
                title: petType.label,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.emptyHabits,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.emptyHabitsHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('\u521b\u5efa\u7b2c\u4e00\u4e2a\u4e60\u60ef'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCardWithStreak extends ConsumerWidget {
  const _HabitCardWithStreak({
    required this.habit,
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onTap,
  });

  final Habit habit;
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(habitStreakProvider(habit.id));

    return streakAsync.when(
      data: (streak) => HabitCard(
        habit: habit,
        isCheckedIn: isCheckedIn,
        onCheckIn: onCheckIn,
        onTap: onTap,
        currentStreak: streak,
      ),
      loading: () => HabitCard(
        habit: habit,
        isCheckedIn: isCheckedIn,
        onCheckIn: onCheckIn,
        onTap: onTap,
        currentStreak: 0,
      ),
      error: (_, __) => HabitCard(
        habit: habit,
        isCheckedIn: isCheckedIn,
        onCheckIn: onCheckIn,
        onTap: onTap,
        currentStreak: 0,
      ),
    );
  }
}
