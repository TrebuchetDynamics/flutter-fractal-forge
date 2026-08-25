# Source inventory — MilkDrop/Carpathian recursive objects

## Public visual lead

| Source | Use | Licensing / retention boundary |
|---|---|---|
| [Reddit post: “The kind of raw, pure, majestic…”](https://www.reddit.com/r/Fractalish/comments/1vxdukc/the_kind_of_raw_pure_majestic_mathematically/) | Identified the user-requested reference and its public discussion. | Post and media ownership remain with their respective authors. No text beyond identifying metadata, screenshot, thumbnail, music, or frame is shipped. |
| [Public Reddit RSS](https://www.reddit.com/comments/1vxdukc/.rss) | Confirmed the post metadata, public `v.redd.it` media identifier, and the author’s statement that the clip came from MilkDrop3. | Read as public metadata only; the RSS response is not retained in the repository. |
| [Reddit-hosted video](https://v.redd.it/7q7jb4t4qdlh1) | Temporarily inspected a 59.55 s, 1280×684, 30 fps copy and nine evenly distributed frames to extract composition-level observations. | Temporary files remain outside the repository. No frame, audio, thumbnail, palette sample, texture, timing sequence, or media byte is imported. |

## Renderer and architectural references

| Source | Verified fact | Use boundary |
|---|---|---|
| [MilkDrop3 repository](https://github.com/milkdrop2077/MilkDrop3) | Public README identifies MilkDrop/projectM preset compatibility and an audio-visualizer pipeline. GitHub reports no root repository license. | Architecture/documentation reference only. No source, preset, shader, binary, image, sprite, or expression was imported or translated. |
| [MilkDrop3 site](https://milkdrop3.com) | Public product page describes personal/non-remunerated free use and a separate PRO offering. | Treated as a warning that the project is not safely characterized as uniformly open source. |
| [MilkDrop preset authoring guide](https://www.geisswerks.com/milkdrop/milkdrop_preset_authoring.html) | Documents frame equations, warp-mesh coordinate equations, feedback warping, and MilkDrop 2 warp/composite shaders. | Used only to distinguish generic scene grammar from MilkDrop’s texture-feedback implementation. |
| [projectM](https://github.com/projectM-visualizer/projectm) | Cross-platform MilkDrop-compatible implementation; core repository states LGPL-2.1 licensing with component-level nuances. | Comparative architecture reference only; no dependency or source import. |
| [MilkDrop/BeatDrop code license](https://github.com/milkdrop2077/MilkDrop3/blob/main/code/LICENSE.txt) | The code subtree carries BSD-style terms naming BeatDrop contributors, while other repository components have separate or absent terms. | Supports the conservative mixed/ambiguous licensing classification. |

## Mathematical and rendering leads

The ResearchForge search library is metadata-only. It is not a screened evidence review and no full text was acquired.

- Hutchinson-style finite iterated function systems and graph-directed attractors motivate the Cayley and Fibonacci constructions.
- The gyroid implicit field follows the standard triply periodic expression; a useful historical lead is Alan Schoen, *Infinite Periodic Minimal Surfaces Without Self-Intersections*, [NASA TN D-5541](https://ntrs.nasa.gov/citations/19700020472).
- Möbius geometry is implemented directly from the half-twist moving frame, not from an external shader.
- Chebyshev recurrence definitions follow the [NIST DLMF classical orthogonal-polynomial reference](https://dlmf.nist.gov/18.3).
- Conservative primary-ray stepping follows the general sphere-tracing idea; all concrete GLSL is original project code.

Metadata leads present in `results-deduped.jsonl` include:

- `10.3842/sigma.2015.084` — fast basins and branched fractal manifolds of IFS attractors.
- `10.1103/physrevlett.76.2726` — high-genus periodic gyroid surfaces.
- `10.1103/physrevb.71.073405` — geometry/electronic structure on a gyroid surface.
- `10.1016/j.geomphys.2011.01.011` — Hopf-fibration geometry (considered, not selected).

## Observed visual grammar transferred

Only these non-exclusive structural traits informed the implementation:

1. one isolated object against dominant near-black negative space;
2. slow orientation drift rather than a moving camera journey;
3. a readable large silhouette with denser recursive surface/interior structure;
4. analytic emissive rims and near-field halos;
5. high-contrast complementary generated color.

The particular objects in the clip, their presets, feedback history, audio response, palettes, textures, transitions, and timing were deliberately not reproduced.
