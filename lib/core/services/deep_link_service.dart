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

  /// Julia set real constant (c.x) from the public `juliaX` URL alias.
  final double? juliaX;

  /// Julia set imaginary constant (c.y) from the public `juliaY` URL alias.
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
    _DeepLinkJuliaConstantParams.addRuntimeParams(
      params,
      real: juliaX,
      imaginary: juliaY,
    );

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
enum _DeepLinkRouteKind {
  customSchemeView,
  universalLinkView,
  rejected,
}

/// Normalized custom-scheme route shape.
///
/// `fractalforge://view?...` uses `view` as URI authority/host, while
/// `fractalforge:/view?...` and `fractalforge:view?...` are path-only forms.
/// Keep those shapes distinct so a non-view authority cannot smuggle a view
/// route through its path (for example `fractalforge://other/view?...`).
class _DeepLinkCustomRouteShape {
  final String host;
  final String path;

  const _DeepLinkCustomRouteShape({
    required this.host,
    required this.path,
  });

  factory _DeepLinkCustomRouteShape.fromUri(Uri uri) {
    return _DeepLinkCustomRouteShape(host: uri.host, path: uri.path);
  }

  bool get hasAuthority => host.isNotEmpty;

  bool get isViewRoute {
    if (hasAuthority) {
      return host == DeepLinkService.host && (path.isEmpty || path == '/');
    }
    return path == '/${DeepLinkService.host}' || path == DeepLinkService.host;
  }
}

class _DeepLinkRoute {
  static const allowedWebHosts = {'fractalforge.app', 'www.fractalforge.app'};

  final _DeepLinkRouteKind kind;

  const _DeepLinkRoute._(this.kind);

  bool get isAccepted => kind != _DeepLinkRouteKind.rejected;

  factory _DeepLinkRoute.fromUri(Uri uri) {
    if (uri.scheme == DeepLinkService.scheme) {
      return _DeepLinkRoute._(
        _isCustomViewRoute(uri)
            ? _DeepLinkRouteKind.customSchemeView
            : _DeepLinkRouteKind.rejected,
      );
    }

    if (uri.scheme == 'https' && allowedWebHosts.contains(uri.host)) {
      return _DeepLinkRoute._(
        _isWebViewRoute(uri)
            ? _DeepLinkRouteKind.universalLinkView
            : _DeepLinkRouteKind.rejected,
      );
    }

    return const _DeepLinkRoute._(_DeepLinkRouteKind.rejected);
  }

  static bool _isCustomViewRoute(Uri uri) {
    return _DeepLinkCustomRouteShape.fromUri(uri).isViewRoute;
  }

  static bool _isWebViewRoute(Uri uri) {
    return uri.path == '/${DeepLinkService.host}';
  }
}

class _DeepLinkModuleId {
  static final RegExp _safePattern = RegExp(r'^[a-z0-9_]+$');

  const _DeepLinkModuleId._();

  static bool isSafe(String moduleId) => _safePattern.hasMatch(moduleId);

  static String requireSafeForBuild(String moduleId) {
    if (!isSafe(moduleId)) {
      throw ArgumentError.value(
        moduleId,
        'moduleId',
        'Deep-link module IDs must match ${_safePattern.pattern}',
      );
    }
    return moduleId;
  }
}

class _DeepLinkQuery {
  static final recognizedNames = {
    'type',
    for (final param in DeepLinkService._allQueryParams) param.name,
  };

  final Map<String, String> _params;

  const _DeepLinkQuery._(this._params);

  factory _DeepLinkQuery.fromUri(Uri uri) {
    final duplicatedRecognizedKeys = uri.queryParametersAll.entries.where(
      (entry) => recognizedNames.contains(entry.key) && entry.value.length > 1,
    );
    if (duplicatedRecognizedKeys.isNotEmpty) {
      throw FormatException(
        'Duplicate deep-link query parameter: '
        '${duplicatedRecognizedKeys.first.key}',
      );
    }

    return _DeepLinkQuery._(uri.queryParameters);
  }

  String? operator [](String name) => _params[name];
}

abstract interface class _DeepLinkQueryParamContract {
  String get name;
}

class _BoundedDoubleQueryParam implements _DeepLinkQueryParamContract {
  @override
  final String name;
  final double min;
  final double max;

  const _BoundedDoubleQueryParam(this.name, this.min, this.max);

  double? parse(_DeepLinkQuery query) {
    return DeepLinkService._parseBoundedDouble(query[name], min, max, name);
  }

