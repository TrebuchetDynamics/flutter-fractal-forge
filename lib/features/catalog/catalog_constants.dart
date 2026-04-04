// Constants for known thumbnail IDs.
///
/// These are fractals with exact CPU-generated thumbnails.
/// Others use approximate gradient fallbacks.
const kKnownThumbnailIds = <String>{
  'mandelbrot',
  'julia',
  'burning_ship',
  'burning_ship_julia',
  'buffalo',
  'buffalo_julia',
  'manowar',
  'celtic',
  'celtic_julia',
  'cosine_mandelbrot',
  'cosine_julia',
  'cosh_mandelbrot',
  'lambda',
  'glynn',
  'magnet_type_2',
  'magnet_newton',
  'halley',
  'householder',
  'legendre',
  'laguerre',
  'chebyshev',
  'eisenstein',
  'fatou',
  'exponential',
  'dual_complex',
  'bicomplex',
  'hypercomplex_newton',
  'collatz',
  'gamma_fractal',
  'ducky',
  'fish',
  'druid',
  'heart',
  'day_night',
  'barnsley_fern',
  'barnsley_j1',
  'barnsley_j2',
  'barnsley_j3',
  'cyclosorus_fern',
  'arnold_cat',
  'henon',
  'hopalong',
  'clifford',
  'gumowski_mira',
  'gingerbreadman',
  'duffing',
  'lyapunov',
  'logistic_lyapunov',
  'circle_map_lyapunov',
  'gauss_map',
  'feigenbaum',
  'lorenz_2d',
  'aizawa',
  'arneodo',
  'bouali',
  'burke_shaw',
  'chen',
  'chua_circuit',
  'dadras',
  'four_wing',
  'hadley',
  'halvorsen',
  'liu_chen',
  'lu_chen',
  'golden_dragon',
  'fibonacci_spiral',
  'fibonacci_word',
  'log_spiral',
  'astroid',
  'hilbert_curve',
  'gosper_curve',
  'levy_c_curve',
  'moore_curve',
  'cesaro_fractal',
  'fractal_canopy',
  'koch_snowflake',
  'hexaflake',
  'cantor_set',
  'cantor_dust',
  'menger_sponge_2d',
  'menger_3d_slice',
  'apollonian_gasket',
  'ford_circles',
  'farey_diagram',
  'cayley_graph',
  'ammann_beenker',
  'hat_monotile',
  'chair_tiling',
  'cactus',
  'dla',
  'eden_growth',
  'forest_fire',
  'langton_ant',
  'brian_brain',
  'kicked_rotator',
  'benesi',
  'anti_buddhabrot',
  'buddhabrot_approx',
  'manair_fire',
  'jerusalem_cube',
};

/// Catalog UI constants.
class CatalogConstants {
  // Grid cross-axis counts for different screen widths.
  // Reduced counts for larger, higher-quality thumbnail display.
  static const gridCrossAxisCountDesktop = 5; // >= 1024
  static const gridCrossAxisCountLargeTablet = 4; // >= 840
  static const gridCrossAxisCountTablet = 3; // >= 600
  static const gridCrossAxisCountPhone = 2; // default

  /// Calculates the grid cross-axis count based on screen width.
  static int gridCrossAxisCount(double width) {
    if (width >= 1024) return gridCrossAxisCountDesktop;
    if (width >= 840) return gridCrossAxisCountLargeTablet;
    if (width >= 600) return gridCrossAxisCountTablet;
    return gridCrossAxisCountPhone;
  }
}
