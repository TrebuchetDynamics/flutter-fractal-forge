# Allow shared thumbnails for systematic generated rule families

Accepted: systematic generated rule families may use a shared family thumbnail plan when each entry is still a distinct deterministic formula/rule identity with renderer parameters and validation. Shared thumbnails must be treated as family thumbnails, not exact per-entry visual previews. Systematic generated families should promote a target-bounded deterministic subset into the app catalog; the full mathematical rule space remains discoverable/generated capacity, not counted catalog entries by default. This avoids thousands of near-duplicate bundled assets and prevents huge rule spaces from overwhelming the curated 5,000-10,000 entry target while keeping the counted catalog honest about formulas/rules rather than presets, palettes, camera views, or thumbnail-only variants.

## Considered Options

- Require one bundled thumbnail per Counted Catalog Identity.
- Count every mathematically valid rule in a generated family by default.
- Allow a shared family thumbnail for systematic generated rule families and promote only a target-bounded deterministic subset.

## Consequences

The catalog can scale deterministic rule families without excessive asset churn, but UI copy and provenance must not imply that every generated rule has a bespoke visual preview or that every valid rule in a large mathematical family is promoted. Families using shared thumbnails need tests or ledger evidence showing the renderer parameters distinguish each counted identity and that the promoted subset is deterministic and target-bounded.
