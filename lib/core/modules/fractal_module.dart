import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// A function that returns a localized display name for a fractal module.
///
/// Takes an [AppLocalizations] instance and returns the appropriate
/// translated string for the current locale.
typedef ModuleNameBuilder = String Function(AppLocalizations l10n);

/// A function that configures shader uniforms for fractal rendering.
///
/// Called each frame to set the shader's uniform values based on the
/// current [state], canvas [size], and elapsed [time].
///
/// Parameters:
/// - [shader]: The fragment shader to configure
/// - [state]: Current fractal parameters and view state
/// - [size]: Canvas dimensions in logical pixels
/// - [time]: Elapsed time in milliseconds (for animations)
typedef UniformSetter = void Function(
  FragmentShader shader,
  FractalRenderState state,
  Size size,
  double time,
);

/// Defines whether a fractal is rendered in 2D or 3D space.
///
/// This affects gesture behavior (pan vs rotate) and rendering approach.
enum FractalDimension {
  /// 2D fractals rendered on a plane (e.g., Mandelbrot, Julia).
  ///
  /// Supports panning and zooming gestures.
  twoD,

  /// 3D fractals rendered with raymarching (e.g., Mandelbulb).
  ///
  /// Supports rotation and zooming gestures.
  threeD,
}

/// Defines a complete fractal type with its rendering configuration.
///
/// A [FractalModule] encapsulates everything needed to render a specific
/// type of fractal:
/// - Display metadata (name, dimension)
/// - Shader asset path
/// - Configurable parameters with their ranges
/// - Default and built-in presets
/// - Uniform setting logic
///
/// Modules are immutable and registered with [ModuleRegistry] at app startup.
///
/// {@category Modules}
///
/// Example of creating a custom fractal module:
/// ```dart
/// final myModule = FractalModule(
///   id: 'my_fractal',
///   displayName: (l10n) => 'My Fractal',
///   dimension: FractalDimension.twoD,
///   shaderAsset: 'shaders/my_fractal.frag',
///   parameters: [/* ... */],
///   defaultPreset: myDefaultPreset,
///   builtInPresets: [/* ... */],
///   setUniforms: (shader, state, size, time) {
///     // Configure shader uniforms...
///   },
/// );
/// ```
@immutable
class FractalModule {
  /// Unique identifier for this module.
  ///
  /// Used for preset storage, module lookup, and serialization.
  /// Should be a lowercase, snake_case string.
  final String id;

  /// Returns the localized display name for this fractal.
  ///
  /// Example: `(l10n) => l10n.moduleMandelbrot`
  final ModuleNameBuilder displayName;

  /// Whether this is a 2D or 3D fractal.
  ///
  /// Affects gesture handling and rendering approach.
  final FractalDimension dimension;

  /// Path to the GLSL fragment shader asset.
  ///
  /// The shader must be registered in `pubspec.yaml` under `flutter.shaders`.
  /// Example: `'shaders/legacy/mandelbrot.frag'`
  final String shaderAsset;

  /// The configurable parameters for this fractal type.
  ///
  /// Each parameter defines its type, valid range, step size, and default value.
  /// These are used to generate the controls UI and validate user input.
  final List<FractalParameter> parameters;

  /// The default preset applied when this module is first selected.
  ///
  /// Should provide sensible starting values for an attractive render.
  final FractalPreset defaultPreset;

  /// Pre-configured presets included with this module.
  ///
  /// These appear in the preset selector and showcase different
  /// visual configurations of this fractal type.
  final List<FractalPreset> builtInPresets;

  /// Function that sets shader uniforms each frame.
  ///
  /// This bridges the Dart parameter values to the GLSL shader's
  /// uniform variables. The uniform layout must match the shader code.
  final UniformSetter setUniforms;

  /// Creates a new [FractalModule] with the specified configuration.
  ///
  /// All parameters are required to ensure a complete module definition.
  const FractalModule({
    required this.id,
    required this.displayName,
    required this.dimension,
    required this.shaderAsset,
    required this.parameters,
    required this.defaultPreset,
    required this.builtInPresets,
    required this.setUniforms,
  });
}

/// Snapshot of the current fractal rendering state.
///
/// Combines the fractal's mathematical parameters with view state
/// (pan, zoom, rotation) for rendering a single frame.
///
/// This is passed to the [UniformSetter] each frame to configure shaders.
@immutable
class FractalRenderState {
  /// Current parameter values keyed by parameter ID.
  ///
  /// Values are typed according to [FractalParamType]:
  /// - `float`: [double]
  /// - `integer`: [int]
  /// - `boolean`: [bool]
  /// - `enumeration`: depends on options
  final Map<String, Object> params;

  /// Current view transformation state.
  ///
  /// Includes pan offset (2D), zoom level, and rotation angles (3D).
  final FractalViewState view;

  /// Whether to render with a transparent background.
  ///
  /// When true, the shader should output alpha=0 for background pixels.
  /// Used for transparent PNG export.
  final bool transparentBackground;

  /// Creates a new [FractalRenderState] with the given values.
  const FractalRenderState({
    required this.params,
    required this.view,
    required this.transparentBackground,
  });
}
