// GENERATED — reviewed KIFS/Menger renderer promotions.
// Source: research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedKifsMengerCatalogEntry {
  final String id;
  final String name;
  final double fractalType;

  const SharedKifsMengerCatalogEntry({
    required this.id,
    required this.name,
    required this.fractalType,
  });
}

const List<SharedKifsMengerCatalogEntry> sharedKifsMengerCatalogEntries = [
  SharedKifsMengerCatalogEntry(
    id: 'f0594_menger_sponge_3d',
    name: 'Menger Sponge 3D',
    fractalType: 0.0,
  ),
  SharedKifsMengerCatalogEntry(
    id: 'f0597_sierpinski_carpet_3d_menger_cross',
    name: 'Sierpinski Carpet 3D / Menger Cross',
    fractalType: 1.0,
  ),
];

List<FractalModule> buildSharedKifsMengerCatalogModules() =>
    sharedKifsMengerCatalogEntries
        .map(_buildSharedKifsMengerModule)
        .toList(growable: false);

FractalModule _buildSharedKifsMengerModule(SharedKifsMengerCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'power': 3.0,
      'iterations': 12,
      'steps': 120,
      'bailout': 4.0,
      'colorScheme': 0,
      'fractalType': entry.fractalType,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3(0.3, -0.4, 0.0),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.threeD,
    shaderAsset: 'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'power',
        label: (_) => 'Scale',
        type: FractalParamType.float,
        min: 1.5,
        max: 5.0,
        step: 0.1,
        defaultValue: 3.0,
      ),
      CommonFractalParams.iterations(defaultValue: 12, min: 4, max: 20),
      FractalParameter(
        id: 'steps',
        label: (l10n) => l10n.paramSteps,
        type: FractalParamType.integer,
        min: 20,
        max: 200,
        step: 1,
        defaultValue: 120,
      ),
      CommonFractalParams.bailout(defaultValue: 4.0, min: 1.0, max: 8.0),
      CommonFractalParams.colorScheme4(defaultValue: 0),
      FractalParameter(
        id: 'fractalType',
        label: (_) => 'Fractal Type',
        type: FractalParamType.integer,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: entry.fractalType,
      ),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, 0.0);
      shader.setFloat(4, 0.0);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, state.view.rotation.x);
      shader.setFloat(7, state.view.rotation.y);
      shader.setFloat(8, state.view.rotation.z);
      shader.setFloat(9, readDouble(state.params, 'power', 3.0));
      shader.setFloat(10, readDouble(state.params, 'iterations', 12));
      shader.setFloat(11, readDouble(state.params, 'steps', 120));
      shader.setFloat(12, readDouble(state.params, 'bailout', 4.0));
      shader.setFloat(13, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(
        14,
        readDouble(state.params, 'fractalType', entry.fractalType),
      );
      shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
