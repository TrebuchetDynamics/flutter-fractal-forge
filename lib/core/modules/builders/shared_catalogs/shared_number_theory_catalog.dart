// GENERATED — reviewed number-theory/special-function promotions.
// Source: existing-app number-theory special-function leads.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedNumberTheoryCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;

  const SharedNumberTheoryCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
  });
}

const List<SharedNumberTheoryCatalogEntry> sharedNumberTheoryCatalogEntries = [
  SharedNumberTheoryCatalogEntry(
    id: 'f0763_weierstrass_function_a_0_3_b_7',
    name: 'Weierstrass Function (a=0.3, b=7)',
    a: 0.3,
    b: 7.0,
  ),
];

List<FractalModule> buildSharedNumberTheoryCatalogModules() =>
    sharedNumberTheoryCatalogEntries
        .map((entry) => buildEscapeTimeModule(EscapeTimeConfig(
              id: entry.id,
              name: entry.name,
              shaderAsset:
                  'shaders/trigonometric_and_transcendental/special_functions/weierstrass_function_gpu.frag',
              defaultIterations: 120,
              defaultBailout: 4,
              category: 'Escape-Time',
              extraParams: [
                FractalParameter(
                  id: 'a',
                  label: (_) => 'a',
                  type: FractalParamType.float,
                  min: 0.01,
                  max: 0.99,
                  step: 0.01,
                  defaultValue: entry.a,
                ),
                FractalParameter(
                  id: 'b',
                  label: (_) => 'b',
                  type: FractalParamType.float,
                  min: 2,
                  max: 15,
                  step: 1,
                  defaultValue: entry.b,
                ),
              ],
            )))
        .toList(growable: false);
