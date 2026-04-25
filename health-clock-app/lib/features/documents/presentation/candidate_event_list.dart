import 'package:flutter/material.dart';

import '../../calendar/presentation/event_form_screen.dart';

/// Shows OCR/AI extracted follow-up suggestions and lets the user confirm them.
class CandidateEventList extends StatefulWidget {
  final String memberId;
  final List<Map<String, dynamic>> candidates;
  final bool showEmptyState;

  const CandidateEventList({
    super.key,
    required this.memberId,
    required this.candidates,
    this.showEmptyState = true,
  });

  @override
  State<CandidateEventList> createState() => _CandidateEventListState();
}

class _CandidateEventListState extends State<CandidateEventList> {
  final Set<int> _createdIndexes = {};

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      if (!widget.showEmptyState) return const SizedBox.shrink();
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('未从文档中识别出候选提醒。可从"AI 创建"手动输入，或回到列表继续。'),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < widget.candidates.length; i++)
          _CandidateEventTile(
            candidate: widget.candidates[i],
            created: _createdIndexes.contains(i),
            onCreate: () => _createCandidate(context, i, widget.candidates[i]),
          ),
      ],
    );
  }

  Future<void> _createCandidate(
    BuildContext context,
    int index,
    Map<String, dynamic> candidate,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final event = await navigator.push(
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          prefill: _buildPrefill(widget.memberId, candidate),
        ),
      ),
    );
    if (!mounted || event == null) return;

    setState(() => _createdIndexes.add(index));
    messenger.showSnackBar(
      const SnackBar(content: Text('候选提醒已创建')),
    );
  }
}

class _CandidateEventTile extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final bool created;
  final VoidCallback onCreate;

  const _CandidateEventTile({
    required this.candidate,
    required this.created,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final title = candidate['title']?.toString().trim();
    final expression = candidate['time_expression']?.toString().trim();
    final source = candidate['source']?.toString().trim();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(created ? Icons.check : Icons.auto_awesome),
        ),
        title: Text(title == null || title.isEmpty ? '未命名提醒' : title),
        subtitle: Text(
          [
            if (expression != null && expression.isNotEmpty) '时间：$expression',
            if (source != null && source.isNotEmpty) '来源：$source',
          ].join('  ·  '),
        ),
        trailing: ElevatedButton(
          onPressed: created ? null : onCreate,
          child: Text(created ? '已创建' : '创建'),
        ),
      ),
    );
  }
}

Map<String, dynamic> _buildPrefill(
  String memberId,
  Map<String, dynamic> candidate,
) {
  final title = candidate['title']?.toString().trim();
  final timeExpression = candidate['time_expression']?.toString().trim();

  return {
    'event_title': title == null || title.isEmpty ? '复查提醒' : title,
    'event_type': 'follow_up',
    'scheduled_at':
        _resolveCandidateDate(timeExpression).toUtc().toIso8601String(),
    'is_all_day': true,
    'member_id': memberId,
    'confidence': 0.7,
    'source_type': 'ai_document',
    'source_text': [
      if (title != null && title.isNotEmpty) title,
      if (timeExpression != null && timeExpression.isNotEmpty) timeExpression,
    ].join(' / '),
    if (timeExpression != null && timeExpression.isNotEmpty)
      'description': '来自文档 OCR 的候选提醒：$timeExpression',
  };
}

DateTime _resolveCandidateDate(String? expression) {
  final now = DateTime.now();
  final fallback = _dateOnly(now.add(const Duration(days: 30)));
  if (expression == null || expression.trim().isEmpty) return fallback;

  final text = expression.trim();
  if (text.contains('明天')) return _dateOnly(now.add(const Duration(days: 1)));
  if (text.contains('后天')) return _dateOnly(now.add(const Duration(days: 2)));
  if (text.contains('下周')) return _dateOnly(now.add(const Duration(days: 7)));
  if (text.contains('下个月')) return _addMonths(now, 1);
  if (text.contains('明年')) return _addYears(now, 1);

  final absolute = RegExp(
    r'(\d{4})[-/.年](\d{1,2})[-/.月](\d{1,2})',
  ).firstMatch(text);
  if (absolute != null) {
    return _safeDate(
      int.parse(absolute.group(1)!),
      int.parse(absolute.group(2)!),
      int.parse(absolute.group(3)!),
    );
  }

  final monthDay = RegExp(r'(\d{1,2})月(\d{1,2})[日号]?').firstMatch(text);
  if (monthDay != null) {
    final month = int.parse(monthDay.group(1)!);
    final day = int.parse(monthDay.group(2)!);
    final candidate = _safeDate(now.year, month, day);
    return candidate.isBefore(_dateOnly(now))
        ? _safeDate(now.year + 1, month, day)
        : candidate;
  }

  final relative = RegExp(r'(\d+)\s*(天|日|周|星期|个月|月|年)后').firstMatch(text);
  if (relative == null) return fallback;

  final amount = int.parse(relative.group(1)!);
  final unit = relative.group(2)!;
  if (unit == '天' || unit == '日') {
    return _dateOnly(now.add(Duration(days: amount)));
  }
  if (unit == '周' || unit == '星期') {
    return _dateOnly(now.add(Duration(days: amount * 7)));
  }
  if (unit == '个月' || unit == '月') return _addMonths(now, amount);
  return _addYears(now, amount);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day, 9);

DateTime _addMonths(DateTime value, int months) {
  return _safeDate(value.year, value.month + months, value.day);
}

DateTime _addYears(DateTime value, int years) {
  return _safeDate(value.year + years, value.month, value.day);
}

DateTime _safeDate(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day.clamp(1, lastDay), 9);
}
