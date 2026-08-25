import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('standard sheet respects Android gesture navigation inset',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    tester.view.devicePixelRatio = 1;
    tester.view.systemGestureInsets = const FakeViewPadding(bottom: 48);
    addTearDown(() async {
      tester.view.reset();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AppBottomSheet(
                    children: [
                      SizedBox(height: 120),
                      SizedBox(
                        key: ValueKey('lastSheetAction'),
                        height: 40,
                      ),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final screenBottom = tester.getRect(find.byType(Scaffold)).bottom;
    final actionBottom =
        tester.getRect(find.byKey(const ValueKey('lastSheetAction'))).bottom;
    expect(actionBottom, lessThanOrEqualTo(screenBottom - 48));
  });

  testWidgets('standard modal bottom sheet renders exactly one drag handle',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AppBottomSheet(
                    children: [SizedBox(height: 120)],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(
      AppTheme.dark.bottomSheetTheme.showDragHandle,
      isFalse,
      reason: 'AppBottomSheet owns the single visible drag handle',
    );
  });
}
