import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math_64.dart';

/// All 3D ray-marched fractals defined declaratively.
///
/// To add a new 3D ray-marched fractal:
/// 1. Write a .frag shader following the standard 3D uniform layout
///    (see raymarched_3d_builder.dart for the layout)
/// 2. Add a [Raymarched3DConfig] entry here
/// 3. Register the shader in pubspec.yaml under flutter.shaders
/// 4. Done! No new Dart file needed.

final List<Raymarched3DConfig> raymarched3DCatalog = [
  // ── KIFS (Kaleidoscopic IFS) Family ──────────────────────────

  Raymarched3DConfig(
    id: 'kifs_menger',
    name: 'KIFS Menger Sponge',
    shaderAsset: 'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
    category: '3D Fractals',
    defaultPower: 3.0,
    minPower: 2.0,
    maxPower: 5.0,
    powerLabel: 'Scale',
    defaultIterations: 8,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_menger-cathedral',
        moduleId: 'kifs_menger',
        name: 'Cathedral',
        params: const {
          'power': 3.0,
          'iterations': 12,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3(0.5, 0.3, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'f0597_sierpinski_carpet_3d_menger_cross',
    name: 'Menger Cross 3D',
    shaderAsset: 'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
    category: '3D Fractals',
    defaultPower: 3.0,
    minPower: 2.0,
    maxPower: 5.0,
    powerLabel: 'Scale',
    defaultIterations: 12,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultFractalType: 1,
  ),

  Raymarched3DConfig(
    id: 'kifs_sierpinski_tetra',
    name: 'KIFS Sierpinski Tetrahedron',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_sierpinski_tetra_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 3.0,
    powerLabel: 'Scale',
    defaultIterations: 10,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_sierpinski_tetra-crystal',
        moduleId: 'kifs_sierpinski_tetra',
        name: 'Crystal Pyramid',
        params: const {
          'power': 2.0,
          'iterations': 14,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.4, 0.6, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'kifs_koch_fold',
    name: 'KIFS Koch 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 4.0,
    powerLabel: 'Scale',
    defaultIterations: 10,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
  ),

  Raymarched3DConfig(
    id: 'kifs_snowflake_fold',
    name: 'KIFS Snowflake 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_snowflake_fold_gpu.frag',
    category: '3D Fractals',
    defaultPower: 3.0,
    minPower: 2.0,
    maxPower: 5.0,
    powerLabel: 'Scale',
    defaultIterations: 8,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_snowflake_fold-ice',
        moduleId: 'kifs_snowflake_fold',
        name: 'Ice Crystal',
        params: const {
          'power': 3.0,
          'iterations': 12,
          'steps': 140,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.3, 0.5, 0.1),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'implicit_affine_fractal_surface',
    name: 'Implicit Affine Fractal Surface',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/implicit_affine_fractal_surface_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.7,
    minPower: 1.2,
    maxPower: 2.2,
    powerLabel: 'Affine Scale',
    defaultIterations: 12,
    maxIterations: 20,
    defaultSteps: 128,
    defaultBailout: 8.0,
  ),

  Raymarched3DConfig(
    id: 'sierpinski_octahedron_3d',
    name: 'Sierpinski Octahedron 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/polyhedral_ifs_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 8,
    maxIterations: 12,
    defaultSteps: 110,
    defaultBailout: 8.0,
    defaultFractalType: 2,
    defaultZoom: 1.35,
  ),

  Raymarched3DConfig(
    id: 'jerusalem_cube_3d',
    name: 'Jerusalem Cube 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/polyhedral_ifs_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 6,
    maxIterations: 9,
    defaultSteps: 110,
    defaultBailout: 8.0,
    defaultFractalType: 1,
    defaultZoom: 0.7,
  ),

  Raymarched3DConfig(
    id: 'vicsek_3d',
    name: 'Vicsek 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/polyhedral_ifs_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 7,
    maxIterations: 12,
    defaultSteps: 110,
    defaultBailout: 8.0,
    defaultFractalType: 0,
    defaultZoom: 1.6,
  ),

  Raymarched3DConfig(
    id: 'cantor_dust_3d',
    name: 'Cantor Dust 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/polyhedral_ifs_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 5,
    maxIterations: 10,
    defaultSteps: 110,
    defaultBailout: 8.0,
    defaultFractalType: 3,
    defaultZoom: 1.35,
  ),

  Raymarched3DConfig(
    id: 'pseudo_kleinian',
    name: 'Pseudo-Kleinian',
    shaderAsset: 'shaders/ifs_and_geometric/pseudo_kleinian_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.95,
    minPower: 1.5,
    maxPower: 2.3,
    powerLabel: 'Fold Scale',
    defaultIterations: 10,
    maxIterations: 16,
    defaultSteps: 110,
    defaultBailout: 8.0,
    defaultZoom: 0.45,
  ),

  // ── Hypercomplex / Quaternion Family ──────────────────────────

  Raymarched3DConfig(
    id: 'quaternion_mandelbrot_3d',
    name: 'Quaternion Mandelbrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_mandelbrot_3d_gpu.frag',
    animationCapability: FractalAnimationCapability.timeDriven,
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 14,
    maxIterations: 24,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 1.5,
  ),

  Raymarched3DConfig(
    id: 'tetrabrot_3d',
    name: 'Tetrabrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/tetrabrot_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 20,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 1.8,
  ),

  Raymarched3DConfig(
    id: 'arrowheadbrot_3d',
    name: 'Arrowheadbrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/arrowheadbrot_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 20,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 2.0,
  ),

  Raymarched3DConfig(
    id: 'mousebrot_3d',
    name: 'Mousebrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/mousebrot_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 20,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 2.0,
  ),

  Raymarched3DConfig(
    id: 'turtlebrot_3d',
    name: 'Turtlebrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/turtlebrot_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 20,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 2.4,
  ),

  Raymarched3DConfig(
    id: 'hourglassbrot_3d',
    name: 'Hourglassbrot 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/hourglassbrot_3d_gpu.frag',
    category: '3D Fractals',
    exposePower: false,
    defaultIterations: 20,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultZoom: 3.0,
  ),

  Raymarched3DConfig(
    id: 'dual_quaternion_julia',
    name: 'Dual-Quaternion Julia',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/dual_quaternion_julia_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.0,
    minPower: 0.1,
    maxPower: 3.0,
    powerLabel: 'Dual Coupling',
    defaultIterations: 20,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
  ),

  // ── Exotic 3D Family ──────────────────────────

  Raymarched3DConfig(
    id: 'mandelbox_shape_inversion',
    name: 'Mandelbox Shape Inversion',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_shape_inversion_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 3.5,
    powerLabel: 'Scale',
    defaultIterations: 15,
    maxIterations: 40,
    defaultSteps: 100,
    defaultBailout: 8.0,
    defaultZoom: 0.3,
    defaultFractalType: 0,
    maxFractalType: 3,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Sphere'),
      FractalParamOption(value: 1, label: (_) => 'Cube'),
      FractalParamOption(value: 2, label: (_) => 'Torus'),
      FractalParamOption(value: 3, label: (_) => 'Octahedron'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'mandelbox_shape_inversion-torus',
        moduleId: 'mandelbox_shape_inversion',
        name: 'Toroidal Fold',
        params: const {
          'power': 2.0,
          'iterations': 18,
          'steps': 120,
          'bailout': 8.0,
          'colorScheme': 2,
          'fractalType': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.3,
          rotation: Vector3(0.5, 0.3, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'apollonian_sphere_packing_3d',
    name: '3D Apollonian Sphere Packing',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/apollonian_sphere_packing_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.85,
    minPower: 1.35,
    maxPower: 2.85,
    powerLabel: 'Packing Scale',
    defaultIterations: 18,
    maxIterations: 32,
    defaultSteps: 130,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 0.55,
    defaultFractalType: 0,
    maxFractalType: 3,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Classic Bubbles'),
      FractalParamOption(value: 1, label: (_) => 'Tetrahedral'),
      FractalParamOption(value: 2, label: (_) => 'Cubic Voids'),
      FractalParamOption(value: 3, label: (_) => 'Pearl Drift'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'apollonian_sphere_packing_3d-golden_bubbles',
        moduleId: 'apollonian_sphere_packing_3d',
        name: 'Golden Bubbles',
        params: const {
          'power': 1.85,
          'iterations': 18,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 0,
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 0.55,
          rotation: Vector3(0.42, -0.38, 0.08),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'inversive_limit_set_3d',
    name: 'Inversive Limit Set 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/inversive_limit_set_3d_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.4,
    minPower: 1.0,
    maxPower: 2.0,
    powerLabel: 'Sphere Radius',
    defaultIterations: 20,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'inversive_limit_set_3d-pearls',
        moduleId: 'inversive_limit_set_3d',
        name: 'Pearl Necklace',
        params: const {
          'power': 1.35,
          'iterations': 30,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3(0.3, 0.5, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'mandelbulb_time_modulated',
    name: 'Time-Modulated Mandelbulb',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
    animationCapability: FractalAnimationCapability.timeDriven,
    category: '3D Fractals',
    defaultPower: 8.0,
    minPower: 2.0,
    maxPower: 24.0,
    powerLabel: 'Power',
    defaultIterations: 50,
    maxIterations: 100,
    defaultSteps: 120,
    defaultBailout: 2.0,
    extraPresets: [
      catalogPreset(
        id: 'mandelbulb_time_modulated-breathing',
        moduleId: 'mandelbulb_time_modulated',
        name: 'Breathing Form',
        params: const {
          'power': 7.0,
          'iterations': 60,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.4, 0.3, 0.1),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'amazing_box',
    name: 'Amazing Box',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.6,
    maxPower: 3.2,
    powerLabel: 'Fold Scale',
    defaultIterations: 16,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 6.0,
    defaultZoom: 0.55,
    extraPresets: [
      catalogPreset(
        id: 'amazing_box-compact',
        moduleId: 'amazing_box',
        name: 'Compact Wirebox',
        params: const {
          'power': 2.25,
          'iterations': 18,
          'steps': 140,
          'bailout': 6.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 0.55,
          rotation: Vector3(0.45, 0.35, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'bulbils',
    name: 'Bulbils',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/bulbils_gpu.frag',
    animationCapability: FractalAnimationCapability.timeDriven,
    category: '3D Fractals',
    defaultPower: 6.0,
    minPower: 3.0,
    maxPower: 10.0,
    powerLabel: 'Bulb Power',
    defaultIterations: 18,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'bulbils-cluster',
        moduleId: 'bulbils',
        name: 'Bulbil Cluster',
        params: const {
          'power': 7.0,
          'iterations': 24,
          'steps': 140,
          'bailout': 4.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.35, -0.45, 0.1),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'hartverdrahtet',
    name: 'Hartverdrahtet',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/hartverdrahtet_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.4,
    maxPower: 3.2,
    powerLabel: 'Wire Scale',
    defaultIterations: 14,
    maxIterations: 32,
    defaultSteps: 90,
    defaultBailout: 5.0,
  ),

  Raymarched3DConfig(
    id: 'tglad_formula',
    name: "Tglad's Formula",
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/tglad_formula_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.1,
    minPower: 1.6,
    maxPower: 3.4,
    powerLabel: 'Fold Scale',
    defaultIterations: 18,
    maxIterations: 40,
    defaultSteps: 120,
    defaultBailout: 5.0,
  ),

  // ── Recursive Toroidal Fiber Systems ───────────

  Raymarched3DConfig(
    id: 'tortoise_toroidal_fractal',
    name: 'TORTOISE Toroidal Fractal',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/tortoise_toroidal_fractal_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 6.0,
    minPower: 3.0,
    maxPower: 12.0,
    powerLabel: 'Fiber Winding',
    defaultIterations: 2,
    minIterations: 1,
    maxIterations: 3,
    defaultSteps: 140,
    defaultBailout: 5.0,
    defaultColorScheme: 0,
    maxColorScheme: 3,
    defaultZoom: 0.95,
    defaultRotationX: 0.06,
    defaultRotationY: 0.0,
    extraPresets: [
      catalogPreset(
        id: 'tortoise_toroidal_fractal-opening-rosette',
        moduleId: 'tortoise_toroidal_fractal',
        name: 'Opening Rosette',
        params: const {
          'power': 6.0,
          'iterations': 3.0,
          'steps': 160.0,
          'bailout': 5.0,
          'colorScheme': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.0,
          rotation: Vector3(0.08, 0.0, 0.0),
        ),
      ),
      catalogPreset(
        id: 'tortoise_toroidal_fractal-woven-shell',
        moduleId: 'tortoise_toroidal_fractal',
        name: 'Woven Shell',
        params: const {
          'power': 9.0,
          'iterations': 2.0,
          'steps': 150.0,
          'bailout': 5.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 0.88,
          rotation: Vector3(0.58, -0.72, 0.12),
        ),
      ),
    ],
  ),

  // ── Glowmarched Recursive Lattices ────────────

  Raymarched3DConfig(
    id: 'luminous_fold_lattice',
    name: 'Luminous Fold Lattice',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/luminous_fold_lattice_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 1.9,
    minPower: 1.45,
    maxPower: 2.8,
    powerLabel: 'Fold Scale',
    defaultIterations: 6,
    minIterations: 2,
    maxIterations: 9,
    defaultSteps: 128,
    defaultBailout: 6.0,
    defaultColorScheme: 0,
    maxColorScheme: 3,
    defaultZoom: 1.1,
    defaultRotationX: 0.30,
    defaultRotationY: -0.35,
    extraPresets: [
      catalogPreset(
        id: 'luminous_fold_lattice-ember-vault',
        moduleId: 'luminous_fold_lattice',
        name: 'Ember Vault',
        params: const {
          'power': 1.72,
          'iterations': 5.0,
          'steps': 112.0,
          'bailout': 7.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.02,
          rotation: Vector3(0.48, -0.20, 0.08),
        ),
      ),
      catalogPreset(
        id: 'luminous_fold_lattice-violet-cathedral',
        moduleId: 'luminous_fold_lattice',
        name: 'Violet Cathedral',
        params: const {
          'power': 2.16,
          'iterations': 7.0,
          'steps': 144.0,
          'bailout': 5.2,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.22,
          rotation: Vector3(0.22, -0.54, 0.15),
        ),
      ),
      catalogPreset(
        id: 'luminous_fold_lattice-ice-lantern',
        moduleId: 'luminous_fold_lattice',
        name: 'Ice Lantern',
        params: const {
          'power': 2.54,
          'iterations': 8.0,
          'steps': 156.0,
          'bailout': 6.4,
          'colorScheme': 3,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.34,
          rotation: Vector3(0.62, -0.38, -0.12),
        ),
      ),
    ],
  ),

  // ── Isolated Recursive Object Systems ─────────

  Raymarched3DConfig(
    id: 'ternary_cayley_lumen',
    name: 'Ternary Cayley Lumen',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 0.63,
    minPower: 0.48,
    maxPower: 0.70,
    powerLabel: 'Branch Scale',
    defaultIterations: 4,
    minIterations: 2,
    maxIterations: 6,
    defaultSteps: 100,
    defaultBailout: 5.5,
    defaultColorScheme: 0,
    defaultZoom: 1.55,
    defaultRotationX: 0.32,
    defaultRotationY: -0.34,
    defaultFractalType: 0,
  ),

  Raymarched3DConfig(
    id: 'gyroid_echo_reliquary',
    name: 'Gyroid Echo Reliquary',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 2.35,
    minPower: 1.6,
    maxPower: 3.4,
    powerLabel: 'Base Frequency',
    defaultIterations: 3,
    minIterations: 1,
    maxIterations: 4,
    defaultSteps: 112,
    defaultBailout: 6.0,
    defaultColorScheme: 1,
    defaultZoom: 1.0,
    defaultRotationX: 0.30,
    defaultRotationY: -0.28,
    defaultFractalType: 1,
  ),

  Raymarched3DConfig(
    id: 'mobius_echo_nest',
    name: 'Möbius Echo Nest',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 0.62,
    minPower: 0.45,
    maxPower: 0.72,
    powerLabel: 'Echo Scale',
    defaultIterations: 4,
    minIterations: 1,
    maxIterations: 5,
    defaultSteps: 96,
    defaultBailout: 5.0,
    defaultColorScheme: 3,
    defaultZoom: 1.08,
    defaultRotationX: 0.46,
    defaultRotationY: -0.22,
    defaultFractalType: 2,
  ),

  Raymarched3DConfig(
    id: 'fibonacci_cone_bloom',
    name: 'Fibonacci Cone Bloom',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 0.39,
    minPower: 0.28,
    maxPower: 0.48,
    powerLabel: 'Child Scale',
    defaultIterations: 3,
    minIterations: 1,
    maxIterations: 4,
    defaultSteps: 115,
    defaultBailout: 6.0,
    defaultColorScheme: 2,
    defaultZoom: 1.02,
    defaultRotationX: 0.24,
    defaultRotationY: -0.40,
    defaultFractalType: 3,
  ),

  Raymarched3DConfig(
    id: 'chebyshev_nodal_lantern',
    name: 'Chebyshev Nodal Lantern',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 3.4,
    minPower: 2.0,
    maxPower: 5.9,
    powerLabel: 'Polynomial Order',
    defaultIterations: 2,
    minIterations: 1,
    maxIterations: 3,
    defaultSteps: 100,
    defaultBailout: 5.5,
    defaultColorScheme: 0,
    defaultZoom: 1.02,
    defaultRotationX: 0.32,
    defaultRotationY: -0.30,
    defaultFractalType: 4,
  ),

  // Recursive crystal constructions.
  Raymarched3DConfig(
    id: 'octahedral_crystal_bloom',
    name: 'Octahedral Crystal Bloom',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 2.7,
    minPower: 2.2,
    maxPower: 3.4,
    powerLabel: 'Branch Scale',
    defaultIterations: 4,
    minIterations: 2,
    maxIterations: 6,
    defaultSteps: 140,
    defaultBailout: 5.5,
    defaultColorScheme: 0,
    defaultZoom: 1.02,
    defaultRotationX: 0.26,
    defaultRotationY: -0.38,
    defaultFractalType: 5,
  ),

  Raymarched3DConfig(
    id: 'tetrahedral_orbit_lantern',
    name: 'Tetrahedral Orbit Lantern',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 2.0,
    minPower: 1.9,
    maxPower: 2.6,
    powerLabel: 'Branch Scale',
    defaultIterations: 4,
    minIterations: 2,
    maxIterations: 6,
    defaultSteps: 140,
    defaultBailout: 5.5,
    defaultColorScheme: 2,
    defaultZoom: 1.02,
    defaultRotationX: 0.26,
    defaultRotationY: -0.38,
    defaultFractalType: 6,
  ),

  Raymarched3DConfig(
    id: 'cantor_cross_crystal',
    name: 'Cantor Cross Crystal',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag',
    category: '3D Fractals',
    animationCapability: FractalAnimationCapability.timeDriven,
    defaultPower: 3.0,
    minPower: 2.5,
    maxPower: 3.5,
    powerLabel: 'Branch Scale',
    defaultIterations: 4,
    minIterations: 2,
    maxIterations: 6,
    defaultSteps: 140,
    defaultBailout: 5.5,
    defaultColorScheme: 1,
    defaultZoom: 1.02,
    defaultRotationX: 0.26,
    defaultRotationY: -0.38,
    defaultFractalType: 7,
  ),

  // ── Mandelbulb Family ──────────────────────────

  Raymarched3DConfig(
    id: 'mandelbulb',
    name: 'Mandelbulb',
    shaderAsset: 'shaders/legacy/raymarched_3d/mandelbulb.frag',
    category: '3D Fractals',
    defaultPower: 8.0,
    minPower: 2.0,
    maxPower: 12.0,
    powerLabel: 'Power',
    defaultIterations: 50,
    maxIterations: 100,
    defaultSteps: 120,
    defaultBailout: 2.0,
    defaultFractalType: 0,
    maxFractalType: 1,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Mandelbulb'),
      FractalParamOption(value: 1, label: (_) => 'Mandelbox'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'mandelbulb-classic',
        moduleId: 'mandelbulb',
        name: 'Classic Bulb',
        params: const {
          'power': 8.0,
          'iterations': 50,
          'steps': 120,
          'bailout': 2.0,
          'colorScheme': 0,
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.3, -0.4, 0.0),
        ),
      ),
      catalogPreset(
        id: 'mandelbulb-spiky',
        moduleId: 'mandelbulb',
        name: 'Spiky Variant',
        params: const {
          'power': 10.0,
          'iterations': 60,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 2,
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.5, 0.2, 0.1),
        ),
      ),
    ],
  ),
];

/// Build all 3D ray-marched modules from the catalog.
List<FractalModule> buildRaymarched3DCatalogModules() {
  return raymarched3DCatalog.map(buildRaymarched3DModule).toList();
}
