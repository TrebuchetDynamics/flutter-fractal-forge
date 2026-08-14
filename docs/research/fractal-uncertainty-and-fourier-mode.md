# Fractal Fourier and Uncertainty Mode

## Scope

Fractal Forge's Fourier mode is a finite numerical and creative laboratory. It
has three distinct layers:

1. **Fourier View** computes a two-dimensional discrete Fourier transform of a
   sampled, finite-resolution image of the current viewport.
2. **Fourier Music** maps measured spatial-spectrum features into artistic
   orchestration controls.
3. **Fractal Uncertainty Lab** estimates a restricted unitary Fourier operator
   norm for exact finite self-similar masks.

None of these layers proves a continuous fractal uncertainty principle.

## Continuous theorem being illustrated

Using Alex Cohen's Fourier convention,

\[
\widehat f(\xi)=\int_{\mathbb R^d}f(x)e^{-2\pi i x\cdot\xi}\,dx,
\]

Theorem 1.1 of *Fractal uncertainty in higher dimensions* assumes that the
physical set `X` is quantitatively porous on balls over the relevant scales and
the frequency set `Y` is quantitatively porous on lines over its relevant
scales. Under those assumptions, a function whose Fourier transform is
supported in `Y` cannot retain all of its energy in `X`; its `L²` concentration
has a power-saving upper bound.

The hypotheses are asymmetric. Line porosity is stronger than ordinary ball
porosity in dimensions greater than one. A line can be ball-porous while failing
line porosity, and orthogonal physical/frequency lines are an explicit
obstruction. A product of middle-thirds Cantor sets supplies the contrasting
line-porous model. Therefore the app must not claim that every sparse-looking or
fractal-looking image satisfies the theorem.

## Finite experiment

For an `N×N` periodic grid, the lab uses the unitary two-dimensional transform

\[
(\mathcal F_Nu)(k)=N^{-1}\sum_x u(x)e^{-2\pi i x\cdot k/N}.
\]

For finite masks `X` and `Y`, define

\[
T=P_Y\mathcal F_NP_X,\qquad \sigma=\lVert T\rVert_{2\to2}.
\]

The estimated maximum retained Fourier energy is `σ²`; the corresponding
estimated minimum leakage over signals supported in `X` is `1-σ²`. The finite
cardinality bound is

\[
\sigma\leq\min\left(1,\sqrt{\frac{|X||Y|}{N^2}}\right).
\]

A single finite value below one is not a proved FUP exponent. The lab may fit an
empirical slope across several recursion depths, but it must label the result as
a finite estimate and show convergence diagnostics.

The exact finite inequality for an approximately localized state is

\[
\sqrt{1-\varepsilon_\xi}
\leq \sigma\sqrt{1-\varepsilon_x}+\sqrt{\varepsilon_x}.
\]

This is preferable to pretending a thresholded raster has exact mathematical
support.

## General rendered-image transform

The current-view transform depends on viewport crop, palette, alpha,
resolution, and preprocessing. The default pipeline is:

- renderer-only RGBA readback, excluding viewer chrome and the spectrum itself;
- alpha-aware linear-light luminance;
- aspect-preserving area downsampling;
- optional mean/DC removal;
- separable Hann window to reduce artificial boundary discontinuities;
- unitary row and column transforms;
- raw magnitude-squared power for measurements;
- centered logarithmic magnitude only for display.

Because Flutter's live GPU `RenderRepaintBoundary.toImage` path can return an
alpha-covered black frame for composed shaders, GPU analysis replays the visible
renderer's emitted **effective base-field snapshot**. That snapshot is taken
after effective-module/precision routing, runtime iteration policy, palette
interpolation, animation time, glow, and kaleidoscope state. Widget-level fluid
warp, morph, celebration, and interface overlays are deliberately excluded and
the app labels this limitation. CPU analysis continues to use the renderer's
scene-only capture boundary. No synthetic replacement is used for blank input.

The Hann window belongs only to general image analysis. Exact Cantor masks in
the scientific lab are never windowed, recolored, or resampled.

Spectrum axes are spatial cycles per viewport, not acoustic frequencies in
Hertz. Magnitude orientation is an axis modulo `π`, not a signed left/right
arrow. Image edges are perpendicular to the corresponding Fourier-energy
direction.

## Fourier Music claims

The transform is a stable feature extractor, not an oscillator bank. Measured
features may include radial power distribution, centroid, rolloff, entropy,
flatness, anisotropy, axial orientation, and temporal spectral flux. Mapping
those quantities to bass articulation, drum density, harmony, melody register,
texture, or stereo placement is an artistic design choice.

The app may say:

> Music composed from measured spatial-spectrum features, rendered colors, and
> the camera journey.

It must not say that Cohen's theorem predicts a chord, instrument, timbre, or
emotion. It must not equate image-space FFT bins with audible Hertz.

## Required in-app disclaimer

> Finite numerical experiment—not a mathematical proof.

Sampled direction/scale searches must be called a **sampled line-porosity
diagnostic**, never certified line porosity.

## Sources

1. Alex Cohen, *Fractal uncertainty in higher dimensions*, Theorem 1.1 and
   Sections 1.1–1.3, arXiv:2305.05022:
   https://arxiv.org/abs/2305.05022
2. Alex Cohen, *Fractal uncertainty for discrete 2D Cantor sets*, Theorem 2,
   arXiv:2206.14131: https://arxiv.org/abs/2206.14131
3. Semyon Dyatlov, *An introduction to fractal uncertainty principle*,
   Sections 2.3 and 4, arXiv:1903.02599:
   https://arxiv.org/abs/1903.02599
4. Jean Bourgain and Semyon Dyatlov, *Spectral gaps without the pressure
   condition*, arXiv:1612.09040: https://arxiv.org/abs/1612.09040
5. Quanta Magazine, *Graduate Student Proves a Quantum Uncertainty Principle for
   Fractals*:
   https://www.quantamagazine.org/graduate-student-proves-the-fractal-uncertainty-principle-20260812/
