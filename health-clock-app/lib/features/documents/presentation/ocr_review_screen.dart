import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../members/presentation/widgets/member_avatar.dart';
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
    final fileName = (ocrResult['file_name'] ??
            ocrResult['document_title'] ??
            aiSummary?['report_name'] ??
            '已上传文件')
        .toString();
    final uploadTime = _formatUploadTime(ocrResult['uploaded_at']);
    final sourceLabel = (ocrResult['source_label'] ?? '上传文件').toString();
    final statusLabel = aiError == null ? '成功' : '部分成功';
    final resultItems = _resultItems(aiSummary, ocrResult);
    final summaryText = _summaryText(aiSummary, ocrText);
    final metricCards = _metricCards(aiSummary, ocrText);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.chevron_left_rounded, size: 34),
                    ),
                  ),
                  const Text(
                    'OCR 识别',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Text(
                        '完成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  const _OcrProgressCard(),
                  const SizedBox(height: 12),
                  _OcrFileCard(
                    fileName: fileName,
                    uploadTime: uploadTime,
                    sourceLabel: sourceLabel,
                    statusLabel: statusLabel,
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: '识别结果'),
                  const SizedBox(height: 8),
                  _ResultGrid(items: resultItems),
                  const SizedBox(height: 10),
                  _AiSummaryCard(summary: summaryText),
                  const SizedBox(height: 16),
                  _MetricsExtracted(metrics: metricCards),
                  const SizedBox(height: 16),
                  _ReminderCandidates(candidates: candidates),
                  if (aiError != null ||
                      hasValidSummary ||
                      candidates.isNotEmpty)
                    const SizedBox(height: 1),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 126,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0BA84A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        '重新识别',
                        style: TextStyle(
                          color: Color(0xFF0BA84A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF08A84F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          '确认并生成档案',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Legacy fallback kept below for non-designed/debug contexts.
    // ignore: dead_code
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

  static String _formatUploadTime(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value)?.toLocal();
      if (parsed != null) {
        return '今天 ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
    }
    return '刚刚';
  }

  static List<_ResultItem> _resultItems(
    Map<String, dynamic>? summary,
    Map<String, dynamic> result,
  ) {
    String pick(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = result[key] ?? summary?[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    return [
      _ResultItem(
        '文档类型',
        pick(['document_type', 'document_category', 'report_name'], '未识别'),
        Icons.description_rounded,
        AppColors.lavender,
      ),
      _ResultItem(
        '就诊机构',
        pick(['hospital_name', 'organization', 'institution'], '未识别'),
        Icons.apartment_rounded,
        AppColors.careBlue,
      ),
      _ResultItem(
        '就诊日期',
        pick(['document_date', 'report_date', 'visit_date'], '未识别'),
        Icons.calendar_month_rounded,
        AppColors.mintDeep,
      ),
      _ResultItem(
        '归属成员',
        pick(['member_name', 'patient_name'], '当前成员'),
        Icons.person_rounded,
        AppColors.mintDeep,
      ),
    ];
  }

  static String _summaryText(Map<String, dynamic>? summary, String ocrText) {
    final candidates = [
      summary?['summary'],
      summary?['ai_summary'],
      summary?['conclusion'],
      summary?['diagnosis'],
      summary?['examination_findings'],
    ];
    for (final value in candidates) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    final compact = ocrText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.isNotEmpty) {
      return compact.length > 120 ? '${compact.substring(0, 120)}…' : compact;
    }
    return 'OCR 已完成，暂未提取到可展示的摘要内容。';
  }

  static List<_MetricCardData> _metricCards(
    Map<String, dynamic>? summary,
    String ocrText,
  ) {
    final cards = <_MetricCardData>[];
    void add(String label, String value, String unit, Color color, String tag) {
      if (value.trim().isEmpty) return;
      cards.add(
        _MetricCardData(
          label: label,
          value: value,
          unit: unit,
          color: color,
          tag: tag,
        ),
      );
    }

    final structured = summary?['metrics'] ?? summary?['examination_items'];
    if (structured is List) {
      for (final item in structured.whereType<Map>()) {
        final label =
            (item['name'] ?? item['label'] ?? item['item'] ?? '指标').toString();
        final value = (item['value'] ?? item['result'] ?? '').toString();
        final unit = (item['unit'] ?? '').toString();
        add(label, value, unit, AppColors.mintDeep, '已提取');
      }
    }

    final text = [
      ocrText,
      if (summary != null) summary.values.join(' '),
    ].join(' ');
    final bp = RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})').firstMatch(text);
    if (bp != null) {
      add(
        '血压',
        '${bp.group(1)}/${bp.group(2)}',
        'mmHg',
        AppColors.mintDeep,
        '已提取',
      );
    }
    final sugar =
        RegExp(r'(?:血糖|GLU|葡萄糖)[^\d]*(\d+(?:\.\d+)?)').firstMatch(text);
    if (sugar != null) {
      add('血糖', sugar.group(1)!, 'mmol/L', AppColors.lavender, '已提取');
    }
    final weight =
        RegExp(r'(?:体重|weight)[^\d]*(\d+(?:\.\d+)?)', caseSensitive: false)
            .firstMatch(text);
    if (weight != null) {
      add('体重', weight.group(1)!, 'kg', AppColors.warmAmber, '已提取');
    }
    final cholesterol =
        RegExp(r'(?:总胆固醇|TC)[^\d]*(\d+(?:\.\d+)?)').firstMatch(text);
    if (cholesterol != null) {
      add(
        '总胆固醇',
        cholesterol.group(1)!,
        'mmol/L',
        AppColors.mintDeep,
        '已提取',
      );
    }

    final seen = <String>{};
    return cards
        .where((card) => seen.add('${card.label}:${card.value}'))
        .take(6)
        .toList();
  }
}

class _ResultItem {
  const _ResultItem(this.label, this.value, this.icon, this.color);
  factory _ResultItem.empty() => const _ResultItem(
        '项目',
        '未识别',
        Icons.info_outline,
        AppColors.textTertiary,
      );

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCardData {
  const _MetricCardData({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.tag,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final String tag;
}

class _OcrProgressCard extends StatelessWidget {
  const _OcrProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.mintBg.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.mintDeep,
                  size: 48,
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '识别完成',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B8F45),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '已提取文档内容，并生成结构化信息与提醒候选项',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _StepNode(done: true, label: '上传文件')),
              Expanded(child: _StepLine()),
              Expanded(
                child: _StepNode(done: false, number: '2', label: 'OCR识别'),
              ),
              Expanded(child: _StepLine()),
              Expanded(child: _StepNode(done: true, label: '整理归档')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.label, this.done = false, this.number});
  final String label;
  final bool done;
  final String? number;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.mintDeep,
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
              : Text(
                  number ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.mintDeep,
    );
  }
}

