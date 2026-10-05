import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy Julia and Burning Ship preserve smooth escape coloring', () {
    final cases = <({String path, String recurrence})>[
      (
        path: 'shaders/legacy/escape_time/julia.frag',
        recurrence: r'z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;',
      ),
      (
        path: 'shaders/legacy/escape_time/burning_ship.frag',
        recurrence: 'z = vec2(abs(z.x), abs(z.y));\n'
            '        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;',
      ),
    ];

    for (final shaderCase in cases) {
      final source = File(shaderCase.path).readAsStringSync();
      expect(source, contains(shaderCase.recurrence),
          reason: '${shaderCase.path} recurrence');
      expect(
        RegExp(
          r'if\s*\(dot\(z,\s*z\)\s*>\s*bailoutSq\)\s*\{\s*// Smooth iteration count\s*iterations\s*=\s*float\(i\)\s*-\s*log2\(log2\(dot\(z,\s*z\)\)\)\s*\+\s*4\.0\s*;\s*break\s*;',
        ).hasMatch(source),
        isTrue,
        reason: '${shaderCase.path} derives smooth iteration on escape',
      );
      expect(
        RegExp(r'float\s+t\s*=\s*iterations\s*/\s*uIterations')
            .hasMatch(source),
        isTrue,
        reason: '${shaderCase.path} colors using the smooth iteration value',
      );

      final insideBranch = source.indexOf('// Inside the set');
      expect(insideBranch, greaterThanOrEqualTo(0), reason: shaderCase.path);
      expect(
        RegExp(
          r'// Inside the set[\s\S]*?if\s*\(uTransparentBg\s*>\s*0\.5\)\s*\{\s*fragColor\s*=\s*vec4\(0\.0,\s*0\.0,\s*0\.0,\s*0\.0\);\s*\}\s*else\s*\{\s*fragColor\s*=\s*vec4\(0\.0,\s*0\.0,\s*0\.0,\s*1\.0\);',
        ).hasMatch(source.substring(insideBranch)),
        isTrue,
        reason: '${shaderCase.path} keeps inside-set output distinct',
      );
    }
  });
}
