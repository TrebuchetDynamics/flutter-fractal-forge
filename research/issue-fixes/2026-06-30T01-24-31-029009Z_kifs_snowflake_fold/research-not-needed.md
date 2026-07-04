# KIFS Snowflake Fold no-image issue

External research was not needed. The issue targets the local KIFS Snowflake shader at the default 3D view.

Fix evidence:

- `shaders/ifs_and_geometric/raymarched_3d/kifs_snowflake_fold_gpu.frag` now uses the full default step budget instead of cutting default zoom to half steps.
- Missed raymarches return closest-distance data and render a soft closest-surface glow instead of a plain background.
- `test/modules/kifs_snowflake_visibility_test.dart` locks the visibility fallback and compiles the shader.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/kifs_snowflake_visibility_test.dart
git diff --check
```

Result: pass.
