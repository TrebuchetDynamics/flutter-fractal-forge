import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_color_helpers.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_preview_thumbnail.dart';

/// Featured card widget for the catalog carousel.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogFeaturedCard extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const CatalogFeaturedCard({
    super.key,
    required this.entry,
    required this.semanticLabel,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<CatalogFeaturedCard> createState() => _CatalogFeaturedCardState();
}

class _CatalogFeaturedCardState extends State<CatalogFeaturedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppAnimations.snappyCurve,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _setHover(bool on) {
    setState(() => _isHovered = on);
    if (on) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final name = widget.entry.module.displayName(widget.l10n);
    final accentColor = categoryAccentColor(widget.entry.category);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  if (_isHovered || _isPressed)
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: _FeaturedCardContent(
                catalogId: widget.entry.catalogId,
                name: name,
                is3D: is3D,
                accentColor: accentColor,
                isPressed: _isPressed,
                isHovered: _isHovered,
                category: widget.entry.category,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCardContent extends StatelessWidget {
  final String catalogId;
  final String name;
  final bool is3D;
  final Color accentColor;
  final bool isPressed;
  final bool isHovered;
  final String category;

  const _FeaturedCardContent({
    required this.catalogId,
    required this.name,
    required this.is3D,
    required this.accentColor,
    required this.isPressed,
    required this.isHovered,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CatalogPreviewThumbnail(
                catalogId: catalogId,
                is3D: is3D,
                category: category,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 90,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 6),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.cardRadius),
                      topRight: Radius.circular(AppSpacing.cardRadius),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.9),
                        accentColor.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
              if (is3D)
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.warning,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '3D',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              if (isPressed)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isHovered || isPressed)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
