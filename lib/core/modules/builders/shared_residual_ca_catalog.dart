// GENERATED — reviewed residual CA renderer promotions.
// Source: research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

enum SharedResidualCaKind { cyclicStates, birthSurvival, fixedRule }

class SharedResidualCaCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final SharedResidualCaKind kind;
  final double? states;
  final double? birthMask;
  final double? survivalMask;

  const SharedResidualCaCatalogEntry.fixedRule({
    required this.id,
    required this.name,
    required this.shaderAsset,
  })  : kind = SharedResidualCaKind.fixedRule,
        states = null,
        birthMask = null,
        survivalMask = null;

  const SharedResidualCaCatalogEntry.cyclic({
    required this.id,
    required this.name,
    required this.states,
  })  : shaderAsset = 'shaders/cellular_and_stochastic/cyclic_ca_gpu.frag',
        kind = SharedResidualCaKind.cyclicStates,
        birthMask = null,
        survivalMask = null;

  const SharedResidualCaCatalogEntry.birthSurvival({
    required this.id,
    required this.name,
    required this.shaderAsset,
    required this.birthMask,
    required this.survivalMask,
  })  : kind = SharedResidualCaKind.birthSurvival,
        states = null;
}

const List<SharedResidualCaCatalogEntry> sharedResidualCaCatalogEntries = [
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0319_conway_s_game_of_life',
    name: "Conway's Game of Life B3/S23",
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 12.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0320_seeds_ca',
    name: 'Seeds CA B2/S',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 4.0,
    survivalMask: 0.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0321_day_and_night',
    name: 'Day and Night B3678/S34678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 456.0,
    survivalMask: 472.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0322_highlife',
    name: 'HighLife B36/S23',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 72.0,
    survivalMask: 12.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0323_life_without_death',
    name: 'Life without Death B3/S012345678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 511.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0324_move',
    name: 'Move B368/S245',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 328.0,
    survivalMask: 52.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0326_serviettes',
    name: 'Serviettes B234/S',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 28.0,
    survivalMask: 0.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0327_maze',
    name: 'Maze B3/S12345',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 62.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0980_replicator_b1357_s1357',
    name: 'Replicator B1357/S1357',
    shaderAsset: 'shaders/cellular_and_stochastic/replicator_ca_gpu.frag',
    birthMask: 170.0,
    survivalMask: 170.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0981_fredkin_s_replicator_b1357_s02468',
    name: "Fredkin's Replicator B1357/S02468",
    shaderAsset: 'shaders/cellular_and_stochastic/replicator_ca_gpu.frag',
    birthMask: 170.0,
    survivalMask: 341.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0995_replicator_4_b1357_s03567',
    name: 'Replicator 4 B1357/S03567',
    shaderAsset: 'shaders/cellular_and_stochastic/replicator_ca_gpu.frag',
    birthMask: 170.0,
    survivalMask: 233.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0983_mazectric_b3_s1234',
    name: 'Mazectric B3/S1234',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 30.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1005_maze_with_mice_b37_s12345',
    name: 'Maze with Mice B37/S12345',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 136.0,
    survivalMask: 62.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0982_live_free_or_die_b2_s0',
    name: 'Live Free or Die B2/S0',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 4.0,
    survivalMask: 1.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0984_coagulations_b378',
    name: 'Coagulations B378/S',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 392.0,
    survivalMask: 0.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0985_2x2_b36_s125',
    name: '2x2 B36/S125',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 72.0,
    survivalMask: 38.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0986_gnarl_b1_s1',
    name: 'Gnarl B1/S1',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 2.0,
    survivalMask: 2.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0987_stains_b3678_s235678',
    name: 'Stains B3678/S235678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 456.0,
    survivalMask: 492.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0988_pseudo_life_b357_s238',
    name: 'Pseudo Life B357/S238',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 168.0,
    survivalMask: 268.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0989_long_life_b345_s5',
    name: 'Long Life B345/S5',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 56.0,
    survivalMask: 32.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0990_anneal_b4678_s35678',
    name: 'Anneal B4678/S35678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 464.0,
    survivalMask: 488.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0991_diamoeba_b35678_s5678',
    name: 'Diamoeba B35678/S5678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 488.0,
    survivalMask: 480.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0992_dot_life_b3_s023',
    name: 'Dot Life B3/S023',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 13.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0993_flock_b3_s12',
    name: 'Flock B3/S12',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 6.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0994_iceballs_b25678_s5678',
    name: 'Iceballs B25678/S5678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 484.0,
    survivalMask: 480.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0996_walled_cities_b45678_s2345',
    name: 'Walled Cities B45678/S2345',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 496.0,
    survivalMask: 60.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0998_3_4_life_b34_s34',
    name: '3/4 Life B34/S34',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 24.0,
    survivalMask: 24.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f0999_move_b368_s245',
    name: 'Move B368/S245',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 328.0,
    survivalMask: 52.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1000_snowflakes_b1_s12345678',
    name: 'Snowflakes B1/S12345678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 2.0,
    survivalMask: 510.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1001_slow_blob_b367_s23478',
    name: 'Slow Blob B367/S23478',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 200.0,
    survivalMask: 412.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1002_bugs_b3567_s15678',
    name: 'Bugs B3567/S15678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 232.0,
    survivalMask: 482.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1003_plow_world_b378_s012345678',
    name: 'Plow World B378/S012345678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 392.0,
    survivalMask: 511.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1004_land_rush_b35_s234578',
    name: 'Land Rush B35/S234578',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 40.0,
    survivalMask: 444.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1006_slow_stains_b36_s378',
    name: 'Slow Stains B36/S378',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 72.0,
    survivalMask: 392.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1007_highflock_b36_s12',
    name: 'Highflock B36/S12',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 72.0,
    survivalMask: 6.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1008_honey_life_b38_s238',
    name: 'Honey Life B38/S238',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 264.0,
    survivalMask: 268.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1009_eightlife_b3_s238',
    name: 'EightLife B3/S238',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 268.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1010_pedestrian_life_b38_s23',
    name: 'Pedestrian Life B38/S23',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 264.0,
    survivalMask: 12.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1011_lowlife_b3_s13',
    name: 'LowLife B3/S13',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 8.0,
    survivalMask: 10.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1012_drigh_life_b367_s23',
    name: 'Drigh Life B367/S23',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 200.0,
    survivalMask: 12.0,
  ),
  SharedResidualCaCatalogEntry.birthSurvival(
    id: 'f1013_inverse_life_b0123478_s34678',
    name: 'Inverse Life B0123478/S34678',
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    birthMask: 415.0,
    survivalMask: 472.0,
  ),
  SharedResidualCaCatalogEntry.cyclic(
    id: 'f1021_cyclic_ca_n_4',
    name: 'Cyclic CA (n=4)',
    states: 4.0,
  ),
  SharedResidualCaCatalogEntry.cyclic(
    id: 'f1022_cyclic_ca_n_16',
    name: 'Cyclic CA (n=16)',
    states: 16.0,
  ),
  SharedResidualCaCatalogEntry.fixedRule(
    id: 'f1014_wireworld',
    name: 'Wireworld',
    shaderAsset: 'shaders/cellular_and_stochastic/wireworld_gpu.frag',
  ),
  SharedResidualCaCatalogEntry.fixedRule(
    id: 'f1020_brian_s_brain',
    name: "Brian's Brain",
    shaderAsset: 'shaders/cellular_and_stochastic/brian_brain_gpu.frag',
  ),
  SharedResidualCaCatalogEntry.fixedRule(
    id: 'f1023_hodgepodge_machine_spiral',
    name: 'Hodgepodge Machine (Spiral)',
    shaderAsset: 'shaders/cellular_and_stochastic/hodgepodge_machine_gpu.frag',
  ),
  SharedResidualCaCatalogEntry.fixedRule(
    id: 'f1024_forest_fire_ca',
    name: 'Forest Fire CA',
    shaderAsset: 'shaders/cellular_and_stochastic/forest_fire_gpu.frag',
  ),
];

