import 'dart:convert';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/history/history_replay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../migration/support/baseline_inventory.dart';

// Frozen selection inputs, not derived from the implementation under test.
const selected = {
  'mandelbrot': (x: -0.747, y: 0.1, zoom: 8.0, scheme: 1),
  'burning_ship': (x: -1.76, y: -0.035, zoom: 12.0, scheme: 1),
  'newton_z3': (x: 0.0, y: 0.0, zoom: 0.45, scheme: 2),
};

Map<String, Object?> serialized(FractalPreset preset) =>
    preset.toJson()..remove('createdAt');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = ModuleRegistry();

  for (final id in selected.keys) {
    final choice = selected[id]!;
    final module = registry.byId(id);
    final original = retainedBaselineRecord('presets', id);

    test('$id explicit framing, palette bounds and unchanged work/math', () {
      final config = escapeTimeCatalog.singleWhere((c) => c.id == id);
      expect(module.dimension, FractalDimension.twoD);
      expect(config.defaultCenterX, choice.x);
      expect(config.defaultCenterY, choice.y);
      expect(config.defaultZoom, choice.zoom);
      final expected = jsonDecode(jsonEncode(original['default'])) as Map;
      expected['view']['panX'] = choice.x;
      expected['view']['panY'] = choice.y;
      expected['view']['zoom'] = choice.zoom;
      expected['params']['colorScheme'] = choice.scheme;
      expect(serialized(module.defaultPreset), expected);
      expect(module.defaultPreset.createdAt, builtInPresetCreatedAt);
      expect(module.defaultPreset.view.zoom, inInclusiveRange(0.2, 32));
      for (final parameter in module.parameters) {
        final value = module.defaultPreset.params[parameter.id] as num;
        expect(value, inInclusiveRange(parameter.min, parameter.max));
        expect(value, parameter.defaultValue);
      }
    });

    test('$id all named presets including Classic retain exact state/order',
        () {
      final old = (original['built_in'] as List).cast<Map>();
      expect(module.builtInPresets.map((p) => p.id).toSet(),
          hasLength(old.length));
      expect([
        for (var i = 0; i < module.builtInPresets.length; i++)
          {...serialized(module.builtInPresets[i]), 'order': i}
      ], old);
      for (final preset in module.builtInPresets) {
        expect(preset.createdAt, builtInPresetCreatedAt);
        expect(preset.isBuiltIn, isTrue);
      }
    });

    test('$id new/reset sessions use selection; old preset/history do not',
        () async {
      final controller = FractalController(registry);
      addTearDown(controller.dispose);
      controller.selectModule(module, animate: false);
      expect(controller.module.id, id);
      expect(controller.params, module.defaultPreset.params);
      expect(controller.view.pan, module.defaultPreset.view.pan);
      expect(controller.view.zoom, module.defaultPreset.view.zoom);
      expect(controller.view.rotation, module.defaultPreset.view.rotation);

      final oldDefault = FractalPreset.fromJson(
          Map<String, Object?>.from(original['default'] as Map));
      final edited = oldDefault.copyWith(
        id: 'saved-edited',
        params: {...oldDefault.params, 'colorScheme': 3, 'iterations': 100.0},
        view: oldDefault.view.copyWith(
          pan: Vector2(0.1, -0.2),
          zoom: 2.0,
          rotation: Vector3(0, 0, 0.3),
        ),
      );
      for (final saved in [oldDefault, ...module.builtInPresets, edited]) {
        final restored = FractalPreset.fromJson(
            jsonDecode(jsonEncode(saved.toJson())) as Map<String, Object?>);
        await controller.applyPreset(restored);
        final expectedParams = {
          ...saved.params,
          // Older named Burning Ship records omit power.
          if (id == 'burning_ship' && !saved.params.containsKey('power'))
            'power': 2.0,
        };
        expect(controller.params, expectedParams);
        expect(controller.view.pan, saved.view.pan);
        expect(controller.view.zoom, saved.view.zoom);
        expect(controller.view.rotation, saved.view.rotation);
        final entry = HistoryEntry(
          id: 'saved-history',
          moduleId: id,
          params: saved.params,
          view: saved.view,
          visitedAt: builtInPresetCreatedAt,
        );
        final restoredEntry = HistoryEntry.fromJson(
            jsonDecode(jsonEncode(entry.toJson())) as Map<String, Object?>);
        controller.selectModule(registry.byId('julia'), animate: false);
        expect(await applyHistoryEntryToController(restoredEntry, controller),
            isTrue);
        expect(controller.module.id, id);
        expect(controller.params, expectedParams);
        expect(controller.view.pan, saved.view.pan);
        expect(controller.view.zoom, saved.view.zoom);
        expect(controller.view.rotation, saved.view.rotation);
      }
      controller.setTransparentBackground(true);
      controller.setRotationLocked(true);
      controller.resetSession();
      expect(controller.module.id, id);
      expect(controller.transparentBackground, isFalse);
      expect(controller.rotationLocked, isFalse);
      expect(controller.params, module.defaultPreset.params);
      expect(controller.view.pan, module.defaultPreset.view.pan);
      expect(controller.view.zoom, module.defaultPreset.view.zoom);
      expect(controller.view.rotation, module.defaultPreset.view.rotation);
    });
  }

  test(
      'explicit framing does not bypass first curated iterations or zoom clamp',
      () {
    final first = registry.byId('mandelbrot').builtInPresets[1];
    final module = buildEscapeTimeModule(EscapeTimeConfig(
      id: 'resolution-contract',
      name: 'Resolution contract',
      shaderAsset: 'unused.frag',
      defaultCenterX: 0,
      defaultCenterY: 0,
      defaultZoom: 100,
      defaultIterations: 40,
      extraPresets: [first],
    ));
    expect(module.defaultPreset.params['iterations'], 350);
    expect(module.defaultPreset.view.pan.x, 0);
    expect(module.defaultPreset.view.pan.y, 0);
    expect(module.defaultPreset.view.zoom, 32);
    final unchanged = buildBuiltInPresetList(
        moduleId: module.id,
        defaultPreset: module.defaultPreset,
        extraPresets: []);
    expect(
        unchanged.single.toJson(),
        module.defaultPreset
            .copyWith(id: '${module.id}-classic', name: 'Classic')
            .toJson());
  });
}
