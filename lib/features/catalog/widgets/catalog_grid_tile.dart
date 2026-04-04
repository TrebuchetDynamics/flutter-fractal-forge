import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_color_helpers.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_preview_thumbnail.dart';

/// Grid tile widget for displaying a catalog entry in grid view.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogGridTile extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const CatalogGridTile({
    super.key,
    required this.entry,
    required this.semanticLabel,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<CatalogGridTile> createState() => _CatalogGridTileState();
}

class _CatalogGridTileState extends State<CatalogGridTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: AppAnimations.snappyCurve,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _setHighlight(bool on) {
    setState(() {
      _isHovered = on;
    });
    if (on) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel =
        is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;
    final name = widget.entry.module.displayName(widget.l10n);
    final accentColor = categoryAccentColor(widget.entry.category);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: MouseRegion(
        onEnter: (_) => _setHighlight(true),
        onExit: (_) => _setHighlight(false),
        child: GestureDetector(
          key: Key('catalogModuleCard_${widget.entry.catalogId}'),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              final glow = _glowAnim.value;
              return AnimatedContainer(
                duration: AppAnimations.fast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    if (_isHovered || _isPressed)
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35 * glow),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: Offset.zero,
                      ),
                  ],
                ),
                child: _GridTileContent(
                  catalogId: widget.entry.catalogId,
                  name: name,
                  dimensionLabel: dimensionLabel,
                  is3D: is3D,
                  accentColor: accentColor,
                  isHovered: _isHovered,
                  isPressed: _isPressed,
                  glow: glow,
                  category: widget.entry.category,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GridTileContent extends StatelessWidget {
  final String catalogId;
  final String name;
  final String dimensionLabel;
  final bool is3D;
  final Color accentColor;
  final bool isHovered;
  final bool isPressed;
  final double glow;
  final String category;

  const _GridTileContent({
    required this.catalogId,
    required this.name,
    required this.dimensionLabel,
    required this.is3D,
    required this.accentColor,
    required this.isHovered,
    required this.isPressed,
    required this.glow,
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
              // Thumbnail
              CatalogPreviewThumbnail(
                catalogId: catalogId,
                is3D: is3D,
                category: category,
              ),
              // Gradient overlay for text
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 20, 6, 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Press darkening overlay
              if (isPressed)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Animated shimmer border overlay on hover/press
        if (isHovered || isPressed)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: glow,
                duration: AppAnimations.fast,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.75),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
