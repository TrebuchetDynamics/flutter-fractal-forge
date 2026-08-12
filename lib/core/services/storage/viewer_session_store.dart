import 'dart:convert';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart';

/// Serializable state needed to recreate the last visible viewer frame.
class ViewerSessionSnapshot {
  static const int schemaVersion = 1;

  final String moduleId;
  final Map<String, Object> params;
  final FractalViewState view;
  final bool transparentBackground;
  final bool rotationLocked;
  final bool glowEnabled;
  final double glowSigma;
  final double glowIntensity;
  final bool fluidModeEnabled;
  final double fluidStrength;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final double kaleidoscopeRotation;
  final int kaleidoscopeMirrorMode;
  final bool controlsVisible;
  final bool fullscreenUnobtrusive;
  final bool viewerActive;

  ViewerSessionSnapshot({
    required this.moduleId,
    required Map<String, Object> params,
    required this.view,
    required this.transparentBackground,
    required this.rotationLocked,
    required this.glowEnabled,
    required this.glowSigma,
    required this.glowIntensity,
    required this.fluidModeEnabled,
    required this.fluidStrength,
    required this.kaleidoscopeEnabled,
    required this.kaleidoscopeSectors,
    required this.kaleidoscopeMirror,
    required this.kaleidoscopeRotation,
    required this.kaleidoscopeMirrorMode,
    required this.controlsVisible,
    required this.fullscreenUnobtrusive,
    required this.viewerActive,
  }) : params = Map<String, Object>.unmodifiable(params);

  void applyToController(
    FractalController controller, {
    bool notifyListeners = true,
  }) {
    if (!controller.registry.modules.any((module) => module.id == moduleId)) {
      throw StateError('Viewer snapshot references unknown module: $moduleId');
    }

    void apply() {
      controller.loadState(
        moduleId: moduleId,
        params: params,
        view: view,
        transparentBackground: transparentBackground,
        animateModule: false,
      );
      controller.setRotationLocked(rotationLocked);
      controller.setGlowEnabled(glowEnabled);
      controller.setGlowSigma(glowSigma);
      controller.setGlowIntensity(glowIntensity);
      controller.setFluidModeEnabled(fluidModeEnabled);
      controller.setFluidStrength(fluidStrength);
      controller.setKaleidoscopeEnabled(kaleidoscopeEnabled);
      controller.setKaleidoscopeSectors(kaleidoscopeSectors);
      controller.setKaleidoscopeMirror(kaleidoscopeMirror);
      controller.setKaleidoscopeRotation(kaleidoscopeRotation);
      controller.setKaleidoscopeMirrorMode(kaleidoscopeMirrorMode);
    }

    if (notifyListeners) {
      apply();
    } else {
      controller.runWithoutNotifications(apply);
    }
  }

  Map<String, Object> toJson() {
    final pan = view.pan;
    final rotation = view.rotation;
    return <String, Object>{
      'schemaVersion': schemaVersion,
      'moduleId': moduleId,
      'params': params,
      'view': <String, Object>{
        'pan': <double>[pan.x, pan.y],
        'zoom': view.zoom,
        'rotation': <double>[rotation.x, rotation.y, rotation.z],
      },
      'transparentBackground': transparentBackground,
      'rotationLocked': rotationLocked,
      'glowEnabled': glowEnabled,
      'glowSigma': glowSigma,
      'glowIntensity': glowIntensity,
      'fluidModeEnabled': fluidModeEnabled,
      'fluidStrength': fluidStrength,
      'kaleidoscopeEnabled': kaleidoscopeEnabled,
      'kaleidoscopeSectors': kaleidoscopeSectors,
      'kaleidoscopeMirror': kaleidoscopeMirror,
      'kaleidoscopeRotation': kaleidoscopeRotation,
      'kaleidoscopeMirrorMode': kaleidoscopeMirrorMode,
      'controlsVisible': controlsVisible,
      'fullscreenUnobtrusive': fullscreenUnobtrusive,
      'viewerActive': viewerActive,
    };
  }

