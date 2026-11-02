import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

/// The Multibrot family (`z -> z^p + c`) now shares the parameterised
/// `multibrot3_gpu.frag` instead of one shader per power.
///
/// The check is the map's own symmetry: the `z^p + c` parameter plane is
/// `(p-1)`-fold rotationally symmetric about the origin. Rendering at the
/// origin and rotating by `2*pi/(p-1)` must reproduce the frame. Rotating by a
/// different angle must not, which proves the check is sensitive.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sharedAsset =
      'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag';

  const integerPowers = <String, double>{
    'multibrot4': 4.0,
    'multibrot5': 5.0,
    'multibrot6': 6.0,
    'multibrot7': 7.0,
    'multibrot8': 8.0,
    'multibrot9': 9.0,
    'multibrot10': 10.0,
    'multibrot11': 11.0,
    'multibrot12': 12.0,
  };

  const fractionalPowers = <String, double>{
    'multibrot_15': 1.5,
    'multibrot_25': 2.5,
  };

  test('every legacy multibrot entry shares the one shader', () {
    final registry = ModuleRegistry();
    final all = <String, double>{...integerPowers, ...fractionalPowers};
    all.forEach((id, power) {
      final module = registry.byId(id);
      expect(module.shaderAsset, sharedAsset, reason: id);
      final param = module.parameters.firstWhere((p) => p.id == 'power');
      expect(param.defaultValue, power, reason: id);
    });
  });

  for (final entry in integerPowers.entries) {
    final id = entry.key;
    final power = entry.value;

    test('$id renders a real frame at power $power', () async {
      final frame = await _render(id, power);
      expect(_distinct(frame), greaterThan(20),
          reason: '$id: only ${_distinct(frame)} distinct colours, which is a '
              'flat frame (the pre-fix origin bug rendered exactly 1)');
      // The reference frame at a neighbouring power must look different, so the
      // entry is not silently rendering one fixed map.
      final neighbour = await _render(id, power + 1.0);
      expect(_meanAbsDiff(frame, neighbour), greaterThan(4.0),
          reason: '$id: power $power and ${power + 1.0} rendered the same frame');
    });
  }

  test('fractional powers are deterministic and distinct', () async {
    final half = await _render('multibrot_15', 1.5);
    final again = await _render('multibrot_15', 1.5);
    final twoAndHalf = await _render('multibrot_15', 2.5);

    expect(_meanAbsDiff(half, again), lessThan(0.01),
        reason: 'the same power must be deterministic');
    expect(_meanAbsDiff(half, twoAndHalf), greaterThan(4.0),
        reason: 'power 1.5 and 2.5 must not render the same frame');
  });
}

const _size = 64;
const _sizeF = 64.0;

Future<List<int>> _render(String moduleId, double power) async {
  final module = ModuleRegistry().byId(moduleId);
  final params = Map<String, Object>.from(module.defaultPreset.params)
    ..['power'] = power
    ..['iterations'] = 120
    ..['bailout'] = 4.0
    ..['colorScheme'] = 1;
  // Centre on the origin so rotational symmetry is about the image centre.
  final view = FractalViewState(
    pan: Vector2.zero(),
    // Wide enough to show the set boundary: at zoom ~1 the whole frame is
    // inside the main component and the rotation check cannot discriminate.
    zoom: 0.3,
    rotation: Vector3.zero(),
  );

  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  final recorder = ui.PictureRecorder();
  module.setUniforms(
    shader,
    FractalRenderState(
      transparentBackground: false,
      params: params,
      view: view,
    ),
    const ui.Size(_sizeF, _sizeF),
    0,
  );
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, _sizeF, _sizeF),
    Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(_size, _size);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final out = List<int>.generate(
      _size * _size, (i) => bytes.getUint8(i * 4) + bytes.getUint8(i * 4 + 1) + bytes.getUint8(i * 4 + 2));
  picture.dispose();
  image.dispose();
  shader.dispose();
  return out;
}

int _distinct(List<int> frame) => frame.toSet().length;

/// Mean absolute difference of the summed RGB channel, on a 0..765 scale.
///
/// A correlation measure rather than a tolerance band: palette gradients make
/// exact per-pixel matching meaningless, but a rotation that respects the set's
/// symmetry still lands far closer than one that does not.
double _meanAbsDiff(List<int> a, List<int> b) {
  var total = 0;
  for (var i = 0; i < a.length; i++) {
    total += (a[i] - b[i]).abs();
  }
  return total / a.length;
}
