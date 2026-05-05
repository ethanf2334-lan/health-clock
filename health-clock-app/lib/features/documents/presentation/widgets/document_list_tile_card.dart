import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DocumentListTileCard extends StatelessWidget {
  const DocumentListTileCard({
    super.key,
    required this.title,
    required this.hospital,
    required this.dateText,
    required this.belongTo,
    required this.statusText,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.tagLabel,
    required this.tagColor,
    required this.tagBg,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? hospital;
  final String dateText;
  final String belongTo;
  final String statusText;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String tagLabel;
  final Color tagColor;
  final Color tagBg;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final secondLine = [
      if (hospital != null && hospital!.isNotEmpty) hospital,
      dateText,
    ].whereType<String>().join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _Tag(
                            label: tagLabel,
                            color: tagColor,
                            bg: tagBg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        secondLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '归属: $belongTo · $statusText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textTertiary,
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
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
