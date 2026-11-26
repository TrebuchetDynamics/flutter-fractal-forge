import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Existing locked hashing dependency.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/features/renderer/palette_transition.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_fractals/l10n/app_localizations_es.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart';
import '../migration/support/baseline_inventory.dart'
    show retainedBaselineRecord, retainedDefaultPreset;

import 'package:flutter_fractals/core/modules/fractals/mandelbulb_module.dart';
import 'package:flutter_fractals/core/modules/fractals/mandelbox_module.dart';
import 'package:flutter_test/flutter_test.dart';

const fixture = 'test/shaders/sculptural_surface_fixture.frag';
const consumers = [
  'shaders/legacy/raymarched_3d/mandelbulb.frag',
  'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
];

Future<List<int>> sample(int which) async {
  final program = await ui.FragmentProgram.fromAsset(fixture);
  final shader = program.fragmentShader()
    ..setFloat(0, 1)
    ..setFloat(1, 1)
    ..setFloat(2, which.toDouble());
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1), ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final bytes = data.buffer.asUint8List().toList();
  image.dispose();
  picture.dispose();
  shader.dispose();
  return bytes;
}

// Real production setter + runtime-effect readback; fixed time, no effects.
Future<Uint8List> renderSurface(FractalModule module, FractalPreset preset,
    {bool transparent = true, bool png = false, int size = 64}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  module.setUniforms(
      shader,
      FractalRenderState(
          params: preset.params,
          view: preset.view,
          transparentBackground: transparent),
      ui.Size.square(size.toDouble()),
      0);
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final data = (await image.toByteData(
      format: png ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba))!;
  final bytes = Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  image.dispose();
  picture.dispose();
  shader.dispose();
  return bytes;
}

