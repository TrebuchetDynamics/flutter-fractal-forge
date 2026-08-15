import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long-pressing random FAB opens polished action sheet',
      (tester) async {
    await _pumpHarness(tester);

    await tester
        .longPress(find.byKey(const ValueKey('viewerRandomFractalFab')));
    await tester.pumpAndSettle();

    expect(find.text('Random options'), findsOneWidget);
    expect(
      find.text(
          'Jump to a new fractal or keep this one and reshape its parameters.'),
      findsOneWidget,
    );
    expect(find.text('Switch to another catalog entry.'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets('overflow secondary actions announce and support Shift+Enter',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpHarness(tester);
    await _openMoreActions(tester);

    final randomTile = find.byKey(const ValueKey('viewerRandomButton'));
    final semantics = tester.getSemantics(randomTile);
    expect(semantics.hint, contains('Shift+Enter'));

    for (var presses = 0;
        presses < 10 &&
            !Focus.of(tester.element(find.text('Random Fractal'))).hasFocus;
        presses++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(
      Focus.of(tester.element(find.text('Random Fractal'))).hasFocus,
      isTrue,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();

    expect(find.text('Random options'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('long-pressing export FAB opens polished export sheet',
      (tester) async {
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerExportButton')));
    await tester.pumpAndSettle();

    expect(find.text('Export / Wallpaper'), findsOneWidget);
    expect(
      find.text('Save, share, or fit the current render to your device.'),
      findsOneWidget,
    );
    expect(find.text('Set this view as your home or lock screen wallpaper.'),
        findsOneWidget);
  });

  // The wallpaper tile used to be described as "Preview crops for phone
  // wallpaper sizes." There is no preview anywhere in the flow: the tile opens
  // WallpaperOptionsSheet and applying from there hands the capture straight to
  // the platform. The old copy was asserted by this very file, which is part of
  // why it survived.
  testWidgets('the wallpaper tile does not promise a preview', (tester) async {
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerExportButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Preview'), findsNothing);
  });

  testWidgets('the wallpaper tile localizes and promises no preview in Spanish',
      (tester) async {
    await _pumpHarness(tester, locale: const Locale('es'));

    await tester.longPress(find.byKey(const ValueKey('viewerExportButton')));
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Establece esta vista como fondo de la pantalla de inicio o de bloqueo.'),
      findsOneWidget,
    );
    expect(find.textContaining('Previsualiza'), findsNothing);
    expect(find.textContaining('Preview'), findsNothing);
  });

  testWidgets('desktop export sheet omits unsupported wallpaper actions',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerExportButton')));
    await tester.pumpAndSettle();

    expect(find.text('Export'), findsNWidgets(2));
    expect(find.text('Save or share the current render.'), findsOneWidget);
    expect(find.text('Wallpaper'), findsNothing);
    expect(find.text('Set this view as your home or lock screen wallpaper.'),
        findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('long-pressing kaleidoscope FAB opens section picker',
      (tester) async {
    int? selectedSectors;

    await _pumpHarness(
      tester,
      onSetSectors: (value) => selectedSectors = value,
    );

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();

    expect(find.text('Kaleidoscope sections'), findsOneWidget);
    expect(find.text('Wedge count'), findsOneWidget);
    expect(
      find.text('Reflect each wedge for sharper radial symmetry.'),
      findsOneWidget,
    );

    await tester.tap(find.text('12'));
    await tester.pump();

    expect(selectedSectors, 12);
  });

  testWidgets('kaleidoscope sheet offers every reachable sector count',
      (tester) async {
    // FractalController.setKaleidoscopeSectors clamps to 4..16 and snaps odd
    // inputs down, so these are exactly the values the app can hold. A missing
    // chip is a state the sheet can neither show as selected nor restore.
    const reachable = [4, 6, 8, 10, 12, 14, 16];

    for (final sectors in reachable) {
      int? selectedSectors;
      await _pumpHarness(
        tester,
        sectors: sectors,
        onSetSectors: (value) => selectedSectors = value,
      );

      await tester
          .longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
      await tester.pumpAndSettle();

      final chip = find.widgetWithText(ChoiceChip, '$sectors');
      expect(chip, findsOneWidget, reason: 'no chip for $sectors sectors');
      expect(
        tester.widget<ChoiceChip>(chip).selected,
        isTrue,
        reason: '$sectors sectors opened with nothing selected',
      );

      await tester.tap(chip);
      await tester.pump();
      expect(selectedSectors, sectors);

      // Close before the next iteration: pumpWidget reuses the Navigator
      // element, so a left-open sheet would survive into the next case.
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('phone wedge choices use a balanced four plus three grid',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 731));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();

    final rects = <Rect>[
      for (final sectors in const [4, 6, 8, 10, 12, 14, 16])
        tester.getRect(find.widgetWithText(ChoiceChip, '$sectors')),
    ];
    final rows = <double, int>{};
    for (final rect in rects) {
      rows.update(rect.top, (count) => count + 1, ifAbsent: () => 1);
      expect(rect.height, greaterThanOrEqualTo(48));
    }

    expect(rows.values.toList(), [4, 3]);
  });

  testWidgets('mirror toggle exposes its label and state on one node',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();

    // Only nodes the platform actually surfaces — a node merged into an
    // ancestor is not reported to TalkBack/VoiceOver separately.
    final toggles = <SemanticsNode>[];
    void collect(SemanticsNode node) {
      if (!node.isMergedIntoParent &&
          node.getSemanticsData().flagsCollection.isToggled != Tristate.none) {
        toggles.add(node);
      }
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    // Semantics live on this pipeline owner; rootPipelineOwner.semanticsOwner
    // is null in a widget test. Matches test/a11y/semantics/.
    // ignore: deprecated_member_use
    collect(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

    expect(toggles, hasLength(1),
        reason: 'switch and row announced separately');
    expect(toggles.single.getSemanticsData().label, contains('Mirror wedges'));
    expect(
      toggles.single.getSemanticsData().flagsCollection.isToggled,
      Tristate.isTrue,
      reason: 'mirror is on but the node does not say so',
    );

    handle.dispose();
  });

  testWidgets('single-action FABs open no sheet on long press', (tester) async {
    // These three toggle or open something directly; a sheet whose only tile
    // repeats that action just costs a second tap.
    for (final key in const [
      'viewerLooperFab',
      'viewerFractalMusicFab',
      'viewerShareImageButton',
      'viewerFullscreenButton',
    ]) {
      await _pumpHarness(tester);
      await tester.longPress(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing, reason: key);
      expect(find.byTooltip('Close'), findsNothing, reason: key);
    }
  });

  testWidgets('FAB without a secondary action ignores long press',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: FloatingActionButtonWidget(
            key: ValueKey('bareFab'),
            icon: Icons.fullscreen_exit_rounded,
            tooltip: 'Exit fullscreen',
            onPressed: _noop,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.longPress(find.byKey(const ValueKey('bareFab')));
    await tester.pumpAndSettle();

    // No sheet whose only content restates the tap action the user just held.
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('long-press sheet copy localizes to Spanish', (tester) async {
    await _pumpHarness(tester, locale: const Locale('es'));

    await tester
        .longPress(find.byKey(const ValueKey('viewerRandomFractalFab')));
    await tester.pumpAndSettle();

    expect(find.text('Opciones aleatorias'), findsOneWidget);
    expect(
      find.text(
          'Salta a otro fractal o quédate en este y transforma sus parámetros.'),
      findsOneWidget,
    );
    expect(find.text('Cambia a otra entrada del catálogo.'), findsOneWidget);
    // The English source strings must be gone, not merely accompanied.
    expect(find.text('Random options'), findsNothing);
    expect(find.text('Switch to another catalog entry.'), findsNothing);

    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();

    expect(find.text('Secciones del kaleidoscopio'), findsOneWidget);
    expect(find.text('Número de sectores'), findsOneWidget);
    expect(find.text('Reflejar sectores'), findsOneWidget);
    expect(find.text('Kaleidoscope sections'), findsNothing);
    expect(find.text('Wedge count'), findsNothing);
  });
}

void _noop() {}

Future<void> _openMoreActions(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('viewerMoreActionsButton')));
  await tester.pumpAndSettle();
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  ValueChanged<int>? onSetSectors,
  Locale locale = const Locale('en'),
  int sectors = 8,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: _Harness(
          onSetSectors: onSetSectors ?? (_) {},
          sectors: sectors,
        ),
      ),
    ),
  );
  await tester.pump();
}

class _Harness extends StatefulWidget {
  final ValueChanged<int> onSetSectors;
  final int sectors;

  const _Harness({required this.onSetSectors, required this.sectors});

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController = AnimationController(
    vsync: this,
    value: 1,
  );

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractalViewControls(
      fabController: _fabController,
      isExporting: false,
      kaleidoscopeEnabled: false,
      kaleidoscopeSectors: widget.sectors,
      kaleidoscopeMirror: true,
      fractalMusicEnabled: false,
      fourierEnabled: false,
      textOverlayEnabled: false,
      actions: FractalViewControlActions(
        toggleFullscreen: () {},
        openRandomFractal: () {},
        openControls: () {},
        randomizeParams: () {},
        cycleColorScheme: () {},
        openPalettePicker: () {},
        toggleKaleidoscope: () {},
        setKaleidoscopeSectors: widget.onSetSectors,
        setKaleidoscopeMirror: (_) {},
        openExport: () {},
        shareLink: () {},
        shareImage: () {},
        toggleTextOverlay: () {},
        editTextOverlay: () {},
        openLooper: () {},
        toggleFractalMusic: () {},
        toggleFourier: () {},
        openFourierSettings: () {},
        reportFractal: () {},
        openWallpaper: () {},
      ),
    );
  }
}
