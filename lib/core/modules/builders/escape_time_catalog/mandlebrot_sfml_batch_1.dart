part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _mandlebrotSfmlBatch1Catalog = [
// ── From MandlebrotSetSFML open-source research ──────────────────────────

// Log-Rotation Mandelbrot: z_{n+1} = Rot(log|z|) * z^2 + c.
// The squared orbit is rotated by log|z_n| before adding c.
// Creates twisted, quasi-self-similar spirals unlike any standard set.
  EscapeTimeConfig(
    id: 'washed_away',
    name: 'Washed Away',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/polynomial_variants/washed_away_gpu.frag',
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
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/damaged_doublebrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: -0.3,
    extraPresets: [
      catalogPreset(
        id: 'damaged-doublebrot-relief',
        moduleId: 'damaged_doublebrot',
        name: 'Damaged DoubleBrot Relief',
        params: {'iterations': 250, 'bailout': 8.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Perpendicular Celtic: z_{n+1} = |Re(z^2)| - i*2|Re(z)|Im(z) + c.
  EscapeTimeConfig(
    id: 'perp_celtic',
    name: 'Perpendicular Celtic',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/perp_celtic_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.35,
    defaultZoom: 0.35,
    extraPresets: [
      catalogPreset(
        id: 'perp-celtic-relief-jade',
        moduleId: 'perp_celtic',
        name: 'Bas-Relief: Jade',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Requested folded variants from the standard Mandelbrot derivatives family.
  EscapeTimeConfig(
    id: 'celtic_mandelbar',
    name: 'Celtic Mandelbar',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_mandelbar_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.45,
    defaultZoom: 0.35,
  ),
  EscapeTimeConfig(
    id: 'celtic_heart',
    name: 'Celtic Heart',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_heart_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
  ),
  EscapeTimeConfig(
    id: 'perp_buffalo',
    name: 'Perpendicular Buffalo',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/perp_buffalo_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.35,
    defaultCenterY: -0.1,
    defaultZoom: 0.35,
  ),

// Feather Fractal: z_{n+1} = z^3 / (1 + |z|^2) + c
// The denominator damps large orbits, producing feather-like spiraling arms
// with rich filament structure distinct from polynomial escape-time sets.
  EscapeTimeConfig(
    id: 'feather',
    name: 'Feather Fractal',
    shaderAsset: 'shaders/escape_time_family/julia_variants/feather_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'feather-relief',
        moduleId: 'feather',
        name: 'Feather Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Cubic Burning Ship: z_{n+1} = (|Re(z)| + i·|Im(z)|)^3 + c
// Extends the Burning Ship to power 3: richer 4-fold symmetric forms.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'burning_ship_cubic',
    name: 'Cubic Burning Ship',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'burning-ship-cubic-relief',
        moduleId: 'burning_ship_cubic',
        name: 'Bas-Relief: Forge',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Celtic Cubic: z_{n+1} = |Re(z^3)| + i·Im(z^3) + c
// Extends Celtic to power 3 — richer aperiodic structure from 3-fold symmetry
// combined with the Celtic abs-fold. Supports normal-map shading (50-63).
  EscapeTimeConfig(
    id: 'celtic_cubic',
    name: 'Celtic Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'celtic-cubic-relief',
        moduleId: 'celtic_cubic',
        name: 'Bas-Relief: Knot',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Mandelbrot Orbit Trap (Cross Trap)
// Colors by minimum orbit distance to real/imaginary axes instead of escape
// iteration count. Reveals rich banded structure in the classic black interior.
  EscapeTimeConfig(
    id: 'mandelbrot_orbit_trap',
    name: 'Mandelbrot Orbit Trap',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
    defaultIterations: 300,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraParams: [
      FractalParameter(
        id: 'trapMode',
        label: (_) => 'Trap Mode',
        type: FractalParamType.integer,
        min: 0,
        max: 24,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'orbit-trap-deep',
        moduleId: 'mandelbrot_orbit_trap',
        name: 'Deep Trap',
        params: {'iterations': 500, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.747, 0.1), zoom: 20.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_15',
    name: 'Multibrot d=1.5',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot_15_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'multibrot15-relief',
        moduleId: 'multibrot_15',
        name: 'Half-Power Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perp_celtic_cubic',
    name: 'Perpendicular Celtic Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/perp_celtic_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'perp-celtic-cubic-relief',
        moduleId: 'perp_celtic_cubic',
        name: 'Fold Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_curvature_avg',
    name: 'Mandelbrot Curvature Avg',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_curvature_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'curvature-bands',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Bands',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'curvature-relief',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'julia_de',
    name: 'Julia DE Glow',
    shaderAsset: 'shaders/escape_time_family/julia_variants/julia_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'julia-de-dragon',
        moduleId: 'julia_de',
        name: 'Dragon Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'julia-de-relief',
        moduleId: 'julia_de',
        name: 'Dragon Relief',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_de',
    name: 'Mandelbrot DE Glow',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'de-wireframe',
        moduleId: 'mandelbrot_de',
        name: 'Boundary Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'de-relief-glow',
        moduleId: 'mandelbrot_de',
        name: 'Relief Glow',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic',
    name: 'Tricorn Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'tricorn-cubic-relief',
        moduleId: 'tricorn_cubic',
        name: 'Triple Horn',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_tia',
    name: 'Mandelbrot TIA',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_tia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'tia-organic',
        moduleId: 'mandelbrot_tia',
        name: 'Organic Flow',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 3},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'tia-relief',
        moduleId: 'mandelbrot_tia',
        name: 'TIA Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic',
    name: 'Buffalo Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'buffalo-cubic-relief',
        moduleId: 'buffalo_cubic',
        name: 'Prairie Thunder',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_stripe_avg',
    name: 'Mandelbrot Stripe Average',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_stripe_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'stripe-freq8',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Dense Stripe',
        params: {'iterations': 300, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'stripe-relief',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Stripe Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp_julia',
    name: 'Perpendicular Ship Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_perp_julia_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'perp-ship-julia-relief',
        moduleId: 'burning_ship_perp_julia',
        name: 'Filament Julia Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_25',
    name: 'Multibrot d=2.5',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot_25_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'multibrot25-relief',
        moduleId: 'multibrot_25',
        name: 'Two-and-Half Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp',
    name: 'Perpendicular Burning Ship',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_perp_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'perp-ship-relief',
        moduleId: 'burning_ship_perp',
        name: 'Filament Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.5, -0.5), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
];
