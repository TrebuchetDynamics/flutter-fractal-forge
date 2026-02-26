import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

/// Parsed deep link data containing fractal configuration.
///
/// This class represents the configuration extracted from a deep link URL
/// like `fractalforge://view?type=mandelbrot&zoom=10&x=0.5`.
///
/// {@category Services}
class DeepLinkData {
  /// The fractal module ID (e.g., 'mandelbrot', 'julia', 'mandelbulb').
  final String type;

  /// Zoom level (magnification).
  final double? zoom;

  /// Pan X coordinate (2D fractals).
  final double? x;

  /// Pan Y coordinate (2D fractals).
  final double? y;

  /// Rotation X angle in radians (3D fractals).
  final double? rotX;

  /// Rotation Y angle in radians (3D fractals).
  final double? rotY;

  /// Rotation Z angle in radians (3D fractals).
  final double? rotZ;

  /// Number of iterations.
  final int? iterations;

  /// Bailout radius.
  final double? bailout;

  /// Color scheme index.
  final int? colorScheme;

  /// Power parameter (for fractals like Mandelbulb).
  final double? power;

  /// Julia set real constant (c.x).
  final double? juliaX;

  /// Julia set imaginary constant (c.y).
  final double? juliaY;

  const DeepLinkData({
    required this.type,
    this.zoom,
    this.x,
    this.y,
    this.rotX,
    this.rotY,
    this.rotZ,
    this.iterations,
    this.bailout,
    this.colorScheme,
    this.power,
    this.juliaX,
    this.juliaY,
  });

  /// Creates a [FractalViewState] from the parsed deep link data.
  FractalViewState toViewState() {
    return FractalViewState(
      pan: Vector2(x ?? 0.0, y ?? 0.0),
      zoom: zoom ?? 1.0,
      rotation: Vector3(rotX ?? 0.0, rotY ?? 0.0, rotZ ?? 0.0),
    );
  }

  /// Extracts fractal parameters from the deep link data.
  ///
  /// Returns a map of parameter IDs to values.
  Map<String, Object> toParams() {
    final params = <String, Object>{};

    if (iterations != null) params['iterations'] = iterations!;
    if (bailout != null) params['bailout'] = bailout!;
    if (colorScheme != null) params['colorScheme'] = colorScheme!;
    if (power != null) params['power'] = power!;
    if (juliaX != null) params['juliaX'] = juliaX!;
    if (juliaY != null) params['juliaY'] = juliaY!;

    return params;
  }

  @override
  String toString() {
    return 'DeepLinkData(type: $type, zoom: $zoom, x: $x, y: $y, '
        'rotX: $rotX, rotY: $rotY, rotZ: $rotZ, iterations: $iterations, '
        'bailout: $bailout, colorScheme: $colorScheme, power: $power, '
        'juliaX: $juliaX, juliaY: $juliaY)';
  }
}

/// Service for handling deep links with the `fractalforge://` scheme.
///
/// Supports URLs like:
/// - `fractalforge://view?type=mandelbrot&zoom=10&x=-0.5&y=0.1`
/// - `fractalforge://view?type=julia&juliaX=-0.7&juliaY=0.27&colorScheme=2`
/// - `fractalforge://view?type=mandelbulb&rotX=0.5&rotY=0.3&power=8`
///
/// {@category Services}
class DeepLinkService {
  static const String scheme = 'fractalforge';
  static const String host = 'view';

  // Method channel for receiving deep links from native code
  static const MethodChannel _channel = MethodChannel('com.fractalforge/deeplink');

  final StreamController<DeepLinkData> _linkController =
      StreamController<DeepLinkData>.broadcast();

  /// Stream of parsed deep link data.
  Stream<DeepLinkData> get linkStream => _linkController.stream;

  DeepLinkData? _initialLink;

  /// The initial deep link that launched the app (if any).
  DeepLinkData? get initialLink => _initialLink;

