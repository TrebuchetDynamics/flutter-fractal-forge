import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/cpu/cpu_coloring.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart'
    show CpuFormula;
import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart'
    show renderCpuRectRgba;

import 'complex.dart';
import 'frm_ast.dart';
import 'frm_parser.dart';

/// Escape-time interpreter for a parsed [FrmFormula], adapted to the CPU
/// renderer's [CpuFormula] contract so FRM formulas reuse the existing
/// (anti-aliased, NaN-safe) CPU pixel loop.
///
/// Convention (the FRM subset has no bailout/comparison syntax yet):
/// - The pixel position is bound to the variable `pixel`.
/// - The formula's `init` section runs once; the `iter` section is the
///   recurrence.
/// - The iterated value is the variable `z`. Escape is `|z|^2 > bailout^2`,
///   checked before each `iter` step, exactly like the native [escapeTime]
///   engine — so e.g. `Mandelbrot { z=(0,0) c=pixel : z=z*z+c }` matches the
///   built-in Mandelbrot pixel-for-pixel.
/// - Colouring reuses [smoothEscape] + [palette]; interior points use
///   [kInsideColor].
CpuFormula frmAsCpuFormula(FrmFormula formula) {
  return (double x, double y, int iterations, double bailout, _) {
    try {
      final ctx = FrmEvalContext(vars: {'pixel': Complex(x, y)});
      for (final stmt in formula.init) {
        stmt.run(ctx);
      }

      final bailout2 = bailout * bailout;
      var it = 0;
      while (it < iterations) {
        final z = ctx.vars['z'];
        // A formula that never assigns `z` cannot escape; treat as interior.
        if (z == null) return kInsideColor;
        if (z.abs2() > bailout2) break;
        for (final stmt in formula.iter) {
          stmt.run(ctx);
        }
        it++;
      }

      if (it >= iterations) return kInsideColor;
      final z = ctx.vars['z'] ?? const Complex(0, 0);
      return palette(smoothEscape(it: it, mag2: z.abs2()));
    } catch (_) {
      // Eval errors (non-finite arithmetic, divide-by-zero, unknown variable)
      // colour as interior so one bad pixel cannot abort the whole tile.
      return kInsideColor;
    }
  };
}

/// Replayable, isolate-sendable request to render a parsed FRM formula to RGBA.
///
/// Holds only primitives + the formula source string so it can cross an
/// `Isolate.run` boundary; the source is parsed on the worker side.
class FrmRenderRequest {
  const FrmRenderRequest({
    required this.source,
    this.formulaName,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.width,
    required this.height,
    required this.iterations,
    required this.bailout,
    this.sampleCount = 1,
  });

  final String source;
  final String? formulaName;
  final double panX;
  final double panY;
  final double zoom;
  final int width;
  final int height;
  final int iterations;
  final double bailout;
  final int sampleCount;
}

/// Parses [FrmRenderRequest.source] and renders the selected formula to an RGBA
/// byte buffer. Top-level + sendable, so it is suitable for `Isolate.run`.
///
/// Throws [FormatException] for parse errors or an unknown formula name.
Uint8List renderFrmImageBytes(FrmRenderRequest req) {
  final file = FrmParser(req.source).parseFile();
  if (file.formulas.isEmpty) {
    throw const FormatException('FRM source defines no formula');
  }
  final name = req.formulaName;
  final formula = name == null
      ? file.formulas.first
      : file.formulas.firstWhere(
          (f) => f.name == name,
          orElse: () => throw FormatException('Formula "$name" not found'),
        );

  return renderCpuRectRgba(
    moduleId: '',
    panX: req.panX,
    panY: req.panY,
    zoom: req.zoom,
    iterations: req.iterations,
    bailout: req.bailout,
    juliaCX: 0,
    juliaCY: 0,
    fullWidth: req.width,
    fullHeight: req.height,
    x0: 0,
    y0: 0,
    w: req.width,
    h: req.height,
    sampleCount: req.sampleCount,
    formulaOverride: frmAsCpuFormula(formula),
  );
}
