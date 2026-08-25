# Deforum-style fractalish motion: procedural translation report

## Scope

This comprehensive metadata search began with a user-supplied Reddit post titled **“Deforum, SDXL, spiders and such.”** Its visible prompt schedule changes the named subject every 1000 frames while preserving a common colorful-fractal style. The goal here is not to reproduce those generated images. It is to identify reusable structural ideas and translate them into original, offline, deterministic runtime-effect GLSL suitable for Fractal Forge.

## Retrieval

ResearchForge v0.1.20 queried 24 variants across OpenAlex, arXiv, and Semantic Scholar. OpenAlex and arXiv returned 767 metadata records (627 after deduplication) with 367 unique DOIs. Semantic Scholar rate-limited every query with HTTP 429; this is retained as an explicit coverage gap. No full text was acquired, no screening decision was self-approved, and no evidence extraction was accepted.

The retrieval is deliberately broad because the source aesthetic combines several domains: keyframed diffusion animation, temporal coherence, radial web geometry, recursive ornament, signed-distance motifs, and procedural sea/aurora synthesis.

## Design lessons

### 1. Keep a stable visual grammar while changing subjects

The source schedule retains one stylistic phrase and changes the semantic noun at long keyframe intervals. Deforum’s public repository documents animation settings, prompt schedules, and mathematical keyframing. Fractal Forge can reproduce the *interaction principle* without a model: keep coordinates, palette grammar, orbit texture, and motion phase stable while smoothly interpolating between four independently procedural motif fields.

Implementation translation: `fourfold_motif_metamorphosis` uses a four-stage loop and Hermite interpolation. There are no prompts or random frame resets, so motion is deterministic and replayable.

### 2. Temporal continuity comes from deterministic state

Video-diffusion and optical-flow metadata leads consistently foreground temporal coherence. The implementation therefore avoids per-frame random seeds. Value noise uses a fixed hash, and every animated quantity is a continuous function of `uTime`, user parameters, and coordinates.

Implementation translation: all five entries use time-driven capability metadata, but reduced-motion/frozen rendering can still hold `uTime` fixed through the existing renderer policy.

### 3. “Fractal spider” can be expressed as topology, not copied imagery

The spider-web lead suggests a radial load-bearing network. The procedural translation uses dihedral folding, spokes, logarithmic rings, analytic paired ellipses, jointed leg curves, and an orbit-trap texture. It evokes an arachnid lattice without tracing a frame or depicting a source-specific spider.

Implementation translation: `chromatic_arachnid_lattice` defaults to eightfold symmetry and exposes symmetry, recursive detail, warp, motion, phase, and palette shift.

### 4. Fantasy and tarot motifs can be geometric rather than illustrative

The “wizard” and “tarot card” prompt nouns are not copied. Their reusable visual grammar is nested framing, luminous radial glyphs, stars, rings, and repeated symbolic centers.

Implementation translation: `astral_sigil_loom` uses concentric/star-chord fields; `recursive_arcana_frames` uses repeated signed-distance card frames and rosettes. Neither contains lettering, known tarot art, a named symbol, or a third-party texture.

### 5. Stormy sea and aurora share multiscale wave structure

The retrieved GPU/Gerstner-wave metadata supports using bounded harmonic layers for water. Aurora curtains are synthesized from domain-warped smooth bands rather than an image lookup.

Implementation translation: `tempest_aurora_tides` combines four aurora ribbons, fixed-seed fBm, layered sea harmonics, a horizon mask, and a rare analytic lightning branch.

## Production additions

One sampler-free shader supports five catalog modules:

1. `chromatic_arachnid_lattice`
2. `astral_sigil_loom`
3. `recursive_arcana_frames`
4. `tempest_aurora_tides`
5. `fourfold_motif_metamorphosis`

All pixels are produced by original code using analytic geometry, bounded fixed loops, complex orbit texture, fixed-seed value noise, and palette functions. The shader does not call a model, access a network, load media, or sample a texture.

These are five catalog identities rather than five presets: each entry locks its motif selector to a different field equation (arachnid lattice, sigil, recursive frame, aurora/sea, or the authored four-field morph), while retaining independently curated defaults and a stable ID. They share one compiled shader asset to avoid duplicating common math, as other Fractal Forge shader families do; changing presets, palettes, or camera state does not create additional counted identities.

## Licensing boundary

- Reddit video/frames, prompt strings, model outputs, and the named LoRA: rights unknown; not used as assets or copied into production.
- Deforum repository: AGPL-3.0; observed only at the architecture/documentation level. No source was copied or integrated.
- Scholarly records: metadata only; no copyrighted full text acquired.
- Production GLSL/Dart/tests: original implementation created within this repository.

## Evidence limits

The search was noisy and academic coverage for the exact artistic combination is weak. Semantic Scholar was unavailable due rate limiting. The report therefore makes no scientific claim that one procedural formula is the canonical model of spider webs, aurora, tarot imagery, or Deforum. The strongest evidence is implementation-level: explicit provenance, sampler-free source, deterministic tests, runtime shader compilation, and numeric pixel-structure checks.

## Sources

- [Deforum Stable Diffusion WebUI extension](https://github.com/deforum/sd-webui-deforum)
- *Video Diffusion Models: A Survey*, DOI `10.48550/arxiv.2405.03150`
- *LAVIE: High-Quality Video Generation with Cascaded Latent Diffusion Models*, DOI `10.48550/arxiv.2309.15103`
- *Estimating optical flow: A comprehensive review of the state of the art*, DOI `10.1016/j.cviu.2024.104160`
- *Diffusion as Shader*, DOI `10.1145/3721238.3730607`
- *Spider webs inspiring soft robotics*, DOI `10.1098/rsif.2020.0569`
- *Fast Simulation Method for Ocean Wave Base on Ocean Wave Spectrum and Improved Gerstner Model with GPU*, DOI `10.1088/1742-6596/787/1/012027`
