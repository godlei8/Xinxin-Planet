import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../../habits/domain/habit.dart';
import '../../habits/presentation/add_edit_habit_page.dart';
import '../../planet/domain/planet_pet.dart';
import '../../planet/presentation/widgets/cute_pet_avatar.dart';
import '../data/daily_quote_service.dart';
import '../domain/habit_suggestion.dart';
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
    final suggestionsAsync = ref.watch(habitSuggestionsProvider);
    final coinsAsync = ref.watch(walletCoinsProvider);
    final petAsync = ref.watch(planetPetProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openHabitEditor(context),
        icon: const Icon(Icons.favorite_rounded),
        label: const Text(AppStrings.addHabit),
      ),
      body: SafeArea(
        child: SanrioBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 124),
            children: [
              progressAsync.when(
                data: (progress) => recordsAsync.when(
                  data: (records) => habitsAsync.when(
                    data: (habits) => _HeroCard(
                      progress: progress,
                      completedCount: records.length,
                      totalCount: habits.length,
                      quoteAsync: quoteAsync,
                      coinsAsync: coinsAsync,
                      petAsync: petAsync,
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
              const SizedBox(height: AppSpacing.xl),
              Text(
                '今日甜甜任务',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '把计划拆成一颗颗小星星，慢慢点亮今天的进度。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (FeatureFlags.enableHabitSuggestions) ...[
                const SizedBox(height: AppSpacing.md),
                _SuggestionPanel(suggestionsAsync: suggestionsAsync),
              ],
              const SizedBox(height: AppSpacing.md),
              habitsAsync.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return _EmptyHabitsCard(
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
          ref.invalidate(habitStreakProvider(habit.id));
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
    required this.quoteAsync,
    required this.coinsAsync,
    required this.petAsync,
  });

  final UserProgress progress;
  final int completedCount;
  final int totalCount;
  final AsyncValue<DailyQuote> quoteAsync;
  final AsyncValue<int> coinsAsync;
  final AsyncValue<PlanetPet> petAsync;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final completionRate = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor =
        isDark ? const Color(0xFFFFEBF6) : const Color(0xFF653A5A);
    final subtitleColor =
        isDark ? const Color(0xFFD8C8D7) : const Color(0xFF8A6680);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF3D2E4B), Color(0xFF2A3E58)]
              : const [Color(0xFFFFE1F0), Color(0xFFE3F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: isDark ? const Color(0x66FFFFFF) : const Color(0xCCFFFFFF),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x66110D15) : const Color(0x33F0B6D6),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -18,
            right: -10,
            child: _ButterflyBadge(
              isDark: isDark,
            ),
          ),
          Positioned(
            right: 18,
            top: 48,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 390;
                  final headline = _HeroHeadline(
                    now: now,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  );

                  final petPeek = _HeroPetPeek(
                    petAsync: petAsync,
                    compact: compact,
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headline,
                        const SizedBox(height: 10),
                        petPeek,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: headline),
                      const SizedBox(width: 10),
                      petPeek,
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              _CoinsBadge(coinsAsync: coinsAsync, titleColor: titleColor),
              const SizedBox(height: AppSpacing.md),
              _QuotePanel(
                quoteAsync: quoteAsync,
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroMetric(
                    label: '已完成',
                    value: '$completedCount/$totalCount',
                    textColor: titleColor,
                    subColor: subtitleColor,
                    isDark: isDark,
                  ),
                  _HeroMetric(
                    label: AppStrings.currentStreak,
                    value: '${progress.currentStreak}${AppStrings.days}',
                    textColor: titleColor,
                    subColor: subtitleColor,
                    isDark: isDark,
                  ),
                  _HeroMetric(
                    label: '星球等级',
                    value: 'Lv.${progress.planetLevel}',
                    textColor: titleColor,
                    subColor: subtitleColor,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProgressPrompt(
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate,
                textColor: titleColor,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinsBadge extends StatelessWidget {
  const _CoinsBadge({
    required this.coinsAsync,
    required this.titleColor,
  });

  final AsyncValue<int> coinsAsync;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD67D),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.monetization_on_rounded,
              size: 14,
              color: Color(0xFF8F5A00),
            ),
          ),
          const SizedBox(width: 6),
          coinsAsync.when(
            data: (coins) => Text(
              '金币 $coins',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            loading: () => Text(
              '金币 ...',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            error: (_, __) => Text(
              '金币 --',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButterflyBadge extends StatelessWidget {
  const _ButterflyBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 26,
      child: CustomPaint(
        painter: _ButterflyPainter(
          wingTop: isDark ? const Color(0xFFFFD2E8) : const Color(0xFFFF92C4),
          wingBottom:
              isDark ? const Color(0xFFC9B8FF) : const Color(0xFF8EB7FF),
          bodyColor: isDark ? const Color(0xFFF8EFFF) : const Color(0xFF7A4F70),
        ),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  const _ButterflyPainter({
    required this.wingTop,
    required this.wingBottom,
    required this.bodyColor,
  });

  final Color wingTop;
  final Color wingBottom;
  final Color bodyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final topWingPaint = Paint()..color = wingTop;
    final bottomWingPaint = Paint()..color = wingBottom;
    final bodyPaint = Paint()..color = bodyColor;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.35,
          size.height * 0.42),
      topWingPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.1, size.width * 0.35,
          size.height * 0.42),
      topWingPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.09, size.height * 0.48, size.width * 0.31,
          size.height * 0.34),
      bottomWingPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.48, size.width * 0.31,
          size.height * 0.34),
      bottomWingPaint,
    );

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.46, size.height * 0.16, size.width * 0.08,
          size.height * 0.6),
      const Radius.circular(999),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    final antenna = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.49, size.height * 0.16),
      Offset(size.width * 0.41, size.height * 0.02),
      antenna,
    );
    canvas.drawLine(
      Offset(size.width * 0.51, size.height * 0.16),
      Offset(size.width * 0.59, size.height * 0.02),
      antenna,
    );
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) {
    return oldDelegate.wingTop != wingTop ||
        oldDelegate.wingBottom != wingBottom ||
        oldDelegate.bodyColor != bodyColor;
  }
}

