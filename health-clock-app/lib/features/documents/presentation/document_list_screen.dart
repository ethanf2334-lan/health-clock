import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/models/document.dart';
import '../../members/providers/current_member_provider.dart';
import '../../members/providers/member_provider.dart';
import '../providers/document_provider.dart';
import 'widgets/document_list_tile_card.dart';
import 'widgets/documents_filter_bar.dart';
import 'widgets/documents_header.dart';
import 'widgets/documents_overview_card.dart';
import 'widgets/documents_subheader.dart';
import 'widgets/documents_upload_actions.dart';

enum _SortMode { recent, oldest, hospital }

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  String _filter = 'all';
  _SortMode _sort = _SortMode.recent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ref.read(currentMemberIdProvider);
      ref.read(documentListProvider.notifier).setMemberFilter(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    ref.listen(currentMemberIdProvider, (_, next) {
      ref.read(documentListProvider.notifier).setMemberFilter(next);
    });
    final docsAsync = ref.watch(documentListProvider);
    final membersAsync = ref.watch(memberListProvider);

    final allDocs = docsAsync.maybeWhen(
      data: (d) => d,
      orElse: () => const <HealthDocument>[],
    );

    final currentMemberName = membersAsync.maybeWhen(
      data: (members) {
        final id = ref.watch(currentMemberIdProvider);
        for (final m in members) {
          if (m.id == id) return m.name;
        }
        return members.isEmpty ? '当前成员' : members.first.name;
      },
      orElse: () => '当前成员',
    );

    final counts = _categoryCounts(allDocs);
    final filtered = _applyFilter(allDocs);
    final sorted = _applySort(filtered);
    final overview = _overviewStats(allDocs);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        DocumentsHeader(
          title: '健康档案',
          subtitle: '共整理 ${allDocs.length} 份健康文档',
          onUpload: () => context.push('/documents/new'),
        ),
        DocumentsSubheader(counts: counts),
        DocumentsOverviewCard(
          title: '已为$currentMemberName整理好近期健康资料',
          subtitle: '支持 OCR 识别、AI 摘要与候选提醒提取',
          newCount: overview.newCount,
          pendingReview: overview.pendingReview,
          candidateReminders: overview.candidateReminders,
        ),
        DocumentsFilterBar(
          filters: const [
            DocFilterItem(label: '全部', value: 'all'),
            DocFilterItem(label: '报告', value: 'report'),
            DocFilterItem(label: '检查', value: 'exam'),
            DocFilterItem(label: '病历', value: 'medical'),
            DocFilterItem(label: '处方', value: 'prescription'),
          ],
          selected: _filter,
          onSelected: (v) => setState(() => _filter = v),
          sortLabel: _sortLabel(_sort),
          onSortTap: _showSortSheet,
        ),
        _buildSectionHeader(),
        if (docsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (docsAsync.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('加载失败：${docsAsync.error}'),
          )
        else if (sorted.isEmpty)
          _buildEmpty(context)
        else
          ...sorted.map(
            (d) => DocumentListTileCard(
              title: _displayTitle(d),
              hospital: d.hospitalName,
              dateText: _formatDate(d),
              belongTo: _memberName(membersAsync, d.memberId),
              statusText: _statusText(d),
              icon: _iconFor(d.category),
              iconColor: _colorFor(d.category),
              iconBg: _bgFor(d.category),
              tagLabel: _tagLabel(d.category),
              tagColor: _colorFor(d.category),
              tagBg: _bgFor(d.category),
              onTap: () => context.push('/documents/${d.id}'),
              onLongPress: () => _showDocOptions(d),
            ),
          ),
        const SizedBox(height: 4),
        DocumentsUploadActions(
          onCamera: () => context.push('/documents/new?source=camera'),
          onGallery: () => context.push('/documents/new?source=gallery'),
          onFile: () => context.push('/documents/new?source=file'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '文档列表',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '管理',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 36,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 8),
              Text(
                '暂无文档',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '可以从下方拍照、相册或文件上传',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- 数据工具 ----------

  String _categoryGroup(String category) {
    switch (category) {
      case 'checkup_report':
        return 'exam';
      case 'lab_report':
      case 'examination_result':
        return 'report';
      case 'outpatient_record':
      case 'hospitalization_record':
        return 'medical';
      case 'prescription':
        return 'prescription';
      default:
        return 'other';
    }
  }

  List<DocCategoryCount> _categoryCounts(List<HealthDocument> docs) {
    int report = 0;
    int exam = 0;
    int medical = 0;
    int prescription = 0;
    for (final d in docs) {
      final group = _categoryGroup(d.category);
      switch (group) {
        case 'report':
          report++;
          break;
        case 'exam':
          exam++;
          break;
        case 'medical':
          medical++;
          break;
        case 'prescription':
          prescription++;
          break;
      }
    }
    return [
      DocCategoryCount(label: '报告', count: report, color: AppColors.careBlue),
      DocCategoryCount(label: '检查', count: exam, color: AppColors.warmAmber),
      DocCategoryCount(label: '病历', count: medical, color: AppColors.rose),
      DocCategoryCount(
        label: '处方',
        count: prescription,
        color: AppColors.lavender,
      ),
    ];
  }

  List<HealthDocument> _applyFilter(List<HealthDocument> docs) {
    if (_filter == 'all') return docs;
    return docs.where((d) => _categoryGroup(d.category) == _filter).toList();
  }

  List<HealthDocument> _applySort(List<HealthDocument> docs) {
    final list = [...docs];
    switch (_sort) {
      case _SortMode.recent:
        list.sort((a, b) => _docDate(b).compareTo(_docDate(a)));
        break;
      case _SortMode.oldest:
        list.sort((a, b) => _docDate(a).compareTo(_docDate(b)));
        break;
      case _SortMode.hospital:
        list.sort(
          (a, b) => (a.hospitalName ?? '').compareTo(b.hospitalName ?? ''),
        );
        break;
    }
    return list;
  }

  DateTime _docDate(HealthDocument d) =>
      d.documentDate ?? d.createdAt;

  _OverviewStats _overviewStats(List<HealthDocument> docs) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final newThisMonth =
        docs.where((d) => d.createdAt.toLocal().isAfter(monthStart)).length;
    final pending = docs.where((d) => d.ocrText == null || d.ocrText!.isEmpty)
        .length;
    final candidate = docs
        .where((d) => d.aiSummary != null && d.aiSummary!.isNotEmpty)
        .length;
    return _OverviewStats(
      newCount: newThisMonth,
      pendingReview: pending,
      candidateReminders: candidate,
    );
  }

  String _displayTitle(HealthDocument d) {
    final t = d.title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final dateStr = DateFormat('yyyy/MM/dd').format(_docDate(d).toLocal());
    return '${_categoryNameOf(d.category)} $dateStr';
  }

  String _formatDate(HealthDocument d) {
    return DateFormat('yyyy/MM/dd').format(_docDate(d).toLocal());
  }

  String _statusText(HealthDocument d) {
    if (d.aiSummary != null && d.aiSummary!.isNotEmpty) {
      return '已识别摘要与候选提醒';
    }
    if (d.ocrText != null && d.ocrText!.isNotEmpty) return 'OCR 已完成';
    return '上传成功，等待识别';
  }

  String _memberName(AsyncValue membersAsync, String memberId) {
    return membersAsync.maybeWhen(
      data: (members) {
        for (final m in members) {
          if (m.id == memberId) return m.name as String;
        }
        return '未知成员';
      },
      orElse: () => '加载中',
    );
  }

  String _categoryNameOf(String c) {
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

  String _tagLabel(String c) {
    final group = _categoryGroup(c);
    switch (group) {
      case 'report':
        return '报告';
      case 'exam':
        return '体检';
      case 'medical':
        return '病历';
      case 'prescription':
        return '处方';
      default:
        return '其他';
    }
  }

  IconData _iconFor(String c) {
    final group = _categoryGroup(c);
    switch (group) {
      case 'report':
        return Icons.science_rounded;
      case 'exam':
        return Icons.medical_services_rounded;
      case 'medical':
        return Icons.description_rounded;
      case 'prescription':
        return Icons.medication_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _colorFor(String c) {
    final group = _categoryGroup(c);
    switch (group) {
      case 'report':
        return AppColors.careBlue;
      case 'exam':
        return AppColors.warmAmber;
      case 'medical':
        return AppColors.rose;
      case 'prescription':
        return AppColors.lavender;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _bgFor(String c) {
    final group = _categoryGroup(c);
    switch (group) {
      case 'report':
        return AppColors.careBlueSoft;
      case 'exam':
        return AppColors.amberSoft;
      case 'medical':
        return AppColors.roseSoft;
      case 'prescription':
        return AppColors.lavenderSoft;
      default:
        return AppColors.lightDivider;
    }
  }

  String _sortLabel(_SortMode m) {
    switch (m) {
      case _SortMode.recent:
        return '最近';
      case _SortMode.oldest:
        return '最早';
      case _SortMode.hospital:
        return '医院';
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Text(
                  '排序方式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final mode in _SortMode.values)
                ListTile(
                  title: Text(_sortLabel(mode)),
                  trailing: _sort == mode
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mintDeep,
                        )
                      : null,
                  onTap: () {
                    setState(() => _sort = mode);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDocOptions(HealthDocument d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_rounded),
              title: const Text('查看详情'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/documents/${d.id}');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: const Text(
                '删除',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('该文档及云端文件将被删除。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          '删除',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  try {
                    await ref
                        .read(documentListProvider.notifier)
                        .delete(d.id);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('删除失败：$e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStats {
  const _OverviewStats({
    required this.newCount,
    required this.pendingReview,
    required this.candidateReminders,
  });
  final int newCount;
  final int pendingReview;
  final int candidateReminders;
}