  String? format(
    Object? value, {
    bool preservePrecision = false,
    double compactTolerance = 0.0,
  }) {
    final parsed = DeepLinkService._tryFiniteDouble(value);
    if (parsed == null || !_contains(parsed)) {
      return null;
    }
    return DeepLinkService._formatDouble(
      parsed,
      preservePrecision: preservePrecision,
      compactTolerance: compactTolerance,
    );
  }

  bool _contains(double value) => value >= min && value <= max;
}

class _BoundedIntQueryParam implements _DeepLinkQueryParamContract {
  @override
  final String name;
  final int min;
  final int max;

  const _BoundedIntQueryParam(this.name, this.min, this.max);

  int? parse(_DeepLinkQuery query) {
    return DeepLinkService._parseBoundedInt(query[name], min, max, name);
  }

  String? format(Object? value) {
    final parsed = _DeepLinkIntegerValue.tryParse(value);
    if (parsed == null || !_contains(parsed)) {
      return null;
    }
    return parsed.toString();
  }

  bool _contains(int value) => value >= min && value <= max;
}

class _DeepLinkIntegerValue {
  static const double _maxSafeIntegerDouble = 9007199254740991.0;

  const _DeepLinkIntegerValue._();

  /// Mirrors runtime module int-param readers for generated links: persisted
  /// parameter maps may carry slider-originated doubles, but generated URLs
  /// must contain replayable integer query values.
  static int? tryParse(Object? value) {
    return switch (value) {
      int v => v,
      double v when _isSafeIntegerDouble(v) => v.round(),
      _ => null,
    };
  }

  static bool _isSafeIntegerDouble(double value) {
    return value.isFinite && value.abs() <= _maxSafeIntegerDouble;
  }
}

/// Mapping between public deep-link Julia aliases and runtime module params.
///
/// Share URLs use compact, stable query names (`juliaX`/`juliaY`), while
/// render modules expose controls as `juliaCReal`/`juliaCImag`. Keeping the
/// mapping explicit prevents generated links and applied deep links from
/// silently dropping Julia constants.
class _DeepLinkJuliaConstantParams {
  static const String urlReal = 'juliaX';
  static const String urlImaginary = 'juliaY';
  static const String runtimeReal = 'juliaCReal';
  static const String runtimeImaginary = 'juliaCImag';

  const _DeepLinkJuliaConstantParams._();

  static void addRuntimeParams(
    Map<String, Object> params, {
    required double? real,
    required double? imaginary,
  }) {
    if (real != null) params[runtimeReal] = real;
    if (imaginary != null) params[runtimeImaginary] = imaginary;
  }

  /// Generated links should prefer actual runtime parameter names but still
  /// accept already URL-shaped maps for compatibility with existing callers.
  static Object? realValueForBuild(Map<String, Object> params) {
    return params[runtimeReal] ?? params[urlReal];
  }

  static Object? imaginaryValueForBuild(Map<String, Object> params) {
    return params[runtimeImaginary] ?? params[urlImaginary];
  }
}

class DeepLinkService {
  static const String scheme = 'fractalforge';
  static const String host = 'view';

  static const _zoomParam = _BoundedDoubleQueryParam('zoom', 0.001, 1e15);
  static const _xParam = _BoundedDoubleQueryParam('x', -1e10, 1e10);
  static const _yParam = _BoundedDoubleQueryParam('y', -1e10, 1e10);
  static const _rotXParam = _BoundedDoubleQueryParam('rotX', -1e10, 1e10);
  static const _rotYParam = _BoundedDoubleQueryParam('rotY', -1e10, 1e10);
  static const _rotZParam = _BoundedDoubleQueryParam('rotZ', -1e10, 1e10);
  static const _iterationsParam = _BoundedIntQueryParam('iterations', 1, 10000);
  static const _bailoutParam = _BoundedDoubleQueryParam('bailout', 1.0, 1e10);
  static const _colorSchemeParam =
      _BoundedIntQueryParam('colorScheme', 0, 9999);
  static const _powerParam = _BoundedDoubleQueryParam('power', 1, 20);
  static const _juliaXParam = _BoundedDoubleQueryParam(
    _DeepLinkJuliaConstantParams.urlReal,
    -1e10,
    1e10,
  );
  static const _juliaYParam = _BoundedDoubleQueryParam(
    _DeepLinkJuliaConstantParams.urlImaginary,
    -1e10,
    1e10,
  );

  /// Keeps common Vector3 float32 artifacts (for example `0.3` becoming
  /// `0.3000000119`) from leaking into share URLs while still preserving
  /// rotation values where six-decimal formatting would visibly change input.
  static const double _rotationCompactTolerance = 5e-8;

