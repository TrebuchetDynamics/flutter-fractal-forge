# CPU Formula Coverage Limitation

CPU availability is module-specific, not a fixed fraction of the catalog and not proof of GPU/CPU image parity. Read the [formula resolver and capability predicates](../../../lib/features/renderer/cpu/formulas/cpu_formulas.dart), [precision ladder](../../../lib/features/renderer/policy/precision_ladder_policy.dart) and [backend policy](../../../lib/features/renderer/policy/backend_policy.dart) for the current decisions.

## Capability boundaries

- `hasNativeCpuFormula` identifies native recurrences eligible for the precision ladder. A deterministic synthetic approximation is **not CPU Precision** or mathematical certification.
- `hasCuratedCpuFormula` also includes curated synthetic previews. A successful lookup or nonblank image alone does not establish equivalence to the module's GPU formula.
- Modules without an eligible native formula must not acquire an exactness claim merely because zoom crossed a threshold. Extended GPU preview remains preview-grade.
- GPU-required modules and exact discrete visualizations can have specialized paths or explicit unsupported states; do not infer universal CPU support from the generic resolver.
- Catalog thumbnails are runtime-rendered. Consult the [thumbnail plan](../../../lib/features/catalog/data/catalog_thumbnail_plan.dart) for availability/fallback labels, rather than assuming every missing CPU formula displays Mandelbrot artwork.

## Verification and scope

The [backend matrix](renderer_backend_matrix.md) separates source policy, dated target observations and unknown platform behavior. The [verification plan](../test-plan.md) owns real-view/export and target gates. Formula registration alone proves neither arbitrary-depth accuracy nor matching exported pixels.

The former v1.0 “8 out of 197” inventory and generic-Mandelbrot thumbnail description no longer describe this tree. There is no current endorsement of universal GPU coverage, a scheduled full-parity phase, or analytics-based prioritization; the production app has no remote usage analytics. Use the [current product contract](../../../PRD.md) and [privacy policy](../../store_listing/PRIVACY_POLICY.md), not those superseded promises.
