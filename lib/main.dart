// Flutter Fractal Forge - A real-time fractal rendering application.
//
// This application provides an interactive experience for exploring
// mathematical fractals with GPU-accelerated shaders.
//
// Features:
// - Multiple fractal types (Mandelbrot, Julia, Mandelbulb, etc.)
// - Real-time parameter adjustment
// - 2D and 3D fractal rendering
// - AR camera overlay mode
// - Export to PNG with transparency support
//
// Architecture:
// - Core: Models, modules, services, and theming
// - Features: Screen-level components (catalog, viewer, AR, etc.)
// - Shared: Cross-cutting utilities
//
// State management is handled via Provider with FractalController
// as the primary state holder for rendering.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
// FractalController is provided per tab (Explore vs AR).

const int kSafeMode = int.fromEnvironment('SAFE_MODE', defaultValue: 0);
const int kBootStep = int.fromEnvironment('BOOT_STEP', defaultValue: 0);

/// Deep links can be noisy/flaky on emulators and in automated UI tests.
///
/// Default: disabled.
/// Enable with: --dart-define=ENABLE_DEEP_LINKS=1
const int kEnableDeepLinks =
    int.fromEnvironment('ENABLE_DEEP_LINKS', defaultValue: 0);

/// Application entry point.
///
/// Initializes services, configures error handling, and launches the app.
Future<void> main() async {
  // All Flutter initialization must happen in the same zone as runApp
  // to avoid zone mismatch errors.
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lightweight, local-only crash/error reporting.
    CrashReporter.install();

    // Set immersive status bar styling.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    if (kSafeMode >= 2) {
      runApp(const _UltraSafeApp());
      return;
    }

    // SAFE_MODE=1: run a minimal Scaffold + AppBar, but skip all services/modules.
    // This isolates black-screen issues caused by app initialization.
    if (kSafeMode == 1) {
      runApp(const _SafeScaffoldApp());
      return;
    }

    // BOOT_STEP=1: Apply AppTheme + basic MaterialApp only (no services/providers).
    if (kBootStep == 1) {
      runApp(const _Step1ThemeOnlyApp());
      return;
    }

    // BOOT_STEP=2: MaterialApp + AppTheme + minimal providers/services.
    if (kBootStep == 2) {
      runApp(const _Step2MinimalProviderApp());
      return;
    }

    // BOOT_STEP=3: Initialize DeepLinkService only.
    if (kBootStep == 3) {
      final deepLinkService = DeepLinkService();
      await deepLinkService.initialize();
      runApp(_Step3DeepLinkInitApp(deepLinkService: deepLinkService));
      return;
    }

    // Launch UI immediately to prevent Android from killing the process
    // for taking too long to attach (process start timeout ~10-12s).
    // Services are initialized asynchronously after the first frame.
    runApp(const _DeferredStartupApp());
  }, (Object error, StackTrace stack) {
    CrashReporter.instance.record(
      error,
      stack,
      source: 'zone',
      fatal: true,
    );
  });
}

/// Deferred startup widget that renders a lightweight splash immediately,
/// then initializes services asynchronously and transitions to the full app.
///
/// This prevents Android from killing the process for taking too long to
/// attach (process start timeout ~10-12s on emulators with swiftshader).
class _DeferredStartupApp extends StatefulWidget {
  const _DeferredStartupApp();

  @override
  State<_DeferredStartupApp> createState() => _DeferredStartupAppState();
}

class _DeferredStartupAppState extends State<_DeferredStartupApp> {
  Widget? _fullApp;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final results = await Future.wait([
      PresetStore.create(),
      ArQualityStore.create(),
      HistoryStore.create(),
      AccessibilityService.create(),
      RendererSettingsService.create(),
      PaletteService.create(),
    ]);
    final presetStore = results[0] as PresetStore;
    final arQualityStore = results[1] as ArQualityStore;
    final historyStore = results[2] as HistoryStore;
    final accessibilityService = results[3] as AccessibilityService;
    final rendererSettingsService = results[4] as RendererSettingsService;
    final onboardingService = await OnboardingService.create();
    DeepLinkService? deepLinkService;
    if (kEnableDeepLinks == 1) {
      deepLinkService = DeepLinkService();
      await deepLinkService.initialize();
    }

