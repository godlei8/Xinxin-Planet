import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart';
import '../../habits/domain/check_record.dart';
import '../../habits/domain/habit.dart';
import '../domain/user_progress.dart';

class HomeOverview {
  const HomeOverview({
    required this.progress,
    required this.records,
    required this.habits,
  });

  final UserProgress progress;
  final Map<String, CheckRecord> records;
  final List<Habit> habits;

  int get completedCount => records.length;
  int get totalCount => habits.length;
}

final homeOverviewProvider = Provider<AsyncValue<HomeOverview>>((ref) {
  final progressAsync = ref.watch(userProgressProvider);
  final recordsAsync = ref.watch(checkRecordsProvider);
  final habitsAsync = ref.watch(habitsProvider);

  if (progressAsync.hasError) {
    return AsyncValue.error(progressAsync.error!, progressAsync.stackTrace!);
  }
  if (recordsAsync.hasError) {
    return AsyncValue.error(recordsAsync.error!, recordsAsync.stackTrace!);
  }
  if (habitsAsync.hasError) {
    return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
  }

  final progress = progressAsync.valueOrNull;
  final records = recordsAsync.valueOrNull;
  final habits = habitsAsync.valueOrNull;
  if (progress == null || records == null || habits == null) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    HomeOverview(
      progress: progress,
      records: records,
      habits: habits,
    ),
  );
});
