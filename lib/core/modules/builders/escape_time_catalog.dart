import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math_64.dart';

part 'escape_time_catalog/families/core_escape_time_family.dart';
part 'escape_time_catalog/families/new_escape_time_fractals.dart';
part 'escape_time_catalog/families/ifs_geometric_fractals.dart';
part 'escape_time_catalog/families/maps_attractors.dart';
part 'escape_time_catalog/families/convergent_root_finding.dart';
part 'escape_time_catalog/families/hypercomplex_slices.dart';
part 'escape_time_catalog/families/trigonometric.dart';
part 'escape_time_catalog/families/rational_polynomial.dart';
part 'escape_time_catalog/families/lyapunov.dart';
part 'escape_time_catalog/families/cellular_stochastic.dart';
part 'escape_time_catalog/research_batches/final_entries.dart';
part 'escape_time_catalog/research_batches/mandlebrot_sfml_batch_1.dart';
part 'escape_time_catalog/research_batches/mandlebrot_sfml_batch_2.dart';
part 'escape_time_catalog/research_batches/batch_14_extensions.dart';
part 'escape_time_catalog/research_batches/batch_16_novel_dynamics.dart';
part 'escape_time_catalog/research_batches/batch_17_weierstrass_steffensen.dart';
part 'escape_time_catalog/research_batches/batch_18_web_researched.dart';
part 'escape_time_catalog/research_batches/batch_19_researched_additions.dart';
part 'escape_time_catalog/research_batches/batch_20_next_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_21_third_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_22_fourth_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_23_fifth_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_24_eighth_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_25_ninth_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_26_tenth_wave_research.dart';
part 'escape_time_catalog/research_batches/batch_27_log_polar_tessellations.dart';
part 'escape_time_catalog/research_batches/batch_28_fractalish_motion.dart';
part 'escape_time_catalog/research_batches/batch_29_clean_room_visuals.dart';
part 'escape_time_catalog/research_batches/batch_30_high_impact_visuals.dart';
part 'escape_time_catalog/research_batches/batch_31_mix_family.dart';
part 'escape_time_catalog/research_batches/batch_32_planar_slices.dart';
part 'escape_time_catalog/families/kaleidoscopes.dart';

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
  ..._batch24EighthWaveResearchCatalog,
  ..._batch25NinthWaveResearchCatalog,
  ..._batch26TenthWaveResearchCatalog,
  ..._batch27LogPolarTessellationsCatalog,
  ..._batch28FractalishMotionCatalog,
  ..._batch29CleanRoomVisualsCatalog,
  ..._batch30HighImpactVisualsCatalog,
  ..._batch31MixFamilyCatalog,
  ..._batch32PlanarSliceCatalog,
  ..._kaleidoscopesCatalog,
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}