    if (!mounted) return;
    setState(() {
      _fullApp = FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        historyStore: historyStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        onboardingService: onboardingService,
        deepLinkService: deepLinkService,
        skipSplash: true, // Deferred startup already showed loading UI.
      );
    });
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
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The root widget for Flutter Fractal Forge.
///
/// Sets up providers for app-wide services and configures theming/localization.
///
/// This widget provides:
/// - [ModuleRegistry]: Available fractal modules
/// - [PresetStore]: User preset persistence
/// - [ArQualityStore]: AR quality preference storage
/// - [AccessibilityService]: Accessibility settings management
///
/// Example usage in tests:
/// ```dart
/// await tester.pumpWidget(
///   FlutterFractalsApp(
///     presetStore: mockPresetStore,
///     arQualityStore: mockArQualityStore,
///     accessibilityService: mockAccessibilityService,
///     locale: const Locale('en'),
///   ),
/// );
/// ```
// NOTE: The diagnostic widgets below (_UltraSafeApp, _SafeScaffoldApp,
// _Step1ThemeOnlyApp, _Step2MinimalProviderApp, _Step3DeepLinkInitApp) use
// hardcoded English strings intentionally. They are developer-only diagnostic
// screens activated via --dart-define=SAFE_MODE=N or --dart-define=BOOT_STEP=N
// and are never shown to end users in normal builds. AppLocalizations is
// unavailable at this point because MaterialApp (and its localization
// delegates) has not yet been configured.

