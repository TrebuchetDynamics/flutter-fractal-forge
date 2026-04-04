import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// MandlebrotSetSFML Research Collection - Part 1.
///
/// Open-source research fractals from the MandlebrotSetSFML project.
/// Novel escape-time formulas with unique dynamical properties.

final List<EscapeTimeConfig> mandlebrotSetSFML1Entries = [
  // Log-Rotation Mandelbrot: z_{n+1} = Rot(log|z|) * z^2 + c.
  // The squared orbit is rotated by log|z_n| before adding c.
  // Creates twisted, quasi-self-similar spirals unlike any standard set.
  EscapeTimeConfig(
    id: 'washed_away',
    name: 'Washed Away',
    shaderAsset: 'shaders/washed_away_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
  ),

  // Golden-Ratio Mandelbrot: z_{n+1} = |z|^φ * exp(i·φ·arg(z)) + c
  // where φ = (1+√5)/2 ≈ 1.618 (golden ratio).
  // Irrational exponent destroys all rotational symmetry → aperiodic geometry.
  EscapeTimeConfig(
    id: 'damaged_doublebrot',
    name: 'Damaged DoubleBrot',
    shaderAsset: 'shaders/damaged_doublebrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: -0.3,
    extraPresets: [
      FractalPreset(
        id: 'damaged-doublebrot-relief',
        moduleId: 'damaged_doublebrot',
        name: 'Damaged DoubleBrot Relief',
        params: {'iterations': 250, 'bailout': 8.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Perpendicular Celtic: z_{n+1} = Re(z^2) + i*|Im(z^2)| + c
  // Complement to Celtic — abs on the imaginary component instead of real,
  // producing different folding symmetry and distinct spiral arm geometry.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'perp_celtic',
    name: 'Perpendicular Celtic',
    shaderAsset: 'shaders/perp_celtic_gpu.frag',
    defaultIterations: 180,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-relief-jade',
        moduleId: 'perp_celtic',
        name: 'Bas-Relief: Jade',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Feather Fractal: z_{n+1} = z^3 / (1 + |z|^2) + c
  // The denominator damps large orbits, producing feather-like spiraling arms
  // with rich filament structure distinct from polynomial escape-time sets.
  EscapeTimeConfig(
    id: 'feather',
    name: 'Feather Fractal',
    shaderAsset: 'shaders/feather_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'feather-relief',
        moduleId: 'feather',
        name: 'Feather Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Cubic Burning Ship: z_{n+1} = (|Re(z)| + i·|Im(z)|)^3 + c
  // Extends the Burning Ship to power 3: richer 4-fold symmetric forms.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'burning_ship_cubic',
    name: 'Cubic Burning Ship',
    shaderAsset: 'shaders/burning_ship_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'burning-ship-cubic-relief',
        moduleId: 'burning_ship_cubic',
        name: 'Bas-Relief: Forge',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Celtic Cubic: z_{n+1} = |Re(z^3)| + i·Im(z^3) + c
  // Extends Celtic to power 3 — richer aperiodic structure from 3-fold symmetry
  // combined with the Celtic abs-fold. Supports normal-map shading (50-63).
  EscapeTimeConfig(
    id: 'celtic_cubic',
    name: 'Celtic Cubic',
    shaderAsset: 'shaders/celtic_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'celtic-cubic-relief',
        moduleId: 'celtic_cubic',
        name: 'Bas-Relief: Knot',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Mandelbrot Orbit Trap (Cross Trap)
  // Colors by minimum orbit distance to real/imaginary axes instead of escape
  // iteration count. Reveals rich banded structure in the classic black interior.
  EscapeTimeConfig(
    id: 'mandelbrot_orbit_trap',
    name: 'Mandelbrot Orbit Trap',
    shaderAsset: 'shaders/mandelbrot_orbit_trap_gpu.frag',
    defaultIterations: 300,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'orbit-trap-deep',
        moduleId: 'mandelbrot_orbit_trap',
        name: 'Deep Trap',
        params: {'iterations': 500, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.747, 0.1), zoom: 20.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_15',
    name: 'Multibrot d=1.5',
    shaderAsset: 'shaders/multibrot_15_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot15-relief',
        moduleId: 'multibrot_15',
        name: 'Half-Power Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perp_celtic_cubic',
    name: 'Perpendicular Celtic Cubic',
    shaderAsset: 'shaders/perp_celtic_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-cubic-relief',
        moduleId: 'perp_celtic_cubic',
        name: 'Fold Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_curvature_avg',
    name: 'Mandelbrot Curvature Avg',
    shaderAsset: 'shaders/mandelbrot_curvature_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'curvature-bands',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Bands',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'curvature-relief',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'julia_de',
    name: 'Julia DE Glow',
    shaderAsset: 'shaders/julia_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'julia-de-dragon',
        moduleId: 'julia_de',
        name: 'Dragon Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'julia-de-relief',
        moduleId: 'julia_de',
        name: 'Dragon Relief',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_de',
    name: 'Mandelbrot DE Glow',
    shaderAsset: 'shaders/mandelbrot_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'de-wireframe',
        moduleId: 'mandelbrot_de',
        name: 'Boundary Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'de-relief-glow',
        moduleId: 'mandelbrot_de',
        name: 'Relief Glow',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic',
    name: 'Tricorn Cubic',
    shaderAsset: 'shaders/tricorn_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-cubic-relief',
        moduleId: 'tricorn_cubic',
        name: 'Triple Horn',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_tia',
    name: 'Mandelbrot TIA',
    shaderAsset: 'shaders/mandelbrot_tia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'tia-organic',
        moduleId: 'mandelbrot_tia',
        name: 'Organic Flow',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 3},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'tia-relief',
        moduleId: 'mandelbrot_tia',
        name: 'TIA Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic',
    name: 'Buffalo Cubic',
    shaderAsset: 'shaders/buffalo_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-cubic-relief',
        moduleId: 'buffalo_cubic',
        name: 'Prairie Thunder',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_stripe_avg',
    name: 'Mandelbrot Stripe Average',
    shaderAsset: 'shaders/mandelbrot_stripe_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'stripe-freq8',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Dense Stripe',
        params: {'iterations': 300, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'stripe-relief',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Stripe Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp_julia',
    name: 'Perpendicular Ship Julia',
    shaderAsset: 'shaders/burning_ship_perp_julia_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-julia-relief',
        moduleId: 'burning_ship_perp_julia',
        name: 'Filament Julia Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_25',
    name: 'Multibrot d=2.5',
    shaderAsset: 'shaders/multibrot_25_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot25-relief',
        moduleId: 'multibrot_25',
        name: 'Two-and-Half Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp',
    name: 'Perpendicular Burning Ship',
    shaderAsset: 'shaders/burning_ship_perp_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-relief',
        moduleId: 'burning_ship_perp',
        name: 'Filament Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.5, -0.5), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
];
