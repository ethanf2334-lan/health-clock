import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

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
    _NavItem(
      '健康档案',
      Icons.add_box_rounded,
      Icons.medical_services_outlined,
    ),
    _NavItem('我的', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomPadding =
        viewPadding > 0 ? AppStyles.spacingS + viewPadding * 0.25 : 0.0;

    return Material(
      color: AppColors.cardWhite,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.lightOutline,
              width: AppStyles.dividerThin,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppStyles.spacingXl,
          AppStyles.spacingS,
          AppStyles.spacingXl,
          bottomPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (i) {
            final selected = i == index;
            final item = _items[i];
            return InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: AppStyles.minTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingS,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selected && i == 2)
                        Container(
                          width: AppStyles.bottomNavIconBoxWidth,
                          height: AppStyles.bottomNavIconBoxHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0BA84A),
                            borderRadius:
                                BorderRadius.circular(AppStyles.radiusS),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      else
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected
                              ? AppColors.mintDeep
                              : AppColors.textTertiary,
                          size: 24,
                        ),
                      const SizedBox(height: AppStyles.spacingXs),
                      Text(
                        item.label,
                        style: AppStyles.caption1.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected
                              ? AppColors.mintDeep
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
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
