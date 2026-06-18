# Shared Renderer Semantic Support Audit

Non-counting audit: a shared shader asset is insufficient unless it exposes parameters that distinguish formula/rule identities.

## Summary

- Candidate total: 19
- Semantic mapping supported: 0
- Needs shader/mapper extension: 19
- Counted now: 0 from this audit

## By batch

| Batch | Total | Supported | Needs extension |
|---|---:|---:|---:|
| mandelbrot | 19 | 0 | 19 |

## Guardrail

Candidates marked `needs_shader_or_mapper_extension` must not be counted until shader/Dart mapping support distinguishes their formula or rule identity and render-smoke validation passes.
