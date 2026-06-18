// GENERATED — reviewed escape-expression renderer promotions.
// Source: research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

enum SharedEscapeExpressionFamily { sine, cosine }

class SharedEscapeExpressionCatalogEntry {
  final String id;
  final String name;
  final SharedEscapeExpressionFamily family;
  final int variant;

  const SharedEscapeExpressionCatalogEntry({
    required this.id,
    required this.name,
    required this.family,
    required this.variant,
  });
}

// Duplicate formula tokens from the source worklist are intentionally omitted:
// f0519_sin_z_c/f0521_sin_z_c duplicate f0498_sin_z_c,
// f0526_sin_z_z_c duplicates f0509_sin_z_z_c, and
// f0520_cos_z_c duplicates f0499_cos_z_c and f0523_exp_z_z_c duplicates
// f0522_exp_z_z_c. The Möbius token is included only after review against
// research/candidates/rational_maps/ct_20260413_5af77c94.yaml.
const List<SharedEscapeExpressionCatalogEntry>
    sharedEscapeExpressionCatalogEntries = [
  SharedEscapeExpressionCatalogEntry(
      id: 'f0498_sin_z_c',
      name: 'sin(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 0),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0502_sin_1_z_c',
      name: 'sin(1/z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 1),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0505_sin_z_cos_z_c',
      name: 'sin(z)cos(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 2),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0506_sinh_z_cosh_z_c',
      name: 'sinh(z)cosh(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 3),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0507_log_sin_z_c',
      name: 'log(sin(z))+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 4),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0509_sin_z_z_c',
      name: 'z sin(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 5),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0517_sin_z_1_c',
      name: 'sin(z)+1+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 6),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0525_sinh_z_c',
      name: 'sinh(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 7),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0528_exp_z_sin_z_c',
      name: 'exp(z)sin(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 8),
  SharedEscapeExpressionCatalogEntry(
      id: 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin',
      name: 'Möbius rotation angle 0.7',
      family: SharedEscapeExpressionFamily.sine,
      variant: 9),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0500_exp_z_c',
      name: 'exp(z²)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 10),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0501_log_z_c',
      name: 'log(z²)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 11),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0503_exp_1_z_c',
      name: 'exp(1/z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 12),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0504_z_tan_z_c',
      name: 'z·tan(z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 13),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0515_z_exp_z_c',
      name: 'z·exp(-z²)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 14),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0516_exp_i_z_c',
      name: 'exp(i·z)+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 15),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0522_exp_z_z_c',
      name: 'exp(z)+z+c',
      family: SharedEscapeExpressionFamily.sine,
      variant: 16),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0499_cos_z_c',
      name: 'cos(z)+c',
      family: SharedEscapeExpressionFamily.cosine,
      variant: 0),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0508_log_cos_z_c',
      name: 'log(cos(z))+c',
      family: SharedEscapeExpressionFamily.cosine,
      variant: 1),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0518_cos_z_1_c',
      name: 'cos(z)+1+c',
      family: SharedEscapeExpressionFamily.cosine,
      variant: 2),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0527_cos_z_z_c',
      name: 'z cos(z)+c',
      family: SharedEscapeExpressionFamily.cosine,
      variant: 3),
  SharedEscapeExpressionCatalogEntry(
      id: 'f0537_newton_cos',
      name: 'Newton cosine escape',
      family: SharedEscapeExpressionFamily.cosine,
      variant: 4),
];

List<FractalModule> buildSharedEscapeExpressionCatalogModules() =>
    sharedEscapeExpressionCatalogEntries
        .map(_buildSharedEscapeExpressionModule)
        .toList(growable: false);

FractalModule _buildSharedEscapeExpressionModule(
  SharedEscapeExpressionCatalogEntry entry,
) {
  return buildEscapeTimeModule(EscapeTimeConfig(
    id: entry.id,
    name: entry.name,
    shaderAsset: _shaderAsset(entry.family),
    defaultIterations:
        entry.family == SharedEscapeExpressionFamily.sine ? 220 : 160,
    defaultBailout:
        entry.family == SharedEscapeExpressionFamily.sine ? 10.0 : 4.0,
    defaultCenterX:
        entry.family == SharedEscapeExpressionFamily.cosine ? -0.4 : 0.0,
    defaultZoom:
        entry.family == SharedEscapeExpressionFamily.cosine ? 0.3 : 1.0,
    extraParams: [
      FractalParameter(
        id: 'variant',
        label: (_) => 'Variant',
        type: FractalParamType.integer,
        min: 0,
        max: entry.family == SharedEscapeExpressionFamily.sine ? 16 : 4,
        step: 1,
        defaultValue: entry.variant,
      ),
    ],
  ));
}

String _shaderAsset(SharedEscapeExpressionFamily family) {
  return switch (family) {
    SharedEscapeExpressionFamily.sine =>
      'shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag',
    SharedEscapeExpressionFamily.cosine =>
      'shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag',
  };
}