List<FractalModule> buildSharedResidualCaCatalogModules() =>
    sharedResidualCaCatalogEntries
        .map(_buildSharedResidualCaModule)
        .toList(growable: false);

FractalModule _buildSharedResidualCaModule(SharedResidualCaCatalogEntry entry) {
  final params = <String, Object>{
    'iterations': 260,
    'bailout': 4.0,
    'colorScheme': 0,
    if (entry.kind == SharedResidualCaKind.cyclicStates)
      'states': entry.states!,
    if (entry.kind == SharedResidualCaKind.birthSurvival) ...{
      'birthMask': entry.birthMask!,
      'survivalMask': entry.survivalMask!,
    },
  };
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: params,
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.twoD,
    shaderAsset: entry.shaderAsset,
    parameters: [
      CommonFractalParams.iterations(defaultValue: 260),
      CommonFractalParams.bailout(defaultValue: 4.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      if (entry.kind == SharedResidualCaKind.cyclicStates)
        FractalParameter(
          id: 'states',
          label: (_) => 'States',
          type: FractalParamType.float,
          min: 2,
          max: 32,
          step: 1,
          defaultValue: entry.states!,
        )
      else if (entry.kind == SharedResidualCaKind.birthSurvival) ...[
        FractalParameter(
          id: 'birthMask',
          label: (_) => 'Birth mask',
          type: FractalParamType.float,
          min: 0,
          max: 511,
          step: 1,
          defaultValue: entry.birthMask!,
        ),
        FractalParameter(
          id: 'survivalMask',
          label: (_) => 'Survival mask',
          type: FractalParamType.float,
          min: 0,
          max: 511,
          step: 1,
          defaultValue: entry.survivalMask!,
        ),
      ],
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, readDouble(state.params, 'iterations', 260));
      shader.setFloat(7, readDouble(state.params, 'bailout', 4.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      if (entry.kind == SharedResidualCaKind.cyclicStates) {
        shader.setFloat(10, readDouble(state.params, 'states', entry.states!));
      } else if (entry.kind == SharedResidualCaKind.birthSurvival) {
        shader.setFloat(
          10,
          readDouble(state.params, 'birthMask', entry.birthMask!),
        );
        shader.setFloat(
          11,
          readDouble(state.params, 'survivalMask', entry.survivalMask!),
        );
      }
    },
  );
}
