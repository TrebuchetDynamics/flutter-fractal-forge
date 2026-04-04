// Cellular automata and discrete system formulas.
//
// This file contains cellular automata including Wolfram rules, Langton's Ant,
// Conway variants, sandpile model, DLA, and other discrete systems.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Elementary Cellular Automata
// ---------------------------------------------------------------------------

/// Wolfram Rule 30
(double r, double g, double b) cpuWolframRule30(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x48c5a56d, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Turing Machines and Ants
// ---------------------------------------------------------------------------

/// Langton's Ant
(double r, double g, double b) cpuLangtonAnt(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x11322f64, x, y, iterations, bailout);

/// Turmite (2D Turing machine)
(double r, double g, double b) cpuTurmite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x2abcb0ad, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Wireworld and Circuit CA
// ---------------------------------------------------------------------------

/// Wireworld cellular automaton
(double r, double g, double b) cpuWireworld(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x20ea286c, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Sandpile and Aggregation Models
// ---------------------------------------------------------------------------

/// Abelian sandpile model
(double r, double g, double b) cpuSandpile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x63d0ec33, x, y, iterations, bailout);

/// Diffusion-limited aggregation (DLA)
(double r, double g, double b) cpuDla(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xd86f62c4, x, y, iterations, bailout);

/// Eden growth model
(double r, double g, double b) cpuEdenGrowth(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x4688b46f, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Forest Fire and Percolation
// ---------------------------------------------------------------------------

/// Forest fire model
(double r, double g, double b) cpuForestFire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3c6b4651, x, y, iterations, bailout);

/// Percolation clusters
(double r, double g, double b) cpuPercolation(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x89fd7427, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Conway's Game of Life Variants
// ---------------------------------------------------------------------------

/// Brian's Brain (3-state CA)
(double r, double g, double b) cpuBrianBrain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9992a380, x, y, iterations, bailout);

/// HighLife (B36/S23)
(double r, double g, double b) cpuHighlife(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xbea6f8f7, x, y, iterations, bailout);

/// Day & Night (B3678/S34678)
(double r, double g, double b) cpuDayNight(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x3df8bb28, x, y, iterations, bailout);
