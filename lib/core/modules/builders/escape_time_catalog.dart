import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

part 'escape_time_catalog/core_escape_time_family.dart';
part 'escape_time_catalog/new_escape_time_fractals.dart';
part 'escape_time_catalog/ifs_geometric_fractals.dart';
part 'escape_time_catalog/maps_attractors.dart';
part 'escape_time_catalog/convergent_root_finding.dart';
part 'escape_time_catalog/hypercomplex_slices.dart';
part 'escape_time_catalog/trigonometric.dart';
part 'escape_time_catalog/rational_polynomial.dart';
part 'escape_time_catalog/lyapunov.dart';
part 'escape_time_catalog/cellular_stochastic.dart';
part 'escape_time_catalog/final_entries.dart';
part 'escape_time_catalog/mandlebrot_sfml_batch_1.dart';
part 'escape_time_catalog/mandlebrot_sfml_batch_2.dart';
part 'escape_time_catalog/batch_14_extensions.dart';
part 'escape_time_catalog/batch_16_novel_dynamics.dart';
part 'escape_time_catalog/batch_17_weierstrass_steffensen.dart';
part 'escape_time_catalog/batch_18_web_researched.dart';
part 'escape_time_catalog/batch_19_researched_additions.dart';
part 'escape_time_catalog/batch_20_next_wave_research.dart';
part 'escape_time_catalog/batch_21_third_wave_research.dart';
part 'escape_time_catalog/batch_22_fourth_wave_research.dart';
part 'escape_time_catalog/batch_23_fifth_wave_research.dart';
part 'escape_time_catalog/kaleidoscopes.dart';

FractalParameter _floatParam({
  required String id,
  required String label,
  required double min,
  required double max,
  required double step,
  required double defaultValue,
}) =>
    FractalParameter(
      id: id,
      label: (_) => label,
      type: FractalParamType.float,
      min: min,
      max: max,
      step: step,
      defaultValue: defaultValue,
    );

/// All standard 2D escape-time fractals defined declaratively.
///
/// To add a new escape-time fractal:
/// 1. Write a .frag shader following the standard uniform layout
///    (see escape_time_builder.dart for the layout)
/// 2. Add an [EscapeTimeConfig] entry here
/// 3. Register the shader in pubspec.yaml under flutter.shaders
/// 4. Done! No new Dart file needed.
///
/// For fractals that need custom uniform layouts or special params,
/// use [extraParams] or write a custom builder.

final List<EscapeTimeConfig> escapeTimeCatalog = [
  ..._coreEscapeTimeFamilyCatalog,
  ..._newEscapeTimeFractalsCatalog,
  ..._ifsGeometricFractalsCatalog,
  ..._mapsAttractorsCatalog,
  ..._convergentRootFindingCatalog,
  ..._hypercomplexSlicesCatalog,
  ..._trigonometricCatalog,
  ..._rationalPolynomialCatalog,
  ..._lyapunovCatalog,
  ..._cellularStochasticCatalog,
  ..._finalEntriesCatalog,
  ..._mandlebrotSfmlBatch1Catalog,
  ..._mandlebrotSfmlBatch2Catalog,
  ..._batch14ExtensionsCatalog,
  ..._batch16NovelDynamicsCatalog,
  ..._batch17WeierstrassSteffensenCatalog,
  ..._batch18WebResearchedCatalog,
  ..._batch19ResearchedAdditionsCatalog,
  ..._batch20NextWaveResearchCatalog,
  ..._batch21ThirdWaveResearchCatalog,
  ..._batch22FourthWaveResearchCatalog,
  ..._batch23FifthWaveResearchCatalog,
  ..._kaleidoscopesCatalog,
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}
