import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/interactive_pet_companion.dart';
import '../core/utils/date_utils.dart' as app_date;
import '../core/utils/streak_calculator.dart';
import '../features/habits/data/achievement_repository.dart';
import '../features/habits/data/category_repository.dart';
import '../features/habits/data/check_record_repository.dart';
import '../features/habits/data/habit_repository.dart';
import '../features/habits/domain/achievement.dart';
import '../features/habits/domain/category.dart';
import '../features/habits/domain/check_record.dart';
import '../features/habits/domain/habit.dart';
import '../features/home/data/daily_quote_service.dart';
import '../features/home/data/user_progress_repository.dart';
import '../features/home/domain/user_progress.dart';

final themeColorIndexProvider = StateProvider<int>((ref) => 0);
final isDarkModeProvider = StateProvider<bool>((ref) => false);
final petTypeProvider = StateProvider<PetType>((ref) => PetType.bunny);

final habitRepositoryProvider = Provider((ref) => HabitRepository());
final checkRecordRepositoryProvider =
    Provider((ref) => CheckRecordRepository());
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());
final achievementRepositoryProvider =
    Provider((ref) => AchievementRepository());
final userProgressRepositoryProvider =
    Provider((ref) => UserProgressRepository());
final dailyQuoteServiceProvider = Provider((ref) => DailyQuoteService());

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
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAllAchievements();
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