Map<String, Object> viewJson(FractalViewState view) => {
      'pan': view.pan.storage.toList(),
      'zoom': view.zoom,
      'rotation': view.rotation.storage.toList(),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();
  final modules = [registry.byId('mandelbulb'), registry.byId('mandelbox')];
  test('module-local selectors extend without changing schema defaults', () {
    for (final (module, max, legacy) in [
      (buildMandelbulbModule(), 4, 0),
      (buildMandelboxModule(), 8, 2),
      (modules[0], 4, 0),
      (modules[1], 8, 2),
    ]) {
      final scheme =
          module.parameters.singleWhere((p) => p.id == 'colorScheme');
      expect(scheme.max, max);
      expect(scheme.defaultValue, legacy);
      expect(scheme.options.last.value, max);
      expect(scheme.options.last.label(AppLocalizationsEn()), 'Sculptural');
      expect(scheme.options.last.label(AppLocalizationsEs()), 'Escultural');
      expect(module.defaultPreset.params['colorScheme'], max);
    }
  });
  test('canonical block is synchronized and legacy shading remains local', () {
    final canonical = File('shaders/shared/surface_lighting.glsl')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    for (final path in [...consumers, fixture]) {
      final source = File(path).readAsStringSync().replaceAll('\r\n', '\n');
      const begin = '// BEGIN GENERATED SURFACE LIGHTING\n';
      const end = '// END GENERATED SURFACE LIGHTING\n';
      expect(begin.allMatches(source), hasLength(1), reason: path);
      expect(end.allMatches(source), hasLength(1), reason: path);
      expect(source, contains('$begin$canonical$end'),
          reason: 'Run python3 scripts/sync_surface_lighting.py --write');
      expect(
          source, isNot(matches(RegExp(r'^\s*#include\s+"', multiLine: true))));
    }
    expect(File(consumers[0]).readAsStringSync(),
        contains('float t = hit.w / uIterations;'));
    expect(File(consumers[1]).readAsStringSync(),
        contains('float t         = hit.w / max(uIterations, 1.0);'));
  });
  test('AO uses exactly three bounded normal taps at the hit epsilon', () {
    for (final (path, estimator) in [
      (consumers[0], 'getDistance'),
      (consumers[1], 'mandelboxDE'),
    ]) {
      final source = File(path).readAsStringSync().replaceAll('\r\n', '\n');
      final marcher = RegExp(r'vec4 rayMarch\([^\n]+\{([\s\S]+?)\n\}')
          .firstMatch(source)!
          .group(1)!;
      final hitEpsilon =
          RegExp(r'float minDist\s*=\s*([^;]+);').firstMatch(marcher)!.group(1);
      final ao = RegExp(r'float sculpturalAO\([^\n]+\{([\s\S]+?)\n\}')
          .firstMatch(source)!
          .group(1)!;
      expect(ao, contains('float epsilon = $hitEpsilon;'), reason: path);
      expect(ao, contains('for (int i = 0; i < 3; i++)'), reason: path);
      expect(ao, contains('offset = epsilon * (2.0 + 3.0 * float(i));'),
          reason: path);
      expect('$estimator('.allMatches(ao), hasLength(1), reason: path);
      expect(ao, contains('$estimator(position + normal * offset);'),
          reason: path);
      expect(ao, contains('if (surfaceFinite(distance))'), reason: path);
      expect(ao, contains('clamp((offset - distance) / offset, 0.0, 1.0)'),
          reason: path);
      expect(ao, contains('valid = false;'), reason: path);
      expect(
          ao,
          contains(
              'return valid ? clamp(1.0 - occlusion / 3.0, 0.0, 1.0) : 1.0;'),
          reason: path);
    }
  });
  test('synthetic key-facing normal is brighter and highlights are neutral',
      () async {
    final facing = await sample(0);
    final away = await sample(1);
    expect(facing[0], greaterThan(away[0] + 30));
    final highlight = await sample(2);
    // The linear 0.24 highlight maps to 134 in RGBA8 sRGB (one transfer).
    expect(highlight[0], closeTo(134, 1));
    expect(highlight[0], highlight[1]);
    expect(highlight[1], highlight[2]);
    expect(facing[3], 255);
    expect(await sample(3), await sample(5));
    expect(await sample(4), facing);
  });

  test('uniform setters write only the existing contiguous ABI', () async {
    for (final (module, slots) in [
      (modules[0], 16),
      (buildMandelbulbModule(), 16),
      (modules[1], 18),
    ]) {
      final shader = (await ui.FragmentProgram.fromAsset(module.shaderAsset))
          .fragmentShader();
      addTearDown(shader.dispose);
      module.setUniforms(
          shader,
          FractalRenderState(
              params: module.defaultPreset.params,
              view: module.defaultPreset.view,
              transparentBackground: true),
          const ui.Size(64, 64),
          0);
      expect(() => shader.setFloat(slots, 0), throwsRangeError);
      expect(
          File('lib/core/modules/fractals/${module.id}_module.dart')
              .readAsStringSync(),
          isNot(contains('PaletteShaderAdapter')));
    }
  });

  test(
      'new/reset, named presets, old missing/unsupported schemes and persistence',
      () async {
    SharedPreferences.setMockInitialValues({});
    final store = await PresetStore.create();
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    for (final module in modules) {
      final max = module.id == 'mandelbulb' ? 4 : 8;
      final legacy = module.id == 'mandelbulb' ? 0 : 2;
      controller.selectModule(module, animate: false);
      expect(controller.params, module.defaultPreset.params);
      expect(viewJson(controller.view), viewJson(module.defaultPreset.view));
      controller.updateParam('colorScheme', 0);
      controller.resetView();
      expect(viewJson(controller.view),
          isNot(viewJson(module.defaultPreset.view)));
      controller.resetSession();
      expect(controller.params['colorScheme'], max);
      expect(viewJson(controller.view), viewJson(module.defaultPreset.view));
      final retained = retainedBaselineRecord('presets', module.id);
      expect([
        for (var i = 0; i < module.builtInPresets.length; i++)
          {
            'order': i,
            ...module.builtInPresets[i].toJson()..remove('createdAt')
          }
      ], retained['built_in']);
      for (final preset in module.builtInPresets) {
        await controller.applyPreset(preset);
        expect(controller.params, preset.params);
        expect(viewJson(controller.view), viewJson(preset.view));
      }
      final original = retainedDefaultPreset(module.id);
      await controller.applyPreset(original.copyWith(
          params: {...original.params}..remove('colorScheme')));
      expect(controller.params['colorScheme'], legacy);
      controller.updateParam('colorScheme', -100);
      expect(controller.params['colorScheme'], 0);
      controller.updateParam('colorScheme', 100);
      expect(controller.params['colorScheme'],
          module.id == 'mandelbulb' ? legacy : max);
      await controller.loadState(
          module: module, params: original.params, view: original.view);
      expect(controller.params['colorScheme'], original.params['colorScheme']);
      expect(viewJson(controller.view), viewJson(original.view));
      await controller.loadState(
          module: module,
          params: {...original.params}..remove('colorScheme'),
          view: original.view);
      expect(controller.params['colorScheme'], legacy);
      expect(viewJson(controller.view), viewJson(original.view));
      await controller.applyPreset(module.defaultPreset);
      final saved = module.defaultPreset.copyWith(
          id: 'saved-${module.id}',
          isBuiltIn: false,
          params: controller.params,
          view: controller.view);
      await store.saveUserPreset(saved);
      final restored = (await store.loadUserPresets(module.id)).single;
      expect(restored.toJson(), saved.toJson());
      // Change both fields so a no-op restore cannot pass.
      await controller.applyPreset(original);
      controller.resetView();
      expect(controller.params['colorScheme'], isNot(max));
      expect(viewJson(controller.view), isNot(viewJson(restored.view)));
      expect(
          await controller.loadState(
              module: module, params: restored.params, view: restored.view),
          isTrue);
      expect(controller.params['colorScheme'], max);
      expect(viewJson(controller.view), viewJson(restored.view));
      final export =
          ExportService(rasterize: (width, height, transparent) async {
        expect((width, height, transparent), (64, 64, true));
        expect(controller.params['colorScheme'], max);
        return renderSurface(
          module,
          restored.copyWith(params: controller.params, view: controller.view),
          transparent: transparent,
          png: true,
        );
      });
      final png = await export.captureWithOptions(GlobalKey(),
          options: const ExportOptions(
              resolution: ExportResolution.screen, transparentBackground: true),
          screenWidth: 64,
          screenHeight: 64);
      final decoded = img.decodePng(png)!;
      expect((decoded.width, decoded.height), (64, 64));
      final expected = img.decodePng(
          await renderSurface(module, module.defaultPreset, png: true))!;
      expect(decoded.getBytes(order: img.ChannelOrder.rgba),
          orderedEquals(expected.getBytes(order: img.ChannelOrder.rgba)));
    }
  });

  test('other modules retain the neutral session reset', () {
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final mandelbrot = registry.byId('mandelbrot');
    controller.selectModule(mandelbrot, animate: false);
    controller.updateView(mandelbrot.defaultPreset.view.copyWith(zoom: 3));
    controller.resetSession();
    expect(viewJson(controller.view), viewJson(FractalViewState.initial()));
  });

  for (final module in modules) {
    final max = module.id == 'mandelbulb' ? 4 : 8;
    final original = retainedDefaultPreset(module.id);
    test('${module.id} discrete material transitions render at 0/125/250ms',
        () async {
      final transition = PaletteTransition();
      final start = DateTime(2026);
      final newFrame = await renderSurface(module,
          original.copyWith(params: {...original.params, 'colorScheme': max}));
      final oldFrame = await renderSurface(module,
          original.copyWith(params: {...original.params, 'colorScheme': 0}));
      expect(newFrame, isNot(orderedEquals(oldFrame)));
      for (final (from, to) in [(max - 1, max), (max, 0)]) {
        final clock = start.add(Duration(seconds: from));
        transition.valueFor(
            target: from,
            now: clock,
            min: 0,
            max: max.toDouble(),
            animate: false);
        for (final ms in [0, 125, 250]) {
          final raw = transition.valueFor(
              target: to,
              now: clock.add(Duration(milliseconds: ms)),
              min: 0,
              max: max.toDouble(),
              animate: true);
          final selectedNew = raw.floor().clamp(0, max) == max;
          expect(selectedNew, from == max ? ms < 250 : ms == 250);
          final frame = await renderSurface(
              module,
              original
                  .copyWith(params: {...original.params, 'colorScheme': raw}));
          if (selectedNew) {
            expect(frame, orderedEquals(newFrame));
          } else if (to == max) {
            expect(frame, isNot(orderedEquals(newFrame)));
          }
          if (ms == 250 && to == 0) expect(frame, orderedEquals(oldFrame));
        }
      }
      for (final target in [max, 0]) {
        final raw = transition.valueFor(
            target: target,
            now: start,
            min: 0,
            max: max.toDouble(),
            animate: false);
        expect(raw, target);
        expect(
            await renderSurface(
                module,
                original.copyWith(
                    params: {...original.params, 'colorScheme': raw})),
            orderedEquals(target == max ? newFrame : oldFrame));
      }
    });
    test('${module.id} misses bypass the material in both alpha modes',
        () async {
      final miss = original.copyWith(
          view: original.view.copyWith(
        pan: Vector2(30, 0),
        zoom: 0.2,
        rotation: Vector3.zero(),
      ));
      final painted =
          miss.copyWith(params: {...miss.params, 'colorScheme': max});
      for (final transparent in [false, true]) {
        final newFrame =
            await renderSurface(module, painted, transparent: transparent);
        expect(
            newFrame,
            orderedEquals(
                await renderSurface(module, miss, transparent: transparent)));
        for (var i = 3; i < newFrame.length; i += 4) {
          expect(newFrame[i], transparent ? 0 : 255);
        }
      }
    });
    test('${module.id} new surface preserves every dispatch hit/miss mask',
        () async {
      for (final type in module.id == 'mandelbulb' ? [0, 1, 2, 3] : [0]) {
        List<int>? mask;
        for (var scheme = 0; scheme <= max; scheme++) {
          final frame = await renderSurface(
              module,
              original.copyWith(params: {
                ...original.params,
                if (module.id == 'mandelbulb') 'fractalType': type,
                'colorScheme': scheme,
              }));
          final alpha = [for (var i = 3; i < frame.length; i += 4) frame[i]];
          expect(alpha.every((a) => a == 0 || a == 255), isTrue);
          expect(alpha, contains(255));
          if (mask != null) expect(alpha, orderedEquals(mask));
          mask = alpha;
          if (scheme < max) {
            // Same-backend retained static decoded output, recorded before treatment.
            expect(sha256.convert(frame).toString(),
                legacyHashes['${module.id}/$type/$scheme']);
          }
        }
      }
    });
  }
}

