import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/perron_tree_model.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

FractalModule buildPerronTreeModule() {
  const id = 'perron_tree';
  const defaults = <String, Object>{
    'depth': 5.0,
    'overlap': .8,
    'angle': 0.0,
    'glow': .7,
    'style': 1,
    'hue': 0.0
  };
  PerronTree? cached;
  return FractalModule(
    id: id,
    displayName: (l10n) => l10n.modulePerronTree,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/ifs_and_geometric/perron_tree_gpu.frag',
    parameters: [
      FractalParameter(
          type: FractalParamType.integer,
          id: 'depth',
          label: (l) => l.perronDepth,
          min: 0,
          max: 5,
          defaultValue: 5,
          step: 1),
      FractalParameter(
          type: FractalParamType.float,
          id: 'overlap',
          label: (l) => l.perronOverlap,
          min: .5,
          max: 1,
          defaultValue: .8,
          step: .01),
      FractalParameter(
          type: FractalParamType.float,
          id: 'angle',
          label: (l) => l.perronAngle,
          min: 0,
          max: 360,
          defaultValue: 0,
          step: 1),
      FractalParameter(
          type: FractalParamType.float,
          id: 'glow',
          label: (l) => l.perronGlow,
          min: 0,
          max: 1,
          defaultValue: .7,
          step: .01),
      FractalParameter(
          type: FractalParamType.enumeration,
          id: 'style',
          min: 0,
          max: 1,
          step: 1,
          label: (l) => l.perronStyle,
          defaultValue: 1,
          options: [
            FractalParamOption(value: 0, label: (l) => l.perronGeometric),
            FractalParamOption(value: 1, label: (l) => l.perronLuminous)
          ]),
      FractalParameter(
          type: FractalParamType.float,
          id: 'hue',
          label: (l) => l.perronHue,
          min: 0,
          max: 1,
          defaultValue: 0,
          step: .01),
    ],
    defaultPreset: catalogPreset(
        id: '$id-default',
        moduleId: id,
        name: 'Luminous',
        params: defaults,
        view: FractalViewState.initial().copyWith(zoom: 1.25)),
    builtInPresets: [
      catalogPreset(
          id: '$id-luminous',
          moduleId: id,
          name: 'Luminous',
          params: defaults,
          view: FractalViewState.initial().copyWith(zoom: 1.25)),
      catalogPreset(
          id: '$id-geometric',
          moduleId: id,
          name: 'Geometric',
          params: {...defaults, 'style': 0.0, 'glow': 0.0},
          view: FractalViewState.initial().copyWith(zoom: 1.25))
    ],
    setUniforms: (shader, state, size, time) {
      double value(String key, double fallback, double low, double high) {
        final raw = state.params[key];
        final number = raw is num ? raw.toDouble() : fallback;
        return number.isFinite ? number.clamp(low, high) : fallback;
      }

      final depth = value('depth', 5, 0, 5).round();
      final overlap = value('overlap', .8, .5, 1);
      var tree = cached;
      if (tree == null || tree.depth != depth || tree.overlap != overlap) {
        tree = PerronTree(depth: depth, overlap: overlap);
        cached = tree;
      }
      var i = 0;
      void put(double v) => shader.setFloat(i++, v);
      put(time);
      put(size.width);
      put(size.height);
      put(state.view.pan.x);
      put(state.view.pan.y);
      put(state.view.zoom);
      put(tree.leafCount.toDouble());
      put(tree.centerY);
      put(value('angle', 0, 0, 360));
      put(value('glow', .7, 0, 1));
      put(value('style', 1, 0, 1).roundToDouble());
      put(value('hue', 0, 0, 1));
      put(state.transparentBackground ? 1.0 : 0.0);
      for (var leaf = 0; leaf < 32; leaf++) {
        put(leaf < tree.leafCount ? tree.offsets[leaf] + tree.centerX : 0);
      }
    },
  );
}
