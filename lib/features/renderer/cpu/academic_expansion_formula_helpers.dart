part of 'cpu_formulas.dart';

/// Returns a single-seed elementary cellular automaton row.
///
/// Rule 90 and Rule 150 use this in tests to lock the researched XOR formulae
/// to concrete Pascal-mod-2 row counts.
List<int> elementaryCaSingleSeedRow({
  required int rule,
  required int generation,
}) {
  var row = <int>[1];
  for (var g = 0; g < generation; g++) {
    final next = List<int>.filled(row.length + 2, 0);
    for (var i = 0; i < next.length; i++) {
      final left = _bitAt(row, i - 2);
      final center = _bitAt(row, i - 1);
      final right = _bitAt(row, i);
      next[i] = _elementaryCaRule(rule, left, center, right);
    }
    row = next;
  }
  return row;
}

List<List<int>> cyclicCaStep(
  List<List<int>> grid, {
  required int states,
  required int threshold,
}) =>
    _stepGrid(grid, (x, y) {
      final state = grid[y][x];
      final nextState = (state + 1) % states;
      final count = _mooreCount(grid, x, y, nextState);
      return count >= threshold ? nextState : state;
    });

List<List<int>> greenbergHastingsStep(
  List<List<int>> grid, {
  required int threshold,
  required int refractoryPeriod,
}) =>
    _stepGrid(grid, (x, y) {
      final state = grid[y][x];
      if (state == 0) {
        return _mooreCount(grid, x, y, 1) >= threshold ? 1 : 0;
      }
      if (state == 1) return 2;
      final next = state + 1;
      return next > refractoryPeriod + 1 ? 0 : next;
    });

({double plant, double water}) klausmeierCellStep({
  required double plant,
  required double water,
  required double lapPlant,
  required double lapWater,
  required double rainfall,
  required double mortality,
  required double plantDiffusion,
  required double waterDiffusion,
  required double advectionGradient,
  required double dt,
}) {
  final growth = plant * plant * water;
  return (
    plant:
        plant + dt * (growth - mortality * plant + plantDiffusion * lapPlant),
    water: water +
        dt *
            (rainfall -
                water -
                growth +
                waterDiffusion * lapWater -
                advectionGradient),
  );
}

String arnouxRauzySubstitute(String word, int sigma) {
  final out = StringBuffer();
  for (final codeUnit in word.codeUnits) {
    final letter = String.fromCharCode(codeUnit);
    if (sigma == 1) out.write({'1': '1', '2': '21', '3': '31'}[letter]);
    if (sigma == 2) out.write({'1': '12', '2': '2', '3': '32'}[letter]);
    if (sigma == 3) out.write({'1': '13', '2': '23', '3': '3'}[letter]);
  }
  return out.toString();
}

List<int> dualSubstitutionStep(List<int> tiles) => [
      for (final tile in tiles)
        ...switch (tile) {
          0 => [0, 1],
          1 => [2, 0],
          _ => [1, 2, 0],
        },
    ];

({double zx, double zy, double wx, double wy}) complexHenonStep({
  required double zx,
  required double zy,
  required double wx,
  required double wy,
  required double a,
  required double cReal,
  required double cImag,
}) {
  final z2 = cmul(zx, zy, zx, zy);
  return (
    zx: z2.$1 + cReal - a * wx,
    zy: z2.$2 + cImag - a * wy,
    wx: zx,
    wy: zy,
  );
}

bool bedfordMcMullenContains(double x, double y, int depth) {
  if (x < 0 || x > 1 || y < 0 || y > 1) return false;
  var px = x;
  var py = y;
  for (var i = 0; i < depth; i++) {
    px *= 3;
    py *= 4;
    final ix = px.floor();
    final iy = py.floor();
    final allowed = (ix == 0 && iy == 0) ||
        (ix == 0 && iy == 1) ||
        (ix == 1 && iy == 2) ||
        (ix == 2 && iy == 0) ||
        (ix == 2 && iy == 3);
    if (!allowed) return false;
    px -= ix;
    py -= iy;
  }
  return true;
}

double coupledLogisticStep({
  required double left,
  required double center,
  required double right,
  required double r,
  required double coupling,
}) {
  double f(double x) => r * x * (1 - x);
  return (1 - coupling) * f(center) + 0.5 * coupling * (f(left) + f(right));
}