  /// Initializes the deep link service.
  ///
  /// Sets up listeners for incoming deep links from the platform.
  Future<void> initialize() async {
    // TEMPORARY SAFETY SWITCH (2026-02): deep link channel init causes a black screen
    // on some Samsung S24 devices during startup.
    // User confirmed deep links are not needed for the immediate release.
    // We leave parsing + stream support intact for later re-enable.
    const bool kEnableDeepLinks = bool.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: false);
    if (!kEnableDeepLinks) {
      return;
    }

    // Set up method channel handler for incoming links
    _channel.setMethodCallHandler(_handleMethodCall);

    // Try to get the initial link that launched the app
    try {
      final String? initialUri = await _channel.invokeMethod('getInitialLink');
      if (initialUri != null) {
        try {
          final uri = Uri.parse(initialUri);
          final data = parseUri(uri);
          if (data != null) {
            _initialLink = data;
          }
        } catch (e) {
          // Malformed URI, ignore
          if (kDebugMode) debugPrint('Failed to parse initial deep link URI: $e');
        }
      }
    } on PlatformException {
      // Platform doesn't support deep links or no initial link
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onDeepLink') {
      final String uriString = call.arguments as String;
      try {
        final uri = Uri.parse(uriString);
        final data = parseUri(uri);
        if (data != null) {
          _linkController.add(data);
        }
      } catch (e) {
        // Malformed URI, ignore
        if (kDebugMode) debugPrint('Failed to parse deep link URI: $e');
      }
    }
  }

  /// Parses a URI into [DeepLinkData].
  ///
  /// Returns null if the URI is not a valid fractalforge deep link or
  /// if the fractal type is not recognized.
  static DeepLinkData? parseUri(Uri uri, {List<String>? validFractalTypes}) {
    // Accept both 'fractalforge' scheme and https with our host
    if (uri.scheme != scheme && uri.scheme != 'https') {
      return null;
    }

    // For https, check the host matches exactly
    const allowedHosts = {'fractalforge.app', 'www.fractalforge.app'};
    if (uri.scheme == 'https' && !allowedHosts.contains(uri.host)) {
      return null;
    }

    // For custom scheme, accept 'view' as host or path
    final isViewPath = uri.host == host || uri.path == '/$host' || uri.path == host;
    if (uri.scheme == scheme && !isViewPath) {
      return null;
    }

    final params = uri.queryParameters;
    final type = params['type'];

    if (type == null || type.isEmpty) {
      return null;
    }

    // Reject type strings with unsafe characters (defense-in-depth)
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(type)) {
      return null;
    }

    // Validate fractal type if validation list provided
    if (validFractalTypes != null && !validFractalTypes.contains(type)) {
      return null;
    }

    return DeepLinkData(
      type: type,
      zoom: _parseBoundedDouble(params['zoom'], 0.001, 1e15, 'zoom'),
      x: _parseBoundedDouble(params['x'], -1e10, 1e10, 'x'),
      y: _parseBoundedDouble(params['y'], -1e10, 1e10, 'y'),
      rotX: _parseBoundedDouble(params['rotX'], -1e10, 1e10, 'rotX'),
      rotY: _parseBoundedDouble(params['rotY'], -1e10, 1e10, 'rotY'),
      rotZ: _parseBoundedDouble(params['rotZ'], -1e10, 1e10, 'rotZ'),
      iterations: _parseBoundedInt(params['iterations'], 1, 10000, 'iterations'),
      bailout: _parseBoundedDouble(params['bailout'], 1.0, 1e10, 'bailout'),
      colorScheme: _parseBoundedInt(params['colorScheme'], 0, 9999, 'colorScheme'),
      power: _parseBoundedDouble(params['power'], 1, 20, 'power'),
      juliaX: _parseBoundedDouble(params['juliaX'], -1e10, 1e10, 'juliaX'),
      juliaY: _parseBoundedDouble(params['juliaY'], -1e10, 1e10, 'juliaY'),
    );
  }

  /// Builds a shareable deep link URL from the current fractal state.
  ///
  /// The [moduleId] specifies the fractal type, [params] contains the
  /// fractal parameters, and [view] contains the camera/view state.
  static Uri buildUri({
    required String moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
  }) {
    final queryParams = <String, String>{
      'type': moduleId,
    };

    // Add view state
    if (view.zoom != 1.0) {
      queryParams['zoom'] = _formatDouble(view.zoom);
    }
    if (view.pan.x != 0.0) {
      queryParams['x'] = _formatDouble(view.pan.x);
    }
    if (view.pan.y != 0.0) {
      queryParams['y'] = _formatDouble(view.pan.y);
    }
    if (view.rotation.x != 0.0) {
      queryParams['rotX'] = _formatDouble(view.rotation.x);
    }
    if (view.rotation.y != 0.0) {
      queryParams['rotY'] = _formatDouble(view.rotation.y);
    }
    if (view.rotation.z != 0.0) {
      queryParams['rotZ'] = _formatDouble(view.rotation.z);
    }

    // Add fractal parameters
    if (params.containsKey('iterations')) {
      queryParams['iterations'] = params['iterations'].toString();
    }
    if (params.containsKey('bailout')) {
      queryParams['bailout'] = _formatDouble(_toDouble(params['bailout']));
    }
    if (params.containsKey('colorScheme')) {
      queryParams['colorScheme'] = params['colorScheme'].toString();
    }
    if (params.containsKey('power')) {
      queryParams['power'] = _formatDouble(_toDouble(params['power']));
    }
    if (params.containsKey('juliaX')) {
      queryParams['juliaX'] = _formatDouble(_toDouble(params['juliaX']));
    }
    if (params.containsKey('juliaY')) {
      queryParams['juliaY'] = _formatDouble(_toDouble(params['juliaY']));
    }

    return Uri(
      scheme: scheme,
      host: host,
      queryParameters: queryParams,
    );
  }

  /// Builds a web-compatible URL for sharing.
  ///
  /// Uses a hypothetical web domain for universal link support.
  static Uri buildWebUri({
    required String moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
  }) {
    final customUri = buildUri(moduleId: moduleId, params: params, view: view);
    return Uri(
      scheme: 'https',
      host: 'fractalforge.app',
      path: '/view',
      queryParameters: customUri.queryParameters,
    );
  }

  static double? _parseBoundedDouble(
      String? v, double min, double max, String paramName) {
    if (v == null) return null;
    final d = double.tryParse(v);
    if (d == null || d.isNaN || d.isInfinite) {
      if (kDebugMode) debugPrint(
          'DeepLink: invalid value for "$paramName": "$v" — ignoring');
      return null;
    }
    final clamped = d.clamp(min, max);
    if (clamped != d) {
      if (kDebugMode) debugPrint(
          'DeepLink: "$paramName" value $d out of [$min, $max] — clamped to $clamped');
    }
    return clamped;
  }

  static int? _parseBoundedInt(
      String? v, int min, int max, String paramName) {
    if (v == null) return null;
    final i = int.tryParse(v);
    if (i == null) {
      if (kDebugMode) debugPrint(
          'DeepLink: invalid value for "$paramName": "$v" — ignoring');
      return null;
    }
    final clamped = i.clamp(min, max);
    if (clamped != i) {
      if (kDebugMode) debugPrint(
          'DeepLink: "$paramName" value $i out of [$min, $max] — clamped to $clamped');
    }
    return clamped;
  }

  static String _formatDouble(double value) {
    // Remove trailing zeros for cleaner URLs
    final formatted = value.toStringAsFixed(6);
    return formatted.replaceAll(RegExp(r'\.?0+$'), '');
  }

  static double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Disposes of the service and closes the stream.
  void dispose() {
    _linkController.close();
  }
}
