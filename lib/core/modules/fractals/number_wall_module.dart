import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:vector_math/vector_math_64.dart';

const _sequences = <String, NumberWallSequence>{
  'signedPagoda': NumberWallSequence.signedPagoda,
  'rook': NumberWallSequence.rook,
  'thueMorse': NumberWallSequence.thueMorse,
  'rudinShapiro': NumberWallSequence.rudinShapiro,
  'fibonacci': NumberWallSequence.fibonacci,
  'squares': NumberWallSequence.squares,
};

/// The single editable Number Walls module; source choices are parameter
/// variants, not separate claims of independent fractal formulae.
FractalModule buildNumberWallModule() {
  FractalPreset preset(String id, String name, String source, String prime) =>
      FractalPreset(
        id: id,
        moduleId: 'number_wall',
        name: name,
        params: {
          'source': source,
          'prime': prime,
          'columns': 96,
          'rows': 32,
          'columnStart': 64,
          'colorMode': 0,
          'colorScheme': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.utc(2026),
        isBuiltIn: true,
      );

  final presets = <FractalPreset>[
    preset('pagoda-2', 'Pagoda mod 2', 'signedPagoda', '2'),
    preset('pagoda-3', 'Pagoda mod 3', 'signedPagoda', '3'),
    preset('rook-2', 'Rook mod 2', 'rook', '2'),
    preset('thue-morse-2', 'Thue–Morse mod 2', 'thueMorse', '2'),
    preset('fibonacci-2', 'Fibonacci mod 2', 'fibonacci', '2'),
    preset('squares-2', 'Squares mod 2', 'squares', '2'),
  ];
  final labels = <String, String Function(AppLocalizations)>{
    'signedPagoda': (l10n) => l10n.numberWallSignedPagoda,
    'rook': (l10n) => l10n.numberWallRook,
    'thueMorse': (l10n) => l10n.numberWallThueMorse,
    'rudinShapiro': (l10n) => l10n.numberWallRudinShapiro,
    'fibonacci': (l10n) => l10n.numberWallFibonacci,
    'squares': (l10n) => l10n.numberWallSquares,
  };

  return FractalModule(
    id: 'number_wall',
    displayName: (l10n) => l10n.numberWalls,
    dimension: FractalDimension.twoD,
    animationCapability: FractalAnimationCapability.static,
    shaderAsset: 'shaders/number_theory/number_wall_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'source',
        label: (l10n) => l10n.numberWallSource,
        type: FractalParamType.enumeration,
        min: 0,
        max: 5,
        step: 1,
        defaultValue: 'signedPagoda',
        options: [
          for (final entry in _sequences.entries)
            FractalParamOption(value: entry.key, label: labels[entry.key]!),
        ],
      ),
      FractalParameter(
        id: 'prime',
        label: (l10n) => l10n.numberWallPrime,
        type: FractalParamType.decimalInteger,
        min: 0,
        max: 0,
        step: 1,
        defaultValue: '2',
      ),
      FractalParameter(
        id: 'columns',
        label: (l10n) => l10n.numberWallColumns,
        type: FractalParamType.integer,
        min: 16,
        max: 256,
        step: 1,
        defaultValue: 96,
      ),
      FractalParameter(
        id: 'rows',
        label: (l10n) => l10n.numberWallRows,
        type: FractalParamType.integer,
        min: 4,
        max: 64,
        step: 1,
        defaultValue: 32,
      ),
      FractalParameter(
        id: 'columnStart',
        label: (l10n) => l10n.numberWallOrigin,
        type: FractalParamType.integer,
        min: 3,
        max: 1000000,
        step: 1,
        defaultValue: 64,
      ),
      CommonFractalParams.colorScheme64(),
      for (final entry in const {
        'foregroundColor': 0x20283b,
        'zeroColor': 0xf4c95d,
        'backgroundColor': 0x090b12,
      }.entries)
        FractalParameter(
          id: entry.key,
          label: (l10n) => switch (entry.key) {
            'foregroundColor' => l10n.numberWallForeground,
            'zeroColor' => l10n.numberWallZero,
            _ => l10n.numberWallBackground,
          },
          type: FractalParamType.integer,
          min: 0,
          max: 0xffffff,
          step: 1,
          defaultValue: entry.value,
        ),
      FractalParameter(
        id: 'showGrid',
        label: (l10n) => l10n.numberWallGrid,
        type: FractalParamType.boolean,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: false,
      ),
      FractalParameter(
        id: 'randomizeModulus',
        label: (l10n) => l10n.numberWallRandomizeModulus,
        type: FractalParamType.boolean,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: false,
      ),
      FractalParameter(
        id: 'randomSeed',
        label: (l10n) => l10n.numberWallSeed,
        type: FractalParamType.integer,
        min: 0,
        max: 0x7fffffff,
        step: 1,
        defaultValue: 0,
      ),
      FractalParameter(
        id: 'colorMode',
        label: (l10n) => l10n.numberWallColorMode,
        type: FractalParamType.enumeration,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: 0, label: (l10n) => l10n.numberWallWindows),
          FractalParamOption(
              value: 1, label: (l10n) => l10n.numberWallResidues),
        ],
      ),
    ],
    defaultPreset: presets.first,
    builtInPresets: presets,
    setUniforms: (shader, state, size, time) {},
  );
}

NumberWallSequence numberWallSequenceFromParameter(Object? value) =>
    _sequences[value] ?? NumberWallSequence.signedPagoda;
