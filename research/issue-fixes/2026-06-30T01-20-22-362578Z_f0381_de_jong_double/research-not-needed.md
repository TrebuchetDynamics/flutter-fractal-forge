# Research not needed

Local shader/detail issue for module `f0381_de_jong_double` (`Low Detail`).

Source/test evidence:
- The module uses `shaders/strange_attractors/peter_de_jong_gpu.frag` through `shared_de_jong_catalog.dart`.
- The shader's previous bounded-orbit color used only averaged orbit glow, which produced low spatial detail.
- Added an orbit-trap term to the bounded-orbit color and mirrored that recurrence in the CPU fallback for `f0381_de_jong_double`.
- Focused test renders the reported view with the native CPU recurrence and asserts visible color/luminance detail.
