import 'complex.dart';

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
    final r = re.eval(ctx).re;
    final i = im.eval(ctx).re;
    return Complex(r, i);
  }
}

final class FrmVar extends FrmExpr {
  const FrmVar(this.name);

  final String name;

  @override
  Complex eval(FrmEvalContext ctx) => ctx.vars[name] ?? (throw StateError('Unknown var: $name'));
}

enum FrmBinaryOp { add, sub, mul, div }

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
  const FrmFormula({required this.name, required this.init, required this.iter});

  final String name;

  /// Statements before `:`
  final List<FrmStmt> init;

  /// Statements after `:`
  final List<FrmStmt> iter;
}

final class FrmFile {
  const FrmFile(this.formulas);

  final List<FrmFormula> formulas;
}
