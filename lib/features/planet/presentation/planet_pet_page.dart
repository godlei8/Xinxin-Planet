import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../domain/planet_pet.dart';
import 'widgets/pet_model_view.dart';

class PlanetPetPage extends ConsumerStatefulWidget {
  const PlanetPetPage({super.key});

  @override
  ConsumerState<PlanetPetPage> createState() => _PlanetPetPageState();
}

class _PlanetPetPageState extends ConsumerState<PlanetPetPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(planetPetProvider);
    final interactionLimitAsync = ref.watch(petInteractionLimitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('星球宠物')),
      body: SafeArea(
        child: SanrioBackground(
          child: petAsync.when(
            data: (pet) {
              final today = app_date.DateUtils.getTodayString();
              final interactionLimit = interactionLimitAsync.maybeWhen(
                data: (value) => value,
                orElse: () => 5,
              );
              final interactionUsed = pet.usedInteractionsOn(today);
              final interactionLeft =
                  (interactionLimit - interactionUsed).clamp(0, 99999);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _PetHeroCard(
                    pet: pet,
                    onRename: _renamePet,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SpeciesSelector(
                    currentSpecies: pet.species,
                    onSelect: _changeSpecies,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StatusCard(
                    pet: pet,
                    interactionLeft: interactionLeft,
                    interactionLimit: interactionLimit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ActionPanel(
                    busy: _busy,
                    interactionLeft: interactionLeft,
                    interactionLimit: interactionLimit,
                    onFeed: () =>
                        _runPetAction((notifier) => notifier.feedPet()),
                    onPlay: () =>
                        _runPetAction((notifier) => notifier.playWithPet()),
                    onPet: () => _runPetAction((notifier) => notifier.petPet()),
                    onRest: () =>
                        _runPetAction((notifier) => notifier.restPet()),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('宠物加载失败：$error'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runPetAction(
    Future<PlanetPetActionResult> Function(PlanetPetNotifier notifier) action,
  ) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final notifier = ref.read(planetPetProvider.notifier);
      final result = await action(notifier);
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        result.message,
        type: result.blockedByLimit
            ? AppToastType.warning
            : result.leveledUp
                ? AppToastType.success
                : AppToastType.info,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '互动失败：$error', type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _renamePet(PlanetPet pet) async {
    final controller = TextEditingController(text: pet.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('给宠物改个名字'),
        content: TextField(
          controller: controller,
          maxLength: 12,
          decoration: const InputDecoration(hintText: '输入新名字'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) {
      return;
    }

    await ref.read(planetPetProvider.notifier).renamePet(newName);
    if (!mounted) {
      return;
    }
    showAppToast(context, '宠物名字已更新', type: AppToastType.success);
  }

  Future<void> _changeSpecies(String species) async {
    final currentSpecies = ref.read(planetPetProvider).valueOrNull?.species;
    if (currentSpecies == species) {
      return;
    }
    ref.read(planetPetProvider.notifier).changeSpecies(species);
    if (!mounted) {
      return;
    }
    showAppToast(
      context,
      '宠物外观切换中，马上就好',
      type: AppToastType.success,
      duration: const Duration(milliseconds: 900),
    );
  }
}

class _PetHeroCard extends StatelessWidget {
  const _PetHeroCard({
    required this.pet,
    required this.onRename,
  });

  final PlanetPet pet;
  final ValueChanged<PlanetPet> onRename;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expRate = pet.nextLevelExp <= 0 ? 0.0 : pet.exp / pet.nextLevelExp;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final model = _AnimatedPetPreview(
            modelAsset: pet.speciesMeta.modelAsset,
            alt: pet.speciesMeta.label,
            size: compact ? 130 : 150,
          );

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pet.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        shadows: const [
                          Shadow(
                            color: Color(0x4D000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRename(pet),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    tooltip: '改名',
                  ),
                ],
              ),
              Text(
                '${pet.speciesMeta.label} · Lv.${pet.level}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                pet.speciesMeta.story,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: expRate.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '经验 ${pet.exp} / ${pet.nextLevelExp}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                model,
                const SizedBox(height: AppSpacing.sm),
                info,
              ],
            );
          }

          return Row(
            children: [
              model,
              const SizedBox(width: AppSpacing.md),
              Expanded(child: info),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedPetPreview extends StatefulWidget {
  const _AnimatedPetPreview({
    required this.modelAsset,
    required this.alt,
    required this.size,
  });

  final String modelAsset;
  final String alt;
  final double size;

  @override
  State<_AnimatedPetPreview> createState() => _AnimatedPetPreviewState();
}

class _AnimatedPetPreviewState extends State<_AnimatedPetPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = math.sin(_controller.value * math.pi * 2) * 4;
          return Transform.translate(
            offset: Offset(0, offset),
            child: child,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
          ),
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: PetModelView(
                modelAsset: widget.modelAsset,
                alt: widget.alt,
                cameraControls: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesSelector extends StatelessWidget {
  const _SpeciesSelector({
    required this.currentSpecies,
    required this.onSelect,
  });

  final String currentSpecies;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3D 宠物外观库（5 种）',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PlanetPetSpecies.values.map((species) {
                final selected = currentSpecies == species.id;
                return ChoiceChip(
                  label: Text(species.label),
                  selected: selected,
                  onSelected: (_) => onSelect(species.id),
                );
              }).toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.pet,
    required this.interactionLeft,
    required this.interactionLimit,
  });

  final PlanetPet pet;
  final int interactionLeft;
  final int interactionLimit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '宠物状态',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: '活力',
              value: pet.energy,
              color: const Color(0xFF4DBD8B),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: '心情',
              value: pet.mood,
              color: const Color(0xFFF08AB3),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '今日互动次数：$interactionLeft / $interactionLimit',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _petHint(pet),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _petHint(PlanetPet pet) {
    if (pet.energy < 25) {
      return '宠物有点疲惫，先休息再互动会更好。';
    }
    if (pet.mood < 35) {
      return '宠物情绪偏低，试试玩耍或摸摸头提升心情。';
    }
    return '完成一个习惯打卡可额外增加 1 次当日互动次数。';
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value'),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.busy,
    required this.interactionLeft,
    required this.interactionLimit,
    required this.onFeed,
    required this.onPlay,
    required this.onPet,
    required this.onRest,
  });

  final bool busy;
  final int interactionLeft;
  final int interactionLimit;
  final VoidCallback onFeed;
  final VoidCallback onPlay;
  final VoidCallback onPet;
  final VoidCallback onRest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '互动操作',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '今日可互动 $interactionLimit 次，完成习惯打卡可继续增加。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PetActionButton(
                  icon: Icons.restaurant_rounded,
                  label: '喂食',
                  onTap: busy || interactionLeft <= 0 ? null : onFeed,
                ),
                _PetActionButton(
                  icon: Icons.sports_esports_rounded,
                  label: '玩耍',
                  onTap: busy || interactionLeft <= 0 ? null : onPlay,
                ),
                _PetActionButton(
                  icon: Icons.favorite_rounded,
                  label: '摸摸头',
                  onTap: busy || interactionLeft <= 0 ? null : onPet,
                ),
                _PetActionButton(
                  icon: Icons.bedtime_rounded,
                  label: '休息',
                  onTap: busy || interactionLeft <= 0 ? null : onRest,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PetActionButton extends StatelessWidget {
  const _PetActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
