// Hypercomplex and transcendental fractal formulas.
//
// Quaternion, tessarine, split-complex, and transcendental functions.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Hypercomplex and Alternative Algebras
// ---------------------------------------------------------------------------

/// Quaternion Julia (2D slice)
(double r, double g, double b) cpuQuaternionJulia2D(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa84d05ce, x, y, iterations, bailout);

/// Tessarine Julia (commutative quaternion)
(double r, double g, double b) cpuTessarineJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x064d1891, x, y, iterations, bailout);

/// Split-complex Julia
(double r, double g, double b) cpuSplitComplex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xc0997e48, x, y, iterations, bailout);

/// Dual complex Julia
(double r, double g, double b) cpuDualComplex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xeea179bc, x, y, iterations, bailout);

/// Bicomplex Julia
(double r, double g, double b) cpuBicomplex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0fd158d8, x, y, iterations, bailout);

/// Hypercomplex Newton
(double r, double g, double b) cpuHypercomplexNewton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9e35f04b, x, y, iterations, bailout);

/// Pseudo-Kleinian (3D slice)
(double r, double g, double b) cpuPseudoKleinian(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x60267e4f, x, y, iterations, bailout);

/// Benesi attractor
(double r, double g, double b) cpuBenesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x364b1039, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Transcendental Functions
// ---------------------------------------------------------------------------

/// Sine Julia: z = sin(z) + c
(double r, double g, double b) cpuSineJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9db1fa6a, x, y, iterations, bailout);

/// Cosine Julia: z = cos(z) + c
(double r, double g, double b) cpuCosineJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x22f495bc, x, y, iterations, bailout);

/// Tangent fractal
(double r, double g, double b) cpuTangent(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x262d6902, x, y, iterations, bailout);

/// Sinh-Cosh fractal
(double r, double g, double b) cpuSinhCosh(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x12a65771, x, y, iterations, bailout);

/// Exponential fractal: z = exp(z) + c
(double r, double g, double b) cpuExponential(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x05804268, x, y, iterations, bailout);

/// Cosine Mandelbrot
(double r, double g, double b) cpuCosineMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe945eae9, x, y, iterations, bailout);

/// Tangent Mandelbrot
(double r, double g, double b) cpuTangentMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe80b7a69, x, y, iterations, bailout);

/// Sinh Mandelbrot
(double r, double g, double b) cpuSinhMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcfdc9102, x, y, iterations, bailout);

/// Cosh Mandelbrot
(double r, double g, double b) cpuCoshMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3c5b7343, x, y, iterations, bailout);

/// Tanh Mandelbrot
(double r, double g, double b) cpuTanhMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf5531caf, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Lyapunov Fractals
// ---------------------------------------------------------------------------

/// Lyapunov exponent fractal
(double r, double g, double b) cpuLyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x92b5be81, x, y, iterations, bailout);

/// Logistic map Lyapunov
(double r, double g, double b) cpuLogisticLyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xeaeefa74, x, y, iterations, bailout);

/// Circle map Lyapunov
(double r, double g, double b) cpuCircleMapLyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x4b9e0d5d, x, y, iterations, bailout);

/// Sine map Lyapunov
(double r, double g, double b) cpuSineMapLyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xaec39f66, x, y, iterations, bailout);

/// Tent map
(double r, double g, double b) cpuTentMap(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcf2f7eb9, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Biomorphs and Special Functions
// ---------------------------------------------------------------------------

/// Pickover biomorph
(double r, double g, double b) cpuPickoverBiomorph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcf4ed2b3, x, y, iterations, bailout);

/// Feigenbaum diagram
(double r, double g, double b) cpuFeigenbaum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xc2e8a39c, x, y, iterations, bailout);

/// Gauss map
(double r, double g, double b) cpuGaussMap(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x7c5536a3, x, y, iterations, bailout);

/// Zircon Zity fractal
(double r, double g, double b) cpuZirconZity(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x95abf6e5, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Special Geometric Fractals
// ---------------------------------------------------------------------------

/// Logarithmic spiral
(double r, double g, double b) cpuLogSpiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xbea6fea3, x, y, iterations, bailout);

/// Heart fractal
(double r, double g, double b) cpuHeart(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0eaa25e3, x, y, iterations, bailout);

/// Farey diagram
(double r, double g, double b) cpuFareyDiagram(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd95c5726, x, y, iterations, bailout);

/// Cayley graph
(double r, double g, double b) cpuCayleyGraph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe7efe891, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Barnsley Julia Variants
// ---------------------------------------------------------------------------

/// Barnsley Julia J1
(double r, double g, double b) cpuBarnsleyJ1(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf0391b23, x, y, iterations, bailout);

/// Barnsley Julia J2
(double r, double g, double b) cpuBarnsleyJ2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf1391cb6, x, y, iterations, bailout);

/// Barnsley Julia J3
(double r, double g, double b) cpuBarnsleyJ3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf2391e49, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Fish, Duck and Special Polynomials
// ---------------------------------------------------------------------------

/// Fish fractal
(double r, double g, double b) cpuFish(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xafad8963, x, y, iterations, bailout);

/// Ducky fractal
(double r, double g, double b) cpuDucky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xb1064a93, x, y, iterations, bailout);

/// Schroeder iteration
(double r, double g, double b) cpuSchroeder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x19df4580, x, y, iterations, bailout);

/// Secant fractal
(double r, double g, double b) cpuSecantFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcdfe1f35, x, y, iterations, bailout);

/// Secant-cosecant fractal
(double r, double g, double b) cpuSecantCosecant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd9996fb8, x, y, iterations, bailout);

/// Taylor series fractal
(double r, double g, double b) cpuTaylor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xb23e7192, x, y, iterations, bailout);

/// Rational map
(double r, double g, double b) cpuRationalMap(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x243fe48a, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Orthogonal Polynomial Variants
// ---------------------------------------------------------------------------

/// Chebyshev polynomial fractal
(double r, double g, double b) cpuChebyshev(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe6f02d6c, x, y, iterations, bailout);

/// Legendre polynomial fractal
(double r, double g, double b) cpuLegendre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3bea1b45, x, y, iterations, bailout);

/// Laguerre polynomial fractal
(double r, double g, double b) cpuLaguerre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x62e5b688, x, y, iterations, bailout);

/// Hermite polynomial fractal
(double r, double g, double b) cpuHermite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9c265311, x, y, iterations, bailout);

/// Virial fractal
(double r, double g, double b) cpuVirial(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x1ab95258, x, y, iterations, bailout);

/// Lambda W function
(double r, double g, double b) cpuLambdaW(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x1bd55c48, x, y, iterations, bailout);

/// Riemann Zeta function visualization
(double r, double g, double b) cpuRiemannZeta(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xb4f73498, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Advanced Variants
// ---------------------------------------------------------------------------

/// Spider X variant
(double r, double g, double b) cpuSpiderX(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf91becf7, x, y, iterations, bailout);

/// Popcorn 2 variant
(double r, double g, double b) cpuPopcorn2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3b8af928, x, y, iterations, bailout);

/// Manair fire fractal
(double r, double g, double b) cpuManairFire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x2d04490e, x, y, iterations, bailout);
