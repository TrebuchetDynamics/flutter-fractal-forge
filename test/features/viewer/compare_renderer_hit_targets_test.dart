import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/rendering/compare_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final large in [false, true]) {
    testWidgets('divider edges own drag, adjacent artwork owns pan ($large)',
        (tester) async {
      final registry = ModuleRegistry();
      final a = FractalController(registry);
      final b = FractalController(registry);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final keyA = GlobalKey();
      final keyB = GlobalKey();
      var divider = .5;
      var active = 0;
      var changes = 0;
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: a,
        child: MaterialApp(
          theme: ThemeData(
              visualDensity: large
                  ? const VisualDensity(horizontal: 4, vertical: 4)
                  : VisualDensity.standard),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: StatefulBuilder(builder: (context, setState) {
            return CompareRenderer(
              keyA: keyA,
              keyB: keyB,
              controllerB: b,
              sliderMode: true,
              divider: divider,
              activePane: active,
              onDividerChanged: (v) => setState(() {
                divider = v;
                changes++;
              }),
              onActivePaneChanged: (v) => setState(() => active = v),
              onOpenControls: () {},
              onOpenPresets: () {},
              onOpenExport: () {},
              freezeFrame: true,
            );
          })),
        ),
      ));
      await tester.pumpAndSettle();
      final handle = find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onHorizontalDragUpdate != null);
      final width = large ? 56.0 : 48.0;
      expect(tester.getSize(handle), Size(width, 64));
      for (final side in [-1, 1]) {
        final rect = tester.getRect(handle);
        final before = divider;
        final panA = a.view.pan.clone();
        final panB = b.view.pan.clone();
        await tester.dragFrom(rect.center + Offset(side * (width / 2 - 1), 0),
            const Offset(60, 0));
        await tester.pumpAndSettle();
        expect(divider, greaterThan(before));
        expect(a.view.pan, panA);
        expect(b.view.pan, panB);
      }
      // Both transparent target halves select their pane at the outer edge.
      var rect = tester.getRect(handle);
      await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
      await tester.pumpAndSettle();
      expect(active, 1);
      await tester.tapAt(Offset(rect.left + 1, rect.center.dy));
      await tester.pumpAndSettle();
      expect(active, 0);

      // Outside the small handle, neither a full-height strip nor an unclipped
      // pane B may steal pane A's input. Repeat on B after selecting it.
      for (final pane in [0, 1]) {
        rect = tester.getRect(handle);
        final adjacent =
            rect.center + Offset((pane == 0 ? -1 : 1) * (width / 2 + 2), 0);
        await tester.tapAt(adjacent);
        await tester.pumpAndSettle();
        expect(active, pane);
        final controller = pane == 0 ? a : b;
        final before = controller.view.pan.clone();
        final dividerBefore = divider;
        final changeCount = changes;
        await tester.dragFrom(adjacent, Offset(pane == 0 ? -60 : 60, 20));
        await tester.pumpAndSettle();
        expect(controller.view.pan, isNot(before));
        expect(divider, dividerBefore);
        expect(changes, changeCount);
      }
      rect = tester.getRect(handle);
      final before = b.view.pan.clone();
      await tester.dragFrom(
          Offset(rect.center.dx + 2, rect.top - 2), const Offset(40, 20));
      await tester.pumpAndSettle();
      expect(b.view.pan, isNot(before));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('divider has localized adjustable semantics and keyboard focus',
      (tester) async {
    final a = FractalController(ModuleRegistry());
    final b = FractalController(ModuleRegistry());
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final semantics = tester.ensureSemantics();
    var divider = .5;
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: a,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: StatefulBuilder(
                builder: (context, setState) => CompareRenderer(
                      keyA: GlobalKey(),
                      keyB: GlobalKey(),
                      controllerB: b,
                      sliderMode: true,
                      divider: divider,
                      activePane: 0,
                      onDividerChanged: (v) => setState(() => divider = v),
                      onActivePaneChanged: (_) {},
                      onOpenControls: () {},
                      onOpenPresets: () {},
                      onOpenExport: () {},
                      freezeFrame: true,
                    ))),
      ),
    ));
    await tester.pumpAndSettle();
    final slider = find.bySemanticsLabel('Divisor de comparación');
    expect(slider, findsOneWidget);
    expect(tester.getSemantics(slider).flagsCollection.isSlider, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(divider, greaterThan(.5));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(divider, closeTo(.5, .0001));
    semantics.dispose();
  });
}
