import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

// The diagnostic widgets below use hardcoded English strings intentionally.
// They are developer-only diagnostic screens activated via
// --dart-define=SAFE_MODE=N or --dart-define=BOOT_STEP=N and are never shown
// to end users in normal builds. AppLocalizations is unavailable at this point
// because MaterialApp (and its localization delegates) has not yet been
// configured.

class UltraSafeApp extends StatelessWidget {
  const UltraSafeApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'ULTRA SAFE MODE\nIf this screen shows, the crash is NOT from shaders/providers.\n\nReport: "ultra safe mode opens".',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SafeScaffoldApp extends StatelessWidget {
  const SafeScaffoldApp();

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

class Step1ThemeOnlyApp extends StatelessWidget {
  const Step1ThemeOnlyApp();

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

class Step2MinimalProviderApp extends StatelessWidget {
  const Step2MinimalProviderApp();

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

class Step3DeepLinkInitApp extends StatelessWidget {
  final DeepLinkService deepLinkService;

  const Step3DeepLinkInitApp({required this.deepLinkService});

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
