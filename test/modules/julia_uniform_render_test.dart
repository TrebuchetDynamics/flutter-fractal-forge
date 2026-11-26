import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

const _side = 96;
const _size = ui.Size.square(96);

Future<Uint32List> _render(void Function(ui.Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(ui.Canvas(recorder));
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(_side, _side);
    try {
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      return bytes.buffer.asUint32List(bytes.offsetInBytes, _side * _side);
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();

  for (final (id, previousId) in [
    ('phoenix_julia', 'f0132_phoenix_d_3'),
    ('mandel_julia_dual', 'julia_dual'),
  ]) {
    group(id, () {
      final module = registry.byId(id);
      late FractalController controller;
      late ui.FragmentProgram program;
      late ui.FragmentShader shader;

      setUp(() async {
        controller = FractalController(registry);
        addTearDown(controller.dispose);
        controller.selectModule(module, animate: false);
        program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
        shader = program.fragmentShader();
        addTearDown(shader.dispose);
      });

      Future<Uint32List> render() => _render((canvas) {
            FractalCanvas(
              module: controller.module,
              state: FractalRenderState(
                params: controller.params,
                view: controller.view,
                transparentBackground: controller.transparentBackground,
              ),
              shader: shader,
              time: 0,
            ).paint(canvas, _size);
          });

      test('transparency changes alpha without recoloring opaque pixels',
          () async {
        final opaque = await render();
        controller.setTransparentBackground(true);
        final transparent = await render();
        var exposed = 0;
        var retained = 0;
        var recolored = 0;
        for (var i = 0; i < opaque.length; i++) {
          if (transparent[i] == 0) {
            exposed++;
          } else {
            retained++;
            if (transparent[i] != opaque[i]) recolored++;
          }
        }
        expect(recolored, 0, reason: 'opaque pixels changed after toggling');
        expect(exposed, greaterThan(0), reason: 'no pixels became transparent');
        expect(retained, greaterThan(0), reason: 'no opaque pixels remained');
      });

      for (final (parameter, slot, value) in [
        ('juliaCReal', 9, -0.3),
        ('juliaCImag', 10, -0.5),
      ]) {
        test('$parameter drives shader slot $slot', () async {
          final before = await render();
          controller.updateParam(parameter, value);
          final changed = await render();
          expect(changed, isNot(equals(before)),
              reason: '$parameter had no effect');

          // Independent reference: write the inputs in GLSL declaration order.
          final params = module.defaultPreset.params;
          final view = controller.view;
          final reference = program.fragmentShader();
          addTearDown(reference.dispose);
          final uniforms = <double>[
            0,
            _size.width,
            _size.height,
            view.pan.x,
            view.pan.y,
            view.zoom,
            (params['iterations'] as num).toDouble(),
            (params['bailout'] as num).toDouble(),
            (params['colorScheme'] as num).toDouble(),
            (params['juliaCReal'] as num).toDouble(),
            (params['juliaCImag'] as num).toDouble(),
            if (id == 'phoenix_julia') ...[-0.5, 2],
            0,
          ];
          uniforms[slot] = value;
          for (var i = 0; i < uniforms.length; i++) {
            reference.setFloat(i, uniforms[i]);
          }
          final expected = await _render((canvas) => canvas.drawRect(
              ui.Offset.zero & _size, ui.Paint()..shader = reference));
          expect(changed, orderedEquals(expected));
        });
      }

      test(
          'drawing after a module using the same shader yields the fresh image',
          () async {
        final first = await render();
        final previous = registry.byId(previousId);
        expect(previous.shaderAsset, module.shaderAsset);
        controller.selectModule(previous, animate: false);
        controller.setTransparentBackground(true);
        await render();
        controller.selectModule(module, animate: false);
        controller.setTransparentBackground(false);
        expect(await render(), orderedEquals(first));
      });
    });
  }
}
