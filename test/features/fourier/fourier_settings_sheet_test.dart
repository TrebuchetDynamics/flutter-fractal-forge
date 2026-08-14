import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_settings_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings expose finite-analysis controls and lab disclaimer',
      (tester) async {
    var display = FourierDisplayMode.split;
    var resolution = FourierResolution.auto;
    var openedLab = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => FourierSettingsSheet(
              displayMode: display,
              resolution: resolution,
              applyHann: true,
              removeDc: true,
              fourierMusicEnabled: false,
              onDisplayModeChanged: (value) => setState(() => display = value),
              onResolutionChanged: (value) =>
                  setState(() => resolution = value),
              onApplyHannChanged: (_) {},
              onRemoveDcChanged: (_) {},
              onFourierMusicChanged: (_) {},
              onOpenUncertaintyLab: () => openedLab = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fourier view'), findsOneWidget);
    expect(find.text('Spatial frequencies are cycles per viewport, not Hertz.'),
        findsOneWidget);
    expect(find.text('Finite numerical experiment—not a mathematical proof.'),
        findsOneWidget);

    await tester.tap(find.text('Spectrum'));
    await tester.pump();
    expect(display, FourierDisplayMode.spectrum);

    await tester.tap(find.text('256'));
    await tester.pump();
    expect(resolution, FourierResolution.pixels256);

    final openLab = find.text('Open Fractal Uncertainty Lab');
    await tester.ensureVisible(openLab);
    await tester.pump();
    await tester.tap(openLab);
    await tester.pump();
    expect(openedLab, isTrue);
  });
}
