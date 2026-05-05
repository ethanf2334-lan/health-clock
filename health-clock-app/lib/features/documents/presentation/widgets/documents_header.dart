import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DocumentsHeader extends StatelessWidget {
  const DocumentsHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUpload,
  });

  final String title;
  final String subtitle;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                _buildSubtitle(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.cardWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            child: InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.lightOutline),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 16,
                      color: AppColors.mintDeep,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '上传',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mintDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    final pattern = RegExp(r'(\d+)');
    final match = pattern.firstMatch(subtitle);
    if (match == null) {
      return Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
      );
    }
    final before = subtitle.substring(0, match.start);
    final number = match.group(0)!;
    final after = subtitle.substring(match.end);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: number,
            style: const TextStyle(
              color: AppColors.mintDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}
