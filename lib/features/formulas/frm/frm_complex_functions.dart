import 'dart:math' as math;

import 'complex.dart';

/// Complex function callable from FRM `name(args...)` calls.
typedef FrmComplexFunction = Complex Function(List<Complex> args);

Complex _arg1(String name, List<Complex> args) {
  if (args.length != 1) {
    throw StateError('$name expects 1 argument, got ${args.length}');
  }
  return args.first;
}

Complex _real(double v) =>
    ComplexArithmeticContract.finiteResult('real', Complex(v, 0));

/// `z^2`, kept exact (z*z) rather than going through exp/log.
Complex cSqr(Complex z) => z * z;

/// Modulus `|z|`, returned as a real-valued complex `(|z|, 0)`.
Complex cAbs(Complex z) => _real(math.sqrt(z.abs2()));

/// Squared modulus `|z|^2`, returned as a real-valued complex `(|z|^2, 0)`.
/// Matches the Fractint `|z|` bailout convention.
Complex cAbs2(Complex z) => _real(z.abs2());

/// Complex conjugate `(re, -im)`.
Complex cConj(Complex z) =>
    ComplexArithmeticContract.finiteResult('conj', Complex(z.re, -z.im));

/// Swap real and imaginary parts `(im, re)` (Fractint `flip`).
Complex cFlip(Complex z) =>
    ComplexArithmeticContract.finiteResult('flip', Complex(z.im, z.re));

/// Real part as a real-valued complex `(re, 0)`.
Complex cRealPart(Complex z) => _real(z.re);

/// Imaginary part as a real-valued complex `(im, 0)`.
Complex cImagPart(Complex z) => _real(z.im);

/// `e^z = e^re * (cos(im), sin(im))`.
Complex cExp(Complex z) {
  final e = math.exp(z.re);
  return ComplexArithmeticContract.finiteResult(
      'exp', Complex(e * math.cos(z.im), e * math.sin(z.im)));
}

/// Principal complex logarithm `(0.5*ln(|z|^2), atan2(im, re))`.
Complex cLog(Complex z) {
  final r2 = z.abs2();
  if (r2 == 0.0) {
    throw StateError('log of zero is undefined');
  }
  return ComplexArithmeticContract.finiteResult(
      'log', Complex(0.5 * math.log(r2), math.atan2(z.im, z.re)));
}

Complex cSin(Complex z) => ComplexArithmeticContract.finiteResult(
    'sin', Complex(math.sin(z.re) * _cosh(z.im), math.cos(z.re) * _sinh(z.im)));

Complex cCos(Complex z) => ComplexArithmeticContract.finiteResult('cos',
    Complex(math.cos(z.re) * _cosh(z.im), -math.sin(z.re) * _sinh(z.im)));

Complex cSinh(Complex z) => ComplexArithmeticContract.finiteResult('sinh',
    Complex(_sinh(z.re) * math.cos(z.im), _cosh(z.re) * math.sin(z.im)));

Complex cCosh(Complex z) => ComplexArithmeticContract.finiteResult('cosh',
    Complex(_cosh(z.re) * math.cos(z.im), _sinh(z.re) * math.sin(z.im)));

double _sinh(double x) => (math.exp(x) - math.exp(-x)) * 0.5;
double _cosh(double x) => (math.exp(x) + math.exp(-x)) * 0.5;

/// `a^b`. For a real non-negative integer exponent this is exact repeated
/// multiplication (so `z^2` equals `z*z`); otherwise `exp(b * log(a))`.
Complex cPow(Complex a, Complex b) {
  if (b.im == 0.0 && b.re >= 0 && b.re == b.re.roundToDouble() && b.re <= 64) {
    final n = b.re.toInt();
    var result = const Complex(1, 0);
    for (var i = 0; i < n; i++) {
      result = result * a;
    }
    return result;
  }
  return cExp(b * cLog(a));
}

/// Registry of FRM-callable complex functions by name.
final Map<String, FrmComplexFunction> frmComplexFunctions = {
  'sqr': (a) => cSqr(_arg1('sqr', a)),
  'cabs': (a) => cAbs(_arg1('cabs', a)),
  'cabs2': (a) => cAbs2(_arg1('cabs2', a)),
  'conj': (a) => cConj(_arg1('conj', a)),
  'flip': (a) => cFlip(_arg1('flip', a)),
  'real': (a) => cRealPart(_arg1('real', a)),
  'imag': (a) => cImagPart(_arg1('imag', a)),
  'exp': (a) => cExp(_arg1('exp', a)),
  'log': (a) => cLog(_arg1('log', a)),
  'sin': (a) => cSin(_arg1('sin', a)),
  'cos': (a) => cCos(_arg1('cos', a)),
  'sinh': (a) => cSinh(_arg1('sinh', a)),
  'cosh': (a) => cCosh(_arg1('cosh', a)),
};
