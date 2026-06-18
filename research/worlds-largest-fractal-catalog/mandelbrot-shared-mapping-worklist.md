# Mandelbrot Shared Mapping Worklist

Non-counting mapping worklist for Mandelbrot-family existing-app source leads.

## Summary

- Candidate shared shader: `shaders/escape_time_family/core/mandel_julia_dual_gpu.frag`
- Candidate leads: 44
- Ready view/period mappings: 19
- Needs renderer compatibility review: 25
- Counted now: 0 from this worklist

## Guardrail

Mandelbrot-family formula/view identities remain uncounted until shared renderer mapping and render validation pass; view aliases identify named stable regions, not random camera presets.

## Items

| Stable ID | Status | Parsed mapping |
|---|---|---|
| `f0119_celtic_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0120_buffalo_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0121_heart_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0122_perpendicular_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0123_anti_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0124_cubic_mandelbrot_c_additive` | needs_manual_mandelbrot_mapping_review |  |
| `f0125_quartic_mandelbrot_c_additive` | needs_manual_mandelbrot_mapping_review |  |
| `f0126_mandelbrot_scaled` | needs_manual_mandelbrot_mapping_review |  |
| `f0127_lambda_mandelbrot` | needs_formula_variant_shader_review |  |
| `f0134_mandelbrot_power_d_2_7` | needs_power_uniform_compatibility_review | {"power": 2.7} |
| `f0135_mandelbrot_power_d_1_25` | needs_power_uniform_compatibility_review | {"power": 1.25} |
| `f0431_mini_mandelbrot_period_2` | ready_for_view_region_review | {"period": 2, "view": {"center_im": 0.0, "center_re": -1.75, "source_alias": "view (-1.75, 0.0) zoom 50.0", "zoom": 50.0}} |
| `f0432_mini_mandelbrot_period_3` | ready_for_view_region_review | {"period": 3, "view": {"center_im": 1.0317, "center_re": -0.1592, "source_alias": "view (-0.1592, 1.0317) zoom 50.0", "zoom": 50.0}} |
| `f0433_mini_mandelbrot_period_4` | ready_for_view_region_review | {"period": 4, "view": {"center_im": 0.5305, "center_re": 0.2815, "source_alias": "view (0.2815, 0.5305) zoom 100.0", "zoom": 100.0}} |
| `f0434_mini_mandelbrot_period_5` | ready_for_view_region_review | {"period": 5, "view": {"center_im": 0.5627, "center_re": -0.5043, "source_alias": "view (-0.5043, 0.5627) zoom 200.0", "zoom": 200.0}} |
| `f0435_mini_mandelbrot_period_6` | ready_for_view_region_review | {"period": 6, "view": {"center_im": 0.3803, "center_re": -1.2573, "source_alias": "view (-1.2573, 0.3803) zoom 200.0", "zoom": 200.0}} |
| `f0436_mini_mandelbrot_period_7` | ready_for_view_region_review | {"period": 7, "view": {"center_im": 1.1151, "center_re": -0.2282, "source_alias": "view (-0.2282, 1.1151) zoom 500.0", "zoom": 500.0}} |
| `f0437_mini_mandelbrot_period_8` | ready_for_view_region_review | {"period": 8, "view": {"center_im": 0.659, "center_re": -0.3743, "source_alias": "view (-0.3743, 0.659) zoom 1000.0", "zoom": 1000.0}} |
| `f0438_mini_mandelbrot_period_9` | ready_for_view_region_review | {"period": 9, "view": {"center_im": 0.6049, "center_re": -0.4521, "source_alias": "view (-0.4521, 0.6049) zoom 2000.0", "zoom": 2000.0}} |
| `f0439_mini_mandelbrot_period_10` | ready_for_view_region_review | {"period": 10, "view": {"center_im": 0.0, "center_re": -1.4812, "source_alias": "view (-1.4812, 0.0) zoom 5000.0", "zoom": 5000.0}} |
| `f0440_mini_mandelbrot_period_11` | ready_for_view_region_review | {"period": 11, "view": {"center_im": 0.005, "center_re": -1.3932, "source_alias": "view (-1.3932, 0.005) zoom 20000.0", "zoom": 20000.0}} |
| `f0441_mini_mandelbrot_period_12` | ready_for_view_region_review | {"period": 12, "view": {"center_im": 0.5655, "center_re": -0.5, "source_alias": "view (-0.5, 0.5655) zoom 30000.0", "zoom": 30000.0}} |
| `f0442_mini_mandelbrot_period_13` | ready_for_view_region_review | {"period": 13, "view": {"center_im": 0.105, "center_re": -0.7682, "source_alias": "view (-0.7682, 0.105) zoom 50000.0", "zoom": 50000.0}} |
| `f0443_mini_mandelbrot_period_14` | ready_for_view_region_review | {"period": 14, "view": {"center_im": 0.0, "center_re": -1.5, "source_alias": "view (-1.5, 0.0) zoom 100000.0", "zoom": 100000.0}} |
| `f0444_mini_mandelbrot_period_15` | ready_for_view_region_review | {"period": 15, "view": {"center_im": 0.1127, "center_re": -0.7453, "source_alias": "view (-0.7453, 0.1127) zoom 200000.0", "zoom": 200000.0}} |
| `f0445_mini_mandelbrot_period_16` | ready_for_view_region_review | {"period": 16, "view": {"center_im": 0.3774, "center_re": -1.2488, "source_alias": "view (-1.2488, 0.3774) zoom 500000.0", "zoom": 500000.0}} |
| `f0446_mini_mandelbrot_period_17` | ready_for_view_region_review | {"period": 17, "view": {"center_im": 0.1352, "center_re": -0.7428, "source_alias": "view (-0.7428, 0.1352) zoom 1000000.0", "zoom": 1000000.0}} |
| `f0447_mini_mandelbrot_period_18` | ready_for_view_region_review | {"period": 18, "view": {"center_im": 0.0, "center_re": -1.4791, "source_alias": "view (-1.4791, 0.0) zoom 1000000.0", "zoom": 1000000.0}} |
| `f0448_mini_mandelbrot_period_19` | ready_for_view_region_review | {"period": 19, "view": {"center_im": 0.131825904, "center_re": -0.743643887, "source_alias": "view (-0.743643887, 0.131825904) zoom 100000000.0", "zoom": 100000000.0}} |
| `f0449_mini_mandelbrot_period_20` | ready_for_view_region_review | {"period": 20, "view": {"center_im": 0.13182590420533, "center_re": -0.743643887037151, "source_alias": "view (-0.743643887037151, 0.13182590420533) zoom 10000000000.0", "zoom": 10000000000.0}} |
| `f0475_mandelbrot_antenna` | needs_manual_mandelbrot_mapping_review |  |
| `f0486_sine_mandelbrot` | needs_transcendental_shader_review |  |
| `f0487_cosine_mandelbrot` | needs_transcendental_shader_review |  |
| `f0488_exponential_mandelbrot` | needs_transcendental_shader_review |  |
| `f0489_log_mandelbrot` | needs_transcendental_shader_review |  |
| `f0490_tangent_mandelbrot` | needs_transcendental_shader_review |  |
| `f0491_hyperbolic_sine_mandelbrot` | needs_transcendental_shader_review |  |
| `f0492_hyperbolic_cosine_mandelbrot` | needs_transcendental_shader_review |  |
| `f0493_hyperbolic_tangent_mandelbrot` | needs_transcendental_shader_review |  |
| `f0494_z_exp_z_mandelbrot` | needs_transcendental_shader_review |  |
| `f0495_z_sin_z_mandelbrot` | needs_transcendental_shader_review |  |
| `f0496_z_sin_z_mandelbrot` | needs_transcendental_shader_review |  |
| `f0497_z_cos_z_mandelbrot` | needs_transcendental_shader_review |  |
| `f0531_gamma_mandelbrot` | needs_transcendental_shader_review |  |
