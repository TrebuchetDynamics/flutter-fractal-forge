# Research not needed

Local deep-zoom rendering bug for `pola_sierpinski`.

Source/test evidence:
- Issue notes say CPU fallback failed and GPU appeared black at zoom `11050652.12473724` near the origin.
- Shader clamped `r` to `1e-6` before `log(r)`, so all coordinates below that radius collapsed to the same value at the reported deep zoom.
- Lowered the shader/CPU log-radius floor and added a CPU formula matching the shader path.
- Focused test renders the reported deep-zoom view and asserts non-black, varied pixels.