  factory ViewerSessionSnapshot.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported viewer session schema');
    }
    final moduleId = json['moduleId'];
    final rawParams = json['params'];
    final rawView = json['view'];
    if (moduleId is! String ||
        moduleId.isEmpty ||
        rawParams is! Map ||
        rawView is! Map) {
      throw const FormatException('Invalid viewer session');
    }
    final pan = _finiteNumbers(rawView['pan'], 2);
    final rotation = _finiteNumbers(rawView['rotation'], 3);
    final zoom = _finiteDouble(rawView['zoom']);
    final params = <String, Object>{};
    for (final entry in rawParams.entries) {
      if (entry.key is! String || entry.value == null) continue;
      params[entry.key as String] = entry.value as Object;
    }

    return ViewerSessionSnapshot(
      moduleId: moduleId,
      params: params,
      view: FractalViewState(
        pan: Vector2(pan[0], pan[1]),
        zoom: zoom,
        rotation: Vector3(rotation[0], rotation[1], rotation[2]),
      ),
      transparentBackground: _bool(json, 'transparentBackground'),
      rotationLocked: _bool(json, 'rotationLocked'),
      glowEnabled: _bool(json, 'glowEnabled'),
      glowSigma: _finiteDouble(json['glowSigma']),
      glowIntensity: _finiteDouble(json['glowIntensity']),
      fluidModeEnabled: _bool(json, 'fluidModeEnabled'),
      fluidStrength: _finiteDouble(json['fluidStrength']),
      kaleidoscopeEnabled: _bool(json, 'kaleidoscopeEnabled'),
      kaleidoscopeSectors: _int(json, 'kaleidoscopeSectors'),
      kaleidoscopeMirror: _bool(json, 'kaleidoscopeMirror'),
      kaleidoscopeRotation: _finiteDouble(json['kaleidoscopeRotation']),
      kaleidoscopeMirrorMode: _int(json, 'kaleidoscopeMirrorMode'),
      controlsVisible: _bool(json, 'controlsVisible'),
      fullscreenUnobtrusive: _bool(json, 'fullscreenUnobtrusive'),
      viewerActive: _bool(json, 'viewerActive'),
    );
  }

  ViewerSessionSnapshot copyWith({
    bool? controlsVisible,
    bool? fullscreenUnobtrusive,
    bool? viewerActive,
  }) {
    return ViewerSessionSnapshot(
      moduleId: moduleId,
      params: params,
      view: view,
      transparentBackground: transparentBackground,
      rotationLocked: rotationLocked,
      glowEnabled: glowEnabled,
      glowSigma: glowSigma,
      glowIntensity: glowIntensity,
      fluidModeEnabled: fluidModeEnabled,
      fluidStrength: fluidStrength,
      kaleidoscopeEnabled: kaleidoscopeEnabled,
      kaleidoscopeSectors: kaleidoscopeSectors,
      kaleidoscopeMirror: kaleidoscopeMirror,
      kaleidoscopeRotation: kaleidoscopeRotation,
      kaleidoscopeMirrorMode: kaleidoscopeMirrorMode,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      fullscreenUnobtrusive:
          fullscreenUnobtrusive ?? this.fullscreenUnobtrusive,
      viewerActive: viewerActive ?? this.viewerActive,
    );
  }

  static bool _bool(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! bool) throw FormatException('Invalid $key');
    return value;
  }

  static int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! int) throw FormatException('Invalid $key');
    return value;
  }

  static double _finiteDouble(Object? value) {
    if (value is! num || !value.isFinite) {
      throw const FormatException('Expected finite number');
    }
    return value.toDouble();
  }

  static List<double> _finiteNumbers(Object? value, int length) {
    if (value is! List || value.length != length) {
      throw const FormatException('Invalid vector');
    }
    return value.map(_finiteDouble).toList(growable: false);
  }
}

/// Durable single-slot storage for the active viewer session.
class ViewerSessionStore {
  static const String preferencesKey = 'viewer_session_v1';

  final SharedPreferences _preferences;
  Future<void>? _writeQueue;

  ViewerSessionStore(this._preferences);

  static Future<ViewerSessionStore> create() async {
    return ViewerSessionStore(await SharedPreferences.getInstance());
  }

  ViewerSessionSnapshot? load() {
    final payload = _preferences.getString(preferencesKey);
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return ViewerSessionSnapshot.fromJson(
        decoded.cast<String, Object?>(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> save(ViewerSessionSnapshot snapshot) async {
    await _enqueueWrite(() => _write(snapshot));
  }

  Future<void> markViewerInactive() async {
    await _enqueueWrite(() async {
      final current = load();
      if (current == null || !current.viewerActive) return;
      await _write(current.copyWith(viewerActive: false));
    });
  }

  Future<void> _write(ViewerSessionSnapshot snapshot) async {
    await _preferences.setString(preferencesKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> _enqueueWrite(Future<void> Function() write) {
    final previous = _writeQueue;
    final result = previous == null ? write() : previous.then((_) => write());
    late final Future<void> tracked;
    tracked = result.catchError((Object _, StackTrace __) {}).whenComplete(() {
      if (identical(_writeQueue, tracked)) _writeQueue = null;
    });
    _writeQueue = tracked;
    return result;
  }
}
