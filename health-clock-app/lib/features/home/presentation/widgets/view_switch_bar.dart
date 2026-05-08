import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

/// 视图切换栏：只负责切换列表 / 周 / 月。
class ViewSwitchBar extends StatelessWidget {
  const ViewSwitchBar({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  final String selectedView;
  final ValueChanged<String> onViewChanged;

  static const _viewItems = [
    _PillItem('列表', 'list', icon: Icons.menu_rounded),
    _PillItem('周', 'cal_week'),
    _PillItem('月', 'cal_month'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: _PillGroup(
        items: _viewItems,
        selected: selectedView,
        onChanged: onViewChanged,
        expanded: true,
      ),
    );
  }
}

class ListRangeBar extends StatelessWidget {
  const ListRangeBar({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  static const _rangeItems = [
    _PillItem('今天', 'today'),
    _PillItem('7天', 'week'),
    _PillItem('30天', 'month'),
    _PillItem('全部', 'all'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: _PillGroup(
        items: _rangeItems,
        selected: selectedRange,
        onChanged: onRangeChanged,
        expanded: true,
      ),
    );
  }
}

class CalendarPeriodBar extends StatelessWidget {
  const CalendarPeriodBar({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Container(
        height: AppStyles.minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          border: Border.all(color: AppColors.lightOutline),
          boxShadow: AppStyles.subtleShadow,
        ),
        child: Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left_rounded,
              onTap: onPrevious,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillItem {
  const _PillItem(this.label, this.value, {this.icon});
  final String label;
  final String value;
  final IconData? icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          size: 22,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PillGroup extends StatelessWidget {
  const _PillGroup({
    required this.items,
    required this.selected,
    required this.onChanged,
    this.expanded = false,
  });

  final List<_PillItem> items;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.minTouchTarget,
      padding: const EdgeInsets.all(AppStyles.spacingXs),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.subtleShadow,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: items.map((item) {
          final pill = _Pill(
            item: item,
            selected: item.value == selected,
            onTap: () => onChanged(item.value),
          );
          if (expanded) {
            return Expanded(child: pill);
          }
          return pill;
        }).toList(),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _PillItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 32,
          constraints: BoxConstraints(minWidth: item.icon == null ? 54 : 82),
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
          decoration: BoxDecoration(
            color: selected ? AppColors.cardWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: AppStyles.spacingS,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppStyles.spacingXs),
              ],
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: AppStyles.caption1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
