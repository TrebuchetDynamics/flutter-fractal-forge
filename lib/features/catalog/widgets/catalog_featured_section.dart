import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/catalog_screen_data.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_featured_card.dart';

/// Featured section widget for the catalog hero carousel.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogFeaturedSection extends StatelessWidget {
  final CatalogScreenData screenData;
  final AppLocalizations l10n;
  final ValueChanged<CatalogEntry> onTap;

  const CatalogFeaturedSection({
    super.key,
    required this.screenData,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (screenData.featuredEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: l10n.semanticFeaturedSection,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.catalogFeatured,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(1) > 2.0 ? 140 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: screenData.featuredEntries.length,
            itemBuilder: (context, index) {
              final entry = screenData.featuredEntries[index];
              return Padding(
                key: ValueKey('featured_${entry.catalogId}'),
                padding: EdgeInsets.only(
                  right: index < screenData.featuredEntries.length - 1
                      ? AppSpacing.sm
                      : 0,
                ),
                child: CatalogFeaturedCard(
                  entry: entry,
                  semanticLabel: screenData.semanticLabelFor(entry),
                  l10n: l10n,
                  onTap: () => onTap(entry),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.border.withValues(alpha: 0.6),
                  AppColors.border.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0, 0.15, 0.85, 1],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}
