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

  // 不对用户展示的内部字段
  static const _hiddenKeys = {'candidate_events', 'raw_text', 'error', 'ai_error'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrText = ocrResult['ocr_text'] as String? ?? '';
    final aiSummary = ocrResult['ai_summary'] as Map<String, dynamic>?;
    final candidates =
        (ocrResult['candidate_events'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // 检测 AI 是否失败
    final aiError = aiSummary?['ai_error'] as String? ?? aiSummary?['error'] as String?;
    final hasValidSummary = aiSummary != null &&
        aiSummary.keys.any((k) => !_hiddenKeys.contains(k));

    return Scaffold(
      appBar: AppBar(title: const Text('OCR 识别结果')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI 解析不可用时显示提示条
          if (aiError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AI 结构化解析暂时不可用，OCR 文本已正常识别。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (hasValidSummary) ...[
            Text('AI 提取信息',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: aiSummary!.entries
                      .where((e) => !_hiddenKeys.contains(e.key))
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

  static const _keyLabels = {
    'hospital_name': '医院',
    'department': '科室',
    'document_date': '报告日期',
    'report_name': '报告名称',
    'examination_method': '检查方法',
    'examination_findings': '检查所见',
    'diagnosis': '检查提示/诊断',
    'examination_items': '检查项目',
    'abnormal_indicators': '异常指标',
    'follow_up_suggestions': '复查建议',
    'patient_name': '姓名',
    'patient_age': '年龄',
    'patient_gender': '性别',
  };

  Widget _kv(String k, dynamic v) {
    // 跳过空值
    if (v == null) return const SizedBox.shrink();
    if (v is List && v.isEmpty) return const SizedBox.shrink();
    if (v is String && v.trim().isEmpty) return const SizedBox.shrink();

    final label = _keyLabels[k] ?? k;
    final display = _formatValue(v);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(display, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic v) {
    if (v == null) return '';
    if (v is List) {
      return v.map((e) {
        if (e is Map) {
          // follow_up_suggestions: {suggestion, time_expression}
          final s = e['suggestion'] ?? e.values.firstOrNull ?? '';
          final t = e['time_expression'];
          return t != null ? '$s（$t）' : s.toString();
        }
        if (e is Map) return e.toString();
        return e.toString();
      }).join('\n');
    }
    return v.toString();
  }
}
