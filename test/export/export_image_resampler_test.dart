import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/services/export/export_image_resampler.dart';

void main() {
  test('transparent RGB does not bleed into a visible edge', () {
    final source = img.Image(width: 2, height: 1, numChannels: 4);
    source.setPixelRgba(0, 0, 255, 0, 0, 255);
    source.setPixelRgba(1, 0, 0, 0, 255, 0);
    final pixel = resizeExportImage(source, width: 1, height: 1).getPixel(0, 0);
    expect([pixel.r, pixel.g, pixel.b, pixel.a], [255, 0, 0, 128]);
  });

  test('fully transparent areas produce canonical transparent black', () {
    final source = img.Image(width: 2, height: 2, numChannels: 4);
    img.fill(source, color: img.ColorRgba8(255, 40, 200, 0));
    final pixel = resizeExportImage(source, width: 1, height: 1).getPixel(0, 0);
    expect([pixel.r, pixel.g, pixel.b, pixel.a], [0, 0, 0, 0]);
  });

  for (final vertical in [false, true]) {
    test(
        'weights fractional pixel coverage on the ${vertical ? 'Y' : 'X'} axis',
        () {
      final source =
          img.Image(width: vertical ? 1 : 3, height: vertical ? 3 : 1);
      source.setPixelRgb(vertical ? 0 : 1, vertical ? 1 : 0, 255, 255, 255);
      final output = resizeExportImage(source,
          width: vertical ? 1 : 2, height: vertical ? 2 : 1);
      // Each destination covers 1.5 source pixels, including half the white
      // pixel: linear intensity 1/3 maps to sRGB 156. Integer buckets alias it.
      for (final pixel in output) {
        expect(pixel.r, closeTo(156, 1));
        expect(pixel.g, pixel.r);
        expect(pixel.b, pixel.r);
      }
    });
  }

  test('preserves every constant 8-bit tone and translucent alpha', () {
    for (var value = 0; value < 256; value++) {
      final source = img.Image(width: 7, height: 5, numChannels: 4);
      img.fill(source, color: img.ColorRgba8(value, value, value, 137));
      final output = resizeExportImage(source, width: 3, height: 2);
      for (final pixel in output) {
        expect(
            [pixel.r, pixel.g, pixel.b, pixel.a], [value, value, value, 137]);
      }
    }
  });

  test('same-size exports bypass resampling and preserve hidden RGB', () {
    final source = img.Image(width: 2, height: 2, numChannels: 4);
    img.fill(source, color: img.ColorRgba8(10, 20, 30, 0));
    expect(identical(resizeExportImage(source, width: 2, height: 2), source),
        isTrue);
  });

  test('preserves metadata and leaves the source unchanged', () {
    final source = img.Image(width: 4, height: 4, textData: {'Title': 'Orbit'});
    img.fill(source, color: img.ColorRgb8(40, 80, 120));
    final output = resizeExportImage(source, width: 2, height: 2);
    expect(output.textData, {'Title': 'Orbit'});
    expect((source.width, source.height), (4, 4));
    output.setPixelRgb(0, 0, 0, 0, 0);
    expect(source.getPixel(0, 0).r, 40);
  });

  test('enlargement keeps the established interpolation behavior', () {
    final source = img.Image(width: 2, height: 1);
    source.setPixelRgb(1, 0, 255, 100, 50);
    final output = resizeExportImage(source, width: 5, height: 3);
    final expected = img.copyResize(source,
        width: 5, height: 3, interpolation: img.Interpolation.average);
    expect(output.getBytes(), expected.getBytes());
  });

  test('rejects nonpositive target sizes', () {
    final source = img.Image(width: 1, height: 1);
    expect(() => resizeExportImage(source, width: 0, height: 1),
        throwsArgumentError);
    expect(() => resizeExportImage(source, width: 1, height: -1),
        throwsArgumentError);
  });

  test('higher bit depths retain the existing precision and format', () {
    final source = img.Image(width: 2, height: 2, format: img.Format.uint16);
    for (final pixel in source) {
      pixel.setRgb(12345, 23456, 34567);
    }
    final output = resizeExportImage(source, width: 1, height: 1);
    expect(output.format, img.Format.uint16);
    final pixel = output.getPixel(0, 0);
    expect([pixel.r, pixel.g, pixel.b], [12345, 23456, 34567]);
  });

  test('oriented images retain the library orientation handling', () {
    final source = img.Image(width: 4, height: 2);
    for (final pixel in source) {
      pixel.setRgb(pixel.x * 60, pixel.y * 200, 0);
    }
    source.exif.imageIfd.orientation = 6;
    final output = resizeExportImage(source, width: 2, height: 1);
    final expected = img.copyResize(source,
        width: 2, height: 1, interpolation: img.Interpolation.average);
    expect(output.getBytes(), expected.getBytes());
  });
}