  static const List<_DeepLinkQueryParamContract> _allQueryParams = [
    _zoomParam,
    _xParam,
    _yParam,
    _rotXParam,
    _rotYParam,
    _rotZParam,
    _iterationsParam,
    _bailoutParam,
    _colorSchemeParam,
    _powerParam,
    _juliaXParam,
    _juliaYParam,
  ];

  // Method channel for receiving deep links from native code
  static const MethodChannel _channel =
      MethodChannel('com.fractalforge/deeplink');

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
    const bool kEnableDeepLinks =
        bool.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: false);
    if (!kEnableDeepLinks) {
      return;
    }

    // Set up method channel handler for incoming links
    _channel.setMethodCallHandler(_handleMethodCall);

    // Try to get the initial link that launched the app
    try {
      final Object? initialUri = await _channel.invokeMethod('getInitialLink');
      final data = parseIncomingLink(initialUri);
      if (data != null) {
        _initialLink = data;
      }
    } on PlatformException {
      // Platform doesn't support deep links or no initial link
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onDeepLink') {
      final data = parseIncomingLink(call.arguments);
      if (data != null) {
        _linkController.add(data);
      }
    }
  }

  /// Parses a platform-provided deep-link payload into [DeepLinkData].
  ///
  /// Native channels are expected to send URI strings, but malformed payloads
  /// are ignored instead of crashing the method-channel handler.
  static DeepLinkData? parseIncomingLink(
    Object? link, {
    List<String>? validFractalTypes,
  }) {
    if (link is! String || link.isEmpty) {
      return null;
    }

    try {
      return parseUri(
        Uri.parse(link),
        validFractalTypes: validFractalTypes,
      );
    } catch (e) {
      // Malformed URI, ignore.
      if (kDebugMode) debugPrint('Failed to parse deep link URI: $e');
      return null;
    }
  }

  /// Parses a URI into [DeepLinkData].
  ///
  /// Returns null if the URI is not a valid fractalforge deep link or
  /// if the fractal type is not recognized.
  static DeepLinkData? parseUri(Uri uri, {List<String>? validFractalTypes}) {
    final route = _DeepLinkRoute.fromUri(uri);
    if (!route.isAccepted) {
      return null;
    }

    final _DeepLinkQuery query;
    try {
      query = _DeepLinkQuery.fromUri(uri);
    } on FormatException catch (e) {
      if (kDebugMode) debugPrint('DeepLink: ${e.message} — rejecting link');
      return null;
    }

    final type = query['type'];

    if (type == null || type.isEmpty) {
      return null;
    }

    // Reject type strings with unsafe characters (defense-in-depth).
    if (!_DeepLinkModuleId.isSafe(type)) {
      return null;
    }

    // Validate fractal type if validation list provided
    if (validFractalTypes != null && !validFractalTypes.contains(type)) {
      return null;
    }

    return DeepLinkData(
      type: type,
      zoom: _zoomParam.parse(query),
      x: _xParam.parse(query),
      y: _yParam.parse(query),
      rotX: _rotXParam.parse(query),
      rotY: _rotYParam.parse(query),
      rotZ: _rotZParam.parse(query),
      iterations: _iterationsParam.parse(query),
      bailout: _bailoutParam.parse(query),
      colorScheme: _colorSchemeParam.parse(query),
      power: _powerParam.parse(query),
      juliaX: _juliaXParam.parse(query),
      juliaY: _juliaYParam.parse(query),
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
      'type': _DeepLinkModuleId.requireSafeForBuild(moduleId),
    };

    _addViewStateQueryParams(queryParams, view);

    // Add fractal parameters. Unsupported values are omitted rather than
    // converted to sentinel values that parse back as valid-but-wrong params.
    _addBoundedIntQueryParam(
        queryParams, _iterationsParam, params['iterations']);
    _addBoundedDoubleQueryParam(queryParams, _bailoutParam, params['bailout']);
    _addBoundedIntQueryParam(
      queryParams,
      _colorSchemeParam,
      params['colorScheme'],
    );
    _addBoundedDoubleQueryParam(queryParams, _powerParam, params['power']);
    _addBoundedDoubleQueryParam(
      queryParams,
      _juliaXParam,
      _DeepLinkJuliaConstantParams.realValueForBuild(params),
      preservePrecision: true,
    );
    _addBoundedDoubleQueryParam(
      queryParams,
      _juliaYParam,
      _DeepLinkJuliaConstantParams.imaginaryValueForBuild(params),
      preservePrecision: true,
    );

    return Uri(
      scheme: scheme,
      host: host,
      queryParameters: queryParams,
    );
  }

  /// Adds view-state fields to generated links.
  ///
  /// View state is one replay contract: zoom, pan, and 3D rotation values all
  /// need significant digits preserved so shared links restore the same camera
  /// instead of a rounded approximation.
  static void _addViewStateQueryParams(
    Map<String, String> queryParams,
    FractalViewState view,
  ) {
    // Use the same bounded contracts as parsing so generated links do not
    // round-trip through clamped or invalid camera values.
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _zoomParam,
      view.zoom,
      defaultValue: 1.0,
      preservePrecision: true,
    );
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _xParam,
      view.pan.x,
      preservePrecision: true,
    );
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _yParam,
      view.pan.y,
      preservePrecision: true,
    );
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _rotXParam,
      view.rotation.x,
      preservePrecision: true,
      compactTolerance: _rotationCompactTolerance,
    );
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _rotYParam,
      view.rotation.y,
      preservePrecision: true,
      compactTolerance: _rotationCompactTolerance,
    );
    _addNonDefaultBoundedDoubleQueryParam(
      queryParams,
      _rotZParam,
      view.rotation.z,
      preservePrecision: true,
      compactTolerance: _rotationCompactTolerance,
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
      if (kDebugMode)
        debugPrint('DeepLink: invalid value for "$paramName": "$v" — ignoring');
      return null;
    }
    final clamped = d.clamp(min, max);
    if (clamped != d) {
      if (kDebugMode)
        debugPrint(
            'DeepLink: "$paramName" value $d out of [$min, $max] — clamped to $clamped');
    }
    return clamped;
  }

  static int? _parseBoundedInt(String? v, int min, int max, String paramName) {
    if (v == null) return null;
    final i = int.tryParse(v);
    if (i == null) {
      if (kDebugMode)
        debugPrint('DeepLink: invalid value for "$paramName": "$v" — ignoring');
      return null;
    }
    final clamped = i.clamp(min, max);
    if (clamped != i) {
      if (kDebugMode)
        debugPrint(
            'DeepLink: "$paramName" value $i out of [$min, $max] — clamped to $clamped');
    }
    return clamped;
  }

  static String _formatDouble(
    double value, {
    bool preservePrecision = false,
    double compactTolerance = 0.0,
  }) {
    // Keep integer-looking values compact without truncating significant deep-zoom
    // view coordinates that need more than six decimal places to round-trip.
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    final compactFixed =
        value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    final compactValue = double.tryParse(compactFixed);
    final compactWithinTolerance = compactValue != null &&
        compactTolerance > 0.0 &&
        (compactValue - value).abs() <= compactTolerance;
    if (!preservePrecision || compactValue == value || compactWithinTolerance) {
      return compactFixed;
    }

    return value.toString();
  }

  static void _addBoundedDoubleQueryParam(
    Map<String, String> queryParams,
    _BoundedDoubleQueryParam param,
    Object? value, {
    bool preservePrecision = false,
    double compactTolerance = 0.0,
  }) {
    final formatted = param.format(
      value,
      preservePrecision: preservePrecision,
      compactTolerance: compactTolerance,
    );
    if (formatted != null) {
      queryParams[param.name] = formatted;
    }
  }

  static void _addNonDefaultBoundedDoubleQueryParam(
    Map<String, String> queryParams,
    _BoundedDoubleQueryParam param,
    Object? value, {
    double defaultValue = 0.0,
    bool preservePrecision = false,
    double compactTolerance = 0.0,
  }) {
    final parsed = _tryFiniteDouble(value);
    if (parsed == null || parsed == defaultValue) return;
    _addBoundedDoubleQueryParam(
      queryParams,
      param,
      parsed,
      preservePrecision: preservePrecision,
      compactTolerance: compactTolerance,
    );
  }

  static void _addBoundedIntQueryParam(
    Map<String, String> queryParams,
    _BoundedIntQueryParam param,
    Object? value,
  ) {
    final formatted = param.format(value);
    if (formatted != null) {
      queryParams[param.name] = formatted;
    }
  }

  static double? _tryFiniteDouble(Object? value) {
    final parsed = switch (value) {
      double v => v,
      int v => v.toDouble(),
      String v => double.tryParse(v),
      _ => null,
    };
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return null;
    }
    return parsed;
  }

  /// Disposes of the service and closes the stream.
  void dispose() {
    _linkController.close();
  }
}
