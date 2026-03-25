import '../../../core/utils/date_utils.dart' as app_date;
import '../../habits/data/check_record_repository.dart';
import '../../habits/data/habit_repository.dart';
import '../../habits/domain/check_record.dart';
import '../domain/habit_suggestion.dart';

class HabitSuggestionService {
  HabitSuggestionService({
    required HabitRepository habitRepository,
    required CheckRecordRepository checkRecordRepository,
  })  : _habitRepository = habitRepository,
        _checkRecordRepository = checkRecordRepository;

  final HabitRepository _habitRepository;
  final CheckRecordRepository _checkRecordRepository;

  Future<List<HabitSuggestion>> buildSuggestions() async {
    final habits = await _habitRepository.getAllHabits();
    final records = await _checkRecordRepository.getAllRecords();

    if (habits.isEmpty) {
      return const [
        HabitSuggestion(
          id: 'start-first-habit',
          title: '从一个习惯开始',
          content: '先创建 1 个最轻松的小习惯，今天就能完成第一步。',
          priority: 1,
        ),
      ];
    }

    final suggestions = <HabitSuggestion>[];
    final recent7Days = _recentRecords(records, 7);

    if (recent7Days.length <= 2) {
      suggestions.add(
        const HabitSuggestion(
          id: 'low-activity',
          title: '降低一点门槛',
          content: '最近 7 天打卡偏少，建议把目标拆小，优先保证连续完成。',
          priority: 1,
        ),
      );
    }

    final morningRatio = _morningRatio(records);
    if (morningRatio >= 0.55) {
      suggestions.add(
        const HabitSuggestion(
          id: 'morning-advantage',
          title: '保留早晨优势',
          content: '你在上午完成的比例更高，可以把最重要的习惯安排在早上。',
          priority: 2,
        ),
      );
    }

    final checkedToday = records.any(
      (item) => item.checkDate == app_date.DateUtils.getTodayString(),
    );
    if (!checkedToday) {
      suggestions.add(
        const HabitSuggestion(
          id: 'today-first-checkin',
          title: '先完成今天第一条',
          content: '先打卡一条最简单的任务，状态就会被快速拉起来。',
          priority: 1,
        ),
      );
    }

    if (records.length >= 20) {
      suggestions.add(
        const HabitSuggestion(
          id: 'add-habit',
          title: '可以尝试新挑战',
          content: '你已经稳定记录了一段时间，可以尝试添加一个新习惯。',
          priority: 3,
        ),
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        const HabitSuggestion(
          id: 'keep-going',
          title: '继续保持',
          content: '你的节奏很稳，今天继续按这个方式前进就很好。',
          priority: 3,
        ),
      );
    }

    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return suggestions.take(3).toList(growable: false);
  }

  List<CheckRecord> _recentRecords(List<CheckRecord> records, int days) {
    final threshold = DateTime.now().subtract(Duration(days: days - 1));
    return records.where((record) {
      final time = DateTime.fromMillisecondsSinceEpoch(record.checkTime);
      return time.isAfter(threshold);
    }).toList();
  }

  double _morningRatio(List<CheckRecord> records) {
    if (records.isEmpty) {
      return 0;
    }
    final morningCount = records.where((record) {
      final time = DateTime.fromMillisecondsSinceEpoch(record.checkTime);
      return time.hour < 12;
    }).length;
    return morningCount / records.length;
  }
}
