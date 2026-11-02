# Landscape list — unresolved names

The owner supplied a landscape list of open-source fractal software on 2026-11-01.
Resolved entries were added to `scripts/clone-all.sh` after `git ls-remote`
accepted them. This file records the names that could **not** be resolved to a
specific repository, so nobody re-guesses them and clones the wrong project.

Resolution rule used: accept a URL only when `git ls-remote --heads` succeeds,
or when the GitHub search API returns a repository whose name matches the
candidate and whose name/description mentions fractal, Mandelbrot, Julia, chaos,
IFS, flame, terrain or Buddhabrot.

## No confident match

| Name from the list | Why it is unresolved |
| --- | --- |
| Oxidizer | macOS recursive flame renderer. Several forks exist, none named Oxidizer on GitHub. |
| xirho | Go IFS plotter. `bezo97/xirho` failed `ls-remote`; no name match found. |
| Mandelbulber (original) | The pre-2.0 code lives inside the `mandelbulber2` history; no separate upstream repository. |
| web-fractals (Godot) | Guess failed; no name match. |
| CrystalPalace | WebXR stereo shader; no name match. |
| recursive-fractal-engine | WebGL2 dynamical-systems renderer; no name match. |
| MilkDrop preset converter | projectM ships several tools; none matched the name. projectM itself is cloned. |
| openPlaG | Function plotter; no name match. |
| FuzzyGraph | Equation/fractal art tool; no name match. |
| rflsgen | R package, distributed via CRAN; no GitHub name match. |
| another_fractal_generator | Quaternion/octonion generator; guesses failed. |
| Fyre | Chaotic-map art tool; guesses failed. |
| gruff | Haskell GUI explorer; no name match. |
| fernery | Haskell IFS CLI. `tonyday567/fernery` failed `ls-remote`. |
| FractGen | Only a JavaScript port was found (`bylexus/JS-fractgen`), not the Qt/KDE original. Not cloned to avoid a false match. |
| Terrain generator (Rust) | Generic name; many candidates, none authoritative. |

## Blocked by rate limit at the time of resolution

| Name | Reason |
| --- | --- |
| sterling | GitHub search API returned HTTP 403 (rate limit). |
| fractals-py-cuda | Same. |
| mraster | Same. |

Retry these with one search call each; the limit resets within a minute.

## Not a repository

| Name | Reason |
| --- | --- |
| Mandelbulb 3D (MB3D) | Closed-source freeware. No upstream repository exists to clone; the list described it as open source. |
| Shadertoy / GLSL | Hosted platform, not a source repository. |
| Various P5.js sketches | Individual sketches, not a project. p5.js itself is cloned as an optional-large toolkit. |
| Fractal Explorer (various) | Resolved to the two named projects (`lobis/fractal-explorer`, `williamfiset/FractalExplorer`). |

## Next action

Add a URL for any row above to the `REPOS` array in `scripts/clone-all.sh`, then
run `scripts/clone-all.sh --verify` followed by `scripts/clone-all.sh --category <name>`.
