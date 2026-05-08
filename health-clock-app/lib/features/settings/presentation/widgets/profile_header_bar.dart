import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

class ProfileHeaderBar extends StatelessWidget {
  const ProfileHeaderBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onSettingsTap,
    this.hasNotificationDot = true,
  });

  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final bool hasNotificationDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.spacingS,
        AppStyles.spacingM,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _IconWithDot(
            icon: Icons.notifications_none_rounded,
            showDot: hasNotificationDot,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: AppStyles.spacingXs),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
            constraints: const BoxConstraints(
              minWidth: AppStyles.minTouchTarget,
              minHeight: AppStyles.minTouchTarget,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconWithDot extends StatelessWidget {
  const _IconWithDot({
    required this.icon,
    required this.showDot,
    this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppStyles.minTouchTarget,
          minHeight: AppStyles.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spacingS),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              if (showDot)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
