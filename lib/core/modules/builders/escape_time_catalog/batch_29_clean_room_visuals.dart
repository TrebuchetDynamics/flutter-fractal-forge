part of '../escape_time_catalog.dart';

/// Clean-room, single-pass interpretations of requested visual families.
/// No ShaderToy source, textures, or multipass state is used.
final List<EscapeTimeConfig> _batch29CleanRoomVisualsCatalog = [
  EscapeTimeConfig(
    id: 'relativistic_black_hole_lensing',
    name: 'Relativistic Black Hole Lensing',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/physical_simulation/relativistic_black_hole_lensing_gpu.frag',
    defaultIterations: 72,
    defaultBailout: 4,
    defaultColorScheme: 1,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: 0.92,
    maxIterations: 96,
    category: 'Fractalish Motion',
    animationCapability: FractalAnimationCapability.timeDriven,
    extraParams: [
      _floatParam(
        id: 'mass',
        label: 'Lens Mass',
        min: 0.6,
        max: 1.8,
        step: 0.05,
        defaultValue: 1,
      ),
      _floatParam(
        id: 'spin',
        label: 'Spin',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0.72,
      ),
      _floatParam(
        id: 'diskTilt',
        label: 'Disk Tilt',
        min: 0.15,
        max: 1.2,
        step: 0.05,
        defaultValue: 0.58,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'recursive_octagram_field',
    name: 'Recursive Octagram Field',
    shaderAsset:
        'shaders/ifs_and_geometric/plane_tilings/recursive_octagram_field_gpu.frag',
    defaultIterations: 20,
    defaultBailout: 4,
    defaultColorScheme: 6,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: 0.78,
    maxIterations: 20,
    category: 'IFS & Geometric Construction',
    animationCapability: FractalAnimationCapability.timeDriven,
    extraParams: [
      _floatParam(
        id: 'foldScale',
        label: 'Fold Scale',
        min: 1.45,
        max: 2.6,
        step: 0.05,
        defaultValue: 1.92,
      ),
      _floatParam(
        id: 'rotationRate',
        label: 'Rotation Rate',
        min: 0,
        max: 1.5,
        step: 0.05,
        defaultValue: 0.22,
      ),
    ],
  ),
];
