# Shared Renderer Promotion Plan

Non-counting implementation plan for existing-app source leads that may share reviewed renderer shaders.

## Summary

- Input audit: `research/worlds-largest-fractal-catalog/existing-app-shader-linkage-audit.json`
- Candidate leads: 355
- Candidate shader batches: 19
- Counted now: 0 from this plan

## Counting guardrail

Candidates remain uncounted until formula/rule identity, renderer path, parameter mapping, thumbnail, provenance, and render validation all pass. Presets/random seeds/palettes/camera views are not entries.

## Batches

| Candidate shared shader | Leads | Status |
|---|---:|---|
| `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag` | 99 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/core/julia_gpu.frag` | 56 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/core/mandel_julia_dual_gpu.frag` | 44 | implementation_plan_only_not_counted |
| `shaders/strange_attractors/sprott_a_gpu.frag` | 34 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag` | 25 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag` | 20 | implementation_plan_only_not_counted |
| `shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag` | 14 | implementation_plan_only_not_counted |
| `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag` | 13 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag` | 10 | implementation_plan_only_not_counted |
| `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag` | 9 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag` | 9 | implementation_plan_only_not_counted |
| `shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag` | 6 | implementation_plan_only_not_counted |
| `shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag` | 3 | implementation_plan_only_not_counted |
| `shaders/cellular_and_stochastic/replicator_ca_gpu.frag` | 3 | implementation_plan_only_not_counted |
| `shaders/escape_time_family/core/phoenix_gpu.frag` | 3 | implementation_plan_only_not_counted |
| `shaders/cellular_and_stochastic/cyclic_ca_gpu.frag` | 2 | implementation_plan_only_not_counted |
| `shaders/cellular_and_stochastic/maze_ca_gpu.frag` | 2 | implementation_plan_only_not_counted |
| `shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag` | 2 | implementation_plan_only_not_counted |
| `shaders/cellular_and_stochastic/forest_fire_gpu.frag` | 1 | implementation_plan_only_not_counted |

## Promotion gates

- review shared shader semantic compatibility with the generated module formula/rule
- define parameter mapping from generated module defaults/metadata to shared shader uniforms
- register or otherwise expose the generated formula/rule as a renderable catalog identity
- run render smoke and quality metrics for the mapped renderer
- verify thumbnail asset exists and is not a random preset/palette/camera-only variant
- flip counted_entry only after validator and completion audit inputs see existing renderer + validation signals

## Candidate IDs by batch

