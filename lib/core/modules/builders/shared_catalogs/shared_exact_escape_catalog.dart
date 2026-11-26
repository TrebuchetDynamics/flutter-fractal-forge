// GENERATED — reviewed exact escape/root/orbit renderer promotions.
// Source: existing-app leads with exact local shader support and bundled thumbnails.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedExactEscapeCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final String category;
  final double iterations;
  final double bailout;
  final List<FractalParameter> extraParams;

  const SharedExactEscapeCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
    required this.category,
    this.iterations = 180,
    this.bailout = 16,
    this.extraParams = const [],
  });
}

final List<SharedExactEscapeCatalogEntry> sharedExactEscapeCatalogEntries = [
  SharedExactEscapeCatalogEntry(
    id: 'f0534_weierstrass_elliptic',
    name: 'Weierstrass Elliptic',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/special_functions/weierstrass_elliptic_gpu.frag',
    category: 'Trigonometric & Transcendental',
    iterations: 120,
    bailout: 4,
    extraParams: [
      FractalParameter(
        id: 'g2',
        label: (_) => 'g₂',
        type: FractalParamType.float,
        min: -8,
        max: 8,
        step: 0.1,
        defaultValue: 4.0,
      ),
    ],
  ),
  const SharedExactEscapeCatalogEntry(
    id: 'f0538_newton_sin',
    name: 'Newton-sin',
    shaderAsset: 'shaders/root_finding/newton_sin_gpu.frag',
    category: 'Convergent & Root-Finding',
    iterations: 120,
    bailout: 8,
  ),
  const SharedExactEscapeCatalogEntry(
    id: 'f1142_buddhabrot',
    name: 'Buddhabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  const SharedExactEscapeCatalogEntry(
    id: 'f1143_anti_buddhabrot',
    name: 'Anti-Buddhabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/anti_buddhabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  const SharedExactEscapeCatalogEntry(
    id: 'f1144_nebulabrot',
    name: 'Nebulabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/nebulabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  const SharedExactEscapeCatalogEntry(
    id: 'f1156_orbit_trap_cross',
    name: 'Orbit Trap Cross',
    shaderAsset:
        'shaders/escape_time_family/orbit_and_domain/orbit_trap_cross_gpu.frag',
    category: 'Escape-Time',
    iterations: 160,
    bailout: 8,
  ),
];

List<FractalModule> buildSharedExactEscapeCatalogModules() =>
    sharedExactEscapeCatalogEntries
        .map(
          (entry) => buildEscapeTimeModule(
            EscapeTimeConfig(
              id: entry.id,
              name: entry.name,
              shaderAsset: entry.shaderAsset,
              category: entry.category,
              defaultIterations: entry.iterations,
              defaultBailout: entry.bailout,
              extraParams: entry.extraParams,
            ),
          ),
        )
        .toList(growable: false);
