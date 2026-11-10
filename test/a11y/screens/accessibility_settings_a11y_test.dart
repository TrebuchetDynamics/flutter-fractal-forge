import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/settings/accessibility_settings_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/a11y_test_helpers.dart';
import '../semantics/interactive_name_audit.dart' show semanticsRoot;

void main() {
  group('AccessibilitySettingsScreen accessibility', () {
    late AccessibilityService accessibilityService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      accessibilityService = await AccessibilityService.create();
    });

    Widget buildApp({String language = 'en', bool systemStatus = false}) {
      return ChangeNotifierProvider<AccessibilityService>.value(
        value: accessibilityService,
        child: MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: systemStatus,
              highContrast: systemStatus,
              accessibleNavigation: systemStatus,
            ),
            child: child!,
          ),
          home: const AccessibilitySettingsScreen(),
        ),
      );
    }

    testWidgets('status messages occur once in the rendered semantics tree',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final handle = tester.ensureSemantics();
      try {
        for (final language in ['en', 'es']) {
          final l10n = lookupAppLocalizations(Locale(language));
          final messages = [
            l10n.accessibilityScreenReaderActive,
            language == 'en'
                ? 'Reduced motion is enabled at system level'
                : 'El movimiento reducido está activado en el sistema',
            language == 'en'
                ? 'High contrast is enabled at system level'
                : 'El alto contraste está activado en el sistema',
          ];
          for (final enabled in [false, true]) {
            await accessibilityService.setHighContrast(enabled);
            await accessibilityService.setReducedMotion(enabled);
            await accessibilityService.setLargeTargets(enabled);
            await tester
                .pumpWidget(buildApp(language: language, systemStatus: true));
            await pumpAccessibilityTestFrames(tester);
            final nodes = <SemanticsNode>[];
            void visit(SemanticsNode node) {
              nodes.add(node);
              node.visitChildren((child) {
                visit(child);
                return true;
              });
            }

            visit(semanticsRoot(tester));
            for (final message in messages) {
              final occurrences = nodes.fold<int>(
                0,
                (count, node) =>
                    count +
                    message.allMatches(node.getSemanticsData().label).length,
              );
              expect(occurrences, 1,
                  reason:
                      '$language all system flags=true app=$enabled: $message');
              expect(find.textContaining(message), findsOneWidget);
            }
            for (final name in [
              l10n.accessibilityHighContrast,
              l10n.accessibilityReducedMotion,
              l10n.accessibilityLargeTargets,
            ]) {
              final controls = nodes
                  .where((node) => node.getSemanticsData().label == name)
                  .toList();
              expect(controls, hasLength(1));
              final data = controls.single.getSemanticsData();
              expect(data.hasAction(SemanticsAction.tap), isTrue);
              expect(data.flagsCollection.isToggled,
                  enabled ? Tristate.isTrue : Tristate.isFalse);
            }
          }
        }
      } finally {
        handle.dispose();
        await disposeAccessibilityTestWidget(tester);
      }
    });

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });
  });
}
