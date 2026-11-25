import 'package:flutter/material.dart';

import 'package:flutter_fractals/app/flutter_fractals_app.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Deep links are enabled by default so shared web URLs can open the app.
/// Disable for diagnostics with: --dart-define=ENABLE_DEEP_LINKS=0
const int kEnableDeepLinks =
    int.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: 1);

class DeferredStartupApp extends StatefulWidget {
  final Future<Widget> Function()? fullAppLoader;
  final Duration startupTimeout;

  const DeferredStartupApp({
    this.fullAppLoader,
    this.startupTimeout = const Duration(seconds: 30),
  });

  @override
  State<DeferredStartupApp> createState() => DeferredStartupAppState();
}

class DeferredStartupAppState extends State<DeferredStartupApp> {
  Widget? _fullApp;
  Object? _startupError;
  DeepLinkService? _deepLinkService;
  Future<_StartupServices>? _pendingStartup;
  _StartupServices? _startupServices;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<Widget?> _createFullApp() async {
    // Register before startup yields to the stores. Keep already received
    // links if the user has to retry loading the app.
    if (kEnableDeepLinks == 1) {
      _deepLinkService ??= DeepLinkService();
    }
    final linksReady = _deepLinkService?.initialize();
    final pending = _pendingStartup = _StartupServices.create();
    final services = await pending;
    // Timeout or unmount can invalidate this attempt before its stores finish.
    if (!identical(_pendingStartup, pending)) {
      services.dispose();
      return null;
    }
    _pendingStartup = null;
    _startupServices = services;
    await linksReady;
    if (!identical(_startupServices, services)) return null;
    return services.buildApp(_deepLinkService);
  }

  Future<void> _initServices() async {
    setState(() {
      _startupError = null;
    });

    try {
      final loader = widget.fullAppLoader ?? _createFullApp;
      final fullApp = await loader().timeout(widget.startupTimeout);
      if (!mounted) return;
      setState(() {
        _fullApp = fullApp;
      });
    } catch (error, stack) {
      _disposeStartupServices();
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'flutter_fractals startup',
        context: ErrorDescription('while initializing startup services'),
      ));
      if (!mounted) return;
      setState(() {
        _startupError = error;
      });
    }
  }

  void _disposeStartupServices() {
    _pendingStartup = null;
    _startupServices?.dispose();
    _startupServices = null;
  }

  @override
  void dispose() {
    _deepLinkService?.dispose();
    _disposeStartupServices();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fullApp != null) return _fullApp!;

    // Minimal static splash — no animations, no CustomPaint.
    // Just enough to satisfy Android's process attach requirement.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: Scaffold(
        body: Center(
          child: _startupError == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Startup failed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The app could not finish loading. Try again, or launch with SAFE_MODE=1 for diagnostics.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _initServices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _StartupServices {
  final PresetStore presetStore;
  final HistoryStore historyStore;
  final AccessibilityService accessibilityService;
  final RendererSettingsService rendererSettingsService;
  final ViewerSessionStore viewerSessionStore;
  final PaletteService paletteService;

  const _StartupServices({
    required this.presetStore,
    required this.historyStore,
    required this.accessibilityService,
    required this.rendererSettingsService,
    required this.viewerSessionStore,
    required this.paletteService,
  });

  static Future<_StartupServices> create() async {
    final results = await Future.wait([
      PresetStore.create(),
      HistoryStore.create(),
      AccessibilityService.create(),
      RendererSettingsService.create(),
      PaletteService.create(),
      ViewerSessionStore.create(),
    ]);

    return _StartupServices(
      presetStore: results[0] as PresetStore,
      historyStore: results[1] as HistoryStore,
      accessibilityService: results[2] as AccessibilityService,
      rendererSettingsService: results[3] as RendererSettingsService,
      paletteService: results[4] as PaletteService,
      viewerSessionStore: results[5] as ViewerSessionStore,
    );
  }

  Widget buildApp(DeepLinkService? deepLinkService) {
    return FlutterFractalsApp(
      presetStore: presetStore,
      historyStore: historyStore,
      viewerSessionStore: viewerSessionStore,
      accessibilityService: accessibilityService,
      rendererSettingsService: rendererSettingsService,
      deepLinkService: deepLinkService,
      skipSplash: true, // Deferred startup already showed loading UI.
    );
  }

  void dispose() {
    paletteService.dispose();
    rendererSettingsService.dispose();
    accessibilityService.dispose();
  }
}
