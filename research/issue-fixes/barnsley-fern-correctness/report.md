# Barnsley Fern correctness research

## Method and limits

Searched OpenAlex, Crossref, Semantic Scholar, and arXiv with three query variants focused on Barnsley fern IFS coefficients, affine transformations, probabilities, and chaos-game rendering. Semantic Scholar returned HTTP 429 for all three queries; other sources returned records. No full text was downloaded.

## Bottom line

The Barnsley fern is an iterated function system (IFS) / chaos-game attractor: render by repeatedly applying affine maps with fixed probabilities, then plotting distance to generated points. A screen-space inverse-IFS hit test is a poor fit for the expected classic fern silhouette.

## Evidence

- Barnsley/Demko, **"Construction of fractal objects with iterated function systems"**, SIGGRAPH/ACM record, DOI `10.1145/325334.325245`, is the foundational IFS construction result found by OpenAlex.
- Crossref/arXiv searches returned chaos-game and Hutchinson-Barnsley IFS literature, including **"The Chaos Game on a General Iterated Function System from a Topological Point of View"**, DOI `10.1142/s0218127414501399`, and **"On the localization of Hutchinson–Barnsley fractals"**, DOI `10.1016/j.chaos.2023.113674`.
- The focused local shader test checks that the live renderer uses the classic forward affine IFS thresholds `0.01`, `0.86`, `0.93` and the main leaflet transform `0.85x + 0.04y, -0.04x + 0.85y + 1.6`, and no longer contains the inverse-IFS branch comments.

## Project implication

Keep the minimal shader fix already present: deterministic forward IFS samples plus point-distance ink. It matches the expected Barnsley fern construction without adding CPU renderers, lookup textures, or new dependencies.
