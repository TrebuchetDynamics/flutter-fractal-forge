import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

// Compare a structured central patch, not the static background. A small camera
// turn changes shading too, so search for the best pixel displacement rather
// than expecting two rotated renders to be identical translated images.
Offset _renderedDisplacement(Uint8List before, Uint8List after) {
  var bestError = double.infinity;
  var best = Offset.zero;
  for (var dy = -6; dy <= 6; dy++) {
    for (var dx = -6; dx <= 6; dx++) {
      var error = 0.0;
      for (var y = 90; y < 166; y++) {
        for (var x = 64; x < 128; x++) {
          for (var channel = 0; channel < 3; channel++) {
            final difference = before[(y * 192 + x) * 4 + channel] -
                after[((y + dy) * 192 + x + dx) * 4 + channel];
            error += difference * difference;
          }
        }
      }
      if (error < bestError) {
        bestError = error;
        best = Offset(dx.toDouble(), dy.toDouble());
      }
    }
  }
  return best;
}

void main() {
  testWidgets('reported Quaternion Julia view follows each drag direction',
      (tester) async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    controller.selectModule(registry.byId('quaternion_julia_3d'),
        animate: false);
    // The report uses the module's default parameters, with this captured pose.
    final reportedView = controller.view.copyWith(
      zoom: 1,
      pan: Vector2.zero(),
      rotation: Vector3(0.2501456243937165, -0.3915631056666277, 0),
    );
    controller.updateView(reportedView);
    controller.setFluidModeEnabled(true);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 300, height: 600, child: FractalRenderer()),
        ),
      ),
    ));
    // Fluid mode can keep scheduling frames on a real device.
    await tester.pump();
    final renderer = find.byType(FractalRenderer);
    final detector = tester
        .widgetList<GestureDetector>(find.descendant(
            of: renderer, matching: find.byType(GestureDetector)))
        .firstWhere((widget) => widget.onScaleUpdate != null);
    final size = tester.getSize(renderer);
    final center = tester.getCenter(renderer);
    final program = await tester.runAsync(
        () => ui.FragmentProgram.fromAsset(controller.module.shaderAsset));

    Future<Uint8List> render() async {
      final shader = program!.fragmentShader();
      ui.Picture? picture;
      ui.Image? image;
      try {
        controller.module.setUniforms(
          shader,
          FractalRenderState(
            params: controller.params,
            view: controller.view,
            transparentBackground: false,
          ),
          const Size(192, 256),
          0,
        );
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawRect(
            const Rect.fromLTWH(0, 0, 192, 256), Paint()..shader = shader);
        picture = recorder.endRecording();
        image = await picture.toImage(192, 256);
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
      } finally {
        image?.dispose();
        picture?.dispose();
        shader.dispose();
      }
    }

    try {
      final baseline = (await tester.runAsync(render))!;
      for (final direction in {
        'right': const Offset(1, 0),
        'left': const Offset(-1, 0),
        'down': const Offset(0, 1),
        'up': const Offset(0, -1),
      }.entries) {
        controller.updateView(reportedView);
        // Exercise an accepted scale-recognizer update, independent of slop.
        final drag = Offset(direction.value.dx * size.width * 0.05 / math.pi,
            direction.value.dy * size.height * 0.05 / math.pi);
        detector.onScaleStart!(
            ScaleStartDetails(focalPoint: center, pointerCount: 1));
        detector.onScaleUpdate!(ScaleUpdateDetails(
          focalPoint: center + drag,
          focalPointDelta: drag,
          pointerCount: 1,
        ));
        final frame = (await tester.runAsync(render))!;
        final displacement = _renderedDisplacement(baseline, frame);
        debugPrint('Quaternion Julia ${direction.key}: $displacement pixels');
        expect(
          displacement.dx * direction.value.dx +
              displacement.dy * direction.value.dy,
          greaterThan(0),
          reason: 'Rendered detail must follow a ${direction.key} drag',
        );
        expect(controller.view.pan, Vector2.zero());
        expect(controller.view.zoom, 1);
        detector.onScaleEnd!(ScaleEndDetails());
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });
}
