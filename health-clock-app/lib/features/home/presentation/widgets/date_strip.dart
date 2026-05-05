import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DateStripItem {
  const DateStripItem({
    required this.date,
    required this.label,
    required this.dotColors,
  });

  final DateTime date;
  final String label;
  final List<Color> dotColors;
}

/// 日期横向滚动条
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<DateStripItem> items;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightOutline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: items.map((item) {
          final isSelected = _isSameDay(item.date, selected);
          return Expanded(
            child: _DateCell(
              item: item,
              selected: isSelected,
              onTap: () => onSelected(item.date),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DateStripItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = today.year == item.date.year &&
        today.month == item.date.month &&
        today.day == item.date.day;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: AppColors.mintDeep.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? AppColors.mintDeep
                    : (isToday
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.mintDeep : AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _weekdayLabel(item.date.weekday),
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? AppColors.mintDeep.withValues(alpha: 0.8)
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: item.dotColors
                    .take(3)
                    .map(
                      (c) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return labels[(weekday - 1).clamp(0, 6)];
  }
}
