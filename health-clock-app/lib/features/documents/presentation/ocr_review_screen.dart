import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/presentation/event_form_screen.dart';

/// OCR 识别结果与候选提醒确认页。
class OcrReviewScreen extends ConsumerWidget {
  final String memberId;
  final Map<String, dynamic> ocrResult;

  const OcrReviewScreen({
    super.key,
    required this.memberId,
    required this.ocrResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrText = ocrResult['ocr_text'] as String? ?? '';
    final aiSummary = ocrResult['ai_summary'] as Map<String, dynamic>?;
    final candidates =
        (ocrResult['candidate_events'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('OCR 识别结果')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (aiSummary != null && aiSummary.isNotEmpty) ...[
            Text('AI 提取信息',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: aiSummary.entries
                      .where((e) => e.key != 'candidate_events')
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _kv(e.key, e.value),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('候选提醒',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (candidates.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('未从文档中识别出候选提醒。可从"AI 创建"手动输入，或回到列表继续。'),
              ),
            ),
          ...candidates.map(
            (c) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
                title: Text(c['title']?.toString() ?? '未命名提醒'),
                subtitle: Text(
                  [
                    if (c['time_expression'] != null)
                      '时间：${c['time_expression']}',
                    if (c['source'] != null) '来源：${c['source']}',
                  ].join('  ·  '),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventFormScreen(prefill: {
                          'event_title': c['title'],
                          'event_type': 'follow_up',
                          'scheduled_at': DateTime.now()
                              .add(const Duration(days: 30))
                              .toUtc()
                              .toIso8601String(),
                          'is_all_day': true,
                          'member_id': memberId,
                          'confidence': 0.5,
                          'source_text': c['time_expression'],
                        }),
                      ),
                    );
                  },
                  child: const Text('创建'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('OCR 原文',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(ocrText.isEmpty ? '（空）' : ocrText),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, dynamic v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(k, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Text(v?.toString() ?? '')),
      ],
    );
  }
}
