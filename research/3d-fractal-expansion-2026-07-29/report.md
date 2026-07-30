# Research report: distinct 3D fractal expansion

## Method and limits

A comprehensive metadata sweep used ResearchForge v0.1.19 with 20 query variants across OpenAlex, Crossref, and arXiv. It retrieved 545 records (421 deduplicated; 336 unique DOIs), with non-zero coverage from all three sources. Citation expansion was attempted for a 3D Vicsek paper, a Sierpinski/layered-IFS paper, and a Mandelbulb paper. No full text was acquired and no third-party shader code was copied.

The selection gate was the repository's Counted Catalog Identity rule: a candidate must be a distinct formula or transform system, not a fixed power, constant, camera, or palette preset.

## Bottom line

Five implementation-ready identities pass the gate: configurable Juliabulb 3D, center-cross Vicsek 3D, mixed-scale Jerusalem Cube 3D, Sierpinski Octahedron 3D, and promotion of the existing Pseudo-Kleinian identity to a true 3D ray-marched renderer. Together they add four new stable IDs and correct one misclassified renderer without reviving parameter spam.

## Evidence and implementation implications

### Juliabulb 3D

Oliver Knill's 2023 preprint describes White-Nylander Mandelbulbs as traces of a polar power construction and states the general map `z^d+c` in a vector space with polar decomposition ([arXiv:2305.17848](https://arxiv.org/abs/2305.17848)). The 2023 *Fractals* paper *On the Algebraic Foundation of the Mandelbulb* also grounds the spherical power map ([DOI 10.1142/S0218348X23500627](https://doi.org/10.1142/S0218348X23500627)).

Implementation decision: one `juliabulb_3d` module starts the orbit at the sampled 3D point and adds configurable `c=(cx,cy,cz)` after each polar power. Built-in constants are presets only.

### Vicsek 3D

The 3D analogue retains seven of 27 subcubes: the center and the six face-adjacent cubes, giving similarity ratio `1/3` and dimension `log(7)/log(3)` ([Vicsek fractal construction](https://en.wikipedia.org/wiki/Vicsek_fractal)). A 2021 *Fractals* paper explicitly studies self-similar networks modeled on the three-dimensional Vicsek fractal ([DOI 10.1142/S0218348X21500948](https://doi.org/10.1142/S0218348X21500948)).

Implementation decision: `vicsek_3d` uses the exact seven-map center-cross IFS and remains distinct from the existing 2D `vicsek_fractal`.

### Jerusalem Cube 3D

The Jerusalem cube recursively keeps eight corner cubes at ratio `r=sqrt(2)-1` and twelve edge-centered cubes at ratio `r^2`; its dimension satisfies `8*r^d + 12*r^(2d) = 1` ([construction and references](https://en.wikipedia.org/wiki/Menger_sponge#Jerusalem_cube)). The repository already carries an unvalidated 3D source lead and a separate module explicitly labeled as a 2D cross-section.

Implementation decision: `jerusalem_cube_3d` is a new mixed-scale 20-map IFS. It does not replace the 2D cross-section.

### Sierpinski Octahedron 3D

The repository's existing-app ledger names an unvalidated `f0595_sierpinski_octahedron_3d` source lead. Tsuiki's layered-IFS work confirms the use of finite similarity systems for related 3D polyhedral fractal objects ([arXiv:2205.13065](https://arxiv.org/abs/2205.13065); [DOI 10.4171/JFG/163](https://doi.org/10.4171/JFG/163)).

Implementation decision: `sierpinski_octahedron_3d` uses six half-scale maps toward the regular octahedron's coordinate-axis vertices, with dimension `log(6)/log(2)`. This is a distinct six-map transform system from the existing four-map Sierpinski tetrahedron. Historical-priority claims are intentionally avoided because retrieved metadata did not state this exact map set.

### Pseudo-Kleinian

The public Pseudo-Kleinian description identifies Knighty's community distance estimator as a box fold followed by spherical inversion with accumulated scale ([implementation description](https://github.com/makarov-mm/pseudo-kleinian)). It must not be presented as a genuine Kleinian-group limit set. The app already has a local Pseudo-Kleinian shader and identity, but currently drives it through the 2D escape-time layout.

Implementation decision: preserve the `pseudo_kleinian` ID and rewrite/promote its local recurrence to the standard 3D camera/uniform contract. No external source code is copied.

## Claim hygiene

- The candidates are described as deterministic 3D formula/IFS identities, not as historically original implementations.
- Pseudo-Kleinian is explicitly distinguished from mathematical Kleinian-group limit sets.
- Fixed Juliabulb powers and constants are controls/presets, never separate catalog identities.
- Image-health tests can establish visible, non-blank GPU output but not mathematical exactness; construction contracts and parameter invariants provide the available non-visual checks.

## Evidence gaps

See `evidence-gaps.json`. The weakest provenance is the exact six-map octahedral naming lineage; the implementation is mathematically explicit and locally tested but should not receive historical attribution. Semantic Scholar was omitted because no API key was configured. No copyrighted full text was downloaded.

## Next steps

Implement the five candidates with fresh local GLSL, add source-contract tests, register new shaders, run strict focused GPU audits, then rerun the complete 3D identity audit and update catalog counts/evidence.
