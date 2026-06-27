# Research not needed

Issue: `issues/2026-06-27T01-15-07-590527Z_f1054_svensson_halo.json`

This is a local parameter-schema bug:

- The Svensson shared catalog intentionally builds these attractors with `bailout=24.0`.
- The shared coefficient-attractor builder used `CommonFractalParams.bailout(defaultValue: bailout)` without raising the parameter max, so the control/randomization schema still capped bailout at 8.0.
- The issue state shows `bailout=8.0`, which can cause premature escape and a wrong-looking Svensson attractor.

Acceptance signal: focused shared Svensson catalog test verifies Svensson Halo exposes bailout default/max 24.0.
