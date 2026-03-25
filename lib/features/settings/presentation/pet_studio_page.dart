import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/interactive_pet_companion.dart';
import '../../../services/providers.dart';

class PetStudioPage extends ConsumerWidget {
  const PetStudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petType = ref.watch(petTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u5ba0\u7269\u966a\u4f34'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _TopPetInfoCard(type: petType),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\u9009\u62e9\u4f60\u559c\u6b22\u7684\u5c0f\u4f19\u4f34',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\u70b9\u51fb\u5361\u7247\u5373\u53ef\u5207\u6362\uff0c\u9996\u9875\u548c\u8bbe\u7f6e\u9875\u4f1a\u7acb\u523b\u540c\u6b65\u66f4\u65b0\u3002',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 640
                    ? 4
                    : width > 430
                        ? 3
                        : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: PetType.values.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 222,
                  ),
                  itemBuilder: (context, index) {
                    final type = PetType.values[index];
                    return PetSelectorCard(
                      type: type,
                      selected: petType == type,
                      onTap: () => _savePetType(context, ref, type),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePetType(
    BuildContext context,
    WidgetRef ref,
    PetType type,
  ) async {
    if (!context.mounted) {
      return;
    }

    final current = ref.read(petTypeProvider);
    if (current == type) {
      showAppToast(
        context,
        '\u5df2\u7ecf\u662f ${type.label}',
        type: AppToastType.info,
      );
      return;
    }

    ref.read(petTypeProvider.notifier).state = type;
    showAppToast(
      context,
      '\u5df2\u5207\u6362\u4e3a ${type.label}',
      type: AppToastType.success,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_type', type.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ref.read(petTypeProvider.notifier).state = current;
      showAppToast(
        context,
        '\u5207\u6362\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5',
        type: AppToastType.error,
      );
    }
  }
}

class _TopPetInfoCard extends StatelessWidget {
  const _TopPetInfoCard({
    required this.type,
  });

  final PetType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 370;

          final preview = Container(
            width: compact ? 98 : 112,
            height: compact ? 98 : 112,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: PetAvatarPreview(
              type: type,
              size: compact ? 60 : 70,
            ),
          );

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '\u5f53\u524d\u966a\u4f34',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                type.hint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.96),
                      height: 1.4,
                    ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  preview,
                  const SizedBox(width: 14),
                  Expanded(child: textBlock),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '\u5728\u4e0b\u65b9\u9009\u62e9\u5361\u7247\uff0c\u53ef\u4ee5\u7acb\u5373\u5207\u6362\u5ba0\u7269',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.94),
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
