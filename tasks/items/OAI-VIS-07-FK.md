+++
schema = 1
id = "OAI-VIS-07-FK"
title = "Decide fortuin–Kasteleyn cluster and interface explorer.**"
short = "Decide fortuin–Kasteleyn cluster and interface explorer.**"
status = "open"
goal = "OAI-VIS-001"
section = "Needs decision"
rank = 29000
depends_on = []
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Proposed finite-model candidate choice only. Finite square-lattice random-cluster configurations with visible bond probability p, cluster weight q, clusters, boundary wiring and exploration interface. The finite law weights configurations by p^open*(1-p)^closed*q^clusters; it is not independent percolation when q differs from one. Treat q=1 and q=2 as configurations of one family. Existing percolation is not this finite random-cluster law; coordinate with OAI-VIS-03-VORONOI and preserve its ID. It also relates to OAI-VIS-02-SLE but finite lattice connectivity is a different model. Reuse a future common model only if justified by real callers, not a speculative graph framework. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning."
acceptance = ["owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem."]
checks = ["planned discriminating fixtures: Tiny exact partition-function/cluster-count fixtures, q=1 reduction to independent bonds, correct wired/free cluster counting and Dobrushin interface rules, seed replay and explicit sampler mixing gaps. Do not infer arbitrary-q uniformity or SLE convergence from a colorful sample. The inspected first paper covers 1<=q<4; the index lists broader companions, whose hypotheses must be reviewed separately. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN."]
exclusions = []
+++

- Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 223 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
- Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
- Ownership: product owner choice; Needs decision, unassigned. No implementation authority.
- Owner decision: 2026-10-16 — Defer this proposal; prioritize existing quality and academic research. This does not change the existing focus/order or authorize a prototype.
- Next action: Keep this proposal in Needs decision, deferred rather than completed; do not select or implement it unless the owner later revisits it.
- Touches: none before conversion; ** stands for the whole repository
