import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          _IconWithDot(
            icon: Icons.notifications_none_rounded,
            showDot: hasNotificationDot,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
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
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(8),
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
    );
  }
}
