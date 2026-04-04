// CPU formula implementations for escape-time catalog modules.
//
// This file is now a barrel export that consolidates all CPU formula
// implementations split by fractal family. The formulas are organized into:
// - Core: Mandelbrot, Julia, Burning Ship, Celtic, Buffalo, etc.
// - IFS: Sierpinski, Koch, Barnsley fern, space-filling curves
// - Attractors: Henon, Tinkerbell, Clifford, Lorenz, etc.
// - Cellular: Wolfram, Langton's Ant, Conway variants
// - Newton: Newton's method, Halley, Householder, Magnet fractals
// - Extended: Transcendental, Lyapunov, Biomorphs, etc.
//
// NOTE: The CPU path mirrors the core recurrence / iteration logic from the
// corresponding GPU shaders under shaders/*.frag. It's a correctness-oriented
// fallback used when GPU shaders are unavailable.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';
import 'cpu_formulas_mandelbrot.dart';
import 'cpu_formulas_variants.dart';
import 'cpu_formulas_ifs.dart';
import 'cpu_formulas_attractors.dart';
import 'cpu_formulas_cellular.dart';
import 'cpu_formulas_newton.dart';
import 'cpu_formulas_transcendental.dart';
import 'cpu_formulas_advanced.dart';

export 'cpu_formulas_utils.dart' show CpuFormula, insideColor;
export 'cpu_formulas_mandelbrot.dart';
export 'cpu_formulas_variants.dart';
export 'cpu_formulas_ifs.dart';
export 'cpu_formulas_attractors.dart';
export 'cpu_formulas_cellular.dart';
export 'cpu_formulas_newton.dart';
export 'cpu_formulas_transcendental.dart';
export 'cpu_formulas_advanced.dart';

// ---------------------------------------------------------------------------
// Registry of all CPU formulas by module id
// ---------------------------------------------------------------------------

