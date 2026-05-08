import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

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

class MonthDateCell {
  const MonthDateCell({
    required this.date,
    required this.dotColors,
  }) : isEmpty = false;

  const MonthDateCell.empty()
      : date = null,
        dotColors = const [],
        isEmpty = true;

  final DateTime? date;
  final List<Color> dotColors;
  final bool isEmpty;
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
      margin: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingXs,
        vertical: AppStyles.spacingS,
      ),
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

class MonthDateGrid extends StatelessWidget {
  const MonthDateGrid({
    super.key,
    required this.cells,
    required this.selected,
    required this.onSelected,
  });

  final List<MonthDateCell> cells;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final paddedCells = [...cells];
    while (paddedCells.length % 7 != 0) {
      paddedCells.add(const MonthDateCell.empty());
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingM,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingS,
        AppStyles.spacingS,
        AppStyles.spacingS,
        AppStyles.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekdayHeader('一'),
              _WeekdayHeader('二'),
              _WeekdayHeader('三'),
              _WeekdayHeader('四'),
              _WeekdayHeader('五'),
              _WeekdayHeader('六'),
              _WeekdayHeader('日'),
            ],
          ),
          const SizedBox(height: AppStyles.spacingS),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paddedCells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 44,
            ),
            itemBuilder: (context, index) {
              final cell = paddedCells[index];
              if (cell.isEmpty || cell.date == null) {
                return const SizedBox.shrink();
              }
              return _MonthDateCellView(
                cell: cell,
                selected: _isSameDay(cell.date!, selected),
                onTap: () => onSelected(cell.date!),
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppStyles.caption1.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MonthDateCellView extends StatelessWidget {
  const _MonthDateCellView({
    required this.cell,
    required this.selected,
    required this.onTap,
  });

  final MonthDateCell cell;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = cell.date!;
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: selected
              ? Border.all(color: AppColors.mintDeep.withValues(alpha: 0.35))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppStyles.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.mintDeep
                    : (isToday
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppStyles.spacingXs),
            SizedBox(
              height: AppStyles.spacingXs,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cell.dotColors
                    .take(3)
                    .map(
                      (c) => Container(
                        width: 4,
                        height: 4,
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
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: AppStyles.spacingXxs),
        padding: const EdgeInsets.symmetric(
          vertical: AppStyles.spacingS,
          horizontal: AppStyles.spacingXs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: selected
              ? Border.all(color: AppColors.mintDeep.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: AppStyles.caption1.fontSize,
                color: selected
                    ? AppColors.mintDeep
                    : (isToday
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
                fontWeight: FontWeight.w600,
                letterSpacing: AppStyles.caption1.letterSpacing,
              ),
            ),
            const SizedBox(height: AppStyles.spacingXs),
            Text(
              '${item.date.day}',
              style: TextStyle(
                fontSize: AppStyles.title3.fontSize,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.mintDeep : AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppStyles.spacingXxs),
            Text(
              _weekdayLabel(item.date.weekday),
              style: TextStyle(
                fontSize: AppStyles.caption1.fontSize,
                letterSpacing: AppStyles.caption1.letterSpacing,
                color: selected
                    ? AppColors.mintDeep.withValues(alpha: 0.8)
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            SizedBox(
              height: AppStyles.spacingS,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: item.dotColors
                    .take(3)
                    .map(
                      (c) => Container(
                        width: AppStyles.spacingXs,
                        height: AppStyles.spacingXs,
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
