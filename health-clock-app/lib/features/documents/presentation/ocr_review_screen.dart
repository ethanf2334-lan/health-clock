import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'candidate_event_list.dart';

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
  static const _hiddenKeys = {
    'candidate_events',
    'raw_text',
    'error',
    'ai_error',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrText = ocrResult['ocr_text'] as String? ?? '';
    final aiSummary = ocrResult['ai_summary'] as Map<String, dynamic>?;
    final candidates = _candidateEvents(ocrResult);

    // 检测 AI 是否失败
    final aiError =
        aiSummary?['ai_error'] as String? ?? aiSummary?['error'] as String?;
    final visibleEntries = _visibleAiEntries(aiSummary);
    final hasValidSummary = visibleEntries.isNotEmpty;

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
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
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
            Text('AI 提取信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visibleEntries
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
          Text('候选提醒', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CandidateEventList(
            memberId: memberId,
            candidates: candidates,
          ),
          const SizedBox(height: 16),
          Text('OCR 原文', style: Theme.of(context).textTheme.titleMedium),
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

  static List<MapEntry<String, dynamic>> _visibleAiEntries(
    Map<String, dynamic>? summary,
  ) {
    if (summary == null || summary.isEmpty) return [];
    return summary.entries.where((entry) {
      if (_hiddenKeys.contains(entry.key)) return false;
      final value = entry.value;
      if (value == null) return false;
      if (value is List && value.isEmpty) return false;
      if (value is String && value.trim().isEmpty) return false;
      return true;
    }).toList();
  }

  static List<Map<String, dynamic>> _candidateEvents(
    Map<String, dynamic> result,
  ) {
    final raw = result['candidate_events'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

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
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
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
        return e.toString();
      }).join('\n');
    }
    return v.toString();
  }
}
