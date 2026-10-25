import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_codec.dart';

export 'deep_link_codec.dart' show DeepLinkData;

/// Service for handling deep links with the `fractalforge://` scheme.
///
/// Supports URLs like:
/// - `fractalforge://view?type=mandelbrot&zoom=10&x=-0.5&y=0.1`
/// - `fractalforge://view?type=julia&juliaX=-0.7&juliaY=0.27&colorScheme=2`
/// - `fractalforge://view?type=mandelbulb&rotX=0.5&rotY=0.3&power=8`
///
/// {@category Services}
class DeepLinkService {
  // Capture before Flutter announces its initial '/' route to the browser.
  static Uri? _initialBrowserUri;
  static Uri get initialBrowserUri => _initialBrowserUri ?? Uri.base;
  static void captureInitialBrowserUri() => _initialBrowserUri = Uri.base;

  static const String scheme = DeepLinkCodec.scheme;
  static const String host = DeepLinkCodec.host;

  // Method channel for receiving deep links from native code
  static const MethodChannel _channel =
      MethodChannel('com.fractalforge/deeplink');
  static DeepLinkService? _handlerOwner;

  final StreamController<DeepLinkData> _linkController =
      StreamController<DeepLinkData>.broadcast();

  /// Stream of parsed deep link data.
  Stream<DeepLinkData> get linkStream => _linkController.stream;

  DeepLinkData? _initialLink;
  bool _disposed = false;

  /// The initial deep link that launched the app (if any).
  DeepLinkData? get initialLink => _initialLink;

  /// Initializes the deep link service.
  ///
  /// Sets up listeners for incoming deep links from the platform.
  Future<void> initialize() async {
    const bool kEnableDeepLinks =
        bool.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: true);
    if (_disposed || !kEnableDeepLinks) {
      return;
    }

    // Set up method channel handler for incoming links
    _handlerOwner = this;
    _channel.setMethodCallHandler(_handleMethodCall);

    // Try to get the initial link that launched the app
    try {
      final Object? initialUri = await _channel.invokeMethod('getInitialLink');
      final data = parseIncomingLink(initialUri);
      if (data != null) {
        _initialLink = data;
      }
    } catch (_) {
      // Platform doesn't support deep links or no initial link.
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (_disposed || call.method != 'onDeepLink') return;
    final data = parseIncomingLink(call.arguments);
    if (data != null && !_linkController.isClosed) {
      _linkController.add(data);
    }
  }

  /// Parses a platform-provided deep-link payload into [DeepLinkData].
  ///
  /// Native channels are expected to send URI strings, but malformed payloads
  /// are ignored instead of crashing the method-channel handler.
  static DeepLinkData? parseIncomingLink(
    Object? link, {
    List<String>? validFractalTypes,
  }) =>
      DeepLinkCodec.parseIncomingLink(
        link,
        validFractalTypes: validFractalTypes,
      );

  /// Parses the address of this web app, including localhost/preview hosts.
  /// Native/universal-link inputs still go through the strict host allowlist.
  static DeepLinkData? parseBrowserUri(Uri uri) =>
      DeepLinkCodec.parseBrowserUri(uri);

  /// Parses a URI into [DeepLinkData].
  ///
  /// Returns null if the URI is not a valid fractalforge deep link or
  /// if the fractal type is not recognized.
  static DeepLinkData? parseUri(Uri uri, {List<String>? validFractalTypes}) =>
      DeepLinkCodec.parseUri(
        uri,
        validFractalTypes: validFractalTypes,
      );

  /// Builds a shareable deep link URL from the current fractal state.
  ///
  /// The [moduleId] specifies the fractal type, [params] contains the
  /// fractal parameters, and [view] contains the camera/view state.
  static Uri buildUri({
    required String moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
    bool transparentBackground = false,
    bool rotationLocked = false,
    bool glowEnabled = false,
    double glowSigma = 1.0,
    double glowIntensity = 0.35,
    bool fluidModeEnabled = false,
    double fluidStrength = 1.0,
    bool kaleidoscopeEnabled = false,
    int kaleidoscopeSectors = 8,
    bool kaleidoscopeMirror = true,
    double kaleidoscopeRotation = 0.0,
    int kaleidoscopeMirrorMode = 0,
    bool includeDefaults = false,
    bool includeReadableParams = true,
  }) =>
      DeepLinkCodec.buildUri(
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
        includeDefaults: includeDefaults,
        includeReadableParams: includeReadableParams,
      );

  /// Builds a web-compatible URL for sharing.
  ///
  /// Uses the verified web domain for universal link support.
  /// With [readable], parameter names and typed JSON scalar values replace the
  /// compact payload, so address-bar links can be inspected and edited.
  static Uri buildWebUri({
    required String moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
    bool transparentBackground = false,
    bool rotationLocked = false,
    bool glowEnabled = false,
    double glowSigma = 1.0,
    double glowIntensity = 0.35,
    bool fluidModeEnabled = false,
    double fluidStrength = 1.0,
    bool kaleidoscopeEnabled = false,
    int kaleidoscopeSectors = 8,
    bool kaleidoscopeMirror = true,
    double kaleidoscopeRotation = 0.0,
    int kaleidoscopeMirrorMode = 0,
    bool includeDefaults = false,
    bool readable = false,
  }) =>
      DeepLinkCodec.buildWebUri(
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
        includeDefaults: includeDefaults,
        readable: readable,
      );

  /// Disposes of the service and closes the stream.
  void dispose() {
    _disposed = true;
    if (identical(_handlerOwner, this)) {
      _handlerOwner = null;
      _channel.setMethodCallHandler(null);
    }
    if (!_linkController.isClosed) {
      _linkController.close();
    }
  }
}
