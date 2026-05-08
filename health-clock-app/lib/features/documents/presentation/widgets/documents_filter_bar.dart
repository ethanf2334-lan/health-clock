import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

class DocumentsFilterBar extends StatelessWidget {
  const DocumentsFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    required this.sortLabel,
    required this.onSortTap,
  });

  final List<DocFilterItem> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  final String sortLabel;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in filters) ...[
                    _FilterChip(
                      label: f.label,
                      selected: f.value == selected,
                      onTap: () => onSelected(f.value),
                    ),
                    if (f != filters.last) const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _SortButton(label: sortLabel, onTap: onSortTap),
        ],
      ),
    );
  }
}

class DocFilterItem {
  const DocFilterItem({required this.label, required this.value});
  final String label;
  final String value;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mintBg
              : const Color(0xFFF5F6F5).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.mintDeep.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.mintDeep : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.lightOutline),
          boxShadow: AppStyles.subtleShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
