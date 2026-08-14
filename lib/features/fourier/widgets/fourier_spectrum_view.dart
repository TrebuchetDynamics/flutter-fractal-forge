import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FourierSpectrumView extends StatelessWidget {
  const FourierSpectrumView({
    super.key,
    required this.image,
    required this.features,
    this.processing = false,
    this.unavailable = false,
  });

  final ui.Image? image;
  final FourierSpectrumFeatures? features;
  final bool processing;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentImage = image;
    final currentFeatures = features;
    if (currentImage == null || currentFeatures == null) {
      final status = unavailable
          ? (l10n?.fourierFrameUnavailable ??
              'Spectrum unavailable for this frame')
          : (l10n?.fourierUpdatingSpectrum ?? 'Updating spectrum…');
      return Semantics(
        container: true,
        liveRegion: true,
        label: status,
        child: ExcludeSemantics(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!unavailable) const CircularProgressIndicator(),
                if (!unavailable) const SizedBox(height: 12),
                Text(status),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      image: true,
      liveRegion: unavailable,
      label: unavailable
          ? '${l10n?.fourierFrameUnavailableRetained ?? 'Spectrum unavailable for the current frame. Showing the last available result.'} '
              '${describeFourierSpectrum(currentFeatures, l10n: l10n)}'
          : describeFourierSpectrum(currentFeatures, l10n: l10n),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: RawImage(
              key: const ValueKey('fourierSpectrumImage'),
              image: currentImage,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
            ),
          ),
          if (processing)
            const Positioned(
              right: 12,
              top: 12,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (unavailable)
            Align(
              alignment: Alignment.bottomCenter,
              child: _StatusBanner(
                l10n?.fourierFrameUnavailable ??
                    'Spectrum unavailable for this frame',
              ),
            ),
        ],
      ),
    );
  }
}

String describeFourierSpectrum(
  FourierSpectrumFeatures features, {
  AppLocalizations? l10n,
}) {
  final low = (features.lowPowerRatio * 100).round();
  final mid = (features.midPowerRatio * 100).round();
  final high = (features.highPowerRatio * 100).round();
  final degrees = features.dominantOrientation * 180 / math.pi;
  final normalizedDegrees = (degrees % 180 + 180) % 180;
  final direction = _orientationLabel(normalizedDegrees, l10n);
  final orientationDescription = features.orientationStrength < 0.08
      ? '${l10n?.fourierNoStrongDirectionalAxis ?? 'No strong directional axis detected'}.'
      : '${l10n?.fourierDominantVariation ?? 'Dominant Fourier-energy axis'}: '
          '$direction ${l10n?.fourierAt ?? 'at'} '
          '${normalizedDegrees.round()} ${l10n?.fourierDegrees ?? 'degrees'}.';
  return '${l10n?.fourierSpectrumSemantic ?? 'Fourier spectrum'}. '
      '${l10n?.fourierLowPower ?? 'Low-frequency power'} $low '
      '${l10n?.fourierPercent ?? 'percent'}, '
      '${l10n?.fourierMidPower ?? 'mid-frequency power'} $mid '
      '${l10n?.fourierPercent ?? 'percent'}, '
      '${l10n?.fourierHighPower ?? 'high-frequency power'} $high '
      '${l10n?.fourierPercent ?? 'percent'}. '
      '$orientationDescription '
      '${l10n?.fourierEntropy ?? 'Spectral entropy'} '
      '${features.entropy.toStringAsFixed(2)}, '
      '${l10n?.fourierFlatness ?? 'spectral flatness'} '
      '${features.flatness.toStringAsFixed(2)}, '
      '${l10n?.fourierAnisotropy ?? 'anisotropy'} '
      '${features.orientationStrength.toStringAsFixed(2)}, '
      '${l10n?.fourierFlux ?? 'spectral flux'} '
      '${features.spectralFlux.toStringAsFixed(2)}. '
      '${l10n?.fourierViewportAnalysis ?? 'Finite numerical image analysis of the current viewport.'}';
}

String _orientationLabel(double degrees, AppLocalizations? l10n) {
  if (degrees < 22.5 || degrees >= 157.5) {
    return l10n?.fourierOrientationHorizontal ?? 'horizontal';
  }
  if (degrees < 67.5) {
    return l10n?.fourierOrientationDiagonal ?? 'diagonal';
  }
  if (degrees < 112.5) {
    return l10n?.fourierOrientationVertical ?? 'vertical';
  }
  return l10n?.fourierOrientationDiagonal ?? 'diagonal';
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
