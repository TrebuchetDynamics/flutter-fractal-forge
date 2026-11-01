import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart';

/// Visual and wiring contracts for the additions researched in
/// `research/beautiful-fractals-next/report.md`.
const _escapeTimeShaders = <String, String>{
  'inversion_fold_lattice':
      'shaders/escape_time_family/experimental_named/rational_singularities/inversion_fold_lattice_gpu.frag',
  'chladni_nodal_field': 'shaders/number_theory/chladni_nodal_field_gpu.frag',
  'domain_warp_nebula':
      'shaders/cellular_and_stochastic/domain_warp_nebula_gpu.frag',
};

const _imordialShader =
    'shaders/3d_and_hypercomplex/raymarched_volumes/imordial_brot_gpu.frag';

Future<Uint8List> _render(
  FractalModule module, {
  required int size,
  Map<String, Object> params = const {},
  FractalViewState? view,
  double time = 0,
  bool transparent = false,
}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  ui.Picture? picture;
  ui.Image? frame;
  try {
    module.setUniforms(
      shader,
      FractalRenderState(
        transparentBackground: transparent,
        params: {...module.defaultPreset.params, ...params},
        view: view ?? module.defaultPreset.view,
      ),
      ui.Size(size.toDouble(), size.toDouble()),
      time,
    );
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..shader = shader,
    );
    picture = recorder.endRecording();
    frame = await picture.toImage(size, size);
    final bytes = await frame.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(bytes, isNotNull, reason: module.shaderAsset);
    return bytes!.buffer.asUint8List();
  } finally {
    frame?.dispose();
    picture?.dispose();
    shader.dispose();
  }
}

RenderAuditMetrics _metrics(Uint8List bytes, int size) {
  final image = img.Image.fromBytes(
    width: size,
    height: size,
    bytes: bytes.buffer,
    numChannels: 4,
  );
  return RenderAuditMetrics.fromImage(image);
}

