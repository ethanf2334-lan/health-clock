import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/models/document.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/metric_record.dart';
import '../../calendar/data/event_repository.dart';
import '../../documents/data/document_repository.dart';
import '../../health_records/data/metric_repository.dart';
import '../data/member_repository.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_labels.dart';

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
      backgroundColor: const Color(0xFFF7FCF9),
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          sliver: SliverList.list(
            children: [
              _OverviewCard(
                member: summary.member,
                isCurrent: isCurrent,
                reminderCount: pendingEvents.length,
                documentCount: summary.documents.length,
                metricCount: summary.metrics.length,
                onSetCurrent: onSetCurrent,
                onCreateEvent: () =>
                    _setCurrentAndGo(ref, context, '/events/new'),
                onUploadDocument: () =>
                    _setCurrentAndGo(ref, context, '/documents/new'),
                onRecordMetric: () =>
                    _setCurrentAndGo(ref, context, '/metrics/new'),
              ),
              const SizedBox(height: 26),
              _SectionHeader(
                title: '近期提醒',
                onViewAll: () => _showUnavailable(context, '请在健康日历查看全部提醒'),
              ),
              const SizedBox(height: 10),
              _ReminderCard(events: pendingEvents.take(3).toList()),
              const SizedBox(height: 22),
              _SectionHeader(
                title: '最近文档',
                onViewAll: () => _setCurrentAndGo(ref, context, '/documents'),
              ),
              const SizedBox(height: 10),
              _DocumentCard(documents: documents.take(2).toList()),
              const SizedBox(height: 22),
              _SectionHeader(
                title: '最近指标',
                onViewAll: () => _setCurrentAndGo(ref, context, '/metrics'),
              ),
              const SizedBox(height: 10),
              _MetricStrip(metrics: metrics.take(3).toList()),
              const SizedBox(height: 18),
              _FullArchiveButton(
                onTap: () => _setCurrentAndGo(ref, context, '/documents'),
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
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
          const Text(
            '成员档案',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4FFFA), Color(0xFFEFFAF4)],
        ),
        border: Border.all(color: const Color(0xFFD7EBE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const Positioned(
                right: -8,
                top: 0,
                child: _FamilyArt(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MemberPortrait(member: member),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 118),
                      child: _MemberTextInfo(
                        member: member,
                        isCurrent: isCurrent,
                        onSetCurrent: onSetCurrent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _StatsBar(
            reminderCount: reminderCount,
            documentCount: documentCount,
            metricCount: metricCount,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.notification_add_rounded,
                  label: '新建提醒',
                  onTap: onCreateEvent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.drive_folder_upload_rounded,
                  label: '上传文档',
                  onTap: onUploadDocument,
                ),
              ),
              const SizedBox(width: 10),
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
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: isCurrent ? null : onSetCurrent,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF7E8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isCurrent ? '当前成员' : '设为当前',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: MemberProfileScreen._green,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          [
            memberRelationLabel(member.relation),
            if (age != null) '$age岁',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        if (birthday != null)
          _InfoLine(icon: Icons.calendar_month_outlined, text: birthday),
        const SizedBox(height: 8),
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
            style: const TextStyle(
              fontSize: 15,
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
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: MemberProfileScreen._green, size: 28),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 25,
                height: 1.05,
                color: MemberProfileScreen._green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: MemberProfileScreen._line);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .055),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: MemberProfileScreen._green, size: 25),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '查看全部',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.chevron_right_rounded, size: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            _RoundIcon(
              icon: _eventIcon(event.eventType),
              color: _eventColor(event.eventType),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _eventSubtitle(event),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _relativeTime(event.scheduledAt),
              style: const TextStyle(
                fontSize: 16,
                color: MemberProfileScreen._green,
                fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            _RoundIcon(
              icon: Icons.description_rounded,
              color: _documentColor(document.category),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title ?? document.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    [
                      DateFormat('yyyy年M月d日').format(date.toLocal()),
                      if (document.hospitalName != null &&
                          document.hospitalName!.isNotEmpty)
                        '来自 ${document.hospitalName}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
          if (i != metrics.length - 1) const SizedBox(width: 10),
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
      height: 126,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .10), Colors.white],
        ),
        border: Border.all(color: color.withValues(alpha: .18)),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 38,
                height: 16,
                child: CustomPaint(painter: _SparkPainter(color)),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _metricValue(metric),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 25,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 7),
          Text(
            DateFormat('M月d日 HH:mm').format(metric.recordedAt.toLocal()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
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
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: const LinearGradient(
            colors: [Color(0xFFF7FFFB), Color(0xFFEFFAF5)],
          ),
          border: Border.all(color: const Color(0xFFDDEFE7)),
        ),
        child: const Row(
          children: [
            Icon(Icons.source_rounded, color: MemberProfileScreen._green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '查看完整健康档案',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: MemberProfileScreen._green,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EEE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EEE9)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
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
      child: Icon(icon, color: color, size: 25),
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
    final isFemale = member.gender == 'female' || member.relation == 'mother';
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isFemale
                ? const [Color(0xFFFFEEF0), Color(0xFFFFDCD7)]
                : const [Color(0xFFE8F5FF), Color(0xFFCFEAFF)],
          ),
        ),
        child: CustomPaint(painter: _PortraitPainter(isFemale: isFemale)),
      ),
    );
  }
}

