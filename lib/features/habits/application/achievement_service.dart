import '../../home/data/user_progress_repository.dart';
import '../data/achievement_repository.dart';
import '../data/habit_repository.dart';
import '../domain/achievement.dart';

class AchievementProgress {
  const AchievementProgress({
    required this.achievement,
    required this.currentValue,
    required this.targetValue,
  });

  final Achievement achievement;
  final int currentValue;
  final int targetValue;

  double get progressRate {
    if (targetValue <= 0) {
      return 1;
    }
    return (currentValue / targetValue).clamp(0, 1).toDouble();
  }
}

class AchievementService {
  AchievementService({
    required AchievementRepository achievementRepository,
    required UserProgressRepository userProgressRepository,
    required HabitRepository habitRepository,
  })  : _achievementRepository = achievementRepository,
        _userProgressRepository = userProgressRepository,
        _habitRepository = habitRepository;

  final AchievementRepository _achievementRepository;
  final UserProgressRepository _userProgressRepository;
  final HabitRepository _habitRepository;

  Future<List<Achievement>> evaluateAndUnlock() async {
    final all = await _achievementRepository.getAllAchievements();
    final progress = await _userProgressRepository.getUserProgress();
    final habitCount = await _habitRepository.getHabitCount();

    final unlocked = <Achievement>[];
    for (final achievement in all) {
      if (achievement.isUnlocked) {
        continue;
      }
      final current = _resolveCurrentValue(
        achievementId: achievement.id,
        totalCheckIns: progress.totalCheckIns,
        currentStreak: progress.currentStreak,
        bestStreak: progress.bestStreak,
        habitCount: habitCount,
      );
      if (current >= achievement.unlockThreshold) {
        final didUnlock = await _achievementRepository
            .unlockAchievementIfNeeded(achievement.id);
        if (didUnlock) {
          unlocked.add(achievement);
        }
      }
    }

    return unlocked;
  }

  int rewardCoinsForAchievement(String achievementId) {
    switch (achievementId) {
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

  int totalRewardCoins(Iterable<Achievement> achievements) {
    return achievements.fold<int>(
      0,
      (sum, item) => sum + rewardCoinsForAchievement(item.id),
    );
  }

  Future<List<AchievementProgress>> getAchievementProgresses() async {
    final all = await _achievementRepository.getAllAchievements();
    final progress = await _userProgressRepository.getUserProgress();
    final habitCount = await _habitRepository.getHabitCount();

    return all
        .map(
          (achievement) => AchievementProgress(
            achievement: achievement,
            currentValue: _resolveCurrentValue(
              achievementId: achievement.id,
              totalCheckIns: progress.totalCheckIns,
              currentStreak: progress.currentStreak,
              bestStreak: progress.bestStreak,
              habitCount: habitCount,
            ),
            targetValue: achievement.unlockThreshold,
          ),
        )
        .toList();
  }

  int _resolveCurrentValue({
    required String achievementId,
    required int totalCheckIns,
    required int currentStreak,
    required int bestStreak,
    required int habitCount,
  }) {
    switch (achievementId) {
      case 'habit_creator':
        return habitCount;
      case 'week_warrior':
      case 'month_master':
      case 'century_star':
        return bestStreak;
      case 'first_checkin':
      default:
        return totalCheckIns > currentStreak ? totalCheckIns : currentStreak;
    }
  }
}
