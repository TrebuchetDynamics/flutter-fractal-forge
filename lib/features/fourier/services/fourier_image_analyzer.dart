import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/models/fourier_grid.dart';
import 'package:flutter_fractals/features/fourier/models/fourier_spectrum_features.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_transform_service.dart';

enum RgbaAlphaRepresentation { straight, premultiplied }

final class FourierImageAnalysis {
  FourierImageAnalysis({
    required this.scalarField,
    required this.spectrum,
    required Float64List power,
    required this.features,
    required this.isBlank,
  }) : _power = Float64List.fromList(power);

  final FourierGrid scalarField;
  final FourierGrid spectrum;
  final Float64List _power;
  final FourierSpectrumFeatures features;
  final bool isBlank;

  Float64List get power => Float64List.fromList(_power);
}

/// Deterministic conversion of captured RGBA pixels into a Fourier spectrum.
final class FourierImageAnalyzer {
  FourierImageAnalyzer({FourierTransformService? transformService})
      : _transformService = transformService ?? FourierTransformService();

  final FourierTransformService _transformService;

  FourierImageAnalysis analyze({
    required Uint8List rgba,
    required int width,
    required int height,
    int? maxDimension,
    bool removeDc = true,
    bool applyHann = true,
    RgbaAlphaRepresentation alphaRepresentation =
        RgbaAlphaRepresentation.straight,
    Float64List? previousPower,
  }) {
    if (width <= 0 || height <= 0 || rgba.length != width * height * 4) {
      throw ArgumentError('RGBA dimensions and byte length must match.');
    }
    if (maxDimension != null && maxDimension <= 0) {
      throw ArgumentError.value(
          maxDimension, 'maxDimension', 'Must be positive.');
    }

    final sourceLuminance = Float64List(width * height);
    var coveredPixels = 0;
    for (var index = 0; index < sourceLuminance.length; index++) {
      final offset = index * 4;
      final alpha = rgba[offset + 3] / 255;
      if (alpha == 0) {
        sourceLuminance[index] = 0;
        continue;
      }
      coveredPixels++;
      var red = rgba[offset] / 255;
      var green = rgba[offset + 1] / 255;
      var blue = rgba[offset + 2] / 255;
      if (alphaRepresentation == RgbaAlphaRepresentation.premultiplied) {
        red = math.min(1, red / alpha);
        green = math.min(1, green / alpha);
        blue = math.min(1, blue / alpha);
      }
      sourceLuminance[index] = alpha *
          (0.2126 * _srgbToLinear(red) +
              0.7152 * _srgbToLinear(green) +
              0.0722 * _srgbToLinear(blue));
    }

    final sampled = _areaDownsample(
      sourceLuminance,
      width: width,
      height: height,
      maxDimension: maxDimension,
    );
    final luminance = sampled.values;
    final mean =
        luminance.reduce((left, right) => left + right) / luminance.length;
    var variance = 0.0;
    for (final value in luminance) {
      final difference = value - mean;
      variance += difference * difference;
    }
    variance /= luminance.length;

    final processed = Float64List.fromList(luminance);
    if (removeDc) {
      for (var index = 0; index < processed.length; index++) {
        processed[index] -= mean;
      }
    }
    if (applyHann) {
      for (var y = 0; y < sampled.height; y++) {
        final windowY = _hann(y, sampled.height);
        for (var x = 0; x < sampled.width; x++) {
          processed[y * sampled.width + x] *= _hann(x, sampled.width) * windowY;
        }
      }
    }
    final field = FourierGrid.real(
      width: sampled.width,
      height: sampled.height,
      values: processed,
    );
    final spectrum = _transformService.forward(field);
    final power = Float64List(spectrum.length);
    for (var index = 0; index < spectrum.length; index++) {
      final real = spectrum.realAt(index);
      final imaginary = spectrum.imaginaryAt(index);
      power[index] = real * real + imaginary * imaginary;
    }

    final features = _extractFeatures(
      power,
      width: sampled.width,
      height: sampled.height,
      previousPower: previousPower,
      captureMean: mean,
      captureVariance: variance,
      alphaCoverage: coveredPixels / sourceLuminance.length,
      windowApplied: applyHann,
      dcRemoved: removeDc,
    );

    return FourierImageAnalysis(
      scalarField: field,
      spectrum: spectrum,
      power: power,
      features: features,
      isBlank: coveredPixels == 0 || variance <= 1e-15,
    );
  }

