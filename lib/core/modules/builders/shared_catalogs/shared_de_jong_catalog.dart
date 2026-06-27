// GENERATED — reviewed Peter de Jong coefficient-map promotions.
// Source: existing-app de Jong metadata aliases with explicit a,b,c,d values.

import 'package:flutter_fractals/core/modules/builders/shared_coefficient_attractor_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedDeJongCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;
  final double c;
  final double d;

  const SharedDeJongCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

const List<SharedDeJongCatalogEntry> sharedDeJongCatalogEntries = [
  SharedDeJongCatalogEntry(
    id: 'f0370_de_jong_classic',
    name: 'de Jong Classic',
    a: 1.4,
    b: -2.3,
    c: 2.4,
    d: -2.1,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0371_de_jong_peacock',
    name: 'de Jong Peacock',
    a: 2.01,
    b: -2.53,
    c: 1.61,
    d: -0.33,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0372_de_jong_spirals',
    name: 'de Jong Spirals',
    a: -2.7,
    b: -0.09,
    c: -0.86,
    d: -2.2,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0373_de_jong_crescent',
    name: 'de Jong Crescent',
    a: -1.24,
    b: -1.25,
    c: -1.88,
    d: -1.11,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0374_de_jong_flow',
    name: 'de Jong Flow',
    a: 1.641,
    b: 1.902,
    c: 0.316,
    d: 1.525,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0375_de_jong_whirlpool',
    name: 'de Jong Whirlpool',
    a: -0.827,
    b: -1.637,
    c: 1.659,
    d: -0.943,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0376_de_jong_petals',
    name: 'de Jong Petals',
    a: -2.24,
    b: 0.43,
    c: -0.65,
    d: -2.43,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0377_de_jong_filigree',
    name: 'de Jong Filigree',
    a: 1.7,
    b: -1.7,
    c: 1.7,
    d: -1.7,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0378_de_jong_cloud',
    name: 'de Jong Cloud',
    a: -2.0,
    b: -2.0,
    c: -1.2,
    d: 2.0,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0379_de_jong_mesh',
    name: 'de Jong Mesh',
    a: 2.0,
    b: -2.0,
    c: -1.2,
    d: 2.0,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0380_de_jong_leaf',
    name: 'de Jong Leaf',
    a: -2.24,
    b: 0.43,
    c: -0.65,
    d: 1.6,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0381_de_jong_double',
    name: 'de Jong Double',
    a: 1.4,
    b: -2.3,
    c: 2.4,
    d: 2.1,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0382_de_jong_cascade',
    name: 'de Jong Cascade',
    a: 0.97,
    b: -1.899,
    c: 1.381,
    d: -1.506,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0383_de_jong_maze',
    name: 'de Jong Maze',
    a: -1.7,
    b: -1.7,
    c: 1.7,
    d: 1.7,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0384_de_jong_web',
    name: 'de Jong Web',
    a: -2.7,
    b: 0.09,
    c: -0.86,
    d: -2.2,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0385_de_jong_hurricane',
    name: 'de Jong Hurricane',
    a: -1.9,
    b: 1.8,
    c: -1.9,
    d: -1.7,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0386_de_jong_coral',
    name: 'de Jong Coral',
    a: 1.1,
    b: -1.32,
    c: -0.79,
    d: 1.82,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0387_de_jong_ribbon',
    name: 'de Jong Ribbon',
    a: -2.1,
    b: 1.9,
    c: -1.2,
    d: 0.45,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0388_de_jong_butterfly',
    name: 'de Jong Butterfly',
    a: -1.0,
    b: -1.8,
    c: -1.9,
    d: -1.4,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0389_de_jong_flame',
    name: 'de Jong Flame',
    a: 1.4,
    b: 1.56,
    c: 1.4,
    d: -6.56,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0390_de_jong_storm',
    name: 'de Jong Storm',
    a: -2.24,
    b: -0.43,
    c: -0.65,
    d: -2.43,
  ),
  SharedDeJongCatalogEntry(
    id: 'f0391_de_jong_eye',
    name: 'de Jong Eye',
    a: 2.879879,
    b: -0.765145,
    c: -0.966918,
    d: 0.744728,
  ),
];

List<FractalModule> buildSharedDeJongCatalogModules() =>
    sharedDeJongCatalogEntries
        .map(_buildSharedDeJongModule)
        .toList(growable: false);

FractalModule _buildSharedDeJongModule(SharedDeJongCatalogEntry entry) {
  return buildSharedCoefficientAttractorModule(
    id: entry.id,
    name: entry.name,
    shaderAsset: 'shaders/strange_attractors/peter_de_jong_gpu.frag',
    a: entry.a,
    b: entry.b,
    c: entry.c,
    d: entry.d,
    bailout: 16.0,
    coefficientMin: -8.0,
    coefficientMax: 8.0,
  );
}
