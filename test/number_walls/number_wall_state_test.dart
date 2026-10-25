import 'dart:math';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/features/history/history_replay.dart';

Future<void> idle(FractalController controller) async {
  final limit = DateTime.now().add(const Duration(seconds: 60));
  while (controller.numberWallPending && DateTime.now().isBefore(limit)) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(controller.numberWallPending, isFalse,
      reason: 'owned request must terminate');
}

void main() {
  test('revoked replay ownership cannot commit or cancel a newer request',
      () async {
    for (final superseded in [false, true]) {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);
      final wall = controller.registry.byId('number_wall');
      final before = Map<String, Object>.from(controller.params);
      final view = controller.view;
      var owned = true;
      var committed = false;
      final older = controller.loadState(
        module: wall,
        params: {
          ...wall.defaultPreset.params,
          'prime': '97',
          'rows': 4,
          'columns': 16
        },
        view: wall.defaultPreset.view,
        transparentBackground: true,
        shouldCommit: () => owned,
        onCommitted: () => committed = true,
      );
      expect(controller.numberWallPending, isTrue);
      owned = false;
      final newer = superseded
          ? controller.loadState(
              module: wall,
              params: {
                ...wall.defaultPreset.params,
                'prime': '101',
                'rows': 4,
                'columns': 16
              },
              view: wall.defaultPreset.view,
            )
          : null;
      expect(await older, isFalse);
      expect(committed, isFalse);
      if (newer != null) {
        expect(await newer, isTrue);
        expect(controller.numberWallGrid!.prime, BigInt.from(101));
      } else {
        expect(controller.module.id, 'mandelbrot');
        expect(controller.params, before);
        expect(controller.view.zoom, view.zoom);
        expect(controller.view.pan, view.pan);
        expect(controller.view.rotation, view.rotation);
        expect(controller.transparentBackground, isFalse);
        expect(controller.numberWallGrid, isNull);
        expect(controller.numberWallStatus, NumberWallPrimeStatus.cancelled);
      }
      expect(controller.numberWallPending, isFalse);
    }
  });

  test('active-module edits invalidate pending Number Walls replay', () async {
    final registry = ModuleRegistry();
    final wall = registry.byId('number_wall');
    final edits = <String, void Function(FractalController)>{
      'parameter': (c) => c.updateParam('iterations', 123),
      'rotation': (c) => c.updateRotation(Vector3(0.1, 0.2, 0.3)),
      'transparency': (c) => c.setTransparentBackground(true),
      'rotation lock': (c) => c.setRotationLocked(true),
      'glow': (c) => c.setGlowEnabled(true),
      'glow radius': (c) => c.setGlowSigma(2),
      'glow intensity': (c) => c.setGlowIntensity(0.7),
      'fluid': (c) => c.setFluidModeEnabled(true),
      'fluid strength': (c) => c.setFluidStrength(0.5),
      'kaleidoscope': (c) => c.setKaleidoscopeEnabled(true),
      'sectors': (c) => c.setKaleidoscopeSectors(10),
      'mirror': (c) => c.setKaleidoscopeMirror(false),
      'mirror mode': (c) => c.setKaleidoscopeMirrorMode(1),
      'kaleidoscope rotation': (c) => c.setKaleidoscopeRotation(0.25),
    };
    for (final edit in edits.entries) {
      final controller = FractalController(registry);
      addTearDown(controller.dispose);
      var committed = false;
      final replay = controller.loadState(
          module: wall,
          params: {...wall.defaultPreset.params, 'rows': 4, 'columns': 16},
          view: wall.defaultPreset.view,
          onCommitted: () => committed = true);
      expect(controller.numberWallPending, isTrue);
      edit.value(controller);
      final editedParams = controller.params;
      final editedRotation = controller.view.rotation;
      expect(await replay, isFalse, reason: edit.key);
      expect(committed, isFalse, reason: edit.key);
      expect(controller.module.id, 'mandelbrot', reason: edit.key);
      expect(controller.params, editedParams, reason: edit.key);
      expect(controller.view.rotation, editedRotation, reason: edit.key);
      expect(controller.numberWallGrid, isNull, reason: edit.key);
    }
  });
  test('successive edits merge into the latest owned candidate', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final wall = controller.registry.byId('number_wall');
    await controller.loadState(
        module: wall,
        params: {...wall.defaultPreset.params, 'rows': 5, 'columns': 16},
        view: wall.defaultPreset.view);
    var adjustedRows = false;
    controller.addListener(() {
      if (!adjustedRows && controller.numberWallPending) {
        adjustedRows = true;
        controller.updateParam('rows', 4);
      }
    });
    controller.updateParam('source', 'rook');
    await idle(controller);
    expect(controller.params['source'], 'rook');
    expect(controller.params['rows'], 4);
    expect(controller.numberWallGrid!.sequence, NumberWallSequence.rook);
    expect(controller.numberWallGrid!.rowCount, 4);
  });

  test('parameter-only edits preserve transparency like ordinary modules',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final wall = controller.registry.byId('number_wall');
    await controller.loadState(
        module: wall,
        params: {...wall.defaultPreset.params, 'rows': 4, 'columns': 16},
        view: wall.defaultPreset.view,
        transparentBackground: true);
    controller.updateParam('colorMode', 1);
    await idle(controller);
    expect(controller.transparentBackground, isTrue);
    await controller.applyPreset(FractalPreset(
        id: 'same',
        moduleId: wall.id,
        name: 'Same',
        params: controller.params,
        view: controller.view,
        createdAt: DateTime.utc(2026)));
    expect(controller.transparentBackground, isTrue);
    controller.randomizeParams(random: Random(1));
    await idle(controller);
    expect(controller.transparentBackground, isTrue);
    controller.resetParams();
    await idle(controller);
    expect(controller.transparentBackground, isTrue);
  });
  test(
      'wall transactions commit exact settings/grid together and cancel on reset',
      () async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final wall = registry.byId('number_wall');
    final params = {
      ...wall.defaultPreset.params,
      'prime': '00097',
      'rows': 4,
      'columns': 16
    };
    await controller.loadState(
        module: wall, params: params, view: wall.defaultPreset.view);
    expect(controller.params['prime'], '97');
    expect(controller.numberWallGrid?.prime, BigInt.from(97));
    final grid = controller.numberWallGrid;
    await controller.loadState(
        module: wall,
        params: {...params, 'rows': 64, 'columnStart': 3},
        view: wall.defaultPreset.view);
    expect(controller.params['rows'], 4);
    expect(controller.numberWallGrid, same(grid));
    final older = controller.applyNumberWallPrime('100003');
    controller.resetParams();
    expect(await older, NumberWallPrimeStatus.cancelled);
    await idle(controller);
    expect(controller.params['prime'], '2');
    final unfinished = controller
        .applyNumberWallPrime('170141183460469231731687303715884105727');
    expect(await controller.applyNumberWallPrime('101'),
        NumberWallPrimeStatus.verifiedPrime);
    expect(await unfinished, NumberWallPrimeStatus.cancelled);
    expect(controller.numberWallGrid!.prime, BigInt.from(101));
    final abandoned = controller.applyNumberWallPrime('100003');
    controller.selectModule(registry.byId('mandelbrot'), animate: false);
    expect(await abandoned, NumberWallPrimeStatus.cancelled);
    expect(controller.module.id, 'mandelbrot');
    final hidden = controller.loadState(
        module: wall, params: params, view: wall.defaultPreset.view);
    controller.cancelNumberWallRequest();
    await hidden;
    expect(controller.module.id, 'mandelbrot');
    expect(controller.numberWallPending, isFalse);
  });

  test(
      'all replay ingress certifies complete decimal state and ignores forged status',
      () async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final wall = registry.byId('number_wall');
    final defaults = {
      ...wall.defaultPreset.params,
      'rows': 4,
      'columns': 16,
      'prime': '97'
    };
    // Importing a wall while another module is active has the same boundary.
    controller.updateParam('iterations', 123);
    final olderParams = controller.params;
    await controller.applyPreset(FractalPreset(
        id: 'invalid-startup-import',
        moduleId: wall.id,
        name: 'Imported',
        params: {...defaults, 'prime': '561'},
        view: wall.defaultPreset.view,
        createdAt: DateTime.utc(2026)));
    expect(controller.module.id, 'mandelbrot');
    expect(controller.params, olderParams);
    expect(controller.numberWallStatus, NumberWallPrimeStatus.composite);
    // Invalid startup replay must not replace an older saved module.
    await controller.loadState(
        module: wall,
        params: {...defaults, 'prime': '561'},
        view: wall.defaultPreset.view);
    expect(controller.module.id, 'mandelbrot');
    expect(controller.numberWallStatus, NumberWallPrimeStatus.composite);
    await controller.applyPreset(FractalPreset(
        id: 'valid-startup-import',
        moduleId: wall.id,
        name: 'Imported',
        params: defaults,
        view: wall.defaultPreset.view,
        createdAt: DateTime.utc(2026)));

    for (final ingress in ['import', 'link', 'history', 'session']) {
      for (final candidate in [
        '561',
        '9' * 257,
        '170141183460469231731687303715884105727',
        '00097'
      ]) {
        final before = controller.numberWallGrid;
        final beforeGlow = controller.glowEnabled;
        final params = {...defaults, 'prime': candidate, 'primeVerified': true};
        switch (ingress) {
          case 'import':
            final preset = FractalPreset.fromJson(FractalPreset(
                    id: 'imported',
                    moduleId: 'number_wall',
                    name: 'Imported',
                    params: params,
                    view: wall.defaultPreset.view,
                    createdAt: DateTime.utc(2026))
                .toJson());
            expect(preset.params['prime'], candidate);
            await controller.applyPreset(preset);
          case 'link':
            final link = DeepLinkService.parseUri(DeepLinkService.buildUri(
                moduleId: 'number_wall',
                params: params,
                view: wall.defaultPreset.view))!;
            expect(link.toParams()['prime'], candidate);
            await controller.loadState(
                moduleId: link.type,
                params: link.toParams(),
                view: link.toViewState(),
                onCommitted: () => controller.setGlowEnabled(true));
          case 'history':
            final entry = HistoryEntry.fromJson(HistoryEntry(
                    id: 'restored',
                    moduleId: 'number_wall',
                    params: params,
                    view: wall.defaultPreset.view,
                    visitedAt: DateTime.utc(2026))
                .toJson());
            expect(entry.params['prime'], candidate);
            applyHistoryEntryToController(entry, controller);
            await idle(controller);
          case 'session':
            final snapshot = ViewerSessionSnapshot.fromJson(
                ViewerSessionSnapshot(
                        moduleId: 'number_wall',
                        params: defaults,
                        view: wall.defaultPreset.view,
                        transparentBackground: false,
                        rotationLocked: false,
                        glowEnabled: true,
                        glowSigma: 1,
                        glowIntensity: 1,
                        fluidModeEnabled: false,
                        fluidStrength: 1,
                        kaleidoscopeEnabled: false,
                        kaleidoscopeSectors: 6,
                        kaleidoscopeMirror: false,
                        kaleidoscopeRotation: 0,
                        kaleidoscopeMirrorMode: 0,
                        controlsVisible: true,
                        fullscreenUnobtrusive: false,
                        viewerActive: true)
                    .toJson());
            final restored = ViewerSessionSnapshot.fromJson(
                {...snapshot.toJson(), 'params': params});
            expect(restored.params['prime'], candidate);
            restored.applyToController(controller);
            await idle(controller);
        }
        if (ingress == 'session' || ingress == 'link') {
          expect(
              controller.glowEnabled, candidate == '00097' ? true : beforeGlow,
              reason: 'rejected replays must not apply visual settings');
        }
        expect(controller.params['prime'], '97',
            reason: '$ingress: $candidate');
        expect(controller.numberWallGrid, same(before),
            reason: 'invalid or same field retains immutable grid');
        expect(
            controller.numberWallStatus,
            candidate == '00097'
                ? NumberWallPrimeStatus.verifiedPrime
                : candidate == '561'
                    ? NumberWallPrimeStatus.composite
                    : candidate.length > 256
                        ? NumberWallPrimeStatus.invalid
                        : NumberWallPrimeStatus.unverified,
            reason: '$ingress: exact completed status');
      }
    }
    controller.updateParam('prime', '561');
    expect(controller.params['prime'], '97');
    await controller.loadState(
        moduleId: 'mandelbrot',
        params: {'iterations': 123, 'bailout': 4},
        view: wall.defaultPreset.view);
    expect(controller.module.id, 'mandelbrot');
    expect(controller.params['iterations'], 123);
  });

  test(
      'all six sources commit exact cells and randomization preserves custom modulus/grid budget',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final wall = controller.registry.byId('number_wall');
    for (final entry in const {
      'signedPagoda': 0,
      'rook': 1,
      'thueMorse': 0,
      'rudinShapiro': 1,
      'fibonacci': 2,
      'squares': 0
    }.entries) {
      await controller.loadState(
          module: wall,
          params: {
            ...wall.defaultPreset.params,
            'source': entry.key,
            'prime': '3',
            'rows': 4,
            'columns': 16,
            'columnStart': 3
          },
          view: wall.defaultPreset.view);
      expect(controller.numberWallGrid!.values[0][0], BigInt.from(entry.value),
          reason: entry.key);
    }
    await controller.applyNumberWallPrime('97');
    controller.randomizeParams(random: Random(1));
    await idle(controller);
    expect(controller.params['prime'], '97');
    expect(controller.params['rows'], 4);
    expect(controller.params['columns'], 16);
    expect(controller.params['columnStart'], 3);
  });
}
