import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/performance_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// A real-time performance overlay displaying FPS, frame times, and metrics.
///
/// Shows a mini graph of recent frame times and key performance indicators.
/// Designed to be non-intrusive while providing valuable debugging info.
class FractalPerformanceOverlay extends StatelessWidget {
  final PerformanceService service;
  final bool compact;

  const FractalPerformanceOverlay({
    Key? key,
    required this.service,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final metrics = service.metrics;
        final samples = service.samples;

        if (compact) {
          return _CompactOverlay(metrics: metrics);
        }

        return _FullOverlay(
          metrics: metrics,
          samples: samples,
          isRunning: service.isRunning,
        );
      },
    );
  }
}

class _CompactOverlay extends StatelessWidget {
  final PerformanceMetrics metrics;

  const _CompactOverlay({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final fpsColor = _getFpsColor(metrics.fps);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            metrics.isJanky ? Icons.warning_rounded : Icons.speed_rounded,
            color: fpsColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${metrics.fps.toStringAsFixed(0)} FPS',
            style: TextStyle(
              color: fpsColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          if (metrics.droppedFrames > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${metrics.droppedFrames} ▼',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullOverlay extends StatelessWidget {
  final PerformanceMetrics metrics;
  final List<FrameSample> samples;
  final bool isRunning;

  const _FullOverlay({
    required this.metrics,
    required this.samples,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRunning ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'PERFORMANCE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${metrics.durationSeconds.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // FPS Display
              _FpsDisplay(metrics: metrics),
              const SizedBox(height: 10),

              // Frame Time Graph
              if (samples.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: _FrameTimeGraph(samples: samples),
                ),
              const SizedBox(height: 10),

              // Stats Grid
              _StatsGrid(metrics: metrics),

              // Shader Compilations Warning
              if (metrics.shaderCompilations > 0) ...[
                const SizedBox(height: 8),
                _ShaderWarning(count: metrics.shaderCompilations),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FpsDisplay extends StatelessWidget {
  final PerformanceMetrics metrics;

  const _FpsDisplay({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final fpsColor = _getFpsColor(metrics.fps);
    final rating = _getFpsRating(metrics.fps);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          metrics.fps.toStringAsFixed(0),
          style: TextStyle(
            color: fpsColor,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            height: 1,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'FPS',
            style: TextStyle(
              color: fpsColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: fpsColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            rating,
            style: TextStyle(
              color: fpsColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FrameTimeGraph extends StatelessWidget {
  final List<FrameSample> samples;

  const _FrameTimeGraph({required this.samples});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FrameTimeGraphPainter(samples: samples),
      child: const SizedBox.expand(),
    );
  }
}

class _FrameTimeGraphPainter extends CustomPainter {
  final List<FrameSample> samples;
  static const double maxFrameTime = 50.0; // Cap at 50ms for display

  _FrameTimeGraphPainter({required this.samples});

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final targetPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final warnPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw target zone (0-16.67ms)
    final targetHeight = (16.67 / maxFrameTime) * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - targetHeight, size.width, targetHeight),
      targetPaint,
    );

    // Draw warn zone (16.67-33.34ms)
    final warnHeight = (16.67 / maxFrameTime) * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - targetHeight - warnHeight, size.width, warnHeight),
      warnPaint,
    );

    // Draw frame times
    final barWidth = size.width / samples.length;
    
    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i];
      final clampedTime = sample.frameTimeMs.clamp(0.0, maxFrameTime);
      final barHeight = (clampedTime / maxFrameTime) * size.height;
      
      Color barColor;
      if (sample.hadShaderCompile) {
        barColor = Colors.purple;
      } else if (sample.wasDropped) {
        barColor = sample.frameTimeMs > 33.34 ? Colors.red : Colors.orange;
      } else {
        barColor = Colors.green;
      }

      final rect = Rect.fromLTWH(
        i * barWidth,
        size.height - barHeight,
        barWidth - 0.5,
        barHeight,
      );

      canvas.drawRect(rect, Paint()..color = barColor.withValues(alpha: 0.8));
    }

    // Draw 16.67ms line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    
    final lineY = size.height - targetHeight;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), linePaint);
  }

  @override
  bool shouldRepaint(_FrameTimeGraphPainter oldDelegate) => true;
}

class _StatsGrid extends StatelessWidget {
  final PerformanceMetrics metrics;

  const _StatsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'AVG',
                value: '${metrics.avgFrameTimeMs.toStringAsFixed(1)}ms',
              ),
            ),
            Expanded(
              child: _StatItem(
                label: 'P95',
                value: '${metrics.p95FrameTimeMs.toStringAsFixed(1)}ms',
                highlight: metrics.p95FrameTimeMs > 16.67,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'DROPS',
                value: '${metrics.droppedFrames}',
                highlight: metrics.droppedFrames > 5,
              ),
            ),
            Expanded(
              child: _StatItem(
                label: 'STABLE',
                value: '${metrics.stabilityScore.toStringAsFixed(0)}%',
                highlight: metrics.stabilityScore < 80,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.orange : Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.orange : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ShaderWarning extends StatelessWidget {
  final int count;

  const _ShaderWarning({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.memory_rounded,
            color: Colors.purple,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$count shader compilation${count > 1 ? 's' : ''} detected',
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _getFpsColor(double fps) {
  if (fps >= 55) return Colors.green;
  if (fps >= 45) return Colors.lightGreen;
  if (fps >= 30) return Colors.orange;
  return Colors.red;
}

String _getFpsRating(double fps) {
  if (fps >= 58) return 'EXCELLENT';
  if (fps >= 50) return 'GOOD';
  if (fps >= 30) return 'FAIR';
  return 'POOR';
}

/// A settings button to toggle the performance overlay.
class PerformanceToggleButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;
  final bool compact;

  const PerformanceToggleButton({
    Key? key,
    required this.isEnabled,
    required this.onToggle,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed_rounded,
              color: isEnabled ? AppColors.primary : Colors.white70,
              size: 16,
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                'PERF',
                style: TextStyle(
                  color: isEnabled ? AppColors.primary : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
