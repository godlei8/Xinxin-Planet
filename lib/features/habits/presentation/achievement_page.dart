import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../application/achievement_service.dart';

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProgressProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就系统'),
      ),
      body: SafeArea(
        child: SanrioBackground(
          child: achievementsAsync.when(
            data: (achievements) {
              final unlockedCount = achievements
                  .where((item) => item.achievement.isUnlocked)
                  .length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _AchievementSummaryCard(
                    unlockedCount: unlockedCount,
                    totalCount: achievements.length,
                    progressText: progressAsync.when(
                      data: (progress) =>
                          '总打卡 ${progress.totalCheckIns} 次 · 最佳连续 ${progress.bestStreak} 天',
                      loading: () => '正在读取进度...',
                      error: (_, __) => '进度读取失败',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...achievements.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AchievementTile(item: item),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('成就加载失败：$error'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementSummaryCard extends StatelessWidget {
  const _AchievementSummaryCard({
    required this.unlockedCount,
    required this.totalCount,
    required this.progressText,
  });

  final int unlockedCount;
  final int totalCount;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已解锁 $unlockedCount / $totalCount',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            progressText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.item,
  });

  final AchievementProgress item;

  @override
  Widget build(BuildContext context) {
    final achievement = item.achievement;
    final scheme = Theme.of(context).colorScheme;
    final completed = achievement.isUnlocked;
    final safeCurrent = item.currentValue.clamp(0, item.targetValue);
    final progressText =
        completed ? '已解锁' : '${safeCurrent.toInt()} / ${item.targetValue}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: completed
                        ? scheme.primary.withValues(alpha: 0.16)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    achievement.iconCode.isEmpty ? '🏆' : achievement.iconCode,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.description ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: completed
                        ? scheme.primary.withValues(alpha: 0.16)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    progressText,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: completed ? scheme.primary : scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: completed ? 1 : item.progressRate,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed ? scheme.primary : scheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
