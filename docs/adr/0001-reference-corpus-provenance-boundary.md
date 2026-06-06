# Keep upstream fractal clones as a Reference Corpus

Accepted: upstream fractal repositories cloned under `opensource/repos/` and `opensource/par-fractal/` are a local-only Reference Corpus, not app source. We keep research notes, scripts, manifests, and distilled findings tracked in git, but direct production reuse must be preceded by tracked provenance and license review; this trades copy-paste speed for license hygiene and clearer engineering memory.

## Considered Options

- Track upstream repositories as gitlinks or vendored source for convenient browsing.
- Ignore upstream repositories and track only distilled notes/scripts/manifests.

## Consequences

The clone corpus can be refreshed or deleted without changing the app repository, but every imported idea needs a tracked note or implementation rationale that names the source and license context.
