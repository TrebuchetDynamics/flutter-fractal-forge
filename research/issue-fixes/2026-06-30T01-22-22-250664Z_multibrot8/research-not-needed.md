# Multibrot⁸ initial view

No external research needed. This mirrors the adjacent Multibrot¹⁰ fix: high-degree Multibrot defaults at zoom 1 crop the boundary, so the default preset should use a wider centered view.

Validation:
- `/home/xel/flutter/bin/flutter test test/modules/multibrot8_initial_view_test.dart --reporter expanded`
- `/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/impellerc --sksl --input=shaders/escape_time_family/families/multibrot/multibrot8_gpu.frag --input-type=frag --sl=/tmp/multibrot8.sksl --spirv=/tmp/multibrot8.spv --include=/home/xel/flutter/bin/cache/artifacts/engine/linux-x64/shader_lib --verbose`
- `/home/xel/flutter/bin/flutter analyze`
