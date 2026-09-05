import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/app_version.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/settings/settings_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/overflow_guard.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  double textScale = 1.0,
  Locale locale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues({});
  final accessibility = await AccessibilityService.create();

  await tester.pumpWidget(
    ChangeNotifierProvider<AccessibilityService>.value(
      value: accessibility,
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen accessibility', () {
    testWidgets('text meets the AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpScreen(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('every control meets the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpScreen(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every control is named', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpScreen(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await expectNoOverflow(
            () => _pumpScreen(tester, textScale: scale),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('the theme selector sheet is readable', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpScreen(tester);
      await tester.tap(find.text('Color Scheme').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.text('Color Theme'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('the about dialog is readable', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpScreen(tester);
      await tester.tap(find.text('About').hitTestable().first);
      await tester.pumpAndSettle();
      // The blurb explicitly overrode to textMuted at 3.70:1, which the
      // typography default fix could not reach.
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('the about dialog fits at large text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await expectNoOverflow(
        () async {
          await _pumpScreen(tester, textScale: 3);
          await tester.scrollUntilVisible(find.text('About'), 200);
          await tester.pumpAndSettle();
          await tester.tap(find.text('About').hitTestable().first);
          await tester.pumpAndSettle();
        },
        reason: 'About dialog at 3x text scale',
      );
    });
  });

  group('SettingsScreen content', () {
    testWidgets('shows the real app version, not a stale literal',
        (tester) async {
      await _pumpScreen(tester);
      // Both the tile subtitle and the dialog carried their own copy; the tile
      // was 14 builds behind pubspec.
      expect(find.text('Version $kAppVersion'), findsOneWidget);

      await tester.tap(find.text('About').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.text('Version $kAppVersion'), findsWidgets);
      expect(find.textContaining('1018 production fractals'), findsOneWidget);
      expect(find.text('Source code'), findsOneWidget);
      expect(find.text('View Fractal Forge on GitHub ↗'), findsOneWidget);
    });

    testWidgets('does not expose an unfinished language selector',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Language'), findsNothing);
      expect(find.text('English / Español'), findsNothing);
    });

    testWidgets('opens the canonical public source repository', (tester) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      String? launchedUrl;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async {
          launchedUrl =
              (call.arguments as Map<Object?, Object?>)['url'] as String;
          return true;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      await _pumpScreen(tester);
      await tester.tap(find.text('About').hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Source code'));
      await tester.pumpAndSettle();

      expect(
        launchedUrl,
        'https://github.com/TrebuchetDynamics/flutter-fractal-forge',
      );
      expect(find.text('Unable to open source code.'), findsNothing);
    });

    testWidgets('reports when the source code link cannot open',
        (tester) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => false,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      await _pumpScreen(tester);
      await tester.tap(find.text('About').hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Source code'));
      await tester.pumpAndSettle();

      expect(find.text('Unable to open source code.'), findsOneWidget);
    });

    testWidgets('labels localize to Spanish', (tester) async {
      await _pumpScreen(tester, locale: const Locale('es'));

      for (final label in const [
        'Accesibilidad',
        'Alto contraste, movimiento reducido, objetivos grandes',
        'Personaliza las paletas de color',
        'Laboratorio de fórmulas',
        'Acerca de',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('Versión $kAppVersion'), findsOneWidget);

      // The English source strings must be gone, not merely accompanied.
      for (final label in const [
        'Formula Lab',
        'Language',
        'About',
        'Customize color palettes',
      ]) {
        expect(find.text(label), findsNothing, reason: label);
      }

      await tester.tap(find.text('Acerca de').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.text('Código fuente'), findsOneWidget);
      expect(find.text('Ver Fractal Forge en GitHub ↗'), findsOneWidget);
      expect(find.text('Source code'), findsNothing);
    });
  });
}
