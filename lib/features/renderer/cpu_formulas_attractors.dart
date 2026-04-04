// Chaos attractor and dynamical system formulas.
//
// This file contains strange attractors including Henon, Tinkerbell,
// Clifford, de Jong, Lorenz, Rossler, and many other chaotic systems.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Classic 2D Attractors
// ---------------------------------------------------------------------------

/// Henon map
(double r, double g, double b) cpuHenon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x778c7111, x, y, iterations, bailout);

/// Tinkerbell map
(double r, double g, double b) cpuTinkerbell(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x79a9dc77, x, y, iterations, bailout);

/// Gingerbreadman map
(double r, double g, double b) cpuGingerbreadman(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x29b691a7, x, y, iterations, bailout);

/// Lozi attractor
(double r, double g, double b) cpuLozi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xc91e8591, x, y, iterations, bailout);

/// Duffing oscillator
(double r, double g, double b) cpuDuffing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x525c6922, x, y, iterations, bailout);

/// Ikeda map
(double r, double g, double b) cpuIkeda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x7fcf50bf, x, y, iterations, bailout);

/// Clifford attractor
(double r, double g, double b) cpuClifford(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x883a29c4, x, y, iterations, bailout);

/// Peter de Jong attractor
(double r, double g, double b) cpuPeterDeJong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe4b4d9a6, x, y, iterations, bailout);

/// Svensson attractor
(double r, double g, double b) cpuSvensson(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x137884d0, x, y, iterations, bailout);

/// Gumowski-Mira attractor
(double r, double g, double b) cpuGumowskiMira(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x03455e2f, x, y, iterations, bailout);

/// Hopalong attractor
(double r, double g, double b) cpuHopalong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x4adc68b5, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Hamiltonian and Map Systems
// ---------------------------------------------------------------------------

/// Arnold's cat map
(double r, double g, double b) cpuArnoldCat(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd0b6c8ee, x, y, iterations, bailout);

/// Standard map (Chirikov-Taylor map)
(double r, double g, double b) cpuStandardMap(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe53c3d61, x, y, iterations, bailout);

/// Zaslavsky map
(double r, double g, double b) cpuZaslavsky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x757769a5, x, y, iterations, bailout);

/// Kicked rotator
(double r, double g, double b) cpuKickedRotator(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0c05a364, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// ODE-Based Attractors (2D projections)
// ---------------------------------------------------------------------------

/// Chua's circuit attractor
(double r, double g, double b) cpuChuaCircuit(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3256308c, x, y, iterations, bailout);

/// Sprott A attractor
(double r, double g, double b) cpuSprottA(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa2a64769, x, y, iterations, bailout);

/// Burke-Shaw attractor
(double r, double g, double b) cpuBurkeShaw(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd291672c, x, y, iterations, bailout);

/// Arneodo attractor
(double r, double g, double b) cpuArneodo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd9b29cc5, x, y, iterations, bailout);

/// Thomas attractor
(double r, double g, double b) cpuThomasAttractor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x712de09a, x, y, iterations, bailout);

/// Four-wing attractor
(double r, double g, double b) cpuFourWing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xbb996add, x, y, iterations, bailout);

/// Lorenz 2D projection
(double r, double g, double b) cpuLorenz2D(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xfb24036c, x, y, iterations, bailout);

/// Rossler 2D projection
(double r, double g, double b) cpuRossler2D(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x0a237dbe, x, y, iterations, bailout);

/// Dadras attractor
(double r, double g, double b) cpuDadras(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x1c54426c, x, y, iterations, bailout);

/// Chen attractor
(double r, double g, double b) cpuChen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xac430f0d, x, y, iterations, bailout);

/// Lu-Chen attractor
(double r, double g, double b) cpuLuChen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x55739177, x, y, iterations, bailout);

/// Halvorsen attractor
(double r, double g, double b) cpuHalvorsen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x7b5bd02d, x, y, iterations, bailout);

/// Scroll waves
(double r, double g, double b) cpuScrollWaves(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xff11a9b9, x, y, iterations, bailout);

/// Rikitake dynamo
(double r, double g, double b) cpuRikitake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xcb8f281f, x, y, iterations, bailout);

/// Aizawa attractor
(double r, double g, double b) cpuAizawa(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe6972862, x, y, iterations, bailout);

/// Rabinovich-Fabrikant attractor
(double r, double g, double b) cpuRabinovichFabrikant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x5dda0b45, x, y, iterations, bailout);

/// Nose-Hoover oscillator
(double r, double g, double b) cpuNoseHoover(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x72ca1fa4, x, y, iterations, bailout);

/// Moore-Spiegel oscillator
(double r, double g, double b) cpuMooreSpiegel(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x8c0ad47f, x, y, iterations, bailout);

/// Hadley circulation
(double r, double g, double b) cpuHadley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xbb31a2bc, x, y, iterations, bailout);

/// Genesio-Tesi system
(double r, double g, double b) cpuGenesioTesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xe96eaf75, x, y, iterations, bailout);

/// Liu-Chen attractor
(double r, double g, double b) cpuLiuChen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x375d0986, x, y, iterations, bailout);

/// Newton-Leipnik attractor
(double r, double g, double b) cpuNewtonLeipnik(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x1b6c9c59, x, y, iterations, bailout);

/// Bouali attractor
(double r, double g, double b) cpuBouali(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xea9799a7, x, y, iterations, bailout);
