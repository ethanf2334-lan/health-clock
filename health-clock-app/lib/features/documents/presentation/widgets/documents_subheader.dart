import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../members/presentation/widgets/member_avatar.dart';
import '../../../members/providers/current_member_provider.dart';
import '../../../members/providers/member_provider.dart';

/// 第二行：左侧当前成员胶囊（点击切换），右侧分类计数标签
class DocumentsSubheader extends ConsumerWidget {
  const DocumentsSubheader({super.key, required this.counts});

  final List<DocCategoryCount> counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _MemberPill(),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in counts) ...[
                    _CategoryCount(count: c),
                    if (c != counts.last) const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocCategoryCount {
  const DocCategoryCount({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;
}

class _MemberPill extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureCurrentMemberProvider);
    final membersAsync = ref.watch(memberListProvider);
    final currentId = ref.watch(currentMemberIdProvider);

    final member = membersAsync.maybeWhen(
      data: (members) {
        for (final m in members) {
          if (m.id == currentId) return m;
        }
        return members.isEmpty ? null : members.first;
      },
      orElse: () => null,
    );

    final name = member?.name ?? '请选择';
    final relation = member?.relation;

    return Material(
      color: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        onTap: () => _showPicker(context, ref),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 5, 6, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '当前成员 ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              MemberAvatar(name: name, relation: relation, size: 24),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...members.map(
                (m) => ListTile(
                  leading: MemberAvatar(name: m.name, relation: m.relation),
                  title: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: currentId == m.id
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mintDeep,
                        )
                      : null,
                  onTap: () {
                    ref.read(currentMemberIdProvider.notifier).state = m.id;
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.lightDivider),
              ListTile(
                leading: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.mintDeep,
                ),
                title: const Text(
                  '添加新成员',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mintDeep,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/members/new');
                },
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('加载失败: $e'),
          ),
        ),
      ),
    );
  }
}

class _CategoryCount extends StatelessWidget {
  const _CategoryCount({required this.count});

  final DocCategoryCount count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: count.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          count.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${count.count}',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
