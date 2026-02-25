// Test modules for debugging GPU rendering on emulator (SwiftShader)
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:vector_math/vector_math.dart';

/// Test 1: Minimal shader - just outputs solid red, no uniforms
final FractalModule testMinimalModule = FractalModule(
  id: 'test_minimal',
  displayName: (AppLocalizations l10n) => 'Test: Minimal (Solid Red)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_minimal.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: FractalPreset(
    id: 'test_minimal_default',
    name: 'Default',
    moduleId: 'test_minimal',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime(2026),
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // No uniforms needed for minimal test
  },
);

/// Test 2: gl_FragCoord shader - uses standard GLSL gl_FragCoord
final FractalModule testGlFragCoordModule = FractalModule(
  id: 'test_gl_fragcoord',
  displayName: (AppLocalizations l10n) => 'Test: gl_FragCoord (UV Gradient)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_gl_fragcoord.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: FractalPreset(
    id: 'test_gl_fragcoord_default',
    name: 'Default',
    moduleId: 'test_gl_fragcoord',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime(2026),
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // Only set resolution uniform
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
  },
);

/// Test 3: FlutterFragCoord shader - uses Flutter's FlutterFragCoord() helper
final FractalModule testFlutterCoordModule = FractalModule(
  id: 'test_flutter_coord',
  displayName: (AppLocalizations l10n) => 'Test: FlutterFragCoord (UV Gradient)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_flutter_coord.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: FractalPreset(
    id: 'test_flutter_coord_default',
    name: 'Default',
    moduleId: 'test_flutter_coord',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime(2026),
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // Only set resolution uniform
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
  },
);

/// Test 4: Always red - no uniforms, no conditions, just constant red output
final FractalModule testAlwaysRedModule = FractalModule(
  id: 'test_always_red',
  displayName: (AppLocalizations l10n) => 'Test: ALWAYS RED (no uniforms)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_always_red.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: FractalPreset(
    id: 'test_always_red_default',
    name: 'Default',
    moduleId: 'test_always_red',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime(2026),
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // NO UNIFORMS - not even trying to set them
  },
);

/// Test 5: Uniform test - outputs green if uResolution.x > 100, red otherwise
final FractalModule testUniformOnlyModule = FractalModule(
  id: 'test_uniform_only',
  displayName: (AppLocalizations l10n) => 'Test: Uniform Check (Green/Red)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_uniform_only.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: FractalPreset(
    id: 'test_uniform_only_default',
    name: 'Default',
    moduleId: 'test_uniform_only',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime(2026),
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // Set resolution - shader will show green if this reaches the GPU correctly
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
  },
);
