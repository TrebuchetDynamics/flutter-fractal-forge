import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';

const legacyPowers = <String, double>{
  'burning_ship_cubic': 3,
  'burning_ship_power4': 4,
  'burning_ship_power5': 5,
  'burning_ship_power6': 6,
  'burning_ship_power7': 7,
  'f0113_burning_ship_d_7': 7,
  'f0114_burning_ship_d_8': 8,
  'f0115_burning_ship_d_9': 9,
  'f0116_burning_ship_d_10': 10,
  'f0117_burning_ship_d_11': 11,
  'f0118_burning_ship_d_12': 12,
  'f0140_burning_ship_z_2_5': 2.5,
  'f0141_burning_ship_z_1_5': 1.5,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('animated legacy selection publishes only the requested degree', () {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final observed = <Object?>[];
    controller.addListener(() => observed.add(controller.params['power']));
    controller.selectModule(registry.byId('burning_ship_power7'));
    expect(observed, [7.0]);
  });

  test('unified user preset list retains legacy storage ownership', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await PresetStore.create();
    final registry = ModuleRegistry();
    for (final id in ['burning_ship_cubic', 'f0114_burning_ship_d_8']) {
      await store.saveUserPreset(registry.byId(id).defaultPreset.copyWith(
            id: 'same-id',
            isBuiltIn: false,
          ));
    }
    final presets = await store.loadUserPresets('burning_ship');
    expect(presets.map((p) => p.moduleId),
        ['burning_ship_cubic', 'f0114_burning_ship_d_8']);
    await store.updatePreset('burning_ship_cubic', 'same-id', name: 'Renamed');
    expect((await store.loadUserPresets('burning_ship')).first.name, 'Renamed');
    await store.deleteUserPreset('burning_ship_cubic', 'same-id');
    expect((await store.loadUserPresets('burning_ship')).single.moduleId,
        'f0114_burning_ship_d_8');
  });

  test('legacy centers retain their mathematical location', () async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    for (final entry in legacyPowers.entries) {
      await controller.loadState(
        moduleId: entry.key,
        params: const {},
        view: FractalViewState(
            pan: Vector2(-0.2, -0.8), zoom: 2, rotation: Vector3.zero()),
      );
      final oldUnflipped = const {
        'burning_ship_power4',
        'burning_ship_power5',
        'burning_ship_power6',
        'burning_ship_power7',
      }.contains(entry.key);
      // At the center, unified GLSL samples (pan.x, -pan.y).
      expect(controller.view.pan.x, -0.2);
      expect(-controller.view.pan.y, oldUnflipped ? -0.8 : 0.8);
      final saved = registry.byId(entry.key).defaultPreset.copyWith(
            view: FractalViewState(
                pan: Vector2(-0.2, -0.8), zoom: 2, rotation: Vector3.zero()),
          );
      await controller.applyPreset(saved);
      expect(-controller.view.pan.y, oldUnflipped ? -0.8 : 0.8);
      expect(saved.view.pan.y, -0.8);
    }
  });

  test('Explore hides degree duplicates but saved catalog IDs still resolve',
      () {
    final repo = CatalogRepository.fromRegistry(ModuleRegistry());
    final ids = repo.exploreEntries.map((e) => e.module.id).toSet();
    expect(ids, contains('burning_ship'));
    expect(ids, containsAll(['burning_ship_perp', 'burning_ship_julia']));
    for (final id in legacyPowers.keys) {
      expect(ids, isNot(contains(id)));
      expect(repo.byCatalogId('core.$id').module.id, id);
    }
  });

  test('degree variants are replayable presets on Burning Ship', () async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final ship = registry.byId('burning_ship');
    controller.selectModule(ship, animate: false);
    for (final entry in legacyPowers.entries) {
      final preset = ship.builtInPresets.singleWhere(
        (preset) => preset.id == '${entry.key}-degree',
      );
      expect(preset.moduleId, 'burning_ship');
      await controller.applyPreset(preset);
      expect(controller.params['power'], entry.value);
    }
  });

  for (final entry in legacyPowers.entries) {
    test('${entry.key} selects unified module at its original power', () async {
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      addTearDown(controller.dispose);
      final legacy = registry.byId(entry.key);
      controller.selectModule(legacy, animate: false);
      expect(controller.module.id, 'burning_ship');
      expect(controller.params['power'], entry.value);
      // Catalog favorites apply their old default preset after selection.
      await controller.applyPreset(legacy.defaultPreset);
      expect(controller.module.id, 'burning_ship');
      expect(controller.params['power'], entry.value);
      await controller.loadState(
        moduleId: entry.key,
        params: const {},
        view: legacy.defaultPreset.view,
      );
      expect(controller.module.id, 'burning_ship');
      expect(controller.params['power'], entry.value);
      expect(controller.view.pan.x, legacy.defaultPreset.view.pan.x);
      await controller.loadState(
        moduleId: entry.key,
        params: const {'power': 6.5},
        view: legacy.defaultPreset.view,
      );
      expect(controller.params['power'], 6.5);
    });
  }
}
