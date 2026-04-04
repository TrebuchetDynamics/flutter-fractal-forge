// Iterated Function System (IFS) fractal formulas.
//
// This file contains IFS-based fractals including Sierpinski variants,
// Koch curves, Barnsley fern, space-filling curves, and tiling patterns.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Sierpinski Variants
// ---------------------------------------------------------------------------

/// Sierpinski triangle
(double r, double g, double b) cpuSierpinskiTriangle(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x2929b303, x, y, iterations, bailout);

/// Sierpinski carpet
(double r, double g, double b) cpuSierpinskiCarpet(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x228b196c, x, y, iterations, bailout);

/// Sierpinski pentagon
(double r, double g, double b) cpuSierpinskiPentagon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xdc1fdb63, x, y, iterations, bailout);

/// Sierpinski arrowhead curve
(double r, double g, double b) cpuSierpinskiArrowhead(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x98394cbe, x, y, iterations, bailout);

/// Sierpinski tetrahedron (3D slice)
(double r, double g, double b) cpuSierpinskiTetrahedron(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9f8d060d, x, y, iterations, bailout);

/// Pola Sierpinski variant
(double r, double g, double b) cpuPolaSierpinski(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x625d23a7, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Koch Curve Variants
// ---------------------------------------------------------------------------

/// Koch snowflake
(double r, double g, double b) cpuKochSnowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa1e241db, x, y, iterations, bailout);

/// Koch anti-snowflake
(double r, double g, double b) cpuKochAntiSnowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xb25939aa, x, y, iterations, bailout);

/// Quadratic Koch island
(double r, double g, double b) cpuQuadraticKochIsland(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x25e42215, x, y, iterations, bailout);

/// Cesaro fractal
(double r, double g, double b) cpuCesaroFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcd174b2c, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Dragon and Related Curves
// ---------------------------------------------------------------------------

/// Dragon curve
(double r, double g, double b) cpuDragonCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xbca4f542, x, y, iterations, bailout);

/// Golden dragon
(double r, double g, double b) cpuGoldenDragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xdb63929a, x, y, iterations, bailout);

/// Twin dragon
(double r, double g, double b) cpuTwinDragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xb1a9736f, x, y, iterations, bailout);

/// Terdragon
(double r, double g, double b) cpuTerdragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd918bb0b, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Levy Curves
// ---------------------------------------------------------------------------

/// Levy C curve
(double r, double g, double b) cpuLevyCCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x59f2294d, x, y, iterations, bailout);

/// Levy tapestry
(double r, double g, double b) cpuLevyTapestry(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0e5c80ba, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Space-Filling Curves
// ---------------------------------------------------------------------------

/// Hilbert curve
(double r, double g, double b) cpuHilbertCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x249cef55, x, y, iterations, bailout);

/// Peano curve
(double r, double g, double b) cpuPeanoCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x30541266, x, y, iterations, bailout);

/// Gosper curve (flowsnake)
(double r, double g, double b) cpuGosperCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x975e1adb, x, y, iterations, bailout);

/// Moore curve
(double r, double g, double b) cpuMooreCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0711c67f, x, y, iterations, bailout);

/// Z-order curve (Morton curve)
(double r, double g, double b) cpuZOrderCurve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe59246f2, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Fern and Plant Fractals
// ---------------------------------------------------------------------------

/// Barnsley fern
(double r, double g, double b) cpuBarnsleyFern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x4a15aae7, x, y, iterations, bailout);

/// Cyclosorus fern
(double r, double g, double b) cpuCyclosorusFern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x23408147, x, y, iterations, bailout);

/// Fractal canopy (tree)
(double r, double g, double b) cpuFractalCanopy(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x765007ef, x, y, iterations, bailout);

/// Pythagorean tree
(double r, double g, double b) cpuPythagoreanTree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa731e992, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Menger and Sponge Variants
// ---------------------------------------------------------------------------

/// Menger sponge 2D slice
(double r, double g, double b) cpuMengerSponge2D(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x6bf8831d, x, y, iterations, bailout);

/// Menger 3D slice
(double r, double g, double b) cpuMenger3DSlice(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9746cd6e, x, y, iterations, bailout);

/// Vicsek fractal
(double r, double g, double b) cpuVicsekFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd698c050, x, y, iterations, bailout);

/// Jerusalem cube
(double r, double g, double b) cpuJerusalemCube(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x5834181b, x, y, iterations, bailout);

/// Cantor dust
(double r, double g, double b) cpuCantorDust(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x02059a93, x, y, iterations, bailout);

/// Cantor set
(double r, double g, double b) cpuCantorSet(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa034897d, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Tiling Patterns
// ---------------------------------------------------------------------------

/// Chair tiling
(double r, double g, double b) cpuChairTiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x6df0635c, x, y, iterations, bailout);

/// Penrose tiling
(double r, double g, double b) cpuPenroseTiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0700c77f, x, y, iterations, bailout);

/// Pinwheel tiling
(double r, double g, double b) cpuPinwheelTiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x54bebb73, x, y, iterations, bailout);

/// Ammann-Beenker tiling
(double r, double g, double b) cpuAmmannBeenker(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x70ba624a, x, y, iterations, bailout);

/// Sphinx tiling
(double r, double g, double b) cpuSphinxTiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x5ad318cf, x, y, iterations, bailout);

/// Hat monotile (einstein tile)
(double r, double g, double b) cpuHatMonotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xfacd86fc, x, y, iterations, bailout);

/// Spectre monotile
(double r, double g, double b) cpuSpectreMonotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x53cd3a9f, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Flake and Hexagonal Variants
// ---------------------------------------------------------------------------

/// Hexaflake
(double r, double g, double b) cpuHexaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x1a63cbae, x, y, iterations, bailout);

/// Pentaflake
(double r, double g, double b) cpuPentaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xefbe3f78, x, y, iterations, bailout);

/// Greek cross fractal
(double r, double g, double b) cpuGreekCrossFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x6a12870e, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Word and Sequence Fractals
// ---------------------------------------------------------------------------

/// Fibonacci word fractal
(double r, double g, double b) cpuFibonacciWord(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x7c59a41c, x, y, iterations, bailout);

/// Rauzy fractal
(double r, double g, double b) cpuRauzyFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x91060bc0, x, y, iterations, bailout);

/// McWorter pentigree
(double r, double g, double b) cpuMcWorterPentigree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x2d7f6ffe, x, y, iterations, bailout);

/// Fibonacci spiral
(double r, double g, double b) cpuFibonacciSpiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa822262d, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Circle and Gasket Fractals
// ---------------------------------------------------------------------------

/// Apollonian gasket
(double r, double g, double b) cpuApollonianGasket(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x8eb91af6, x, y, iterations, bailout);

/// Ford circles
(double r, double g, double b) cpuFordCircles(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x401fd4ea, x, y, iterations, bailout);

/// Steiner chain
(double r, double g, double b) cpuSteinerChain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xc4008f3f, x, y, iterations, bailout);
