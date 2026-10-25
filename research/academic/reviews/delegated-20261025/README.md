# Delegated academic review draft

**ACAD-DRAFT-01 · agent draft only · six sources / 12 pilot identities**

Start with [draft-packet.json](draft-packet.json); [provenance.json](provenance.json) records offline reuse and input hashes. This is a companion to the immutable [preparation package](../ACAD-02-pilot-approval.json) and [six-record brief](../ACAD-02-pilot-approval.md), not a replacement or accepted review. Authority: [delegated academic priorities](../../../../docs/tasks/DELEGATED-DECISIONS-20261025.md#academic-draft-priorities).

## Method and limits

The drafting actor is explicitly an **agent**, not a human reviewer. Exactly the preparation package's six paper IDs and 12 identity IDs are retained: six proposed-unreviewed associations and six unresolved identities. Metadata/rights observations retain their **2026-10-18** date; no external source was revisited. There was no search, full text, PDF/OCR, provider setup, reviewed-alias edit, screening decision, acquisition, accepted extraction, accepted claim, review export or publication. This is **not approval of the 906-record queue**. The original pilot's 20 arXiv attempt failures remain failures, not zero-hit evidence.

Every source and dossier has pending human identity, inclusion, rights, acquisition, extraction and claim fields, with null human actors. Source spans are empty; source equations and independent numerical oracles are null. Equations below describe **local implementation only**, not paper contents or mathematical acceptance. Device/GPU execution, numerical comparison and human composition review were not performed.

## Per-source recommendations, in delegated priority order

All six mapping statuses remain `proposed_unreviewed`. Exact titles, versions, retained result-row references, inherited metadata observations and per-source next inputs are in the packet and immutable preparation package. These recommendations do not include or exclude sources.

| Priority / retained source | Draft role and relevance limit | Rights gap / exact next human input |
|---|---|---|
| 1 · `paper-c797646dae2767ea525a` · Newton root-finding (2012), DOI `10.5120/8821-2742` | **First relevance candidate** for `core.newton_z3`; paper's exact cubic, relaxation and termination are unverified. | No Crossref license record. A named human must adjudicate this DOI/version's identity link and inclusion; supply a lawful access URL and rights basis if requesting acquisition. |
| 2 · `paper-7e5f945cdd5c68bdc9ec` · Newton / Mandelbrot polynomials (2021), arXiv `2109.03765v1` | **Contextual lead**, not canonical quadratic evidence for `core.mandelbrot`. Title also suggests Newton-family context, not an additional mapping. | Retained metadata reports CC BY-NC-SA 4.0; not a commercial-use conclusion. Human must choose exact-identity relevance versus context only, decide inclusion for v1 and separately document lawful access/intended-use rights. |
| 3 · `paper-7d8c6ee70e9aac109422` · Sierpinski relatives (2018), arXiv `1801.08325v1` | **Family context** for `core.sierpinski_triangle`, not evidence of the canonical triangle or shader folds. | Repository non-exclusive distribution terms are not a general reuse grant. Human must adjudicate context relevance and inclusion for v1, with a separate lawful access basis. |
| 4 · `paper-9806495c34ee36881d38` · Lorenz dimension (2016), DOI `10.1016/j.cnsns.2016.04.032` | **Family context** for `core.lorenz_2d`; source conditions, equations, parameters and finite projected trajectory remain unverified. | Elsevier TDM metadata only. Human must decide the identity association/context inclusion and provide lawful access evidence beyond those TDM terms. |
| 5 · `paper-7ecdeae2ea0585a3c4ab` · Mandelbulb magazine item (2009), DOI `10.1016/s0262-4079(09)63150-x` | **Bibliography/attribution only**, not mathematical authority for `core.mandelbulb` or its distance estimator. | Elsevier TDM metadata only. Human must decide supplementary retention and independently document rights/access if requesting content; mathematical authority remains missing. |
| 6 · `paper-7ed9dce0b5117c4a1add` · general IFS chapter (1992), DOI `10.1007/978-3-642-95678-2_1` | **Deprioritize as Barnsley-map evidence** for `core.barnsley_fern`; not specific to its affine maps or Brian's Brain. | Springer TDM metadata; no verified open reuse license. Human must choose unresolved versus general context only and supply a lawful access basis before any content request. |

### Collision and alias alternatives

The [collision record](../../identity-review.json) contains **no title-collision group involving any of these six paper IDs**. That bounded observation does not adjudicate other library collisions or prove these mappings correct. The packet preserves each source's existing DOI aliases, exact version and library/result-row links. Keep stable IDs separate; no merge on title similarity and no change to the empty [reviewed-alias file](../../identity-aliases.json).

For the Newton/Mandelbrot paper, a human could consider Newton-family context instead of the original Mandelbrot proposal, based only on the retained title. That alternative is not inserted as a second mapping. Its related publication DOI is not silently equated with arXiv v1. For all other sources, retain the proposal as context or leave it unresolved rather than invent an exact match. The six identities without a source remain empty-paper-ID gaps, not exclusions.

## Twelve implementation-bound dossier skeletons

Each JSON dossier preserves its preparation mapping/labels, names current paths with SHA-256 and inclusive local-code line ranges, states the equation/source gap, and requests the next attributable human input. Historical inventory previews are not current renderer proof. Common routing: [ModuleRegistry](../../../../lib/core/modules/module_registry.dart) retains later colliding IDs; [FractalRenderer](../../../../lib/features/renderer/widgets/renderer/fractal_renderer.dart) checks a trajectory before precision/CPU/GPU paths.

| Pilot identity | Current local implementation focus / unresolved comparison |
|---|---|
| `core.newton_z3` | [Root-finding config](../../../../lib/core/modules/builders/escape_time_catalog/convergent_root_finding.dart), [shader](../../../../shaders/root_finding/newton_z3_gpu.frag): `z³−1`, relaxed Newton step, singular/convergence/escape guards and nearest-root coloring. Paper's exact cubic is still unknown. |
| `core.mandelbrot` | [Core config](../../../../lib/core/modules/builders/escape_time_catalog/core_escape_time_family.dart), [standard shader](../../../../shaders/legacy/escape_time/mandel_step_smooth.frag): `z₀=0`, quadratic recurrence and interior shortcuts. [Precision resolver](../../../../lib/features/renderer/policy/render_plan.dart) can substitute DF2; CPU/DF2/source equivalence is not checked. |
| `core.koch_snowflake` | [Geometric config](../../../../lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart), [shader](../../../../shaders/ifs_and_geometric/koch_snowflake_gpu.frag): folds, scale-three edge trap and triangle shell. **Unmapped**; canonical substitution/equivalence unverified. |
| `core.sierpinski_triangle` | Same geometric config; [shader](../../../../shaders/ifs_and_geometric/sierpinski_triangle_gpu.frag) includes doubling, reflections and a 0.95 contraction. Related gasket metadata does not validate these operations. |
| `core.barnsley_fern` | Same geometric config; [shader](../../../../shaders/ifs_and_geometric/barnsley_fern_gpu.frag) samples four affine transforms with deterministic hash choices and finite-width orbit strokes. General IFS metadata does not verify coefficients/probabilities. |
| `core.penrose_tiling` | Same geometric config; [shader](../../../../shaders/ifs_and_geometric/penrose_tiling_gpu.frag) projects onto five star directions. **Unmapped**; P3 matching rules/aperiodicity not established by appearance or code comment. |
| `core.henon` | [Attractor config](../../../../lib/core/modules/builders/escape_time_catalog/maps_attractors.dart), [shader](../../../../shaders/strange_attractors/henon_gpu.frag): scaled viewport initial conditions, `a=1.4`, `b=0.3`, escape coloring. **Unmapped**; preparation records reject name-only relevance from encryption/pulse/fifth-dimensional topics. |
| `core.thomas_attractor` | Default **finite RK4 trajectory**, not the registered Euler-texture shader: cyclic sine field with damping 0.208186, Thomas-oblique projection. **Unmapped**; source/parameter/convergence comparison missing. |
| `core.four_wing` | Default **finite RK4 trajectory**, coefficients `(0.2,0.01,−0.4,0.6)`, seed `(1,1,1)`, xz projection. **Unmapped**; exact system variant and source equation unknown. |
| `core.lorenz_2d` | Default **finite RK4 trajectory**, `(σ,ρ,β)=(10,28,8/3)`, xz projection; the old GPU Euler texture has different stepping/initialization. Family dimension paper does not validate this finite presentation. |
| `core.mandelbulb` | Later [raymarched config](../../../../lib/core/modules/builders/raymarched_3d/catalog_impl.dart) / [builder](../../../../lib/core/modules/builders/raymarched_3d/builder.dart) supersede the custom module. [Shader](../../../../shaders/legacy/raymarched_3d/mandelbulb.frag) uses spherical-power DE with static 50-iteration loop; no mathematical authority/oracle supplied by magazine context. |
| `core.brian_brain` | [Cellular config](../../../../lib/core/modules/builders/escape_time_catalog/cellular_stochastic.dart), [shader](../../../../shaders/cellular_and_stochastic/brian_brain_gpu.frag): hash-seeded stateless pseudo-evolution, not a persisted generation grid. **Unmapped**; no transition/boundary/multigeneration oracle. |

The three trajectory dossiers bind [settings](../../../../lib/core/models/attractor_trajectory_settings.dart), [RK4 fields/integrator/projection](../../../../lib/core/modules/attractor_trajectory.dart) and [canvas](../../../../lib/features/renderer/widgets/canvas/attractor_trajectory_canvas.dart): defaults `dt=0.01`, 5,000 burn-in + 20,000 retained steps; Thomas/Lorenz seed `(0.1,0.2,0.3)`. These are implementation observations, not new academic acceptance.

Shared [escape-time builder](../../../../lib/core/modules/builders/escape_time/builder.dart) resolves curated/ID-derived defaults; configured iterations=120 need not be effective iterations=120. It sends extra parameters from slot 10 with local clamps; shared scalar setters do not add those clamps. Current [bailout schema](../../../../lib/core/modules/common_params.dart) expands its maximum to the configured default: the historical four-wing “12 normalized to 8” note is not current source truth. Shader iteration truncation/caps and trajectory precedence remain distinct.

## Next human input / no gate released

For **each mapped identity**, a named human must adjudicate the exact source/version association (or keep it unresolved), inclusion and rights/access separately. For **each unmapped identity**, supply a specific authoritative source identity/version and relevance decision through a separately authorized source workflow; this task does not search for one. Only a separately approved subset with lawful access evidence may proceed to acquisition. Actual source equation spans, accepted extraction, implementation comparison and independent numerical checks must precede separate human claim acceptance. ACAD-01-LIVE, ACAD-02-LIVE and ACAD-03 holds are not released by this packet. Number Walls stays accepted-planned outside these 12 actual pilot IDs.

## Offline validation and preservation

Run from the repository root with the provisioned interpreter; no network is used:

```sh
/usr/bin/python3 -m scripts.research.academic.review_package --repo-root .
/usr/bin/python3 -m pytest test/research/test_academic_review_package.py -q
git diff --check
```

The following read-only check reconciles the new packet, pending/draft invariants, current file bindings, local links and original hashes against the supplied baseline. It does not weaken or replace the preparation validator:

```python
import hashlib, json, re, subprocess
from pathlib import Path

folder = Path('research/academic/reviews/delegated-20261025')
read = lambda path: json.loads(Path(path).read_text())
sha = lambda data: 'sha256:' + hashlib.sha256(data).hexdigest()
p = read(folder / 'draft-packet.json')
q = read(p['preparation_package'])
v = read(folder / 'provenance.json')
assert p['source_revision'] == '5f77b348bd7907cd5e7776b5b05f6be48157bb20'
assert p['status'] == v['status'] == 'agent_draft'
assert p['draft_actor']['type'] == v['actor']['type'] == 'agent'
assert p['paper_count'] == len(p['papers']) == 6
assert p['identity_count'] == len(p['identity_dossiers']) == 12
assert {r['paper_id'] for r in p['papers']} == {r['paper_id'] for r in q['papers']}
assert {r['identity_id'] for r in p['identity_dossiers']} == {r['identity_id'] for r in q['identity_mappings']}
assert sorted(r['priority'] for r in p['papers']) == list(range(1, 7))
assert p['papers'][0]['paper_id'] == 'paper-c797646dae2767ea525a'
assert p['preservation']['preparation_input_hashes'] == q['input_hashes']
assert v['inputs'] == p['preservation']['original_file_hashes']
for path, expected in v['inputs'].items():
    assert sha(Path(path).read_bytes()) == expected, path
    assert sha(subprocess.check_output(['git', 'show', p['source_revision'] + ':' + path])) == expected, path
for row in p['papers'] + p['identity_dossiers']:
    assert row['draft_status'] == 'agent_draft' and row['draft_actor']['type'] == 'agent'
    assert set(row['human_decisions']) == {'identity', 'inclusion', 'rights', 'acquisition', 'extraction', 'claim'}
    assert all(g == {'status': 'pending', 'actor': None} for g in row['human_decisions'].values())
    assert row['claim_state'] == 'unreviewed' and row['accepted_claim'] is False
    assert row['source_spans'] == [] and row['source_equation'] is row['numerical_oracle'] is None
    assert row['next_human_input']
for row in p['papers']:
    old = next(r for r in q['papers'] if r['paper_id'] == row['paper_id'])
    for key in ('title', 'authors', 'year', 'doi', 'arxiv_id', 'exact_version', 'source_url', 'rights_evidence', 'retained_record_ref'):
        assert row[key] == old[key], (row['paper_id'], key)
    assert row['acquired'] is False and row['content_state'] == 'metadata_only'
    assert all(row[k] == 'pending' for k in ('screening_decision', 'identity_approval', 'acquisition_decision', 'extraction_decision', 'claim_approval'))
    assert all(row[k] is None for k in ('screening_actor', 'identity_actor', 'acquisition_actor', 'extraction_actor', 'claim_actor'))
    assert row['mapping_status'] == 'proposed_unreviewed' and row['rights_gap'] and row['alias_alternatives']
for row in p['identity_dossiers']:
    old = next(r for r in q['identity_mappings'] if r['identity_id'] == row['identity_id'])
    assert all(row[k] == value for k, value in old.items())
    assert row['source_equation_gap'] and row['implementation_observation']
    assert row['implementation_bindings']
    for b in row['implementation_bindings']:
        data = Path(b['path']).read_bytes()
        assert sha(data) == b['sha256'], b['path']
        assert 1 <= b['lines'][0] <= b['lines'][1] <= len(data.splitlines())
assert sum(not r['paper_ids'] for r in p['identity_dossiers']) == 6
collisions = read('research/academic/identity-review.json')['title_collisions']
for row in p['papers']:
    assert not any(row['paper_id'] in group['paper_ids'] for group in collisions)
    assert row['collision_group_refs'] == []
assert p['collision_review']['shortlist_collision_group_count'] == 0
boundary = p['decision_boundary']
assert all(boundary[k] is False for k in ('full_text_acquired', 'new_search_performed', 'reviewed_aliases_changed', 'accepted_claim', 'blanket_906_record_approval'))
assert all(g == {'status': 'pending', 'actor': None} for g in boundary['human_decisions'].values())
brief = (folder / 'README.md').read_text()
for row in p['papers'] + p['identity_dossiers']:
    assert row.get('paper_id', row.get('identity_id')) in brief
for target in re.findall(r'\]\(([^)]+)\)', brief):
    path, _, anchor = target.partition('#')
    local = folder / path
    assert local.is_file(), target
    if anchor:
        assert anchor in re.findall(r'^#+ (.+)$', local.read_text(), re.M)[0].lower().replace(' ', '-') or any(
            re.sub(r'[^\w -]', '', heading.lower()).replace(' ', '-') == anchor
            for heading in re.findall(r'^#+ (.+)$', local.read_text(), re.M)), target
assert all((folder / name).is_file() for name in v['outputs'])
print('draft packet: six sources / 12 identities; pending gates, bindings, links and baseline hashes valid')
```

### Maintain boundary and update triggers

Scoped Docs Sync Maintain: this brief is the new slice's entry point and explains its data contract, verification and retained gates. The parent academic README/preparation snapshot remain correct and unchanged; shared roadmap/history/task closeout belongs to the coordinator. No new component/API behavior or task-store change is introduced. Revisit this draft if any bound implementation/input hash changes or a later human review supplies decisions; never repin the immutable preparation package or silently promote a draft to an accepted claim.
