# Research not needed

Issue: `issues/2026-06-27T01-04-00-752962Z_f0508_log_cos_z_c.json`

This is a local catalog framing bug, not a domain/math uncertainty:

- The issue tags `f0508_log_cos_z_c` with bad initial coordinates and provides a better view (`x=-1.0138758420944214`, `y=-0.30382946133613586`, `zoom=0.2588516917544482`).
- `shared_escape_expression_catalog.dart` was using the same generic cosine-family default center/zoom for this formula.

Acceptance signal: focused shared escape-expression catalog test verifies the F0508 default view uses the issue-provided framing.
