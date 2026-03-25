import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../../../services/notification_service.dart';
import '../domain/focus_forest_entry.dart';

enum FocusTimerState { idle, running, paused, finished }

class FocusTimerData {
  const FocusTimerData({
    this.state = FocusTimerState.idle,
    this.totalDuration = const Duration(minutes: 25),
    this.remainingDuration = const Duration(minutes: 25),
    this.selectedMinutes = 25,
  });

  final FocusTimerState state;
  final Duration totalDuration;
  final Duration remainingDuration;
  final int selectedMinutes;

  FocusTimerData copyWith({
    FocusTimerState? state,
    Duration? totalDuration,
    Duration? remainingDuration,
    int? selectedMinutes,
  }) {
    return FocusTimerData(
      state: state ?? this.state,
      totalDuration: totalDuration ?? this.totalDuration,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
    );
  }

  double get progress {
    if (totalDuration.inSeconds == 0) {
      return 0;
    }
    return 1 - (remainingDuration.inSeconds / totalDuration.inSeconds);
  }

  String get displayTime {
    final minutes = remainingDuration.inMinutes;
    final seconds = remainingDuration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerData> {
  FocusTimerNotifier({
    required Future<void> Function({
      required int durationSec,
      required bool isAlive,
    }) onSessionPersist,
  })  : _onSessionPersist = onSessionPersist,
        super(const FocusTimerData());

  Timer? _timer;
  final Future<void> Function({
    required int durationSec,
    required bool isAlive,
  }) _onSessionPersist;

  void setDuration(int minutes) {
    if (state.state != FocusTimerState.idle) {
      return;
    }

    final duration = Duration(minutes: minutes);
    state = state.copyWith(
      selectedMinutes: minutes,
      totalDuration: duration,
      remainingDuration: duration,
    );
  }

  void start() {
    if (state.state == FocusTimerState.running) {
      return;
    }

    if (state.state == FocusTimerState.finished) {
      final duration = Duration(minutes: state.selectedMinutes);
      state = state.copyWith(
        totalDuration: duration,
        remainingDuration: duration,
      );
    }

    _timer?.cancel();
    state = state.copyWith(state: FocusTimerState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingDuration - const Duration(seconds: 1);
      if (next.inSeconds <= 0) {
        _timer?.cancel();
        final completedDuration = state.totalDuration.inSeconds;
        state = state.copyWith(
          state: FocusTimerState.finished,
          remainingDuration: Duration.zero,
        );
        unawaited(
          _onSessionPersist(durationSec: completedDuration, isAlive: true),
        );
        unawaited(_notifyComplete());
        return;
      }
      state = state.copyWith(remainingDuration: next);
    });
  }

  void pause() {
    if (state.state != FocusTimerState.running) {
      return;
    }
    _timer?.cancel();
    state = state.copyWith(state: FocusTimerState.paused);
  }

  void resume() {
    if (state.state != FocusTimerState.paused) {
      return;
    }
    start();
  }

  void stop() {
    final wasRunningOrPaused = state.state == FocusTimerState.running ||
        state.state == FocusTimerState.paused;
    final elapsedSec =
        state.totalDuration.inSeconds - state.remainingDuration.inSeconds;

    _timer?.cancel();
    final duration = Duration(minutes: state.selectedMinutes);
    state = FocusTimerData(
      totalDuration: duration,
      remainingDuration: duration,
      selectedMinutes: state.selectedMinutes,
    );

    if (wasRunningOrPaused && elapsedSec > 0) {
      unawaited(_onSessionPersist(durationSec: elapsedSec, isAlive: false));
    }
  }

  void reset() {
    _timer?.cancel();
    state = const FocusTimerData();
  }

  Future<void> _notifyComplete() async {
    await NotificationService.showInstantNotification(
      title: '专注完成',
      body: '这段时间你已经很好地守住了注意力。',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerData>((ref) {
  return FocusTimerNotifier(
    onSessionPersist: ({required durationSec, required isAlive}) async {
      if (!FeatureFlags.enableFocusForest) {
        return;
      }
      await ref.read(focusForestProvider.notifier).addSession(
            durationSec: durationSec,
            isAlive: isAlive,
          );
    },
  );
});

class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final forestAsync = FeatureFlags.enableFocusForest
        ? ref.watch(focusForestProvider)
        : const AsyncValue<List<FocusForestEntry>>.data(
            <FocusForestEntry>[],
          );
    final screenSize = MediaQuery.sizeOf(context);
    final compact = screenSize.height < 760;
    final heroPadding = compact ? 18.0 : 24.0;
    final timerSize =
        (screenSize.width - (compact ? 128 : 108)).clamp(176.0, 260.0);
    final ringSize = (timerSize - 36).clamp(148.0, 220.0);
    final timeFontSize = compact ? 40.0 : 48.0;
    final sectionSpacing = compact ? AppSpacing.md : AppSpacing.lg;
    final cardPadding = compact ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.focusTab),
      ),
      body: SafeArea(
        child: SanrioBackground(
          child: ListView(
            padding:
                EdgeInsets.fromLTRB(16, compact ? 6 : 8, 16, compact ? 16 : 24),
            children: [
              Container(
                padding: EdgeInsets.all(heroPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.95),
                      AppColors.secondaryColor.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: timerSize,
                      height: timerSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: ringSize,
                            height: ringSize,
                            child: CircularProgressIndicator(
                              value: timer.progress,
                              strokeWidth: 12,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _progressColor(timer.state),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timer.displayTime,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: timeFontSize,
                                    ),
                              ),
                              SizedBox(height: compact ? 6 : 10),
                              Text(
                                _stateText(timer.state),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.94),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '给自己一小段安静时间，完成一件最重要的事。',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionSpacing),
              if (FeatureFlags.enableFocusForest) ...[
                _FocusForestPanel(forestAsync: forestAsync),
                SizedBox(height: sectionSpacing),
              ],
              Card(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('专注时长',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        timer.state == FocusTimerState.idle
                            ? '先选一个舒服的长度，再开始这一轮专注。'
                            : '计时开始后，会按当前状态自动切换按钮。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [5, 15, 25, 45, 60].map((minutes) {
                          final isSelected = timer.selectedMinutes == minutes;
                          return ChoiceChip(
                            label: Text('$minutes 分钟'),
                            selected: isSelected,
                            onSelected: timer.state == FocusTimerState.idle
                                ? (_) => notifier.setDuration(minutes)
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sectionSpacing),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildButtons(context, notifier, timer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons(
    BuildContext context,
    FocusTimerNotifier notifier,
    FocusTimerData timer,
  ) {
    switch (timer.state) {
      case FocusTimerState.idle:
        return [
          ElevatedButton.icon(
            onPressed: notifier.start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(AppStrings.startFocus),
          ),
        ];
      case FocusTimerState.running:
        return [
          ElevatedButton.icon(
            onPressed: notifier.pause,
            icon: const Icon(Icons.pause_rounded),
            label: const Text(AppStrings.pauseFocus),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningColor),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: notifier.stop,
            icon: const Icon(Icons.stop_rounded),
            label: const Text(AppStrings.stopFocus),
          ),
        ];
      case FocusTimerState.paused:
        return [
          ElevatedButton.icon(
            onPressed: notifier.resume,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(AppStrings.resumeFocus),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: notifier.stop,
            icon: const Icon(Icons.stop_rounded),
            label: const Text(AppStrings.stopFocus),
          ),
        ];
      case FocusTimerState.finished:
        return [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  AppStrings.focusComplete,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.successColor,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '下一轮也可以慢慢来，不用急。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: notifier.start,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('再来一轮'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: notifier.reset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('恢复默认 25 分钟'),
          ),
        ];
    }
  }

  static Color _progressColor(FocusTimerState state) {
    switch (state) {
      case FocusTimerState.idle:
        return Colors.white;
      case FocusTimerState.running:
        return Colors.white;
      case FocusTimerState.paused:
        return AppColors.accentColor;
      case FocusTimerState.finished:
        return AppColors.successColor;
    }
  }

  static String _stateText(FocusTimerState state) {
    switch (state) {
      case FocusTimerState.idle:
        return '准备开始';
      case FocusTimerState.running:
        return '专注进行中';
      case FocusTimerState.paused:
        return '已暂停';
      case FocusTimerState.finished:
        return '做得很好';
    }
  }
}

class _FocusForestPanel extends StatelessWidget {
  const _FocusForestPanel({
    required this.forestAsync,
  });

  final AsyncValue<List<FocusForestEntry>> forestAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: forestAsync.when(
          data: (entries) {
            final aliveCount = entries.where((item) => item.isAlive).length;
            final totalDurationMin = entries.fold<int>(
              0,
              (sum, item) => sum + (item.durationSec ~/ 60),
            );
            final recent = entries.take(14).toList(growable: false);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '专注森林',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '专注完成会长成树苗，中途退出会留下枯枝。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ForestStatChip(
                      icon: Icons.park_rounded,
                      label: '存活 $aliveCount 棵',
                    ),
                    const SizedBox(width: 8),
                    _ForestStatChip(
                      icon: Icons.schedule_rounded,
                      label: '累计 $totalDurationMin 分钟',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '开始第一轮专注后，这里会出现你的第一棵树。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recent
                        .map((entry) => _ForestTreeChip(entry: entry))
                        .toList(),
                  ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ForestStatChip extends StatelessWidget {
  const _ForestStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ForestTreeChip extends StatelessWidget {
  const _ForestTreeChip({
    required this.entry,
  });

  final FocusForestEntry entry;

  @override
  Widget build(BuildContext context) {
    final isAlive = entry.isAlive;
    final icon = _treeIcon(entry.treeType, entry.treeSize, isAlive);
    final minText = '${(entry.durationSec / 60).ceil()} 分钟';

    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isAlive
            ? const Color(0xFFE8F8EC)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlive ? const Color(0xFFD0F0D9) : const Color(0xFFE4DEE8),
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            minText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  String _treeIcon(String type, String size, bool isAlive) {
    if (!isAlive) {
      return '🥀';
    }

    if (type == 'golden' || size == 'ancient') {
      return '🌲';
    }
    if (type == 'pine' || size == 'tree') {
      return '🌳';
    }
    if (type == 'oak' || size == 'sapling') {
      return '🌿';
    }
    return '🌱';
  }
}
