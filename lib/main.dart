// Flutter Fractal Forge - A real-time fractal rendering application.
//
// This application provides an interactive experience for exploring
// mathematical fractals with GPU-accelerated shaders.
//
// Features:
// - Multiple fractal types (Mandelbrot, Julia, Mandelbulb, etc.)
// - Real-time parameter adjustment
// - 2D and 3D fractal rendering
// - Export to PNG with transparency support
//
// Architecture:
// - Core: Models, modules, services, and theming
// - Features: Screen-level components (catalog, viewer, etc.)
// - Shared: Cross-cutting utilities
//
// State management is handled via Provider with FractalController
// as the primary state holder for rendering.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_fractals/app/diagnostic_apps.dart';
import 'package:flutter_fractals/app/startup.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';

export 'package:flutter_fractals/app/flutter_fractals_app.dart';

const int kSafeMode = int.fromEnvironment('SAFE_MODE', defaultValue: 0);
const int kBootStep = int.fromEnvironment('BOOT_STEP', defaultValue: 0);

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

    if (kSafeMode >= 2) {
      runApp(const UltraSafeApp());
      return;
    }

    // SAFE_MODE=1: run a minimal Scaffold + AppBar, but skip all services/modules.
    // This isolates black-screen issues caused by app initialization.
    if (kSafeMode == 1) {
      runApp(const SafeScaffoldApp());
      return;
    }

    // BOOT_STEP=1: Apply AppTheme + basic MaterialApp only (no services/providers).
    if (kBootStep == 1) {
      runApp(const Step1ThemeOnlyApp());
      return;
    }

    // BOOT_STEP=2: MaterialApp + AppTheme + minimal providers/services.
    if (kBootStep == 2) {
      runApp(const Step2MinimalProviderApp());
      return;
    }

    // BOOT_STEP=3: Initialize DeepLinkService only.
    if (kBootStep == 3) {
      final deepLinkService = DeepLinkService();
      await deepLinkService.initialize();
      runApp(Step3DeepLinkInitApp(deepLinkService: deepLinkService));
      return;
    }

    // Launch UI immediately to prevent Android from killing the process
    // for taking too long to attach (process start timeout ~10-12s).
    // Services are initialized asynchronously after the first frame.
    runApp(const DeferredStartupApp());
  }, (Object error, StackTrace stack) {
    CrashReporter.instance.record(
      error,
      stack,
      source: 'zone',
      fatal: true,
    );
  });
}
