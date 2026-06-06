import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

Future<Set<String>>? _thumbnailAssetIdsFuture;

Future<Set<String>> _loadThumbnailAssetIds() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest
        .listAssets()
        .where((asset) =>
            asset.startsWith('assets/catalog_thumbs/') &&
            asset.endsWith('.png'))
        .map((asset) => asset.split('/').last.replaceAll('.png', ''))
        .toSet();
  } catch (_) {
    // Test bundles and unusual embedders may not expose an asset manifest.
    // Fall back to the historical exact-thumbnail allow-list rather than
    // making missing web assets perform 404-generating HTTP fetches.
    return _kKnownThumbnailIds;
  }
}

const _kKnownThumbnailIds = <String>{
  'mandelbrot',
  'julia',
  'burning_ship',
  'burning_ship_julia',
  'buffalo',
  'buffalo_julia',
  'manowar',
  'celtic',
  'celtic_julia',
  'cosine_mandelbrot',
  'cosine_julia',
  'cosh_mandelbrot',
  'lambda',
  'glynn',
  'magnet_type_2',
  'magnet_newton',
  'halley',
  'householder',
  'legendre',
  'laguerre',
  'chebyshev',
  'eisenstein',
  'fatou',
  'exponential',
  'dual_complex',
  'bicomplex',
  'hypercomplex_newton',
  'collatz',
  'gamma_fractal',
  'ducky',
  'fish',
  'druid',
  'heart',
  'day_night',
  'barnsley_fern',
  'barnsley_j1',
  'barnsley_j2',
  'barnsley_j3',
  'cyclosorus_fern',
  'arnold_cat',
  'henon',
  'hopalong',
  'clifford',
  'gumowski_mira',
  'gingerbreadman',
  'duffing',
  'lyapunov',
  'logistic_lyapunov',
  'circle_map_lyapunov',
  'gauss_map',
  'feigenbaum',
  'lorenz_2d',
  'aizawa',
  'arneodo',
  'bouali',
  'burke_shaw',
  'chen',
  'chua_circuit',
  'dadras',
  'four_wing',
  'hadley',
  'halvorsen',
  'liu_chen',
  'lu_chen',
  'golden_dragon',
  'fibonacci_spiral',
  'fibonacci_word',
  'log_spiral',
  'astroid',
  'hilbert_curve',
  'gosper_curve',
  'levy_c_curve',
  'moore_curve',
  'cesaro_fractal',
  'fractal_canopy',
  'koch_snowflake',
  'hexaflake',
  'cantor_set',
  'cantor_dust',
  'menger_sponge_2d',
  'menger_3d_slice',
  'apollonian_gasket',
  'ford_circles',
  'farey_diagram',
  'cayley_graph',
  'ammann_beenker',
  'hat_monotile',
  'chair_tiling',
  'cactus',
  'dla',
  'eden_growth',
  'forest_fire',
  'langton_ant',
  'brian_brain',
  'kicked_rotator',
  'benesi',
  'anti_buddhabrot',
  'buddhabrot_approx',
  'manair_fire',
  'jerusalem_cube',
};

/// Global shimmer animation controller shared by all thumbnails.
/// Single controller instead of one per thumbnail (350+ savings).
class GlobalShimmerController {
  static GlobalShimmerController? _instance;
  late final AnimationController controller;
  bool _isDisposed = false;

  GlobalShimmerController(TickerProvider vsync)
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 1500),
        ) {
    controller.repeat();
  }

  factory GlobalShimmerController.of(TickerProvider vsync) {
    _instance ??= GlobalShimmerController(vsync);
    return _instance!;
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      controller.dispose();
      _instance = null;
    }
  }
}

/// Returns the accent color for a given fractal category string.
Color categoryAccentColor(String category) {
  final cat = category.toLowerCase();
  if (cat.contains('escape')) return const Color(0xFF5B6FD4);
  if (cat.contains('complex')) return const Color(0xFF9B59B6);
  if (cat.contains('rational')) return const Color(0xFFE67E22);
  if (cat.contains('attract')) return const Color(0xFF27AE60);
  if (cat.contains('cellular') || cat.contains('automata')) {
    return const Color(0xFF7F8C8D);
  }
  return const Color(0xFF2980B9);
}

// ---------------------------------------------------------------------------
// Shimmer skeleton shown while thumbnail image is loading
// ---------------------------------------------------------------------------

class ShimmerSkeleton extends StatelessWidget {
  final AnimationController controller;

