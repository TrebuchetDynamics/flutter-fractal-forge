import 'package:flutter/material.dart';

/// Shimmer skeleton widget shown while thumbnail image is loading.
///
/// Extracted from FractalCatalogScreen to follow Single Responsibility Principle.
class ThumbnailShimmerSkeleton extends StatelessWidget {
  final AnimationController controller;

  const ThumbnailShimmerSkeleton({
    super.key,
    required this.controller,
  });

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
