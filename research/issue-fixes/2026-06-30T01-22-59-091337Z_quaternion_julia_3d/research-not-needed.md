# Quaternion Julia 3D rotation issue

External research was not needed. The issue reports that the local `quaternion_julia_3d` renderer does not follow 3D rotation input.

Fix evidence:

- `shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag` now rotates the camera ray basis directly with `uRotation`, so roll/pitch/yaw all affect the rendered view.
- The previous world-up cross-product camera basis discarded roll and could make rotation controls feel disconnected.
- `test/modules/quaternion_julia_3d_rotation_test.dart` locks the shader to the direct rotated ray basis.

Validation:

```sh
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/quaternion_julia_3d_rotation_test.dart
/home/xel/flutter/bin/flutter test --reporter expanded test/shader_3d_diagnostic_test.dart --plain-name 'loads shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag'
git diff --check
```

Result: pass.
