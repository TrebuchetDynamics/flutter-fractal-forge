import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  testWidgets('live HUD keyboard reveals palettes and operates switches',
      (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(
        harness.wrapScaffold(const FractalControlsHud(), theme: AppTheme.dark));
    await tester.pumpAndSettle();
    final palette = harness.controller.module.parameters
        .firstWhere((p) => p.id == 'colorScheme');
    for (final target in [
      find.byType(ChoiceChip).last,
      find.byType(SwitchListTile).at(0),
      find.byType(SwitchListTile).at(1)
    ]) {
      var reached = false;
      for (var i = 0; i < 100; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final context = FocusManager.instance.primaryFocus?.context;
        if (context != null &&
            find
                .ancestor(of: find.byWidget(context.widget), matching: target)
                .evaluate()
                .isNotEmpty) {
          reached = true;
          break;
        }
      }
      expect(reached, isTrue, reason: 'Tab must reach $target');
      expect(target.hitTestable(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
    }
    expect(
        harness.controller.params['colorScheme'], palette.options.last.value);
    expect(harness.controller.kaleidoscopeEnabled, isTrue);
    expect(harness.controller.fluidModeEnabled, isTrue);
    expect(
        calls.where((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.selectionClick'),
        hasLength(3));
  });

  testWidgets('live HUD preserves palette and extra-enum option subsets',
      (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    final extraEnumModule = harness.registry.modules.firstWhere((m) =>
        m.parameters.any((p) =>
            p.type == FractalParamType.enumeration && p.id != 'colorScheme'));
    for (final module in [harness.controller.module, extraEnumModule]) {
      harness.controller.selectModule(module);
      await tester.pumpWidget(harness.wrapScaffold(const FractalControlsHud(),
          theme: AppTheme.dark));
      await tester.pumpAndSettle();
      final l10n =
          AppLocalizations.of(tester.element(find.byType(FractalControlsHud)))!;
      final expected = module.parameters
          .where((p) => p.type == FractalParamType.enumeration)
          .expand((p) => p.options)
          .map((o) => o.label(l10n));
      expect(
          tester
              .widgetList<ChoiceChip>(find.byType(ChoiceChip))
              .map((c) => (c.label as Text).data),
          unorderedEquals(expected));
    }
  });

  testWidgets('live HUD reset is reachable with Tab and Enter', (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    final initial = harness.controller.params['iterations'];
    harness.controller.updateParam('iterations', 500);
    await tester.pumpWidget(harness.wrapScaffold(
      const FractalControlsHud(),
      theme: AppTheme.dark,
    ));
    await tester.pumpAndSettle();
    var reached = false;
    for (var i = 0; i < 100; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final context = FocusManager.instance.primaryFocus?.context;
      if (context != null &&
          find
              .descendant(
                  of: find.byWidget(context.widget),
                  matching: find.text('Reset parameters'))
              .evaluate()
              .isNotEmpty) {
        reached = true;
        break;
      }
    }
    expect(reached, isTrue,
        reason: 'Tab must reach the live Reset Params action');
    expect(find.text('Reset parameters').hitTestable(), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(harness.controller.params['iterations'], initial);
  });

  for (final locale in ['en', 'es']) {
    for (final scale in [2.0, 3.0]) {
      testWidgets(
          'Ahem live HUD keeps 48px actions at 320px/${scale}x ($locale)',
          (tester) async {
        final harness = FractalControllerWidgetHarness();
        addTearDown(harness.dispose);
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(harness.wrapScaffold(
          MediaQuery(
            data: MediaQueryData(
                size: const Size(320, 568),
                textScaler: TextScaler.linear(scale)),
            child: const FractalControlsHud(),
          ),
          locale: Locale(locale),
          theme: AppTheme.dark,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations.of(
            tester.element(find.byType(FractalControlsHud)))!;
        // Check the actual hit-test region, not an outer semantics wrapper.
        final paletteLabel = find.text(harness.controller.module.parameters
            .firstWhere((p) => p.id == 'colorScheme')
            .options
            .first
            .label(l10n));
        final targets = find.ancestor(
            of: paletteLabel,
            matching: find.byWidgetPredicate(
                (widget) => widget is GestureDetector || widget is RawChip));
        expect(targets, findsWidgets);
        expect(tester.getSize(targets.first).height, greaterThanOrEqualTo(48));
        for (final label in [
          l10n.hudResetViewLabel,
          l10n.hudResetParamsLabel,
          l10n.randomize
        ]) {
          await tester.ensureVisible(find.text(label));
          await tester.pumpAndSettle();
          expect(find.text(label).hitTestable(), findsOneWidget);
          expect(tester.widget<Text>(find.text(label)).maxLines, isNull,
              reason: 'Actions must wrap rather than hide their names');
          final rect = tester.getRect(find.text(label));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(320));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
