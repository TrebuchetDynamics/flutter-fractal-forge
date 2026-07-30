import 'package:vector_math/vector_math.dart' show Vector2, Vector3, Vector4;

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
    if (moduleId == 'tetrabrot_3d') {
      return _evaluateTetrabrot3D();
    }
    if (moduleId == 'arrowheadbrot_3d') {
      return _evaluateArrowheadbrot3D();
    }
    if (moduleId == 'mousebrot_3d') {
      return _evaluateMousebrot3D();
    }
    if (moduleId == 'turtlebrot_3d') {
      return _evaluateTurtlebrot3D();
    }
    if (moduleId == 'hourglassbrot_3d') {
      return _evaluateHourglassbrot3D();
    }
    if (moduleId == 'quaternion_mandelbrot_3d') {
      return _evaluateQuaternionMandelbrot3D();
    }
    if (moduleId == 'cantor_dust_3d') {
      return _evaluateCantorDust3D();
    }

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

  static MathOracleResult _evaluateTetrabrot3D() {
    final cases = <(String, Vector3, bool)>[
      ('origin belongs to both complex components', Vector3.zero(), true),
      ('negative unit parameter is bounded', Vector3(-1.0, 0.0, 0.0), true),
      (
        'far real parameter escapes both components',
        Vector3(2.0, 0.0, 0.0),
        false
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (name, point, expectedContained) in cases) {
      final cMinus = Vector2(point.x, point.y - point.z);
      final cPlus = Vector2(point.x, point.y + point.z);
      final actualContained = !_complexMandelbrotEscapes(cMinus) &&
          !_complexMandelbrotEscapes(cPlus);
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedContained': expectedContained,
        'actualContained': actualContained,
        'passed': actualContained == expectedContained,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'tetrabrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static MathOracleResult _evaluateArrowheadbrot3D() {
    final cases = <(String, Vector3, bool, bool)>[
      ('origin belongs to both slices', Vector3.zero(), true, true),
      (
        'real-axis endpoint pair belongs only to Arrowheadbrot',
        Vector3(-0.875, 0.0, 1.125),
        true,
        false
      ),
      (
        'positive hyperbolic displacement belongs only to Tetrabrot',
        Vector3(0.0, 0.0, 0.3),
        false,
        true
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (
          name,
          point,
          expectedArrowheadContained,
          expectedTetrabrotContained
        ) in cases) {
      final arrowMinus = Vector2(point.x - point.z, point.y);
      final arrowPlus = Vector2(point.x + point.z, point.y);
      final actualArrowheadContained = !_complexMandelbrotEscapes(arrowMinus) &&
          !_complexMandelbrotEscapes(arrowPlus);
      final tetrabrotMinus = Vector2(point.x, point.y - point.z);
      final tetrabrotPlus = Vector2(point.x, point.y + point.z);
      final actualTetrabrotContained =
          !_complexMandelbrotEscapes(tetrabrotMinus) &&
              !_complexMandelbrotEscapes(tetrabrotPlus);
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedArrowheadContained': expectedArrowheadContained,
        'actualArrowheadContained': actualArrowheadContained,
        'expectedTetrabrotContained': expectedTetrabrotContained,
        'actualTetrabrotContained': actualTetrabrotContained,
        'passed': actualArrowheadContained == expectedArrowheadContained &&
            actualTetrabrotContained == expectedTetrabrotContained,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'arrowheadbrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static MathOracleResult _evaluateMousebrot3D() {
    final cases = <(String, Vector3, bool, bool, bool)>[
      ('origin belongs to all three slices', Vector3.zero(), true, true, true),
      (
        'imaginary component pair belongs only to Mousebrot',
        Vector3(-0.75, -0.25, 0.0),
        true,
        false,
        false
      ),
      (
        'negative real endpoint belongs to the other two slices',
        Vector3(-2.0, 0.0, 0.0),
        false,
        true,
        true
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (
          name,
          point,
          expectedMousebrotContained,
          expectedArrowheadContained,
          expectedTetrabrotContained
        ) in cases) {
      final mouseMinus = Vector2(point.z, point.x - point.y);
      final mousePlus = Vector2(-point.z, point.x + point.y);
      final actualMousebrotContained = !_complexMandelbrotEscapes(mouseMinus) &&
          !_complexMandelbrotEscapes(mousePlus);
      final arrowMinus = Vector2(point.x - point.z, point.y);
      final arrowPlus = Vector2(point.x + point.z, point.y);
      final actualArrowheadContained = !_complexMandelbrotEscapes(arrowMinus) &&
          !_complexMandelbrotEscapes(arrowPlus);
      final tetrabrotMinus = Vector2(point.x, point.y - point.z);
      final tetrabrotPlus = Vector2(point.x, point.y + point.z);
      final actualTetrabrotContained =
          !_complexMandelbrotEscapes(tetrabrotMinus) &&
              !_complexMandelbrotEscapes(tetrabrotPlus);
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedMousebrotContained': expectedMousebrotContained,
        'actualMousebrotContained': actualMousebrotContained,
        'expectedArrowheadContained': expectedArrowheadContained,
        'actualArrowheadContained': actualArrowheadContained,
        'expectedTetrabrotContained': expectedTetrabrotContained,
        'actualTetrabrotContained': actualTetrabrotContained,
        'passed': actualMousebrotContained == expectedMousebrotContained &&
            actualArrowheadContained == expectedArrowheadContained &&
            actualTetrabrotContained == expectedTetrabrotContained,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'mousebrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static MathOracleResult _evaluateTurtlebrot3D() {
    final cases = <(String, Vector3, bool, bool, bool, bool)>[
      (
        'origin belongs to all four compared slices',
        Vector3.zero(),
        true,
        true,
        true,
        true
      ),
      (
        'Mousebrot point is removed by the reflected intersection',
        Vector3(0.125, -0.75, -0.125),
        false,
        true,
        false,
        false
      ),
      (
        'Turtlebrot point remains outside the other principal slices',
        Vector3(-0.75, -0.25, 0.0),
        true,
        true,
        false,
        false
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (
          name,
          point,
          expectedTurtlebrotContained,
          expectedMousebrotContained,
          expectedArrowheadContained,
          expectedTetrabrotContained
        ) in cases) {
      final complexComponents = [
        Vector2(-point.z, point.x - point.y),
        Vector2(point.z, point.x + point.y),
        Vector2(point.z, point.x - point.y),
        Vector2(-point.z, point.x + point.y),
      ];
      final actualTurtlebrotContained =
          complexComponents.every((c) => !_complexMandelbrotEscapes(c));
      final actualMousebrotContained =
          !_complexMandelbrotEscapes(complexComponents[2]) &&
              !_complexMandelbrotEscapes(complexComponents[3]);
      final arrowMinus = Vector2(point.x - point.z, point.y);
      final arrowPlus = Vector2(point.x + point.z, point.y);
      final actualArrowheadContained = !_complexMandelbrotEscapes(arrowMinus) &&
          !_complexMandelbrotEscapes(arrowPlus);
      final tetrabrotMinus = Vector2(point.x, point.y - point.z);
      final tetrabrotPlus = Vector2(point.x, point.y + point.z);
      final actualTetrabrotContained =
          !_complexMandelbrotEscapes(tetrabrotMinus) &&
              !_complexMandelbrotEscapes(tetrabrotPlus);
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedTurtlebrotContained': expectedTurtlebrotContained,
        'actualTurtlebrotContained': actualTurtlebrotContained,
        'expectedMousebrotContained': expectedMousebrotContained,
        'actualMousebrotContained': actualMousebrotContained,
        'expectedArrowheadContained': expectedArrowheadContained,
        'actualArrowheadContained': actualArrowheadContained,
        'expectedTetrabrotContained': expectedTetrabrotContained,
        'actualTetrabrotContained': actualTetrabrotContained,
        'passed': actualTurtlebrotContained == expectedTurtlebrotContained &&
            actualMousebrotContained == expectedMousebrotContained &&
            actualArrowheadContained == expectedArrowheadContained &&
            actualTetrabrotContained == expectedTetrabrotContained,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'turtlebrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static MathOracleResult _evaluateHourglassbrot3D() {
    final cases = <(String, Vector3, List<bool>)>[
      (
        'origin belongs to all compared slices',
        Vector3.zero(),
        [true, true, true, true, true, true]
      ),
      (
        'Arrowheadbrot copy point is removed by reflection',
        Vector3(-0.5, -0.25, -0.25),
        [false, true, false, false, false, true]
      ),
      (
        'Hourglassbrot point is outside the prior principal slices',
        Vector3(0.5, -0.25, 0.0),
        [true, true, false, false, false, false]
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (name, point, expected) in cases) {
      final hourglassComponents = [
        Vector2(point.y - point.z, point.x),
        Vector2(-point.y + point.z, point.x),
        Vector2(point.y + point.z, point.x),
        Vector2(-point.y - point.z, point.x),
      ];
      final actualHourglassContained =
          hourglassComponents.every((c) => !_complexMandelbrotEscapes(c));
      final actualArrowheadCopyContained =
          !_complexMandelbrotEscapes(hourglassComponents[1]) &&
              !_complexMandelbrotEscapes(hourglassComponents[2]);
      final turtleComponents = [
        Vector2(-point.z, point.x - point.y),
        Vector2(point.z, point.x + point.y),
        Vector2(point.z, point.x - point.y),
        Vector2(-point.z, point.x + point.y),
      ];
      final actualTurtlebrotContained =
          turtleComponents.every((c) => !_complexMandelbrotEscapes(c));
      final actualMousebrotContained =
          !_complexMandelbrotEscapes(turtleComponents[2]) &&
              !_complexMandelbrotEscapes(turtleComponents[3]);
      final actualArrowheadContained =
          !_complexMandelbrotEscapes(Vector2(point.x - point.z, point.y)) &&
              !_complexMandelbrotEscapes(Vector2(point.x + point.z, point.y));
      final actualTetrabrotContained =
          !_complexMandelbrotEscapes(Vector2(point.x, point.y - point.z)) &&
              !_complexMandelbrotEscapes(Vector2(point.x, point.y + point.z));
      final actual = [
        actualHourglassContained,
        actualArrowheadCopyContained,
        actualTurtlebrotContained,
        actualMousebrotContained,
        actualArrowheadContained,
        actualTetrabrotContained,
      ];
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedHourglassContained': expected[0],
        'actualHourglassContained': actual[0],
        'expectedArrowheadCopyContained': expected[1],
        'actualArrowheadCopyContained': actual[1],
        'expectedTurtlebrotContained': expected[2],
        'actualTurtlebrotContained': actual[2],
        'expectedMousebrotContained': expected[3],
        'actualMousebrotContained': actual[3],
        'expectedArrowheadContained': expected[4],
        'actualArrowheadContained': actual[4],
        'expectedTetrabrotContained': expected[5],
        'actualTetrabrotContained': actual[5],
        'passed': List.generate(
          expected.length,
          (index) => actual[index] == expected[index],
        ).every((matches) => matches),
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'hourglassbrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static bool _complexMandelbrotEscapes(Vector2 c) {
    var z = Vector2.zero();
    for (var iteration = 0; iteration < 64; iteration++) {
      z = Vector2(
        z.x * z.x - z.y * z.y + c.x,
        2.0 * z.x * z.y + c.y,
      );
      if (z.length2 > 16.0) return true;
    }
    return false;
  }

  static MathOracleResult _evaluateQuaternionMandelbrot3D() {
    final cases = <(String, Vector3, bool)>[
      ('origin remains bounded', Vector3.zero(), false),
      (
        'negative unit parameter stays in a two-cycle',
        Vector3(-1.0, 0.0, 0.0),
        false
      ),
      ('far real parameter escapes', Vector3(2.0, 0.0, 0.0), true),
    ];
    final checks = <Map<String, Object>>[];
    for (final (name, parameter, expectedEscaped) in cases) {
      final actualEscaped = _quaternionMandelbrotEscapes(parameter);
      checks.add({
        'name': name,
        'parameter': [parameter.x, parameter.y, parameter.z, 0.0],
        'expectedEscaped': expectedEscaped,
        'actualEscaped': actualEscaped,
        'passed': actualEscaped == expectedEscaped,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'quaternion_mandelbrot_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static bool _quaternionMandelbrotEscapes(Vector3 parameter) {
    var z = Vector4.zero();
    final c = Vector4(parameter.x, parameter.y, parameter.z, 0.0);
    for (var iteration = 0; iteration < 32; iteration++) {
      final scalar = z.x * z.x - z.y * z.y - z.z * z.z - z.w * z.w;
      z = Vector4(
        scalar + c.x,
        2.0 * z.x * z.y + c.y,
        2.0 * z.x * z.z + c.z,
        2.0 * z.x * z.w + c.w,
      );
      if (z.length2 > 16.0) return true;
    }
    return false;
  }

  static MathOracleResult _evaluateCantorDust3D() {
    final cases = <(String, Vector3, bool)>[
      ('corner remains in C cubed', Vector3(1.0, 1.0, 1.0), true),
      ('origin lies in the first middle-third gap', Vector3.zero(), false),
      (
        'one middle coordinate excludes the product point',
        Vector3(1.0, 0.0, 1.0),
        false
      ),
    ];
    final checks = <Map<String, Object>>[];
    for (final (name, point, expected) in cases) {
      final actual = _cantorDustContains(point, 12);
      checks.add({
        'name': name,
        'point': [point.x, point.y, point.z],
        'expectedContained': expected,
        'actualContained': actual,
        'passed': actual == expected,
      });
    }

    final failed = checks.where((check) => check['passed'] != true).length;
    return MathOracleResult(
      moduleId: 'cantor_dust_3d',
      verdict: failed == 0 ? 'pass' : 'fail',
      checks: checks,
      reason: failed == 0 ? '' : '$failed reference checks failed',
    );
  }

  static bool _cantorDustContains(Vector3 point, int depth) {
    final coordinates = [point.x, point.y, point.z];
    for (var iteration = 0; iteration < depth; iteration++) {
      for (var axis = 0; axis < coordinates.length; axis++) {
        final coordinate = coordinates[axis];
        if (coordinate < -1.0 || coordinate > 1.0) return false;
        if (coordinate <= -1.0 / 3.0) {
          coordinates[axis] = (coordinate + 2.0 / 3.0) * 3.0;
        } else if (coordinate >= 1.0 / 3.0) {
          coordinates[axis] = (coordinate - 2.0 / 3.0) * 3.0;
        } else {
          return false;
        }
      }
    }
    return true;
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
