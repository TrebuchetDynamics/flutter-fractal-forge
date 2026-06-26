import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time/catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_3d_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_clifford_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_de_jong_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_direct_3d_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_direct_transcendental_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_escape_expression_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_escape_power_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_exact_attractor_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_exact_escape_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_fractal_flame_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_gumowski_mira_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_hopalong_catalog.dart';
import 'package:flutter_fractals/core/modules/gpu_gradient_module.dart';
import 'package:flutter_fractals/core/modules/gpu_sampler_diag_module.dart';
import 'package:flutter_fractals/core/modules/hydrogen_orbital_module.dart';
import 'package:flutter_fractals/core/modules/julia_dual_module.dart';
import 'package:flutter_fractals/core/modules/julia_module.dart';
import 'package:flutter_fractals/core/modules/mandelbox_module.dart';
import 'package:flutter_fractals/core/modules/mandelbulb_module.dart';
import 'package:flutter_fractals/core/modules/nova_module.dart';
import 'package:flutter_fractals/core/modules/phoenix_module.dart';
import 'package:flutter_fractals/core/modules/builders/shared_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_life_like_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_lozi_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_kifs_menger_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_multibrot_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_number_theory_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_orbit_trap_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_phoenix_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_quaternion_julia_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_residual_ca_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_sprott_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_standard_map_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_svensson_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/shared_tinkerbell_catalog.dart';
import 'package:flutter_fractals/core/modules/test_shaders_module.dart';

/// Registry of all available fractal modules.
///
/// ## Architecture (post-refactor)
///
/// Most 2D escape-time fractals are built **declaratively** from
/// [EscapeTimeConfig] entries in `builders/escape_time/catalog.dart`.
/// Adding a new escape-time fractal = one config entry + one .frag shader.
///
/// Fractals with **custom parameters** (Julia seeds, Phoenix p/q, 3D rotation)
/// still use dedicated builder functions.
///
/// ## How to add a new fractal
///
/// **Standard escape-time (iterations + bailout + color):**
/// 1. Write shader following standard uniform layout (see builders/escape_time/builder.dart)
/// 2. Add `EscapeTimeConfig(...)` to `builders/escape_time/catalog.dart`
/// 3. Register shader in `pubspec.yaml`
/// 4. Done!
///
/// **Custom params or non-escape-time:**
/// 1. Create a `buildXxxModule()` function
/// 2. Add it to [_customModules] below
///
/// {@category Modules}
class ModuleRegistry {
  /// All available fractal modules (built lazily on first access).
  late final List<FractalModule> modules = _buildAll();

  /// Creates the registry.
  ModuleRegistry();

  /// Look up a module by [id]. Throws if not found.
  FractalModule byId(String id) {
    return modules.firstWhere((m) => m.id == id);
  }

