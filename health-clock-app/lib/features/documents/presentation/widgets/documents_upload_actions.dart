import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DocumentsUploadActions extends StatelessWidget {
  const DocumentsUploadActions({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _UploadAction(
              icon: Icons.photo_camera_outlined,
              label: '拍照上传',
              onTap: onCamera,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _UploadAction(
              icon: Icons.photo_library_outlined,
              label: '从相册选择',
              onTap: onGallery,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _UploadAction(
              icon: Icons.folder_open_outlined,
              label: '选择文件',
              onTap: onFile,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadAction extends StatelessWidget {
  const _UploadAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightOutline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
