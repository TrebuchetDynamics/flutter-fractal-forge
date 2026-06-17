import 'complex.dart';
import 'frm_complex_functions.dart';

sealed class FrmExpr {
  const FrmExpr();

  Complex eval(FrmEvalContext ctx);
}

final class FrmNumber extends FrmExpr {
  const FrmNumber(this.value);

  final double value;

  @override
  Complex eval(FrmEvalContext ctx) => Complex(value, 0);
}

final class FrmComplexLiteral extends FrmExpr {
  const FrmComplexLiteral(this.re, this.im);

  final FrmExpr re;
  final FrmExpr im;

  @override
  Complex eval(FrmEvalContext ctx) {
    final r = evalFrmRealScalarComponent(re, ctx, componentName: 'real');
    final i = evalFrmRealScalarComponent(im, ctx, componentName: 'imaginary');
    return Complex(r, i);
  }
}

/// Evaluates one component of a `(real, imaginary)` literal.
///
/// FRM complex literal components are scalar slots. Silently taking `.re` from
/// a complex-valued expression drops data and makes replay depend on an
/// undocumented truncation rule, so reject that shape at the evaluation seam.
double evalFrmRealScalarComponent(
  FrmExpr expr,
  FrmEvalContext ctx, {
  required String componentName,
}) {
  final value = expr.eval(ctx);
  if (value.im == 0.0) return value.re;
  throw StateError(
    'Complex literal components must evaluate to real scalars; '
    '$componentName component was $value',
  );
}

final class FrmVar extends FrmExpr {
  const FrmVar(this.name);

  final String name;

  @override
  Complex eval(FrmEvalContext ctx) =>
      ctx.vars[name] ?? (throw StateError('Unknown var: $name'));
}

enum FrmBinaryOp { add, sub, mul, div, pow }

final class FrmBinary extends FrmExpr {
  const FrmBinary(this.op, this.left, this.right);

  final FrmBinaryOp op;
  final FrmExpr left;
  final FrmExpr right;

  @override
  Complex eval(FrmEvalContext ctx) {
    final a = left.eval(ctx);
    final b = right.eval(ctx);
    return switch (op) {
      FrmBinaryOp.add => a + b,
      FrmBinaryOp.sub => a - b,
      FrmBinaryOp.mul => a * b,
      FrmBinaryOp.div => a / b,
      FrmBinaryOp.pow => cPow(a, b),
    };
  }
}

/// A call to a built-in complex function, e.g. `sin(z)` or `conj(z+c)`.
final class FrmCall extends FrmExpr {
  const FrmCall(this.name, this.args);

  final String name;
  final List<FrmExpr> args;

  @override
  Complex eval(FrmEvalContext ctx) {
    final fn = frmComplexFunctions[name];
    if (fn == null) {
      throw StateError('Unknown function: $name');
    }
    return fn(args.map((a) => a.eval(ctx)).toList());
  }
}

/// Comparison operators usable in a bailout condition.
enum FrmCmpOp { lt, le, gt, ge, eq, ne }

/// A formula's escape test, e.g. `cabs2(z) <= 4`.
///
/// Iteration continues *while* this condition is true (Fractint convention), so
/// the engine escapes the pixel when [test] first returns false. Both sides must
/// evaluate to real scalars — comparing complex magnitudes is what these
/// conditions express, and silently dropping an imaginary part would make replay
/// depend on an undocumented truncation rule (same contract as a complex
/// literal's components).
final class FrmBailout {
  const FrmBailout(this.left, this.op, this.right);

  final FrmExpr left;
  final FrmCmpOp op;
  final FrmExpr right;

  bool test(FrmEvalContext ctx) {
    final a = evalFrmRealScalarComponent(left, ctx,
        componentName: 'left side of bailout comparison');
    final b = evalFrmRealScalarComponent(right, ctx,
        componentName: 'right side of bailout comparison');
    return switch (op) {
      FrmCmpOp.lt => a < b,
      FrmCmpOp.le => a <= b,
      FrmCmpOp.gt => a > b,
      FrmCmpOp.ge => a >= b,
      FrmCmpOp.eq => a == b,
      FrmCmpOp.ne => a != b,
    };
  }
}

sealed class FrmStmt {
  const FrmStmt();

  void run(FrmEvalContext ctx);
}

final class FrmAssign extends FrmStmt {
  const FrmAssign(this.name, this.expr);

  final String name;
  final FrmExpr expr;

  @override
  void run(FrmEvalContext ctx) {
    ctx.vars[name] = expr.eval(ctx);
  }
}

/// Execution context for a single pixel / iteration.
final class FrmEvalContext {
  FrmEvalContext({required this.vars});

  final Map<String, Complex> vars;
}

final class FrmFormula {
  FrmFormula({
    required this.name,
    required Iterable<FrmStmt> init,
    required Iterable<FrmStmt> iter,
    this.bailout,
  })  : init = List.unmodifiable(init),
        iter = List.unmodifiable(iter);

  final String name;

  /// Statements before `:`
  final List<FrmStmt> init;

  /// Statements after `:`
  final List<FrmStmt> iter;

  /// Optional explicit escape test from the iter section. When null the engine
  /// falls back to the default `|z|^2 > bailout^2`.
  final FrmBailout? bailout;
}

final class FrmFile {
  FrmFile(Iterable<FrmFormula> formulas)
      : formulas = List.unmodifiable(formulas);

  final List<FrmFormula> formulas;
}
