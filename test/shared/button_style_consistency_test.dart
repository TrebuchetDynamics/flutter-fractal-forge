import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the shared button geometry used by the viewer and its modal sheets.
///
/// Material 3 defaults give filled and tonal buttons a stadium (pill) outline,
/// which reads as a different control family from the app's 12 px rounded
/// rectangles. The theme must keep every variant on one geometry, while filled
/// and tonal keep different fills.
void main() {
  final themes = <String, ThemeData Function()>{
    'dark': () => AppTheme.dark,
    'high contrast': () => AppTheme.highContrast,
    'oled': () => AppTheme.oled,
  };

  double relativeLuminance(Color color) {
    double channel(double value) => value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  double contrastRatio(Color a, Color b) {
    final la = relativeLuminance(a);
    final lb = relativeLuminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  BorderRadiusGeometry? radiusOf(ButtonStyle? style) {
    final shape = style?.shape?.resolve(<WidgetState>{});
    if (shape is! RoundedRectangleBorder) return null;
    return shape.borderRadius;
  }

  for (final entry in themes.entries) {
    final name = entry.key;

    group('$name theme button geometry', () {
      test('every button variant shares the app radius', () {
        final theme = entry.value();
        final expected = BorderRadius.circular(AppSpacing.buttonRadius);
        expect(radiusOf(theme.filledButtonTheme.style), expected,
            reason: 'FilledButton must not fall back to a stadium outline');
        expect(radiusOf(theme.textButtonTheme.style), expected);
        expect(radiusOf(theme.elevatedButtonTheme.style), expected);
        expect(radiusOf(theme.outlinedButtonTheme.style), expected);
      });

      test('filled and tonal fills stay distinguishable', () {
        final scheme = entry.value().colorScheme;
        expect(scheme.primary, isNot(scheme.secondaryContainer),
            reason: 'a shared filled theme must not flatten tonal buttons');
      });

      test('tonal label keeps AA contrast on its container', () {
        final scheme = entry.value().colorScheme;
        final ratio = contrastRatio(
            scheme.onSecondaryContainer, scheme.secondaryContainer);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'FilledButton.tonal label contrast is $ratio:1');
      });
    });
  }

  testWidgets('dialog actions keep 48dp targets and the shared radius',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const cancelKey = ValueKey('dialogCancelAction');
    const confirmKey = ValueKey('dialogConfirmAction');
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: AppDialog(
            icon: Icons.edit_rounded,
            title: 'Rename preset',
            content: const TextField(),
            actions: [
              TextButton(
                key: cancelKey,
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: confirmKey,
                onPressed: () {},
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    for (final key in [cancelKey, confirmKey]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget),
          reason: '$key height is ${size.height}');
    }

    final surface = tester.widget<Material>(find
        .descendant(of: find.byKey(confirmKey), matching: find.byType(Material))
        .first);
    expect(surface.shape, isA<RoundedRectangleBorder>());
    expect((surface.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(AppSpacing.buttonRadius));
  });

  for (final entry in themes.entries) {
    testWidgets('${entry.key} dialog actions stay one row at 2x text',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: entry.value(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: AppDialog(
              icon: Icons.edit_rounded,
              title: 'Rename preset',
              content: const TextField(),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Cancel')),
                FilledButton(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final cancel = tester.getRect(find.widgetWithText(TextButton, 'Cancel'));
      final save = tester.getRect(find.widgetWithText(FilledButton, 'Save'));
      expect(
          cancel.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
      expect(
          save.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
      expect(save.overlaps(cancel), isFalse,
          reason: 'action buttons must not overlap at 2x text');
    });
  }
}
