import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

class ReminderCardData {
  const ReminderCardData({
    required this.title,
    required this.source,
    required this.tag,
    required this.timeText,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.tagColor,
    required this.tagBg,
    this.timeColor,
    this.isOverdue = false,
    this.timeIcon,
  });

  final String title;
  final String source;
  final String tag;
  final String timeText;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color tagColor;
  final Color tagBg;
  final Color? timeColor;
  final IconData? timeIcon;
  final bool isOverdue;
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.data,
    this.onTap,
    this.onComplete,
  });

  final ReminderCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppStyles.minTouchTarget),
            child: Container(
              padding: const EdgeInsets.all(AppStyles.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                border: Border.all(color: AppColors.lightOutline),
                borderRadius: BorderRadius.circular(AppStyles.radiusL),
                boxShadow: AppStyles.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    alignment: Alignment.center,
                    child: Icon(data.icon, color: data.iconColor, size: 22),
                  ),
                  const SizedBox(width: AppStyles.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.spacingXs),
                        Text(
                          data.source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.caption1.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Tag(
                        label: data.tag,
                        color: data.tagColor,
                        bg: data.tagBg,
                      ),
                      const SizedBox(height: AppStyles.spacingS),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            data.timeIcon ??
                                (data.isOverdue
                                    ? Icons.access_time_filled_rounded
                                    : Icons.access_time_rounded),
                            size: 12,
                            color: data.timeColor ?? AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppStyles.spacingXs),
                          Text(
                            data.timeText,
                            style: TextStyle(
                              fontSize: AppStyles.caption1.fontSize,
                              letterSpacing: AppStyles.caption1.letterSpacing,
                              fontWeight: FontWeight.w600,
                              color: data.timeColor ?? AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                  _CompleteButton(onTap: onComplete),
                  const SizedBox(width: AppStyles.spacingXs),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '标记完成',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mintBgLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.mintDeep.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.mintDeep,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
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
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
