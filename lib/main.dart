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
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
// FractalController is provided per tab (Explore vs AR).

/// Application entry point.
///
/// Initializes services, configures error handling, and launches the app.
Future<void> main() async {
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

  await runZonedGuarded(() async {
    final presetStore = await PresetStore.create();
    final arQualityStore = await ArQualityStore.create();
    runApp(
      FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
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
///
/// Example usage in tests:
/// ```dart
/// await tester.pumpWidget(
///   FlutterFractalsApp(
///     presetStore: mockPresetStore,
///     arQualityStore: mockArQualityStore,
///     locale: const Locale('en'),
///   ),
/// );
/// ```
class FlutterFractalsApp extends StatelessWidget {
  /// Storage service for user-created presets.
  final PresetStore presetStore;

  /// Storage service for AR quality preferences.
  final ArQualityStore arQualityStore;

  /// Optional locale override for testing.
  ///
  /// When null, the system locale is used.
  final Locale? locale;

  /// Creates the root app widget.
  const FlutterFractalsApp({
    Key? key,
    required this.presetStore,
    required this.arQualityStore,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final registry = ModuleRegistry();
    return MultiProvider(
      providers: [
        Provider<ModuleRegistry>.value(value: registry),
        Provider<PresetStore>.value(value: presetStore),
        Provider<ArQualityStore>.value(value: arQualityStore),
      ],
      child: MaterialApp(
        locale: locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
