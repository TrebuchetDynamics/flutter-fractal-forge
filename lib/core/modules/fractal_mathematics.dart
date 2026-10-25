import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_escape_power_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_life_like_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_multibrot_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_orbit_trap_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_phoenix_catalog.dart';
import 'package:flutter_fractals/core/models/attractor_trajectory_settings.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/life_like_rule.dart';

/// Source-based browse facets, not certification of every named identity.
class FractalMathematics {
  final FractalModule _module;
  final String family;
  final String algebra;
  final String view;
  final String method;
  final String qualification;
  final String groupId;
  final String relationship;

  const FractalMathematics._(
    this._module, {
    required this.family,
    this.algebra = 'Unverified',
    required this.view,
    this.method = 'Unverified',
    this.qualification = 'Unverified identity',
    required this.groupId,
    this.relationship = 'No verified relationship',
  });

  static FractalMathematics forModule(FractalModule module,
      {String? category}) {
    final shader = module.shaderAsset;
    final file = _reviewedFile(shader);
    var family = _familyForSource(shader, category);
    var algebra = 'Unverified';
    var view =
        module.dimension == FractalDimension.threeD ? '3D view' : '2D view';
    var method = 'Unverified';
    var qualification = 'Unverified identity';
    var groupId = module.id;
    var relationship = 'No verified relationship';

    if (module.id == 'number_wall' &&
        shader == 'shaders/number_theory/number_wall_gpu.frag') {
      return FractalMathematics._(module,
          family: 'Number Walls',
          algebra: 'Finite field',
          view: 'Discrete field',
          method: 'Exact Toeplitz determinants',
          qualification: 'Self-similarity depends on sequence and modulus',
          groupId: 'number_wall',
          relationship: 'Sequence variants of one number wall');
    }
    final trajectory = OrbitTrajectorySettings.defaultsForOrNull(module.id);
    if (trajectory != null) {
      family = 'Maps, flows and attractors';
      algebra = 'Real';
      view = switch (trajectory.projection) {
        OrbitProjection.xz => 'Finite 3D orbit projected to x-z',
        OrbitProjection.thomasOblique =>
          'Finite 3D orbit projected to an orthonormal oblique plane',
      };
      method = 'Fixed-step RK4 trajectory';
      qualification =
          'Finite numerical approximation (seed, step size, burn-in and sample count are saved); legacy views retain the prior portrait';
    }

    // Only reviewed catalog membership establishes groups; shader reuse does not.
    if ((module.id == 'julia' ||
            sharedJuliaCatalogEntries.any((e) => e.id == module.id)) &&
        file == 'julia_gpu.frag') {
      groupId = 'quadratic-julia';
      relationship = 'Parameter configuration of quadratic Julia';
    } else if ((module.id == 'multibrot3' ||
            sharedMultibrotCatalogEntries.any((e) => e.id == module.id)) &&
        file == 'multibrot3_gpu.frag') {
      groupId = 'multibrot-power';
      relationship = 'Exponent-family member; not necessarily polynomial';
    } else if ((module.id == 'phoenix' ||
            sharedPhoenixCatalogEntries.any((e) => e.id == module.id)) &&
        file == 'phoenix_gpu.frag') {
      groupId = 'phoenix-memory';
      relationship = 'Different recurrence: memory term, not Julia coloring';
    } else if ((const {'mandelbrot', 'mandelbrot_orbit_trap'}
                .contains(module.id) ||
            sharedOrbitTrapCatalogEntries.any((e) => e.id == module.id)) &&
        const {'mandel_step_smooth.frag', 'mandelbrot_orbit_trap_gpu.frag'}
            .contains(file)) {
      groupId = 'quadratic-mandelbrot';
      relationship = 'Coloring/measurement variant of quadratic Mandelbrot';
    } else if ((const {'tricorn', 'burning_ship'}.contains(module.id) ||
            sharedEscapePowerCatalogEntries.any((e) => e.id == module.id)) &&
        const {'tricorn_gpu.frag', 'burning_ship_gpu.frag'}.contains(file)) {
      groupId =
          file == 'tricorn_gpu.frag' ? 'multicorn-power' : 'burning-ship-power';
      relationship =
          'Different recurrence: ${file == 'tricorn_gpu.frag' ? 'conjugate' : 'componentwise absolute value'} before powering';
    } else if (sharedLifeLikeCatalogEntries.any((e) => e.id == module.id) &&
        file == 'maze_ca_gpu.frag') {
      groupId = 'life-like-rules';
      relationship =
          'Rule configuration; procedural visualization, not verified CA evolution';
    }

    if (shader.startsWith('shaders/escape_time_family/') ||
        shader.startsWith('shaders/trigonometric_and_transcendental/')) {
      algebra = 'Complex';
    }
    if (const {'julia_gpu.frag', 'phoenix_gpu.frag'}.contains(file)) {
      family = 'Complex dynamics';
      algebra = 'Complex';
      view = 'Dynamical plane';
      method = 'Escape-time';
      qualification =
          'Source-reviewed recurrence; named starting configuration';
    } else if (const {
      'mandel_step_smooth.frag',
      'multibrot3_gpu.frag',
      'tricorn_gpu.frag',
      'burning_ship_gpu.frag',
      'mandelbrot_orbit_trap_gpu.frag',
      'sine_mandelbrot_gpu.frag',
      'cosine_mandelbrot_gpu.frag'
    }.contains(file)) {
      family = 'Complex dynamics';
      algebra = 'Complex';
      view = 'Parameter plane';
      method = file == 'mandelbrot_orbit_trap_gpu.frag'
          ? 'Orbit-trap coloring'
          : 'Escape-time';
      qualification =
          'Source-reviewed recurrence; numerical regularization may apply';
    } else if (const {
      'newton_z3_gpu.frag',
      'halley_gpu.frag',
      'householder_gpu.frag'
    }.contains(file)) {
      family = 'Root finding';
      algebra = 'Complex';
      view = 'Nearest-root basin coloring';
      method = switch (file) {
        'newton_z3_gpu.frag' => 'Newton',
        'halley_gpu.frag' => 'Halley',
        _ => 'Householder correction',
      };
      qualification =
          'Source-reviewed update; color does not prove convergence';
      if (file == 'halley_gpu.frag' &&
          !module.defaultPreset.params.containsKey('relaxation')) {
        qualification =
            'Unverified effective update: relaxation uniform is not bound';
      }
      relationship = 'Related root-finding methods; not aliases';
    } else if (file == 'henon_gpu.frag') {
      family = 'Maps, flows and attractors';
      algebra = 'Real';
      view = 'Escape/boundedness of initial conditions, not orbit density';
      method = 'Escape-time';
      qualification = 'Source-reviewed recurrence';
    } else if (file == 'quaternion_julia_2d_gpu.frag') {
      family = 'Complex dynamics';
      algebra = 'Quaternion';
      view = '2D time-varying slice of 4D state';
      method = 'Escape-time';
      qualification = 'Source-reviewed recurrence';
      relationship = 'Underlying algebra differs from rendered dimension';
    } else if (file == 'hypercomplex_newton_gpu.frag') {
      family = 'Root finding';
      algebra = 'Quaternion';
      view = '2D slice';
      relationship =
          'Related method in a different algebra; not a complex alias';
    } else if (const {'ammann_beenker_gpu.frag', 'penrose_tiling_gpu.frag'}
        .contains(file)) {
      family = 'Tilings, substitutions and L-systems';
      qualification = 'Tiling-inspired; exact substitution tiling unverified';
      relationship = 'Related aperiodic tilings; not aliases';
    } else if (const {
      'apollonian_gasket_gpu.frag',
      'apollonian_sphere_packing_gpu.frag'
    }.contains(file)) {
      family = 'IFS and geometric constructions';
      qualification = 'Packing-inspired; canonical tangency unverified';
      relationship =
          'Related inversive constructions, different dimension; slice/projection unverified';
    } else if (file == 'maze_ca_gpu.frag') {
      family = 'Cellular automata and growth';
      algebra = 'Discrete';
      view = 'Procedural rule view';
      method = 'Procedural rule visualization';
      qualification = 'Rule-inspired procedural visualization';
    }
    if (file == 'recursive_sine_sphere_gpu.frag') {
      family = 'IFS and geometric constructions';
      algebra = 'Real';
      view = '3D implicit surface';
      method = 'Conservative level-set intersection';
      qualification =
          'Finite sine-warped sphere; not an SDF or an infinite fractal';
      relationship = "Inspired by Íñigo Quílez's domain warping";
    }
    if (module.id == 'milnor_brieskorn') {
      family = 'Complex dynamics';
      algebra = 'Complex';
      view = 'Parameter plane';
      method = 'Escape-time';
      qualification =
          'Inspired; not an exotic sphere. Not escaped within N is not proven boundedness; orbit of 0 only, not complete connectedness locus';
    }
    if (module.id == 'perron_tree') {
      family = 'IFS and geometric constructions';
      algebra = 'Real';
      view = '2D view';
      method = 'Translated-triangle union';
      qualification =
          'Finite approximation; not a zero-area set or continuous needle motion';
    }
    return FractalMathematics._(module,
        family: family,
        algebra: algebra,
        view: view,
        method: method,
        qualification: qualification,
        groupId: groupId,
        relationship: relationship);
  }

