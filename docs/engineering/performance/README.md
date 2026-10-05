# Performance engineering docs

These documents have separate evidence scopes. Their measurements apply only to the stated environment and method.

- [`PERFORMANCE.md`](PERFORMANCE.md) describes runtime frame metrics, shader loading, and available performance checks.
- [`SHADER_OPTIMIZATIONS.md`](SHADER_OPTIMIZATIONS.md) describes shader asset and uniform ownership, coloring coverage limits, and source checks. It does not claim a universal optimization result.
- [`LINUX_FRACTAL_AUDIT.md`](LINUX_FRACTAL_AUDIT.md) describes the Linux catalog audit and its retained reports. The recorded full sweeps used Mesa llvmpipe software rendering, not a hardware-GPU benchmark.
- [`apk_size_analysis.md`](apk_size_analysis.md) is a dated Android APK-size snapshot. Do not treat it as a current release measurement.

Renderer policy, environment setup, and validation incident reports remain owned by their respective project documents.
