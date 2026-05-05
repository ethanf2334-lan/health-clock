import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    _NavItem(
      '健康日历',
      Icons.calendar_today_rounded,
      Icons.calendar_today_outlined,
    ),
    _NavItem('家庭成员', Icons.people_alt_rounded, Icons.people_alt_outlined),
    _NavItem('健康档案', Icons.assignment_rounded, Icons.assignment_outlined),
    _NavItem('我的', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    // 比之前再减少约 10pt 的底部空间
    final bottomPadding = viewPadding > 0 ? 8.0 + viewPadding * 0.18 : 6.0;

    return Material(
      color: AppColors.cardWhite,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.lightOutline,
              width: 0.5,
            ),
          ),
        ),
        // 整体上下 padding 更紧凑；左右留出空白让 4 个 tab 居中、彼此靠近
        padding: EdgeInsets.fromLTRB(36, 4, 36, bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (i) {
            final selected = i == index;
            final item = _items[i];
            return InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? item.activeIcon : item.icon,
                      color: selected
                          ? AppColors.mintDeep
                          : AppColors.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                        color: selected
                            ? AppColors.mintDeep
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.activeIcon, this.icon);
  final String label;
  final IconData activeIcon;
  final IconData icon;
}