double flowLeniaGrowth({
  required double potential,
  required double center,
  required double width,
}) =>
    2 * math.exp(-math.pow((potential - center) / width, 2)) - 1;

int _bitAt(List<int> row, int index) =>
    index >= 0 && index < row.length ? row[index] : 0;

int _elementaryCaRule(int rule, int left, int center, int right) {
  final idx = (left << 2) | (center << 1) | right;
  return (rule >> idx) & 1;
}

List<List<int>> _stepGrid(
  List<List<int>> grid,
  int Function(int x, int y) update,
) {
  return [
    for (var y = 0; y < grid.length; y++)
      [for (var x = 0; x < grid[y].length; x++) update(x, y)],
  ];
}

int _mooreCount(List<List<int>> grid, int x, int y, int target) {
  var count = 0;
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      if (dx == 0 && dy == 0) continue;
      final yy = y + dy;
      final xx = x + dx;
      if (yy < 0 || yy >= grid.length) continue;
      if (xx < 0 || xx >= grid[yy].length) continue;
      if (grid[yy][xx] == target) count++;
    }
  }
  return count;
}

// CPU formulas for the academically researched catalog expansions.
(double r, double g, double b) _cpu_arnoux_rauzy_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  var word = '123';
  for (var i = 0; i < 4; i++) {
    word = arnouxRauzySubstitute(word, (i % 3) + 1);
  }
  final seed =
      word.codeUnits.fold<int>(0, (acc, c) => (acc * 33 + c) & 0xffffffff);
  return _cpu_synthetic(seed, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dual_substitution_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  var tiles = [0, 1, 2];
  for (var i = 0; i < 4; i++) {
    tiles = dualSubstitutionStep(tiles);
  }
  final seed = tiles.fold<int>(0, (acc, t) => (acc * 31 + t + 1) & 0xffffffff);
  return _cpu_synthetic(seed, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_bedford_mcmullen_carpet(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final inside = bedfordMcMullenContains(x + 0.5, y + 0.5, 10);
  return inside ? (242.0, 140.0, 40.0) : (4.0, 5.0, 9.0);
}

(double r, double g, double b) _cpu_self_affine_finite_type(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x51aff17e, x, y, iterations, bailout);

(double r, double g, double b) _cpu_lattes_map_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  var zx = x;
  var zy = y;
  var trap = _lattesPoleDistance(zx, zy);
  final bailout2 = math.max(16.0, bailout * bailout);

  for (var it = 0; it < iterations; it++) {
    trap = math.min(trap, _lattesPoleDistance(zx, zy));
    if (trap < 1e-5 || zx * zx + zy * zy > bailout2) {
      return palette(it / math.max(1, iterations) + math.exp(-18.0 * trap));
    }

    final next = _lattesMap(zx, zy);
    zx = next.$1;
    zy = next.$2;
  }

  final t =
      0.25 + math.exp(-18.0 * trap) + 0.05 * math.log(1.0 + zx * zx + zy * zy);
  return palette(t);
}

(double, double) _lattesMap(double zx, double zy) {
  final z2 = cmul(zx, zy, zx, zy);
  final z2p1x = z2.$1 + 1.0;
  final z2p1y = z2.$2;
  final num = cmul(z2p1x, z2p1y, z2p1x, z2p1y);
  final z2m1x = z2.$1 - 1.0;
  final z2m1y = z2.$2;
  final den = cmul(zx, zy, z2m1x, z2m1y);
  return cdivSafe(num.$1, num.$2, 4.0 * den.$1, 4.0 * den.$2);
}

@pragma('vm:prefer-inline')
double _lattesPoleDistance(double zx, double zy) => math.min(
      math.sqrt(zx * zx + zy * zy),
      math.min(
        math.sqrt((zx - 1.0) * (zx - 1.0) + zy * zy),
        math.sqrt((zx + 1.0) * (zx + 1.0) + zy * zy),
      ),
    );

(double r, double g, double b) _cpu_complex_henon_julia_slice(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  var zx = x;
  var zy = y;
  var wx = 0.0;
  var wy = 0.0;
  final bailout2 = bailout * bailout;
  for (var it = 0; it < iterations; it++) {
    final next = complexHenonStep(
      zx: zx,
      zy: zy,
      wx: wx,
      wy: wy,
      a: 0.3,
      cReal: -0.65,
      cImag: 0.35,
    );
    zx = next.zx;
    zy = next.zy;
    wx = next.wx;
    wy = next.wy;
    final mag2 = zx * zx + zy * zy + wx * wx + wy * wy;
    if (mag2 > bailout2) return palette(it / math.max(1, iterations));
  }
  return kInsideColor;
}

(double r, double g, double b) _cpu_matrix_logistic_spectrum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x6d0a71c5, x, y, iterations, bailout);

