# Engineering docs

Engineering documentation is grouped by responsibility:

- [`development/`](development/) — local setup, build/test workflows, troubleshooting, and agent-oriented development guidance.
- [`rendering/`](rendering/) — renderer architecture, CPU/GPU backend policy, formula coverage, and AR architecture analysis.
- [`performance/`](performance/) — runtime performance, shader optimization, and release build size analysis.
- [`release/`](release/) — official distribution pipelines and operator runbooks.
- [`validation/`](validation/) — GPU/emulator validation, troubleshooting evidence, and generated thumbnail integrity reports.

Core document owners: [product scope](../../PRD.md), [current architecture and change contracts](spec.md), [verification](test-plan.md), [local operations](runbook.md), [workflow queues and history](../README.md#queues-and-history) and [changelog](../../CHANGELOG.md). The [Fibonacci prime-degree Julia note](../../research/fibonacci-prime-degree-julia.md) retains the original research; the [module builder](../../lib/core/modules/builders/fibonacci_complex_module.dart) is now integrated. Implementation, target qualification and release inclusion are separate claims.

Start with [`development/DEVELOPMENT.md`](development/DEVELOPMENT.md) for environment setup, [`rendering/cpu_vs_gpu_rendering.md`](rendering/cpu_vs_gpu_rendering.md) for renderer decisions, or [`performance/PERFORMANCE.md`](performance/PERFORMANCE.md) for runtime performance work.
