import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/modules/builders/escape_time/catalog.dart'
    as escape_time_facade;
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart'
    as escape_time_flat;
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart'
    as raymarched_3d_facade;
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart'
    as raymarched_3d_flat;

void main() {
  group('builder catalog compatibility facades', () {
    test('escape-time facade exports the canonical catalog', () {
      expect(escape_time_facade.escapeTimeCatalog,
          same(escape_time_flat.escapeTimeCatalog));
      expect(escape_time_facade.buildEscapeTimeCatalogModules().length,
          escape_time_flat.buildEscapeTimeCatalogModules().length);
    });

    test('raymarched 3D facade exports the canonical catalog', () {
      expect(raymarched_3d_facade.raymarched3DCatalog,
          same(raymarched_3d_flat.raymarched3DCatalog));
      expect(raymarched_3d_facade.buildRaymarched3DCatalogModules().length,
          raymarched_3d_flat.buildRaymarched3DCatalogModules().length);
    });
  });
}
