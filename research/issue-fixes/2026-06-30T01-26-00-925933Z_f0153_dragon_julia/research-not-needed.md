# Dragon Julia low-detail/deep-zoom issue

External research was not needed. The issue targets the shared Julia shader path where bounded regions rendered as flat black unless a trap-specific color scheme was selected.

Fix evidence:

- `shaders/escape_time_family/core/julia_gpu.frag` now tracks point/cross traps for all Julia color schemes.
- Bounded regions render with trap-based detail instead of a black fill, improving Dragon Julia at the issue view and deep-zoom interiors.
- `test/modules/julia_bounded_detail_test.dart` locks the bounded-region detail behavior.

Validation:

```sh
find shaders -type d -exec mkdir -p build/unit_test_assets/{} \;
/home/xel/flutter/bin/flutter test --reporter expanded test/modules/julia_bounded_detail_test.dart
git diff --check
```

Result: pass.
