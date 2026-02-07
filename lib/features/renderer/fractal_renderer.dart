import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import './providers/fractal_provider.dart';
import 'fractal_canvas.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalRenderer extends StatefulWidget {
  final GlobalKey? boundaryKey;
  final bool gesturesEnabled;

  const FractalRenderer({
    Key? key,
    this.boundaryKey,
    this.gesturesEnabled = true,
  }) : super(key: key);

  @override
  State<FractalRenderer> createState() => _FractalRendererState();
}

class _FractalRendererState extends State<FractalRenderer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  ui.FragmentProgram? _program;
  String? _shaderAsset;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    )..repeat();
  }

  Future<void> _loadShader(String asset) async {
    if (_loading) {
      return;
    }
    _loading = true;
    try {
      final program = await ui.FragmentProgram.fromAsset(asset);
      setState(() {
        _program = program;
        _shaderAsset = asset;
      });
    } catch (e) {
      debugPrint('Error loading shader: $e');
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final module = controller.module;
    if (_shaderAsset != module.shaderAsset && !_loading) {
      _loadShader(module.shaderAsset);
    }
    if (_program == null) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingShaders),
          ],
        ),
      );
    }

    final content = RepaintBoundary(
      key: widget.boundaryKey,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final renderState = FractalRenderState(
              params: controller.params,
              view: controller.view,
              transparentBackground: controller.transparentBackground,
            );
            return CustomPaint(
              painter: FractalCanvas(
                module: controller.module,
                state: renderState,
                time: _animationController.value * 1000.0,
                program: _program!,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );

    if (!widget.gesturesEnabled) {
      return content;
    }

    return GestureDetector(
      onScaleUpdate: (details) {
        final provider = context.read<FractalController>();
        final view = provider.view;

        if (details.scale != 1.0) {
          provider.updateZoom(view.zoom * details.scale);
        }

        if (details.focalPointDelta != Offset.zero) {
          final delta = details.focalPointDelta;
          if (module.dimension == FractalDimension.threeD) {
            provider.updateRotation(
              view.rotation +
                  Vector3(delta.dy * 0.01, delta.dx * 0.01, 0),
            );
          } else {
            // Invert panning so dragging the finger moves the view intuitively
            // (i.e., drag right -> scene shifts right).
            final pan = Vector2(
              view.pan.x - delta.dx * 0.005,
              view.pan.y - delta.dy * 0.005,
            );
            provider.updatePan(pan);
          }
        }
      },
      child: content,
    );
  }
}
