import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
  });

  final ReminderCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightOutline),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(data.icon, color: data.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Tag(
                      label: data.tag,
                      color: data.tagColor,
                      bg: data.tagBg,
                    ),
                    const SizedBox(height: 6),
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
                        const SizedBox(width: 3),
                        Text(
                          data.timeText,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: data.timeColor ?? AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
