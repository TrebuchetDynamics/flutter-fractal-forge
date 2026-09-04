import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Area filtering for the 8-bit sRGB still images captured by the renderer.
///
/// Accumulates linear-light, premultiplied RGB so thin bright structures retain
/// their energy and invisible RGB cannot stain translucent edges. Fractional
/// pixel coverage avoids uneven bands at non-integer reduction ratios.
///
/// Only the destination image is allocated, with constant-sized transfer tables
/// shared across calls. Run large exports in the existing export worker.
img.Image resizeExportImage(
  img.Image source, {
  required int width,
  required int height,
}) {
  if (width <= 0 || height <= 0) {
    throw ArgumentError('Export dimensions must be positive');
  }
  if (source.width == width && source.height == height) return source;

  // Keep existing enlargement and non-capture format handling. In particular,
  // a tagged color profile must not be interpreted as untagged sRGB.
  if (width > source.width ||
      height > source.height ||
      source.format != img.Format.uint8 ||
      source.numChannels < 3 ||
      source.hasPalette ||
      source.numFrames != 1 ||
      source.iccProfile != null ||
      (source.exif.imageIfd.hasOrientation &&
          source.exif.imageIfd.orientation != 1)) {
    return img.copyResize(source,
        width: width, height: height, interpolation: img.Interpolation.average);
  }

  final output = img.Image.fromResized(source, width: width, height: height);
  final scaleX = source.width / width;
  final scaleY = source.height / height;
  final area = scaleX * scaleY;
  final pixel = source.getPixel(0, 0);
  final decode = _srgbToLinear;
  final encode = _linearToSrgb;

  for (var y = 0; y < height; y++) {
    final top = y * scaleY;
    final bottom = math.min((y + 1) * scaleY, source.height.toDouble());
    for (var x = 0; x < width; x++) {
      final left = x * scaleX;
      final right = math.min((x + 1) * scaleX, source.width.toDouble());
      var red = 0.0;
      var green = 0.0;
      var blue = 0.0;
      var alpha = 0.0;
      for (var sy = top.floor(); sy < bottom.ceil(); sy++) {
        final coverageY = math.min(sy + 1.0, bottom) - math.max(sy, top);
        for (var sx = left.floor(); sx < right.ceil(); sx++) {
          final coverageX = math.min(sx + 1.0, right) - math.max(sx, left);
          source.getPixel(sx, sy, pixel);
          final weight = coverageX * coverageY * pixel.a;
          alpha += weight;
          red += decode[pixel.r.toInt()] * weight;
          green += decode[pixel.g.toInt()] * weight;
          blue += decode[pixel.b.toInt()] * weight;
        }
      }
      if (alpha == 0) {
        output.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        final normalize = (_encodeSteps - 1) / alpha;
        output.setPixelRgba(
          x,
          y,
          encode[(red * normalize).round().clamp(0, _encodeSteps - 1)],
          encode[(green * normalize).round().clamp(0, _encodeSteps - 1)],
          encode[(blue * normalize).round().clamp(0, _encodeSteps - 1)],
          (alpha / area).round().clamp(0, 255),
        );
      }
    }
  }
  return output;
}

// sRGB transfer functions: https://www.w3.org/TR/css-color-4/#color-conversion-code
// Lookup tables keep exponentiation out of the per-pixel export loop.
final _srgbToLinear = Float64List.fromList(List.generate(256, (value) {
  final encoded = value / 255;
  return encoded <= 0.04045
      ? encoded / 12.92
      : math.pow((encoded + 0.055) / 1.055, 2.4).toDouble();
}));

const _encodeSteps = 65536;
final _linearToSrgb = Uint8List.fromList(List.generate(_encodeSteps, (value) {
  final linear = value / (_encodeSteps - 1);
  final encoded = linear <= 0.0031308
      ? linear * 12.92
      : 1.055 * math.pow(linear, 1 / 2.4) - 0.055;
  return (encoded * 255).round().clamp(0, 255);
}));