class _HeroPetPeek extends StatelessWidget {
  const _HeroPetPeek({
    required this.petAsync,
    required this.compact,
  });

  final AsyncValue<PlanetPet> petAsync;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? double.infinity : 200.0;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: petAsync.when(
            data: (pet) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CutePetAvatar(
                  speciesId: pet.species,
                  size: 82,
                  withShadow: false,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${pet.speciesMeta.label} · Lv.${pet.level}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MiniStatChip(
                            icon: Icons.bolt_rounded,
                            value: '${pet.energy}',
                            color: const Color(0xFF3FAF7A),
                          ),
                          const SizedBox(width: 6),
                          _MiniStatChip(
                            icon: Icons.favorite_rounded,
                            value: '${pet.mood}',
                            color: const Color(0xFFE870A3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 98,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox(
              height: 98,
              child: Center(
                child: Icon(Icons.pets_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
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
    required this.titleColor,
    required this.subtitleColor,
  });

  final DateTime now;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${app_date.DateUtils.getWeekdayName(now.weekday)} · ${app_date.DateUtils.formatDateCN(now)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: subtitleColor,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '今天也把计划过得轻一点、稳一点。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: titleColor.withValues(alpha: 0.92),
                height: 1.45,
              ),
        ),
      ],
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，也辛苦啦';
    if (hour < 11) return '早安，准备出发';
    if (hour < 14) return '中午好，继续慢慢来';
    if (hour < 18) return '下午好，今天也在进步';
    return '晚上好，收集一点小成就';
  }
}

class _QuotePanel extends StatelessWidget {
  const _QuotePanel({
    required this.quoteAsync,
    required this.isDark,
    required this.titleColor,
    required this.subtitleColor,
  });

  final AsyncValue<DailyQuote> quoteAsync;
  final bool isDark;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xCCFFFFFF),
        ),
      ),
      child: quoteAsync.when(
        data: (quote) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: titleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '每日一句 · Daily Spark',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quote.english,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              quote.chinese,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: subtitleColor,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuoteMetaChip(
                  label: quote.date.isEmpty ? '今天' : quote.date,
                  icon: Icons.calendar_today_rounded,
                  isDark: isDark,
                  textColor: titleColor,
                ),
                _QuoteMetaChip(
                  label: quote.isFallback ? '离线文案' : quote.source,
                  icon: quote.isFallback
                      ? Icons.offline_bolt_rounded
                      : Icons.public_rounded,
                  isDark: isDark,
                  textColor: titleColor,
                ),
              ],
            ),
          ],
        ),
        loading: () => SizedBox(
          height: 118,
          child: Center(
            child: CircularProgressIndicator(color: titleColor),
          ),
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '每日一句加载失败',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
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
    required this.isDark,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFFFEEF7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 104),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xB3FFFFFF),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
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
    required this.textColor,
    required this.isDark,
  });

  final int totalCount;
  final int completedCount;
  final double completionRate;
  final Color textColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final message = totalCount == 0
        ? '先创建一个小习惯，让今天有一个轻松的开始。'
        : completionRate >= 1
            ? '今天的习惯已经全部完成，状态超棒。'
            : '再完成 ${totalCount - completedCount} 个，今天就会更圆满。';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.09)
            : const Color(0xFFFFF5FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({
    required this.suggestionsAsync,
  });

  final AsyncValue<List<HabitSuggestion>> suggestionsAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: suggestionsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '智能建议',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SuggestionTile(item: item),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.item,
  });

  final HabitSuggestion item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.content,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  const _EmptyHabitsCard({
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF4A3A56), Color(0xFF2F5068)]
                      : const [Color(0xFFFFDFF0), Color(0xFFDDF1FF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text(
                '🌼',
                style: TextStyle(fontSize: 44),
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
              label: const Text('创建第一个习惯'),
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
