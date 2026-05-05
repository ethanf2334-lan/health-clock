import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.lavenderBg,
                  AppColors.lavenderSoft,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.lavender.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lavender.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.lavender,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lavender,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onMicTap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
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
    );
  }
}
