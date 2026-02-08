import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
// FractalController is provided per tab (Explore vs AR).

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lightweight, local-only crash/error reporting.
  CrashReporter.install();

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

class FlutterFractalsApp extends StatelessWidget {
  final PresetStore presetStore;
  final ArQualityStore arQualityStore;
  final Locale? locale;

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
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
