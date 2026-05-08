import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

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
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.screenTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                _buildSubtitle(),
              ],
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Material(
            color: AppColors.cardWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            ),
            child: InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: AppStyles.minTouchTarget),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingM,
                    vertical: AppStyles.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                    border: Border.all(color: AppColors.lightOutline),
                    boxShadow: AppStyles.subtleShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_rounded,
                        size: 20,
                        color: Color(0xFF0BA84A),
                      ),
                      const SizedBox(width: AppStyles.spacingXs),
                      Text(
                        '上传',
                        style: AppStyles.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
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
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
    final before = subtitle.substring(0, match.start);
    final number = match.group(0)!;
    final after = subtitle.substring(match.end);
    return RichText(
      text: TextSpan(
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: number,
            style: AppStyles.footnote.copyWith(
              color: AppColors.mintDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}
