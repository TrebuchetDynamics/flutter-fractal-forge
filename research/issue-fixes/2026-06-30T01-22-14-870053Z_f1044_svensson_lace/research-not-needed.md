# Svensson Lace low detail

No external research needed. The existing shader already used the Svensson map; the problem was presentation detail. The fix keeps the map and adds deterministic orbit/thread traps plus a native CPU implementation for the reported coefficients so the regression test can measure detail at the reported view.

Validation:
- `/home/xel/flutter/bin/flutter test test/modules/svensson_lace_detail_test.dart --reporter expanded`
- `/home/xel/flutter/bin/flutter test test/features/catalog/shared_svensson_catalog_test.dart --reporter expanded`
- `/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/impellerc --sksl --input=shaders/strange_attractors/svensson_gpu.frag --input-type=frag --sl=/tmp/svensson.sksl --spirv=/tmp/svensson.spv --include=/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/shader_lib --verbose`
- `/home/xel/flutter/bin/flutter analyze`
