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
              final ordered = [...achievements]..sort((a, b) {
                  final aUnlocked = a.achievement.isUnlocked;
                  final bUnlocked = b.achievement.isUnlocked;
                  if (aUnlocked != bUnlocked) {
                    return aUnlocked ? 1 : -1;
                  }
                  return b.currentValue.compareTo(a.currentValue);
                });

              final unlockedCount =
                  ordered.where((item) => item.achievement.isUnlocked).length;
              AchievementProgress? nextTarget;
              for (final item in ordered) {
                if (!item.achievement.isUnlocked) {
                  nextTarget = item;
                  break;
                }
              }

              final nextTargetText = ordered.isEmpty
                  ? '还没有成就数据'
                  : nextTarget == null
                      ? '全部成就已解锁，太棒了！'
                      : '下一个目标：${nextTarget.achievement.name}';

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _AchievementSummaryCard(
                    unlockedCount: unlockedCount,
                    totalCount: ordered.length,
                    progressText: progressAsync.when(
                      data: (progress) =>
                          '总打卡 ${progress.totalCheckIns} 次 · 最佳连胜 ${progress.bestStreak} 天',
                      loading: () => '正在读取你的成长进度...',
                      error: (_, __) => '进度读取失败',
                    ),
                    nextTarget: nextTargetText,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...ordered.map(
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
    required this.nextTarget,
  });

  final int unlockedCount;
  final int totalCount;
  final String progressText;
  final String nextTarget;

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
          const SizedBox(height: 6),
          Text(
            nextTarget,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
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
    final rewardCoins = _rewardCoins(achievement.id);

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
                  child: Icon(
                    _achievementIcon(achievement.id),
                    size: 24,
                    color: completed ? scheme.primary : scheme.onSurfaceVariant,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.monetization_on_rounded,
                  label: '奖励 +$rewardCoins 金币',
                  color: scheme.secondary,
                ),
                if (completed && achievement.unlockedAt != null)
                  _MetaChip(
                    icon: Icons.verified_rounded,
                    label: '解锁于 ${_dateLabel(achievement.unlockedAt!)}',
                    color: scheme.primary,
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

  static IconData _achievementIcon(String id) {
    switch (id) {
      case 'first_checkin':
        return Icons.flag_rounded;
      case 'week_warrior':
        return Icons.local_fire_department_rounded;
      case 'month_master':
        return Icons.workspace_premium_rounded;
      case 'century_star':
        return Icons.auto_awesome_rounded;
      case 'habit_creator':
        return Icons.design_services_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  static int _rewardCoins(String id) {
    switch (id) {
      case 'first_checkin':
        return 10;
      case 'week_warrior':
        return 20;
      case 'month_master':
        return 60;
      case 'century_star':
        return 180;
      case 'habit_creator':
        return 30;
      default:
        return 10;
    }
  }

  static String _dateLabel(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
