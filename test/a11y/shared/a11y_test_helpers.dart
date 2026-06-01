import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a bounded number of frames after building an accessibility test widget.
///
/// Several app surfaces intentionally keep animations/tickers active, so
/// [WidgetTester.pumpAndSettle] can time out even after the accessibility tree is
/// ready. This helper waits for the first rendered frames without requiring the
/// app to become completely idle.
Future<void> pumpAccessibilityTestFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> expectMeetsAccessibilityGuideline(
  WidgetTester tester,
  AccessibilityGuideline guideline,
) async {
  final handle = tester.ensureSemantics();
  try {
    await pumpAccessibilityTestFrames(tester);
    await expectLater(tester, meetsGuideline(guideline));
  } finally {
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  }
}

Future<void> disposeAccessibilityTestWidget(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox.shrink());
}
