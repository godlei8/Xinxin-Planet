import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/sanrio_background.dart';
import '../../../services/providers.dart';
import '../domain/supervision_partner.dart';

class SupervisionPage extends ConsumerStatefulWidget {
  const SupervisionPage({super.key});

  @override
  ConsumerState<SupervisionPage> createState() => _SupervisionPageState();
}

class _SupervisionPageState extends ConsumerState<SupervisionPage> {
  final _nameController = TextEditingController();
  String _relation = 'friend';
  String _emoji = '🐰';
  bool _loading = true;
  List<SupervisionPartner> _partners = const [];
  List<Map<String, dynamic>> _logs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(supervisionRepositoryProvider);
    final partners = await repo.getPartners();
    final logs = await repo.getLogs();
    if (!mounted) {
      return;
    }
    setState(() {
      _partners = partners;
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('好友监督搭子')),
      body: SafeArea(
        child: SanrioBackground(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _buildCreateCard(context),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '我的搭子',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_partners.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text('还没有监督搭子，先添加一个吧。'),
                          ),
                        )
                      else
                        ..._partners.map(
                          (partner) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Text(
                                  partner.avatarEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(partner.name),
                                subtitle: Text(_relationText(partner.relation)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.campaign_rounded),
                                  onPressed: () => _encourage(partner),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '监督日志',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_logs.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text('暂无监督日志。'),
                          ),
                        )
                      else
                        ..._logs.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Text(
                                  row['avatar_emoji'] as String? ?? '🐰',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(row['message'] as String? ?? ''),
                                subtitle: Text(
                                  row['partner_name'] as String? ?? '伙伴',
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

  Widget _buildCreateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加监督搭子',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                hintText: '比如：小晴、阿远、未来的自己',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _relation,
                    decoration: const InputDecoration(labelText: '关系'),
                    items: const [
                      DropdownMenuItem(value: 'friend', child: Text('朋友')),
                      DropdownMenuItem(value: 'family', child: Text('家人')),
                      DropdownMenuItem(value: 'mentor', child: Text('导师')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _relation = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _emoji,
                    decoration: const InputDecoration(labelText: '头像'),
                    items: const [
                      DropdownMenuItem(value: '🐰', child: Text('🐰')),
                      DropdownMenuItem(value: '🌸', child: Text('🌸')),
                      DropdownMenuItem(value: '🐻', child: Text('🐻')),
                      DropdownMenuItem(value: '🦊', child: Text('🦊')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _emoji = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addPartner,
                child: const Text('添加搭子'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPartner() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(context, '请先输入昵称', type: AppToastType.warning);
      return;
    }

    final repo = ref.read(supervisionRepositoryProvider);
    await repo.addPartner(name: name, relation: _relation, avatarEmoji: _emoji);
    _nameController.clear();
    await _load();
    if (!mounted) {
      return;
    }
    showAppToast(context, '搭子添加成功', type: AppToastType.success);
  }

  Future<void> _encourage(SupervisionPartner partner) async {
    final repo = ref.read(supervisionRepositoryProvider);
    await repo.createEncourageLog(partner.id, partner.name);
    await _load();
    if (!mounted) {
      return;
    }
    showAppToast(context, '已发送鼓励', type: AppToastType.info);
  }

  String _relationText(String relation) {
    switch (relation) {
      case 'family':
        return '家人';
      case 'mentor':
        return '导师';
      default:
        return '朋友';
    }
  }
}
