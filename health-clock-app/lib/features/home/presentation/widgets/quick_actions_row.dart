import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

class QuickAction {
  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
}

/// 并排展示的快捷操作卡片
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: a == actions.last ? 0 : AppStyles.spacingS,
                  ),
                  child: _QuickActionCard(action: a),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppStyles.minTouchTarget),
          child: Container(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              border: Border.all(color: AppColors.lightOutline),
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: AppStyles.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: AppStyles.iconContainerM,
                  height: AppStyles.iconContainerM,
                  decoration: BoxDecoration(
                    color: action.iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(action.icon, color: action.iconColor, size: 20),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppStyles.spacingXs),
                      Text(
                        action.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.caption1.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
