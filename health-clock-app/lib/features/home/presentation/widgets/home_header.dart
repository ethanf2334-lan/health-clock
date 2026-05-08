import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';
import '../../../members/providers/current_member_provider.dart';
import '../../../members/providers/member_provider.dart';
import '../../../members/presentation/member_labels.dart';

/// 顶部页头：左侧大标题 + 副标题，右侧成员切换胶囊
class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.screenTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                Text(
                  subtitle,
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          const _MemberPill(),
        ],
      ),
    );
  }
}

class _MemberPill extends ConsumerWidget {
  const _MemberPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureCurrentMemberProvider);
    final membersAsync = ref.watch(memberListProvider);
    final currentId = ref.watch(currentMemberIdProvider);

    final selectedName = membersAsync.maybeWhen(
      data: (members) {
        for (final m in members) {
          if (m.id == currentId) return m.name;
        }
        return members.isEmpty ? null : members.first.name;
      },
      orElse: () => null,
    );

    final selectedRelation = membersAsync.maybeWhen(
      data: (members) {
        for (final m in members) {
          if (m.id == currentId) return m.relation;
        }
        return null;
      },
      orElse: () => null,
    );

    return Material(
      color: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.05),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
        onTap: () => _showPicker(context, ref),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppStyles.minTouchTarget,
            minWidth: AppStyles.minTouchTarget,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.spacingM,
              AppStyles.spacingS,
              AppStyles.spacingS,
              AppStyles.spacingS,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              border: Border.all(
                color: AppColors.lightOutline,
                width: AppStyles.borderRegular,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '当前成员 ',
                  style: AppStyles.caption1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  selectedName ?? '请选择',
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                _MemberAvatar(
                  name: selectedName,
                  relation: selectedRelation,
                ),
                const SizedBox(width: AppStyles.spacingXxs),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              AppStyles.spacingS,
              0,
              AppStyles.spacingM,
            ),
            children: [
              Center(
                child: Container(
                  width: AppStyles.spacingXxl,
                  height: AppStyles.spacingXs,
                  margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.lightOutline,
                    borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.spacingM,
                  AppStyles.spacingXs,
                  AppStyles.spacingM,
                  AppStyles.spacingM,
                ),
                child: Text(
                  '选择成员',
                  style: AppStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...members.map(
                (m) => ListTile(
                  leading: _MemberAvatar(name: m.name, relation: m.relation),
                  title: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(memberRelationLabel(m.relation)),
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
                leading: Container(
                  width: AppStyles.iconContainerM,
                  height: AppStyles.iconContainerM,
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: AppColors.mintDeep,
                  ),
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
          loading: () => const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Text('加载失败: $e'),
          ),
        ),
      ),
    );
  }
}

/// 成员小头像，根据关系生成颜色和 emoji
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({this.name, this.relation});

  final String? name;
  final String? relation;

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiFor(relation, name);
    final bg = _bgFor(relation);
    return Container(
      width: AppStyles.avatarS,
      height: AppStyles.avatarS,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: AppStyles.subhead,
      ),
    );
  }

  String _emojiFor(String? relation, String? name) {
    switch (relation) {
      case 'mother':
        return '👩';
      case 'father':
        return '👨';
      case 'self':
        return '🧑';
      case 'spouse':
        return '💑';
      case 'child':
        return '🧒';
      default:
        if (name == null || name.isEmpty) return '🙂';
        return name.characters.first;
    }
  }

  Color _bgFor(String? relation) {
    switch (relation) {
      case 'mother':
        return AppColors.roseSoft;
      case 'father':
        return AppColors.careBlueSoft;
      case 'self':
        return AppColors.mintSoft;
      case 'child':
        return AppColors.sunSoft;
      default:
        return AppColors.mintSoft;
    }
  }
}
