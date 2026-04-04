import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/catalog_constants.dart';
import 'package:flutter_fractals/features/catalog/widgets/catalog_color_helpers.dart';
import 'package:flutter_fractals/features/catalog/widgets/thumbnail_gradient_fallback.dart';
import 'package:flutter_fractals/features/catalog/widgets/thumbnail_shimmer_skeleton.dart';

/// Preview thumbnail widget with shimmer, dimension badge, and gradient fallback.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class CatalogPreviewThumbnail extends StatefulWidget {
  final String catalogId;
  final bool is3D;
  final String category;
  final double? size;

  const CatalogPreviewThumbnail({
    super.key,
    required this.catalogId,
    required this.is3D,
    required this.category,
    this.size,
  });

  @override
  State<CatalogPreviewThumbnail> createState() =>
      _CatalogPreviewThumbnailState();
}

class _CatalogPreviewThumbnailState extends State<CatalogPreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final bool _animateShimmer;
  bool _imageLoaded = false;
  bool _imageError = false;

  bool get _hasExactCpuThumbnail {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    return kKnownThumbnailIds.contains(thumbId);
  }

  @override
  void initState() {
    super.initState();
    _animateShimmer = !RuntimeModeService.isAutomatedTest;
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppAnimations.shimmer,
    );
    if (_animateShimmer) {
      _shimmerController.repeat();
    }
  }

  void _markImageLoaded() {
    if (_imageLoaded) return;
    if (_shimmerController.isAnimating) {
      _shimmerController.stop();
    }
    if (!mounted) return;
    setState(() => _imageLoaded = true);
  }

  void _markImageError() {
    if (_imageError) return;
    if (_shimmerController.isAnimating) {
      _shimmerController.stop();
    }
    if (!mounted) return;
    setState(() => _imageError = true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    final thumbAsset = 'assets/catalog_thumbs/$thumbId.png';
    final isApproximate = !_hasExactCpuThumbnail;
    final accentColor = categoryAccentColor(widget.category);

    return Container(
      width: widget.size ?? double.infinity,
      height: widget.size ?? double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Shimmer shown while image is loading
          if (!_imageLoaded && !_imageError)
            ThumbnailShimmerSkeleton(controller: _shimmerController),

          // Image (or gradient fallback on error)
          Positioned.fill(
            child: Image.asset(
              thumbAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                final imageReady = wasSynchronouslyLoaded || frame != null;
                if (imageReady && !_imageLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markImageLoaded();
                  });
                }
                return AnimatedOpacity(
                  opacity: imageReady ? 1.0 : 0.0,
                  duration:
                      imageReady ? Duration.zero : AppAnimations.thumbnailFade,
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) {
                if (!_imageError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markImageError();
                  });
                }
                return ThumbnailGradientFallback(
                  catalogId: widget.catalogId,
                  category: widget.category,
                );
              },
            ),
          ),

          // Category accent bar — 3px strip at top edge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Dimension badge — pill shape, amber for 3D, subtle for 2D.
          Positioned(
            top: 7,
            right: 6,
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.is3D
                      ? AppColors.warning.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.is3D
                        ? AppColors.warning
                        : Colors.white.withValues(alpha: 0.45),
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
                  widget.is3D ? '3D' : '2D',
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.is3D ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),

          // "Preview approximate" label
          if (isApproximate)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Preview approximate',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