### `shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0881_elementary_ca_rule_2, f0882_elementary_ca_rule_4, f0883_elementary_ca_rule_6, f0884_elementary_ca_rule_8, f0885_elementary_ca_rule_10, f0886_elementary_ca_rule_12, f0887_elementary_ca_rule_14, f0888_elementary_ca_rule_16, f0889_elementary_ca_rule_18, f0890_elementary_ca_rule_20, f0891_elementary_ca_rule_24, f0892_elementary_ca_rule_26, f0893_elementary_ca_rule_28, f0894_elementary_ca_rule_32, f0895_elementary_ca_rule_34, f0896_elementary_ca_rule_36, f0897_elementary_ca_rule_38, f0898_elementary_ca_rule_40, f0899_elementary_ca_rule_42, f0900_elementary_ca_rule_44, f0901_elementary_ca_rule_46, f0902_elementary_ca_rule_56, f0903_elementary_ca_rule_58, f0904_elementary_ca_rule_64, f0905_elementary_ca_rule_66, f0906_elementary_ca_rule_68, f0907_elementary_ca_rule_70, f0908_elementary_ca_rule_72, f0909_elementary_ca_rule_74, f0910_elementary_ca_rule_76, f0911_elementary_ca_rule_78, f0912_elementary_ca_rule_80, f0913_elementary_ca_rule_82, f0914_elementary_ca_rule_84, f0915_elementary_ca_rule_88, f0916_elementary_ca_rule_92, f0917_elementary_ca_rule_96, f0918_elementary_ca_rule_98, f0919_elementary_ca_rule_100, f0920_elementary_ca_rule_104, f0921_elementary_ca_rule_106, f0922_elementary_ca_rule_108, f0923_elementary_ca_rule_112, f0924_elementary_ca_rule_114, f0925_elementary_ca_rule_118, f0926_elementary_ca_rule_120, f0927_elementary_ca_rule_124, f0928_elementary_ca_rule_128, f0929_elementary_ca_rule_130, f0930_elementary_ca_rule_132, f0931_elementary_ca_rule_134, f0932_elementary_ca_rule_136, f0933_elementary_ca_rule_138, f0934_elementary_ca_rule_140, f0935_elementary_ca_rule_142, f0936_elementary_ca_rule_144, f0937_elementary_ca_rule_146, f0938_elementary_ca_rule_148, f0939_elementary_ca_rule_152, f0940_elementary_ca_rule_154, f0941_elementary_ca_rule_156, f0942_elementary_ca_rule_158, f0943_elementary_ca_rule_160, f0944_elementary_ca_rule_162, f0945_elementary_ca_rule_164, f0946_elementary_ca_rule_166, f0947_elementary_ca_rule_168, f0948_elementary_ca_rule_170, f0949_elementary_ca_rule_172, f0950_elementary_ca_rule_174, f0951_elementary_ca_rule_176, f0952_elementary_ca_rule_178, f0953_elementary_ca_rule_180, f0954_elementary_ca_rule_186, f0955_elementary_ca_rule_188, f0956_elementary_ca_rule_190, f0957_elementary_ca_rule_192, f0958_elementary_ca_rule_194, f0959_elementary_ca_rule_196, f0960_elementary_ca_rule_198, f0961_elementary_ca_rule_200, f0962_elementary_ca_rule_202, f0963_elementary_ca_rule_204, f0964_elementary_ca_rule_206, f0965_elementary_ca_rule_208, f0966_elementary_ca_rule_210, f0967_elementary_ca_rule_212, f0968_elementary_ca_rule_214, f0969_elementary_ca_rule_218, f0970_elementary_ca_rule_220, f0971_elementary_ca_rule_222, f0972_elementary_ca_rule_226, f0973_elementary_ca_rule_230, f0974_elementary_ca_rule_232, f0975_elementary_ca_rule_234, f0976_elementary_ca_rule_238, f0977_elementary_ca_rule_242, f0978_elementary_ca_rule_246, f0979_elementary_ca_rule_254

### `shaders/escape_time_family/core/julia_gpu.frag`

Julia-style complex-plane identities. Needs c-parameter/seed mapping from metadata or a reviewed default, not random presets.

f0143_dendrite_julia, f0144_airplane_julia, f0145_seahorse_valley_julia, f0146_basilica_julia, f0147_san_marco_julia, f0148_kaleidoscope_julia, f0149_cactus_julia, f0150_fatou_dust_julia, f0151_siegel_disk_julia, f0152_galaxy_julia, f0153_dragon_julia, f0154_period_3_julia, f0155_period_4_julia, f0156_period_5_julia, f0157_period_6_julia, f0158_period_7_julia, f0161_swirl_julia, f0162_lightning_julia, f0163_filigree_julia, f0164_spiral_julia, f0166_chebyshev_julia, f0167_cauliflower_bulb_julia, f0173_mini_brot_julia, f0174_elephant_valley_julia, f0175_near_elephant_julia, f0176_dendritic_tree_julia, f0177_mink_julia, f0178_star_julia, f0180_jumping_jack_julia, f0181_twin_spiral_julia, f0182_hyperbolic_julia, f0184_centrally_symmetric_julia, f0185_thistle_julia, f0186_zig_zag_julia, f0187_spider_julia, f0188_flower_julia, f0189_medusa_julia, f0190_broccoli_julia, f0191_spring_julia, f0192_maze_julia, f0193_gossamer_julia, f0194_sparse_dust_julia, f0195_period_8_julia, f0196_period_9_julia, f0197_near_boundary_julia, f0198_grainy_julia, f0199_flying_bird_julia, f0200_infinity_julia, f0201_northern_light_julia, f0202_lacework_julia, f0461_julia_island, f0484_miniature_julia_region, f1224_chebyshev_julia_t_2, f1225_chebyshev_julia_t_3, f1226_chebyshev_julia_t_5, f1232_elliptic_function_julia

