part of '../../escape_time_catalog.dart';

/// Affine-plane 4D slices: `z0 = e^{i*b}*x + q`, `c = e^{i*a}*y + q`,
/// `z -> (-z)^p + c`.
///
/// Source: the "multimin / multirot" formulas in
/// `opensource/repos/formula-catalogs/fract4d-formulas/orgform/fotdv7.frm`
/// (MIT, commit 2b3e04b). Mathematics adapted; no source text is copied.
/// Provenance: `opensource/docs/mandelbrot-mix-source.md`.
///
/// The two angles choose which 2D cut of the 4D family is shown. Angle 0 maps
/// the pixel axes onto the real line, so the intrinsic slice is thin; other
/// angles fill the plane.
final List<EscapeTimeConfig> _batch32PlanarSliceCatalog = [
  _sliceEntry(
    id: 'slice_multimin_0',
    name: 'Multimin Slice 0/0',
    angleA: 0,
    angleB: 0,
    description: 'Both planes coincide with the real axis: the thin intrinsic slice.',
  ),
  _sliceEntry(
    id: 'slice_multimin_45',
    name: 'Multimin Slice 45/45',
    angleA: 45,
    angleB: 45,
    description: 'Both planes rotated by 45 degrees.',
  ),
  _sliceEntry(
    id: 'slice_multimin_90_45',
    name: 'Multimin Slice 90/45',
    angleA: 90,
    angleB: 45,
    description: 'Parameter plane on the imaginary axis, orbit plane at 45 degrees.',
    zoom: 0.45,
  ),
  _sliceEntry(
    id: 'slice_multimin_30_60',
    name: 'Multimin Slice 30/60',
    angleA: 30,
    angleB: 60,
    description: 'Asymmetric cut through the 4D family.',
  ),
  _sliceEntry(
    id: 'slice_multirot_planes',
    name: 'Multirot Six-Plane Cut',
    angleA: 20,
    angleB: 70,
    description: 'Rotated slice in the multirot convention.',
    mode: 1,
  ),
  _sliceEntry(
    id: 'slice_multirot_cubic',
    name: 'Multirot Cubic Cut',
    angleA: 60,
    angleB: 15,
    power: 3,
    description: 'Cubic orbit on a rotated slice.',
    mode: 1,
    zoom: 0.45,
  ),
];

EscapeTimeConfig _sliceEntry({
  required String id,
  required String name,
  required double angleA,
  required double angleB,
  required String description,
  double power = 2,
  double offsetReal = 0,
  double offsetImag = 0,
  double mode = 0,
  double zoom = 0.9,
}) {
  return EscapeTimeConfig(
    id: id,
    name: name,
    shaderAsset:
        'shaders/escape_time_family/families/slice/planar_slice_4d_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6,
    defaultColorScheme: 1,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: zoom,
    maxIterations: 400,
    category: 'Complex Dynamics',
    extraParams: [
      _floatParam(id: 'sliceAngleA', label: 'Plane Angle A', min: -180, max: 180, step: 1, defaultValue: angleA),
      _floatParam(id: 'sliceAngleB', label: 'Plane Angle B', min: -180, max: 180, step: 1, defaultValue: angleB),
      _floatParam(id: 'slicePower', label: 'Power', min: 1, max: 6, step: 0.05, defaultValue: power),
      _floatParam(id: 'sliceOffsetRe', label: 'Offset Real', min: -2, max: 2, step: 0.01, defaultValue: offsetReal),
      _floatParam(id: 'sliceOffsetIm', label: 'Offset Imag', min: -2, max: 2, step: 0.01, defaultValue: offsetImag),
      _floatParam(id: 'sliceMode', label: 'Variant', min: 0, max: 1, step: 1, defaultValue: mode),
    ],
  );
}
