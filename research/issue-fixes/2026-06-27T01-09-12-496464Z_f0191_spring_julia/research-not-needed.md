# Research not needed

Issue: `issues/2026-06-27T01-09-12-496464Z_f0191_spring_julia.json`

This is a local parameter-schema bug, not a domain/math uncertainty:

- The issue notes randomize produces bad results for `f0191_spring_julia` and shows a randomized `iterations=4368`.
- Shared Julia modules used `CommonFractalParams.iterations(defaultValue: 280)` without a max override, so randomization could choose up to 5000 iterations.
- The shared Julia shader is an interactive GPU shader and should use the same 500-iteration UI cap used by standard escape-time configs.

Acceptance signal: focused shared Julia catalog test verifies Spring Julia's iteration parameter max is 500.