class _FamilyArt extends StatelessWidget {
  const _FamilyArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 95,
      child: CustomPaint(painter: _FamilyPainter()),
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

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter({required this.isFemale});

  final bool isFemale;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final skin = Paint()..color = const Color(0xFFFFBE9F);
    final hair = Paint()
      ..color = isFemale ? const Color(0xFF6A5650) : const Color(0xFF333438);
    final shirt = Paint()
      ..color = isFemale ? const Color(0xFFFF8F76) : const Color(0xFF5DADE9);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * .98),
        width: size.width * .78,
        height: size.height * .52,
      ),
      shirt,
    );
    if (isFemale) {
      canvas.drawCircle(Offset(cx - 24, size.height * .36), 20, hair);
      canvas.drawCircle(Offset(cx + 24, size.height * .36), 20, hair);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, size.height * .42),
          width: size.width * .65,
          height: size.height * .58,
        ),
        hair,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 32, size.height * .22, 64, 34),
          const Radius.circular(22),
        ),
        hair,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * .50),
        width: size.width * .46,
        height: size.height * .52,
      ),
      skin,
    );
    final eye = Paint()..color = const Color(0xFF202225);
    canvas.drawCircle(Offset(cx - 12, size.height * .48), 2.6, eye);
    canvas.drawCircle(Offset(cx + 12, size.height * .48), 2.6, eye);
    final smile = Paint()
      ..color = const Color(0xFFD96D58)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, size.height * .58),
        width: 18,
        height: 10,
      ),
      .15,
      2.84,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter oldDelegate) =>
      oldDelegate.isFemale != isFemale;
}

class _FamilyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()
      ..color = const Color(0xFF7BD4A4).withValues(alpha: .34)
      ..style = PaintingStyle.fill;
    final pale = Paint()
      ..color = Colors.white.withValues(alpha: .7)
      ..style = PaintingStyle.fill;
    final coral = Paint()
      ..color = const Color(0xFFFF9F92).withValues(alpha: .7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * .46, size.height * .28), 25, pale);
    canvas.drawCircle(Offset(size.width * .66, size.height * .36), 18, pale);

    final roof = Paint()
      ..color = const Color(0xFF70C997).withValues(alpha: .35)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * .28, size.height * .58),
      Offset(size.width * .52, size.height * .28),
      roof,
    );
    canvas.drawLine(
      Offset(size.width * .52, size.height * .28),
      Offset(size.width * .77, size.height * .58),
      roof,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .34, size.height * .52, 58, 35),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFE6F8EF),
    );

    void person(double x, double h) {
      canvas.drawCircle(Offset(x, size.height * .60), 4.5, green);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height * .73),
            width: 9,
            height: h,
          ),
          const Radius.circular(5),
        ),
        green,
      );
    }

    person(size.width * .47, 22);
    person(size.width * .56, 27);
    person(size.width * .65, 18);

    canvas.drawCircle(Offset(size.width * .82, size.height * .58), 14, coral);
    canvas.drawCircle(Offset(size.width * .90, size.height * .58), 14, coral);
    final heart = Path()
      ..moveTo(size.width * .86, size.height * .79)
      ..lineTo(size.width * .74, size.height * .60)
      ..lineTo(size.width * .98, size.height * .60)
      ..close();
    canvas.drawPath(heart, coral);

    final stem = Paint()
      ..color = const Color(0xFF71C894).withValues(alpha: .5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [size.width * .18, size.width * .96]) {
      canvas.drawLine(
        Offset(x, size.height * .84),
        Offset(x, size.height * .30),
        stem,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - 7, size.height * .48),
          width: 14,
          height: 27,
        ),
        green,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 8, size.height * .62),
          width: 14,
          height: 27,
        ),
        green,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
