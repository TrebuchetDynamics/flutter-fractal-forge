// GENERATED — reviewed direct transcendental renderer promotions.
// Source: existing-app escape-time polynomial/transcendental leads.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedDirectTranscendentalCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final double iterations;
  final double bailout;
  final double? variant;

  const SharedDirectTranscendentalCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
    this.iterations = 140,
    this.bailout = 4.0,
    this.variant,
  });
}

const List<SharedDirectTranscendentalCatalogEntry>
    sharedDirectTranscendentalCatalogEntries = [
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0490_tangent_mandelbrot',
    name: 'Tangent Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/tangent_mandelbrot_gpu.frag',
    iterations: 110,
    variant: 0,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0491_hyperbolic_sine_mandelbrot',
    name: 'Hyperbolic Sine Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/sinh_mandelbrot_gpu.frag',
    iterations: 120,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0492_hyperbolic_cosine_mandelbrot',
    name: 'Hyperbolic Cosine Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/cosh_mandelbrot_gpu.frag',
    iterations: 120,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0493_hyperbolic_tangent_mandelbrot',
    name: 'Hyperbolic Tangent Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag',
    iterations: 120,
    variant: 0,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0510_tan_z_c',
    name: 'tan(z²)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/tangent_mandelbrot_gpu.frag',
    iterations: 140,
    variant: 1,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0511_sech_z_c',
    name: 'sech(z)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag',
    iterations: 140,
    variant: 2,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0512_csc_z_c',
    name: 'csc(z²)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/cosecant_mandelbrot_gpu.frag',
    iterations: 140,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0513_sec_z_c',
    name: 'sec(z²)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/secant_mandelbrot_gpu.frag',
    iterations: 140,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0514_cot_z_c',
    name: 'cot(z²)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/cotangent_mandelbrot_gpu.frag',
    iterations: 140,
  ),
  SharedDirectTranscendentalCatalogEntry(
    id: 'f0524_tanh_z_c',
    name: 'tanh(z²)+c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag',
    iterations: 140,
    variant: 1,
  ),
];

List<FractalModule> buildSharedDirectTranscendentalCatalogModules() =>
    sharedDirectTranscendentalCatalogEntries
        .map((entry) => buildEscapeTimeModule(EscapeTimeConfig(
              id: entry.id,
              name: entry.name,
              shaderAsset: entry.shaderAsset,
              defaultIterations: entry.iterations,
              defaultBailout: entry.bailout,
              extraParams: [
                if (entry.variant != null)
                  FractalParameter(
                    id: 'variant',
                    label: (_) => 'Variant',
                    type: FractalParamType.integer,
                    min: 0,
                    max: 2,
                    step: 1,
                    defaultValue: entry.variant!,
                  ),
              ],
            )))
        .toList(growable: false);
