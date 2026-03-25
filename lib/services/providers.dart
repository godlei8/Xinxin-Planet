import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/feature_flags.dart';
import '../core/utils/date_utils.dart' as app_date;
import '../core/utils/streak_calculator.dart';
import '../features/habits/application/achievement_service.dart';
import '../features/habits/data/achievement_repository.dart';
import '../features/habits/data/category_repository.dart';
import '../features/habits/data/check_record_repository.dart';
import '../features/habits/data/habit_repository.dart';
import '../features/habits/domain/achievement.dart';
import '../features/habits/domain/category.dart';
import '../features/habits/domain/check_record.dart';
import '../features/habits/domain/habit.dart';
import '../features/focus/data/focus_forest_repository.dart';
import '../features/focus/domain/focus_forest_entry.dart';
import '../features/home/application/habit_suggestion_service.dart';
import '../features/home/data/daily_quote_service.dart';
import '../features/home/data/user_progress_repository.dart';
import '../features/home/domain/habit_suggestion.dart';
import '../features/home/domain/user_progress.dart';
import '../features/settings/data/health_reminder_repository.dart';
import '../features/settings/domain/health_reminder.dart';

final themeColorIndexProvider = StateProvider<int>((ref) => 0);
final isDarkModeProvider = StateProvider<bool>((ref) => false);

final habitRepositoryProvider = Provider((ref) => HabitRepository());
final checkRecordRepositoryProvider =
    Provider((ref) => CheckRecordRepository());
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());
final achievementRepositoryProvider =
    Provider((ref) => AchievementRepository());
final userProgressRepositoryProvider =
    Provider((ref) => UserProgressRepository());
final dailyQuoteServiceProvider = Provider((ref) => DailyQuoteService());
final focusForestRepositoryProvider =
    Provider((ref) => FocusForestRepository());
final healthReminderRepositoryProvider =
    Provider((ref) => HealthReminderRepository());
final achievementServiceProvider = Provider((ref) => AchievementService(
      achievementRepository: ref.watch(achievementRepositoryProvider),
      userProgressRepository: ref.watch(userProgressRepositoryProvider),
      habitRepository: ref.watch(habitRepositoryProvider),
    ));
final habitSuggestionServiceProvider = Provider(
  (ref) => HabitSuggestionService(
    habitRepository: ref.watch(habitRepositoryProvider),
    checkRecordRepository: ref.watch(checkRecordRepositoryProvider),
  ),
);

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitsNotifier(ref.watch(habitRepositoryProvider));
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final HabitRepository _repository;

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _repository.getAllHabits();
      state = AsyncValue.data(habits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addHabit(Habit habit) async {
    await _repository.insertHabit(habit);
    await loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _repository.updateHabit(habit);
    await loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
    await loadHabits();
  }
}

final checkRecordsProvider = StateNotifierProvider<CheckRecordsNotifier,
    AsyncValue<Map<String, CheckRecord>>>((ref) {
  return CheckRecordsNotifier(ref.watch(checkRecordRepositoryProvider));
});

class CheckRecordsNotifier
    extends StateNotifier<AsyncValue<Map<String, CheckRecord>>> {
  CheckRecordsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTodayRecords();
  }

  final CheckRecordRepository _repository;

  Future<void> loadTodayRecords() async {
    state = const AsyncValue.loading();
    try {
      final records = await _repository
          .getRecordsByDate(app_date.DateUtils.getTodayString());
      final map = <String, CheckRecord>{};
      for (final record in records) {
        map[record.habitId] = record;
      }
      state = AsyncValue.data(map);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> checkIn(CheckRecord record) async {
    final inserted = await _repository.insertRecord(record);
    await loadTodayRecords();
    return inserted;
  }

  Future<bool> hasCheckedIn(String habitId) async {
    return _repository.hasCheckedIn(
        habitId, app_date.DateUtils.getTodayString());
  }
}

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getAllCategories();
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  if (FeatureFlags.enableAchievementSystem) {
    await ref.watch(achievementServiceProvider).evaluateAndUnlock();
  }
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAllAchievements();
});

final achievementProgressProvider =
    FutureProvider<List<AchievementProgress>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  if (FeatureFlags.enableAchievementSystem) {
    await service.evaluateAndUnlock();
  }
  return service.getAchievementProgresses();
});

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, AsyncValue<UserProgress>>(
        (ref) {
  return UserProgressNotifier(
    ref.watch(userProgressRepositoryProvider),
    ref.watch(checkRecordRepositoryProvider),
  );
});

class UserProgressNotifier extends StateNotifier<AsyncValue<UserProgress>> {
  UserProgressNotifier(this._repository, this._checkRecordRepository)
      : super(const AsyncValue.loading()) {
    loadProgress();
  }

  final UserProgressRepository _repository;
  final CheckRecordRepository _checkRecordRepository;

  Future<void> loadProgress() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _repository.getUserProgress();
      state = AsyncValue.data(progress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> recordCheckIn(String habitId) async {
    final checkedDates =
        await _checkRecordRepository.getCheckedDatesForHabit(habitId);
    final currentStreak = StreakCalculator.calculateCurrentStreak(checkedDates);
    final bestStreak = StreakCalculator.calculateBestStreak(checkedDates);
    await _repository.updateStreak(
      currentStreak,
      bestStreak,
      app_date.DateUtils.getTodayString(),
    );
    await _repository.incrementCheckIns();
    await loadProgress();
  }
}

final habitStreakProvider =
    FutureProvider.family<int, String>((ref, habitId) async {
  final repository = ref.watch(checkRecordRepositoryProvider);
  final checkedDates = await repository.getCheckedDatesForHabit(habitId);
  return StreakCalculator.calculateCurrentStreak(checkedDates);
});

final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  final service = ref.watch(dailyQuoteServiceProvider);
  return service.fetchTodayQuote();
});

final habitSuggestionsProvider = FutureProvider<List<HabitSuggestion>>((ref) {
  final service = ref.watch(habitSuggestionServiceProvider);
  return service.buildSuggestions();
});

final focusForestProvider = StateNotifierProvider<FocusForestNotifier,
    AsyncValue<List<FocusForestEntry>>>((ref) {
  return FocusForestNotifier(ref.watch(focusForestRepositoryProvider));
});

class FocusForestNotifier
    extends StateNotifier<AsyncValue<List<FocusForestEntry>>> {
  FocusForestNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  final FocusForestRepository _repository;

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repository.getRecentEntries(limit: 24);
      state = AsyncValue.data(entries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSession({
    required int durationSec,
    required bool isAlive,
  }) async {
    await _repository.addSession(durationSec: durationSec, isAlive: isAlive);
    await loadEntries();
  }
}

final healthRemindersProvider = StateNotifierProvider<HealthRemindersNotifier,
    AsyncValue<List<HealthReminder>>>((ref) {
  return HealthRemindersNotifier(ref.watch(healthReminderRepositoryProvider));
});

class HealthRemindersNotifier
    extends StateNotifier<AsyncValue<List<HealthReminder>>> {
  HealthRemindersNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadReminders();
  }

  final HealthReminderRepository _repository;

  Future<void> loadReminders() async {
    state = const AsyncValue.loading();
    try {
      final reminders = await _repository.getAllReminders();
      state = AsyncValue.data(reminders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReminder(HealthReminder reminder) async {
    await _repository.updateReminder(reminder);
    await loadReminders();
  }
}
