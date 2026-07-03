// GENERATED — reviewed Svensson attractor coefficient-map promotions.
// Source: existing-app Svensson metadata aliases with explicit a,b,c,d values.

import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_coefficient_attractor_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedSvenssonCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;
  final double c;
  final double d;

  const SharedSvenssonCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

const List<SharedSvenssonCatalogEntry> sharedSvenssonCatalogEntries = [
  SharedSvenssonCatalogEntry(
    id: 'f1041_svensson_classic',
    name: 'Svensson Classic',
    a: 1.4,
    b: 1.56,
    c: 1.4,
    d: -6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1042_svensson_bloom',
    name: 'Svensson Bloom',
    a: -2.337,
    b: -2.337,
    c: 0.533,
    d: 1.378,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1043_svensson_storm',
    name: 'Svensson Storm',
    a: -2.0,
    b: 2.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1044_svensson_lace',
    name: 'Svensson Lace',
    a: 1.5,
    b: -1.8,
    c: 1.6,
    d: 0.9,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1045_svensson_iris',
    name: 'Svensson Iris',
    a: -1.78,
    b: -2.05,
    c: -2.55,
    d: -0.53,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1046_svensson_wave',
    name: 'Svensson Wave',
    a: 1.4,
    b: 1.56,
    c: 1.4,
    d: 6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1047_svensson_coral',
    name: 'Svensson Coral',
    a: 0.77,
    b: 2.39,
    c: 6.34,
    d: -6.36,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1048_svensson_eye',
    name: 'Svensson Eye',
    a: -2.0,
    b: -2.0,
    c: -1.2,
    d: 2.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1049_svensson_net',
    name: 'Svensson Net',
    a: 1.4,
    b: 1.56,
    c: -1.4,
    d: -6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1050_svensson_bay',
    name: 'Svensson Bay',
    a: -1.55,
    b: 1.55,
    c: -2.4,
    d: -2.4,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1051_svensson_petals',
    name: 'Svensson Petals',
    a: -2.7,
    b: 5.0,
    c: -1.9,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1052_svensson_arc',
    name: 'Svensson Arc',
    a: 1.0,
    b: 1.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1053_svensson_mandala',
    name: 'Svensson Mandala',
    a: -2.34,
    b: 2.0,
    c: 0.2,
    d: 0.1,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1054_svensson_halo',
    name: 'Svensson Halo',
    a: -2.5,
    b: 5.0,
    c: -1.9,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1055_svensson_cyclone',
    name: 'Svensson Cyclone',
    a: -2.34,
    b: -3.34,
    c: 0.5,
    d: -1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1056_svensson_twist',
    name: 'Svensson Twist',
    a: 1.5,
    b: -2.5,
    c: 1.5,
    d: 0.5,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1057_svensson_disk',
    name: 'Svensson Disk',
    a: 2.0,
    b: 2.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1058_svensson_tornado',
    name: 'Svensson Tornado',
    a: -1.4,
    b: 1.6,
    c: 1.0,
    d: 0.7,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1059_svensson_mist',
    name: 'Svensson Mist',
    a: -0.2,
    b: -1.1,
    c: -0.5,
    d: 1.3,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1060_svensson_fan',
    name: 'Svensson Fan',
    a: -1.5,
    b: -1.7,
    c: -0.3,
    d: -0.7,
  ),
];

List<FractalModule> buildSharedSvenssonCatalogModules() =>
    sharedSvenssonCatalogEntries
        .map(_buildSharedSvenssonModule)
        .toList(growable: false);

FractalModule _buildSharedSvenssonModule(SharedSvenssonCatalogEntry entry) {
  return buildSharedCoefficientAttractorModule(
    id: entry.id,
    name: entry.name,
    shaderAsset: 'shaders/strange_attractors/svensson_gpu.frag',
    a: entry.a,
    b: entry.b,
    c: entry.c,
    d: entry.d,
    bailout: 24.0,
    coefficientMin: -8.0,
    coefficientMax: 8.0,
    coefficientRadius: 0.6,
  );
}
