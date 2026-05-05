import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 视图切换栏：左侧时间范围(今日/7天/30天/全部)，右侧视图模式(列表/周/月)
class ViewSwitchBar extends StatelessWidget {
  const ViewSwitchBar({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.selectedView,
    required this.onViewChanged,
  });

  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  final String selectedView;
  final ValueChanged<String> onViewChanged;

  static const _rangeItems = [
    _PillItem('今日', 'today'),
    _PillItem('7天', 'week'),
    _PillItem('30天', 'month'),
    _PillItem('全部', 'all'),
  ];

  static const _viewItems = [
    _PillItem('列表', 'list', icon: Icons.menu_rounded),
    _PillItem('周', 'cal_week'),
    _PillItem('月', 'cal_month'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _PillGroup(
              items: _rangeItems,
              selected: selectedRange,
              onChanged: onRangeChanged,
              expanded: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _PillGroup(
              items: _viewItems,
              selected: selectedView,
              onChanged: onViewChanged,
              expanded: true,
            ),
          ),
        ],
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
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightOutline),
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
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
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
                size: 13,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12.5,
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
    );
  }
}
