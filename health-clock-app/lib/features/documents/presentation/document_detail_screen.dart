import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: detailAsync.when(
          data: (doc) => _buildBody(context, ref, doc),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: '加载失败：$e'),
        ),
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
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingL + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _DetailHeader(
          title: doc.title ?? doc.fileName,
          subtitle: '${_categoryLabel(doc.category)} · $dateText',
          icon: _iconFor(doc.category),
          iconColor: _colorFor(doc.category),
          iconBg: _bgFor(doc.category),
          tagLabel: _categoryLabel(doc.category),
          onBack: () {
            if (context.canPop()) context.pop();
          },
          onDelete: () => _confirmDelete(context, ref, doc),
        ),
        const SizedBox(height: AppStyles.spacingM),
        if (isImage && doc.downloadUrl != null) ...[
          _buildImagePreview(doc.downloadUrl!),
          const SizedBox(height: AppStyles.spacingM),
        ],
        if ((isPdf || doc.downloadUrl != null)) ...[
          _OpenFileCard(
            isPdf: isPdf,
            fileName: doc.fileName,
            fileSize: _formatSize(doc.fileSize),
            onTap: () => _openInBrowser(context, doc),
          ),
          const SizedBox(height: AppStyles.spacingM),
        ],
        _InfoSection(
          title: '文档信息',
          icon: Icons.description_outlined,
          rows: [
            _InfoItem('标题', doc.title ?? doc.fileName),
            _InfoItem('分类', _categoryLabel(doc.category)),
            if (doc.hospitalName != null) _InfoItem('医院', doc.hospitalName!),
            _InfoItem('日期', dateText),
            _InfoItem('文件名', doc.fileName),
            _InfoItem('大小', _formatSize(doc.fileSize)),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        if (aiEntries.isNotEmpty) ...[
          _InfoSection(
            title: 'AI 提取信息',
            icon: Icons.auto_awesome_rounded,
            accentColor: AppColors.lavender,
            accentBg: AppColors.lavenderSoft,
            rows: aiEntries
                .map((e) => _InfoItem(_labelKey(e.key), _formatValue(e.value)))
                .toList(),
          ),
          const SizedBox(height: AppStyles.spacingM),
        ],
        if (candidateEvents.isNotEmpty) ...[
          _SectionShell(
            title: '候选提醒',
            icon: Icons.notifications_active_outlined,
            child: CandidateEventList(
              memberId: doc.memberId,
              candidates: candidateEvents,
              showEmptyState: false,
            ),
          ),
          const SizedBox(height: AppStyles.spacingM),
        ],
        if (doc.ocrText != null && doc.ocrText!.isNotEmpty) ...[
          _SectionShell(
            title: 'OCR 识别文本',
            icon: Icons.document_scanner_outlined,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.spacingM),
              child: SelectableText(
                doc.ocrText!,
                style: AppStyles.footnote.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 220,
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
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除文档')),
      );
      try {
        await ref.read(documentListProvider.notifier).delete(doc.id);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
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

  IconData _iconFor(String category) {
    switch (category) {
      case 'checkup_report':
      case 'lab_report':
        return Icons.assignment_rounded;
      case 'examination_result':
        return Icons.biotech_rounded;
      case 'outpatient_record':
        return Icons.local_hospital_rounded;
      case 'prescription':
        return Icons.medication_liquid_rounded;
      case 'hospitalization_record':
        return Icons.hotel_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'checkup_report':
        return AppColors.mintDeep;
      case 'examination_result':
      case 'lab_report':
        return AppColors.careBlue;
      case 'outpatient_record':
        return AppColors.lavender;
      case 'prescription':
        return AppColors.warmAmber;
      case 'hospitalization_record':
        return AppColors.rose;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _bgFor(String category) {
    switch (category) {
      case 'checkup_report':
        return AppColors.mintBg;
      case 'examination_result':
      case 'lab_report':
        return AppColors.careBlueSoft;
      case 'outpatient_record':
        return AppColors.lavenderSoft;
      case 'prescription':
        return AppColors.amberSoft;
      case 'hospitalization_record':
        return AppColors.roseSoft;
      default:
        return AppColors.lightSurface;
    }
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.tagLabel,
    required this.onBack,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String tagLabel;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              onTap: onBack,
            ),
            const SizedBox(width: AppStyles.spacingS),
            Expanded(
              child: Text(
                '文档详情',
                style: AppStyles.screenTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _CircleIconButton(
              icon: Icons.delete_outline_rounded,
              color: AppColors.danger,
              bg: AppColors.coralSoft.withValues(alpha: 0.55),
              onTap: onDelete,
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingM),
        Container(
          padding: const EdgeInsets.all(AppStyles.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            border: Border.all(color: AppColors.lightOutline),
            boxShadow: AppStyles.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.subhead.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppStyles.spacingS),
                        _SmallTag(
                          label: tagLabel,
                          color: iconColor,
                          bg: iconBg,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingXs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.footnote.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.bg = Colors.white,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppStyles.minTouchTarget,
          height: AppStyles.minTouchTarget,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: AppStyles.subtleShadow,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenFileCard extends StatelessWidget {
  const _OpenFileCard({
    required this.isPdf,
    required this.fileName,
    required this.fileSize,
    required this.onTap,
  });

  final bool isPdf;
  final String fileName;
  final String fileSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isPdf ? AppColors.coral : AppColors.careBlue;
    final bg = isPdf ? AppColors.coralSoft : AppColors.careBlueSoft;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppStyles.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            border: Border.all(color: AppColors.lightOutline),
            boxShadow: AppStyles.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : Icons.open_in_new,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPdf ? '打开 PDF 原件' : '查看原文件',
                      style: AppStyles.subhead.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingXs),
                    Text(
                      '$fileName · $fileSize',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.footnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.icon,
    required this.child,
    this.accentColor = AppColors.mintDeep,
    this.accentBg = AppColors.mintBg,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color accentColor;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.spacingM,
              AppStyles.spacingM,
              AppStyles.spacingM,
              AppStyles.spacingS,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.subhead.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.accentColor = AppColors.mintDeep,
    this.accentBg = AppColors.mintBg,
  });

  final String title;
  final IconData icon;
  final List<_InfoItem> rows;
  final Color accentColor;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: title,
      icon: icon,
      accentColor: accentColor,
      accentBg: accentBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppStyles.spacingM,
          0,
          AppStyles.spacingM,
          AppStyles.spacingS,
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _InfoRow(item: rows[i]),
              if (i != rows.length - 1)
                const Divider(
                  height: AppStyles.dividerThin,
                  color: AppColors.lightDivider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              item.label,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: Text(
              item.value,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
      ),
      child: Text(
        label,
        style: AppStyles.caption1.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppStyles.subhead.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// 文档详情 Provider（从后端拉取含 download_url 的完整信息）
final _documentDetailProvider =
    FutureProvider.family<HealthDocument, String>((ref, id) async {
  final repo = ref.read(documentRepositoryProvider);
  return repo.getDocument(id);
});
