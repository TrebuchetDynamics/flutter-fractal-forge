import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('short tool sheet scrolls its header and final action above IME',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(3),
              viewPadding: const EdgeInsets.only(bottom: 32),
              systemGestureInsets: const EdgeInsets.only(bottom: 48),
              viewInsets: const EdgeInsets.only(bottom: 80)),
          child: child!),
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Builder(
              builder: (context) => TextButton(
                  onPressed: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (_) => AppOptionsSheet(
                          icon: Icons.tune,
                          title: 'Long options title',
                          child: Column(children: [
                            const SizedBox(height: 800),
                            FilledButton(
                                onPressed: () {},
                                child: const Text('Final action'))
                          ]))),
                  child: const Text('Open')))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Final action'));
    await tester.pumpAndSettle();
    expect(find.text('Final action').hitTestable(), findsOneWidget);
    expect(tester.getRect(find.text('Final action')).bottom,
        lessThanOrEqualTo(160));
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
