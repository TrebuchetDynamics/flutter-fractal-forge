/// Minimal complex number type for CPU-side formula evaluation.
///
/// We keep this tiny and allocation-light so we can evolve it into a proper
/// iteration engine later.
class Complex {
  const Complex(this.re, this.im);

  final double re;
  final double im;

  Complex operator +(Complex other) => Complex(re + other.re, im + other.im);
  Complex operator -(Complex other) => Complex(re - other.re, im - other.im);

  Complex operator *(Complex other) => Complex(
        re * other.re - im * other.im,
        re * other.im + im * other.re,
      );

  Complex operator /(Complex other) {
    final denom = other.re * other.re + other.im * other.im;
    return Complex(
      (re * other.re + im * other.im) / denom,
      (im * other.re - re * other.im) / denom,
    );
  }

  Complex scale(double s) => Complex(re * s, im * s);

  double abs2() => re * re + im * im;

  @override
  String toString() => '($re,$im)';
}
