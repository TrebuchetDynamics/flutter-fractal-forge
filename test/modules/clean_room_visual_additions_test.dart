import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = {
    'relativistic_black_hole_lensing':
        'shaders/escape_time_family/experimental_named/physical_simulation/relativistic_black_hole_lensing_gpu.frag',
    'recursive_octagram_field':
        'shaders/ifs_and_geometric/plane_tilings/recursive_octagram_field_gpu.frag',
  };

  test('clean-room visual additions are distinct registered modules', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final entry in expected.entries) {
      final config =
          escapeTimeCatalog.singleWhere((item) => item.id == entry.key);
      expect(config.shaderAsset, entry.value);
      expect(config.animationCapability, FractalAnimationCapability.timeDriven);
      expect(File(entry.value).existsSync(), isTrue);
      expect(pubspec, contains('- ${entry.value}'));
    }
  });

  test('sources document and enforce single-pass clean-room boundaries', () {
    for (final asset in expected.values) {
      final source = File(asset).readAsStringSync();
      expect(source, contains('Original'));
      expect(source, isNot(contains('sampler2D')));
      expect(source, isNot(contains('texture(')));
    }
  });

  test('new shaders compile as Flutter runtime effects', () async {
    for (final asset in expected.values) {
      expect(await ui.FragmentProgram.fromAsset(asset), isNotNull,
          reason: asset);
    }
  });

  test('defaults render structured, non-uniform images', () async {
    const size = 64;
    for (final entry in expected.entries) {
      final config =
          escapeTimeCatalog.singleWhere((item) => item.id == entry.key);
      final program = await ui.FragmentProgram.fromAsset(entry.value);
      final pixels = await renderTestShaderFrame(
        program: program,
        shaderAsset: entry.value,
        width: size,
        height: size,
        uniforms: [
          0,
          size.toDouble(),
          size.toDouble(),
          config.defaultCenterX ?? 0,
          config.defaultCenterY ?? 0,
          config.defaultZoom,
          config.defaultIterations,
          config.defaultBailout,
          config.defaultColorScheme.toDouble(),
          0,
          ...config.extraParams
              .map((param) => (param.defaultValue as num).toDouble()),
        ],
      );

      final colors = <int>{};
      var visiblePixels = 0;
      for (var offset = 0; offset < pixels.length; offset += 4) {
        colors.add(
          (pixels[offset] << 16) |
              (pixels[offset + 1] << 8) |
              pixels[offset + 2],
        );
        if (pixels[offset] + pixels[offset + 1] + pixels[offset + 2] > 30) {
          visiblePixels++;
        }
      }
      expect(colors.length, greaterThan(48), reason: '${entry.key} is uniform');
      expect(visiblePixels, greaterThan(size * size ~/ 20),
          reason: '${entry.key} is effectively blank');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
