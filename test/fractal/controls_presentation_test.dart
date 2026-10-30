import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Ahem's square glyphs make a ten-letter word wider than a 320px phone at
    // 3x, independent of layout. Use the SDK's existing Android fallback font
    // for numerical word-break checks; no app font or text scale is changed.
    final configFile = File('.dart_tool/package_config.json').absolute;
    final packages =
        jsonDecode(configFile.readAsStringSync())['packages'] as List;
    final flutter = packages.singleWhere((entry) => entry['name'] == 'flutter');
    final root = configFile.uri.resolve('${flutter['rootUri']}/');
    final font = File.fromUri(root.resolve(
        '../../bin/cache/artifacts/material_fonts/Roboto-Regular.ttf'));
    final bytes = ByteData.sublistView(await font.readAsBytes());
    await (FontLoader(AppTypography.bodyFont)..addFont(Future.value(bytes)))
        .load();
  });
  for (final language in ['en', 'es']) {
    for (final width in [320.0, 360.0, 390.0]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
            'SDK Roboto reset geometry and callbacks $language ${width}px ${scale}x',
            (tester) async {
          final harness = FractalControllerWidgetHarness();
          addTearDown(harness.dispose);
          await tester.binding.setSurfaceSize(Size(width, 720));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final initialIterations = harness.controller.params['iterations'];
          harness.controller.updateParam('iterations', 420);
          harness.controller.updateZoom(2);
          var closes = 0;
          final semantics = tester.ensureSemantics();
          try {
            await tester.pumpWidget(harness.wrapScaffold(
              MediaQuery(
                data: MediaQueryData(
                    size: Size(width, 720),
                    textScaler: TextScaler.linear(scale)),
                child: FractalControlsHud(onClose: () => closes++),
              ),
              locale: Locale(language),
              theme: AppTheme.highContrast,
            ));
            await tester.pumpAndSettle();
            final l10n = AppLocalizations.of(
                tester.element(find.byType(FractalControlsHud)))!;
            final colors = AppTheme.highContrast.colorScheme;
            for (final label in [
              l10n.hudResetViewLabel,
              l10n.hudResetParamsLabel,
              l10n.randomize
            ]) {
              final textFinder = find.text(label);
              await tester.ensureVisible(textFinder);
              await tester.pumpAndSettle();
              expect(textFinder.hitTestable(), findsOneWidget);
              final text = tester.widget<Text>(textFinder);
              expect(text.maxLines, isNull);
              final paragraph = tester.renderObject<RenderParagraph>(find
                  .descendant(of: textFinder, matching: find.byType(RichText)));
              for (final word in RegExp(r'\S+').allMatches(label)) {
                expect(
                    paragraph
                        .getBoxesForSelection(TextSelection(
                            baseOffset: word.start, extentOffset: word.end))
                        .length,
                    1,
                    reason: 'No mid-word breaks in $label');
              }
              final buttonFinder = find.widgetWithText(FilledButton, label);
              final size = tester.getSize(buttonFinder);
              expect(size.width, greaterThanOrEqualTo(48));
              expect(size.height, greaterThanOrEqualTo(48));
              final rect = tester.getRect(textFinder);
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(width));
              final button = tester.widget<FilledButton>(buttonFinder);
              expect(
                  button.style!.backgroundColor!.resolve({}),
                  label == l10n.randomize
                      ? colors.primary
                      : colors.surfaceContainerHigh,
                  reason: 'Only Randomize uses the primary fill');
            }
            expect(find.byIcon(Icons.home_filled), findsNothing);
            final resetView = find.text(l10n.hudResetViewLabel);
            await tester.ensureVisible(resetView);
            await tester.pumpAndSettle();
            expect(
                tester.getSemantics(resetView).label, l10n.hudResetViewLabel);
            await tester.tap(resetView);
            await tester.pumpAndSettle();
            expect(harness.controller.view.zoom, 1);
            expect(harness.controller.params['iterations'], 420);
            final resetParams = find.text(l10n.hudResetParamsLabel);
            await tester.ensureVisible(resetParams);
            await tester.pumpAndSettle();
            expect(tester.getSemantics(resetParams).label,
                l10n.hudResetParamsLabel);
            await tester.tap(resetParams);
            await tester.pumpAndSettle();
            expect(harness.controller.params['iterations'], initialIterations);
            final close =
                find.widgetWithIcon(AppToolButton, Icons.close_rounded);
            await tester.ensureVisible(close);
            await tester.pumpAndSettle();
            expect(tester.getSize(close), const Size(48, 48));
            await tester.tap(close);
            await tester.pumpAndSettle();
            expect(closes, 1);
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        });
      }
    }
  }
}
