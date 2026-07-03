part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _mandlebrotSfmlBatch2Catalog = [
// ── MandlebrotSetSFML batch 2 — 8 more unique formulas ──────────────────

// Prison fractal: w=(sin x, sin y);  z_{n+1} = w² + c.
// Component-wise sin then complex-square; creates banded prison-bar-like
// structures in Julia space. Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'prison',
    name: 'Prison',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/rational_singularities/prison_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'prison-relief',
        moduleId: 'prison',
        name: 'Prison Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Crazybrot: z_{n+1} = 1/z + c  (complex inversion).
// Maps exterior to interior, producing "ball" structures at the origin.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'crazybrot',
    name: 'Crazybrot',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/crazybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'crazybrot-relief',
        moduleId: 'crazybrot',
        name: 'Crazybrot Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Eaten fractal: a=z²;  z_{n+1} = a + c/(a+0.1).
// The 0.1 offset prevents the singularity at z²=0, creating "eaten" notches.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'eaten',
    name: 'Eaten',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/rational_singularities/eaten_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 6.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'eaten-relief',
        moduleId: 'eaten',
        name: 'Eaten Relief',
        params: {'iterations': 280, 'bailout': 6.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Polar Cowlick: r=|z|; θ=arg(z); z_{n+1} = sin(3r)·exp(i(θ+r)) + c.
// Three radial sin-folds combined with an angular rotation by r itself.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'polar_cowlick',
    name: 'Polar Cowlick',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/polynomial_variants/polar_cowlick_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'polar-cowlick-relief',
        moduleId: 'polar_cowlick',
        name: 'Cowlick Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Vase fractal: F(z) = z^{1−i} + c = exp((1−i)·log z) + c.
// Complex power (1−i) simultaneously scales and rotates, creating 3D-like
// vase shapes especially visible in Julia views.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'vase',
    name: 'Vase',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/rational_singularities/vase_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'vase-relief',
        moduleId: 'vase',
        name: 'Vase Relief',
        params: {'iterations': 220, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// LightningBrot: z_{n+1} = z² + cos(arg z) · c.
// The constant c is modulated by cos(angle of z), fading in/out with orbit
// direction and creating lightning-bolt-shaped Julia sets.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'lightningbrot',
    name: 'LightningBrot',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/lightningbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'lightningbrot-relief',
        moduleId: 'lightningbrot',
        name: 'Lightning Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Angrybrot: z_{n+1} = (atan(x)²−atan(y)², 2·atan(x)·y) + c.
// Real atan compresses axes nonlinearly (saturates at ±π/2), producing a
// sharper, more "aggressive" Mandelbrot variant with spiky filaments.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'angrybrot',
    name: 'Angrybrot',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/angrybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.3,
    extraPresets: [
      catalogPreset(
        id: 'angrybrot-relief',
        moduleId: 'angrybrot',
        name: 'Angry Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Singularity fractal: z_{n+1} = (x²−y²+c_x,  2·c_x·y + c_y).
// The imaginary update uses c_x (not x_n), creating unusual coupling:
// near c_x=0 the set collapses; near |c_x|=1 it tilts like Mandelbrot.
// Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'singularity',
    name: 'Singularity',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/rational_singularities/singularity_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'singularity-relief',
        moduleId: 'singularity',
        name: 'Singularity Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// z² + c/(z+0.01) — offset denominator creates deep spiral arms reminiscent
// of galaxy structures; avoids true singularity at z=0.
  EscapeTimeConfig(
    id: 'space_fractal',
    name: 'Space Fractal',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/rational_singularities/space_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'space-fractal-relief',
        moduleId: 'space_fractal',
        name: 'Space Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Component-wise tan(z²+c) — tan singularities slice the plane into many
// near-copies of the base fractal, creating a "field of contused fractals".
  EscapeTimeConfig(
    id: 'contused_fields',
    name: 'Contused Fields',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/polynomial_variants/contused_fields_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'contused-fields-relief',
        moduleId: 'contused_fields',
        name: 'Contused Fields Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Rot(|z|)·sinh(z)+c — hyperbolic geometry rotated by its own magnitude;
// creates road-like tunnel structures with distinctive symmetry.
  EscapeTimeConfig(
    id: 'car_road',
    name: 'Car Road',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/physical_simulation/car_road_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'car-road-relief',
        moduleId: 'car_road',
        name: 'Car Road Relief',
        params: {'iterations': 260, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// z²+sin(z·c)+cos(z+c) — three additive terms create a set split into
// halves with thin filaments resembling bullets shot through the fractal.
  EscapeTimeConfig(
    id: 'bullet_shot',
    name: 'Bullet Shot',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/polynomial_variants/bullet_shot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'bullet-shot-relief',
        moduleId: 'bullet_shot',
        name: 'Bullet Shot Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// sin(z)+c — complex sine in Mandelbrot mode; spiral arms shaped by the
// cosh stretching of the imaginary axis, distinct from the cosine variant.
  EscapeTimeConfig(
    id: 'sine_mandelbrot',
    name: 'Sine Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraParams: [
      FractalParameter(
        id: 'variant',
        label: (_) => 'Variant',
        type: FractalParamType.integer,
        min: 0,
        max: 16,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'sine-mandelbrot-relief',
        moduleId: 'sine_mandelbrot',
        name: 'Sine Mandelbrot Relief',
        params: {'iterations': 260, 'bailout': 10.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// √π·z²+c — standard Mandelbrot scaled by √π ≈ 1.7724; the extra factor
// stretches escape basins and produces elongated drill-bit filaments.
  EscapeTimeConfig(
    id: 'drill',
    name: 'Drill Fractal',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/polynomial_variants/drill_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: 'drill-relief',
        moduleId: 'drill',
        name: 'Drill Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// |z|²·z+c — each component scaled by squared magnitude; non-analytic map
// with cubic radial growth; Julia sets appear to have pseudo-3D depth.
  EscapeTimeConfig(
    id: '3d_fractal',
    name: '3D Fractal',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/3d_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultColorScheme: 59,
    defaultCenterX: -0.5,
    extraPresets: [
      catalogPreset(
        id: '3d-fractal-relief',
        moduleId: '3d_fractal',
        name: '3D Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// cos(z²+c) — complex cosine applied to the Mandelbrot step; cosh growth
// creates white "undefined" regions where the orbit diverges via cosh blow-up.
  EscapeTimeConfig(
    id: 'undefined',
    name: 'Undefined Fractal',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/undefined_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'undefined-relief',
        moduleId: 'undefined',
        name: 'Undefined Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),

// Sprott B (1994) — dx=yz, dy=x-y, dz=1-xy. Single-scroll attractor.
  EscapeTimeConfig(
    id: 'sprott_b',
    name: 'Sprott Case B',
    shaderAsset: 'shaders/strange_attractors/sprott_b_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Sprott C (1994) — dx=yz, dy=x-y, dz=1-x². Double-lobe attractor.
  EscapeTimeConfig(
    id: 'sprott_c',
    name: 'Sprott Case C',
    shaderAsset: 'shaders/strange_attractors/sprott_c_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Sprott D (1994) — dx=-y, dy=x+z, dz=xz+3y². Three-wing attractor.
  EscapeTimeConfig(
    id: 'sprott_d',
    name: 'Sprott Case D',
    shaderAsset: 'shaders/strange_attractors/sprott_d_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Sprott E (1994) — dx=yz, dy=x²-y, dz=1-4x. Figure-eight cross-section.
  EscapeTimeConfig(
    id: 'sprott_e',
    name: 'Sprott Case E',
    shaderAsset: 'shaders/strange_attractors/sprott_e_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Sprott F (1994) — dx=y+z, dy=-x+y/2, dz=x²-z. C-shaped single-scroll.
  EscapeTimeConfig(
    id: 'sprott_f',
    name: 'Sprott Case F',
    shaderAsset: 'shaders/strange_attractors/sprott_f_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Rucklidge (1992) — κ=2, λ=6.7; magnetoconvection model with spiral lobes.
  EscapeTimeConfig(
    id: 'rucklidge',
    name: 'Rucklidge Attractor',
    shaderAsset: 'shaders/strange_attractors/rucklidge_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Shimizu-Morioka (1980) — a=0.75, b=0.45; period-doubling route to chaos.
  EscapeTimeConfig(
    id: 'shimizu_morioka',
    name: 'Shimizu-Morioka Attractor',
    shaderAsset: 'shaders/strange_attractors/shimizu_morioka_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

// Chen-Lee (2004) — a=5, b=-10, c=-0.38; gyroscope rigid-body dynamics.
  EscapeTimeConfig(
    id: 'chen_lee',
    name: 'Chen-Lee Attractor',
    shaderAsset: 'shaders/strange_attractors/chen_lee_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),
];
