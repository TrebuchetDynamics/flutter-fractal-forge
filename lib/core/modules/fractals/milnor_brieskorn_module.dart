import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math_64.dart';

FractalModule buildMilnorBrieskornModule() => buildEscapeTimeModule(
      EscapeTimeConfig(
        id: 'milnor_brieskorn',
        name: 'Milnor — Brieskorn Orbit (Inspired)',
        displayName: (l) => l.moduleMilnorBrieskorn,
        shaderAsset: 'shaders/escape_time_family/milnor_brieskorn_gpu.frag',
        defaultIterations: 400,
        maxIterations: 500,
        defaultBailout: 4,
        defaultColorScheme: 1,
        defaultCenterX: -.45,
        defaultCenterY: 0,
        defaultZoom: .65,
        extraPresets: [
          catalogPreset(
            id: 'milnor_brieskorn-close-up',
            moduleId: 'milnor_brieskorn',
            name: 'Close-up',
            params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 2},
            view: FractalViewState.initial().copyWith(
              pan: Vector2(-.5, .06),
              zoom: 2.2,
            ),
          ),
        ],
      ),
    );
