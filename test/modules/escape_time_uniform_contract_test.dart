import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

const _samplerExclusions = {
  'number_wall', // The viewer generates and binds the grid outside the setter.
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();

  test('registry shader output is independent of previous float slots',
      () async {
    const side = 32;
    const size = ui.Size.square(side * 1.0);
    final failures = <String>[];
    final skipped = <String>{};

    for (final module in registry.modules) {
      if (_samplerExclusions.contains(module.id)) {
        skipped.add(module.id);
        continue;
      }

      final shaderSource = File(module.shaderAsset).readAsStringSync();
      final slots = _countFlutterFloatSlots(shaderSource);
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      final shader = program.fragmentShader();
      final preset = module.defaultPreset;
      final painter = FractalCanvas(
        module: module,
        state: FractalRenderState(
          params: preset.params,
          view: preset.view,
          transparentBackground: false,
        ),
        shader: shader,
        time: 0,
      );

      Future<Uint32List> render(double seed) {
        for (var slot = 0; slot < slots; slot++) {
          shader.setFloat(slot, seed);
        }
        return _render(side, (canvas) => painter.paint(canvas, size));
      }

      try {
        final fresh = await render(0);
        final reused = await render(0.37);
        var changed = 0;
        for (var i = 0; i < fresh.length; i++) {
          if (fresh[i] != reused[i]) changed++;
        }
        if (changed != 0) {
          failures.add('${module.id} (${module.shaderAsset}): '
              '$changed/${fresh.length} pixels changed');
        }
      } finally {
        shader.dispose();
      }
    }

    expect(skipped, _samplerExclusions);
    expect(failures, isEmpty, reason: failures.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('Halley renders unit relaxation first and after Halley Nova', () async {
    const side = 96;
    const size = ui.Size.square(side * 1.0);
    final halley = registry.byId('halley');
    final nova = registry.byId('halley_nova');
    expect(nova.shaderAsset, halley.shaderAsset);
    final program = await ui.FragmentProgram.fromAsset(halley.shaderAsset);
    final shader = program.fragmentShader();
    addTearDown(shader.dispose);
    final controller = FractalController(registry);
    addTearDown(controller.dispose);

    Future<Uint32List> selectAndRender(FractalModule module,
        {double? relaxation}) {
      controller.selectModule(module, animate: false);
      if (relaxation != null) controller.updateParam('relaxation', relaxation);
      return _render(side, (canvas) {
        FractalCanvas(
          module: controller.module,
          state: FractalRenderState(
            params: controller.params,
            view: controller.view,
            transparentBackground: controller.transparentBackground,
          ),
          shader: shader,
          time: 0,
        ).paint(canvas, size);
      });
    }

    final fresh = await selectAndRender(halley);
    final reference = program.fragmentShader();
    addTearDown(reference.dispose);
    // Bind in halley_gpu.frag declaration order, independently of the setter.
    final uniforms = <double>[
      0,
      size.width,
      size.height,
      controller.view.pan.x,
      controller.view.pan.y,
      controller.view.zoom,
      for (final id in ['iterations', 'bailout', 'colorScheme'])
        (controller.params[id] as num).toDouble(),
      0,
      1,
    ];
    for (var i = 0; i < uniforms.length; i++) {
      reference.setFloat(i, uniforms[i]);
    }
    final expected = await _render(
        side,
        (canvas) => canvas.drawRect(
            ui.Offset.zero & size, ui.Paint()..shader = reference));

    await selectAndRender(nova, relaxation: 1.7);
    final afterNova = await selectAndRender(halley);
    expect(fresh, orderedEquals(expected), reason: 'Halley must step at 1.0');
    expect(afterNova, orderedEquals(fresh),
        reason: 'Halley inherited Nova state');
  });
  test('escape-time shaders expose slots for declared extra params', () {
    final failures = <String>[];

    for (final config in escapeTimeCatalog) {
      if (config.extraParams.isEmpty) continue;

      final shaderFile = File(config.shaderAsset);
      expect(
        shaderFile.existsSync(),
        isTrue,
        reason: 'Shader asset missing for ${config.id}: ${config.shaderAsset}',
      );

      final floatSlotCount =
          _countFlutterFloatSlots(shaderFile.readAsStringSync());
      final requiredSlots =
          EscapeTimeUniformSlots.extraStart + config.extraParams.length;
      if (floatSlotCount < requiredSlots) {
        failures.add(
          '${config.id} declares ${config.extraParams.length} extra params but '
          '${config.shaderAsset} exposes $floatSlotCount float slots; '
          'requires at least $requiredSlots.',
        );
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

Future<Uint32List> _render(int side, void Function(ui.Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  try {
    paint(canvas);
  } catch (_) {
    recorder.endRecording().dispose();
    rethrow;
  }
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(side, side);
    try {
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      return bytes.buffer.asUint32List(bytes.offsetInBytes, side * side);
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

int _countFlutterFloatSlots(String shaderSource) {
  const slotWidths = {
    'float': 1,
    'int': 1,
    'bool': 1,
    'vec2': 2,
    'vec3': 3,
    'vec4': 4,
  };
  final source =
      shaderSource.replaceAll(RegExp(r'//[^\n]*|/\*[\s\S]*?\*/'), '');
  final uniformPattern = RegExp(
      r'\buniform\s+(float|int|bool|vec2|vec3|vec4)\s+\w+\s*(?:\[\s*(\d+)\s*\])?\s*;');
  return uniformPattern.allMatches(source).fold<int>(0, (sum, match) {
    final length = int.parse(match.group(2) ?? '1');
    return sum + slotWidths[match.group(1)]! * length;
  });
}
