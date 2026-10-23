# Milnor — Brieskorn Orbit (Inspired)

Stable app identity: `milnor_brieskorn`. **Inspired art, not an exotic sphere.**

## Source and construction boundary

Durán, Püttmann and Rigas, *An infinite family of Gromoll–Meyer spheres*,
[arXiv:math/0610349v1, Introduction](https://arxiv.org/html/math/0610349v1),
describe the Brieskorn family with exponents `(6n−1,3,2,2,2)`. Its link in
`C⁵` satisfies **both** `w^(6n−1)+z₀³+z₁²+z₂²+z₃²=0` and
`|w|²+|z₀|²+|z₁|²+|z₂|²+|z₃|²=1`. See also Kwon and van Koert,
[*Brieskorn manifolds in contact topology*, §1](https://arxiv.org/pdf/1310.0343)
for the two defining constraints.

For `n=1`, substituting the **unnormalized** diagonal
`D(z)=(z,z,z,z,z)` in the defining polynomial gives exactly
`f(D(z))=z⁵+z³+3z²`. This is a restriction of the polynomial, **not** a
restriction/projection of the link. A normalized sphere diagonal would change
the coefficients. The app then makes its own artistic choice to iterate

```
z₀ = 0
zₖ₊₁ = zₖ⁵ + zₖ³ + 3zₖ² + c,   c ∈ C (the 2D pixel parameter plane).
```

This iteration is project-chosen inspired dynamics, not a claim of worldwide
mathematical novelty, a real slice of a seven-sphere, Milnor's original bundle
construction, or a detector of exotic smoothness. Milnor's original
[*On manifolds homeomorphic to the 7-sphere* (1956)](https://webhomes.maths.ed.ac.uk/~v1ranick/papers/exotic.pdf)
uses `S³` bundles over `S⁴`. The `28` oriented smooth structures in dimension
seven include **one standard structure and 27 exotic structures**; see the
`Θ₇ ≅ Z/28` discussion and Kervaire–Milnor (1963) reference in the first source.
No academic identity or paper approval is implied by app registration.

## Finite-orbit meaning and safeguards

The shader reports escape observed in at most `N` updates, otherwise **not
escaped within N**, never proven boundedness. Only the orbit of `0` is tested.
`P′(z)=z(5z³+3z+6)` has four critical points counted with multiplicity; testing
one is not the complete connectedness locus. In particular at `c=0`, `0` is
fixed while the nonzero real critical point near `−0.8767501890` escapes.

For `r ≥ R = max(2, 12^(1/3), (4|c|)^(1/5), user bailout)`,
`r³ ≤ r⁵/4`, `3r² ≤ r⁵/4`, and `|c| ≤ r⁵/4`. Therefore
`|P(z)+c| ≥ r⁵−r³−3r²−|c| ≥ r⁵/4 > r`.
This gives a forward escape certificate in exact arithmetic. The shader adds
a relative `1e-5` radius rounding margin, checks every update (including the
Nth) before any next powers, and never evaluates a huge escaped state again.
The UI bailout range is `2..8`, iterations `20..500` (static cap `500`);
malformed/out-of-range uniforms normalize to legal ranges. Shader tests also
exercise `N=0,1,2,3` to pin update semantics.

The standard ten float slots and all 64 procedural palette/relief modes are
retained. Scaled complex derivatives avoid long-orbit overflow in relief modes.
Transparent output removes the not-escaped-within-N region with zero premultiplied
RGBA; opaque output colors it for appearance, not as a boundedness certificate.
Zoom is normalized to `1e-9..1e12`; single-precision coordinates cannot resolve
all such zooms. CPU viewing/precision is unsupported and synthetic CPU dispatch
is refused with an EN/ES viewer notice.

## Verification boundary

`test/helpers/milnor_brieskorn_oracle.dart` uses independent binomial expansion,
not the shader multiplication chain. Module/render tests cover exact orbit
fixtures, escape inequalities, actual `FragmentProgram` drawing/readback,
near-boundary margin samples, palette and preset roundtrips, transparency,
extreme inputs and localized limitations. The overview and close-up framings
were adjusted after actual 960×720 shader previews, not invented images.

Host fragment image readback is native raster evidence, **not hardware GPU
qualification**. Shader compiler success, browser execution, hardware GPU,
installed-device behavior and full export journeys remain separate evidence.
