/// Minimal complex number type for CPU-side formula evaluation.
///
/// We keep this tiny and allocation-light so we can evolve it into a proper
/// iteration engine later.
class Complex {
  const Complex(this.re, this.im);

  final double re;
  final double im;

  Complex operator +(Complex other) => ComplexArithmeticContract.finiteResult(
      'add', Complex(re + other.re, im + other.im));
  Complex operator -(Complex other) => ComplexArithmeticContract.finiteResult(
      'subtract', Complex(re - other.re, im - other.im));

  Complex operator *(Complex other) => ComplexArithmeticContract.finiteResult(
        'multiply',
        Complex(
          re * other.re - im * other.im,
          re * other.im + im * other.re,
        ),
      );

  Complex operator /(Complex other) {
    final denom = ComplexDivisionContract.denominatorFor(other);
    return ComplexArithmeticContract.finiteResult(
      'divide',
      Complex(
        (re * other.re + im * other.im) / denom,
        (im * other.re - re * other.im) / denom,
      ),
    );
  }

  bool get isFinite => re.isFinite && im.isFinite;

  Complex scale(double s) =>
      ComplexArithmeticContract.finiteResult('scale', Complex(re * s, im * s));

  double abs2() => re * re + im * im;

  @override
  bool operator ==(Object other) =>
      other is Complex && other.re == re && other.im == im;

  @override
  int get hashCode => Object.hash(re, im);

  @override
  String toString() => '($re,$im)';
}

/// Replayable finite-result contract for complex arithmetic.
///
/// FRM numeric literals are finite, but finite operands can still overflow
/// during arithmetic. Keep that invariant at the arithmetic seam so evaluator
/// tests can replay malformed formulas before non-finite state enters vars.
final class ComplexArithmeticContract {
  const ComplexArithmeticContract._();

  static Complex finiteResult(String operation, Complex result) {
    if (result.isFinite) return result;
    throw StateError(
      'Complex arithmetic result must be finite after $operation: $result',
    );
  }
}

/// Replayable denominator contract for complex division.
///
/// FRM evaluation is finite-state: a zero or non-finite divisor previously
/// leaked Infinity/NaN into the variable map. Keep that invariant at the
/// arithmetic seam so parser/evaluator tests can replay malformed formulas.
final class ComplexDivisionContract {
  const ComplexDivisionContract._();

  static double denominatorFor(Complex divisor) {
    final denominator = divisor.abs2();
    if (!divisor.isFinite || denominator == 0.0 || denominator.isNaN) {
      throw StateError(
        'Complex divisor must be finite and non-zero: $divisor',
      );
    }
    return denominator;
  }
}
