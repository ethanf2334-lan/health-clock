import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../shared/models/document.dart';
import '../../../shared/widgets/app_cupertino_pickers.dart';
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
  const DocumentUploadScreen({super.key, this.source});

  final String? source;

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
  bool _autoPickerStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _memberId = ref.read(currentMemberIdProvider));
      _autoOpenSystemPickerIfNeeded();
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

  void _autoOpenSystemPickerIfNeeded() {
    if (_autoPickerStarted || widget.source != 'gallery') return;
    _autoPickerStarted = true;
    _pickAndSubmit(isFile: false);
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
        ocrResult = {
          ...ocrResult,
          'file_name': fileName,
          'file_size': fileSize,
          'mime_type': _mimeType,
          'uploaded_at': DateTime.now().toIso8601String(),
          'source_label': _sourceLabel(),
          'document_title': _documentTitle(),
          'document_category': _category,
          if (_hospitalController.text.trim().isNotEmpty)
            'hospital_name': _hospitalController.text.trim(),
          if (_docDate != null) 'document_date': _formatDate(_docDate!),
        };
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
    final source = widget.source ?? 'file';
    if (source == 'camera') return _buildCameraUpload(context);
    if (source == 'gallery') return _buildPickerGrid(context, isFile: false);
    if (source == 'file') return _buildPickerGrid(context, isFile: true);

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
            style: AppStyles.subhead.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(labelText: '标题（可选）'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hospitalController,
            style: AppStyles.subhead.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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
              final d = await AppCupertinoPickers.date(
                context: context,
                initialDate: _docDate ?? DateTime.now(),
                minimumDate: DateTime(2000),
                maximumDate: DateTime.now().add(const Duration(days: 1)),
                title: '选择文档日期',
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

  Widget _buildCameraUpload(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _UploadTopBar(
              title: '拍照上传',
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline_rounded, size: 29),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4B4538),
                            Color(0xFF7A6B55),
                          ],
                        ),
                      ),
                      child: CustomPaint(painter: _DeskPainter()),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '请将报告放入框内',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '支持自动裁边与文字识别',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 28,
                    right: 28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 440,
                          padding: const EdgeInsets.fromLTRB(34, 28, 34, 26),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF7),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 22,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const _ReportMockup(),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ScanFramePainter(),
                          ),
                        ),
                        Positioned(
                          top: -36,
                          right: -12,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.mintDeep,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  '已检测到报告',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 36,
                    right: 36,
                    bottom: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CameraTool(icon: Icons.crop_rounded, label: '自动裁边'),
                        _CameraTool(
                          icon: Icons.file_copy_outlined,
                          label: '多页拍摄',
                        ),
                        _CameraTool(
                          icon: Icons.document_scanner,
                          label: '识别报告',
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 26, 28, 82),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _GalleryThumb(),
                              InkWell(
                                onTap: _captureAndSubmit,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.mintDeep,
                                      width: 4,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.mintDeep,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.cameraswitch_rounded,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 17,
                                color: AppColors.mintDeep,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '拍摄清晰完整的报告照片，可自动生成档案与提醒候选项',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }

  Widget _buildPickerGrid(BuildContext context, {required bool isFile}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _UploadTopBar(
              title: isFile ? '选择文件' : '从相册选择',
              trailing: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: _SystemPickerPrompt(
                  isFile: isFile,
                  uploading: _uploading,
                  status: _status,
                  onPick: () => _pickAndSubmit(isFile: isFile),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      _uploading ? null : () => _pickAndSubmit(isFile: isFile),
                  icon: Icon(
                    isFile
                        ? Icons.folder_open_rounded
                        : Icons.photo_library_rounded,
                  ),
                  label: Text(
                    isFile ? '打开系统文件选择器' : '打开系统相册',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF08A84F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSubmit() async {
    await _pickImage(ImageSource.camera);
    if (_file != null) await _submit();
  }

  Future<void> _pickAndSubmit({required bool isFile}) async {
    if (isFile) {
      await _pickFromFile();
    } else {
      await _pickImage(ImageSource.gallery);
    }
    if (_file != null) await _submit();
  }

  String _sourceLabel() {
    switch (widget.source) {
      case 'camera':
        return '拍照上传';
      case 'gallery':
        return '相册选择';
      case 'file':
        return '本机存储';
      default:
        return '上传';
    }
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

class _UploadTopBar extends StatelessWidget {
  const _UploadTopBar({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
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
          Text(
            title,
            style: AppStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}

class _SystemPickerPrompt extends StatelessWidget {
  const _SystemPickerPrompt({
    required this.isFile,
    required this.uploading,
    required this.status,
    required this.onPick,
  });

  final bool isFile;
  final bool uploading;
  final String status;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppStyles.spacingL),
        decoration: BoxDecoration(
          color: AppColors.mintBg.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
          border: Border.all(color: AppColors.mintSoft),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppStyles.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintDeep.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, AppStyles.spacingS),
                  ),
                ],
              ),
              child: Icon(
                isFile
                    ? Icons.folder_open_rounded
                    : Icons.photo_library_rounded,
                color: AppColors.mintDeep,
                size: 44,
              ),
            ),
            const SizedBox(height: AppStyles.spacingL),
            Text(
              isFile ? '从系统文件中选择健康资料' : '从系统相册中选择健康资料',
              textAlign: TextAlign.center,
              style: AppStyles.headline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              isFile
                  ? '支持 PDF、JPG、PNG 等文件。选择后将立即上传并进行 OCR 识别。'
                  : '将打开 iOS 系统相册。选中照片后会立即上传并进行 OCR 识别。',
              textAlign: TextAlign.center,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (uploading) ...[
              const SizedBox(height: AppStyles.spacingL),
              const LinearProgressIndicator(
                color: AppColors.mintDeep,
                backgroundColor: AppColors.mintSoft,
              ),
              const SizedBox(height: AppStyles.spacingS),
              Text(
                status,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppStyles.spacingL),
            SizedBox(
              width: double.infinity,
              height: AppStyles.primaryButtonHeight,
              child: FilledButton.icon(
                onPressed: uploading ? null : onPick,
                icon: Icon(
                  isFile
                      ? Icons.folder_open_rounded
                      : Icons.photo_library_rounded,
                ),
                label: Text(
                  isFile ? '选择文件' : '打开系统相册',
                  style: AppStyles.headline.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF08A84F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDocumentLines extends StatelessWidget {
  const _MiniDocumentLines();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Container(
            height: 5,
            width: index.isEven ? double.infinity : 70,
            decoration: BoxDecoration(
              color: index == 0 ? AppColors.mintDeep : AppColors.lightOutline,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _ReportMockup extends StatelessWidget {
  const _ReportMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '健康体检报告',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        const _MiniDocumentLines(),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            children: [
              const Expanded(child: _MiniDocumentLines()),
              const SizedBox(width: 18),
              SizedBox(
                width: 80,
                child: CustomPaint(painter: _BarChartPainter()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _MiniDocumentLines(),
      ],
    );
  }
}

class _DeskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.10, 20), 70, paint);
    canvas.drawCircle(Offset(size.width * 0.92, 20), 55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF66F3A6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 48.0;
    const r = 12.0;
    canvas.drawLine(const Offset(0, r), const Offset(0, len), paint);
    canvas.drawLine(const Offset(r, 0), const Offset(len, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, len), paint);
    canvas.drawLine(
      Offset(size.width - r, 0),
      Offset(size.width - len, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - r),
      Offset(0, size.height - len),
      paint,
    );
    canvas.drawLine(Offset(r, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(size.width, size.height - r),
      Offset(size.width, size.height - len),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - r, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.65);
    for (var i = 0; i < 3; i++) {
      final h = size.height * (0.35 + i * 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(10 + i * 23, size.height - h, 12, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraTool extends StatelessWidget {
  const _CameraTool({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mintDeep, size: 20),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mintDeep,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 3),
        gradient: const LinearGradient(
          colors: [Color(0xFF9CCDF6), Color(0xFF597EAD)],
        ),
      ),
    );
  }
}
