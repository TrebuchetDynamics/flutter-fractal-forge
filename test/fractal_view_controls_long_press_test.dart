import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long-pressing kaleidoscope FAB opens section picker',
      (tester) async {
    int? selectedSectors;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: _Harness(
            onSetSectors: (value) => selectedSectors = value,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester
        .longPress(find.byKey(const ValueKey('viewerKaleidoscopeButton')));
    await tester.pumpAndSettle();

    expect(find.text('Kaleidoscope sections'), findsOneWidget);

    await tester.tap(find.text('12'));
    await tester.pump();

    expect(selectedSectors, 12);
  });
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
