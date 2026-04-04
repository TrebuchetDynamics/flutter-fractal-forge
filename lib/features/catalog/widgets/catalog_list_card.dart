import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_preview_thumbnail.dart';

/// List item card widget for displaying a catalog entry in list view.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogListCard extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const CatalogListCard({
    super.key,
    required this.entry,
    required this.semanticLabel,
    required this.onTap,
    required this.l10n,
  });

  @override
  State<CatalogListCard> createState() => _CatalogListCardState();
}

class _CatalogListCardState extends State<CatalogListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel =
        is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;

    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(
          key: Key('catalogModuleCard_${widget.entry.catalogId}'),
          onTapDown: reduceMotion
              ? null
              : (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                },
          onTapUp: reduceMotion
              ? null
              : (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
          onTapCancel: reduceMotion
              ? null
              : () {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
          onTap: widget.onTap,
          child: reduceMotion
              ? _buildCardContent(dimensionLabel, is3D)
              : ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildCardContent(dimensionLabel, is3D),
                ),
        ),
      ),
    );
  }

  Widget _buildCardContent(String dimensionLabel, bool is3D) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: _isPressed ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border.withValues(alpha: 0.4),
        ),
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            CatalogPreviewThumbnail(
              catalogId: widget.entry.catalogId,
              is3D: is3D,
              category: widget.entry.category,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.module.displayName(widget.l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dimensionLabel / ${widget.entry.category}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isPressed
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: _isPressed ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
