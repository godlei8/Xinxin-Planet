import 'dart:async';

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
import '../features/planet/data/gacha_repository.dart';
import '../features/planet/data/planet_pet_repository.dart';
import '../features/planet/data/sleep_mode_repository.dart';
import '../features/planet/data/supervision_repository.dart';
import '../features/planet/domain/planet_pet.dart';
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
final gachaRepositoryProvider = Provider((ref) => GachaRepository());
final planetPetRepositoryProvider = Provider((ref) => PlanetPetRepository());
final supervisionRepositoryProvider =
    Provider((ref) => SupervisionRepository());
final sleepModeRepositoryProvider = Provider((ref) => SleepModeRepository());
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
  // Recompute streak right after today's check-in state changes.
  ref.watch(checkRecordsProvider);
  final repository = ref.watch(checkRecordRepositoryProvider);
  final checkedDates = await repository.getCheckedDatesForHabit(habitId);
  return StreakCalculator.calculateCurrentStreak(checkedDates);
});

final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  final service = ref.watch(dailyQuoteServiceProvider);
  return service.fetchTodayQuote();
});

final walletCoinsProvider = FutureProvider<int>((ref) async {
  if (!FeatureFlags.enableGachaSystem) {
    return 0;
  }
  final repository = ref.watch(gachaRepositoryProvider);
  return repository.getCoins();
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

class PlanetPetActionResult {
  const PlanetPetActionResult({
    required this.pet,
    required this.message,
    this.leveledUp = false,
    this.blockedByLimit = false,
    this.interactionsLeft = 0,
    this.interactionLimit = 0,
  });

  final PlanetPet pet;
  final String message;
  final bool leveledUp;
  final bool blockedByLimit;
  final int interactionsLeft;
  final int interactionLimit;
}

const _basePetInteractionLimit = 5;

final planetPetProvider =
    StateNotifierProvider<PlanetPetNotifier, AsyncValue<PlanetPet>>((ref) {
  return PlanetPetNotifier(
    ref.watch(planetPetRepositoryProvider),
    ref.watch(checkRecordRepositoryProvider),
  );
});

final petInteractionLimitProvider = FutureProvider<int>((ref) async {
  // Refresh limit instantly when today's check-in list changes.
  ref.watch(checkRecordsProvider);
  final repository = ref.watch(checkRecordRepositoryProvider);
  final records =
      await repository.getRecordsByDate(app_date.DateUtils.getTodayString());
  return _basePetInteractionLimit + records.length;
});

class PlanetPetNotifier extends StateNotifier<AsyncValue<PlanetPet>> {
  PlanetPetNotifier(this._repository, this._checkRecordRepository)
      : super(const AsyncValue.loading()) {
    loadPet();
  }

  final PlanetPetRepository _repository;
  final CheckRecordRepository _checkRecordRepository;

  Future<void> loadPet() async {
    state = const AsyncValue.loading();
    try {
      final pet = await _repository.getPet();
      state = AsyncValue.data(pet);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> renamePet(String name) async {
    final current = state.valueOrNull ?? await _repository.getPet();
    final updated = current.copyWith(
      name: name.trim(),
      lastInteractionAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.savePet(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> changeSpecies(String species) async {
    final current = state.valueOrNull ?? await _repository.getPet();
    final resolvedSpecies = PlanetPetSpecies.byId(species).id;
    if (current.species == resolvedSpecies) {
      return;
    }
    final updated = current.copyWith(
      species: resolvedSpecies,
      lastInteractionAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = AsyncValue.data(updated);
    unawaited(_repository.savePet(updated));
  }

  Future<PlanetPetActionResult> feedPet() async {
    return _applyAction(
      energyDelta: 20,
      moodDelta: 6,
      expGain: 14,
      message: '喂食成功，宠物吃得很开心。',
      markFed: true,
    );
  }

  Future<PlanetPetActionResult> playWithPet() async {
    final current = state.valueOrNull ?? await _repository.getPet();
    if (current.energy < 15) {
      final today = app_date.DateUtils.getTodayString();
      final interactionLimit = await _resolveInteractionLimit(today);
      final interactionsLeft = _computeInteractionsLeft(
        pet: current,
        date: today,
        interactionLimit: interactionLimit,
      );
      return PlanetPetActionResult(
        pet: current,
        message: '宠物体力不足，先让它休息一下吧。',
        interactionsLeft: interactionsLeft,
        interactionLimit: interactionLimit,
      );
    }
    return _applyAction(
      energyDelta: -16,
      moodDelta: 18,
      expGain: 18,
      message: '玩耍完成，宠物心情明显变好了。',
      markPlay: true,
    );
  }

  Future<PlanetPetActionResult> petPet() async {
    return _applyAction(
      energyDelta: -3,
      moodDelta: 10,
      expGain: 8,
      message: '摸摸头成功，宠物黏人值上升。',
    );
  }

  Future<PlanetPetActionResult> restPet() async {
    return _applyAction(
      energyDelta: 28,
      moodDelta: 4,
      expGain: 10,
      message: '休息完成，宠物状态恢复了不少。',
      markRest: true,
    );
  }

  Future<PlanetPetActionResult> _applyAction({
    required int energyDelta,
    required int moodDelta,
    required int expGain,
    required String message,
    bool markFed = false,
    bool markPlay = false,
    bool markRest = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final today = app_date.DateUtils.getTodayString();
    final interactionLimit = await _resolveInteractionLimit(today);
    var current = state.valueOrNull ?? await _repository.getPet();
    if (current.dailyInteractionDate != today) {
      current = current.copyWith(
        dailyInteractionDate: today,
        dailyInteractionUsed: 0,
      );
    }

    final usedToday = current.usedInteractionsOn(today);
    if (usedToday >= interactionLimit) {
      return PlanetPetActionResult(
        pet: current,
        message:
            '今日互动次数已用完（$interactionLimit/$interactionLimit），先去完成习惯打卡补充次数吧。',
        blockedByLimit: true,
        interactionsLeft: 0,
        interactionLimit: interactionLimit,
      );
    }

    var level = current.level;
    var exp = current.exp + expGain;
    var leveledUp = false;
    var threshold = _expThreshold(level);
    while (exp >= threshold) {
      exp -= threshold;
      level += 1;
      leveledUp = true;
      threshold = _expThreshold(level);
    }

    final updated = current.copyWith(
      level: level,
      exp: exp,
      energy: (current.energy + energyDelta).clamp(0, 100).toInt(),
      mood: (current.mood + moodDelta).clamp(0, 100).toInt(),
      lastInteractionAt: now,
      dailyInteractionDate: today,
      dailyInteractionUsed: usedToday + 1,
      lastFedAt: markFed ? now : current.lastFedAt,
      lastPlayAt: markPlay ? now : current.lastPlayAt,
      lastRestAt: markRest ? now : current.lastRestAt,
    );

    await _repository.savePet(updated);
    state = AsyncValue.data(updated);
    final interactionsLeft =
        (interactionLimit - updated.usedInteractionsOn(today)).clamp(0, 99999);
    final finalMessage = leveledUp
        ? '$message 已升级到 Lv.$level！'
        : '$message（剩余互动 $interactionsLeft 次）';
    return PlanetPetActionResult(
      pet: updated,
      message: finalMessage,
      leveledUp: leveledUp,
      interactionsLeft: interactionsLeft,
      interactionLimit: interactionLimit,
    );
  }

  int _computeInteractionsLeft({
    required PlanetPet pet,
    required String date,
    required int interactionLimit,
  }) {
    final used = pet.usedInteractionsOn(date);
    return (interactionLimit - used).clamp(0, 99999);
  }

  Future<int> _resolveInteractionLimit(String date) async {
    final records = await _checkRecordRepository.getRecordsByDate(date);
    return _basePetInteractionLimit + records.length;
  }

  int _expThreshold(int level) => 40 + ((level - 1) * 15);
}