class _OcrFileCard extends StatelessWidget {
  const _OcrFileCard({
    required this.fileName,
    required this.uploadTime,
    required this.sourceLabel,
    required this.statusLabel,
  });

  final String fileName;
  final String uploadTime;
  final String sourceLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 132,
            height: 168,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightOutline),
            ),
            child: const Column(
              children: [
                Text('健康体检报告', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 18),
                Expanded(child: _TinyReportCover()),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FileMeta('文件名：', fileName),
                _FileMeta('上传时间：', uploadTime),
                _FileMeta('来源：', sourceLabel),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '识别状态：',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mintBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.mintDeep,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('查看原文'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.lightOutline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileMeta extends StatelessWidget {
  const _FileMeta(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyReportCover extends StatelessWidget {
  const _TinyReportCover();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(7, (i) {
        return Container(
          height: 6,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.careBlue : AppColors.lightOutline,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid({required this.items});

  final List<_ResultItem> items;

  @override
  Widget build(BuildContext context) {
    final displayItems = items.length >= 4
        ? items.take(4).toList()
        : [
            ...items,
            ...List.generate(4 - items.length, (_) => _ResultItem.empty()),
          ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ResultCell(item: displayItems[0])),
            const SizedBox(width: 8),
            Expanded(child: _ResultCell(item: displayItems[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _ResultCell(item: displayItems[2])),
            const SizedBox(width: 8),
            Expanded(
              child: _ResultCell(
                item: displayItems[3],
                avatar: displayItems[3].label == '归属成员',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultCell extends StatelessWidget {
  const _ResultCell({required this.item, this.avatar = false});

  final _ResultItem item;
  final bool avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 20),
          const SizedBox(width: 7),
          Flexible(
            flex: 5,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 5),
          if (avatar) ...[
            const MemberAvatar(name: '妈妈', relation: 'mother', size: 24),
            const SizedBox(width: 4),
          ],
          Flexible(
            flex: 6,
            child: Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lavenderSoft.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lavender.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.lavender),
              SizedBox(width: 8),
              Text(
                'AI 摘要',
                style: TextStyle(
                  color: AppColors.lavender,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsExtracted extends StatelessWidget {
  const _MetricsExtracted({required this.metrics});

  final List<_MetricCardData> metrics;

  @override
  Widget build(BuildContext context) {
    final displayMetrics = metrics.isEmpty
        ? [
            const _MetricCardData(
              label: 'OCR文本',
              value: '已识别',
              unit: '',
              color: AppColors.mintDeep,
              tag: '待整理',
            ),
          ]
        : metrics;
    return Column(
      children: [
        _SectionHeader(title: '提取指标', trailing: '共提取 ${metrics.length} 项'),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayMetrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.28,
          ),
          itemBuilder: (context, index) {
            final metric = displayMetrics[index];
            return _MetricMiniCard(
              label: metric.label,
              value: metric.value,
              unit: metric.unit,
              color: metric.color,
              tag: metric.tag,
            );
          },
        ),
      ],
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.tag,
  });
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String tag;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: color, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            tag,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCandidates extends StatelessWidget {
  const _ReminderCandidates({required this.candidates});

  final List<Map<String, dynamic>> candidates;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: '提醒候选项', trailing: '共提取 ${candidates.length} 项'),
        const SizedBox(height: 8),
        if (candidates.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightOutline),
            ),
            child: const Text(
              '暂无提醒候选项',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          for (var i = 0; i < candidates.length; i++) ...[
            _CandidateTile(
              icon: _candidateIcon(candidates[i]),
              title: _candidateTitle(candidates[i]),
              subtitle: _candidateSubtitle(candidates[i]),
              tag: i == 0 ? '建议创建' : '待确认',
              selected: i == 0,
            ),
            if (i != candidates.length - 1) const SizedBox(height: 8),
          ],
      ],
    );
  }

  static String _candidateTitle(Map<String, dynamic> item) {
    return (item['event_title'] ?? item['title'] ?? item['name'] ?? '健康提醒')
        .toString();
  }

  static String _candidateSubtitle(Map<String, dynamic> item) {
    final suggestion = item['description'] ??
        item['suggestion'] ??
        item['time_expression'] ??
        item['scheduled_at'] ??
        '建议确认时间';
    return suggestion.toString();
  }

  static IconData _candidateIcon(Map<String, dynamic> item) {
    final type = (item['event_type'] ?? item['type'] ?? '').toString();
    if (type.contains('medication')) return Icons.medication_rounded;
    if (type.contains('follow') || type.contains('revisit')) {
      return Icons.calendar_month_rounded;
    }
    if (type.contains('check')) return Icons.medical_information_outlined;
    return Icons.event_available_rounded;
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.selected,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            selected ? AppColors.mintBg.withValues(alpha: 0.45) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                selected ? AppColors.mintBg : AppColors.lavenderSoft,
            child: Icon(
              icon,
              color: selected ? AppColors.mintDeep : AppColors.lavender,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? AppColors.mintBg : AppColors.lavenderSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: selected ? AppColors.mintDeep : AppColors.lavender,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.mintDeep : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
