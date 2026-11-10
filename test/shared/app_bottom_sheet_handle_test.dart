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

  testWidgets('both shells reserve the larger navigation or keyboard inset',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      tester.view.reset();
      await tester.binding.setSurfaceSize(null);
    });

    for (final size in const [Size(360, 640), Size(640, 240)]) {
      for (final metrics in const [
        (navigation: 0.0, gesture: 0.0, keyboard: 0.0, reserved: AppSpacing.xl),
        (navigation: 0.0, gesture: 48.0, keyboard: 0.0, reserved: 48.0),
        (navigation: 32.0, gesture: 0.0, keyboard: 0.0, reserved: 32.0),
        (navigation: 32.0, gesture: 48.0, keyboard: 20.0, reserved: 48.0),
        (navigation: 32.0, gesture: 48.0, keyboard: 80.0, reserved: 80.0),
      ]) {
        for (final draggable in [false, true]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.binding.setSurfaceSize(size);
          tester.view.viewPadding = FakeViewPadding(bottom: metrics.navigation);
          tester.view.systemGestureInsets =
              FakeViewPadding(bottom: metrics.gesture);
          tester.view.viewInsets = FakeViewPadding(bottom: metrics.keyboard);
          ScrollController? suppliedController;
          Widget viewport([ScrollController? controller]) => Flexible(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.zero,
                  children: const [SizedBox(height: 1200)],
                ),
              );

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAppBottomSheet<void>(
                    context: context,
                    constraints: BoxConstraints(maxHeight: size.height - 40),
                    builder: (_) => draggable
                        ? AppDraggableBottomSheet(
                            childrenBuilder: (_, controller) {
                              suppliedController = controller;
                              return [viewport(controller)];
                            },
                          )
                        : AppBottomSheet(children: [viewport()]),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ));
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          final bounds = tester.getRect(find.byType(ListView));
          final reason = '$size, $metrics, draggable: $draggable';
          expect(bounds.bottom, closeTo(size.height - metrics.reserved, 0.01),
              reason: reason);
          expect(bounds.top, greaterThanOrEqualTo(40), reason: reason);
          expect(bounds.height, greaterThan(0), reason: reason);
          if (draggable) {
            expect(suppliedController!.hasClients, isTrue);
            await tester.drag(find.byType(ListView), const Offset(0, -800));
            await tester.pumpAndSettle();
            expect(tester.getSize(find.byType(ListView)).height,
                greaterThan(bounds.height),
                reason: reason);
            await tester.drag(find.byType(ListView), const Offset(0, -200));
            await tester.pumpAndSettle();
            expect(suppliedController!.offset, greaterThan(0), reason: reason);
          }
          expect(tester.takeException(), isNull, reason: reason);
        }
      }
    }
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
