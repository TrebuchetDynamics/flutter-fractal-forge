import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/overflow_guard.dart';
import '../semantics/interactive_name_audit.dart';
import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';

/// Pumps past the app's entrance animations without requiring full idle —
/// several surfaces keep tickers running, so pumpAndSettle can time out.
Future<void> _settleChrome(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('HomeScreen accessibility', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });

    /// The three guidelines above run through the shared helper, which stops
    /// pumping at 100ms. That is sound only while nothing here enters later
    /// than that. The viewer's FAB column staggers to 490ms, and its unnamed
    /// nodes survived a labelled-tap-target test for exactly this reason: the
    /// guideline ran against a tree the buttons had not joined yet.
    ///
    /// If a delayed-entrance widget is ever added to this screen, this test
    /// diverges and says so, instead of the three above quietly measuring less.
    testWidgets('the shared 100ms helper sees the whole tree', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness.buildApp());

      await pumpAccessibilityTestFrames(tester);
      final early = operableControlNames(semanticsRoot(tester)).length;
      await _settleChrome(tester);
      final settled = operableControlNames(semanticsRoot(tester)).length;

      expect(
        early,
        settled,
        reason: 'controls appear after 100ms, so the guideline tests on this '
            'screen are measuring an incomplete tree',
      );

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness.buildApp());
      await _settleChrome(tester);

      final root = semanticsRoot(tester);
      expect(operableControlNames(root), isNotEmpty,
          reason: 'nothing rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // test/layout sweeps 375/428/768 at up to 2.0x. These narrower widths and
    // 3.0x are where the HUD and every sheet broke, and were never covered here.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await expectNoOverflow(
            () async {
              await tester.pumpWidget(
                MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: harness.buildApp(),
                ),
              );
              await _settleChrome(tester);
            },
            reason: '$scale x on $size',
          );
        });
      }
    }
  });
}
