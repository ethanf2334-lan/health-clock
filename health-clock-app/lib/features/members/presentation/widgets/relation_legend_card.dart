import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

class RelationLegendCard extends StatelessWidget {
  const RelationLegendCard({super.key});

  static const _items = [
    _RelationItem('本人', AppColors.careBlue, AppColors.careBlueSoft),
    _RelationItem('父亲', AppColors.lavender, AppColors.lavenderSoft),
    _RelationItem('母亲', AppColors.rose, AppColors.roseSoft),
    _RelationItem('配偶', AppColors.mintDeep, AppColors.mintSoft),
    _RelationItem('子女', AppColors.warmAmber, AppColors.amberSoft),
    _RelationItem('其他', AppColors.textSecondary, AppColors.lightDivider),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.careBlueSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.question_mark_rounded,
                  size: 11,
                  color: AppColors.careBlue,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '成员关系说明',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items.map((item) => _Pill(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _RelationItem {
  const _RelationItem(this.label, this.color, this.bg);
  final String label;
  final Color color;
  final Color bg;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.item});

  final _RelationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: item.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        item.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: item.color,
        ),
      ),
    );
  }
}
