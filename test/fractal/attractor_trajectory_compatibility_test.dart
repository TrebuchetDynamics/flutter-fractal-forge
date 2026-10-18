import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/controllers/input/fractal_view_input_bounds.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/modules/attractor_trajectory.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('legacy presets and history remain on the portrait representation', () {
    final preset = FractalPreset.fromJson({
      'id': 'legacy-thomas',
      'moduleId': 'thomas_attractor',
      'name': 'Legacy view',
      'params': <String, Object>{'iterations': 260},
      'view': <String, Object>{
        'panX': 0.2,
        'panY': -0.1,
        'zoom': 0.8,
        'rotX': 0,
        'rotY': 0,
        'rotZ': 0,
      },
      'createdAt': '2026-01-01T00:00:00.000Z',
    });
    final history = HistoryEntry.fromJson({
      'id': 'old-history',
      'moduleId': 'thomas_attractor',
      'params': <String, Object>{'iterations': 260},
      'view': <String, Object>{'panX': 0.2, 'panY': -0.1, 'zoom': 0.8},
      'visitedAt': '2026-01-01T00:00:00.000Z',
    });

    expect(preset.view.trajectory, isNull);
    expect(history.view.trajectory, isNull);
    expect(preset.view.zoom, 0.8);
    expect(preset.view.pan.x, 0.2);
  });

  test('trajectory representation round-trips through saved state paths', () {
    final settings = OrbitTrajectorySettings.defaultsFor('four_wing');
    final view = FractalViewState(
      pan: Vector2(0.15, -0.25),
      zoom: 1.4,
      rotation: Vector3.zero(),
      trajectory: settings,
    );
    final preset = FractalPreset(
      id: 'trajectory-four-wing',
      moduleId: 'four_wing',
      name: 'Trajectory',
      params: const <String, Object>{'iterations': 260},
      view: view,
      createdAt: DateTime.utc(2026),
    );
    final restoredPreset = FractalPreset.fromJson(preset.toJson());
    expect(restoredPreset.view.trajectory, settings);
    expect(restoredPreset.view.pan.x, 0.15);
    expect(restoredPreset.view.zoom, 1.4);

    final snapshot = ViewerSessionSnapshot(
      moduleId: 'four_wing',
      params: const <String, Object>{'iterations': 260},
      view: view,
      transparentBackground: false,
      rotationLocked: false,
      glowEnabled: false,
      glowSigma: 1,
      glowIntensity: 0.35,
      fluidModeEnabled: false,
      fluidStrength: 1,
      kaleidoscopeEnabled: false,
      kaleidoscopeSectors: 8,
      kaleidoscopeMirror: true,
      kaleidoscopeRotation: 0,
      kaleidoscopeMirrorMode: 0,
      controlsVisible: true,
      fullscreenUnobtrusive: false,
      viewerActive: true,
    );
    final restoredSnapshot = ViewerSessionSnapshot.fromJson(snapshot.toJson());
    expect(restoredSnapshot.view.trajectory, settings);
  });

  test('trajectory metadata is discarded when restored onto another system',
      () {
    final candidate = FractalViewState(
      pan: Vector2.zero(),
      zoom: 1,
      rotation: Vector3.zero(),
      trajectory: OrbitTrajectorySettings.defaultsFor('four_wing'),
    );
    final normalized = FractalViewInputBounds.normalizeView(
      candidate: candidate,
      current: FractalViewState.initial(),
      moduleId: 'thomas_attractor',
    );

    expect(normalized.trajectory, isNull);
  });

  test('only the three exact module defaults opt into trajectory rendering',
      () {
    final registry = ModuleRegistry();
    final trajectoryIds = {
      for (final module in registry.modules)
        if (module.defaultPreset.view.trajectory != null) module.id,
    };

    expect(
      trajectoryIds,
      containsAll({'thomas_attractor', 'four_wing', 'lorenz_2d'}),
    );
    expect(trajectoryIds, hasLength(3));
    for (final id in trajectoryIds) {
      expect(registry.byId(id).defaultPreset.view.zoom, 1.0, reason: id);
    }
    final legacyAlias = registry.byId('f0057_thomas_attractor');
    expect(legacyAlias.defaultPreset.view.trajectory, isNull);
    expect(
        legacyAlias.shaderAsset, registry.byId('thomas_attractor').shaderAsset);
  });

  test('mathematics disclosure names finite integration and its equation', () {
    final registry = ModuleRegistry();
    final thomas = registry.byId('thomas_attractor');
    final disclosure = FractalMathematics.forModule(thomas);
    final formula = disclosure.formula(thomas.defaultPreset.params);

    expect(disclosure.method, 'Fixed-step RK4 trajectory');
    expect(disclosure.view, contains('oblique plane'));
    expect(formula, contains('sin(y)-0.208186x'));
    expect(formula, contains('burn-in=5000'));
    expect(formula, contains('samples=20000'));
    expect(formula, contains('legacy saved views retain'));
  });
}
