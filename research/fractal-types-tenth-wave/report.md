# Tenth-wave fractals and fractal-inspired visualizations

## Method and limits

This is a comprehensive synthesis-and-implementation pass over the repository's four preceding comprehensive ResearchForge waves, the world's-largest-catalog evidence package, the canonical alias ledger, and the 70,730-line source-backed reference registry. Those earlier packages searched OpenAlex, Crossref, arXiv, and Semantic Scholar with broad and gap passes; their overlapping totals range from 390–485 records per pass and 275–422 unique DOI-bearing records per pass. Counts are not summed because the packages overlap.

For this wave I wrote 24 additional query variants, checked every proposed identity against active Dart catalog IDs, shader names, and the pubspec manifest, and verified seven primary/authoritative URLs directly. Fresh `rforge` was unavailable in PATH and Search Hub's configured provider failed all four attempted batches, so no fresh scholarly API records were added. No PDFs or copyrighted full text were fetched. Exact failures and the reused evidence boundary are recorded in `coverage-stats.txt`, `source-inventory.md`, and `provenance.json`.

## Bottom line

Sixteen distinct systems passed the identity, GPU-feasibility, and duplicate gates. They add four complex-dynamics fields, five number-theory/modular fields, four nonlinear/physical dynamics views, and three self-affine/substitution constructions. This is deliberately not a wave of power aliases: every entry has a dedicated formula-bearing shader and a stable catalog ID.

Combined with waves eight and nine, the live public catalog reaches **1,000 production fractals** (535 declarative escape-time/field configs; 1,008 debug/test registry modules including seven diagnostics and one non-fractal scientific visualization).

## Selected implementation batch

### Complex dynamics and root-finding parameter spaces

1. **Cubic connectedness locus** — `f(z)=z³−3a²z+b`; both critical orbits `±a` are tested. This is a genuine cubic slice rather than another Multibrot power. Research anchor: Branner–Hubbard cubic connectedness work; implementation uses the standard critical-orbit criterion.
2. **Newton parameter plane** — each pixel is coefficient `c` in `f_c(z)=(z−1)(z²+z+c)`, while all pixels share an orbit seed. This complements existing Newton basins, where pixels are initial `z` values.
3. **Polylogarithm Julia field** — bounded iteration of a documented 12-term `Li_s(z)=Σzⁿ/nˢ` approximation. The title says “field” because finite truncation regularizes the analytic polylogarithm. Function anchor: [NIST DLMF §25.12](https://dlmf.nist.gov/25.12).
4. **q-exponential Julia field** — bounded iteration of `e_q(z)=Σzⁿ/[n]_q!` with an explicit finite series. It is presented as a q-deformed Julia field, not as a claim about a unique canonical set. Function anchor: [NIST DLMF Chapter 17](https://dlmf.nist.gov/17).

### Modular forms, arithmetic, and automatic sequences

5. **Klein j-invariant modular field** — finite `E₄³/Δ` q-series with magnitude, phase, and fundamental-domain views. Anchor: [NIST DLMF Chapter 23](https://dlmf.nist.gov/23).
6. **Jacobi theta field** — defining Fourier series for θ₂, θ₃, and θ₄ with zero/phase modes. Anchor: [NIST DLMF Chapter 20](https://dlmf.nist.gov/20).
7. **Eisenstein series field** — E₄/E₆ q-expansions using divisor sums σ₃ and σ₅. Evidence includes *Theta functions and Eisenstein series* (2014), [DOI 10.1007/s40590-014-0044-4](https://doi.org/10.1007/s40590-014-0044-4).
8. **Gaussian prime lattice** — exact bounded integer primality checks on Gaussian norms, with the separate axis congruence rule. This is distinct from the existing Pascal/Ulam visualizer.
9. **Thomae popcorn field** — finite reduced-rational scan of `f(p/q)=1/q`, with graph, stems, and denominator coloring. The denominator cap is visible in the iteration control rather than hidden.
10. **Substitution diffraction field** — finite Fourier intensity for Thue–Morse, Rudin–Shapiro, and Fibonacci/Sturmian weights. Sequence definitions are anchored by [MathWorld: Thue–Morse](https://mathworld.wolfram.com/Thue-MorseSequence.html) and [MathWorld: Rudin–Shapiro](https://mathworld.wolfram.com/Rudin-ShapiroSequence.html).

### Nonlinear dynamics and physical fractal structure

11. **Arnold tongues** — circle-map parameter plane, rotation-number plateaus, and low-denominator locking. Primary anchor: V. I. Arnold, *Small denominators I: mappings of the circumference into itself* (1961), as recorded in `docs/catalog/fractal_registry.yaml`.
12. **Kicked Harper resonance web** — torus map `p′=p+K sin q`, `q′=q−L sin p′`, with recurrence, winding, and finite-time stretching views. Anchor: Leboeuf et al. (1990), [DOI 10.1103/PhysRevLett.65.3076](https://doi.org/10.1103/PhysRevLett.65.3076).
13. **Hénon–Heiles escape basins** — leapfrog integration of `H=(pₓ²+pᵧ²+x²+y²)/2+x²y−y³/3` above `E=1/6`, colored by three exits. Original system: Hénon & Heiles (1964), [DOI 10.1086/109234](https://doi.org/10.1086/109234); basin implementation anchor: de Moura & Letelier (1999), [DOI 10.1016/S0375-9601(99)00209-1](https://doi.org/10.1016/S0375-9601(99)00209-1).
14. **Fractal Talbot carpet** — bounded Fresnel sum `U(X,Z)=Σa_m exp(i2π(mX−m²Z))` with intensity and phase modes. Anchor: Berry & Klein, *Integer, fractional and fractal Talbot effects* (1996), [DOI 10.1080/09500349608232876](https://doi.org/10.1080/09500349608232876).

### Self-affine and folding constructions

15. **Paperfolding curve atlas** — direct turn-sequence construction with regular, mirrored, and alternating fold variants. Anchor: Dekking, Mendes France & van der Poorten, *Paperfolding morphisms, planefilling curves, and fractal tiles* (2012), [DOI 10.1016/j.tcs.2011.09.025](https://doi.org/10.1016/j.tcs.2011.09.025).
16. **de Rham self-affine curve family** — binary-address affine functional equation with an exposed contraction weight. Anchor: G. de Rham, *Sur quelques courbes définies par des équations fonctionnelles* (1957), [Numdam](http://www.numdam.org/item/CM_1957__16__115_0/).

## Duplicate and quality gate

The selected IDs and concept-name patterns had no active matches in `lib/core/modules`, `shaders`, or `pubspec.yaml`. Adjacent entries were treated as non-equivalent only when the independent variable or formula changed: Newton basin versus Newton coefficient plane; Dedekind η versus j/θ/Eisenstein fields; Standard Map orbit versus Kicked Harper recurrence; Bessel scalar zeros versus other special-function dynamics.

Candidates deferred despite novelty: Airy/Bessel Newton basins (root approximation and classification need a numerical error test), Cahn–Hilliard (requires ping-pong state textures), Schramm–Loewner traces and double-pendulum FTLE (benchmark-gated), rotor-router aggregation (too expensive for the current single-fragment pattern), and formal Julia mating (high risk of misleading approximation).

## Evidence gaps

The weakest evidence is not mathematical identity but visual/numerical fidelity at high truncation order: polylogarithm and q-exponential fields are explicitly finite approximations; modular q-series lose fidelity near the real axis; automatic-sequence diffraction is finite-window; Talbot and paperfolding views are bounded sums. Shader compilation and catalog contracts can prove integration, but full visual QA still requires GPU render-audit/thumbnail runs on representative hardware.
