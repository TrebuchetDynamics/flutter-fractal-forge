import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_iterators.dart';

/// Tiny reference-oracle layer for formulas with known CPU iterators.
///
/// Unsupported modules are reported as `skipped` instead of guessed. Add a
/// module here only when we have stable known points for that formula family.
final class RenderMathOracle {
  static const int _iterations = 64;
  static const double _bailout = 4.0;
  static final Vector2 _juliaC = Vector2(-0.8, 0.156);

  static final Set<String> _originBoundedModules = <String>{
    'mandelbrot',
    'burning_ship',
    'tricorn',
    'multibrot4',
    'multibrot5',
  };

  static final Set<String> _farEscapeModules = <String>{
    ..._originBoundedModules,
    'julia',
    'phoenix',
  };

  static MathOracleResult evaluate(String moduleId) {
    final iterator = cpuIteratorsByModuleId[moduleId];
    if (iterator == null || !_farEscapeModules.contains(moduleId)) {
      return MathOracleResult.skipped(
        moduleId,
        'no reference oracle for this formula family yet',
      );
    }

    final checks = <Map<String, Object>>[];

    if (_originBoundedModules.contains(moduleId)) {
      final result = iterator(0.0, 0.0, _iterations, _bailout, _juliaC);
      checks.add({
        'name': 'origin stays bounded',
        'x': 0.0,
        'y': 0.0,
        'expectedEscaped': false,
        'actualEscaped': result.escaped,
        'iterations': result.it,
        'passed': !result.escaped,
      });
    }

    final far = iterator(2.0, 2.0, _iterations, _bailout, _juliaC);
    checks.add({
      'name': 'far point escapes',
      'x': 2.0,
      'y': 2.0,
      'expectedEscaped': true,
      'actualEscaped': far.escaped,
      'iterations': far.it,
      'passed': far.escaped && far.it < 16,
    });

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: moduleId,
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }
}

final class MathOracleResult {
  final String moduleId;
  final String verdict;
  final String reason;
  final List<Map<String, Object>> checks;

  const MathOracleResult({
    required this.moduleId,
    required this.verdict,
    required this.reason,
    required this.checks,
  });

  factory MathOracleResult.skipped(String moduleId, String reason) {
    return MathOracleResult(
      moduleId: moduleId,
      verdict: 'skipped',
      reason: reason,
      checks: const [],
    );
  }

  Map<String, Object> toJson() => {
        'moduleId': moduleId,
        'verdict': verdict,
        if (reason.isNotEmpty) 'reason': reason,
        'checks': checks,
      };
}
