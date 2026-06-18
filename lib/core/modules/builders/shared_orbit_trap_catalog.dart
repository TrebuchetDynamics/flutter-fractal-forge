// GENERATED — reviewed orbit-trap geometry renderer promotions.
// Source: research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedOrbitTrapCatalogEntry {
  final String id;
  final String name;
  final int trapMode;

  const SharedOrbitTrapCatalogEntry({
    required this.id,
    required this.name,
    required this.trapMode,
  });
}

// Cross (mode 0) is already represented by the generic mandelbrot_orbit_trap
// module and f1156 is intentionally omitted by the duplicate-risk gate.
const List<SharedOrbitTrapCatalogEntry> sharedOrbitTrapCatalogEntries = [
  SharedOrbitTrapCatalogEntry(
      id: 'f1155_orbit_trap_circle_pickover_stalks',
      name: 'Orbit Trap: Circle Pickover Stalks',
      trapMode: 1),
  SharedOrbitTrapCatalogEntry(
      id: 'f1157_orbit_trap_square', name: 'Orbit Trap: Square', trapMode: 2),
  SharedOrbitTrapCatalogEntry(
      id: 'f1158_orbit_trap_point_origin',
      name: 'Orbit Trap: Point Origin',
      trapMode: 3),
  SharedOrbitTrapCatalogEntry(
      id: 'f1159_orbit_trap_point_custom',
      name: 'Orbit Trap: Point Custom',
      trapMode: 4),
  SharedOrbitTrapCatalogEntry(
      id: 'f1160_orbit_trap_line_real_axis',
      name: 'Orbit Trap: Real Axis Line',
      trapMode: 5),
  SharedOrbitTrapCatalogEntry(
      id: 'f1161_orbit_trap_line_imaginary_axis',
      name: 'Orbit Trap: Imaginary Axis Line',
      trapMode: 6),
  SharedOrbitTrapCatalogEntry(
      id: 'f1162_orbit_trap_multi_lines_cross',
      name: 'Orbit Trap: Multi-Line Cross',
      trapMode: 7),
  SharedOrbitTrapCatalogEntry(
      id: 'f1163_orbit_trap_heart_curve',
      name: 'Orbit Trap: Heart Curve',
      trapMode: 8),
  SharedOrbitTrapCatalogEntry(
      id: 'f1164_orbit_trap_star_5_pointed',
      name: 'Orbit Trap: 5-Point Star',
      trapMode: 9),
  SharedOrbitTrapCatalogEntry(
      id: 'f1165_orbit_trap_spiral', name: 'Orbit Trap: Spiral', trapMode: 10),
  SharedOrbitTrapCatalogEntry(
      id: 'f1166_orbit_trap_text_a', name: 'Orbit Trap: Text A', trapMode: 11),
  SharedOrbitTrapCatalogEntry(
      id: 'f1167_orbit_trap_text_m', name: 'Orbit Trap: Text M', trapMode: 12),
  SharedOrbitTrapCatalogEntry(
      id: 'f1168_orbit_trap_epicycloid',
      name: 'Orbit Trap: Epicycloid',
      trapMode: 13),
  SharedOrbitTrapCatalogEntry(
      id: 'f1169_orbit_trap_rose_curve',
      name: 'Orbit Trap: Rose Curve',
      trapMode: 14),
  SharedOrbitTrapCatalogEntry(
      id: 'f1170_orbit_trap_lima_on',
      name: 'Orbit Trap: Limaçon',
      trapMode: 15),
  SharedOrbitTrapCatalogEntry(
      id: 'f1171_orbit_trap_cardioid',
      name: 'Orbit Trap: Cardioid',
      trapMode: 16),
  SharedOrbitTrapCatalogEntry(
      id: 'f1172_orbit_trap_lemniscate',
      name: 'Orbit Trap: Lemniscate',
      trapMode: 17),
  SharedOrbitTrapCatalogEntry(
      id: 'f1173_orbit_trap_astroid',
      name: 'Orbit Trap: Astroid',
      trapMode: 18),
  SharedOrbitTrapCatalogEntry(
      id: 'f1174_orbit_trap_hypocycloid_3_cusp',
      name: 'Orbit Trap: 3-Cusp Hypocycloid',
      trapMode: 19),
  SharedOrbitTrapCatalogEntry(
      id: 'f1175_orbit_trap_square_lattice',
      name: 'Orbit Trap: Square Lattice',
      trapMode: 20),
  SharedOrbitTrapCatalogEntry(
      id: 'f1176_orbit_trap_hexagonal_lattice',
      name: 'Orbit Trap: Hexagonal Lattice',
      trapMode: 21),
  SharedOrbitTrapCatalogEntry(
      id: 'f1177_orbit_trap_field_lines',
      name: 'Orbit Trap: Field Lines',
      trapMode: 22),
  SharedOrbitTrapCatalogEntry(
      id: 'f1178_orbit_trap_composite_multi_shape',
      name: 'Orbit Trap: Composite Multi-Shape',
      trapMode: 23),
  SharedOrbitTrapCatalogEntry(
      id: 'f1179_orbit_trap_concentric_rings',
      name: 'Orbit Trap: Concentric Rings',
      trapMode: 24),
];

List<FractalModule> buildSharedOrbitTrapCatalogModules() =>
    sharedOrbitTrapCatalogEntries
        .map(_buildSharedOrbitTrapModule)
        .toList(growable: false);

FractalModule _buildSharedOrbitTrapModule(SharedOrbitTrapCatalogEntry entry) {
  return buildEscapeTimeModule(EscapeTimeConfig(
    id: entry.id,
    name: entry.name,
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
    defaultIterations: 300,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraParams: [
      FractalParameter(
        id: 'trapMode',
        label: (_) => 'Trap Mode',
        type: FractalParamType.integer,
        min: 0,
        max: 24,
        step: 1,
        defaultValue: entry.trapMode,
      ),
    ],
  ));
}