  const ShimmerSkeleton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final shimmerPos = controller.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shimmerPos - 1, -0.3),
            end: Alignment(shimmerPos, 0.3),
            colors: const [
              Color(0xFF2A2A3A),
              Color(0xFF3E3E54),
              Color(0xFF4A4A62),
              Color(0xFF3E3E54),
              Color(0xFF2A2A3A),
            ],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
          ).createShader(bounds),
          child: const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF2A2A3A)),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category-aware gradient fallback using CustomPainter
// ---------------------------------------------------------------------------

class FractalGradientFallback extends StatelessWidget {
  final String catalogId;
  final String category;

  const FractalGradientFallback({
    super.key,
    required this.catalogId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FractalGradientPainter(
        catalogId: catalogId,
        category: category,
      ),
    );
  }
}

class _FractalGradientPainter extends CustomPainter {
  final String catalogId;
  final String category;

  const _FractalGradientPainter({
    required this.catalogId,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cat = category.toLowerCase();
    final hash = catalogId.hashCode.abs();

    if (cat.contains('escape')) {
      _paintEscapeTime(canvas, rect, hash);
    } else if (cat.contains('complex')) {
      _paintComplexViz(canvas, rect, hash);
    } else if (cat.contains('rational')) {
      _paintRationalMaps(canvas, rect, hash);
    } else if (cat.contains('attract')) {
      _paintAttractors(canvas, rect, hash);
    } else if (cat.contains('cellular') || cat.contains('automata')) {
      _paintCellular(canvas, rect, hash);
    } else {
      _paintDefault(canvas, rect, hash);
    }
  }

  /// Deep blue/purple with radial glow (Escape-Time fractals).
  void _paintEscapeTime(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF040820));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF3B1FA0),
            Color(0xFF1A0A50),
            Color(0xFF040820),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final offsetX = (hash % 40 - 20) / 60.0;
    final offsetY = ((hash ~/ 37) % 40 - 20) / 60.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(offsetX, offsetY),
          radius: 0.38,
          colors: const [
            Color(0xCCBBDDFF),
            Color(0x885599FF),
            Color(0x003311AA),
          ],
        ).createShader(rect),
    );

    final angle = (hash % 60).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(angle),
          colors: const [
            Color(0x004488FF),
            Color(0x336699FF),
            Color(0x004488FF),
          ],
        ).createShader(rect),
    );
  }

  /// Rainbow/spectrum sweep (Complex Visualization).
  void _paintComplexViz(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0D0015));

    final sweepAngle = (hash % 45).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(sweepAngle),
          colors: const [
            Color(0xFFFF0080),
            Color(0xFFFF6600),
            Color(0xFFFFDD00),
            Color(0xFF00FF88),
            Color(0xFF0088FF),
            Color(0xFF8800FF),
            Color(0xFFFF0080),
          ],
          stops: const [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.85,
          colors: [
            Color(0x00000000),
            Color(0xAA000000),
          ],
        ).createShader(rect),
    );
  }

  /// Warm red/orange (Rational Maps).
  void _paintRationalMaps(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF1A0500));

    final cx = (hash % 30 - 20) / 40.0;
    final cy = ((hash ~/ 31) % 30 - 20) / 40.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.85,
          colors: const [
            Color(0xFFFF6B00),
            Color(0xFFCC2200),
            Color(0xFF1A0500),
          ],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0x55FF9900),
            Color(0x00FF5500),
            Color(0x33FF2200),
          ],
        ).createShader(rect),
    );
  }

  /// Green/teal (Attractors).
  void _paintAttractors(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF010E06));

    final cx = (hash % 40 - 20) / 50.0;
    final cy = ((hash ~/ 41) % 40 - 20) / 50.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.9,
          colors: const [
            Color(0xFF00C864),
            Color(0xFF006644),
            Color(0xFF010E06),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x4400E5CC),
            Color(0x0000CC99),
            Color(0x2200AAAA),
          ],
        ).createShader(rect),
    );
  }

  /// Monochrome geometric (Cellular Automata).
  void _paintCellular(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF111111));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E2E2E),
            Color(0xFF111111),
          ],
        ).createShader(rect),
    );

    final linePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 0.8;

    final step = 8.0 + (hash % 6).toDouble();
    for (double x = 0; x < rect.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, rect.height), linePaint);
    }
    for (double y = 0; y < rect.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(rect.width, y), linePaint);
    }

    final accentPaint = Paint()..color = const Color(0x44FFFFFF);
    final cols = (rect.width / step).floor();
    final rows = (rect.height / step).floor();
    if (cols > 0 && rows > 0) {
      for (int i = 0; i < 6; i++) {
        final col = ((hash ~/ math.pow(3, i).toInt()) % cols).toDouble() * step;
        final row = ((hash ~/ math.pow(5, i).toInt()) % rows).toDouble() * step;
        canvas.drawRect(
            Rect.fromLTWH(col, row, step - 1, step - 1), accentPaint);
      }
    }
  }

  /// Default — HSV-based with overlapping gradients for depth.
  void _paintDefault(Canvas canvas, Rect rect, int hash) {
    final hueA = (hash % 360).toDouble();
    final hueB = ((hash ~/ 11) % 360).toDouble();
    final colorA = HSVColor.fromAHSV(1, hueA, 0.58, 0.92).toColor();
    final colorB = HSVColor.fromAHSV(1, hueB, 0.66, 0.78).toColor();
    final colorMid =
        HSVColor.fromAHSV(1, (hueA + hueB) / 2, 0.72, 0.55).toColor();

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            colorMid.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    final angle = (hash % 90).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          transform: GradientRotation(angle),
          colors: [
            colorB.withValues(alpha: 0.4),
            Colors.transparent,
            colorA.withValues(alpha: 0.3),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FractalGradientPainter old) =>
      old.catalogId != catalogId || old.category != category;
}

