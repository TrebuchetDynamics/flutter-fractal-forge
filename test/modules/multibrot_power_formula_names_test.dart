import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_multibrot_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-polynomial powers do not claim degree or inverse iteration', () {
    for (final entry in sharedMultibrotCatalogEntries) {
      if (entry.power < 0) {
        expect(entry.name, 'Rational map z^${entry.power.toInt()} + c');
      } else if (entry.power != entry.power.roundToDouble()) {
        expect(entry.name, 'Branch-selected power z^${entry.power} + c');
      } else {
        expect(entry.name, 'Multibrot z^${entry.power.toInt()}');
      }
    }
    expect(
        sharedMultibrotCatalogEntries
            .singleWhere((entry) => entry.power == -3)
            .id,
        'f0103_inverse_multibrot_d_3');
  });
}