  /// Merge partial edits with defaults and mirror inspected uniform/shader selectors.
  String formula(Map<String, dynamic> params) {
    if (_module.id == 'milnor_brieskorn') {
      return 'z(0) = 0; z(n+1) = z(n)^5 + z(n)^3 + 3*z(n)^2 + c; finite orbit of 0 only';
    }
    if (_module.id == 'perron_tree') {
      final rawDepth = params['depth'];
      final rawAlpha = params['overlap'];
      final depth = rawDepth is num && rawDepth.isFinite
          ? rawDepth.round().clamp(0, 5)
          : 5;
      final alpha = rawAlpha is num && rawAlpha.isFinite
          ? rawAlpha.toDouble().clamp(.5, 1.0)
          : .8;
      if (depth == 0) return 'N=1, a=$alpha; t_0=0';
      return 'N=${1 << depth}, a=$alpha; t_j=-sum(bit_k(j) 2^k (2/sqrt(3)/N) [1+a^k(1-2a)]), k=0..${depth - 1}';
    }
    final values = {..._module.defaultPreset.params, ...params};
    double value(String key, [double fallback = 0]) {
      final raw = values[key];
      final defaultValue = _module.defaultPreset.params[key];
      return raw is num && raw.isFinite
          ? raw.toDouble()
          : defaultValue is num && defaultValue.isFinite
              ? defaultValue.toDouble()
              : fallback;
    }

    double bounded(String key, [double fallback = 0]) {
      final raw = value(key, fallback);
      for (final parameter in _module.parameters) {
        if (parameter.id == key)
          return raw.clamp(parameter.min, parameter.max).toDouble();
      }
      return raw;
    }

    final file = _reviewedFile(_module.shaderAsset);
    final trajectory = OrbitTrajectorySettings.defaultsForOrNull(_module.id);
    if (trajectory != null) {
      final equations = switch (trajectory.system) {
        AttractorSystem.thomas =>
          'dx/dt = sin(y)-0.208186x; dy/dt = sin(z)-0.208186y; dz/dt = sin(x)-0.208186z',
        AttractorSystem.fourWing =>
          'dx/dt = 0.2x+yz; dy/dt = 0.01x-0.4y-xz; dz/dt = -z-xy+0.6',
        AttractorSystem.lorenz2d =>
          'dx/dt = 10(y-x); dy/dt = x(28-z)-y; dz/dt = xy-(8/3)z',
      };
      return '$equations; finite RK4 approximation from (${trajectory.seed.x}, ${trajectory.seed.y}, ${trajectory.seed.z}), dt=${trajectory.stepSize}, burn-in=${trajectory.burnInSteps}, samples=${trajectory.retainedSteps}; projection=${trajectory.projection.name}; legacy saved views retain the initial-condition portrait';
    }
    switch (file) {
      case 'recursive_sine_sphere_gpu.frag':
        final phase = values['animate'] == true ? 'phi+0.0002*t' : 'phi';
        return 'C(x,y,z)=(y,z,x); q(0)=p; q(n+1)=q(n)+a*2^-n*sin(2^n*C(q(n))+phase(t)), 0<=n<N; |q(N)|-R=0; N=${bounded('depth').toInt()}, a=${bounded('strength')}, R=${bounded('radius')}, phi=${bounded('phase')}; phase(t)=$phase';
      case 'julia_gpu.frag':
        return 'z(n+1) = z(n)^2 + c; c = (${value('juliaCReal')}, ${value('juliaCImag')}); z(0) = pixel';
      case 'phoenix_gpu.frag':
        final power = _module.id == 'phoenix'
            ? 2
            : (value('phoenixPower', 2) + 0.5).floor().clamp(2, 8);
        return 'z(n+1) = z(n)^$power + c + p*z(n-1); c = (${value('phoenixCReal')}, ${value('phoenixCImag')}); p = ${value('phoenixP')}; z(-1) = 0; z(0) = pixel';
      case 'multibrot3_gpu.frag':
        var power = bounded('power', 3).clamp(-8.0, 24.0);
        if (power.abs() < 0.001) power = 3;
        final kind = power != power.truncateToDouble()
            ? 'branch-selected real power (atan)'
            : power < 0
                ? 'rational-map variant, not inverse iteration'
                : 'integer-degree polynomial';
        return 'z(n+1) = z(n)^$power + c; $kind; z(0) = ${power < 0 ? 'c' : '0'}; radius floor 1e-8';
      case 'tricorn_gpu.frag':
      case 'burning_ship_gpu.frag':
        final power = bounded('power', 2).abs().clamp(0.5, double.infinity);
        final base = file == 'tricorn_gpu.frag'
            ? 'conj(z(n))'
            : '(|Re(z(n))| + i*|Im(z(n))|)';
        return 'z(n+1) = $base^$power + c; z(0) = 0; ${file == 'tricorn_gpu.frag' && power == 2 ? 'quadratic Tricorn' : 'power-family member'}${power != power.truncateToDouble() ? '; branch-selected real power' : ''}';
      case 'mandel_step_smooth.frag':
      case 'mandelbrot_orbit_trap_gpu.frag':
        return 'z(n+1) = z(n)^2 + c; z(0) = 0${file == 'mandelbrot_orbit_trap_gpu.frag' ? '; orbit-trap mode ${bounded('trapMode').toInt()} changes measurement/coloring, not recurrence' : ''}';
      case 'sine_mandelbrot_gpu.frag':
      case 'cosine_mandelbrot_gpu.frag':
        final variant = bounded('variant').toInt();
        final sine = file == 'sine_mandelbrot_gpu.frag';
        final expressions = sine ? _sineExpressions : _cosineExpressions;
        final expression = expressions[
            variant >= 0 && variant < expressions.length ? variant : 0];
        return 'z(n+1) = $expression; z(0) = ${sine && const {
              9,
              11,
              12
            }.contains(variant) ? 'c' : '0'}; ${sine ? 'transcendental components clamped to +/-20; safe log/division' : 'input components clamped to +/-12; safe log/division'}';
      case 'maze_ca_gpu.frag':
        return 'Life-like ${lifeLikeRuleName(bounded('birthMask'), bounded('survivalMask'))}; procedural rule visualization, not verified CA evolution';
      case 'newton_z3_gpu.frag':
        return 'z(n+1) = z - ${bounded('relaxation', 1)}*f/f\'; f(z) = z^3 - 1; regularized division; color does not prove convergence';
      case 'halley_gpu.frag':
        if (!_module.defaultPreset.params.containsKey('relaxation')) {
          return 'Unverified effective formula: shader z(n+1) = z - relaxation*2*f*f\'/(2*f\'^2 - f*f\'\'), f(z) = z^3 - 1; relaxation uniform not bound';
        }
        return 'z(n+1) = z - ${bounded('relaxation', 1)}*2*f*f\'/(2*f\'^2 - f*f\'\'); f(z) = z^3 - 1; regularized division';
      case 'householder_gpu.frag':
        return 'z(n+1) = z - ${bounded('relaxation', 1)}*(u + 0.5*(f\'\'/f\')*u^2); u = f/f\'; f(z) = z^3 - 1; regularized division';
      case 'henon_gpu.frag':
        return 'x(n+1) = 1 - 1.4*x(n)^2 + y(n); y(n+1) = 0.3*x(n); initial state = 4*pixel; escape/boundedness view';
      case 'quaternion_julia_2d_gpu.frag':
        return 'q(n+1) = q(n)^2 + (-0.20, 0.74, 0.12, -0.08); quaternion; q(0) = (pixel.x, pixel.y, 0.25*sin(0.17*time), 0.25*cos(0.13*time))';
      default:
        return 'Unverified formula: this renderer has not been mathematically reviewed';
    }
  }

  static String _reviewedFile(String shader) => const {
        'shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_gpu.frag',
        'shaders/legacy/escape_time/mandel_step_smooth.frag',
        'shaders/escape_time_family/core/julia_gpu.frag',
        'shaders/escape_time_family/core/phoenix_gpu.frag',
        'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
        'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag',
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag',
        'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
        'shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag',
        'shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag',
        'shaders/root_finding/newton_z3_gpu.frag',
        'shaders/root_finding/halley_gpu.frag',
        'shaders/root_finding/householder_gpu.frag',
        'shaders/strange_attractors/henon_gpu.frag',
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/quaternion_julia_2d_gpu.frag',
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/hypercomplex_newton_gpu.frag',
        'shaders/ifs_and_geometric/ammann_beenker_gpu.frag',
        'shaders/ifs_and_geometric/penrose_tiling_gpu.frag',
        'shaders/ifs_and_geometric/apollonian_gasket_gpu.frag',
        'shaders/3d_and_hypercomplex/raymarched_volumes/apollonian_sphere_packing_gpu.frag',
        'shaders/cellular_and_stochastic/maze_ca_gpu.frag',
      }.contains(shader)
          ? shader.split('/').last
          : '';

  // Semantic shader directories outrank builder defaults (Escape-Time / 3D).
  static String _familyForSource(String shader, String? category) {
    if (const {
      'Complex dynamics',
      'Root finding',
      'IFS and geometric constructions',
      'Maps, flows and attractors',
      'Tilings, substitutions and L-systems',
      'Cellular automata and growth',
      'Fields, spectra and scientific visualization',
      'Procedural and artistic systems'
    }.contains(category)) return category!;
    if (const {'Aperiodic Tiling', 'Image Tessellations', 'L-Systems'}
        .contains(category)) return 'Tilings, substitutions and L-systems';
    if (shader.startsWith('shaders/root_finding/')) return 'Root finding';
    if (shader.startsWith('shaders/strange_attractors/') ||
        shader.startsWith('shaders/lyapunov_and_stability/'))
      return 'Maps, flows and attractors';
    if (shader.startsWith('shaders/cellular_and_stochastic/'))
      return 'Cellular automata and growth';
    if (shader.startsWith('shaders/ifs_and_geometric/'))
      return 'IFS and geometric constructions';
    if (shader.startsWith('shaders/escape_time_family/') ||
        shader.startsWith('shaders/trigonometric_and_transcendental/') ||
        shader.startsWith(
            'shaders/3d_and_hypercomplex/hypercomplex_escape_time/'))
      return 'Complex dynamics';
    return switch (category) {
      'Complex Dynamics' ||
      'Advanced Rational & Polynomial' ||
      'Trigonometric & Transcendental' ||
      'Orbit / Domain Coloring' =>
        'Complex dynamics',
      'Root Finding' ||
      'Root-Finding' ||
      'Convergent & Root-Finding' =>
        'Root finding',
      'IFS & Geometric Construction' ||
      'IFS / Geometric Fractals' ||
      'Self-Affine IFS' =>
        'IFS and geometric constructions',
      'Strange Attractors' ||
      'Lyapunov / Stability' ||
      'Spatiotemporal Chaos' =>
        'Maps, flows and attractors',
      'Aperiodic Tiling' ||
      'Image Tessellations' ||
      'L-Systems' =>
        'Tilings, substitutions and L-systems',
      'Cellular Automata' ||
      'Cellular / Stochastic' ||
      'Cellular & Stochastic Growth' ||
      'Cellular & Stochastic' ||
      'Reaction-Diffusion' =>
        'Cellular automata and growth',
      'Scientific Visualization' ||
      'Spectral Fractals' =>
        'Fields, spectra and scientific visualization',
      'Procedural Fractals' ||
      'Fractalish Motion' ||
      'Kaleidoscopes' =>
        'Procedural and artistic systems',
      _ => 'Unclassified',
    };
  }

  static const _sineExpressions = [
    'sin(z)+c',
    'sin(1/z)+c',
    'sin(z)*cos(z)+c',
    'sinh(z)*cosh(z)+c',
    'log(sin(z))+c',
    'z*sin(z)+c',
    'sin(z)+1+c',
    'sinh(z)+c',
    'exp(z)*sin(z)+c',
    '(exp(0.7*i)*z+1)/(z+exp(-0.7*i))',
    'exp(z^2)+c',
    'log(z^2)+c',
    'exp(1/z)+c',
    'z*tan(z)+c',
    'z*exp(-z^2)+c',
    'exp(i*z)+c',
    'exp(z)+z+c'
  ];
  static const _cosineExpressions = [
    'cos(z)+c',
    'log(cos(z))+c',
    'cos(z)+1+c',
    'z*cos(z)+c',
    'z+cos(z)/sin(z)+c'
  ];
}