### `shaders/escape_time_family/core/mandel_julia_dual_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0119_celtic_mandelbrot, f0120_buffalo_mandelbrot, f0121_heart_mandelbrot, f0122_perpendicular_mandelbrot, f0123_anti_mandelbrot, f0124_cubic_mandelbrot_c_additive, f0125_quartic_mandelbrot_c_additive, f0126_mandelbrot_scaled, f0127_lambda_mandelbrot, f0134_mandelbrot_power_d_2_7, f0135_mandelbrot_power_d_1_25, f0431_mini_mandelbrot_period_2, f0432_mini_mandelbrot_period_3, f0433_mini_mandelbrot_period_4, f0434_mini_mandelbrot_period_5, f0435_mini_mandelbrot_period_6, f0436_mini_mandelbrot_period_7, f0437_mini_mandelbrot_period_8, f0438_mini_mandelbrot_period_9, f0439_mini_mandelbrot_period_10, f0440_mini_mandelbrot_period_11, f0441_mini_mandelbrot_period_12, f0442_mini_mandelbrot_period_13, f0443_mini_mandelbrot_period_14, f0444_mini_mandelbrot_period_15, f0445_mini_mandelbrot_period_16, f0446_mini_mandelbrot_period_17, f0447_mini_mandelbrot_period_18, f0448_mini_mandelbrot_period_19, f0449_mini_mandelbrot_period_20, f0475_mandelbrot_antenna, f0486_sine_mandelbrot, f0487_cosine_mandelbrot, f0488_exponential_mandelbrot, f0489_log_mandelbrot, f0490_tangent_mandelbrot, f0491_hyperbolic_sine_mandelbrot, f0492_hyperbolic_cosine_mandelbrot, f0493_hyperbolic_tangent_mandelbrot, f0494_z_exp_z_mandelbrot, f0495_z_sin_z_mandelbrot, f0496_z_sin_z_mandelbrot, f0497_z_cos_z_mandelbrot, f0531_gamma_mandelbrot

### `shaders/strange_attractors/sprott_a_gpu.frag`

Sprott-style attractor identities. Needs per-system coefficient mapping; do not collapse distinct Sprott equations into one visual without parameter validation.

f0014_sprott_a, f0015_sprott_b, f0016_sprott_c, f0017_sprott_d, f0018_sprott_e, f0019_sprott_f, f0020_sprott_g, f0021_sprott_h, f0022_sprott_i, f0023_sprott_j, f0024_sprott_k, f0025_sprott_l, f0026_sprott_m, f0027_sprott_n, f0028_sprott_o, f0029_sprott_p, f0030_sprott_q, f0031_sprott_r, f0032_sprott_s, f0033_sprott_linz_a, f0034_sprott_linz_b, f0035_sprott_linz_c, f0036_sprott_linz_d, f0037_sprott_linz_e, f0038_sprott_linz_f, f0039_sprott_linz_g, f0040_sprott_linz_h, f0041_sprott_linz_i, f0042_sprott_linz_j, f0043_sprott_labyrinth_chaos, f0044_sprott_minimum_chaotic_flow, f0045_sprott_windmi, f0046_sprott_conservative_sc, f0086_sprott_jafari_no_equilibrium

### `shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f1155_orbit_trap_circle_pickover_stalks, f1156_orbit_trap_cross, f1157_orbit_trap_square, f1158_orbit_trap_point_origin, f1159_orbit_trap_point_custom, f1160_orbit_trap_line_real_axis, f1161_orbit_trap_line_imaginary_axis, f1162_orbit_trap_multi_lines_cross, f1163_orbit_trap_heart_curve, f1164_orbit_trap_star_5_pointed, f1165_orbit_trap_spiral, f1166_orbit_trap_text_a, f1167_orbit_trap_text_m, f1168_orbit_trap_epicycloid, f1169_orbit_trap_rose_curve, f1170_orbit_trap_lima_on, f1171_orbit_trap_cardioid, f1172_orbit_trap_lemniscate, f1173_orbit_trap_astroid, f1174_orbit_trap_hypocycloid_3_cusp, f1175_orbit_trap_square_lattice, f1176_orbit_trap_hexagonal_lattice, f1177_orbit_trap_field_lines, f1178_orbit_trap_composite_multi_shape, f1179_orbit_trap_concentric_rings

