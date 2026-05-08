import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

/// 紧凑的 AI 输入栏。点击展开实际的AI面板。
class AIInputBar extends StatelessWidget {
  const AIInputBar({
    super.key,
    required this.placeholder,
    required this.onTap,
    required this.onMicTap,
    required this.onSend,
  });

  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback onMicTap;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppStyles.minTouchTarget),
            child: Container(
              padding: const EdgeInsets.all(AppStyles.spacingS),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.lavenderBg,
                    AppColors.lavenderSoft,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                border: Border.all(
                  color: AppColors.lavender.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lavender.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, AppStyles.spacingXs),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      border: Border.all(
                        color: AppColors.lavender.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lavender.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.lavender,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'AI',
                          style: AppStyles.caption1.copyWith(
                            color: AppColors.lavender,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                  Expanded(
                    child: Text(
                      placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subhead.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.88),
                        height: 1.1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onMicTap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AppStyles.iconTouchTarget,
                      minHeight: AppStyles.iconTouchTarget,
                    ),
                    icon: const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.textSecondary,
                      size: 23,
                    ),
                  ),
                  Container(
                    width: AppStyles.iconTouchTarget,
                    height: AppStyles.iconTouchTarget,
                    decoration: const BoxDecoration(
                      color: AppColors.lavender,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onSend,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
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
