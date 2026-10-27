import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'fractal_module.dart';

/// Legacy degree-only identities retained for saved presets, favorites and links.
const burningShipDegrees = <String, double>{
  'burning_ship_cubic': 3,
  'burning_ship_power4': 4,
  'burning_ship_power5': 5,
  'burning_ship_power6': 6,
  'burning_ship_power7': 7,
  'f0113_burning_ship_d_7': 7,
  'f0114_burning_ship_d_8': 8,
  'f0115_burning_ship_d_9': 9,
  'f0116_burning_ship_d_10': 10,
  'f0117_burning_ship_d_11': 11,
  'f0118_burning_ship_d_12': 12,
  'f0140_burning_ship_z_2_5': 2.5,
  'f0141_burning_ship_z_1_5': 1.5,
};

/// Old fixed power4–7 shaders used mathematical Y rather than screen-pan Y.
FractalViewState burningShipDegreeView(String moduleId, FractalViewState view) {
  if (!const {
    'burning_ship_power4',
    'burning_ship_power5',
    'burning_ship_power6',
    'burning_ship_power7',
  }.contains(moduleId)) return view;
  final pan = view.pan;
  pan.y = -pan.y;
  return view.copyWith(pan: pan);
}

FractalModule withBurningShipDegreePresets(
    FractalModule ship, List<FractalModule> modules) {
  return FractalModule(
    id: ship.id,
    displayName: ship.displayName,
    dimension: ship.dimension,
    animationCapability: ship.animationCapability,
    shaderAsset: ship.shaderAsset,
    parameters: ship.parameters,
    defaultPreset: ship.defaultPreset,
    builtInPresets: [
      ...ship.builtInPresets,
      for (final module in modules)
        if (burningShipDegrees[module.id] case final power?)
          module.defaultPreset.copyWith(
            id: '${module.id}-degree',
            moduleId: ship.id,
            name: 'Burning Ship d=$power',
            params: {...module.defaultPreset.params, 'power': power},
            view: burningShipDegreeView(module.id, module.defaultPreset.view),
          ),
    ],
    setUniforms: ship.setUniforms,
  );
}
