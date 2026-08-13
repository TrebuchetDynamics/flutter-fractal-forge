import 'dart:async';
import 'dart:convert';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart';

class _DelayedSharedPreferences implements SharedPreferences {
  _DelayedSharedPreferences(String initialValue) : _value = initialValue;

  String? _value;
  final List<({String value, Completer<bool> completer})> _writes = [];

  void completeNewestPendingWrite() {
    final write = _writes.lastWhere((write) => !write.completer.isCompleted);
    _value = write.value;
    write.completer.complete(true);
  }

  @override
  String? getString(String key) =>
      key == ViewerSessionStore.preferencesKey ? _value : null;

  @override
  Future<bool> setString(String key, String value) {
    final completer = Completer<bool>();
    _writes.add((value: value, completer: completer));
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ViewerSessionSnapshot _snapshot({
  required String moduleId,
  required double zoom,
  bool viewerActive = true,
}) {
  return ViewerSessionSnapshot(
    moduleId: moduleId,
    params: const <String, Object>{},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: zoom,
      rotation: Vector3.zero(),
    ),
    transparentBackground: false,
    rotationLocked: false,
    glowEnabled: false,
    glowSigma: 1,
    glowIntensity: 1,
    fluidModeEnabled: false,
    fluidStrength: 1,
    kaleidoscopeEnabled: false,
    kaleidoscopeSectors: 6,
    kaleidoscopeMirror: false,
    kaleidoscopeRotation: 0,
    kaleidoscopeMirrorMode: 0,
    controlsVisible: false,
    fullscreenUnobtrusive: false,
    viewerActive: viewerActive,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('round trips the complete durable viewer snapshot', () async {
    final store = await ViewerSessionStore.create();
    final snapshot = ViewerSessionSnapshot(
      moduleId: 'julia',
      params: const <String, Object>{
        'iterations': 321,
        'colorScheme': 7,
      },
      view: FractalViewState(
        pan: Vector2(-0.75, 0.125),
        zoom: 42.5,
        rotation: Vector3(0.1, 0.2, 0.3),
      ),
      transparentBackground: true,
      rotationLocked: true,
      glowEnabled: true,
      glowSigma: 2.25,
      glowIntensity: 0.8,
      fluidModeEnabled: true,
      fluidStrength: 1.4,
      kaleidoscopeEnabled: true,
      kaleidoscopeSectors: 12,
      kaleidoscopeMirror: false,
      kaleidoscopeRotation: 0.45,
      kaleidoscopeMirrorMode: 2,
      controlsVisible: true,
      fullscreenUnobtrusive: false,
      viewerActive: true,
    );

    await store.save(snapshot);
    final restored = store.load();

    expect(restored, isNotNull);
    expect(restored!.moduleId, 'julia');
    expect(restored.params, snapshot.params);
    expect(restored.view.pan.x, -0.75);
    expect(restored.view.pan.y, 0.125);
    expect(restored.view.zoom, 42.5);
    expect(restored.view.rotation.z, closeTo(0.3, 1e-6));
    expect(restored.transparentBackground, isTrue);
    expect(restored.rotationLocked, isTrue);
    expect(restored.glowEnabled, isTrue);
    expect(restored.glowSigma, 2.25);
    expect(restored.glowIntensity, 0.8);
    expect(restored.fluidModeEnabled, isTrue);
    expect(restored.fluidStrength, 1.4);
    expect(restored.kaleidoscopeEnabled, isTrue);
    expect(restored.kaleidoscopeSectors, 12);
    expect(restored.kaleidoscopeMirror, isFalse);
    expect(restored.kaleidoscopeRotation, 0.45);
    expect(restored.kaleidoscopeMirrorMode, 2);
    expect(restored.controlsVisible, isTrue);
    expect(restored.fullscreenUnobtrusive, isFalse);
    expect(restored.viewerActive, isTrue);
  });

  test('corrupt or unsupported snapshots safely fall back to no state',
      () async {
    SharedPreferences.setMockInitialValues({
      ViewerSessionStore.preferencesKey: '{not json',
    });
    var store = await ViewerSessionStore.create();
    expect(store.load(), isNull);

    SharedPreferences.setMockInitialValues({
      ViewerSessionStore.preferencesKey: '{"schemaVersion":999}',
    });
    store = await ViewerSessionStore.create();
    expect(store.load(), isNull);
  });

  test('a delayed active save cannot resurrect a closed viewer', () async {
    final initial = _snapshot(moduleId: 'mandelbrot', zoom: 1);
    final preferences = _DelayedSharedPreferences(jsonEncode(initial.toJson()));
    final store = ViewerSessionStore(preferences);

    final staleSave = store.save(_snapshot(moduleId: 'mandelbrot', zoom: 2));
    final close = store.markViewerInactive();
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 2; i++) {
      preferences.completeNewestPendingWrite();
      await Future<void>.delayed(Duration.zero);
    }
    await Future.wait([staleSave, close]);

    expect(store.load()!.viewerActive, isFalse);
  });

  test('a stale session cannot overwrite a rapid reopen', () async {
    final initial = _snapshot(moduleId: 'mandelbrot', zoom: 1);
    final preferences = _DelayedSharedPreferences(jsonEncode(initial.toJson()));
    final store = ViewerSessionStore(preferences);

    final staleSave = store.save(_snapshot(moduleId: 'mandelbrot', zoom: 2));
    final close = store.markViewerInactive();
    final reopen = store.save(_snapshot(moduleId: 'julia', zoom: 3));
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 3; i++) {
      preferences.completeNewestPendingWrite();
      await Future<void>.delayed(Duration.zero);
    }
    await Future.wait([staleSave, close, reopen]);

    expect(store.load()!.moduleId, 'julia');
    expect(store.load()!.view.zoom, 3);
    expect(store.load()!.viewerActive, isTrue);
  });
}
