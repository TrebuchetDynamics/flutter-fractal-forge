import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

/// 2D Maps and Attractor Fractals.
///
/// Discrete dynamical systems and strange attractors including
/// Hénon, Tinkerbell, Gingerbreadman, and other iterative maps.

final List<EscapeTimeConfig> mapsAttractorEntries = [
  EscapeTimeConfig(
    id: 'henon',
    name: 'Hénon Map',
    shaderAsset: 'shaders/henon_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'tinkerbell',
    name: 'Tinkerbell Map',
    shaderAsset: 'shaders/tinkerbell_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'gingerbreadman',
    name: 'Gingerbreadman Map',
    shaderAsset: 'shaders/gingerbreadman_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'lozi',
    name: 'Lozi Map',
    shaderAsset: 'shaders/lozi_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'duffing',
    name: 'Duffing Map',
    shaderAsset: 'shaders/duffing_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'ikeda',
    name: 'Ikeda Map',
    shaderAsset: 'shaders/ikeda_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'clifford',
    name: 'Clifford Attractor',
    shaderAsset: 'shaders/clifford_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'peter_de_jong',
    name: 'Peter de Jong Attractor',
    shaderAsset: 'shaders/peter_de_jong_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'svensson',
    name: 'Svensson Attractor',
    shaderAsset: 'shaders/svensson_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'gumowski_mira',
    name: 'Gumowski-Mira Map',
    shaderAsset: 'shaders/gumowski_mira_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 48.0,
  ),
  EscapeTimeConfig(
    id: 'arnold_cat',
    name: "Arnold's Cat Map",
    shaderAsset: 'shaders/arnold_cat_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'standard_map',
    name: 'Standard Map (Chirikov)',
    shaderAsset: 'shaders/standard_map_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'zaslavsky',
    name: 'Zaslavsky Map',
    shaderAsset: 'shaders/zaslavsky_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'kicked_rotator',
    name: 'Kicked Rotator',
    shaderAsset: 'shaders/kicked_rotator_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'chua_circuit',
    name: "Chua's Circuit",
    shaderAsset: 'shaders/chua_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'sprott_a',
    name: 'Sprott Case A',
    shaderAsset: 'shaders/sprott_a_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'burke_shaw',
    name: 'Burke-Shaw Attractor',
    shaderAsset: 'shaders/burke_shaw_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'arneodo',
    name: 'Arneodo Attractor',
    shaderAsset: 'shaders/arneodo_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'thomas_attractor',
    name: 'Thomas Attractor',
    shaderAsset: 'shaders/thomas_attractor_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'four_wing',
    name: 'Four-Wing Attractor',
    shaderAsset: 'shaders/four_wing_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'lorenz_2d',
    name: 'Lorenz Attractor (2D)',
    shaderAsset: 'shaders/lorenz_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'rossler_2d',
    name: 'Rossler Attractor (2D)',
    shaderAsset: 'shaders/rossler_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'dadras',
    name: 'Dadras Attractor',
    shaderAsset: 'shaders/dadras_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'chen',
    name: 'Chen Attractor',
    shaderAsset: 'shaders/chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'lu_chen',
    name: 'Lu-Chen Attractor',
    shaderAsset: 'shaders/lu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'halvorsen',
    name: 'Halvorsen Attractor',
    shaderAsset: 'shaders/halvorsen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'scroll_waves',
    name: 'Scroll Waves Attractor',
    shaderAsset: 'shaders/scroll_waves_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'rikitake',
    name: 'Rikitake Dynamo',
    shaderAsset: 'shaders/rikitake_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
  ),
  EscapeTimeConfig(
    id: 'aizawa',
    name: 'Aizawa Attractor',
    shaderAsset: 'shaders/aizawa_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
  ),
  EscapeTimeConfig(
    id: 'rabinovich_fabrikant',
    name: 'Rabinovich-Fabrikant Attractor',
    shaderAsset: 'shaders/rabinovich_fabrikant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'nose_hoover',
    name: 'Nosé-Hoover Attractor',
    shaderAsset: 'shaders/nose_hoover_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'moore_spiegel',
    name: 'Moore-Spiegel Attractor',
    shaderAsset: 'shaders/moore_spiegel_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'hadley',
    name: 'Hadley Circulation',
    shaderAsset: 'shaders/hadley_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'genesio_tesi',
    name: 'Genesio-Tesi Attractor',
    shaderAsset: 'shaders/genesio_tesi_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'liu_chen',
    name: 'Liu-Chen Attractor',
    shaderAsset: 'shaders/liu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'newton_leipnik',
    name: 'Newton-Leipnik Attractor',
    shaderAsset: 'shaders/newton_leipnik_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'bouali',
    name: 'Bouali Attractor',
    shaderAsset: 'shaders/bouali_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),

  // Dequan Li (2008) — a=40, k=20, f=1.833, c=−11, d=0.16, e=0.65; dragon-wing attractor.
  EscapeTimeConfig(
    id: 'dequan_li',
    name: 'Dequan Li Attractor',
    shaderAsset: 'shaders/dequan_li_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Coullet-Tresser-Arneodo (1979) — cubic Duffing oscillator; double-well potential.
  EscapeTimeConfig(
    id: 'coullet',
    name: 'Coullet Attractor',
    shaderAsset: 'shaders/coullet_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sakarya — a=0.4, b=0.3; compact single-lobe attractor near origin.
  EscapeTimeConfig(
    id: 'sakarya',
    name: 'Sakarya Attractor',
    shaderAsset: 'shaders/sakarya_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Qi-Chen (2005) — a=14, b=43, c=13; four-wing chaotic system.
  EscapeTimeConfig(
    id: 'qi_chen',
    name: 'Qi-Chen Attractor',
    shaderAsset: 'shaders/qi_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Yu-Wang (2012) — a=10, b=40, c=2, d=2.5; exponential coupling exp(xy).
  EscapeTimeConfig(
    id: 'yu_wang',
    name: 'Yu-Wang Attractor',
    shaderAsset: 'shaders/yu_wang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Zhou-Chen (2004) — a=35, b=3, c=28; Lorenz-family four-wing system.
  EscapeTimeConfig(
    id: 'zhou_chen',
    name: 'Zhou-Chen Attractor',
    shaderAsset: 'shaders/zhou_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // TSUCS — Two-Scroll Unified Chaotic System (Elabbasy 2007); double-scroll attractor.
  EscapeTimeConfig(
    id: 'tsucs',
    name: 'TSUCS Attractor',
    shaderAsset: 'shaders/tsucs_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Lorenz-84 atmospheric circulation / Rayleigh-Bénard model (Lorenz 1984).
  EscapeTimeConfig(
    id: 'rayleigh_benard',
    name: 'Rayleigh-Bénard Attractor',
    shaderAsset: 'shaders/rayleigh_benard_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Robinson attractor — Duffing double-well oscillator with z feedback.
  EscapeTimeConfig(
    id: 'robinson',
    name: 'Robinson Attractor',
    shaderAsset: 'shaders/robinson_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Globo-Toroid — toroidal winding chaotic system; a=0.5, b=0.5, c=1.0.
  EscapeTimeConfig(
    id: 'globo_toroid',
    name: 'Globo-Toroid Attractor',
    shaderAsset: 'shaders/globo_toroid_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Tamari — Lorenz-family with reversed xz coupling; a=50, b=0.833, c=20.
  EscapeTimeConfig(
    id: 'tamari',
    name: 'Tamari Attractor',
    shaderAsset: 'shaders/tamari_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Wang-Sun-Cang (2010) — tilted double-scroll; a=0.2, b=0.01, c=−0.4, d=0.5.
  EscapeTimeConfig(
    id: 'wang_sun_cang',
    name: 'Wang-Sun-Cang Attractor',
    shaderAsset: 'shaders/wang_sun_cang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),
];
