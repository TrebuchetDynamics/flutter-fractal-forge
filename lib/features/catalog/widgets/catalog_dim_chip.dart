import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Dimension filter chip widget.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogDimChip extends StatelessWidget {
  final Key? chipKey;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const CatalogDimChip({
    super.key,
    this.chipKey,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: selected
          ? '$label filter, selected, $count fractals'
          : '$label filter, $count fractals',
      child: GestureDetector(
        key: chipKey,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.28)
                      : AppColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
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
