import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long-pressing random FAB opens polished action sheet',
      (tester) async {
    await _pumpHarness(tester);

    await tester.longPress(find.byKey(const ValueKey('viewerRandomButton')));
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
    expect(
        find.text('Preview crops for phone wallpaper sizes.'), findsOneWidget);
  });

  testWidgets('long-pressing kaleidoscope FAB opens section picker',
      (tester) async {
    int? selectedSectors;

    await _pumpHarness(
      tester,
      onSetSectors: (value) => selectedSectors = value,
    );

    await tester
        .longPress(find.byKey(const ValueKey('viewerKaleidoscopeButton')));
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
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  ValueChanged<int>? onSetSectors,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: _Harness(
          onSetSectors: onSetSectors ?? (_) {},
        ),
      ),
    ),
  );
  await tester.pump();
}

class _Harness extends StatefulWidget {
  final ValueChanged<int> onSetSectors;

  const _Harness({required this.onSetSectors});

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
      kaleidoscopeSectors: 8,
      kaleidoscopeMirror: true,
      fractalMusicEnabled: false,
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
        reportFractal: () {},
        openWallpaper: () {},
      ),
    );
  }
}
