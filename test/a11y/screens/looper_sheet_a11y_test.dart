import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/features/looper/looper_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/overflow_guard.dart';
import '../semantics/interactive_name_audit.dart';
import '../shared/a11y_test_helpers.dart';

void main() {
  group('LooperSheet accessibility', () {
    late ModuleRegistry registry;
    late FractalController fractal;
    late LooperController looper;

    setUp(() {
      registry = ModuleRegistry();
      fractal = FractalController(registry);
      looper = LooperController(controller: fractal);
    });

    tearDown(() {
      looper.dispose();
      fractal.dispose();
    });

    Future<void> pumpSheet(
      WidgetTester tester, {
      double textScale = 1.0,
      Size? size,
      Locale locale = const Locale('en'),
      int points = 0,
    }) async {
      if (size != null) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
      }
      for (var i = 0; i < points; i++) {
        looper.addPointFromCurrent();
      }
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: fractal),
          Provider<ModuleRegistry>.value(value: registry),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: LooperSheet(
              controller: looper,
              isExporting: false,
              onExportGif: () {},
            ),
          ),
        ),
      ));
      await pumpAccessibilityTestFrames(tester);
    }

    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSheet(tester, points: 4);
      final root = semanticsRoot(tester);

      expect(operableControlNames(root), contains('Set A'),
          reason: 'the sheet never rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      expect(findUnnamedSliders(root), isEmpty);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('guides the camera keyframe workflow', (tester) async {
      await pumpSheet(tester);
      expect(
        find.text('Move to a starting view, then set A.'),
        findsOneWidget,
      );

      looper.setAFromCurrent();
      await tester.pump();
      expect(
        find.text('Move to the next view, then set B.'),
        findsOneWidget,
      );

      looper.setBFromCurrent();
      await tester.pump();
      expect(
        find.text('2 keyframes ready. Preview the loop or export it.'),
        findsOneWidget,
      );
    });

    // The slider carried only its value, so it announced "6s" and never said
    // what the six seconds were. findUnnamedSliders does not catch this: the
    // value string counts as a label, so the check has to name the label.
    testWidgets('GIF remains the looper export format', (tester) async {
      await pumpSheet(tester, points: 2);

      expect(find.text('Export GIF'), findsOneWidget);
      expect(find.textContaining('MP4'), findsNothing);
    });

    testWidgets('the duration slider says what it adjusts', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSheet(tester);

      final names = operableControlNames(semanticsRoot(tester));
      expect(names.where((n) => n.contains('Duration')), isNotEmpty,
          reason: 'the duration slider announces its value but not its name');

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // Each keyframe chip carries a delete affordance. Unnamed they all announce
    // the bare word "Delete", so a screen reader hears the same name once per
    // keyframe with no way to tell which one it is about to remove.
    testWidgets('each keyframe delete names its keyframe', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSheet(tester, points: 4);

      final names = operableControlNames(semanticsRoot(tester));
      final deletes = names.where((n) => n.startsWith('Remove ')).toList();
      expect(deletes.length, greaterThanOrEqualTo(2));
      expect(deletes.toSet().length, deletes.length,
          reason: 'two delete actions announce the same name: $deletes');
      expect(names, isNot(contains('Delete')));

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // The Duration row was a Text, a Spacer and a second Text with nothing
    // bounding either side, so it ran off the right edge from a 1.3x text scale
    // upward: 31px at 1.3x on a 360-wide screen, 547px at 3.0x on a 320-wide
    // one. Point count does not affect it, but it is varied here because the
    // chip Wrap above only exists once keyframes are set.
    for (final points in const [0, 4]) {
      for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
        for (final size in const [
          Size(360, 640),
          Size(320, 568),
          Size(640, 360),
        ]) {
          testWidgets('no overflow with $points points at ${scale}x on $size',
              (tester) async {
            await expectNoOverflow(
              () => pumpSheet(tester,
                  textScale: scale, size: size, points: points),
              reason: '$points points at ${scale}x on $size',
            );
            await disposeAccessibilityTestWidget(tester);
          });
        }
      }
    }

    testWidgets('meets tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSheet(tester, points: 4);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // Contrast is asserted only where the sheet's content fits its viewport.
    //
    // On a 640x360 landscape screen the content scrolls, and for a scrolled
    // child textContrastGuideline reads the semantics rect as if it were global
    // when it is local to the scrollable. Measured on Export GIF there: the
    // guideline samples y 212-239 and reports 3.86, while the button actually
    // paints at y 313-361 — sampling the guideline's rect directly returns 8208
    // pixels of a single colour, #12121C, the sheet background. The number
    // describes no rendered pixel of that button, so asserting on it would lock
    // in an artifact.
    for (final size in const [Size(360, 640), Size(320, 568)]) {
      testWidgets('meets contrast guideline on $size', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSheet(tester, size: size, points: 4);

        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
        await disposeAccessibilityTestWidget(tester);
      });
    }

    testWidgets('its copy localizes', (tester) async {
      await pumpSheet(tester, locale: const Locale('es'), points: 4);

      expect(find.text('Bucle de cámara'), findsOneWidget);
      expect(find.text('Fijar A'), findsOneWidget);
      expect(find.text('Duración'), findsOneWidget);
      expect(find.text('Exportar GIF'), findsOneWidget);
      expect(find.text('Previsualizar'), findsOneWidget);
      expect(find.text('Actualizar C'), findsOneWidget);
      expect(
        find.text(
          '4 fotogramas clave listos. Previsualiza el bucle o expórtalo.',
        ),
        findsOneWidget,
      );

      for (final english in const [
        'Camera looper',
        'Set A',
        'Duration',
        'Export GIF',
        'Preview',
        'Update C',
      ]) {
        expect(find.text(english), findsNothing, reason: english);
      }
    });
  });
}
