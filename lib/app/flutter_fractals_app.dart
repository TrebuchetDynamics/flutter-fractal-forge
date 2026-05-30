import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/home/home_screen.dart';
import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// The root widget for Flutter Fractal Forge.
///
/// Sets up providers for app-wide services and configures theming/localization.
///
/// This widget provides:
/// - [ModuleRegistry]: Available fractal modules
/// - [PresetStore]: User preset persistence
/// - [AccessibilityService]: Accessibility settings management
///
/// Example usage in tests:
/// ```dart
/// await tester.pumpWidget(
///   FlutterFractalsApp(
///     presetStore: mockPresetStore,
///     accessibilityService: mockAccessibilityService,
///     locale: const Locale('en'),
///   ),
/// );
/// ```
class FlutterFractalsApp extends StatelessWidget {
  /// Storage service for user-created presets.
  final PresetStore presetStore;

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
  final HistoryStore? historyStore;
  final AccessibilityService accessibilityService;
  final RendererSettingsService rendererSettingsService;
  final OnboardingService? onboardingService;
  final DeepLinkService? deepLinkService;
  final Locale? locale;
  final bool skipSplash;

  const _AppProviders({
    required this.presetStore,
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
        // Determine which theme to use based on user selection
        final theme = switch (accessibility.themeMode) {
          AppThemeMode.dark => AppTheme.dark,
          AppThemeMode.oled => AppTheme.oled,
          AppThemeMode.highContrast => AppTheme.highContrast,
        };

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

  const _AppBootstrap(
      {required this.onboardingService, this.skipSplash = false});

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
