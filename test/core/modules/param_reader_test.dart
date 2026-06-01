import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/modules/param_reader.dart';

void main() {
  group('readDouble', () {
    test('accepts finite int and double values', () {
      expect(readDouble({'power': 8}, 'power', 2.0), 8.0);
      expect(readDouble({'power': 3.5}, 'power', 2.0), 3.5);
    });

    test('falls back for missing, non-numeric, and non-finite values', () {
      expect(readDouble(const {}, 'power', 2.0), 2.0);
      expect(readDouble({'power': '8'}, 'power', 2.0), 2.0);
      expect(readDouble({'power': double.nan}, 'power', 2.0), 2.0);
      expect(readDouble({'power': double.infinity}, 'power', 2.0), 2.0);
      expect(readDouble({'power': double.negativeInfinity}, 'power', 2.0), 2.0);
    });
  });

  group('readInt', () {
    test('accepts integer values and rounds finite doubles', () {
      expect(readInt({'iterations': 120}, 'iterations', 80), 120);
      expect(readInt({'iterations': 120.4}, 'iterations', 80), 120);
      expect(readInt({'iterations': 120.5}, 'iterations', 80), 121);
    });

    test('falls back for missing, non-numeric, and non-finite values', () {
      expect(readInt(const {}, 'iterations', 80), 80);
      expect(readInt({'iterations': '120'}, 'iterations', 80), 80);
      expect(readInt({'iterations': double.nan}, 'iterations', 80), 80);
      expect(readInt({'iterations': double.infinity}, 'iterations', 80), 80);
      expect(readInt({'iterations': double.negativeInfinity}, 'iterations', 80),
          80);
    });

    test('falls back for finite doubles outside integer range', () {
      expect(readInt({'iterations': 1e100}, 'iterations', 80), 80);
      expect(readInt({'iterations': -1e100}, 'iterations', 80), 80);
    });
  });
}
