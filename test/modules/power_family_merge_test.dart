import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

/// The Tricorn, Celtic, Buffalo and Perpendicular power families now share one
/// shader each, with the exponent as a control. These tests check the wiring
/// and that the controls actually change the rendered map.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const f = 'shaders/escape_time_family/families';
  const tricornPower = '$f/tricorn/parameter_plane/tricorn_gpu.frag';
  const tricornJulia = '$f/tricorn/julia_sets/tricorn_power_julia_gpu.frag';
  const celticPower = '$f/celtic/power_plane/celtic_power_gpu.frag';
  const celticJulia = '$f/celtic/julia/celtic_power_julia_gpu.frag';
  const buffaloPower = '$f/buffalo/power_plane/buffalo_power_gpu.frag';
  const buffaloJulia = '$f/buffalo/julia/buffalo_power_julia_gpu.frag';
  const perpPower = '$f/perpendicular/perpendicular_bs_power_gpu.frag';
  const perpJulia = '$f/perpendicular/perpendicular_bs_power_julia_gpu.frag';

  // id: (asset, power, julia constant or null, fold axis or null)
  const entries = <String, (String, double, (double, double)?, double?)>{
    'tricorn_cubic': (tricornPower, 3.0, null, null),
    'tricorn_power4': (tricornPower, 4.0, null, null),
    'tricorn_power5': (tricornPower, 5.0, null, null),
    'tricorn_cubic_julia': (tricornJulia, 3.0, (0.10, 0.55), null),
    'tricorn_power8_julia': (tricornJulia, 8.0, (-0.20, 0.50), null),
    'celtic_cubic': (celticPower, 3.0, null, null),
    'celtic_power7': (celticPower, 7.0, null, null),
    'celtic_cubic_julia': (celticJulia, 3.0, (-0.32, 0.60), null),
    'celtic_power6_julia': (celticJulia, 6.0, (-0.30, 0.50), null),
    'buffalo_cubic': (buffaloPower, 3.0, null, null),
    'buffalo_power7': (buffaloPower, 7.0, null, null),
    'buffalo_cubic_julia': (buffaloJulia, 3.0, (-0.35, 0.55), null),
    'buffalo_power6_julia': (buffaloJulia, 6.0, (-0.50, 0.50), null),
    'perpendicular_burning_ship': (perpPower, 2.0, null, 0.0),
    'perpendicular_bs_cubic': (perpPower, 3.0, null, 0.0),
    'perpendicular_bs_power5': (perpPower, 5.0, null, 1.0),
    'perpendicular_burning_ship_julia': (perpJulia, 2.0, (-0.90, 0.30), null),
    'perpendicular_bs_cubic_julia': (perpJulia, 3.0, (-0.52, 0.35), null),
  };

  test('every merged entry points at its family shader with the right controls',
      () {
    final registry = ModuleRegistry();
    entries.forEach((id, spec) {
      final (asset, power, julia, axis) = spec;
      final module = registry.byId(id);
      expect(module.shaderAsset, asset, reason: id);
      double param(String name) => (module.parameters
              .firstWhere((p) => p.id == name)
              .defaultValue as num)
          .toDouble();
      expect(param('power'), power, reason: id);
      if (julia != null) {
        expect(param('juliaRe'), julia.$1, reason: id);
        expect(param('juliaImag'), julia.$2, reason: id);
      }
      if (axis != null) {
        expect(param('foldAxis'), axis, reason: id);
      }
    });
  });

  for (final id in const [
    'tricorn_cubic',
    'tricorn_cubic_julia',
    'celtic_cubic',
    'celtic_cubic_julia',
    'buffalo_cubic',
    'buffalo_cubic_julia',
    'perpendicular_burning_ship',
    'perpendicular_burning_ship_julia',
  ]) {
    test('$id renders a real frame', () async {
      final frame = await _render(id);
      expect(_distinct(frame), greaterThan(20),
          reason: '$id: ${_distinct(frame)} distinct colours is a flat frame');
    });
  }

  test('the power control changes the map for every family', () async {
    for (final id in const [
      'tricorn_cubic',
      'tricorn_cubic_julia',
      'celtic_cubic',
      'celtic_cubic_julia',
      'buffalo_cubic',
      'buffalo_cubic_julia',
      'perpendicular_burning_ship',
      'perpendicular_burning_ship_julia',
    ]) {
      final atDefault = await _render(id);
      final shifted = await _render(id, power: 4.0);
      // Some Julia frames keep most pixels inside the set, so the difference is
      // small but must be non-zero: the map, not the palette, has to change.
      expect(_meanAbsDiff(atDefault, shifted), greaterThan(1.5),
          reason: '$id: changing power did not change the frame');
    }
  });

  test('the fold axis control selects between the two documented maps',
      () async {
    // Same power, different axis: the two conventions must not coincide.
    final realFold = await _render('perpendicular_burning_ship', power: 2.0);
    final imaginaryFold = await _render('perpendicular_bs_power5', power: 2.0);
    expect(_meanAbsDiff(realFold, imaginaryFold), greaterThan(4.0),
        reason: 'fold axis 0 and 1 rendered the same map');
  });

  test('the Julia constant control changes the map', () async {
    final base = await _render('celtic_cubic_julia');
    final shifted = await _render('celtic_cubic_julia', juliaRe: -0.60);
    expect(_meanAbsDiff(base, shifted), greaterThan(4.0),
        reason: 'changing the Julia constant did not change the frame');
  });
}

const _size = 64;
const _sizeF = 64.0;

Future<List<int>> _render(
  String moduleId, {
  double? power,
  double? juliaRe,
  double? juliaImag,
}) async {
  final module = ModuleRegistry().byId(moduleId);
  final params = Map<String, Object>.from(module.defaultPreset.params)
    ..['iterations'] = 120
    ..['bailout'] = 4.0
    ..['colorScheme'] = 1;
  if (power != null) params['power'] = power;
  if (juliaRe != null) params['juliaRe'] = juliaRe;
  if (juliaImag != null) params['juliaImag'] = juliaImag;

  final view = FractalViewState(
    pan: Vector2.zero(),
    zoom: 0.5,
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
      _size * _size,
      (i) =>
          bytes.getUint8(i * 4) +
          bytes.getUint8(i * 4 + 1) +
          bytes.getUint8(i * 4 + 2));
  picture.dispose();
  image.dispose();
  shader.dispose();
  return out;
}

int _distinct(List<int> frame) => frame.toSet().length;

double _meanAbsDiff(List<int> a, List<int> b) {
  var total = 0;
  for (var i = 0; i < a.length; i++) {
    total += (a[i] - b[i]).abs();
  }
  return total / a.length;
}
