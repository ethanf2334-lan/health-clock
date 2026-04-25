import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/models/document.dart';
import '../data/document_repository.dart';
import '../providers/document_provider.dart';
import 'candidate_event_list.dart';

/// 文档详情页：显示元信息、图片预览、OCR/AI摘要，支持原文查看和删除。
class DocumentDetailScreen extends ConsumerWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_documentDetailProvider(documentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('文档详情'),
        actions: [
          detailAsync.whenOrNull(
                data: (doc) => IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: '删除文档',
                  onPressed: () => _confirmDelete(context, ref, doc),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: detailAsync.when(
        data: (doc) => _buildBody(context, ref, doc),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HealthDocument doc) {
    final isImage = doc.mimeType.startsWith('image/');
    final isPdf = doc.mimeType == 'application/pdf';
    final dateText = doc.documentDate != null
        ? DateFormat('yyyy-MM-dd').format(doc.documentDate!.toLocal())
        : DateFormat('yyyy-MM-dd').format(doc.createdAt.toLocal());
    final aiEntries = _visibleAiEntries(doc);
    final candidateEvents = _candidateEvents(doc);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 图片预览
        if (isImage && doc.downloadUrl != null) ...[
          _buildImagePreview(doc.downloadUrl!),
          const SizedBox(height: 16),
        ],

        // PDF / 文件打开按钮
        if ((isPdf || doc.downloadUrl != null)) ...[
          OutlinedButton.icon(
            onPressed: () => _openInBrowser(context, doc),
            icon: Icon(isPdf ? Icons.picture_as_pdf : Icons.open_in_new),
            label: Text(isPdf ? '在浏览器中打开 PDF' : '查看原文件'),
          ),
          const SizedBox(height: 16),
        ],

        // 基本信息
        _section(
          context,
          '文档信息',
          [
            _infoRow('标题', doc.title ?? doc.fileName),
            _infoRow('分类', _categoryLabel(doc.category)),
            if (doc.hospitalName != null) _infoRow('医院', doc.hospitalName!),
            _infoRow('日期', dateText),
            _infoRow('文件名', doc.fileName),
            _infoRow('大小', _formatSize(doc.fileSize)),
          ],
        ),
        const SizedBox(height: 16),

        // AI 摘要
        if (aiEntries.isNotEmpty) ...[
          _section(
            context,
            'AI 提取信息',
            aiEntries
                .map((e) => _infoRow(_labelKey(e.key), _formatValue(e.value)))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // 候选提醒
        if (candidateEvents.isNotEmpty) ...[
          Text('候选提醒', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CandidateEventList(
            memberId: doc.memberId,
            candidates: candidateEvents,
            showEmptyState: false,
          ),
          const SizedBox(height: 16),
        ],

        // OCR 全文
        if (doc.ocrText != null && doc.ocrText!.isNotEmpty) ...[
          Text('OCR 识别文本', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                doc.ocrText!,
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InteractiveViewer(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => const SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, dynamic>> _visibleAiEntries(HealthDocument doc) {
    final summary = doc.aiSummary;
    if (summary == null || summary.isEmpty) return [];

    const hidden = {'candidate_events', 'raw_text', 'error', 'ai_error'};
    return summary.entries.where((entry) {
      if (hidden.contains(entry.key)) return false;
      final value = entry.value;
      if (value == null) return false;
      if (value is List && value.isEmpty) return false;
      if (value is String && value.trim().isEmpty) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _candidateEvents(HealthDocument doc) {
    final raw = doc.aiSummary?['candidate_events'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _openInBrowser(BuildContext context, HealthDocument doc) async {
    final url = doc.downloadUrl ?? doc.fileUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文件链接不可用')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开文件，请复制链接手动访问')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    HealthDocument doc,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('该文档及云端文件将被删除，无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(documentRepositoryProvider).deleteDocument(doc.id);
      await ref.read(documentListProvider.notifier).refresh();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  String _categoryLabel(String c) {
    const m = {
      'checkup_report': '体检报告',
      'examination_result': '检查结果',
      'outpatient_record': '门诊病历',
      'lab_report': '化验报告',
      'prescription': '处方',
      'hospitalization_record': '住院记录',
      'other': '其他',
    };
    return m[c] ?? c;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  String _labelKey(String k) {
    const m = {
      'hospital_name': '医院',
      'department': '科室',
      'document_date': '日期',
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
      'raw_text': '原文',
      'error': '解析状态',
    };
    return m[k] ?? k;
  }

  String _formatValue(dynamic v) {
    if (v == null) return '';
    if (v is List) {
      return v.map((e) {
        if (e is Map) {
          final s = e['suggestion'] ?? e['name'] ?? '';
          final extra = e['time_expression'] ?? e['flag'] ?? '';
          return extra.toString().isNotEmpty ? '$s（$extra）' : s.toString();
        }
        return e.toString();
      }).join('\n');
    }
    if (v is Map) {
      return v.entries.map((e) => '${e.key}: ${e.value}').join('、');
    }
    return v.toString();
  }
}

/// 文档详情 Provider（从后端拉取含 download_url 的完整信息）
final _documentDetailProvider =
    FutureProvider.family<HealthDocument, String>((ref, id) async {
  final repo = ref.read(documentRepositoryProvider);
  return repo.getDocument(id);
});