// ---------------------------------------------------------------------------
// Preview thumbnail with shimmer, improved badge, and category accent bar
// ---------------------------------------------------------------------------

class CatalogThumbnail extends StatefulWidget {
  final String catalogId;
  final bool is3D;
  final String category;
  final double? width;
  final double? height;
  final GlobalShimmerController? shimmerController;

  const CatalogThumbnail({
    super.key,
    required this.catalogId,
    required this.is3D,
    required this.category,
    this.width,
    this.height,
    this.shimmerController,
  });

  @override
  State<CatalogThumbnail> createState() => _CatalogThumbnailState();
}

class _CatalogThumbnailState extends State<CatalogThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localShimmerController;
  late final Future<Set<String>> _thumbnailAssetIds;
  bool _imageLoaded = false;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _thumbnailAssetIds = _thumbnailAssetIdsFuture ??= _loadThumbnailAssetIds();

    // Use global controller if available, otherwise local fallback
    if (widget.shimmerController != null) {
      _localShimmerController = widget.shimmerController!.controller;
    } else {
      _localShimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      if (!RuntimeModeService.isAutomatedTest) {
        _localShimmerController.repeat();
      }
    }
  }

  @override
  void dispose() {
    // Only dispose local controller, not the global one
    if (widget.shimmerController == null) {
      _localShimmerController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(CatalogThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogId != widget.catalogId) {
      _imageLoaded = false;
      _imageError = false;
    }
  }

  void _markImageLoaded() {
    if (_imageLoaded) return;
    if (!mounted) return;
    setState(() => _imageLoaded = true);
  }

  void _markImageError() {
    if (_imageError) return;
    if (!mounted) return;
    setState(() => _imageError = true);
  }

  @override
  Widget build(BuildContext context) {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    final thumbAsset = 'assets/catalog_thumbs/$thumbId.png';

    return FutureBuilder<Set<String>>(
      future: _thumbnailAssetIds,
      builder: (context, snapshot) {
        final availableThumbnailIds = snapshot.data;
        final hasManifest = availableThumbnailIds != null;
        final hasExactThumbnail =
            hasManifest && availableThumbnailIds.contains(thumbId);
        final isApproximate =
            hasManifest && (!hasExactThumbnail || _imageError);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Shimmer shown while the manifest or exact image is loading.
              if (!hasManifest ||
                  (hasExactThumbnail && !_imageLoaded && !_imageError))
                ShimmerSkeleton(controller: _localShimmerController),

              // Avoid creating AssetImage for missing thumbnails. On web that
              // prevents 404s for catalog entries that intentionally use the
              // generated gradient fallback.
              if (hasExactThumbnail)
                Image(
                  image: ResizeImage(
                    AssetImage(thumbAsset),
                    width: 256,
                    height: 256,
                  ),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    final imageReady = wasSynchronouslyLoaded || frame != null;
                    if (imageReady && !_imageLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _markImageLoaded();
                      });
                    }
                    return AnimatedOpacity(
                      opacity: imageReady ? 1.0 : 0.0,
                      duration: imageReady
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stack) {
                    if (!_imageError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _markImageError();
                      });
                    }
                    return FractalGradientFallback(
                      catalogId: widget.catalogId,
                      category: widget.category,
                    );
                  },
                )
              else if (hasManifest)
                FractalGradientFallback(
                  catalogId: widget.catalogId,
                  category: widget.category,
                ),

              // Dimension badge — pill shape, amber for 3D, subtle for 2D.
              Positioned(
                top: 7,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

              // "Preview approximate" label
              if (isApproximate)
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
      },
    );
  }
}