  static FourierSpectrumFeatures _extractFeatures(
    Float64List power, {
    required int width,
    required int height,
    required Float64List? previousPower,
    required double captureMean,
    required double captureVariance,
    required double alphaCoverage,
    required bool windowApplied,
    required bool dcRemoved,
  }) {
    final radialBands = List<double>.filled(10, 0);
    final radii = Float64List(power.length);
    final logRadii = Float64List(power.length);
    final minimumRadius = math.min(1 / width, 1 / height) * math.sqrt(2);
    var totalPower = 0.0;
    var lowPower = 0.0;
    var midPower = 0.0;
    var highPower = 0.0;
    var weightedLogRadius = 0.0;
    var axialCosine = 0.0;
    var axialSine = 0.0;
    var orientedPower = 0.0;
    for (var index = 0; index < power.length; index++) {
      final x = index % width;
      final y = index ~/ width;
      final frequencyX = (x <= width ~/ 2 ? x : x - width) / width;
      final frequencyY = (y <= height ~/ 2 ? y : y - height) / height;
      final radius = math.min(
        1.0,
        math.sqrt(frequencyX * frequencyX + frequencyY * frequencyY) *
            math.sqrt(2),
      );
      final logRadius = radius == 0 || minimumRadius >= 1
          ? radius
          : (math.log(radius / minimumRadius) / math.log(1 / minimumRadius))
              .clamp(0.0, 1.0);
      radii[index] = radius;
      logRadii[index] = logRadius;
      final value = power[index];
      totalPower += value;
      weightedLogRadius += value * logRadius;
      if (radius > 0 && value > 0) {
        final physicalRadius =
            math.sqrt(frequencyX * frequencyX + frequencyY * frequencyY);
        final unitX = frequencyX / physicalRadius;
        final unitY = frequencyY / physicalRadius;
        axialCosine += value * (unitX * unitX - unitY * unitY);
        axialSine += value * 2 * unitX * unitY;
        orientedPower += value;
      }
      if (radius < 0.15) {
        lowPower += value;
      } else if (radius <= 0.45) {
        midPower += value;
      } else {
        highPower += value;
      }
      final band = radius == 0 ? 0 : (1 + (logRadius * 9).floor()).clamp(1, 9);
      radialBands[band] += value;
    }
    if (totalPower > 0) {
      for (var index = 0; index < radialBands.length; index++) {
        radialBands[index] /= totalPower;
      }
    }
    final centroid = totalPower == 0 ? 0.0 : weightedLogRadius / totalPower;
    var bandwidth = 0.0;
    if (totalPower > 0) {
      for (var index = 0; index < power.length; index++) {
        final difference = logRadii[index] - centroid;
        bandwidth += power[index] * difference * difference;
      }
      bandwidth = math.sqrt(bandwidth / totalPower);
    }
    var cumulative = 0.0;
    var rolloff85 = 0.0;
    if (totalPower > 0) {
      final order = List<int>.generate(power.length, (index) => index)
        ..sort((left, right) => radii[left].compareTo(radii[right]));
      for (final index in order) {
        cumulative += power[index];
        if (cumulative >= totalPower * 0.85) {
          rolloff85 = logRadii[index];
          break;
        }
      }
    }
    var entropy = 0.0;
    var logPowerSum = 0.0;
    const flatnessEpsilon = 1e-20;
    for (final value in power) {
      if (totalPower > 0 && value > 0) {
        final probability = value / totalPower;
        entropy -= probability * math.log(probability);
      }
      logPowerSum += math.log(value + flatnessEpsilon);
    }
    if (power.length > 1) {
      entropy /= math.log(power.length);
    }
    final arithmeticMean = totalPower / power.length + flatnessEpsilon;
    final flatness = totalPower == 0
        ? 0.0
        : math.exp(logPowerSum / power.length) / arithmeticMean;
    var orientation = 0.5 * math.atan2(axialSine, axialCosine);
    if (orientation < 0) orientation += math.pi;
    final orientationStrength = orientedPower == 0
        ? 0.0
        : math.sqrt(axialCosine * axialCosine + axialSine * axialSine) /
            orientedPower;

    var spectralFlux = 0.0;
    if (previousPower != null &&
        previousPower.length == power.length &&
        totalPower > 0) {
      final previousTotal = previousPower.fold<double>(
        0,
        (sum, value) => sum + math.max(0, value),
      );
      if (previousTotal > 0) {
        var squaredDifference = 0.0;
        for (var index = 0; index < power.length; index++) {
          final difference = power[index] / totalPower -
              math.max(0, previousPower[index]) / previousTotal;
          squaredDifference += difference * difference;
        }
        spectralFlux =
            math.sqrt(squaredDifference / 2).clamp(0.0, 1.0).toDouble();
      }
    }

    final nonzeroBands = <(double, double)>[
      for (var index = 1; index < radialBands.length; index++)
        if (radialBands[index] > 0)
          (
            math.log((index + 0.5) / radialBands.length),
            math.log(radialBands[index])
          ),
    ];
    var logPowerSlope = 0.0;
    if (nonzeroBands.length >= 2) {
      final meanX = nonzeroBands.fold<double>(0, (sum, pair) => sum + pair.$1) /
          nonzeroBands.length;
      final meanY = nonzeroBands.fold<double>(0, (sum, pair) => sum + pair.$2) /
          nonzeroBands.length;
      var covariance = 0.0;
      var varianceX = 0.0;
      for (final pair in nonzeroBands) {
        covariance += (pair.$1 - meanX) * (pair.$2 - meanY);
        varianceX += (pair.$1 - meanX) * (pair.$1 - meanX);
      }
      if (varianceX > 0) logPowerSlope = covariance / varianceX;
    }
    final strongestBand = radialBands.reduce(math.max);
    final radialPeakSalience = strongestBand == 0
        ? 0.0
        : ((strongestBand - 0.1) / (strongestBand + 0.1))
            .clamp(0.0, 1.0)
            .toDouble();

    return FourierSpectrumFeatures(
      radialBandPower: radialBands,
      lowPowerRatio: totalPower == 0 ? 0 : lowPower / totalPower,
      midPowerRatio: totalPower == 0 ? 0 : midPower / totalPower,
      highPowerRatio: totalPower == 0 ? 0 : highPower / totalPower,
      centroid: centroid,
      bandwidth: bandwidth,
      rolloff85: rolloff85,
      logPowerSlope: logPowerSlope,
      radialPeakSalience: radialPeakSalience,
      entropy: entropy,
      flatness: flatness.clamp(0.0, 1.0),
      dominantOrientation: orientation,
      orientationStrength: orientationStrength.clamp(0.0, 1.0).toDouble(),
      spectralFlux: spectralFlux,
      captureMean: captureMean,
      captureVariance: captureVariance,
      alphaCoverage: alphaCoverage,
      width: width,
      height: height,
      windowApplied: windowApplied,
      dcRemoved: dcRemoved,
    );
  }

