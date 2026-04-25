import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';

/// 顶部成员切换条：点击弹出底部选择。
class MemberSwitcherBar extends ConsumerWidget {
  final bool showAllOption;
  const MemberSwitcherBar({super.key, this.showAllOption = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);
    final currentId = ref.watch(currentMemberIdProvider);

    final label = membersAsync.when(
      data: (members) {
        if (currentId == null) return '全部成员';
        final found = members.where((m) => m.id == currentId).toList();
        if (found.isEmpty) return '未选择';
        return found.first.name;
      },
      loading: () => '加载中…',
      error: (_, __) => '加载失败',
    );

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _showPicker(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.arrow_drop_down),
              const Spacer(),
              Text(
                '切换',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.read(memberListProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: membersAsync.when(
            data: (members) {
              return ListView(
                shrinkWrap: true,
                children: [
                  if (showAllOption)
                    ListTile(
                      leading: const Icon(Icons.groups),
                      title: const Text('全部成员'),
                      onTap: () {
                        ref.read(currentMemberIdProvider.notifier).state = null;
                        Navigator.pop(context);
                      },
                    ),
                  ...members.map(
                    (m) => ListTile(
                      leading: CircleAvatar(
                        child: Text(m.name.substring(0, 1)),
                      ),
                      title: Text(m.name),
                      subtitle: Text(m.relation ?? ''),
                      onTap: () {
                        ref.read(currentMemberIdProvider.notifier).state = m.id;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('添加新成员'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/members/new');
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('加载失败: $e'),
            ),
          ),
        );
      },
    );
  }
}
