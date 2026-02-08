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
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
// FractalController is provided per tab (Explore vs AR).

const int kSafeMode = int.fromEnvironment('SAFE_MODE', defaultValue: 0);

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

    final presetStore = await PresetStore.create();
    final arQualityStore = await ArQualityStore.create();
    final historyStore = await HistoryStore.create();
    final accessibilityService = await AccessibilityService.create();
    final onboardingService = await OnboardingService.create();
    final deepLinkService = DeepLinkService();
    await deepLinkService.initialize();
    runApp(
      FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        historyStore: historyStore,
        accessibilityService: accessibilityService,
        onboardingService: onboardingService,
        deepLinkService: deepLinkService,
      ),
    );
  }, (Object error, StackTrace stack) {
    CrashReporter.instance.record(
      error,
      stack,
      source: 'zone',
      fatal: true,
    );
  });
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

class FlutterFractalsApp extends StatefulWidget {
  /// Storage service for user-created presets.
  final PresetStore presetStore;

  /// Storage service for AR quality preferences.
  final ArQualityStore arQualityStore;

  /// Storage service for exploration history.
  final HistoryStore? historyStore;

  /// Service for accessibility settings.
  final AccessibilityService accessibilityService;

  /// Service for onboarding state management.
  final OnboardingService? onboardingService;

  /// Service for handling deep links.
  final DeepLinkService? deepLinkService;

  /// Optional locale override for testing.
  ///
  /// When null, the system locale is used.
  final Locale? locale;

  /// Creates the root app widget.
  const FlutterFractalsApp({
    Key? key,
    required this.presetStore,
    required this.arQualityStore,
    this.historyStore,
    required this.accessibilityService,
    this.onboardingService,
    this.deepLinkService,
    this.locale,
  }) : super(key: key);

  @override
  State<FlutterFractalsApp> createState() => _FlutterFractalsAppState();
}

class _FlutterFractalsAppState extends State<FlutterFractalsApp> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Check if onboarding should be shown
    if (widget.onboardingService != null) {
      _showOnboarding = !widget.onboardingService!.isOnboardingComplete;
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final registry = ModuleRegistry();
    return MultiProvider(
      providers: [
        Provider<ModuleRegistry>.value(value: registry),
        Provider<PresetStore>.value(value: widget.presetStore),
        Provider<ArQualityStore>.value(value: widget.arQualityStore),
        if (widget.historyStore != null)
          Provider<HistoryStore>.value(value: widget.historyStore!),
        if (widget.historyStore != null)
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(store: widget.historyStore!),
          ),
        ChangeNotifierProvider<AccessibilityService>.value(
          value: widget.accessibilityService,
        ),
        if (widget.onboardingService != null)
          Provider<OnboardingService>.value(value: widget.onboardingService!),
        if (widget.deepLinkService != null)
          Provider<DeepLinkService>.value(value: widget.deepLinkService!),
      ],
      child: Consumer<AccessibilityService>(
        builder: (context, accessibility, child) {
          // Use high contrast theme when enabled (in-app or system)
          final useHighContrast = accessibility.highContrastEnabled ||
              MediaQuery.of(context).highContrast;
          final theme = useHighContrast ? AppTheme.highContrast : AppTheme.dark;

          return MaterialApp(
            locale: widget.locale,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: theme,
            home: _showOnboarding && widget.onboardingService != null
                ? OnboardingScreen(
                    onboardingService: widget.onboardingService!,
                    onComplete: _onOnboardingComplete,
                  )
                : const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
