import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';
import 'member_labels.dart';

/// 顶部成员切换条：点击弹出底部选择。
class MemberSwitcherBar extends ConsumerWidget {
  final bool showAllOption;
  const MemberSwitcherBar({super.key, this.showAllOption = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);
    ref.watch(ensureCurrentMemberProvider);
    final currentId = ref.watch(currentMemberIdProvider);

    final selectedMember = membersAsync.maybeWhen(
      data: (members) {
        if (currentId == null) return null;
        for (final member in members) {
          if (member.id == currentId) return member;
        }
        return null;
      },
      orElse: () => null,
    );
    final label = membersAsync.when(
      data: (members) {
        if (currentId == null) return '请选择成员';
        final found = members.where((m) => m.id == currentId).toList();
        if (found.isEmpty) return '未选择';
        return found.first.name;
      },
      loading: () => '加载中…',
      error: (_, __) => '加载失败',
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => _showPicker(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.careBlue.withValues(alpha: 0.28),
                  child: Text(
                    selectedMember?.name.substring(0, 1) ?? '家',
                    style: const TextStyle(
                      color: AppColors.mintDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        selectedMember?.relation == null
                            ? '当前照护对象'
                            : memberRelationLabel(selectedMember!.relation),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '切换',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.careBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.careBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.read(memberListProvider);
    final currentId = ref.read(currentMemberIdProvider);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: membersAsync.when(
            data: (members) {
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text(
                      '选择照护对象',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (showAllOption && members.isEmpty)
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
                      subtitle: Text(memberRelationLabel(m.relation)),
                      trailing: currentId == m.id
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
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
