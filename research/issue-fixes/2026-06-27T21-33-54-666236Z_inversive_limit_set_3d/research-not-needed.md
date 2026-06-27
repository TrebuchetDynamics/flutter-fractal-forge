# Inversive Limit Set 3D bad randomized/correctness result

External research not needed. This is local shader/config mismatch at the supplied params.

Local evidence:
- The module exposes up to 50 iterations and 200 ray steps through `Raymarched3DConfig`.
- `inversive_limit_set_3d_gpu.frag` internally capped inversion iterations at 30 and ray steps at 150.
- The reported params request `steps=200`; randomized settings could also request iterations above 30, but the shader silently ignored those values.
- Raised the shader loop caps to match the module's public controls.