### `shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0088_multibrot_z_13, f0089_multibrot_z_14, f0090_multibrot_z_15, f0091_multibrot_z_16, f0092_multibrot_z_17, f0093_multibrot_z_18, f0094_multibrot_z_19, f0095_multibrot_z_20, f0096_multibrot_d_0_5, f0097_multibrot_d_3_5, f0098_multibrot_d_4_5, f0099_multibrot_d_5_5, f0100_multibrot_d_6_5, f0101_multibrot_d_7_5, f0102_multibrot_d_8_5, f0103_inverse_multibrot_d_3, f0104_inverse_multibrot_d_4, f0105_inverse_multibrot_d_5, f0136_multibrot_z_1_8, f0137_multibrot_z_2_3

### `shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0498_sin_z_c, f0502_sin_1_z_c, f0505_sin_z_cos_z_c, f0506_sinh_z_cosh_z_c, f0507_log_sin_z_c, f0509_sin_z_z_c, f0517_sin_z_1_c, f0519_sin_z_c, f0521_sin_z_c, f0525_sinh_z_c, f0526_sin_z_z_c, f0528_exp_z_sin_z_c, f0538_newton_sin, f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin

### `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0570_mandelbox_s_1_5, f0571_mandelbox_s_1_8, f0572_mandelbox_s_2_0, f0573_mandelbox_s_2_2, f0574_mandelbox_s_2_5, f0575_mandelbox_s_2_7, f0576_mandelbox_s_3_0, f0577_mandelbox_s_3_5, f0578_mandelbox_s_4_0, f0579_mandelbox_s_1_5, f0580_mandelbox_s_2_0, f0581_mandelbox_s_2_5, f0582_mandelbox_s_3_0

### `shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0106_tricorn_d_9, f0107_tricorn_d_10, f0108_tricorn_d_11, f0109_tricorn_d_12, f0110_tricorn_d_13, f0111_tricorn_d_14, f0112_tricorn_d_15, f0138_tricorn_z_1_5, f0139_tricorn_z_2_5, f1153_buddhabrot_tricorn

### `shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0561_mandelbulb_n_8, f0562_mandelbulb_n_9, f0563_mandelbulb_n_10, f0564_mandelbulb_n_11, f0565_mandelbulb_n_12, f0566_mandelbulb_n_14, f0567_mandelbulb_n_16, f0568_mandelbulb_n_20, f0569_mandelbulb_n_24

### `shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0113_burning_ship_d_7, f0114_burning_ship_d_8, f0115_burning_ship_d_9, f0116_burning_ship_d_10, f0117_burning_ship_d_11, f0118_burning_ship_d_12, f0140_burning_ship_z_2_5, f0141_burning_ship_z_1_5, f1152_buddhabrot_burning_ship

### `shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0499_cos_z_c, f0508_log_cos_z_c, f0518_cos_z_1_c, f0520_cos_z_c, f0527_cos_z_z_c, f0537_newton_cos

### `shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0540_quaternion_julia_0_2_0_8_0_0_0_0, f0544_quaternion_julia_0_291_0_399_0_339_0_437, f0545_quaternion_julia_0_08_0_0_0_8_0_0

### `shaders/cellular_and_stochastic/replicator_ca_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0980_replicator_b1357_s1357, f0981_fredkin_s_replicator_b1357_s02468, f0995_replicator_4_b1357_s03567

### `shaders/escape_time_family/core/phoenix_gpu.frag`

Phoenix escape-time identities. Needs degree/feedback parameter compatibility review.

f0131_phoenix_d_2, f0132_phoenix_d_3, f0133_phoenix_d_4

### `shaders/cellular_and_stochastic/cyclic_ca_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f1021_cyclic_ca_n_4, f1022_cyclic_ca_n_16

### `shaders/cellular_and_stochastic/maze_ca_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0983_mazectric_b3_s1234, f1005_maze_with_mice_b37_s12345

### `shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f0594_menger_sponge_3d, f0597_sierpinski_carpet_3d_menger_cross

### `shaders/cellular_and_stochastic/forest_fire_gpu.frag`

Requires reviewed shared renderer mapping before promotion.

f1024_forest_fire_ca

