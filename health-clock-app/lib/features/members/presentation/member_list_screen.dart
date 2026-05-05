import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/models/member.dart';
import '../../calendar/providers/event_provider.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_labels.dart';
import 'widgets/current_member_card.dart';
import 'widgets/member_list_tile_card.dart';
import 'widgets/members_header.dart';
import 'widgets/relation_legend_card.dart';

class MemberListScreen extends ConsumerWidget {
  const MemberListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);
    final currentId = ref.watch(currentMemberIdProvider);
    final eventsAsync = ref.watch(eventListProvider);

    final body = membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return _buildEmpty(context);
        }
        return _buildContent(
          context,
          ref,
          members: members,
          currentId: currentId,
          events: eventsAsync.maybeWhen(
            data: (e) => e,
            orElse: () => const <HealthEvent>[],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
    );

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭成员'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _addMember(context),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 44,
                color: AppColors.mintDeep,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有添加成员',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '为家人创建独立健康档案，统一管理提醒和数据',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addMember(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加成员'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required List<Member> members,
    required String? currentId,
    required List<HealthEvent> events,
  }) {
    final currentMember = members.firstWhere(
      (m) => m.id == currentId,
      orElse: () => members.first,
    );
    final otherMembers =
        members.where((m) => m.id != currentMember.id).toList();

    final currentStats = _statsFor(currentMember.id, events);
    final pendingCount = currentStats.pendingCount;
    final reminderCount = currentStats.reminderCount;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(memberListProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MembersHeader(
            title: '家庭成员',
            subtitle: '当前为 ${members.length} 位成员管理健康事项',
            onAdd: () => _addMember(context),
          ),
          CurrentMemberCard(
            name: currentMember.name,
            relation: currentMember.relation,
            relationLabel: memberRelationLabel(currentMember.relation),
            age: _ageFrom(currentMember.birthDate),
            pendingCount: pendingCount,
            reminderCount: reminderCount,
            documentCount: currentStats.documentCount,
            metricCount: currentStats.metricCount,
            isCurrent: true,
            onViewProfile: () => context.push('/members/${currentMember.id}'),
            onSetCurrent: () {
              ref.read(currentMemberIdProvider.notifier).state =
                  currentMember.id;
            },
          ),
          _buildSectionHeader(
            context,
            title: '全部成员',
            actionLabel: '管理',
            onActionTap: () => _showManageSheet(context, ref, members),
          ),
          ...otherMembers.map(
            (m) => MemberListTileCard(
              name: m.name,
              relation: m.relation,
              relationLabel: memberRelationLabel(m.relation),
              age: _ageFrom(m.birthDate),
              isSelf: m.relation == 'self',
              summary: _summaryFor(m, events),
              summaryHighlight: null,
              onTap: () {
                ref.read(currentMemberIdProvider.notifier).state = m.id;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('已切换到 ${m.name}'),
                      duration: const Duration(milliseconds: 1200),
                    ),
                  );
              },
              onLongPress: () => _showMemberOptions(context, ref, m),
            ),
          ),
          if (otherMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _EmptyOtherHint(),
            ),
          const RelationLegendCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _ageFrom(DateTime? birth) {
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  _MemberStats _statsFor(String memberId, List<HealthEvent> events) {
    final now = DateTime.now();
    final memberEvents = events.where((e) => e.memberId == memberId).toList();
    final pending = memberEvents
        .where(
          (e) =>
              e.status == 'pending' &&
              (e.scheduledAt.toLocal().isBefore(now) ||
                  _isSameDay(e.scheduledAt.toLocal(), now)),
        )
        .length;
    final reminder = memberEvents.where((e) => e.status == 'pending').length;
    return _MemberStats(
      pendingCount: pending,
      reminderCount: reminder,
      documentCount: 0,
      metricCount: 0,
    );
  }

  String? _summaryFor(Member m, List<HealthEvent> events) {
    final stats = _statsFor(m.id, events);
    if (stats.reminderCount == 0) return '暂无待办';
    return '${stats.reminderCount} 条提醒';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _addMember(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MemberFormScreen()),
    );
  }

  void _showManageSheet(
    BuildContext context,
    WidgetRef ref,
    List<Member> members,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                '管理家庭成员',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...members.map(
              (m) => ListTile(
                leading: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                title: Text(m.name),
                subtitle: Text(memberRelationLabel(m.relation)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MemberFormScreen(member: m),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                      onPressed: () => _confirmDelete(context, ref, m),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, WidgetRef ref, Member member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_pin_rounded),
              title: const Text('设为当前成员'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(currentMemberIdProvider.notifier).state = member.id;
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('查看综合档案'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(currentMemberIdProvider.notifier).state = member.id;
                context.push('/members/${member.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MemberFormScreen(member: member),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: const Text(
                '删除',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, member);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${member.name}」吗？相关数据将一并清理。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(memberListProvider.notifier).deleteMember(member.id);
    final curId = ref.read(currentMemberIdProvider);
    if (curId == member.id) {
      ref.read(currentMemberIdProvider.notifier).state = null;
    }
  }
}

class _MemberStats {
  const _MemberStats({
    required this.pendingCount,
    required this.reminderCount,
    required this.documentCount,
    required this.metricCount,
  });
  final int pendingCount;
  final int reminderCount;
  final int documentCount;
  final int metricCount;
}

class _EmptyOtherHint extends StatelessWidget {
  const _EmptyOtherHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '暂无其他成员，可以为父母、孩子、配偶等创建档案',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
