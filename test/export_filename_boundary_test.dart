import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportSizePolicy.validateExportFilename', () {
    test('accepts sanitized basenames', () {
      for (final name in [
        'mandelbrot_1718500000000.png',
        'fractal_log_1718500000000.txt',
        'gpu_debug_burning_ship_1718.json',
        'a.png',
        'my-export_2.webp',
        'my..name.png', // literal `..` inside a segment is harmless
      ]) {
        expect(() => ExportSizePolicy.validateExportFilename(name),
            returnsNormally,
            reason: '"$name" should be accepted');
      }
    });

    test('rejects path-traversal and separator filenames', () {
      for (final name in [
        '',
        '.',
        '..',
        '../evil.png',
        '../../etc/passwd',
        'sub/dir.png',
        '/absolute/path.png',
        r'back\slash.png',
        'with\u0000null.png',
      ]) {
        expect(
          () => ExportSizePolicy.validateExportFilename(name),
          throwsA(isA<StateError>()),
          reason: '"$name" must be rejected',
        );
      }
    });
  });
}
