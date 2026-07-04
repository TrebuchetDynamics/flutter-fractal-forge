# Fibonacci Spiral visual correctness

No external research needed. The existing shader used a finite set of golden-angle seed traps, which disappears near the reported origin zoom. The fix uses the standard golden logarithmic spiral relation: each quarter turn scales radius by φ.

Validation:
- `/home/xel/flutter/bin/flutter test test/modules/fibonacci_spiral_visual_contract_test.dart --reporter expanded`
- `/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/impellerc --sksl --input=shaders/ifs_and_geometric/fibonacci_spiral_gpu.frag --input-type=frag --sl=/tmp/fibonacci_spiral.sksl --spirv=/tmp/fibonacci_spiral.spv --include=/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/shader_lib --verbose`
- `/home/xel/flutter/bin/flutter analyze`
