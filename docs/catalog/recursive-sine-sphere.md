# Recursive Sine-Warped Sphere

**Stable app ID:** `recursive_sine_sphere` (`core.recursive_sine_sphere` in catalog exports)
**Shader:** `shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_gpu.frag`
**Dimension:** 3D implicit level set; no escape-time power or bailout.

This finite fractal-inspired surface applies the cyclic domain map from Íñigo Quílez's [domain-warping explanation](https://iquilezles.org/articles/warp/) to a sphere. It does not claim infinite self-similarity or a fractal dimension.

For `C(x,y,z)=(y,z,x)`, start with `q₀=p`, then simultaneously compute

`qₙ₊₁ = qₙ + a·2⁻ⁿ·sin(2ⁿ·C(qₙ)+φ)` for `n=0,…,N−1`.

The rendered level set is `length(qN) − R = 0`. Parameter bounds are depth `N=0…6` (default 3), strength `a=0…1` (default 0.8), radius `R=0.25…2` (default 1), phase `φ` in radians (default 0), and ray budget 64…512 (default 256). Depth zero or strength zero gives the exact sphere. Optional animation is disabled by default; when enabled it adds a small deterministic time offset to phase.

The field is not a signed-distance function. Each warp Jacobian is `I + a·D·C`, where `D` is diagonal with cosine entries of magnitude at most 1 and the cyclic permutation `C` is orthogonal. Thus its norm is at most `1+|a|`, giving the composed field's conservative global Lipschitz bound `L=(1+|a|)^N`. Each level displaces a point by at most `√3|a|2⁻ⁿ`, so the surface lies inside `R+√3|a|Σ₂⁻ⁿ`. The marcher uses `0.8·|field|/L` steps inside this enclosure. Intersections require a small field residual or sign-bracket refinement. Finite-difference normals are normalized. Tangencies retain an explicit status; exhausted rays remain unresolved and are never promoted to hits. Float shader acceptance is 5e-4 world units; the independent double reference uses 2e-5. Rendering failure/non-convergence is not evidence of a valid surface.

The existing catalog/viewer [mathematics mapping](../../lib/core/modules/fractal_mathematics.dart) exposes this real implicit-surface formula using the current bounded parameters, including the opt-in `φ+0.0002·t` phase. Its [EN/ES summary](../../lib/shared/widgets/fractal_math_summary.dart) names the finite construction, conservative method and Quílez inspiration without claiming an infinite fractal or academic approval.

## Offline verification and limits

The [scalar reference tests](../../test/modules/recursive_sine_sphere_test.dart) cover simultaneous composition, sphere degeneracies, deterministic phase, finite normals, and observable controller normalization of invalid inputs. The [diagnostic runtime-effect tests](../../test/shaders/recursive_sine_sphere_kernel_test.dart) draw a four-pixel result from the same canonical [intersection kernel](../../shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_kernel.glsl) embedded in the production shader; there is no second test marcher or public debug parameter. Status distinguishes miss, hit, unresolved and tangent. Readback encodes distance in increments of 1e-5 and residual in increments of 1e-6; selected shader distances/residuals are checked within 5e-4.

For the two warped rays (`N=2`, `a=0.8`, `R=1`, `φ=0.4`, direction `(0,0,-1)`), independent double scalar recurrences scan 200,000 intervals from enclosure entry and bisect the first sign-changing interval 64 times. Origins `(0,0,4)` and `(0.3,-0.4,4)` retain nearest sampled crossings at approximately `4.0894271782` and `3.9893505716`. This finite sampling is fixture evidence, not a proof that all possible tangent or arbitrarily close crossings are detected. Analytic sphere cases separately check axial/interior/silhouette/tangent behavior; finite-enclosure miss and exhausted-budget cases are distinct. An initially zero-residual warped ray is classified before attempting a zero-length step, preserving the valid distance-zero boundary case.

## Portable shader maintenance

Flutter's Windows shader compiler cannot resolve the quoted local includes previously used for this kernel. Both fragment assets therefore contain generated inline blocks from the canonical `.glsl` file. Edit only that kernel, then run `python3 scripts/sync_sine_sphere_kernel.py`. The parity case in the diagnostic tests requires both inline blocks to match the canonical content exactly after normalizing LF/CRLF checkout line endings; `python3 scripts/sync_sine_sphere_kernel.py --check` checks the same synchronization without writing. Only the Flutter runtime-effect include remains. The existing Windows include guard checks the production asset, and the parity case checks both assets. These source and Linux compilation checks are not a Windows build or device qualification.

Source study: [recursive sine-sphere study](../../research/recursive-sine-sphere.md). Shader compilation and software runtime-effect tests do not establish hardware GPU parity, visual framing, performance, restoration or PNG export. Those require the separate [SINEWARP-002-47 qualification](../../tasks/items/SINEWARP-002-47.md); this metadata page does not certify them.
