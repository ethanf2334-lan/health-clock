import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../shared/models/document.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/metric_record.dart';
import '../../calendar/data/event_repository.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/presentation/document_quick_upload.dart';
import '../../health_records/data/metric_repository.dart';
import '../../home/presentation/widgets/metric_record_sheet.dart';
import '../../home/presentation/widgets/manual_reminder_sheet.dart';
import '../data/member_repository.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_labels.dart';
import 'widgets/member_avatar.dart';

class MemberProfileSummary {
  final Member member;
  final List<HealthEvent> events;
  final List<HealthDocument> documents;
  final List<MetricRecord> metrics;

  const MemberProfileSummary({
    required this.member,
    required this.events,
    required this.documents,
    required this.metrics,
  });
}

final memberProfileSummaryProvider =
    FutureProvider.family<MemberProfileSummary, String>((ref, memberId) async {
  final member = await ref.read(memberRepositoryProvider).getMember(memberId);
  final results = await Future.wait([
    ref.read(eventRepositoryProvider).getEvents(memberId: memberId),
    ref.read(documentRepositoryProvider).listDocuments(memberId: memberId),
    ref.read(metricRepositoryProvider).listMetrics(memberId: memberId),
  ]);
  return MemberProfileSummary(
    member: member,
    events: results[0] as List<HealthEvent>,
    documents: results[1] as List<HealthDocument>,
    metrics: results[2] as List<MetricRecord>,
  );
});

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key, required this.memberId});

  final String memberId;

  static const _green = Color(0xFF26976C);
  static const _softGreen = Color(0xFFEAF8F1);
  static const _line = Color(0xFFE8EFEA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(memberProfileSummaryProvider(memberId));
    final currentId = ref.watch(currentMemberIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: summaryAsync.when(
          data: (summary) => _ProfileContent(
            summary: summary,
            isCurrent: currentId == summary.member.id,
            onEdit: () => _editMember(context, ref, summary.member),
            onSetCurrent: () {
              ref.read(currentMemberIdProvider.notifier).state =
                  summary.member.id;
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('加载失败：$error')),
        ),
      ),
    );
  }

  Future<void> _editMember(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)),
    );
    ref.invalidate(memberProfileSummaryProvider(memberId));
    ref.invalidate(memberListProvider);
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({
    required this.summary,
    required this.isCurrent,
    required this.onEdit,
    required this.onSetCurrent,
  });

  final MemberProfileSummary summary;
  final bool isCurrent;
  final VoidCallback onEdit;
  final VoidCallback onSetCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingEvents = summary.events
        .where((event) => event.status == 'pending')
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final documents = [...summary.documents]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final metrics = _latestMetrics(summary.metrics);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _TopBar(onEdit: onEdit)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppStyles.screenMargin,
            AppStyles.spacingS,
            AppStyles.screenMargin,
            AppStyles.spacingL,
          ),
          sliver: SliverList.list(
            children: [
              _OverviewCard(
                member: summary.member,
                isCurrent: isCurrent,
                reminderCount: pendingEvents.length,
                documentCount: summary.documents.length,
                metricCount: summary.metrics.length,
                onSetCurrent: onSetCurrent,
                onCreateEvent: () => _openManualReminderPanel(ref, context),
                onUploadDocument: () => _pickAndUploadDocument(ref, context),
                onRecordMetric: () => _openMetricRecordPanel(ref, context),
              ),
              const SizedBox(height: AppStyles.spacingL),
              _SectionHeader(
                title: '近期提醒',
                onViewAll: () => _showUnavailable(context, '请在健康日历查看全部提醒'),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _ReminderCard(events: pendingEvents.take(3).toList()),
              const SizedBox(height: AppStyles.spacingL),
              _SectionHeader(
                title: '最近文档',
                onViewAll: () => _setCurrentAndGo(ref, context, '/documents'),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _DocumentCard(documents: documents.take(2).toList()),
              const SizedBox(height: AppStyles.spacingL),
              _SectionHeader(
                title: '最近指标',
                onViewAll: () => _setCurrentAndGo(ref, context, '/metrics'),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _MetricStrip(metrics: metrics.take(3).toList()),
              const SizedBox(height: AppStyles.spacingM),
              _FullArchiveButton(
                onTap: () => _openFullArchive(ref, context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setCurrentAndGo(WidgetRef ref, BuildContext context, String path) {
    ref.read(currentMemberIdProvider.notifier).state = summary.member.id;
    context.push(path);
  }

  void _openManualReminderPanel(WidgetRef ref, BuildContext context) {
    ref.read(currentMemberIdProvider.notifier).state = summary.member.id;
    showModalBottomSheet<HealthEvent>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.73,
              child: ManualReminderSheet(
                onCreated: (_) => ref.invalidate(
                  memberProfileSummaryProvider(summary.member.id),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openFullArchive(WidgetRef ref, BuildContext context) {
    ref.read(currentMemberIdProvider.notifier).state = summary.member.id;
    context.go('/home?tab=documents');
  }

  Future<void> _pickAndUploadDocument(
    WidgetRef ref,
    BuildContext context,
  ) async {
    ref.read(currentMemberIdProvider.notifier).state = summary.member.id;
    await pickFileAndUploadDocument(
      context: context,
      ref: ref,
      memberId: summary.member.id,
      onUploaded: () => ref.invalidate(
        memberProfileSummaryProvider(summary.member.id),
      ),
    );
  }

  void _openMetricRecordPanel(WidgetRef ref, BuildContext context) {
    ref.read(currentMemberIdProvider.notifier).state = summary.member.id;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.73,
              child: MetricRecordSheet(
                onSaved: () => ref.invalidate(
                  memberProfileSummaryProvider(summary.member.id),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUnavailable(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<MetricRecord> _latestMetrics(List<MetricRecord> source) {
    final sorted = [...source]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final byType = <String, MetricRecord>{};
    for (final metric in sorted) {
      byType.putIfAbsent(metric.metricType, () => metric);
    }
    return byType.values.toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.chevron_left_rounded, size: 34),
              color: MemberProfileScreen._green,
              style: IconButton.styleFrom(
                minimumSize: const Size(42, 42),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Text(
            '成员档案',
            style: AppStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.more_horiz_rounded, size: 26),
              color: MemberProfileScreen._green,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(38, 38),
                shadowColor: Colors.black.withValues(alpha: .12),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.member,
    required this.isCurrent,
    required this.reminderCount,
    required this.documentCount,
    required this.metricCount,
    required this.onSetCurrent,
    required this.onCreateEvent,
    required this.onUploadDocument,
    required this.onRecordMetric,
  });

  final Member member;
  final bool isCurrent;
  final int reminderCount;
  final int documentCount;
  final int metricCount;
  final VoidCallback onSetCurrent;
  final VoidCallback onCreateEvent;
  final VoidCallback onUploadDocument;
  final VoidCallback onRecordMetric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        color: Colors.white,
        border: Border.all(color: MemberProfileScreen._line),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _MemberPortrait(member: member),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: _MemberTextInfo(
                  member: member,
                  isCurrent: isCurrent,
                  onSetCurrent: onSetCurrent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          _StatsBar(
            reminderCount: reminderCount,
            documentCount: documentCount,
            metricCount: metricCount,
          ),
          const SizedBox(height: AppStyles.spacingS),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.notification_add_rounded,
                  label: '新建提醒',
                  primary: true,
                  onTap: onCreateEvent,
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: _QuickAction(
                  icon: Icons.drive_folder_upload_rounded,
                  label: '上传文档',
                  onTap: onUploadDocument,
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: _QuickAction(
                  icon: Icons.edit_square,
                  label: '记录指标',
                  onTap: onRecordMetric,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberTextInfo extends StatelessWidget {
  const _MemberTextInfo({
    required this.member,
    required this.isCurrent,
    required this.onSetCurrent,
  });

  final Member member;
  final bool isCurrent;
  final VoidCallback onSetCurrent;

  @override
  Widget build(BuildContext context) {
    final age = _ageFrom(member.birthDate);
    final birthday = member.birthDate == null
        ? null
        : DateFormat('yyyy年M月d日').format(member.birthDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppStyles.spacingS),
            InkWell(
              onTap: isCurrent ? null : onSetCurrent,
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.spacingS,
                  vertical: AppStyles.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF7E8),
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                ),
                child: Text(
                  isCurrent ? '当前成员' : '设为当前',
                  style: AppStyles.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    color: MemberProfileScreen._green,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingXs),
        Text(
          [
            memberRelationLabel(member.relation),
            if (age != null) '$age岁',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.footnote.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.spacingS),
        if (birthday != null)
          _InfoLine(icon: Icons.calendar_month_outlined, text: birthday),
        if (birthday != null) const SizedBox(height: AppStyles.spacingXs),
        _InfoLine(
          icon: Icons.favorite_border_rounded,
          text: member.notes?.trim().isNotEmpty == true
              ? member.notes!.trim()
              : '档案由本人及家庭成员共同管理',
        ),
      ],
    );
  }

  int? _ageFrom(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MemberProfileScreen._green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.footnote.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.reminderCount,
    required this.documentCount,
    required this.metricCount,
  });

  final int reminderCount;
  final int documentCount;
  final int metricCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.compactListRowHeight,
      decoration: BoxDecoration(
        color: MemberProfileScreen._softGreen,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: MemberProfileScreen._line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_rounded,
              label: '提醒',
              value: reminderCount,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.description_rounded,
              label: '文档',
              value: documentCount,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.monitor_heart_rounded,
              label: '指标',
              value: metricCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MemberProfileScreen._green, size: 20),
            const SizedBox(width: AppStyles.spacingS),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: label),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: '$value',
                    style: AppStyles.headline.copyWith(
                      color: MemberProfileScreen._green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppStyles.dividerThin,
      height: AppStyles.spacingL,
      color: MemberProfileScreen._line,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final textColor = primary ? Colors.white : AppColors.textPrimary;
    final iconColor = primary ? Colors.white : MemberProfileScreen._green;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: primary ? null : Colors.white,
          gradient: primary
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34C58A),
                    Color(0xFF16995C),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: primary ? null : Border.all(color: MemberProfileScreen._line),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.mintDeep.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, AppStyles.spacingS),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: AppStyles.spacingS),
                Text(
                  label,
                  style: AppStyles.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '查看全部',
                style: AppStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.events});

  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const _EmptyCard(text: '暂无近期提醒');
    return _ListCard(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          _ReminderRow(event: events[i]),
          if (i != events.length - 1)
            const Divider(height: 1, color: MemberProfileScreen._line),
        ],
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.event});

  final HealthEvent event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/events/${event.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingS),
        child: Row(
          children: [
            _RoundIcon(
              icon: _eventIcon(event.eventType),
              color: _eventColor(event.eventType),
            ),
            const SizedBox(width: AppStyles.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingXs),
                  Text(
                    _eventSubtitle(event),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppStyles.spacingS),
            Text(
              _relativeTime(event.scheduledAt),
              style: AppStyles.footnote.copyWith(
                color: MemberProfileScreen._green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  IconData _eventIcon(String type) {
    if (type.contains('med')) return Icons.medication_rounded;
    if (type.contains('check') || type.contains('exam')) {
      return Icons.event_note;
    }
    if (type.contains('review') || type.contains('visit')) {
      return Icons.medical_services_outlined;
    }
    return Icons.notifications_rounded;
  }

  Color _eventColor(String type) {
    if (type.contains('med')) return const Color(0xFF43B98B);
    if (type.contains('check') || type.contains('exam')) {
      return const Color(0xFFFFA928);
    }
    if (type.contains('review') || type.contains('visit')) {
      return const Color(0xFFFF7474);
    }
    return MemberProfileScreen._green;
  }

  String _eventSubtitle(HealthEvent event) {
    final date = event.scheduledAt.toLocal();
    final detail = DateFormat('M月d日 HH:mm').format(date);
    if (event.repeatRule != null && event.repeatRule!.isNotEmpty) {
      return '$detail · 重复提醒';
    }
    return detail;
  }

  String _relativeTime(DateTime source) {
    final now = DateTime.now();
    final date = source.toLocal();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final isTomorrow = tomorrow.year == date.year &&
        tomorrow.month == date.month &&
        tomorrow.day == date.day;
    if (sameDay) return '今天 ${DateFormat('HH:mm').format(date)}';
    if (isTomorrow) return '明天 ${DateFormat('HH:mm').format(date)}';
    final days = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (days > 0) return '还有 $days 天';
    return DateFormat('M月d日').format(date);
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.documents});

  final List<HealthDocument> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const _EmptyCard(text: '暂无最近文档');
    return _ListCard(
      children: [
        for (var i = 0; i < documents.length; i++) ...[
          _DocumentRow(document: documents[i]),
          if (i != documents.length - 1)
            const Divider(height: 1, color: MemberProfileScreen._line),
        ],
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document});

  final HealthDocument document;

  @override
  Widget build(BuildContext context) {
    final date = document.documentDate ?? document.createdAt;
    return InkWell(
      onTap: () => context.push('/documents/${document.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingS),
        child: Row(
          children: [
            _RoundIcon(
              icon: Icons.description_rounded,
              color: _documentColor(document.category),
            ),
            const SizedBox(width: AppStyles.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title ?? document.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingXs),
                  Text(
                    [
                      DateFormat('yyyy年M月d日').format(date.toLocal()),
                      if (document.hospitalName != null &&
                          document.hospitalName!.isNotEmpty)
                        '来自 ${document.hospitalName}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppStyles.spacingS),
            _Tag(text: _documentLabel(document.category)),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Color _documentColor(String category) {
    if (category.contains('image') || category.contains('scan')) {
      return const Color(0xFF5796F6);
    }
    if (category.contains('prescription')) return const Color(0xFF8D6BEE);
    return const Color(0xFFFF7474);
  }

  String _documentLabel(String category) {
    const labels = {
      'report': '报告',
      'checkup_report': '检验报告',
      'imaging': '影像报告',
      'prescription': '处方',
      'medical_record': '病历',
    };
    return labels[category] ?? '文档';
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics});

  final List<MetricRecord> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const _EmptyCard(text: '暂无最近指标');
    return Row(
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          Expanded(child: _MetricTile(metric: metrics[i])),
          if (i != metrics.length - 1)
            const SizedBox(width: AppStyles.spacingS),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final MetricRecord metric;

  @override
  Widget build(BuildContext context) {
    final color = _metricColor(metric.metricType);
    return Container(
      height: 104,
      padding: const EdgeInsets.all(AppStyles.spacingS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .12), Colors.white],
        ),
        border: Border.all(color: color.withValues(alpha: .20)),
        boxShadow: AppStyles.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _metricLabel(metric.metricType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 34,
                height: 14,
                child: CustomPaint(painter: _SparkPainter(color)),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _metricValue(metric),
                    style: AppStyles.title3.copyWith(
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: ' ${metric.unit}',
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXs),
          Text(
            DateFormat('M月d日 HH:mm').format(metric.recordedAt.toLocal()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.caption1.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _metricValue(MetricRecord metric) {
    if (metric.metricType == 'blood_pressure' && metric.valueExtra != null) {
      final diastolic = metric.valueExtra!['diastolic'];
      if (diastolic != null) {
        return '${_cleanNum(metric.value)}/${_cleanNum(diastolic)}';
      }
    }
    return _cleanNum(metric.value);
  }

  String _cleanNum(Object value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null) return '$value';
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(1);
  }

  String _metricLabel(String type) {
    const labels = {
      'blood_pressure': '血压',
      'blood_sugar': '血糖',
      'weight': '体重',
      'height': '身高',
      'heart_rate': '心率',
      'temperature': '体温',
      'blood_oxygen': '血氧',
    };
    return labels[type] ?? type;
  }

  Color _metricColor(String type) {
    if (type == 'blood_sugar') return const Color(0xFFF29A22);
    if (type == 'weight') return const Color(0xFF8D62D9);
    if (type == 'heart_rate') return const Color(0xFFFF5E65);
    return MemberProfileScreen._green;
  }
}

class _FullArchiveButton extends StatelessWidget {
  const _FullArchiveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          color: Colors.white,
          border: Border.all(color: AppColors.mintDeep),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.source_rounded,
              color: AppColors.mintDeep,
              size: 20,
            ),
            const SizedBox(width: AppStyles.spacingS),
            Text(
              '查看完整健康档案',
              style: AppStyles.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mintDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.cardPadding,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.listRowHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.subtleShadow,
      ),
      child: Text(
        text,
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MemberProfileScreen._softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppStyles.caption1.copyWith(
          fontWeight: FontWeight.w600,
          color: MemberProfileScreen._green,
        ),
      ),
    );
  }
}

class _MemberPortrait extends StatelessWidget {
  const _MemberPortrait({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(AppStyles.spacingXs),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: MemberProfileScreen._line),
        boxShadow: AppStyles.subtleShadow,
      ),
      child: MemberAvatar(
        name: member.name,
        relation: member.relation,
        size: 64,
        borderColor: Colors.white,
        borderWidth: 2,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * .65)
      ..lineTo(size.width * .22, size.height * .45)
      ..lineTo(size.width * .42, size.height * .58)
      ..lineTo(size.width * .63, size.height * .28)
      ..lineTo(size.width * .85, size.height * .42)
      ..lineTo(size.width, size.height * .20);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.color != color;
}
