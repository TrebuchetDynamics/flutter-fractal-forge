import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Empty state widget for catalog search results.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogEmptyState extends StatelessWidget {
  final String query;
  final AppLocalizations l10n;
  final VoidCallback onClear;

  const CatalogEmptyState({
    super.key,
    required this.query,
    required this.l10n,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppAnimations.normal,
      curve: AppAnimations.defaultCurve,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 280;
          final contentPadding = isCompact ? AppSpacing.lg : AppSpacing.xxxl;
          final iconPadding = isCompact ? AppSpacing.md : AppSpacing.xl;
          final iconSize = isCompact ? 28.0 : 36.0;
          final spacing = isCompact ? AppSpacing.sm : AppSpacing.lg;

          return SingleChildScrollView(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: iconSize,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  l10n.catalogSearchEmpty,
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (query.isNotEmpty) ...[
                  SizedBox(height: spacing),
                  TextButton.icon(
                    key: const Key('catalogClearSearchButton'),
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(l10n.actionClearSearch),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
