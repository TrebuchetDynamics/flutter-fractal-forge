/// Replayable kaleidoscope effect state owned by [FractalController].
///
/// Some catalog modules are kaleidoscope-specific and temporarily force the
/// global kaleidoscope canvas effect on with module defaults. Keeping the
/// previous user-controlled effect state separate from the forced module state
/// prevents module switches from leaking kaleidoscope settings into unrelated
/// fractals.
final class FractalKaleidoscopeState {
  static const int defaultSectors = 8;
  static const int forcedModuleSectors = 16;
  static const int defaultMirrorMode = 0;
  static const int forcedModuleMirrorMode = 3;

  final bool enabled;
  final int sectors;
  final bool mirror;
  final double rotation;
  final int mirrorMode;

  const FractalKaleidoscopeState({
    required this.enabled,
    required this.sectors,
    required this.mirror,
    required this.rotation,
    required this.mirrorMode,
  });

  const FractalKaleidoscopeState.defaults()
      : enabled = false,
        sectors = defaultSectors,
        mirror = true,
        rotation = 0.0,
        mirrorMode = defaultMirrorMode;

  FractalKaleidoscopeState copyWith({
    bool? enabled,
    int? sectors,
    bool? mirror,
    double? rotation,
    int? mirrorMode,
  }) {
    return FractalKaleidoscopeState(
      enabled: enabled ?? this.enabled,
      sectors: sectors ?? this.sectors,
      mirror: mirror ?? this.mirror,
      rotation: rotation ?? this.rotation,
      mirrorMode: mirrorMode ?? this.mirrorMode,
    );
  }
}

/// Result of applying module-specific kaleidoscope defaults.
final class FractalKaleidoscopeModuleTransition {
  final FractalKaleidoscopeState effective;
  final FractalKaleidoscopeState? restoreAfterForcedModule;

  const FractalKaleidoscopeModuleTransition({
    required this.effective,
    required this.restoreAfterForcedModule,
  });
}

/// Pure module-switch policy for kaleidoscope-specific catalog modules.
final class FractalKaleidoscopeModulePolicy {
  const FractalKaleidoscopeModulePolicy._();

  static bool isForcedModuleId(String moduleId) =>
      moduleId.contains('kaleidoscope');

  static FractalKaleidoscopeModuleTransition transitionForModule({
    required String moduleId,
    required FractalKaleidoscopeState current,
    required FractalKaleidoscopeState? restoreAfterForcedModule,
  }) {
    if (isForcedModuleId(moduleId)) {
      return FractalKaleidoscopeModuleTransition(
        effective: current.copyWith(
          enabled: true,
          sectors: FractalKaleidoscopeState.forcedModuleSectors,
          mirrorMode: FractalKaleidoscopeState.forcedModuleMirrorMode,
        ),
        restoreAfterForcedModule: restoreAfterForcedModule ?? current,
      );
    }

    if (restoreAfterForcedModule != null) {
      return FractalKaleidoscopeModuleTransition(
        effective: restoreAfterForcedModule,
        restoreAfterForcedModule: null,
      );
    }

    return FractalKaleidoscopeModuleTransition(
      effective: current,
      restoreAfterForcedModule: null,
    );
  }
}
