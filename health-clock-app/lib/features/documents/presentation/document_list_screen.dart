import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/document.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/document_provider.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() =>
      _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
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
    ref.listen(currentMemberIdProvider, (_, next) {
      ref.read(documentListProvider.notifier).setMemberFilter(next);
    });
    final docsAsync = ref.watch(documentListProvider);

    return docsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 72, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('还没有文档', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/documents/new'),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('上传文档'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(documentListProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: docs.length,
            itemBuilder: (_, i) => _tile(docs[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败：$e')),
    );
  }

  Widget _tile(HealthDocument d) {
    final dateText = d.documentDate != null
        ? DateFormat('yyyy-MM-dd').format(d.documentDate!.toLocal())
        : DateFormat('yyyy-MM-dd').format(d.createdAt.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _icon(d.mimeType),
        title: Text(d.title ?? d.fileName),
        subtitle: Text(
          [
            _categoryLabel(d.category),
            if (d.hospitalName != null) d.hospitalName!,
            dateText,
          ].join('  ·  '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'delete') {
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
                      child: const Text('删除'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(documentListProvider.notifier).delete(d.id);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
      ),
    );
  }

  Icon _icon(String mime) {
    if (mime == 'application/pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    }
    return const Icon(Icons.image);
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
}