  static double _srgbToLinear(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  static double _hann(int index, int length) => length == 1
      ? 1
      : 0.5 * (1 - math.cos(2 * math.pi * index / (length - 1)));

  static _SampledField _areaDownsample(
    Float64List source, {
    required int width,
    required int height,
    required int? maxDimension,
  }) {
    final sourceMaximum = math.max(width, height);
    if (maxDimension == null || sourceMaximum <= maxDimension) {
      return _SampledField(source, width, height);
    }
    final scale = maxDimension / sourceMaximum;
    final targetWidth = math.max(1, (width * scale).round());
    final targetHeight = math.max(1, (height * scale).round());
    final output = Float64List(targetWidth * targetHeight);
    final scaleX = width / targetWidth;
    final scaleY = height / targetHeight;
    for (var targetY = 0; targetY < targetHeight; targetY++) {
      final top = targetY * scaleY;
      final bottom = (targetY + 1) * scaleY;
      for (var targetX = 0; targetX < targetWidth; targetX++) {
        final left = targetX * scaleX;
        final right = (targetX + 1) * scaleX;
        var weightedSum = 0.0;
        for (var sourceY = top.floor(); sourceY < bottom.ceil(); sourceY++) {
          final overlapY = math.max(
            0.0,
            math.min(bottom, sourceY + 1.0) - math.max(top, sourceY.toDouble()),
          );
          for (var sourceX = left.floor(); sourceX < right.ceil(); sourceX++) {
            final overlapX = math.max(
              0.0,
              math.min(right, sourceX + 1.0) -
                  math.max(left, sourceX.toDouble()),
            );
            weightedSum +=
                source[sourceY * width + sourceX] * overlapX * overlapY;
          }
        }
        output[targetY * targetWidth + targetX] =
            weightedSum / (scaleX * scaleY);
      }
    }
    return _SampledField(output, targetWidth, targetHeight);
  }
}

final class _SampledField {
  const _SampledField(this.values, this.width, this.height);

  final Float64List values;
  final int width;
  final int height;
}