/// Registry of CPU formulas by module id (escape-time catalog + custom modules).
final Map<String, CpuFormula> cpuFormulasByModuleId = <String, CpuFormula>{
  // Core Mandelbrot family
  'mandelbrot': cpuMandelbrot,
  'julia': cpuJulia,
  'phoenix': cpuPhoenix,
  'burning_ship': cpuBurningShip,
  'burning_ship_cubic': cpuBurningShipCubic,
  'burning_ship_power4': cpuBurningShipPower4,
  'burning_ship_power5': cpuBurningShipPower5,
  'burning_ship_power6': cpuBurningShipPower6,
  'burning_ship_power7': cpuBurningShipPower7,
  'burning_ship_julia': cpuBurningShipJulia,
  'tricorn': cpuTricorn,
  'tricorn_julia': cpuTricornJulia,
  'celtic': cpuCeltic,
  'celtic_cubic': cpuCelticCubic,
  'celtic_power4': cpuCelticPower4,
  'celtic_power5': cpuCelticPower5,
  'celtic_julia': cpuCelticJulia,
  'buffalo': cpuBuffalo,
  'buffalo_cubic': cpuBuffaloCubic,
  'buffalo_julia': cpuBuffaloJulia,
  'multibrot3': cpuMultibrot3,
  'multibrot4': cpuMultibrot4,
  'multibrot5': cpuMultibrot5,
  'multibrot_neg2': cpuMultibrotNeg2,
  'perpendicular_mandelbrot': cpuPerpendicularMandelbrot,
  'perpendicular_julia': cpuPerpendicularJulia,

  // Nova and related
  'nova': cpuNova,
  'nova_julia': cpuNovaJulia,
  'fatou': cpuFatou,
  'gamma_fractal': cpuGammaFractal,
  'lambda': cpuLambda,

  // Magnet fractals
  'magnet_type_1': cpuMagnetType1,
  'magnet_type_2': cpuMagnetType2,
  'magnet_type_3': cpuMagnetType3,
  'magnet_newton': cpuMagnetNewton,

  // Polynomial variants
  'power_sum': cpuPowerSum,
  'cactus': cpuCactus,
  'druid': cpuDruid,
  'astroid': cpuAstroid,
  'deltoid': cpuDeltoid,
  'inverse_mandelbrot': cpuInverseMandelbrot,
  'glynn': cpuGlynn,
  'simonbrot': cpuSimonbrot,
  'shark_fin': cpuSharkFin,
  'manowar': cpuManowar,
  'spider': cpuSpider,

  // Special recurrence
  'collatz': cpuCollatz,
  'popcorn': cpuPopcorn,
  'popcorn2': cpuPopcorn2,
  'talis': cpuTalis,
  'tetration': cpuTetration,
  'eisenstein': cpuEisenstein,

  // IFS fractals
  'sierpinski_triangle': cpuSierpinskiTriangle,
  'sierpinski_carpet': cpuSierpinskiCarpet,
  'sierpinski_pentagon': cpuSierpinskiPentagon,
  'sierpinski_arrowhead': cpuSierpinskiArrowhead,
  'sierpinski_tetrahedron': cpuSierpinskiTetrahedron,
  'pola_sierpinski': cpuPolaSierpinski,
  'koch_snowflake': cpuKochSnowflake,
  'koch_anti_snowflake': cpuKochAntiSnowflake,
  'quadratic_koch_island': cpuQuadraticKochIsland,
  'dragon_curve': cpuDragonCurve,
  'golden_dragon': cpuGoldenDragon,
  'twin_dragon': cpuTwinDragon,
  'terdragon': cpuTerdragon,
  'levy_c_curve': cpuLevyCCurve,
  'levy_tapestry': cpuLevyTapestry,
  'hilbert_curve': cpuHilbertCurve,
  'peano_curve': cpuPeanoCurve,
  'gosper_curve': cpuGosperCurve,
  'moore_curve': cpuMooreCurve,
  'z_order_curve': cpuZOrderCurve,
  'barnsley_fern': cpuBarnsleyFern,
  'cyclosorus_fern': cpuCyclosorusFern,
  'fractal_canopy': cpuFractalCanopy,
  'pythagorean_tree': cpuPythagoreanTree,
  'menger_sponge_2d': cpuMengerSponge2D,
  'menger_3d_slice': cpuMenger3DSlice,
  'vicsek_fractal': cpuVicsekFractal,
  'jerusalem_cube': cpuJerusalemCube,
  'cantor_dust': cpuCantorDust,
  'cantor_set': cpuCantorSet,
  'chair_tiling': cpuChairTiling,
  'penrose_tiling': cpuPenroseTiling,
  'pinwheel_tiling': cpuPinwheelTiling,
  'ammann_beenker': cpuAmmannBeenker,
  'sphinx_tiling': cpuSphinxTiling,
  'hat_monotile': cpuHatMonotile,
  'spectre_monotile': cpuSpectreMonotile,
  'hexaflake': cpuHexaflake,
  'pentaflake': cpuPentaflake,
  'greek_cross_fractal': cpuGreekCrossFractal,
  'fibonacci_word': cpuFibonacciWord,
  'fibonacci_spiral': cpuFibonacciSpiral,
  'rauzy_fractal': cpuRauzyFractal,
  'mcworter_pentigree': cpuMcWorterPentigree,
  'apollonian_gasket': cpuApollonianGasket,
  'ford_circles': cpuFordCircles,
  'steiner_chain': cpuSteinerChain,
  'cesaro_fractal': cpuCesaroFractal,

  // Chaos attractors
  'henon': cpuHenon,
  'tinkerbell': cpuTinkerbell,
  'gingerbreadman': cpuGingerbreadman,
  'lozi': cpuLozi,
  'duffing': cpuDuffing,
  'ikeda': cpuIkeda,
  'clifford': cpuClifford,
  'peter_de_jong': cpuPeterDeJong,
  'svensson': cpuSvensson,
  'gumowski_mira': cpuGumowskiMira,
  'hopalong': cpuHopalong,
  'arnold_cat': cpuArnoldCat,
  'standard_map': cpuStandardMap,
  'zaslavsky': cpuZaslavsky,
  'kicked_rotator': cpuKickedRotator,
  'chua_circuit': cpuChuaCircuit,
  'sprott_a': cpuSprottA,
  'burke_shaw': cpuBurkeShaw,
  'arneodo': cpuArneodo,
  'thomas_attractor': cpuThomasAttractor,
  'four_wing': cpuFourWing,
  'lorenz_2d': cpuLorenz2D,
  'rossler_2d': cpuRossler2D,
  'dadras': cpuDadras,
  'chen': cpuChen,
  'lu_chen': cpuLuChen,
  'halvorsen': cpuHalvorsen,
  'scroll_waves': cpuScrollWaves,
  'rikitake': cpuRikitake,
  'aizawa': cpuAizawa,
  'rabinovich_fabrikant': cpuRabinovichFabrikant,
  'nose_hoover': cpuNoseHoover,
  'moore_spiegel': cpuMooreSpiegel,
  'hadley': cpuHadley,
  'genesio_tesi': cpuGenesioTesi,
  'liu_chen': cpuLiuChen,
  'newton_leipnik': cpuNewtonLeipnik,
  'bouali': cpuBouali,

  // Cellular automata
  'wolfram_rule30': cpuWolframRule30,
  'langton_ant': cpuLangtonAnt,
  'turmite': cpuTurmite,
  'wireworld': cpuWireworld,
  'sandpile': cpuSandpile,
  'dla': cpuDla,
  'forest_fire': cpuForestFire,
  'percolation': cpuPercolation,
  'brian_brain': cpuBrianBrain,
  'highlife': cpuHighlife,
  'day_night': cpuDayNight,
  'eden_growth': cpuEdenGrowth,

  // Newton and root-finding
  'newton_z3': cpuNewtonZ3,
  'newton_sin': cpuNewtonSin,
  'newton_general': cpuNewtonGeneral,
  'halley': cpuHalley,
  'householder': cpuHouseholder,
  'damped_newton': cpuDampedNewton,
  'durand_kerner': cpuDurandKerner,
  'ehrlich_aberth': cpuEhrlichAberth,

  // Hypercomplex
  'quaternion_julia_2d': cpuQuaternionJulia2D,
  'tessarine_julia': cpuTessarineJulia,
  'split_complex': cpuSplitComplex,
  'dual_complex': cpuDualComplex,
  'bicomplex': cpuBicomplex,
  'hypercomplex_newton': cpuHypercomplexNewton,
  'pseudo_kleinian': cpuPseudoKleinian,
  'benesi': cpuBenesi,

  // Transcendental
  'sine_julia': cpuSineJulia,
  'cosine_julia': cpuCosineJulia,
  'tangent': cpuTangent,
  'sinh_cosh': cpuSinhCosh,
  'exponential': cpuExponential,
  'cosine_mandelbrot': cpuCosineMandelbrot,
  'tangent_mandelbrot': cpuTangentMandelbrot,
  'sinh_mandelbrot': cpuSinhMandelbrot,
  'cosh_mandelbrot': cpuCoshMandelbrot,
  'tanh_mandelbrot': cpuTanhMandelbrot,

  // Lyapunov and dynamical
  'lyapunov': cpuLyapunov,
  'logistic_lyapunov': cpuLogisticLyapunov,
  'circle_map_lyapunov': cpuCircleMapLyapunov,
  'sine_map_lyapunov': cpuSineMapLyapunov,
  'tent_map': cpuTentMap,
  'feigenbaum': cpuFeigenbaum,
  'gauss_map': cpuGaussMap,

  // Biomorphs and special
  'pickover_biomorph': cpuPickoverBiomorph,
  'zircon_zity': cpuZirconZity,
  'heart': cpuHeart,
  'log_spiral': cpuLogSpiral,
  'farey_diagram': cpuFareyDiagram,
  'cayley_graph': cpuCayleyGraph,

  // Barnsley Julia variants
  'barnsley_j1': cpuBarnsleyJ1,
  'barnsley_j2': cpuBarnsleyJ2,
  'barnsley_j3': cpuBarnsleyJ3,

  // Special polynomials
  'fish': cpuFish,
  'ducky': cpuDucky,
  'schroeder': cpuSchroeder,
  'secant_fractal': cpuSecantFractal,
  'secant_cosecant': cpuSecantCosecant,
  'taylor': cpuTaylor,
  'rational_map': cpuRationalMap,
  'chebyshev': cpuChebyshev,
  'legendre': cpuLegendre,
  'laguerre': cpuLaguerre,
  'hermite': cpuHermite,
  'virial': cpuVirial,
  'lambda_w': cpuLambdaW,
  'riemann_zeta': cpuRiemannZeta,

  // Advanced variants
  'spider_x': cpuSpiderX,
  'manair_fire': cpuManairFire,

  // Buddhabrot variants
  'buddhabrot_approx': cpuBuddhabrotApprox,
  'anti_buddhabrot': cpuAntiBuddhabrot,
  'nebulabrot': cpuNebulabrot,
  'buddhabrot_full': cpuBuddhabrotFull,

  // McMullen maps
  'mcmullen_map': cpuMcmullenMap,
  'generalized_mcmullen': cpuGeneralizedMcmullen,

  // Shape modulation and rational
  'shape_modulus_julia': cpuShapeModulusJulia,
  'fractal_flame': cpuFractalFlame,
  'sierpinski_julia_rational': cpuSierpinskiJuliaRational,

  // Domain coloring and rendering
  'alternated_iteration': cpuAlternatedIteration,
  'domain_coloring': cpuDomainColoring,
  'phase_portrait': cpuPhasePortrait,

  // Growth models
  'gray_scott_rd': cpuGrayScottRD,
  'dielectric_breakdown': cpuDielectricBreakdown,
  'lichtenberg_growth': cpuLichtenbergGrowth,
};

// ---------------------------------------------------------------------------
// Synthetic fallback cache
// ---------------------------------------------------------------------------

final Map<String, CpuFormula> _syntheticFallbackByModuleId =
    <String, CpuFormula>{};

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// True when [moduleId] has an explicit CPU implementation.
bool hasNativeCpuFormula(String moduleId) =>
    cpuFormulasByModuleId.containsKey(moduleId);

/// Resolves a CPU formula for [moduleId].
///
/// If no explicit implementation exists, returns a deterministic synthetic
/// fallback keyed by module id (instead of silently reusing Mandelbrot).
CpuFormula cpuFormulaForModuleId(String moduleId) {
  final direct = cpuFormulasByModuleId[moduleId];
  if (direct != null) return direct;

  return _syntheticFallbackByModuleId.putIfAbsent(moduleId, () {
    final seed = fnv1a32(moduleId);
    return (
      double x,
      double y,
      int iterations,
      double bailout,
      Vector2 _,
    ) =>
        cpuSynthetic(seed, x, y, iterations, bailout);
  });
}
