# Research not needed

Issue: `issues/2026-06-27T01-14-51-683793Z_f1047_svensson_coral.json`

This is a local catalog coefficient correction:

- The issue reports `f1047_svensson_coral` does not look like the expected fractal and provides a concrete Svensson parameter set: `a=0.77`, `b=2.39`, `c=6.34`, `d=-6.36`.
- The catalog entry was using different coefficients for the same public identity.

Acceptance signal: focused shared Svensson catalog test verifies Svensson Coral now uses the issue-provided coefficients and the shared Svensson shader wiring remains valid.
