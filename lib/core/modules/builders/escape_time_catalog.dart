import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

// Category exports
export 'catalog/core_escape_time.dart';
export 'catalog/new_escape_time.dart';
export 'catalog/ifs_geometric.dart';
export 'catalog/maps_attractors.dart';
export 'catalog/convergent_root_finding.dart';
export 'catalog/hypercomplex.dart';
export 'catalog/trigonometric.dart';
export 'catalog/advanced_rational.dart';
export 'catalog/lyapunov.dart';
export 'catalog/cellular_automata.dart';
export 'catalog/final_entries.dart';
export 'catalog/mandlebrot_setsfml_1.dart';
export 'catalog/mandlebrot_setsfml_2.dart';
export 'catalog/batch_14.dart';
export 'catalog/batches_16_17.dart';
export 'catalog/batch_18.dart';

// Import all category lists
import 'catalog/core_escape_time.dart';
import 'catalog/new_escape_time.dart';
import 'catalog/ifs_geometric.dart';
import 'catalog/maps_attractors.dart';
import 'catalog/convergent_root_finding.dart';
import 'catalog/hypercomplex.dart';
import 'catalog/trigonometric.dart';
import 'catalog/advanced_rational.dart';
import 'catalog/lyapunov.dart';
import 'catalog/cellular_automata.dart';
import 'catalog/final_entries.dart';
import 'catalog/mandlebrot_setsfml_1.dart';
import 'catalog/mandlebrot_setsfml_2.dart';
import 'catalog/batch_14.dart';
import 'catalog/batches_16_17.dart';
import 'catalog/batch_18.dart';

/// All standard 2D escape-time fractals defined declaratively.
///
/// This is a barrel export that combines all category-specific
/// escape-time fractal entries into a single catalog list.
///
/// To add a new escape-time fractal:
/// 1. Write a .frag shader following the standard uniform layout
///    (see escape_time_builder.dart for the layout)
/// 2. Add an [EscapeTimeConfig] entry to the appropriate category file
///    in the catalog/ directory
/// 3. Register the shader in pubspec.yaml under flutter.shaders
/// 4. Done! No new Dart file needed.
///
/// For fractals that need custom uniform layouts or special params,
/// use [extraParams] or write a custom builder.

/// Master catalog combining all escape-time fractal entries.
///
/// Categories are ordered to maintain backwards compatibility
/// and logical grouping:
/// 1. Core escape-time family
/// 2. New escape-time additions
/// 3. IFS / Geometric fractals
/// 4. 2D Maps / Attractors
/// 5. Convergent / Root-finding
/// 6. Hypercomplex / Higher-dimensional slices
/// 7. Trigonometric
/// 8. Advanced Rational & Polynomial
/// 9. Lyapunov
/// 10. Cellular Automata & Stochastic Growth
/// 11. Final entries (monotiles, etc.)
/// 12-16. Research batches (MandlebrotSetSFML, batches 14-18)
final List<EscapeTimeConfig> escapeTimeCatalog = [
  ...coreEscapeTimeEntries,
  ...newEscapeTimeEntries,
  ...ifsGeometricEntries,
  ...mapsAttractorEntries,
  ...convergentRootFindingEntries,
  ...hypercomplexEntries,
  ...trigonometricEntries,
  ...advancedRationalEntries,
  ...lyapunovEntries,
  ...cellularAutomataEntries,
  ...finalEntries,
  ...mandlebrotSetSFML1Entries,
  ...mandlebrotSetSFML2Entries,
  ...batch14Entries,
  ...batches16_17Entries,
  ...batch18Entries,
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}
