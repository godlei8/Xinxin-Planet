import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';

class SleepModePage extends ConsumerStatefulWidget {
  const SleepModePage({super.key});

  @override
  ConsumerState<SleepModePage> createState() => _SleepModePageState();
}

class _SleepModePageState extends ConsumerState<SleepModePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  Timer? _timer;
  int _targetMin = 10;
  int _leftSec = 10 * 60;
  bool _running = false;
  bool _loadingHistory = true;
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.88,
      upperBound: 1.08,
    )..repeat(reverse: true);
    _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final rows = await ref.read(sleepModeRepositoryProvider).recentSessions();
    if (!mounted) {
      return;
    }
    setState(() {
      _history = rows;
      _loadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final min = (_leftSec ~/ 60).toString().padLeft(2, '0');
    final sec = (_leftSec % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('呼吸伴睡')),
      body: SafeArea(
        child: SanrioBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _breathController,
                        child: Container(
                          width: 182,
                          height: 182,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _running ? '吸\n呼' : '🌙',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$min:$sec',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _running ? '跟随圆球节奏慢慢呼吸。' : '选择时长后开始伴睡。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '伴睡时长',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [10, 20, 30].map((item) {
                          final selected = item == _targetMin;
                          return ChoiceChip(
                            label: Text('$item 分钟'),
                            selected: selected,
                            onSelected: _running
                                ? null
                                : (_) => setState(() {
                                      _targetMin = item;
                                      _leftSec = item * 60;
                                    }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _running ? _stop : _start,
                          icon: Icon(_running
                              ? Icons.stop_circle_rounded
                              : Icons.nightlight_round),
                          label: Text(_running ? '结束伴睡' : '开始伴睡'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '最近记录',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              if (_loadingHistory)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_history.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('还没有伴睡记录。'),
                  ),
                )
              else
                ..._history.take(10).map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: Text(
                            ((row['completed'] as int? ?? 0) == 1)
                                ? '✅'
                                : '🕯️',
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text('${row['duration_min'] ?? 0} 分钟伴睡'),
                          subtitle: Text(
                            ((row['completed'] as int? ?? 0) == 1)
                                ? '已完成本次伴睡'
                                : '中途结束，也是一种照顾自己',
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  void _start() {
    _timer?.cancel();
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_leftSec <= 0) {
        timer.cancel();
        await _saveSession(completed: true);
        await _loadHistory();
        if (mounted) {
          setState(() => _running = false);
          showAppToast(context, '伴睡完成，晚安。', type: AppToastType.success);
        }
        return;
      }
      if (mounted) {
        setState(() => _leftSec -= 1);
      }
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    await _saveSession(completed: false);
    await _loadHistory();
    if (!mounted) {
      return;
    }
    setState(() {
      _running = false;
      _leftSec = _targetMin * 60;
    });
    showAppToast(context, '已结束本次伴睡', type: AppToastType.info);
  }

  Future<void> _saveSession({required bool completed}) {
    return ref.read(sleepModeRepositoryProvider).addSession(
          durationMin: _targetMin,
          completed: completed,
          moodAfter: 3,
        );
  }
}