int _differingPixels(Uint8List a, Uint8List b) {
  var count = 0;
  for (var offset = 0; offset < a.length; offset += 4) {
    if ((a[offset] - b[offset]).abs() > 2 ||
        (a[offset + 1] - b[offset + 1]).abs() > 2 ||
        (a[offset + 2] - b[offset + 2]).abs() > 2) {
      count++;
    }
  }
  return count;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final registry = ModuleRegistry();

  group('registration', () {
    test('new escape-time entries are declared with their shader assets', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final entry in _escapeTimeShaders.entries) {
        final config =
            escapeTimeCatalog.singleWhere((item) => item.id == entry.key);
        expect(config.shaderAsset, entry.value, reason: entry.key);
        expect(File(entry.value).existsSync(), isTrue, reason: entry.key);
        expect(pubspec, contains('- ${entry.value}'), reason: entry.key);
        expect(config.maxIterations, greaterThan(20), reason: entry.key);
      }
    });

    test('imordial brot is a registered 3D module with a variant selector', () {
      final config = raymarched3DCatalog
          .singleWhere((entry) => entry.id == 'imordial_brot');
      expect(config.shaderAsset, _imordialShader);
      expect(pubspec(), contains('- $_imordialShader'));
      expect(config.maxFractalType, 3);
      expect(config.fractalTypeOptions, hasLength(4));
      expect(config.extraParams.map((param) => param.id), contains('sliceW'));

      final module = registry.byId('imordial_brot');
      expect(module.dimension, FractalDimension.threeD);
      expect(module.animationCapability, FractalAnimationCapability.timeDriven);
      expect(
        module.parameters.map((parameter) => parameter.id),
        contains('fractalType'),
      );
    });

    test('new shaders are single-pass and sampler-free', () {
      for (final asset in [..._escapeTimeShaders.values, _imordialShader]) {
        final source = File(asset).readAsStringSync();
        expect(RegExp(r'uniform\s+sampler').hasMatch(source), isFalse,
            reason: asset);
        expect(source, isNot(contains('texture(')), reason: asset);
        expect(source, contains('#include <flutter/runtime_effect.glsl>'),
            reason: asset);
      }
    });

    test('shader sources keep the researched operators', () {
      expect(
          File(_escapeTimeShaders['inversion_fold_lattice']!)
              .readAsStringSync(),
          contains('abs(p) / max(d2, 1e-6) - c'));
      expect(
          File(_escapeTimeShaders['chladni_nodal_field']!).readAsStringSync(),
          contains('modalPair'));
      expect(File(_escapeTimeShaders['domain_warp_nebula']!).readAsStringSync(),
          contains('warp * r * 1.3'));
      final imordial = File(_imordialShader).readAsStringSync();
      expect(imordial, contains('e_a * e_b = sgn(b - a) * e_b'));
      expect(imordial, contains('imSquareJv'));
      expect(imordial, contains('imMul(square, z)'));
      expect(imordial, contains('imMul(z, square)'));
    });
  });

  group('escape-time visual health', () {
    for (final id in _escapeTimeShaders.keys) {
      test('$id renders structured, non-blank output', () async {
        const size = 128;
        final module = registry.byId(id);
        final bytes = await _render(module, size: size);
        final metrics = _metrics(bytes, size);

        expect(metrics.verdict, 'pass', reason: '$id ${metrics.toJson()}');
        expect(metrics.uniqueRgbColors, greaterThan(128), reason: id);
        expect(metrics.luminanceStdDev, greaterThan(8), reason: id);
        expect(metrics.nonBlackPixelRatio, greaterThan(0.10), reason: id);
      });

      test('$id controls change the rendered image', () async {
        const size = 96;
        final module = registry.byId(id);
        final baseline = await _render(module, size: size);
        for (final parameter in module.parameters) {
          // colorScheme is covered by the preset-distinctness test; bailout is a
          // shared-ABI slot that the field shaders document as unused.
          if (parameter.id == 'colorScheme' || parameter.id == 'bailout') {
            continue;
          }
          final fallback = parameter.defaultValue as num;
          final candidate = parameter.id == 'iterations'
              ? fallback.toDouble() + 6
              : (fallback.toDouble() <= (parameter.min + parameter.max) / 2
                  ? parameter.max.toDouble()
                  : parameter.min.toDouble());
          final bumped = await _render(
            module,
            size: size,
            params: {parameter.id: candidate},
          );
          expect(
            _differingPixels(baseline, bumped),
            greaterThan(size * size ~/ 200),
            reason: '$id: ${parameter.id} does not affect the image',
          );
        }
      });

      test('$id curated presets are visually distinct', () async {
        const size = 96;
        final module = registry.byId(id);
        final images = <String, Uint8List>{};
        for (final preset in module.builtInPresets) {
          images[preset.id] = await _render(
            module,
            size: size,
            params: preset.params,
            view: preset.view,
          );
        }
        final ids = images.keys.toList();
        for (var i = 0; i < ids.length; i++) {
          for (var j = i + 1; j < ids.length; j++) {
            expect(
              _differingPixels(images[ids[i]]!, images[ids[j]]!),
              greaterThan(size * size ~/ 400),
              reason: '$id: ${ids[i]} vs ${ids[j]} are identical',
            );
          }
        }
      });
    }
  });

  group('imordial brot', () {
    const variants = <int, String>{
      0: 'Quadratic',
      1: 'Quadratic Julia',
      2: 'Cubic (zz)z',
      3: 'Cubic z(zz)',
    };

    for (final variant in variants.entries) {
      test('variant ${variant.key} (${variant.value}) renders a solid body',
          () async {
        const size = 96;
        final module = registry.byId('imordial_brot');
        final bytes = await _render(
          module,
          size: size,
          params: {'fractalType': variant.key},
        );
        final metrics = _metrics(bytes, size);

        expect(metrics.verdict, 'pass',
            reason: '${variant.value} ${metrics.toJson()}');
        // A hit surface must cover a meaningful part of the frame: the body is
        // centred, so the middle band has to be lit.
        var litCenter = 0;
        for (var y = size ~/ 3; y < size * 2 ~/ 3; y++) {
          for (var x = size ~/ 3; x < size * 2 ~/ 3; x++) {
            final offset = (y * size + x) * 4;
            final luminance = 0.2126 * bytes[offset] +
                0.7152 * bytes[offset + 1] +
                0.0722 * bytes[offset + 2];
            if (luminance > 20) litCenter++;
          }
        }
        expect(litCenter, greaterThan(size * size ~/ 40),
            reason: '${variant.value} centre is empty');
        expect(metrics.uniqueRgbColors, greaterThan(256),
            reason: variant.value);
      }, timeout: const Timeout(Duration(minutes: 3)));
    }

    test('variant selector produces four different bodies', () async {
      const size = 88;
      final module = registry.byId('imordial_brot');
      final images = <int, Uint8List>{};
      for (final variant in variants.keys) {
        images[variant] = await _render(
          module,
          size: size,
          params: {'fractalType': variant},
        );
      }
      final keys = images.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        for (var j = i + 1; j < keys.length; j++) {
          expect(
            _differingPixels(images[keys[i]]!, images[keys[j]]!),
            greaterThan(size * size ~/ 100),
            reason: 'variants ${keys[i]} and ${keys[j]} are identical',
          );
        }
      }
    }, timeout: const Timeout(Duration(minutes: 4)));

    test('section roll and 4D slice offsets change the body', () async {
      const size = 80;
      final module = registry.byId('imordial_brot');
      final baseline = await _render(module, size: size);

      final rolled = await _render(
        module,
        size: size,
        params: {'power': 62.0},
      );
      expect(_differingPixels(baseline, rolled), greaterThan(size * size ~/ 40),
          reason: 'section roll has no effect');

      final sliced = await _render(
        module,
        size: size,
        params: {'sliceW': 0.62},
      );
      expect(_differingPixels(baseline, sliced), greaterThan(size * size ~/ 60),
          reason: '4D slice offset has no effect');
    }, timeout: const Timeout(Duration(minutes: 3)));

    test('curated presets render their documented framing', () async {
      const size = 88;
      final module = registry.byId('imordial_brot');
      for (final preset in module.builtInPresets) {
        final bytes = await _render(
          module,
          size: size,
          params: preset.params,
          view: preset.view,
        );
        final metrics = _metrics(bytes, size);
        expect(metrics.verdict, 'pass',
            reason: '${preset.id} ${metrics.toJson()}');
      }
    }, timeout: const Timeout(Duration(minutes: 4)));

    test('transparent background keeps premultiplied alpha', () async {
      const size = 80;
      final module = registry.byId('imordial_brot');
      final bytes = await _render(module, size: size, transparent: true);
      var clear = 0;
      for (var offset = 0; offset < bytes.length; offset += 4) {
        final alpha = bytes[offset + 3];
        if (alpha == 0) clear++;
        expect(bytes[offset], lessThanOrEqualTo(alpha), reason: 'red');
        expect(bytes[offset + 1], lessThanOrEqualTo(alpha), reason: 'green');
        expect(bytes[offset + 2], lessThanOrEqualTo(alpha), reason: 'blue');
      }
      expect(clear, greaterThan(size * size ~/ 8));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  test('export review images for the new entries', () async {
    const size = 320;
    final directory = Directory('test/results/high-impact-visuals')
      ..createSync(recursive: true);

    for (final id in _escapeTimeShaders.keys) {
      final module = registry.byId(id);
      for (final preset in module.builtInPresets) {
        final bytes = await _render(
          module,
          size: size,
          params: preset.params,
          view: preset.view,
        );
        final image = img.Image.fromBytes(
          width: size,
          height: size,
          bytes: bytes.buffer,
          numChannels: 4,
        );
        File('${directory.path}/$id-${preset.id}.png')
            .writeAsBytesSync(img.encodePng(image));
      }
    }

    final module = registry.byId('imordial_brot');
    for (final preset in module.builtInPresets) {
      final bytes = await _render(
        module,
        size: size,
        params: preset.params,
        view: preset.view,
      );
      final image = img.Image.fromBytes(
        width: size,
        height: size,
        bytes: bytes.buffer,
        numChannels: 4,
      );
      File('${directory.path}/imordial_brot-${preset.id}.png')
          .writeAsBytesSync(img.encodePng(image));
    }
  }, skip: !const bool.fromEnvironment('EXPORT_HIGH_IMPACT_VISUALS'));

  test('default framing is centred and non-degenerate', () {
    for (final id in _escapeTimeShaders.keys) {
      final module = registry.byId(id);
      final view = module.defaultPreset.view;
      expect(view.zoom, greaterThan(0.2), reason: id);
      expect(view.pan.x.abs(), lessThan(2), reason: id);
      expect(view.pan.y.abs(), lessThan(2), reason: id);
      expect(view.rotation, Vector3.zero(), reason: id);
    }
  });
}

String pubspec() => File('pubspec.yaml').readAsStringSync();
