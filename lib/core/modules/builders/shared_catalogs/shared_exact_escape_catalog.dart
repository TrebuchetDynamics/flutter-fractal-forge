// GENERATED — reviewed exact escape/root/orbit renderer promotions.
// Source: existing-app leads with exact local shader support and bundled thumbnails.

import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedExactEscapeCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final String category;
  final double iterations;
  final double bailout;

  const SharedExactEscapeCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
    required this.category,
    this.iterations = 180,
    this.bailout = 16,
  });
}

const List<SharedExactEscapeCatalogEntry> sharedExactEscapeCatalogEntries = [
  SharedExactEscapeCatalogEntry(
    id: 'f0534_weierstrass_elliptic',
    name: 'Weierstrass Elliptic',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/special_functions/weierstrass_elliptic_gpu.frag',
    category: 'Trigonometric & Transcendental',
    iterations: 120,
    bailout: 4,
  ),
  SharedExactEscapeCatalogEntry(
    id: 'f0538_newton_sin',
    name: 'Newton-sin',
    shaderAsset: 'shaders/root_finding/newton_sin_gpu.frag',
    category: 'Convergent & Root-Finding',
    iterations: 120,
    bailout: 8,
  ),
  SharedExactEscapeCatalogEntry(
    id: 'f1142_buddhabrot',
    name: 'Buddhabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  SharedExactEscapeCatalogEntry(
    id: 'f1143_anti_buddhabrot',
    name: 'Anti-Buddhabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/anti_buddhabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  SharedExactEscapeCatalogEntry(
    id: 'f1144_nebulabrot',
    name: 'Nebulabrot',
    shaderAsset:
        'shaders/escape_time_family/families/buddhabrot/nebulabrot_gpu.frag',
    category: 'Escape-Time',
    iterations: 220,
    bailout: 8,
  ),
  SharedExactEscapeCatalogEntry(
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
            ),
          ),
        )
        .toList(growable: false);
