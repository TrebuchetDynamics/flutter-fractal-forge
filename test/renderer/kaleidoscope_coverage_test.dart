import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<int>> render(
    ui.FragmentShader shader, {
    int sectors = 6,
    int mode = 0,
    bool mirror = true,
    double rotation = 0,
    bool glow = false,
    ui.Size size = const ui.Size(128, 128),
  }) async {
    final view = FractalViewState.initial();
    final module = FractalModule(
      id: 'coverage',
      displayName: (_) => 'Coverage',
      dimension: FractalDimension.twoD,
      shaderAsset: 'shaders/diagnostic/test_always_red.frag',
      parameters: const [],
      defaultPreset: FractalPreset(
        id: 'coverage.default',
        moduleId: 'coverage',
        name: 'Default',
        params: const {},
        view: view,
        createdAt: DateTime(2026),
      ),
      builtInPresets: const [],
      setUniforms: (_, __, ___, ____) {},
    );
    final recorder = ui.PictureRecorder();
    FractalCanvas(
      module: module,
      state: FractalRenderState(
        params: const {},
        view: view,
        transparentBackground: false,
      ),
      time: 0,
      shader: shader,
      kaleidoscopeEnabled: true,
      kaleidoscopeSectors: sectors,
      kaleidoscopeMirrorMode: mode,
      kaleidoscopeMirror: mirror,
      kaleidoscopeRotation: rotation,
      glowEnabled: glow,
    ).paint(ui.Canvas(recorder), size);
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    try {
      return (await image.toByteData())!.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  Future<ui.FragmentShader> load(String name) async {
    final program =
        await ui.FragmentProgram.fromAsset('shaders/diagnostic/$name.frag');
    final shader = program.fragmentShader();
    addTearDown(shader.dispose);
    return shader;
  }

  int nonOpaquePixels(List<int> pixels) {
    var count = 0;
    for (var i = 3; i < pixels.length; i += 4) {
      if (pixels[i] != 255) count++;
    }
    return count;
  }

  test('six mirrored sectors cover the whole canvas', () async {
    final shader = await load('test_always_red');
    expect(nonOpaquePixels(await render(shader)), 0);
  });

  test('sector coverage survives all modes, rotations, aspect ratios and glow',
      () async {
    final shader = await load('test_always_red');
    for (final size in [
      const ui.Size(64, 64),
      const ui.Size(96, 64),
      const ui.Size(64, 96)
    ]) {
      for (var sectors = 4; sectors <= 16; sectors += 2) {
        for (var mode = 0; mode <= 3; mode++) {
          for (final rotation in [0.0, 0.37, -1.2]) {
            for (final glow in [false, true]) {
              final pixels = await render(shader,
                  size: size,
                  sectors: sectors,
                  mode: mode,
                  rotation: rotation,
                  glow: glow);
              expect(nonOpaquePixels(pixels), 0,
                  reason:
                      'size=$size, sectors=$sectors, mode=$mode, rotation=$rotation, glow=$glow');
            }
          }
        }
      }
    }
  });

  test('reflections change artwork without moving sector coverage', () async {
    final shader = await load('test_flutter_coord');
    shader.setFloat(0, 128);
    shader.setFloat(1, 128);
    final plain = await render(shader, mirror: false);
    final mirrored = await render(shader, mode: 1);
    final noReflectionMode = await render(shader, mode: 3);
    expect(mirrored, isNot(orderedEquals(plain)));
    expect(noReflectionMode, orderedEquals(plain));
    expect(nonOpaquePixels(mirrored), 0);
  });
}
