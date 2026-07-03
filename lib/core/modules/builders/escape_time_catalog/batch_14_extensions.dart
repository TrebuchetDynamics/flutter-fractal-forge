part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _batch14ExtensionsCatalog = [
// ── Batch 14 — Newton extensions, transcendental Julia, power-law families ─

// Newton z^4−1=0: four roots at ±1, ±i — cross-symmetric basin pattern.
  EscapeTimeConfig(
    id: 'newton_z4',
    name: 'Newton z⁴−1',
    shaderAsset: 'shaders/root_finding/newton_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

// Newton z^6−1=0: six roots at 60° intervals — snowflake basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z6',
    name: 'Newton z⁶−1',
    shaderAsset: 'shaders/root_finding/newton_z6_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

// Julia set of f(z)=c·tan(z), c=(0.12,0.48) — canals near tangent poles.
  EscapeTimeConfig(
    id: 'tangent_julia',
    name: 'Tangent Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/tangent_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

// Julia set of f(z)=c·sinh(z), c=(−0.65,0.45) — hyperbolic sine spirals.
  EscapeTimeConfig(
    id: 'sinh_julia',
    name: 'Sinh Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/sinh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

// Julia set of f(z)=c·cosh(z), c=(0.55,0.40) — symmetric lenticular arms.
  EscapeTimeConfig(
    id: 'cosh_julia',
    name: 'Cosh Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/cosh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

// Julia set of f(z)=c·tanh(z), c=(0.80,0.40) — quasi-circular Fatou disks.
  EscapeTimeConfig(
    id: 'tanh_julia',
    name: 'Tanh Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/tanh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

// Burning Ship degree 4: (|Re|+i|Im|)^4+c — four-pronged hull structure.
  EscapeTimeConfig(
    id: 'burning_ship_power4',
    name: 'Burning Ship ⁴',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

// Multibrot degree 6: z^6+c — five-fold star branching at Misiurewicz pts.
  EscapeTimeConfig(
    id: 'multibrot6',
    name: 'Multibrot ⁶',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

// Mandelbar degree 4: conj(z)^4+c — anti-holomorphic 4-fold cusp symmetry.
  EscapeTimeConfig(
    id: 'tricorn_power4',
    name: 'Tricorn ⁴ (Mandelbar)',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

// Buffalo degree 4: |Re(z^4)|+i|Im(z^4)|+c — post-fold abs on degree-4 orbit.
  EscapeTimeConfig(
    id: 'buffalo_power4',
    name: 'Buffalo ⁴',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

// Newton z^5−1=0: five roots at 5th roots of unity — pentagonal basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z5',
    name: 'Newton z⁵−1',
    shaderAsset: 'shaders/root_finding/newton_z5_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

// Biomorph (Pickover 1986): z^2+c with |Re|<B OR |Im|<B escape test.
// Creates organic, cell-like shapes with dendritic filaments.
  EscapeTimeConfig(
    id: 'biomorph',
    name: 'Biomorph',
    shaderAsset: 'shaders/escape_time_family/julia_variants/biomorph_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 10.0,
    extraPresets: [
      catalogPreset(
        id: 'biomorph-relief',
        moduleId: 'biomorph',
        name: 'Biomorph Relief',
        params: {'iterations': 100, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multijulia3',
    name: 'Multijulia ³',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia3_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia4',
    name: 'Multijulia ⁴',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia5',
    name: 'Multijulia ⁵',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia6',
    name: 'Multijulia ⁶',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4',
    name: 'Celtic ⁴',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_cubic_julia',
    name: 'Burning Ship Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5',
    name: 'Tricorn ⁵ (Mandelbar)',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'exponential_julia',
    name: 'Exponential Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/exponential_iteration/exponential_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 50.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic_julia',
    name: 'Buffalo Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet1',
    name: 'Magnet Type I',
    shaderAsset:
        'shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet1_gpu.frag',
    defaultIterations: 158,
    defaultBailout: 8.0,
    defaultCenterX: 0.7072526812553406,
    defaultCenterY: -0.21410192549228668,
    defaultZoom: 0.2039256117342137,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_cubic',
    name: 'Mandelbar Cubic (Tricorn ³)',
    shaderAsset:
        'shaders/escape_time_family/families/mandelbar/mandelbar_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship',
    name: 'Perpendicular Burning Ship',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_burning_ship_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5',
    name: 'Burning Ship ⁵',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power5',
    name: 'Celtic ⁵',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power5',
    name: 'Buffalo ⁵',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot7',
    name: 'Multibrot ⁷',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot8',
    name: 'Multibrot ⁸',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'multibrot8-wide',
        moduleId: 'multibrot8',
        name: 'Octic Boundary',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 0.5,
          rotation: Vector3.zero(),
        ),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multijulia7',
    name: 'Multijulia ⁷',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia8',
    name: 'Multijulia ⁸',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z7',
    name: 'Newton z⁷−1',
    shaderAsset: 'shaders/root_finding/newton_z7_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'feather_julia',
    name: 'Feather Julia',
    shaderAsset:
        'shaders/escape_time_family/julia_variants/feather_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'heart_julia',
    name: 'Heart Julia',
    shaderAsset:
        'shaders/escape_time_family/julia_variants/heart_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z8',
    name: 'Newton z⁸−1',
    shaderAsset: 'shaders/root_finding/newton_z8_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power4_julia',
    name: 'Burning Ship⁴ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5_julia',
    name: 'Burning Ship⁵ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power4_julia',
    name: 'Buffalo⁴ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4_julia',
    name: 'Celtic⁴ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power4_julia',
    name: 'Tricorn⁴ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power4_julia_gpu.frag',
    defaultIterations: 160,
    maxIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5_julia',
    name: 'Tricorn⁵ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship_julia',
    name: 'Perpendicular BS Julia',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_burning_ship_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_julia',
    name: 'Lambda Julia',
    shaderAsset:
        'shaders/escape_time_family/julia_variants/lambda_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_cubic_julia',
    name: 'Celtic Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power5_julia',
    name: 'Celtic⁵ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power5_julia',
    name: 'Buffalo⁵ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic_julia',
    name: 'Tricorn Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet1_julia',
    name: 'Magnet I Julia',
    shaderAsset:
        'shaders/escape_time_family/julia_variants/magnet1_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'magnet2_julia',
    name: 'Magnet II Julia',
    shaderAsset:
        'shaders/escape_time_family/julia_variants/magnet2_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power6',
    name: 'Mandelbar⁶',
    shaderAsset:
        'shaders/escape_time_family/families/mandelbar/mandelbar_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power6_julia',
    name: 'Tricorn⁶ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_cubic',
    name: 'Perpendicular BS Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_bs_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_cubic_julia',
    name: 'Perp. BS Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_bs_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'schroeder_z3',
    name: 'Schröder z³−1',
    shaderAsset: 'shaders/root_finding/schroeder_z3_gpu.frag',
    defaultIterations: 80,
    maxIterations: 120,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'schroeder_z4',
    name: 'Schröder z⁴−1',
    shaderAsset: 'shaders/root_finding/schroeder_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'nova_cubic',
    name: 'Nova Cubic',
    shaderAsset:
        'shaders/escape_time_family/families/nova/parameter_plane/nova_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_cubic_julia',
    name: 'Nova Cubic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/nova/julia_sets/nova_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power6',
    name: 'Burning Ship⁶',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power6',
    name: 'Buffalo⁶',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power6',
    name: 'Celtic⁶',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot9',
    name: 'Multibrot⁹',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia9',
    name: 'Multijulia⁹',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot10',
    name: 'Multibrot¹⁰',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'multibrot10-wide',
        moduleId: 'multibrot10',
        name: 'Decagonal Boundary',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 0.5,
          rotation: Vector3.zero(),
        ),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multijulia10',
    name: 'Multijulia¹⁰',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot11',
    name: 'Multibrot¹¹',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot11_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot12',
    name: 'Multibrot¹²',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot12_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power6_julia',
    name: 'Burning Ship⁶ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power6_julia',
    name: 'Buffalo⁶ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power6_julia',
    name: 'Celtic⁶ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'halley_z4',
    name: 'Halley z⁴−1',
    shaderAsset: 'shaders/root_finding/halley_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power7',
    name: 'Mandelbar⁷',
    shaderAsset:
        'shaders/escape_time_family/families/mandelbar/mandelbar_power7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_degree4',
    name: 'Nova⁴',
    shaderAsset:
        'shaders/escape_time_family/families/nova/parameter_plane/nova_degree4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_degree4_julia',
    name: 'Nova⁴ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/nova/julia_sets/nova_degree4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia11',
    name: 'Multijulia¹¹',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia11_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia12',
    name: 'Multijulia¹²',
    shaderAsset:
        'shaders/escape_time_family/families/multijulia/multijulia12_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power8',
    name: 'Mandelbar⁸',
    shaderAsset:
        'shaders/escape_time_family/families/mandelbar/mandelbar_power8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power9',
    name: 'Mandelbar⁹',
    shaderAsset:
        'shaders/escape_time_family/families/mandelbar/mandelbar_power9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power7_julia',
    name: 'Tricorn⁷ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power7_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power8_julia',
    name: 'Tricorn⁸ Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_power4',
    name: 'Perpendicular BS⁴',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_bs_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_power5',
    name: 'Perpendicular BS⁵',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_bs_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
];