class _UltraSafeApp extends StatelessWidget {
  const _UltraSafeApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'ULTRA SAFE MODE\nIf this screen shows, the crash is NOT from shaders/AR/providers.\n\nReport: "ultra safe mode opens".',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SafeScaffoldApp extends StatelessWidget {
  const _SafeScaffoldApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SAFE MODE 1'),
        ),
        body: const Center(
          child: Text(
            'SAFE_MODE=1\nMinimal UI (AppBar + Text).\nNo services/modules initialized.\n\nReport: "safe mode 1 renders".',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Step1ThemeOnlyApp extends StatelessWidget {
  const _Step1ThemeOnlyApp();

  @override
  Widget build(BuildContext context) {
    // Use our app theme, but do NOT initialize any stores/services.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BOOT STEP 1'),
        ),
        body: const Center(
          child: Text(
            'BOOT_STEP=1\nMaterialApp + AppTheme only.\nNo providers/services.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Step2MinimalProviderApp extends StatelessWidget {
  const _Step2MinimalProviderApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Minimal provider wiring (no app services yet).
        Provider<int>.value(value: 42),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BOOT STEP 2'),
          ),
          body: const Center(
            child: Text(
              'BOOT_STEP=2\nAppTheme + Provider<int>(42).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _Step3DeepLinkInitApp extends StatelessWidget {
  final DeepLinkService deepLinkService;

  const _Step3DeepLinkInitApp({required this.deepLinkService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeepLinkService>.value(value: deepLinkService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BOOT STEP 3'),
          ),
          body: const Center(
            child: Text(
              'BOOT_STEP=3\nDeepLinkService initialized.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class FlutterFractalsApp extends StatelessWidget {
  /// Storage service for user-created presets.
  final PresetStore presetStore;

  /// Storage service for AR quality preferences.
  final ArQualityStore arQualityStore;

  /// Storage service for exploration history.
  final HistoryStore? historyStore;

  /// Service for accessibility settings.
  final AccessibilityService accessibilityService;

  /// Service for renderer backend preferences.
  final RendererSettingsService rendererSettingsService;

  /// Service for onboarding state management.
  final OnboardingService? onboardingService;

  /// Service for handling deep links.
  final DeepLinkService? deepLinkService;

  /// Optional locale override for testing.
  ///
  /// When null, the system locale is used.
  final Locale? locale;

  /// When true, skip the animated splash screen (e.g. deferred startup
  /// already showed a loading indicator).
  final bool skipSplash;

  /// Creates the root app widget.
  const FlutterFractalsApp({
    Key? key,
    required this.presetStore,
    required this.arQualityStore,
    this.historyStore,
    required this.accessibilityService,
    required this.rendererSettingsService,
    this.onboardingService,
    this.deepLinkService,
    this.locale,
    this.skipSplash = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppProviders(
      presetStore: presetStore,
      arQualityStore: arQualityStore,
      historyStore: historyStore,
      accessibilityService: accessibilityService,
      rendererSettingsService: rendererSettingsService,
      onboardingService: onboardingService,
      deepLinkService: deepLinkService,
      locale: locale,
      skipSplash: skipSplash,
    );
  }
}

/// Provides app-scoped dependencies and stores.
class _AppProviders extends StatelessWidget {
  final PresetStore presetStore;
  final ArQualityStore arQualityStore;
  final HistoryStore? historyStore;
  final AccessibilityService accessibilityService;
  final RendererSettingsService rendererSettingsService;
  final OnboardingService? onboardingService;
  final DeepLinkService? deepLinkService;
  final Locale? locale;
  final bool skipSplash;

  const _AppProviders({
    required this.presetStore,
    required this.arQualityStore,
    required this.historyStore,
    required this.accessibilityService,
    required this.rendererSettingsService,
    required this.onboardingService,
    required this.deepLinkService,
    required this.locale,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ModuleRegistry>(create: (_) => ModuleRegistry()),
        Provider<PresetStore>.value(value: presetStore),
        Provider<ArQualityStore>.value(value: arQualityStore),
        if (historyStore != null)
          Provider<HistoryStore>.value(value: historyStore!),
        if (historyStore != null)
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(store: historyStore!),
          ),
        ChangeNotifierProvider<AccessibilityService>.value(
          value: accessibilityService,
        ),
        ChangeNotifierProvider<RendererSettingsService>.value(
          value: rendererSettingsService,
        ),
        if (onboardingService != null)
          Provider<OnboardingService>.value(value: onboardingService!),
        if (deepLinkService != null)
          Provider<DeepLinkService>.value(value: deepLinkService!),
      ],
      child: _AppShell(
        locale: locale,
        onboardingService: onboardingService,
        skipSplash: skipSplash,
      ),
    );
  }
}

/// Owns MaterialApp/theme/localization shell.
class _AppShell extends StatelessWidget {
  final Locale? locale;
  final OnboardingService? onboardingService;
  final bool skipSplash;

  const _AppShell({
    required this.locale,
    required this.onboardingService,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityService>(
      builder: (context, accessibility, child) {
        // Use high contrast theme when enabled (in-app or system).
        final mediaHighContrast =
            MediaQuery.maybeOf(context)?.highContrast ?? false;
        final useHighContrast =
            accessibility.highContrastEnabled || mediaHighContrast;
        final theme = useHighContrast ? AppTheme.highContrast : AppTheme.dark;

        return MaterialApp(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme,
          home: _AppBootstrap(
            onboardingService: onboardingService,
            skipSplash: skipSplash,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Handles splash -> onboarding -> home startup flow.
class _AppBootstrap extends StatefulWidget {
  final OnboardingService? onboardingService;
  final bool skipSplash;

  const _AppBootstrap({required this.onboardingService, this.skipSplash = false});

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late bool _showSplash =
      !RuntimeModeService.isAutomatedTest && !widget.skipSplash;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    if (widget.onboardingService != null) {
      _showOnboarding = !widget.onboardingService!.isOnboardingComplete;
    }
  }

  void _onSplashFinished() {
    if (!mounted) return;
    setState(() {
      _showSplash = false;
    });
  }

  void _onOnboardingComplete() {
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return FractalSplashScreen(onFinished: _onSplashFinished);
    }

    if (_showOnboarding && widget.onboardingService != null) {
      return OnboardingScreen(
        onboardingService: widget.onboardingService!,
        onComplete: _onOnboardingComplete,
      );
    }

    return const HomeScreen();
  }
}
