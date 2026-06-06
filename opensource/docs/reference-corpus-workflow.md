# Reference Corpus Workflow

Use this workflow when mining `opensource/repos/` or `opensource/par-fractal/` for ideas to adapt into Flutter Fractal Forge.

The Reference Corpus is research input, not app source. Before any upstream idea influences production code, create or update a tracked provenance record in the relevant research note, catalog entry, issue, or implementation plan.

## Minimum provenance record

```md
## Provenance

- Source repo: https://github.com/<owner>/<repo>
- Source path: <path/in/source/repo>
- Source commit: <sha>
- License: <license identifier or "unknown"> via <LICENSE path or upstream URL>
- Idea summary: <algorithm, parameter range, UI pattern, validation trick, etc.>
- Reuse mode: adapted idea | direct reuse candidate
- Target app area: <Flutter file/module/shader/docs path>
- Validation signal: <test, analyzer, shader compile, screenshot/pixel check, benchmark, or manual check>
```

## Rules

- Prefer adapted implementations in our own style over direct source reuse.
- Direct reuse requires explicit license compatibility notes before editing app code.
- Do not cite ignored clone paths alone; include the upstream URL and commit SHA so the record survives deleting local clones.
- Keep extracted notes and decisions tracked in git; keep upstream clone directories ignored by git.
- If the source license is missing, unclear, or incompatible, use the idea only as mathematical/architectural context and do not copy code or assets.

## Example

```md
## Provenance

- Source repo: https://github.com/buddhi1980/mandelbulber2
- Source path: mandelbulber2/formula/opencl/mandelbulb.cl
- Source commit: <sha>
- License: GPL-3.0-or-later via LICENSE
- Idea summary: Mandelbulb distance-estimator parameter ranges and normal-sampling strategy.
- Reuse mode: adapted idea
- Target app area: shaders/mandelbulb.frag; lib/core/modules/mandelbox_module.dart
- Validation signal: shader compile plus visual/pixel comparison against existing Mandelbulb preset.
```
