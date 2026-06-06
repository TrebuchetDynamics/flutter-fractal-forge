# Open-source fractal references

This folder stores third-party fractal reference projects and the local analysis distilled from them. Upstream clones are a local-only Reference Corpus; app changes should come from tracked distillation with provenance and license review. See `docs/reference-corpus-workflow.md` for the required provenance record.

- `docs/` — catalogs, implementation notes, provenance workflow, deep-zoom and visual-fidelity extraction notes, and refactor roadmap derived from the reference projects.
- `scripts/` — tracked helper scripts for cloning/updating reference projects. Run `scripts/clone-all.sh --dry-run` to preview the full GitHub reference clone set.
- `repos/` — local-only upstream clones ignored by git; keep only `repos/README.md` tracked.
- `par-fractal/` — local-only legacy clone ignored by git while its nested working tree has local modifications.
