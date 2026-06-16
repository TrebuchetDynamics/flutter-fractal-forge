import 'package:flutter_fractals/shared/utils/byte_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatByteSize', () {
    test('formats bytes below 1 KiB as B', () {
      expect(formatByteSize(0), '0 B');
      expect(formatByteSize(512), '512 B');
      expect(formatByteSize(1023), '1023 B');
    });

    test('formats the KiB range with one decimal', () {
      expect(formatByteSize(1024), '1.0 KB');
      expect(formatByteSize(1536), '1.5 KB');
      expect(formatByteSize(1024 * 1024 - 1), '1024.0 KB');
    });

    test('formats the MiB range with one decimal', () {
      expect(formatByteSize(1024 * 1024), '1.0 MB');
      expect(formatByteSize(3 * 1024 * 1024 + 512 * 1024), '3.5 MB');
    });
  });
}
