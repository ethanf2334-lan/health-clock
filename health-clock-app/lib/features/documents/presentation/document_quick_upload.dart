import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../shared/models/document.dart';
import '../../members/providers/current_member_provider.dart';
import '../data/document_repository.dart';
import '../providers/document_provider.dart';
import 'ocr_review_screen.dart';

Future<void> pickFileAndUploadDocument({
  required BuildContext context,
  required WidgetRef ref,
  String? memberId,
  VoidCallback? onUploaded,
}) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  );
  final path = picked?.files.single.path;
  if (path == null) return;
  if (!context.mounted) return;

  await uploadPickedDocumentFile(
    context: context,
    ref: ref,
    file: File(path),
    mimeType: _mimeTypeForPath(path),
    sourceLabel: '本机存储',
    memberId: memberId,
    onUploaded: onUploaded,
  );
}

Future<void> uploadPickedDocumentFile({
  required BuildContext context,
  required WidgetRef ref,
  required File file,
  required String mimeType,
  required String sourceLabel,
  String? memberId,
  VoidCallback? onUploaded,
}) async {
  final targetMemberId = memberId ?? ref.read(currentMemberIdProvider);
  if (targetMemberId == null || targetMemberId.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请先选择成员')),
    );
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('正在上传并识别，请稍候...')),
    );

  try {
    final repo = ref.read(documentRepositoryProvider);
    final fileSize = await file.length();
    final fileName = _displayUploadFileName(file.path);
    final now = DateTime.now();

    final sig = await repo.getUploadSignature(
      UploadSignatureRequest(
        memberId: targetMemberId,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
      ),
    );
    await repo.putFileToSignedUrl(sig.uploadUrl, file, mimeType);

    final doc = await repo.createDocument(
      DocumentCreate(
        memberId: targetMemberId,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
        category: 'checkup_report',
        title: fileName,
        documentDate: now,
        fileUrl: sig.fileUrl,
        storageBucket: 'health-clock-files',
        storageKey: sig.objectKey,
      ),
    );

    final ocrResult = await repo.processOcr(doc.id);
    final enriched = {
      ...ocrResult,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': now.toIso8601String(),
      'source_label': sourceLabel,
      'document_title': doc.title ?? fileName,
      'document_category': doc.category,
      if (doc.documentDate != null)
        'document_date': DateFormat('yyyy-MM-dd').format(doc.documentDate!),
    };

    await ref.read(documentListProvider.notifier).refresh();
    onUploaded?.call();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OcrReviewScreen(
          memberId: targetMemberId,
          ocrResult: enriched,
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('上传识别失败：$e')));
  }
}

String _displayUploadFileName(String path) {
  final fileName = p.basename(path);
  if (!fileName.toLowerCase().startsWith('image_picker_')) return fileName;
  final ext = p.extension(fileName).isEmpty ? '.jpg' : p.extension(fileName);
  return '相册图片$ext';
}

String _mimeTypeForPath(String path) {
  final ext = p.extension(path).toLowerCase();
  if (ext == '.pdf') return 'application/pdf';
  if (ext == '.png') return 'image/png';
  return 'image/jpeg';
}
