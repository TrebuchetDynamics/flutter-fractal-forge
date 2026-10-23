import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';

void main() {
  test(
      'Milnor shader keeps ten slots, finite static cap and escape-before-repower',
      () {
    final module = ModuleRegistry().byId('milnor_brieskorn');
    final source = File(module.shaderAsset).readAsStringSync();
    final uniforms = RegExp(r'uniform\s+(float|vec2)\s+(\w+)')
        .allMatches(source)
        .map((m) => m[2])
        .toList();
    expect(uniforms, [
      'uTime',
      'uResolution',
      'uCenter',
      'uZoom',
      'uIterations',
      'uBailout',
      'uColorScheme',
      'uTransparentBg'
    ]);
    expect(source, contains('const int MAX_ITERS = 500;'));
    expect(source, contains('if (j >= target) break;'));
    expect(
        source,
        contains(
            'if (logMagnitude(z) > log(radius)) { escape = true; break; }'));
    expect(source, contains('cmul(z3,z2)+z3+3.0*z2+c'));
    expect(source, contains('radius *= 1.00001;'));
    expect(source, contains('1e-9,1e12'));
    expect(source, contains('logDer'));
    expect(source, contains('finiteValue'));
    expect(source, contains('fragColor=vec4(0.0); return;'));
    expect(source, contains('scheme >= 50'));
    // Static time is declared only to preserve the shared uniform layout.
    expect(RegExp(r'\buTime\b').allMatches(source).length, 1);
    expect(module.parameters.firstWhere((p) => p.id == 'iterations').max, 500);
    expect(module.parameters.firstWhere((p) => p.id == 'colorScheme').max, 63);
  });
}
