# Open-source reference repositories

Upstream fractal and reference projects, cloned shallow (`--depth 1`) by
`../scripts/clone-all.sh`. Every clone is ignored by git; only this README and
the files under `../docs/` and `../scripts/` are tracked.

Clones are **reference inputs, not app source**. Before an idea from any clone
touches production code, add the provenance record required by
`../docs/reference-corpus-workflow.md` (repo URL, source path, commit SHA,
license, idea summary, target file, validation signal). Direct code reuse needs
a license-compatibility note first.

## Layout

| Directory | Purpose |
| --- | --- |
| `desktop-classics/` | 2D explorers and classic generators: XaoS, Gnofract 4D, Fractint, FractalNow, Fraqtive, Iterated Dynamics, NextFractal, Fractalshades, Fractionarium/FragM, Fractorium |
| `formula-catalogs/` | Formula, shader and variation corpora: Mandelbulber2, glChAoS.P, JWildfire, shader-fractals, fract4d formulas |
| `renderers/` | Complete renderers and engines: `interactive-cpp/` (giulia, FractaVista, DoomsDay), `rust-wgpu/` (Fractl, par-fractal, cuda-mandelbox) |
| `deep-zoom/` | Perturbation and series-approximation tools: KF2, FractalShark, DeepDrill, rust-fractal-core, nanobrot, rsfrac |
| `flames-ifs/` | Fractal flames and IFS: flam3, Apophysis 7X, qosmic, Fractorium, fr0st, JWildfireSwan, barnsley, FLAM3 for Houdini |
| `browser-webgpu/` | Web renderers and WebGPU/WebGL explorers: FractalLab, Fractr, fractos, react-fractal-renderer, fractal-garden |
| `cli-small/` | Small command-line generators in Go, Rust and Haskell used for algorithm cross-checks |
| `specialized/` | Focused tools: Newton fractals, Lyapunov, Buddhabrot, xmountains, Cinefractal, projectM, wxChaos, MathMod |
| `mobile/` | Android/iOS renderers: `Puzzaks/fractals` (Dart), mandelbrot generators |
| `apple-metal/` | Metal and RealityKit shader references |
| `research-toolkits/` | Large creative-coding frameworks cloned only with `--with-large` (Processing, p5.js, openFrameworks, Cinder, nannou, Psychtoolbox) |

## Commands

```sh
../scripts/clone-all.sh --list-categories     # categories above
../scripts/clone-all.sh --verify              # check every remote is reachable
../scripts/clone-all.sh                       # clone the default set (shallow)
../scripts/clone-all.sh --with-large          # include the large framework clones
../scripts/clone-all.sh --category flames-ifs --update
```

Names from the owner's landscape list that could not be resolved to a repository
are recorded in `../docs/landscape-unresolved.md` with the reason.
