import 'package:flutter/material.dart';

import 'package:flutter_fractals/app/flutter_fractals_app.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Deep links can be noisy/flaky on emulators and in automated UI tests.
///
/// Default: disabled.
/// Enable with: --dart-define=ENABLE_DEEP_LINKS=1
const int kEnableDeepLinks =
    int.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: 0);

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

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<Widget> _createFullApp() async {
    final results = await Future.wait([
      PresetStore.create(),
      HistoryStore.create(),
      AccessibilityService.create(),
      RendererSettingsService.create(),
      PaletteService.create(),
    ]);
    final presetStore = results[0] as PresetStore;
    final historyStore = results[1] as HistoryStore;
    final accessibilityService = results[2] as AccessibilityService;
    final rendererSettingsService = results[3] as RendererSettingsService;
    final onboardingService = await OnboardingService.create();
    DeepLinkService? deepLinkService;
    if (kEnableDeepLinks == 1) {
      deepLinkService = DeepLinkService();
      await deepLinkService.initialize();
    }

    return FlutterFractalsApp(
      presetStore: presetStore,
      historyStore: historyStore,
      accessibilityService: accessibilityService,
      rendererSettingsService: rendererSettingsService,
      onboardingService: onboardingService,
      deepLinkService: deepLinkService,
      skipSplash: true, // Deferred startup already showed loading UI.
    );
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
