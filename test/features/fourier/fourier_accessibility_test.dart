import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/lab/fractal_uncertainty_lab_screen.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_settings_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fourier settings meet contrast and control guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FourierSettingsSheet(
            displayMode: FourierDisplayMode.split,
            resolution: FourierResolution.auto,
            applyHann: true,
            removeDc: true,
            fourierMusicEnabled: false,
            onDisplayModeChanged: (_) {},
            onResolutionChanged: (_) {},
            onApplyHannChanged: (_) {},
            onRemoveDcChanged: (_) {},
            onFourierMusicChanged: (_) {},
            onOpenUncertaintyLab: () {},
          ),
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('uncertainty lab meets contrast and control guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FractalUncertaintyLabScreen(),
      ),
    );

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });
}
