import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';

class WidgetStudioPage extends ConsumerWidget {
  const WidgetStudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final recordsAsync = ref.watch(checkRecordsProvider);

    final totalHabits = habitsAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );
    final checkedCount = recordsAsync.maybeWhen(
      data: (map) => map.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('桌面小组件中心')),
      body: SafeArea(
        child: SanrioBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                '组件预览',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              _WidgetPreviewCard(
                title: '今日打卡卡片',
                subtitle: '已完成 $checkedCount / $totalHabits',
                icon: '📊',
                toneColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const _WidgetPreviewCard(
                title: '快速专注',
                subtitle: '一键开始 25 分钟专注',
                icon: '⏱️',
              ),
              const SizedBox(height: 8),
              const _WidgetPreviewCard(
                title: '成长徽章',
                subtitle: '展示当前连续天数和等级',
                icon: '🏆',
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '添加指引',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. 长按手机桌面空白处'),
                      const Text('2. 点击“小组件”'),
                      const Text('3. 搜索“馨馨星球”并选择样式'),
                      const Text('4. 拖到桌面并完成添加'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  showAppToast(context, '组件偏好已保存', type: AppToastType.success);
                },
                icon: const Icon(Icons.widgets_rounded),
                label: const Text('保存组件偏好'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.toneColor,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color? toneColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (toneColor ?? Theme.of(context).colorScheme.secondary)
                .withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
