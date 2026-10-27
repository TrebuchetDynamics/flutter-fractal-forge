import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {bool largeTargets = false,
    bool settle = true,
    double textScale = 1}) async {
  SharedPreferences.setMockInitialValues({
    'accessibility_large_targets': largeTargets,
    'accessibility_reduced_motion': true,
  });
  final accessibility = await AccessibilityService.create();
  final controller = FractalController(ModuleRegistry());
  final service = AutoExploreService(controller: controller);
  addTearDown(() {
    service.dispose();
    controller.dispose();
    accessibility.dispose();
  });
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<AccessibilityService>.value(value: accessibility),
      ChangeNotifierProvider<AutoExploreService>.value(value: service),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  ));
  if (settle) await tester.pumpAndSettle();
}

void main() {
  testWidgets('reduced-motion tools are fully visible on their first frame',
      (tester) async {
    await _pump(
        tester,
        AppBottomSheetHeader(
          icon: Icons.tune_rounded,
          title: 'Controls',
          onClose: () {},
        ),
        settle: false);
    final circle = find.byType(AnimatedContainer);
    final before = tester.getRect(circle);
    for (final fade in tester.widgetList<FadeTransition>(find.ancestor(
      of: circle,
      matching: find.byType(FadeTransition),
    ))) {
      expect(fade.opacity.value, 1);
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getRect(circle), before);
  });

  testWidgets('yield indicator stays within the tool at 3x text scale',
      (tester) async {
    await _pump(tester, const AutoExploreButton(), textScale: 3);
    final tool = find.byType(AutoExploreButton);
    final service = tester.element(tool).read<AutoExploreService>();
    service.start();
    service.onUserInteractionStart();
    await tester.pumpAndSettle();
    final bounds = tester.getRect(tool);
    final badge = tester.getRect(find.descendant(
      of: tool,
      matching: find.byType(Positioned),
    ));
    expect(bounds.contains(badge.topLeft), isTrue);
    expect(bounds.contains(badge.bottomRight - const Offset(0.1, 0.1)), isTrue);
    service.stop();
    await tester.pump();
  });

  testWidgets('shared sheet keeps one handle and returns the selected result',
      (tester) async {
    String? result;
    await _pump(tester, Builder(builder: (context) {
      return FilledButton(
        onPressed: () async {
          result = await showAppBottomSheet<String>(
            context: context,
            builder: (sheetContext) => AppOptionsSheet(
              icon: Icons.tune_rounded,
              title: 'Options',
              child: FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop('applied'),
                child: const Text('Apply'),
              ),
            ),
          );
        },
        child: const Text('Open'),
      );
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(SheetDragHandle), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(result, 'applied');
    expect(find.byType(AppOptionsSheet), findsNothing);
  });

  for (final auto in [false, true]) {
    testWidgets('toolbar hover is visible without changing size auto=$auto',
        (tester) async {
      await _pump(
          tester,
          auto
              ? const AutoExploreButton()
              : FloatingActionButtonWidget(
                  icon: Icons.palette_rounded,
                  tooltip: 'Palette',
                  onPressed: () {},
                ));
      final circle = find.byType(AnimatedContainer);
      final before = tester.widget<AnimatedContainer>(circle).decoration;
      final rect = tester.getRect(circle);
      final mouse =
          await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(rect.center);
      await tester.pumpAndSettle();
      expect(
          tester.widget<AnimatedContainer>(circle).decoration, isNot(before));
      expect(tester.getRect(circle), rect);
      await mouse.removePointer();
    });
  }

  for (final large in [false, true]) {
    testWidgets('sheet close matches toolbar geometry large=$large',
        (tester) async {
      var closed = false;
      await _pump(
        tester,
        AppBottomSheetHeader(
          icon: Icons.tune_rounded,
          title: 'Controls',
          onClose: () => closed = true,
        ),
        largeTargets: large,
      );
      final close = find.byTooltip('Close');
      expect(tester.getSize(close), Size.square(large ? 56 : 48));
      expect(
          find.descendant(of: close, matching: find.byType(AnimatedContainer)),
          findsOneWidget);
      await tester.tap(close);
      expect(closed, isTrue);
    });
  }
}
