import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog_impl.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final shader = File(
    'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
  ).readAsStringSync();
  final kifs = raymarched3DCatalog.singleWhere(
    (config) => config.id == 'kifs_menger',
  );
  final cross = raymarched3DCatalog.singleWhere(
    (config) => config.id == 'f0597_sierpinski_carpet_3d_menger_cross',
  );

  test('KIFS Menger uses a bounded, escape-terminating fold estimator', () {
    expect(kifs.defaultIterations, 8);
    expect(kifs.maxIterations, 8);
    expect(kifs.extraPresets.single.params['iterations'], 8);
    expect(shader, contains('const int MAX_KIFS_ITERATIONS = 8;'));
    expect(shader, contains('float boxSDF(vec3 p)'));
    expect(shader, contains('float mengerSpongeDE(vec3 p, int maxIter)'));
    expect(shader, contains('if (cellDistance > 0.0)'));
    expect(shader, contains('return boxSDF(p) / accumulatedScale;'));
  });

  test('Menger Cross keeps its existing variant path and settings', () {
    expect(cross.shaderAsset, kifs.shaderAsset);
    expect(cross.defaultIterations, 12);
    expect(cross.maxIterations, 20);
    expect(cross.defaultFractalType, 1);
    expect(shader, contains('float mengerCrossDE(vec3 p, int maxIter)'));
  });

  test('KIFS Menger and Menger Cross rasterize distinct frames', () async {
    const size = 96;
    final program = await ui.FragmentProgram.fromAsset(kifs.shaderAsset);
    final spongeUniforms = <double>[
      0.0,
      size.toDouble(),
      size.toDouble(),
      0.0,
      0.0,
      1.0,
      0.3,
      -0.4,
      0.0,
      3.0,
      8.0,
      120.0,
      4.0,
      0.0,
      0.0,
      0.0,
    ];
    final crossUniforms = List<double>.of(spongeUniforms)
      ..[10] = 12.0
      ..[14] = 1.0;

    final sponge = await _renderShader(program, spongeUniforms, size);
    final crossFrame = await _renderShader(program, crossUniforms, size);
    var differingPixels = 0;
    var brightSpongePixels = 0;
    var brightCrossPixels = 0;
    for (var i = 0; i < sponge.length; i += 4) {
      if (sponge[i] != crossFrame[i] ||
          sponge[i + 1] != crossFrame[i + 1] ||
          sponge[i + 2] != crossFrame[i + 2]) {
        differingPixels++;
      }
      if (sponge[i] + sponge[i + 1] + sponge[i + 2] > 180) {
        brightSpongePixels++;
      }
      if (crossFrame[i] + crossFrame[i + 1] + crossFrame[i + 2] > 180) {
        brightCrossPixels++;
      }
    }

    expect(sponge.length, size * size * 4);
    expect(crossFrame.length, size * size * 4);
    expect(brightSpongePixels, greaterThan(0));
    expect(brightCrossPixels, greaterThan(0));
    expect(differingPixels, greaterThan(0));
  });

  test('KIFS Menger survives its maximum interactive quality settings',
      () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(kifs.shaderAsset);
    final frame = await _renderShader(
      program,
      <double>[
        0.0,
        size.toDouble(),
        size.toDouble(),
        0.0,
        0.0,
        2.0,
        0.5,
        0.3,
        0.0,
        5.0,
        8.0,
        150.0,
        4.0,
        0.0,
        0.0,
        0.0,
      ],
      size,
    );

    expect(frame.length, size * size * 4);
  });

  test('registered Mandelbulb still rasterizes its 3D shader', () async {
    const size = 64;
    final module = ModuleRegistry().byId('mandelbulb');
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final frame = await _renderShader(
      program,
      <double>[
        0.0,
        size.toDouble(),
        size.toDouble(),
        0.0,
        0.0,
        1.0,
        0.3,
        -0.4,
        0.0,
        8.0,
        10.0,
        80.0,
        2.0,
        0.0,
        0.0,
        0.0,
      ],
      size,
    );
    final colors = <int>{};
    var brightPixels = 0;
    for (var i = 0; i < frame.length; i += 4) {
      colors.add((frame[i] << 16) | (frame[i + 1] << 8) | frame[i + 2]);
      if (frame[i] + frame[i + 1] + frame[i + 2] > 180) brightPixels++;
    }

    expect(frame.length, size * size * 4);
    expect(colors.length, greaterThan(8));
    expect(brightPixels, greaterThan(0));
  });

  test(
      'folded Menger distance classifies the central hole and a retained corner',
      () {
    expect(
      _mengerFoldDistance([0.0, 0.0, 0.0], iterations: 1),
      closeTo(math.sqrt(2.0) / 3.0, 1e-12),
    );
    expect(
      _mengerFoldDistance([0.8, 0.8, 0.8], iterations: 1),
      closeTo(-0.2, 1e-12),
    );
  });
}

Future<List<int>> _renderShader(
  ui.FragmentProgram program,
  List<double> uniforms,
  int size,
) async {
  final shader = program.fragmentShader();
  for (var i = 0; i < uniforms.length; i++) {
    shader.setFloat(i, uniforms[i]);
  }

  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    ui.Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  ui.Image? image;
  try {
    image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) throw StateError('Missing rendered pixel bytes.');
    return bytes.buffer.asUint8List();
  } finally {
    image?.dispose();
    picture.dispose();
    shader.dispose();
  }
}

double _mengerFoldDistance(List<double> input, {required int iterations}) {
  var p = List<double>.of(input);
  var accumulatedScale = 1.0;
  for (var i = 0; i < iterations; i++) {
    p = p.map((value) => value.abs()).toList();
    if (p[0] < p[1]) _swap(p, 0, 1);
    if (p[0] < p[2]) _swap(p, 0, 2);
    if (p[1] < p[2]) _swap(p, 1, 2);
    p = p.map((value) => value * 3.0 - 2.0).toList();
    if (p[2] < -1.0) p[2] += 2.0;
    accumulatedScale *= 3.0;
  }

  final q = p.map((value) => value.abs() - 1.0).toList();
  final outsideDistance = math.sqrt(
    q.map((value) => math.pow(math.max(value, 0.0), 2)).reduce((a, b) => a + b),
  );
  final insideDistance = math.min(
    math.max(q[0], math.max(q[1], q[2])),
    0.0,
  );
  return (outsideDistance + insideDistance) / accumulatedScale;
}

void _swap(List<double> values, int first, int second) {
  final value = values[first];
  values[first] = values[second];
  values[second] = value;
}