// Frozen 6031f273 assets, 64x64, time=0, retained default view, transparent=true.
// Flutter 3.47.9 deterministic Skia software RGBA8 readback (not GPU parity).
const legacyHashes = <String, String>{
  'mandelbulb/0/0':
      '5fd50b4771a5d742737310e56893ba667c53ac351e1ce932eb2c9ffc3a2cdd26',
  'mandelbulb/0/1':
      'c42779993774f4ed6c389dd944bb2a1b620f52ddfde2283489316d8cd76d9f56',
  'mandelbulb/0/2':
      '9f71f7f9db53d0cca5a2e86ce265f1fe84e8d2708c9afd95444fad845b1225f3',
  'mandelbulb/0/3':
      '3810f478cb7b8a9485eb8902c21634c9efd10aec988c126f3426eba662a8aa82',
  'mandelbulb/1/0':
      '70e614d9d55fc11795e64655ef12a1806f80f5b682d832a1f6d609275521e84e',
  'mandelbulb/1/1':
      '68c3ac429c5782dad44371b196efdcadc584acfac86c17df08eea8e5336d561e',
  'mandelbulb/1/2':
      '7e1441ea445d80f80daf6f66d1039a9ce549f2172783f62c7a5f2cd63c1ccd4d',
  'mandelbulb/1/3':
      '62fb561c59d0cea247fc588f3311ee665375f35d8675b186e2792cb7dfcff88c',
  'mandelbulb/2/0':
      '15c410143d755fef38302baa0bdcb88e57a7f4bef7de715e87a077824d4ac271',
  'mandelbulb/2/1':
      '0ee2c3bbeab37d09ccff4fcdcbf992b9ce7f06276c7f159c18c06cd48fa483a1',
  'mandelbulb/2/2':
      '4f50008ecf204247eaa5650055c162b3f89ee1b3b85ad9c148f8430e274bb8b7',
  'mandelbulb/2/3':
      '4f4662ef219b5d1dfb3285446048ad6b7dc88d07c71416185c5e2592cd761c4b',
  'mandelbulb/3/0':
      '054b96cc4f3ae35376c0d9181a512552f5a9373876c32a6cf9bf21e229191ee7',
  'mandelbulb/3/1':
      'f4454542481e2b13dfce7ed73510ccee470dd7972170ea3abbaf830eb5a7d4a8',
  'mandelbulb/3/2':
      'f211e18d55f4b5074044da14041d3832aaa692311db3bef742872d02ee6f4c10',
  'mandelbulb/3/3':
      'a48be5624f850fc397fe01f6ccd9623dd29e8c4ecce7f2edca73d419ed20f99d',
  'mandelbox/0/0':
      '09075975f4a10847f8242acf7e56dcd8bde75acb1602eafd451f6ac63f56ffe1',
  'mandelbox/0/1':
      'd00d4d30714d6835f0f39f04cebe8bb4a157a20485d18ea1a16b16a9a3670edf',
  'mandelbox/0/2':
      '3f411da6d1774270ca2a2df33078babcb413be8a612724ca367af8bc94ac85b1',
  'mandelbox/0/3':
      'a7cca9567773399fcfe3b33860698fa40ad8381dcaaf35f755539ac88400639e',
  'mandelbox/0/4':
      'b87de3d063a03c6b0e73c2fa5d7695a22414a4e029a8d2aead9d60b9f0e04530',
  'mandelbox/0/5':
      '91e3fb6b309d823816f776d9672f2825e7c4819c00c9cc200777ee356e01d0b6',
  'mandelbox/0/6':
      'e3047cd79929eaaf1aa3d98a10fd991a9f5899293b322460140d01ce570d41a9',
  'mandelbox/0/7':
      'e9b41436ee8cd66f04db8a076f7b732cd78b46b9557f30e1c1fe3211e8e1ae47',
};
