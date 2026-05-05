import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ProfileServiceGrid extends StatelessWidget {
  const ProfileServiceGrid({
    super.key,
    required this.onIndicators,
    required this.onDocuments,
    required this.onNotifications,
    required this.onMembers,
  });

  final VoidCallback onIndicators;
  final VoidCallback onDocuments;
  final VoidCallback onNotifications;
  final VoidCallback onMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的服务',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ServiceItem(
                icon: Icons.monitor_heart_rounded,
                iconColor: AppColors.mintDeep,
                iconBg: AppColors.mintSoft,
                label: '健康指标',
                onTap: onIndicators,
              ),
              _ServiceItem(
                icon: Icons.folder_open_rounded,
                iconColor: AppColors.careBlue,
                iconBg: AppColors.careBlueSoft,
                label: '我的文档',
                onTap: onDocuments,
              ),
              _ServiceItem(
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.warmAmber,
                iconBg: AppColors.amberSoft,
                label: '通知设置',
                onTap: onNotifications,
              ),
              _ServiceItem(
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.lavender,
                iconBg: AppColors.lavenderSoft,
                label: '家庭成员',
                onTap: onMembers,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
