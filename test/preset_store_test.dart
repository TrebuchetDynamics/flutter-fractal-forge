import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';

FractalPreset _makePreset(String id, String moduleId,
    {String name = 'Test', bool isBuiltIn = false}) {
  return FractalPreset(
    id: id,
    moduleId: moduleId,
    name: name,
    params: {'iterations': 100},
    view: FractalViewState(
      pan: Vector2(0.0, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.utc(2024, 1, 1),
    isBuiltIn: isBuiltIn,
  );
}

void main() {
  group('PresetStore', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('create() factory returns a valid store', () async {
      final store = await PresetStore.create();
      expect(store, isNotNull);
    });

    test('loadUserPresets returns empty list for unknown module', () async {
      final store = await PresetStore.create();
      final presets = await store.loadUserPresets('unknown_module');
      expect(presets, isEmpty);
    });

    test('saveUserPreset persists preset and loadUserPresets returns it',
        () async {
      final store = await PresetStore.create();
      final preset = _makePreset('p1', 'mandelbrot', name: 'My Preset');

      await store.saveUserPreset(preset);
      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded, hasLength(1));
      expect(loaded.first.id, equals('p1'));
      expect(loaded.first.name, equals('My Preset'));
      expect(loaded.first.moduleId, equals('mandelbrot'));
    });

    test('loadUserPresets for a different module returns empty list', () async {
      final store = await PresetStore.create();
      await store.saveUserPreset(_makePreset('p1', 'mandelbrot'));

      final loaded = await store.loadUserPresets('julia');
      expect(loaded, isEmpty);
    });

    test(
        'loadUserPresets filters stale entries stored under the wrong module key',
        () async {
      SharedPreferences.setMockInitialValues({
        'user_presets_mandelbrot': FractalPreset.listToPrefs([
          _makePreset('p1', 'mandelbrot'),
          _makePreset('stale-julia', 'julia'),
        ]),
      });
      final store = await PresetStore.create();

      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded.map((preset) => preset.id), ['p1']);
    });

    test('deleteUserPreset removes the preset', () async {
      final store = await PresetStore.create();
      await store.saveUserPreset(_makePreset('p1', 'mandelbrot'));
      await store.saveUserPreset(_makePreset('p2', 'mandelbrot'));

      await store.deleteUserPreset('mandelbrot', 'p1');
      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded, hasLength(1));
      expect(loaded.first.id, equals('p2'));
    });

    test('deleteUserPreset on non-existent id leaves list unchanged', () async {
      final store = await PresetStore.create();
      await store.saveUserPreset(_makePreset('p1', 'mandelbrot'));

      await store.deleteUserPreset('mandelbrot', 'does-not-exist');
      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded, hasLength(1));
    });

    test('saveUserPreset replaces preset with same id', () async {
      final store = await PresetStore.create();
      await store
          .saveUserPreset(_makePreset('p1', 'mandelbrot', name: 'Original'));
      await store
          .saveUserPreset(_makePreset('p1', 'mandelbrot', name: 'Updated'));

      final loaded = await store.loadUserPresets('mandelbrot');
      expect(loaded, hasLength(1));
      expect(loaded.first.name, equals('Updated'));
    });

    test('user presets are stored separately per module', () async {
      final store = await PresetStore.create();
      await store.saveUserPreset(_makePreset('p1', 'mandelbrot'));
      await store.saveUserPreset(_makePreset('p2', 'julia'));

      final mandelbrot = await store.loadUserPresets('mandelbrot');
      final julia = await store.loadUserPresets('julia');

      expect(mandelbrot, hasLength(1));
      expect(mandelbrot.first.id, equals('p1'));
      expect(julia, hasLength(1));
      expect(julia.first.id, equals('p2'));
    });

    test(
        'user presets are separate from built-in presets (isBuiltIn flag preserved)',
        () async {
      final store = await PresetStore.create();
      final userPreset = _makePreset('user-1', 'mandelbrot', isBuiltIn: false);
      final builtIn = _makePreset('builtin-1', 'mandelbrot', isBuiltIn: true);

      await store.saveUserPreset(userPreset);
      await store.saveUserPreset(builtIn);

      final loaded = await store.loadUserPresets('mandelbrot');
      expect(loaded, hasLength(2));

      final userLoaded = loaded.firstWhere((p) => p.id == 'user-1');
      final builtInLoaded = loaded.firstWhere((p) => p.id == 'builtin-1');
      expect(userLoaded.isBuiltIn, isFalse);
      expect(builtInLoaded.isBuiltIn, isTrue);
    });

    test('updatePreset renames preset by id', () async {
      final store = await PresetStore.create();
      await store
          .saveUserPreset(_makePreset('p1', 'mandelbrot', name: 'Old Name'));

      await store.updatePreset('mandelbrot', 'p1', name: 'New Name');
      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded.first.name, equals('New Name'));
    });

    test('updatePreset on non-existent id is a no-op', () async {
      final store = await PresetStore.create();
      await store
          .saveUserPreset(_makePreset('p1', 'mandelbrot', name: 'Original'));

      await store.updatePreset('mandelbrot', 'does-not-exist', name: 'Ghost');
      final loaded = await store.loadUserPresets('mandelbrot');

      expect(loaded.first.name, equals('Original'));
    });
  });
}
