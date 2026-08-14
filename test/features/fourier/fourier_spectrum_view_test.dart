import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_spectrum_view.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spectrum semantic measurements localize to Spanish', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final description = describeFourierSpectrum(_features(), l10n: l10n);

    expect(description, contains('potencia de baja frecuencia 60 por ciento'));
    expect(description, contains('entropía espectral 0.54'));
    expect(description, contains('planitud espectral 0.20'));
    expect(description, contains('flujo espectral 0.10'));
  });

  testWidgets('renders spectrum pixels with a stable descriptive summary',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 4, 4),
      Paint()..color = Colors.purple,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(4, 4);
    picture.dispose();
    addTearDown(image.dispose);

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: FourierSpectrumView(
            image: image,
            features: _features(),
          ),
        ),
      );

      expect(find.byType(RawImage), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(
          r'Low-frequency power 60 percent.*diagonal at 45 degrees',
        )),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('retains the last image while reporting an unavailable frame',
      (tester) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(Colors.black, BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(2, 2);
    picture.dispose();
    addTearDown(image.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FourierSpectrumView(
          image: image,
          features: _features(),
          unavailable: true,
        ),
      ),
    );

    expect(find.byType(RawImage), findsOneWidget);
    expect(find.text('Spectrum unavailable for this frame'), findsOneWidget);
  });

  testWidgets('initial unavailable frame is not reported as still loading',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(
        home: FourierSpectrumView(
          image: null,
          features: null,
          unavailable: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Spectrum unavailable for this frame'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Spectrum unavailable for this frame'),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });

  test('weak anisotropy omits a misleading orientation angle', () {
    final description =
        describeFourierSpectrum(_features(orientationStrength: 0.01));
    expect(description, contains('No strong directional axis detected'));
    expect(description, isNot(contains('45 degrees')));
  });
}

FourierSpectrumFeatures _features({double orientationStrength = 0.7}) =>
    FourierSpectrumFeatures(
      radialBandPower: const [0.3, 0.3, 0.1, 0.1, 0.1, 0.05, 0.03, 0.02, 0, 0],
      lowPowerRatio: 0.6,
      midPowerRatio: 0.3,
      highPowerRatio: 0.1,
      centroid: 0.3,
      bandwidth: 0.2,
      rolloff85: 0.6,
      logPowerSlope: -1,
      radialPeakSalience: 0.4,
      entropy: 0.54,
      flatness: 0.2,
      dominantOrientation: 0.7853981633974483,
      orientationStrength: orientationStrength,
      spectralFlux: 0.1,
      captureMean: 0.4,
      captureVariance: 0.2,
      alphaCoverage: 1,
      width: 4,
      height: 4,
      windowApplied: true,
      dcRemoved: true,
    );
