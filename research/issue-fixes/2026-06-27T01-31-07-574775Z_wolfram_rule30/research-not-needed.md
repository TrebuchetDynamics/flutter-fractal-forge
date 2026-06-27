# Research not needed

Issue: `issues/2026-06-27T01-31-07-574775Z_wolfram_rule30.json`

This is a local shader framing/detail bug:

- The issue reports low detail for Wolfram Rule 30 at `y=-1.725...` and zoom `0.488...`.
- `wolfram_rule30_gpu.frag` converted vertical world position to generation with `(p.y + 0.5) * target` and then clamped out-of-range values. The reported view therefore collapses to generation 0 over most/all of the viewport.
- Wrapping the vertical coordinate before mapping to a generation keeps panned views inside the visible CA band instead of producing a flat clamped row.

Acceptance signal: focused shader source test verifies the generation mapping uses wrapped vertical coordinates.
