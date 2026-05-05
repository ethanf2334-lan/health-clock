import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'member_avatar.dart';

/// 全部成员列表中的卡片
class MemberListTileCard extends StatelessWidget {
  const MemberListTileCard({
    super.key,
    required this.name,
    required this.relationLabel,
    required this.relation,
    this.age,
    this.isSelf = false,
    this.summary,
    this.summaryHighlight,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final String relationLabel;
  final String? relation;
  final int? age;
  final bool isSelf;
  final String? summary;
  final String? summaryHighlight;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ageText = age != null ? '$relationLabel · $age岁' : relationLabel;

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
                MemberAvatar(
                  name: name,
                  relation: relation,
                  size: 50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            const _Tag(
                              label: '本人',
                              color: AppColors.careBlue,
                              bg: AppColors.careBlueSoft,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ageText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: 6),
                        _buildSummary(),
                      ],
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

  Widget _buildSummary() {
    final summary = this.summary!;
    final highlight = summaryHighlight;
    if (highlight == null || !summary.contains(highlight)) {
      return Text(
        summary,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.careBlue,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final parts = summary.split(highlight);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (parts.first.isNotEmpty) TextSpan(text: parts.first),
          TextSpan(
            text: highlight,
            style: const TextStyle(
              color: AppColors.careBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.sublist(1).join(highlight)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
