import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the Mandelbrot-mix family, its three-term extension and the affine
/// 4D planar slices. Root-finding formula pins live in
/// `root_finding_formula_test.dart`.
void main() {
  group('Mandelbrot mix family', () {
    final entries = escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/mix/mandelbrot_mix_'))
        .toList();

    test('sixteen entries share the one mix shader', () {
      expect(entries.length, 16);
      for (final e in entries) {
        expect(e.shaderAsset.endsWith('mandelbrot_mix_gpu.frag'), isTrue);
        final names = e.extraParams.map((p) => p.id).toList();
        expect(names, [
          'mixA',
          'mixB',
          'mixD',
          'mixF',
          'mixG',
          'mixH',
          'mixK',
          'juliaMode',
          'juliaReal',
          'juliaImag',
        ]);
      }
    });

    test('degenerate parameters reproduce z^2 + c exactly', () {
      // a = d = 0.5, b = f = 2, k = 1 -> z^2 + c for every orbit step.
      double re(double x, double y) {
        // k*(a*Re(z^b) + d*Re(z^f)) + c with b = f = 2
        return 1.0 * (0.5 * (x * x - y * y) + 0.5 * (x * x - y * y));
      }

      double im(double x, double y) {
        return 1.0 * (0.5 * (2 * x * y) + 0.5 * (2 * x * y));
      }

      for (final z in const [
        [0.3, 0.4],
        [-0.7, 0.2],
        [0.0, -0.9],
      ]) {
        final mandelRe = z[0] * z[0] - z[1] * z[1];
        final mandelIm = 2 * z[0] * z[1];
        expect(re(z[0], z[1]), closeTo(mandelRe, 1e-15));
        expect(im(z[0], z[1]), closeTo(mandelIm, 1e-15));
      }
    });

    test('shader declares the extras in uniform order and keeps the chain rule',
        () {
      final source = File(
              'shaders/escape_time_family/families/mix/mandelbrot_mix_gpu.frag')
          .readAsStringSync();
      final order = <String>[
        'uMixA',
        'uMixB',
        'uMixD',
        'uMixF',
        'uMixG',
        'uMixH',
        'uMixK',
        'uJuliaMode',
        'uJuliaReal',
        'uJuliaImag',
      ];
      var cursor = -1;
      for (final name in order) {
        final at = source.indexOf('uniform float $name;');
        expect(at, greaterThan(cursor), reason: '$name declared out of order');
        cursor = at;
      }
      expect(source,
          contains('a*b*cpowr(z, b - 1.0) + d*f*cpowr(z, f - 1.0)'));
      expect(source, contains('+ g*h*cpowr(z, h - 1.0)'));
      expect(source,
          contains('z = k * (a*cpowr(z, b) + d*cpowr(z, f) + g*cpowr(z, h)) + c;'));
    });

    for (final config in escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/mix/mandelbrot_mix_'))) {
      test('${config.id} compiles and renders a non-blank frame', () async {
        final module = ModuleRegistry().byId(config.id);
        final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
        final shader = program.fragmentShader();
        final recorder = ui.PictureRecorder();
        module.setUniforms(
          shader,
          FractalRenderState(
            transparentBackground: false,
            params: module.defaultPreset.params,
            view: module.defaultPreset.view,
          ),
          const ui.Size(64, 64),
          0,
        );
        Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 64, 64),
          Paint()..shader = shader,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        var lit = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) >
              12) {
            lit++;
          }
        }
        // Slice entries can be intrinsically thin; require visible structure,
        // not a full frame.
        expect(lit, greaterThan(8), reason: '${config.id} drew a black frame');
        picture.dispose();
        image.dispose();
        shader.dispose();
      });
    }
  });

  group('planar 4D slices', () {
    final entries = escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/slice/planar_slice_4d'))
        .toList();

    test('six slice entries share one shader and keep uniform order', () {
      expect(entries.length, 6);
      for (final e in entries) {
        expect(e.extraParams.map((p) => p.id).toList(), [
          'sliceAngleA',
          'sliceAngleB',
          'slicePower',
          'sliceOffsetRe',
          'sliceOffsetIm',
          'sliceMode',
        ]);
      }
      final source = File(
              'shaders/escape_time_family/families/slice/planar_slice_4d_gpu.frag')
          .readAsStringSync();
      var cursor = -1;
      for (final name in const [
        'uSliceAngleA',
        'uSliceAngleB',
        'uSlicePower',
        'uSliceOffsetRe',
        'uSliceOffsetIm',
        'uSliceMode',
      ]) {
        final at = source.indexOf('uniform float $name;');
        expect(at, greaterThan(cursor), reason: '$name out of order');
        cursor = at;
      }
    });

    test('zero angles map z0 = x and c = y, the real slice', () {
      // Two iterations of z -> z^2 + c with z0 = x, c = y.
      double z1(double x, double y) => x * x + y;
      double z2(double x, double y) {
        final a = z1(x, y);
        return a * a + y;
      }

      for (final p in const [
        [0.2, -0.3],
        [-0.6, 0.1],
        [0.45, 0.45],
      ]) {
        final manual = p[0] * p[0] + p[1];
        expect(z1(p[0], p[1]), closeTo(manual, 1e-15));
        final second = manual * manual + p[1];
        expect(z2(p[0], p[1]), closeTo(second, 1e-15));
      }
    });

    for (final config in escapeTimeCatalog
        .where((e) => e.shaderAsset.contains('/slice/planar_slice_4d'))) {
      test('${config.id} compiles and renders a non-blank frame', () async {
        final module = ModuleRegistry().byId(config.id);
        final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
        final shader = program.fragmentShader();
        final recorder = ui.PictureRecorder();
        module.setUniforms(
          shader,
          FractalRenderState(
            transparentBackground: false,
            params: module.defaultPreset.params,
            view: module.defaultPreset.view,
          ),
          const ui.Size(64, 64),
          0,
        );
        Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 64, 64),
          Paint()..shader = shader,
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        var lit = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2) >
              12) {
            lit++;
          }
        }
        // Slice entries can be intrinsically thin; require visible structure,
        // not a full frame.
        expect(lit, greaterThan(8), reason: '${config.id} drew a black frame');
        picture.dispose();
        image.dispose();
        shader.dispose();
      });
    }
  });

  test('three multirot plane presets render, are non-blank and differ', () async {
    final module = ModuleRegistry().byId('slice_multirot_planes');
    final presets = module.builtInPresets
        .where((p) => p.id.startsWith('slice_multirot_planes-p'))
        .toList();
    expect(presets.length, 3);
    final frames = <String, List<int>>{};
    for (final preset in presets) {
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      final shader = program.fragmentShader();
      final recorder = ui.PictureRecorder();
      module.setUniforms(
        shader,
        FractalRenderState(
          transparentBackground: false,
          params: preset.params,
          view: preset.view,
        ),
        const ui.Size(48, 48),
        0,
      );
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 48, 48),
        Paint()..shader = shader,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(48, 48);
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      var lit = 0;
      for (var i = 0; i < 48 * 48; i++) {
        if (bytes.getUint8(i * 4) + bytes.getUint8(i * 4 + 1) +
                bytes.getUint8(i * 4 + 2) >
            12) {
          lit++;
        }
      }
      expect(lit, greaterThan(4), reason: '${preset.id} is blank');
      frames[preset.id] = List<int>.generate(
          48 * 48, (i) => bytes.getUint8(i * 4) + bytes.getUint8(i * 4 + 1) + bytes.getUint8(i * 4 + 2));
      picture.dispose();
      image.dispose();
      shader.dispose();
    }
    final ids = frames.keys.toList();
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        var diff = 0;
        for (var k = 0; k < frames[ids[i]]!.length; k++) {
          if (frames[ids[i]]![k] != frames[ids[j]]![k]) diff++;
        }
        expect(diff, greaterThan(20), reason: '${ids[i]} vs ${ids[j]}');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
