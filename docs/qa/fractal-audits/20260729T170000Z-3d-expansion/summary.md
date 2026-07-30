# Researched 3D catalog expansion and re-audit

## Objective and acceptance criteria

Research and add multiple mathematically distinct 3D fractals, preserve the prior identity cleanup, avoid counting parameter presets as fractals, provide source/provenance artifacts, and re-audit every 3D entry with shader, image-health, analyzer, and full-suite evidence.

## Research

- Package: `research/3d-fractal-expansion-2026-07-29/`
- Depth: comprehensive
- ResearchForge: v0.1.19
- Queries: 20
- Sources: OpenAlex, Crossref, arXiv
- Coverage: 545 records; 421 deduplicated; 336 unique DOIs
- Source counts: OpenAlex 148, Crossref 197, arXiv 200
- Citation expansions: 3 attempted and completed; Vicsek returned 20 edges, the two other seeds returned zero
- Full text: not acquired
- Third-party shader code: not copied
- Core artifacts: `report.md`, `provenance.json`, `evidence-grid.json`, `evidence-gaps.json`, `coverage-stats.log`

The selection gate was the Counted Catalog Identity rule. Fixed powers, constants, colors, and views remain parameters/presets rather than new entries.

## Added/promoted identities

1. **Juliabulb 3D** (`juliabulb_3d`)
   - One configurable Julia family of the White-Nylander polar power map.
   - Exposes power and `c=(cx,cy,cz)`; three constants are presets, not entries.
   - Fresh local shader: `juliabulb_3d_gpu.frag`.
2. **Vicsek 3D** (`vicsek_3d`)
   - Exact center-cross IFS: 7 maps at ratio 1/3.
   - Distinct from the retained 2D `vicsek_fractal`.
3. **Jerusalem Cube 3D** (`jerusalem_cube_3d`)
   - Mixed-scale IFS: 8 corner maps at `sqrt(2)-1`, 12 edge maps at its square.
   - Distinct from the retained 2D cross-section.
4. **Sierpinski Octahedron 3D** (`sierpinski_octahedron_3d`)
   - Six half-scale maps toward the regular octahedron vertices.
   - Distinct from the four-map Sierpinski tetrahedron.
5. **Pseudo-Kleinian** (`pseudo_kleinian`)
   - Existing identity promoted from a 2D projection to a rotatable 3D box-fold/sphere-inversion renderer.
   - Explicitly documented as a community pseudo-Kleinian, not a mathematical Kleinian-group limit set.

The three polyhedral IFS identities share one reviewed shader with fixed selector values. The builder now permits formula modules without a misleading power slider.

## Catalog impact

- 3D category: 18 → 23 identities
- New stable IDs: 4
- Existing identity promoted to 3D: 1
- Production fractals: 953 → 957
- Scientific visualizations: 1
- Debug/test registry modules: 961 → 965
- Escape-time raw entries: 502 → 501 (Pseudo-Kleinian moved out)
- Ray-marched configs: 16 → 20
- Custom modules: 8 → 9

The previous 24 clone/alias removals remain locked by `three_d_catalog_identity_test.dart`; none were reintroduced.

## Render audit

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/pass: 18/18/18
- failures/skips/warnings/Flutter errors: 0/0/0/0

Final strict audit: `final_3d_thumbnail_report.json`

- selected: 23
- generated: 23
- render pass: 23
- failed: 0
- skipped: 0
- warnings/non-pass: 0
- Flutter errors: 0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracle: pass 0, fail 0, skipped 23

The five researched entries also passed a focused strict GPU audit before the full 3D run. Their staged 96×96 previews were inspected alongside objective PNG/color/luminance metrics; all contain visible non-flat structure.

## Verification

- Research JSON files parse: pass
- `rforge search stats`: three non-zero sources, 545 records
- Source/identity contract tests: pass
- New runtime-effect shader compilation tests: pass
- Focused catalog/count/ledger tests: 30 passed
- Strict focused GPU audit: 5/5 pass
- Strict full 3D GPU audit: 23/23 pass
- `flutter analyze`: pass, no issues
- `flutter test`: 1858 passed, 3 skipped
- `bash -n scripts/run_fractal_render_audit.sh`: pass
- `git diff --check`: pass

## Prompt-to-artifact completion checklist

| Requirement | Evidence | Status |
|---|---|---|
| Research more 3D fractals | Comprehensive ResearchForge package with 20 queries, 3 sources, reports, provenance, evidence grid/gaps | Complete |
| Add multiple distinct identities | Four new IDs plus one 3D promotion in catalog/module/shader sources | Complete |
| Do not add parameter spam | Juliabulb powers/constants remain controls/presets; fixed IFS selectors are hidden | Complete |
| Preserve prior removals | Exact 23-ID catalog test plus removed-clone intersection test | Complete |
| Validate mathematical construction | Shader contract tests lock map counts, scales, recurrence, and fold/inversion operations | Complete |
| Validate rendering objectively | Focused and complete strict GPU reports with PNG metrics and zero non-pass verdicts | Complete |
| Keep counts and ledger accurate | Registry/count tests, README/store/PRD/TODO updates, scoped live-ledger additions | Complete |
| Repository regression gate | Full analyzer and complete Flutter unit/widget suite pass | Complete |

## Remaining evidence limitation

The render pipeline has no stable CPU distance-estimator oracle for 3D formulas, so all 23 math-oracle rows are skipped. Formula assurance comes from explicit construction contracts, shader compilation, finite bounded controls, complete strict GPU metrics, and provenance records. The exact historical naming lineage for the six-map octahedral IFS remains the weakest research point and is documented without a priority claim.