  static List<FractalModule> _buildAll() {
    // IDs already in the escape-time catalog (built declaratively).
    // Defensive de-duplication keeps registry stable even if the catalog
    // accidentally contains repeated ids.
    final catalogModules = _dedupeById(buildEscapeTimeCatalogModules());
    final catalogIds = catalogModules.map((m) => m.id).toSet();

    // Custom modules with special params/uniforms
    final customModules = <FractalModule>[
      // Julia needs extra seed params (cx, cy)
      if (!catalogIds.contains('julia')) buildJuliaModule(),
      // Julia Dual: side-by-side Mandelbrot + Julia viewer
      if (!catalogIds.contains('julia_dual')) buildJuliaDualModule(),
      // Phoenix needs extra c/p/power-aware uniforms; keep the custom module so
      // the core Phoenix shader is never driven by the generic escape-time layout.
      buildPhoenixModule(),
      // Nova needs relaxation param instead of bailout
      if (!catalogIds.contains('nova')) buildNovaModule(),
      // Mandelbulb is 3D with rotation uniforms
      if (!catalogIds.contains('mandelbulb')) buildMandelbulbModule(),
      // Mandelbox is 3D with box-fold + sphere-fold DE
      if (!catalogIds.contains('mandelbox')) buildMandelboxModule(),
      // Hydrogen orbital is a volumetric density renderer with custom controls.
      if (!catalogIds.contains('hydrogen_orbital'))
        buildHydrogenOrbitalModule(),
    ];

    // Diagnostics (debug only, always last)
    final diagModules = kDebugMode
        ? [
            testAlwaysRedModule,
            testUniformOnlyModule,
            testMinimalModule,
            testGlFragCoordModule,
            testFlutterCoordModule,
            buildGpuGradientModule(),
            buildGpuSamplerDiagModule(),
          ]
        : <FractalModule>[];

    // Merge: catalog first (Mandelbrot at top), then custom, then diag.
    // Insert Julia after Mandelbrot, Phoenix after Burning Ship for UX order.
    final result = <FractalModule>[];

    // Find key positions for insertion
    final mandelbrotIdx =
        catalogModules.indexWhere((m) => m.id == 'mandelbrot');
    final burningShipIdx =
        catalogModules.indexWhere((m) => m.id == 'burning_ship');
    final novaJuliaIdx = catalogModules.indexWhere((m) => m.id == 'nova_julia');

    for (int i = 0; i < catalogModules.length; i++) {
      // Insert Nova right before Nova Julia
      if (i == novaJuliaIdx) {
        final nova = customModules.where((m) => m.id == 'nova');
        result.addAll(nova);
      }
      result.add(catalogModules[i]);
      // Insert Julia and Julia Dual right after Mandelbrot
      if (i == mandelbrotIdx) {
        final julia = customModules.where((m) => m.id == 'julia');
        result.addAll(julia);
        final juliaDual = customModules.where((m) => m.id == 'julia_dual');
        result.addAll(juliaDual);
      }
      // Insert Phoenix right after Burning Ship
      if (i == burningShipIdx) {
        final phoenix = customModules.where((m) => m.id == 'phoenix');
        result.addAll(phoenix);
      }
    }

    // Add remaining custom modules not yet inserted
    for (final m in customModules) {
      if (!result.any((r) => r.id == m.id)) {
        result.add(m);
      }
    }

    // Keep the custom Phoenix module after the declarative catalog duplicate so
    // final preferLast de-duplication selects the custom uniform layout.
    result.add(buildPhoenixModule());

    // Shared renderer promotion batches: stable formula identities that reuse
    // reviewed shared shaders with fixed mathematical parameters.
    result.addAll(buildSharedJuliaCatalogModules());
    result.addAll(buildSharedDirectTranscendentalCatalogModules());
    result.addAll(buildSharedPhoenixCatalogModules());
    result.addAll(buildSharedSprottCatalogModules());
    result.addAll(buildSharedCliffordCatalogModules());
    result.addAll(buildSharedSvenssonCatalogModules());
    result.addAll(buildSharedHopalongCatalogModules());
    result.addAll(buildSharedDeJongCatalogModules());
    result.addAll(buildSharedLoziCatalogModules());
    result.addAll(buildSharedTinkerbellCatalogModules());
    result.addAll(buildSharedStandardMapCatalogModules());
    result.addAll(buildSharedGumowskiMiraCatalogModules());
    result.addAll(buildSharedExactAttractorCatalogModules());
    result.addAll(buildSharedExactEscapeCatalogModules());
    result.addAll(buildShared3DCatalogModules());
    result.addAll(buildSharedDirect3DCatalogModules());
    result.addAll(buildSharedQuaternionJuliaCatalogModules());
    result.addAll(buildSharedKifsMengerCatalogModules());
    result.addAll(buildSharedNumberTheoryCatalogModules());
    result.addAll(buildSharedResidualCaCatalogModules());
    result.addAll(buildSharedLifeLikeCatalogModules());
    result.addAll(buildSharedMultibrotCatalogModules());
    result.addAll(buildSharedEscapePowerCatalogModules());
    result.addAll(buildSharedEscapeExpressionCatalogModules());
    result.addAll(buildSharedFractalFlameCatalogModules());
    result.addAll(buildSharedOrbitTrapCatalogModules());

    // 3D ray-marched catalog modules (KIFS, Quaternion, exotic)
    final raymarched3DModules = buildRaymarched3DCatalogModules();
    result.addAll(raymarched3DModules);

    result.addAll(diagModules);
    // Keep later modules when ids collide so purpose-built 3D catalog entries
    // can replace older placeholder escape-time variants with the same id.
    return _dedupeById(result, preferLast: true);
  }

  static List<FractalModule> _dedupeById(
    List<FractalModule> modules, {
    bool preferLast = false,
  }) {
    if (preferLast) {
      final seen = <String>{};
      final reversedUnique = <FractalModule>[];
      for (final module in modules.reversed) {
        if (seen.add(module.id)) {
          reversedUnique.add(module);
        }
      }
      return reversedUnique.reversed.toList(growable: false);
    }

    final seen = <String>{};
    final unique = <FractalModule>[];
    for (final module in modules) {
      if (seen.add(module.id)) {
        unique.add(module);
      }
    }
    return unique;
  }
}
