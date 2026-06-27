# Research not needed

Issue: `issues/2026-06-27T01-04-18-881164Z_magnet1.json`

This is a local catalog default bug, not a domain uncertainty:

- The issue tags `magnet1` with bad initial params and provides a usable state: iterations 158, bailout 8, center `(0.7072526812553406, -0.21410192549228668)`, zoom `0.2039256117342137`.
- The catalog entry used generic defaults (`iterations=150`, center `(0,0)`, zoom `1`) for this exact public identity.

Acceptance signal: a focused catalog test verifies the `magnet1` default preset uses the reported params and framing.
