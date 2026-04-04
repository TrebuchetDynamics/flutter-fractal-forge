import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Cellular Automata and Stochastic Growth Fractals.
///
/// Discrete computational systems including Wolfram rules,
/// Langton's Ant, Turmites, and diffusion-limited aggregation.

final List<EscapeTimeConfig> cellularAutomataEntries = [
  EscapeTimeConfig(
    id: 'wolfram_rule30',
    name: 'Wolfram Rule 30',
    shaderAsset: 'shaders/wolfram_rule30_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'langton_ant',
    name: "Langton's Ant",
    shaderAsset: 'shaders/langton_ant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'turmite',
    name: 'Turmite',
    shaderAsset: 'shaders/turmite_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'wireworld',
    name: 'Wireworld',
    shaderAsset: 'shaders/wireworld_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sandpile',
    name: 'Abelian Sandpile',
    shaderAsset: 'shaders/sandpile_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'dla',
    name: 'DLA (Approximation)',
    shaderAsset: 'shaders/dla_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'forest_fire',
    name: 'Forest Fire Model',
    shaderAsset: 'shaders/forest_fire_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'percolation',
    name: 'Percolation Cluster',
    shaderAsset: 'shaders/percolation_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'brian_brain',
    name: "Brian's Brain",
    shaderAsset: 'shaders/brian_brain_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'highlife',
    name: 'HighLife',
    shaderAsset: 'shaders/highlife_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'day_night',
    name: 'Day & Night',
    shaderAsset: 'shaders/day_night_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'eden_growth',
    name: 'Eden Growth Model',
    shaderAsset: 'shaders/eden_growth_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),

  // All remaining fractals already registered by subagent batches above.

  EscapeTimeConfig(
    id: 'farey_diagram',
    name: 'Farey Diagram',
    shaderAsset: 'shaders/farey_diagram_gpu.frag',
    defaultIterations: 140,
    defaultCenterX: 0.0,
    defaultCenterY: 0.2,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cayley_graph',
    name: 'Cayley Graph Fractal',
    shaderAsset: 'shaders/cayley_graph_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_arrowhead',
    name: 'Sierpinski Arrowhead',
    shaderAsset: 'shaders/sierpinski_arrowhead_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mcworter_pentigree',
    name: "McWorter's Pentigree",
    shaderAsset: 'shaders/mcworter_pentigree_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'ammann_beenker',
    name: 'Ammann-Beenker Tiling',
    shaderAsset: 'shaders/ammann_beenker_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'moore_curve',
    name: 'Moore Curve',
    shaderAsset: 'shaders/moore_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_w',
    name: 'Lambda W Fractal',
    shaderAsset: 'shaders/lambda_w_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'lambda_w-relief',
        moduleId: 'lambda_w',
        name: 'Lambert W Relief',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'riemann_zeta',
    name: 'Riemann Zeta Fractal',
    shaderAsset: 'shaders/zeta_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'riemann_zeta-relief',
        moduleId: 'riemann_zeta',
        name: 'Zeta Relief',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manair_fire',
    name: 'Man-Air-Fire',
    shaderAsset: 'shaders/manair_fire_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'spider_x',
    name: 'Spider-X',
    shaderAsset: 'shaders/spider_x_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'spider_x-relief',
        moduleId: 'spider_x',
        name: 'Spider Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn2',
    name: 'Popcorn II',
    shaderAsset: 'shaders/popcorn2_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'chebyshev',
    name: 'Chebyshev Fractal',
    shaderAsset: 'shaders/chebyshev_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
    extraPresets: [
      FractalPreset(
        id: 'chebyshev-relief',
        moduleId: 'chebyshev',
        name: 'Chebyshev Relief',
        params: {'iterations': 140, 'bailout': 6.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'legendre',
    name: 'Legendre Fractal',
    shaderAsset: 'shaders/legendre_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'laguerre',
    name: 'Laguerre Fractal',
    shaderAsset: 'shaders/laguerre_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hermite',
    name: 'Hermite Fractal',
    shaderAsset: 'shaders/hermite_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'virial',
    name: 'Virial Fractal',
    shaderAsset: 'shaders/virial_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'virial-relief',
        moduleId: 'virial',
        name: 'Virial Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'newton_sin',
    name: 'Newton sin(z)',
    shaderAsset: 'shaders/newton_sin_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_general',
    name: 'Newton Fractal (z⁴ - 1)',
    shaderAsset: 'shaders/newton_general_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot4',
    name: 'Multibrot d=4',
    shaderAsset: 'shaders/multibrot4_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'multibrot4-relief-quad',
        moduleId: 'multibrot4',
        name: 'Bas-Relief: Quad',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot5',
    name: 'Multibrot d=5',
    shaderAsset: 'shaders/multibrot5_gpu.frag',
    defaultIterations: 170,
    extraPresets: [
      FractalPreset(
        id: 'multibrot5-relief-quint',
        moduleId: 'multibrot5',
        name: 'Bas-Relief: Quint',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sierpinski_tetrahedron',
    name: 'Sierpinski Tetrahedron (2D Projection)',
    shaderAsset: 'shaders/sierpinski_tetrahedron_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'jerusalem_cube',
    name: 'Jerusalem Cube (2D Cross-Section)',
    shaderAsset: 'shaders/jerusalem_cube_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'menger_3d_slice',
    name: 'Menger Sponge (3D Slice)',
    shaderAsset: 'shaders/menger_3d_slice_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pola_sierpinski',
    name: 'Pola-Sierpinski Hybrid',
    shaderAsset: 'shaders/pola_sierpinski_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fibonacci_spiral',
    name: 'Fibonacci Spiral Fractal',
    shaderAsset: 'shaders/fibonacci_spiral_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
];
