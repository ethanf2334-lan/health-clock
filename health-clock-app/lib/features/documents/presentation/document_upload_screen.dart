import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../shared/models/document.dart';
import '../../members/presentation/member_picker_field.dart';
import '../../members/providers/current_member_provider.dart';
import '../data/document_repository.dart';
import '../providers/document_provider.dart';
import 'ocr_review_screen.dart';

const _categories = [
  {'value': 'checkup_report', 'label': '体检报告'},
  {'value': 'examination_result', 'label': '检查结果'},
  {'value': 'outpatient_record', 'label': '门诊病历'},
  {'value': 'lab_report', 'label': '化验报告'},
  {'value': 'prescription', 'label': '处方'},
  {'value': 'hospitalization_record', 'label': '住院记录'},
  {'value': 'other', 'label': '其他'},
];

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  File? _file;
  String? _mimeType;
  String? _memberId;
  String _category = 'checkup_report';
  final _titleController = TextEditingController();
  final _hospitalController = TextEditingController();
  DateTime? _docDate;
  bool _uploading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _pickFromFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (res != null && res.files.single.path != null) {
      final path = res.files.single.path!;
      final ext = p.extension(path).toLowerCase();
      String mime;
      if (ext == '.pdf') {
        mime = 'application/pdf';
      } else if (ext == '.png') {
        mime = 'image/png';
      } else {
        mime = 'image/jpeg';
      }
      setState(() {
        _file = File(path);
        _mimeType = mime;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pick = await picker.pickImage(source: source, imageQuality: 85);
    if (pick != null) {
      setState(() {
        _file = File(pick.path);
        _mimeType = 'image/jpeg';
      });
    }
  }

  Future<void> _submit() async {
    if (_memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择成员')),
      );
      return;
    }
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择文件')),
      );
      return;
    }

    setState(() {
      _uploading = true;
      _status = '正在申请上传地址…';
    });

    try {
      final repo = ref.read(documentRepositoryProvider);
      final fileSize = await _file!.length();
      final fileName = p.basename(_file!.path);

      final sig = await repo.getUploadSignature(
        UploadSignatureRequest(
          memberId: _memberId!,
          fileName: fileName,
          fileSize: fileSize,
          mimeType: _mimeType!,
        ),
      );

      setState(() => _status = '正在上传文件…');
      await repo.putFileToSignedUrl(sig.uploadUrl, _file!, _mimeType!);

      setState(() => _status = '正在保存文档信息…');
      final doc = await repo.createDocument(
        DocumentCreate(
          memberId: _memberId!,
          fileName: fileName,
          fileSize: fileSize,
          mimeType: _mimeType!,
          category: _category,
          title: _documentTitle(),
          hospitalName: _hospitalController.text.trim().isEmpty
              ? null
              : _hospitalController.text.trim(),
          documentDate: _docDate,
          fileUrl: sig.fileUrl,
          storageBucket: 'health-clock-files',
          storageKey: sig.objectKey,
        ),
      );

      setState(() => _status = '正在进行 OCR 识别…');
      Map<String, dynamic>? ocrResult;
      try {
        ocrResult = await repo.processOcr(doc.id);
      } catch (_) {
        // OCR 失败不影响文档本身的保存
      }

      await ref.read(documentListProvider.notifier).refresh();

      if (!mounted) return;
      if (ocrResult != null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OcrReviewScreen(
              memberId: _memberId!,
              ocrResult: ocrResult!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文档已上传，但 OCR 暂时不可用')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('上传失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    ref.listen(currentMemberIdProvider, (_, next) {
      if (_memberId == null && next != null) {
        setState(() => _memberId = next);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('上传文档')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MemberPickerField(
            value: _memberId,
            onChanged: (v) => setState(() => _memberId = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: '分类'),
            items: _categories
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e['value'],
                    child: Text(e['label']!),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '标题（可选）'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hospitalController,
            decoration: const InputDecoration(labelText: '医院名称（可选）'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('文档日期'),
            subtitle: Text(
              _docDate == null
                  ? '未设置'
                  : '${_docDate!.year}-${_docDate!.month.toString().padLeft(2, '0')}-${_docDate!.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _docDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (d != null) setState(() => _docDate = d);
            },
          ),
          const Divider(),
          if (_file != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(
                  _shortFileName(_file!.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_mimeType ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _file = null;
                    _mimeType = null;
                  }),
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    _uploading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('拍照'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _uploading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('相册'),
              ),
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickFromFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('选择文件'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_uploading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(_status, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: _uploading ? null : _submit,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('上传并识别'),
          ),
        ],
      ),
    );
  }

  String _documentTitle() {
    final input = _titleController.text.trim();
    if (input.isNotEmpty) return input;
    final date = _docDate ?? DateTime.now();
    return '${_categoryLabel(_category)} ${_formatDate(date)}';
  }

  String _shortFileName(String path) {
    final fileName = p.basename(path);
    if (!fileName.toLowerCase().startsWith('image_picker_')) return fileName;
    final ext = p.extension(fileName).isEmpty ? '.jpg' : p.extension(fileName);
    return '拍照/相册图片$ext';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _categoryLabel(String value) {
    return _categories.firstWhere(
      (item) => item['value'] == value,
      orElse: () => const {'value': 'other', 'label': '其他'},
    )['label']!;
  }
}