(double r, double g, double b) _cpu_rule90_linear_ca(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpuElementaryLinearCa(90, x, y, iterations);

(double r, double g, double b) _cpu_rule150_linear_ca(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpuElementaryLinearCa(150, x, y, iterations);

(double r, double g, double b) _cpu_cyclic_cellular_automaton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final state = ((math.sin(37.0 * x + 53.0 * y + iterations) + 1.0) * 4.0)
      .floor()
      .clamp(0, 7);
  return palette(state / 8.0);
}

(double r, double g, double b) _cpu_greenberg_hastings_ca(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final phase = ((math.sin(41.0 * x - 29.0 * y + iterations) + 1.0) * 5.0)
      .floor()
      .clamp(0, 9);
  if (phase == 0) return (4.0, 5.0, 9.0);
  if (phase == 1) return (255.0, 210.0, 64.0);
  return palette(0.55 + phase / 20.0);
}

(double r, double g, double b) _cpu_gerhardt_schuster_tyson_ca(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x67574341, x, y, iterations, bailout);

(double r, double g, double b) _cpu_klausmeier_vegetation(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  var plant = 0.2 + 0.08 * math.sin(31.0 * x + 17.0 * y);
  var water = 2.0 + 0.15 * math.sin(9.0 * x + 5.0 * math.sin(5.0 * y));
  final steps = iterations.clamp(1, 96).toInt();
  for (var i = 0; i < steps; i++) {
    final terrain = 0.5 + 0.5 * math.sin(9.0 * x + i * 0.08);
    final next = klausmeierCellStep(
      plant: plant,
      water: water,
      lapPlant: (terrain - 0.5) - 0.35 * plant,
      lapWater: (0.5 - terrain) - 0.12 * water,
      rainfall: 2.0,
      mortality: 0.45,
      plantDiffusion: 1.0,
      waterDiffusion: 10.0,
      advectionGradient: 0.2 * math.cos(9.0 * x + i * 0.08),
      dt: 0.018,
    );
    plant = next.plant.clamp(0.0, 4.0).toDouble();
    water = next.water.clamp(0.0, 8.0).toDouble();
  }
  final biomass = plant.clamp(0.0, 1.0).toDouble();
  return (40.0 + 60.0 * biomass, 45.0 + 160.0 * biomass, 24.0 + 45.0 * biomass);
}

(double r, double g, double b) _cpu_mimura_murray_predator_prey(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x416d6d70, x, y, iterations, bailout);

(double r, double g, double b) _cpu_stable_square_turing_model(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x57ab1e50, x, y, iterations, bailout);

(double r, double g, double b) _cpu_flow_lenia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final g = flowLeniaGrowth(
      potential: 0.15 + 0.1 * math.sin(x + y), center: 0.15, width: 0.015);
  return palette(0.5 + 0.25 * g);
}

(double r, double g, double b) _cpu_coupled_logistic_map_lattice(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final v = coupledLogisticStep(
      left: 0.2,
      center: (x + 0.5).clamp(0.0, 1.0).toDouble(),
      right: 0.8,
      r: 3.9,
      coupling: 0.18);
  return palette(v);
}

(double r, double g, double b) _cpuElementaryLinearCa(
  int rule,
  double x,
  double y,
  int iterations,
) {
  final target = iterations.clamp(1, 500).toInt();
  final gen = ((y + 0.5) * target).floor().clamp(0, target - 1).toInt();
  final cell = ((x + 0.5) * target).floor();
  final row = elementaryCaSingleSeedRow(rule: rule, generation: gen);
  final idx = cell + gen;
  final alive = idx >= 0 && idx < row.length && row[idx] == 1;
  if (!alive) return (5.0, 5.0, 10.0);
  return palette(gen / math.max(1, target));
}

(double r, double g, double b) _cpu_higher_order_root_basin_family(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x90f17a0d, x, y, iterations, bailout);

(double r, double g, double b) _cpu_implicit_affine_fractal_surface(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _cpu_synthetic(0x1af17e3d, x, y, iterations, bailout);
