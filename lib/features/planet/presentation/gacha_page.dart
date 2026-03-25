import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../domain/gacha_item.dart';

class GachaPage extends ConsumerStatefulWidget {
  const GachaPage({super.key});

  @override
  ConsumerState<GachaPage> createState() => _GachaPageState();
}

class _GachaPageState extends ConsumerState<GachaPage> {
  int _coins = 0;
  List<Map<String, dynamic>> _inventory = const [];
  bool _loading = true;
  bool _drawing = false;
  GachaItem? _lastDraw;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(gachaRepositoryProvider);
    final coins = await repo.getCoins();
    final inventory = await repo.getInventory();
    if (!mounted) {
      return;
    }
    setState(() {
      _coins = coins;
      _inventory = inventory;
      _loading = false;
    });
    ref.invalidate(walletCoinsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自律盲盒')),
      body: SafeArea(
        child: SanrioBackground(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _WalletHero(coins: _coins),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _drawing ? null : _drawOnce,
                              icon: const Icon(Icons.redeem_rounded),
                              label: Text(_drawing ? '抽取中...' : '抽 1 次'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _drawing ? null : _rewardCoins,
                            icon: const Icon(Icons.monetization_on_rounded),
                            label: const Text('+20 金币'),
                          ),
                        ],
                      ),
                      if (_lastDraw != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _LastDrawCard(item: _lastDraw!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '我的背包',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_inventory.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text('还没有抽到任何道具，先试试手气吧。'),
                          ),
                        )
                      else
                        ..._inventory.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Text(
                                  _rarityEmoji((row['rarity'] as int?) ?? 1),
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title:
                                    Text(row['item_name'] as String? ?? '未知道具'),
                                subtitle: Text(
                                  '稀有度 ${row['rarity']} · 来源 ${row['source'] ?? 'gacha'}',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _drawOnce() async {
    final repo = ref.read(gachaRepositoryProvider);
    setState(() => _drawing = true);
    try {
      final item = await repo.drawOnce();
      final coins = await repo.getCoins();
      final inventory = await repo.getInventory();
      if (!mounted) {
        return;
      }
      setState(() {
        _lastDraw = item;
        _coins = coins;
        _inventory = inventory;
      });
      ref.invalidate(walletCoinsProvider);
      showAppToast(context, '抽中 ${item.emoji} ${item.name}',
          type: AppToastType.success);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(context, '$error', type: AppToastType.warning);
    } finally {
      if (mounted) {
        setState(() => _drawing = false);
      }
    }
  }

  Future<void> _rewardCoins() async {
    final repo = ref.read(gachaRepositoryProvider);
    await repo.addCoins(20);
    await _load();
    if (!mounted) {
      return;
    }
    showAppToast(context, '已获得 20 金币', type: AppToastType.success);
  }

  static String _rarityEmoji(int rarity) {
    if (rarity >= 3) {
      return '👑';
    }
    if (rarity == 2) {
      return '💎';
    }
    return '🌸';
  }
}

class _WalletHero extends StatelessWidget {
  const _WalletHero({required this.coins});

  final int coins;

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
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '金币余额  $coins',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '每次抽取消耗 10 金币，稀有度越高越难获得。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
          ),
        ],
      ),
    );
  }
}

class _LastDrawCard extends StatelessWidget {
  const _LastDrawCard({required this.item});

  final GachaItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最新抽中：${item.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    '稀有度 ${item.rarity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
