// GENERATED — systematic Life-like B/S cellular automaton rule catalog.
// Counts deterministic birth/survival rule identities, not presets or seeds.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

const int sharedLifeLikeTotalRuleSpace = 512 * 512;

// Promoted subset size is target-bounded for the 5k-10k curated catalog goal.
// The remaining valid B/S rules are generated-family capacity, not counted
// catalog entries by default.
const int sharedLifeLikeCatalogSize = 18;

class SharedLifeLikeCatalogEntry {
  final String id;
  final String name;
  final double birthMask;
  final double survivalMask;

  const SharedLifeLikeCatalogEntry({
    required this.id,
    required this.name,
    required this.birthMask,
    required this.survivalMask,
  });
}

List<SharedLifeLikeCatalogEntry> get sharedLifeLikeCatalogEntries =>
    List<SharedLifeLikeCatalogEntry>.generate(
      sharedLifeLikeCatalogSize,
      (index) {
        final birthMask = index % 512;
        final survivalMask = index ~/ 512;
        final id = 'life_like_b${birthMask.toString().padLeft(3, '0')}'
            '_s${survivalMask.toString().padLeft(3, '0')}';
        return SharedLifeLikeCatalogEntry(
          id: id,
          name: 'Life-like B$birthMask/S$survivalMask',
          birthMask: birthMask.toDouble(),
          survivalMask: survivalMask.toDouble(),
        );
      },
      growable: false,
    );

List<FractalModule> buildSharedLifeLikeCatalogModules() =>
    sharedLifeLikeCatalogEntries
        .map(_buildSharedLifeLikeModule)
        .toList(growable: false);

FractalModule _buildSharedLifeLikeModule(SharedLifeLikeCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 240,
      'bailout': 4.0,
      'colorScheme': 0,
      'birthMask': entry.birthMask,
      'survivalMask': entry.survivalMask,
    },
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
    shaderAsset: 'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 240),
      CommonFractalParams.bailout(defaultValue: 4.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      FractalParameter(
        id: 'birthMask',
        label: (_) => 'Birth mask',
        type: FractalParamType.integer,
        min: 0,
        max: 511,
        step: 1,
        defaultValue: entry.birthMask,
      ),
      FractalParameter(
        id: 'survivalMask',
        label: (_) => 'Survival mask',
        type: FractalParamType.integer,
        min: 0,
        max: 511,
        step: 1,
        defaultValue: entry.survivalMask,
      ),
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
      shader.setFloat(6, readDouble(state.params, 'iterations', 240));
      shader.setFloat(7, readDouble(state.params, 'bailout', 4.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(
          10, readDouble(state.params, 'birthMask', entry.birthMask));
      shader.setFloat(
        11,
        readDouble(state.params, 'survivalMask', entry.survivalMask),
      );
    },
  );
}
