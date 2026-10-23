import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  testWidgets('Tab and Space operate choices and labeled switches',
      (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.wrapScaffold(const FractalControlsSheet(),
        theme: AppTheme.dark));
    await tester.pumpAndSettle();
    final l10n =
        AppLocalizations.of(tester.element(find.byType(FractalControlsSheet)))!;
    for (final target in [
      find.widgetWithText(ChoiceChip, 'Ocean'),
      find.byType(SwitchListTile).at(0),
      find.widgetWithText(ChoiceChip, l10n.kaleidoscopeMirrorDouble),
      find.byType(SwitchListTile).at(1),
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
    expect(harness.controller.params['colorScheme'], 1);
    expect(harness.controller.kaleidoscopeEnabled, isTrue);
    expect(harness.controller.kaleidoscopeMirrorMode, 1);
    expect(harness.controller.glowEnabled, isTrue);
  });

  testWidgets('choice domain and kaleidoscope values stay unchanged',
      (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.wrapScaffold(const FractalControlsSheet(),
        theme: AppTheme.dark));
    await tester.pumpAndSettle();
    final l10n =
        AppLocalizations.of(tester.element(find.byType(FractalControlsSheet)))!;
    final options = harness.controller.module.parameters
        .where((p) => p.type == FractalParamType.enumeration)
        .expand((p) => p.options)
        .map((o) => o.label(l10n))
        .toList();
    expect(
        tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .map((c) => (c.label as Text).data)
            .toList(),
        options);
    for (final chip in find.byType(ChoiceChip).evaluate()) {
      expect(tester.getSize(find.byWidget(chip.widget)).height,
          greaterThanOrEqualTo(48));
    }
    harness.controller.setKaleidoscopeEnabled(true);
    await tester.pumpAndSettle();
    final mirrorLabels = [
      l10n.kaleidoscopeMirrorAlternate,
      l10n.kaleidoscopeMirrorDouble,
      l10n.kaleidoscopeMirrorTriple,
      l10n.kaleidoscopeMirrorNone
    ];
    for (var i = 0; i < mirrorLabels.length; i++) {
      final chip = find.widgetWithText(ChoiceChip, mirrorLabels[i]);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(harness.controller.kaleidoscopeMirrorMode, i);
      expect(tester.widget<ChoiceChip>(chip).selected, isTrue);
    }
    final sectors = tester
        .widgetList<Slider>(find.byType(Slider))
        .singleWhere((s) => s.min == 4 && s.max == 16);
    expect(sectors.divisions, 6);
    for (var value = 4; value <= 16; value += 2) {
      sectors.onChanged!(value.toDouble());
      expect(harness.controller.kaleidoscopeSectors, value);
    }
  });

  testWidgets('keyboard randomize preserves semantic name and medium haptic',
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
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(harness.wrapScaffold(const FractalControlsSheet(),
        theme: AppTheme.dark));
    await tester.pumpAndSettle();
    final before = Map<String, Object>.of(harness.controller.params);
    var reached = false;
    for (var i = 0; i < 100; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final context = FocusManager.instance.primaryFocus?.context;
      if (context != null &&
          find
              .descendant(
                  of: find.byWidget(context.widget),
                  matching: find.text('Randomize'))
              .evaluate()
              .isNotEmpty) {
        reached = true;
        break;
      }
    }
    expect(reached, isTrue);
    expect(find.text('Randomize').hitTestable(), findsOneWidget);
    expect(tester.getSemantics(find.byType(FilledButton)).label,
        'Randomize all fractal parameters');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(harness.controller.params, isNot(equals(before)));
    expect(
        calls.where((c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.mediumImpact'),
        hasLength(1));
    semantics.dispose();
  });

  testWidgets('reset action is reachable and activated with Tab and Enter',
      (tester) async {
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);
    final initial = harness.controller.params['iterations'];
    harness.controller.updateParam('iterations', 500);
    await tester.pumpWidget(
      harness.wrapScaffold(const FractalControlsSheet(), theme: AppTheme.dark),
    );
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
                matching: find.text('Reset Params'),
              )
              .evaluate()
              .isNotEmpty) {
        reached = true;
        break;
      }
    }
    expect(reached, isTrue, reason: 'Tab must reach Reset Params');
    expect(find.text('Reset Params').hitTestable(), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(harness.controller.params['iterations'], initial);
  });

  for (final locale in ['en', 'es']) {
    testWidgets('controls reflow at 320px and 200 percent text ($locale)',
        (tester) async {
      final harness = FractalControllerWidgetHarness();
      addTearDown(harness.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      harness.controller.setKaleidoscopeEnabled(true);
      harness.controller.setGlowEnabled(true);
      await tester.pumpWidget(harness.wrapScaffold(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 900),
            textScaler: TextScaler.linear(2),
          ),
          child: const FractalControlsSheet(),
        ),
        locale: Locale(locale),
        theme: AppTheme.dark,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l10n = AppLocalizations.of(
          tester.element(find.byType(FractalControlsSheet)))!;
      for (final label in [l10n.resetView, l10n.resetParams, l10n.randomize]) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label).hitTestable(), findsOneWidget);
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
