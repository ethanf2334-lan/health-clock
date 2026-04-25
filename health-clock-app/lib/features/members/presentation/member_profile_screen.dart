import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/document.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/metric_record.dart';
import '../../calendar/data/event_repository.dart';
import '../../documents/data/document_repository.dart';
import '../../health_records/data/metric_repository.dart';
import '../data/member_repository.dart';
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
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(memberProfileSummaryProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('成员档案'),
        actions: [
          summaryAsync.whenOrNull(
                data: (summary) => IconButton(
                  tooltip: '编辑成员',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MemberFormScreen(member: summary.member),
                      ),
                    );
                    ref.invalidate(memberProfileSummaryProvider(memberId));
                  },
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => _buildBody(context, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MemberProfileSummary summary) {
    final pendingEvents = summary.events
        .where((event) => event.status == 'pending')
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final sortedMetrics = [...summary.metrics]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final sortedDocuments = [...summary.documents]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latestMetric = sortedMetrics.isEmpty ? null : sortedMetrics.first;
    final latestDocument =
        sortedDocuments.isEmpty ? null : sortedDocuments.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(context, summary.member),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statCard('待办提醒', pendingEvents.length)),
            const SizedBox(width: 8),
            Expanded(child: _statCard('健康文档', summary.documents.length)),
            const SizedBox(width: 8),
            Expanded(child: _statCard('指标记录', summary.metrics.length)),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          context,
          '基础信息',
          [
            _infoRow('关系', memberRelationLabel(summary.member.relation)),
            if (summary.member.gender != null)
              _infoRow('性别', _genderLabel(summary.member.gender!)),
            if (summary.member.birthDate != null)
              _infoRow(
                '生日',
                DateFormat('yyyy-MM-dd').format(summary.member.birthDate!),
              ),
            if (summary.member.bloodType != null)
              _infoRow('血型', summary.member.bloodType!),
            if (summary.member.notes != null &&
                summary.member.notes!.trim().isNotEmpty)
              _infoRow('备注', summary.member.notes!),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          context,
          '最近动态',
          [
            _infoRow(
              '下一条提醒',
              pendingEvents.isEmpty
                  ? '暂无待办提醒'
                  : '${pendingEvents.first.title} · ${DateFormat('MM-dd HH:mm').format(pendingEvents.first.scheduledAt.toLocal())}',
            ),
            _infoRow(
              '最新文档',
              latestDocument == null
                  ? '暂无文档'
                  : latestDocument.title ?? latestDocument.fileName,
            ),
            _infoRow(
              '最新指标',
              latestMetric == null
                  ? '暂无指标'
                  : '${_metricLabel(latestMetric.metricType)} ${latestMetric.value}${latestMetric.unit}',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => context.push('/events/new'),
              icon: const Icon(Icons.add_alert_outlined),
              label: const Text('新建提醒'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/documents/new'),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('上传文档'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/metrics/new'),
              icon: const Icon(Icons.favorite_outline),
              label: const Text('记录指标'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _header(BuildContext context, Member member) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                member.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memberRelationLabel(member.relation),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    final visible = children.isEmpty
        ? [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无信息'),
            ),
          ]
        : children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(child: Column(children: visible)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _genderLabel(String gender) {
    const labels = {
      'male': '男',
      'female': '女',
      'other': '其他',
    };
    return labels[gender] ?? gender;
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
}
