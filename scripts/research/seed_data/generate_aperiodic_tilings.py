"""Aperiodic tilings and substitution tilings (Family 1).

Sources:
  - Penrose 1974 "The Role of Aesthetics in Pure and Applied Mathematical Research".
  - Ammann, Grünbaum, Shephard "Aperiodic tiles" (1992).
  - Socolar & Taylor "An aperiodic hexagonal tile" (2011).
  - Smith, Myers, Kaplan, Goodman-Strauss "An aperiodic monotile" (arXiv:2303.10798, 2023).
  - Paul Bourke's tilings catalog.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "aperiodic_tilings"
FAMILY = "tiling"

_PARAMS = {
    "depth": {"default": 5, "range": [1, 10]},
    "iterations": {"default": 6, "range": [1, 12]},
}
_PRESETS = [{"id": "classic", "name": "Classic view", "params": {}}]


def _e(name: str, update: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None) -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "tiling",
        "update": update,
        "init": "seed_tile(unit)",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


_PB = "http://paulbourke.net/geometry/tilings/"
_PENROSE_WIKI = "https://en.wikipedia.org/wiki/Penrose_tiling"
_AMMANN_WIKI = "https://en.wikipedia.org/wiki/Ammann%E2%80%93Beenker_tiling"
_HAT_ARXIV = "https://arxiv.org/abs/2303.10798"
_SPECTRE_ARXIV = "https://arxiv.org/abs/2305.17743"

_REFS_PENROSE = [
    {"author": "R. Penrose",
     "title": "The Role of Aesthetics in Pure and Applied Mathematical Research",
     "year": 1974, "url": _PENROSE_WIKI},
]
_REFS_AMMANN = [
    {"author": "R. Ammann, B. Grünbaum, G. C. Shephard",
     "title": "Aperiodic tiles", "year": 1992, "url": _AMMANN_WIKI},
]
_REFS_HAT = [
    {"author": "D. Smith, J. S. Myers, C. S. Kaplan, C. Goodman-Strauss",
     "title": "An aperiodic monotile", "year": 2023, "url": _HAT_ARXIV},
]
_REFS_SPECTRE = [
    {"author": "D. Smith, J. S. Myers, C. S. Kaplan, C. Goodman-Strauss",
     "title": "A chiral aperiodic monotile", "year": 2023, "url": _SPECTRE_ARXIV},
]
_REFS_BOURKE = [
    {"author": "Paul Bourke", "title": "Tiling and rep-tiles",
     "year": 2001, "url": _PB},
]
_REFS_SOCOLAR = [
    {"author": "J. E. S. Socolar, J. M. Taylor",
     "title": "An aperiodic hexagonal tile", "year": 2011,
     "url": "https://doi.org/10.1016/j.jcta.2010.11.002",
     "doi": "10.1016/j.jcta.2010.11.002"},
]


TABLE: list[dict] = [
    _e("Penrose P1 Tiling",
       "substitution_rule P1: pentagon -> 6 pentagons + 5 diamonds + 5 halfstars",
       "Penrose P1 tiling (1974) — Penrose's first non-periodic set using pentagons, pentacles, diamonds and boats. Five-fold rotational symmetry; no periodic tiling exists.",
       _REFS_PENROSE, aliases=["P1"]),
    _e("Penrose P2 Kite-and-Dart",
       "substitution_rule P2: kite -> 2 kites + 2 darts; dart -> 1 kite + 1 dart",
       "Penrose P2 kite-and-dart tiling — two rhombi (kite φ angles and dart) with matching rules forcing aperiodicity. Golden-ratio scaling.",
       _REFS_PENROSE, aliases=["Kite-Dart", "P2"]),
    _e("Penrose P3 Rhombic",
       "substitution_rule P3: thick_rhomb -> 2 thick + 1 thin; thin_rhomb -> 1 thick + 2 thin",
       "Penrose P3 rhombic tiling — two golden rhombi (36° and 72° acute angles). Dual of P2 and most commonly rendered Penrose variant.",
       _REFS_PENROSE, aliases=["P3", "Penrose rhombic"]),
    _e("Ammann-Beenker Tiling",
       "substitution_rule AB: square + 45-rhombus -> scaled square + 45-rhombus ; eightfold symmetry",
       "Ammann-Beenker tiling — octagonal-symmetry aperiodic tiling using a square and 45° rhombus; silver-ratio (1+√2) scaling.",
       _REFS_AMMANN, aliases=["Ammann-Beenker", "8-fold aperiodic"]),
    _e("Ammann A2 Tiling",
       "substitution_rule A2: golden_bowtie -> bowtie + small_bowtie (matching-bar decoration)",
       "Ammann A2 tiling — bowtie-based aperiodic set decorated with Ammann bars; uses golden-ratio bowtie substitution.",
       _REFS_AMMANN),
    _e("Ammann A3 Tiling",
       "substitution_rule A3: isoceles_golden_triangle pair substitution",
       "Ammann A3 tiling — Robinson triangle substitution alternate to Penrose P2 kites/darts; equivalent up to matching rules.",
       _REFS_AMMANN),
    _e("Ammann A4 Tiling",
       "substitution_rule A4: golden rectangle + matching bars -> 2 rectangles scaled by phi",
       "Ammann A4 tiling — rectangular-bar aperiodic tiling with golden-ratio substitution.",
       _REFS_AMMANN),
    _e("Ammann A5 Tiling",
       "substitution_rule A5: two hexagons + matching bars (5-fold)",
       "Ammann A5 tiling — hexagonal aperiodic prototile set with five-fold matching bars.",
       _REFS_AMMANN),
    _e("Pinwheel Tiling",
       "substitution_rule pinwheel: 1-2-sqrt(5) right triangle -> 5 copies at arctan(1/2) angles",
       "Conway-Radin pinwheel tiling — aperiodic tiling by 1-2-√5 right triangles appearing in infinitely many orientations (statistical rotational isotropy).",
       [{"author": "C. Radin", "title": "The pinwheel tilings of the plane",
         "year": 1994, "url": "https://doi.org/10.2307/2118643",
         "doi": "10.2307/2118643"}],
       aliases=["Conway-Radin pinwheel"]),
    _e("Generalized Pinwheel",
       "substitution_rule gen_pinwheel: p-q-hypotenuse triangle, 5-subtile division",
       "Generalized Conway-Radin pinwheel with alternate side ratios — produces pinwheels with arbitrary irrational rotation angle.",
       _REFS_BOURKE),
    _e("Wang Tile Set (Kari-Culik 13-tile)",
       "substitution_rule Kari-Culik: 13-tile aperiodic Wang set with edge-colour matching",
       "Kari-Culik Wang tile set (1996) — 13 aperiodic square tiles with coloured edges; smallest known 4-edge Wang set forcing aperiodicity.",
       [{"author": "J. Kari", "title": "A small aperiodic set of Wang tiles",
         "year": 1996, "url": "https://doi.org/10.1016/0012-365X(94)00179-M",
         "doi": "10.1016/0012-365X(94)00179-M"}],
       aliases=["Wang tiles", "Kari-Culik"]),
    _e("Wang 11-Tile Set (Jeandel-Rao)",
       "substitution_rule Jeandel-Rao: 11-tile aperiodic Wang set (minimum known)",
       "Jeandel-Rao 11-tile Wang set (2015) — smallest possible aperiodic Wang tile set (proven minimum).",
       [{"author": "E. Jeandel, M. Rao",
         "title": "An aperiodic set of 11 Wang tiles",
         "year": 2015, "url": "https://arxiv.org/abs/1506.06492"}]),
    _e("Robinson Tiles",
       "substitution_rule Robinson: 6-tile aperiodic set with arrow matching",
       "Robinson aperiodic tile set (1971) — 6 prototiles with arrow-edge matching rules; first simple aperiodic set after Berger's 20426-tile set.",
       [{"author": "R. M. Robinson",
         "title": "Undecidability and nonperiodicity for tilings of the plane",
         "year": 1971, "url": "https://doi.org/10.1007/BF01418780",
         "doi": "10.1007/BF01418780"}]),
    _e("Chair Tiling",
       "substitution_rule chair: L-tromino -> 4 L-trominos rotated by 0/90/180/270",
       "Chair tiling — aperiodic substitution tiling by L-shaped trominos; each L splits into 4 smaller Ls. Related to dimer problem.",
       _REFS_BOURKE, aliases=["L-tromino"]),
    _e("L-Tromino Tiling",
       "substitution_rule L_tromino: 3-square L -> 4 identical L trominos at half scale",
       "L-tromino self-similar substitution tiling — exhibits 4-fold substitution matrix and non-trivial combinatorial dynamics.",
       _REFS_BOURKE),
    _e("Sphinx Tiling",
       "substitution_rule sphinx: hexiamond -> 4 sphinx hexiamonds (rep-4)",
       "Sphinx tiling — hexiamond shaped like a sphinx; the only known pentagonal rep-4 hexiamond that tiles aperiodically (Martin Gardner 1977).",
       _REFS_BOURKE, aliases=["Sphinx hexiamond"]),
    _e("Lebesgue Tile",
       "substitution_rule lebesgue: unit square -> 5 Lebesgue tiles (space-filling continuous)",
       "Lebesgue's curve tile — a square divided into 5 substitution subtiles producing Lebesgue's space-filling curve.",
       _REFS_BOURKE),
    _e("Rep-4 L-Tile",
       "substitution_rule rep4: L-shape -> 4 same-shape L-tiles at 1/2 linear scale",
       "Rep-4 tile (Solomon W. Golomb 1962) — a tile that can be dissected into 4 self-similar copies. L-tromino is the simplest.",
       _REFS_BOURKE, aliases=["rep-tile 4"]),
    _e("Rep-5 Tile",
       "substitution_rule rep5: P-pentomino -> 5 same-shape pentominos scaled by 1/sqrt(5)",
       "Rep-5 P-pentomino tile — divides into 5 self-similar copies (Solomon Golomb).",
       _REFS_BOURKE, aliases=["rep-tile 5"]),
    _e("Rep-7 Tile",
       "substitution_rule rep7: fudgeflake hex -> 7 smaller fudgeflakes",
       "Rep-7 fudgeflake — divides into 7 self-similar hexagonal copies; underlies the hexagonal Koch snowflake variant.",
       _REFS_BOURKE),
    _e("Rep-9 Tile",
       "substitution_rule rep9: nonomino -> 9 copies of itself at scale 1/3",
       "Rep-9 tile — Solomon Golomb's nonomino-based self-similar tile dividing into 9 copies.",
       _REFS_BOURKE),
    _e("Truchet Tile (Classic)",
       "substitution_rule truchet: square with diagonal cut -> 4 rotations randomized",
       "Sebastien Truchet (1704) classic Truchet tile — a square divided by a diagonal; random rotations produce intricate surface patterns.",
       [{"author": "S. Truchet",
         "title": "Mémoire sur les combinaisons",
         "year": 1704, "url": "https://en.wikipedia.org/wiki/Truchet_tiles"}],
       aliases=["Truchet"]),
    _e("Truchet Tile (Smith Quarter-Arcs)",
       "substitution_rule truchet_arcs: square with two opposing quarter-arcs (4 variants)",
       "Smith's quarter-arc Truchet tile (1987) — a square with two quarter-arcs connecting midpoints of opposing edges; produces looping maze patterns.",
       [{"author": "Cyril S. Smith", "title": "The tiling patterns of Sebastien Truchet",
         "year": 1987, "url": "https://en.wikipedia.org/wiki/Truchet_tiles"}]),
    _e("Truchet Tile (Extended Multi-Arc)",
       "substitution_rule truchet_ext: multi-colour extended Truchet set with 8 orientations",
       "Extended multi-arc Truchet set — modern generalizations (Bosch, Reas) producing woven-curve patterns.",
       _REFS_BOURKE),
    _e("Socolar 12-Fold Tiling",
       "substitution_rule Socolar12: 12-fold set of rhombi and squares with decoration",
       "Socolar 12-fold aperiodic tiling (1989) — dodecagonal-symmetry tiling from two rhombi (30° and 60°) plus a square; serves as toy model for quasicrystals.",
       [{"author": "J. E. S. Socolar",
         "title": "Simple octagonal and dodecagonal quasicrystals",
         "year": 1989, "url": "https://doi.org/10.1103/PhysRevB.39.10519",
         "doi": "10.1103/PhysRevB.39.10519"}]),
    _e("Socolar-Taylor Hexagonal Monotile",
       "substitution_rule Socolar-Taylor: marked hexagon + decorations, non-local matching",
       "Socolar-Taylor hexagonal tile (2011) — a single marked hexagonal prototile that tiles only aperiodically when matching rules include non-local 2nd-neighbor markings.",
       _REFS_SOCOLAR, aliases=["Socolar-Taylor"]),
    _e("Hat Aperiodic Monotile",
       "substitution_rule hat: 13-sided polykite -> 4 hats + reflection substitution",
       "Hat aperiodic monotile (Smith et al. 2023) — the first einstein (single aperiodic tile) using only orientation-preserving isometries and reflections. 13-sided polykite.",
       _REFS_HAT, aliases=["Einstein tile", "Hat monotile"]),
    _e("Turtle Aperiodic Monotile",
       "substitution_rule turtle: polykite variant of hat -> 4 turtles",
       "Turtle tile (Smith et al. 2023) — reflection-related sibling of the hat; both are aperiodic monotiles sharing the same substitution.",
       _REFS_HAT, aliases=["Turtle tile"]),
    _e("Spectre Aperiodic Monotile",
       "substitution_rule spectre: 14-sided chiral monotile -> substitution without reflection",
       "Spectre chiral aperiodic monotile (Smith et al. 2023) — the first chiral einstein, requiring no reflections for aperiodic tiling. 14-sided.",
       _REFS_SPECTRE, aliases=["Chiral einstein"]),
    _e("T-Tile (Tetromino Aperiodic)",
       "substitution_rule T_tile: T-tetromino with coloured edges; forces aperiodicity",
       "T-tile aperiodic set — L. Sadun's T-tetromino variant with edge colourings that force aperiodic tilings of the plane.",
       _REFS_BOURKE, aliases=["T-tile"]),
    _e("Fibonacci 1D Substitution",
       "substitution_rule fib1d: a -> ab; b -> a  ; generates Fibonacci sequence",
       "Fibonacci 1D substitution tiling — strings generated by a→ab, b→a give Fibonacci word; tile lengths have golden-ratio frequencies.",
       [{"author": "N. P. Fogg", "title": "Substitutions in dynamics, arithmetics and combinatorics",
         "year": 2002, "url": "https://doi.org/10.1007/b13861"}],
       aliases=["Fibonacci tiling"]),
    _e("Tribonacci Substitution",
       "substitution_rule tri: a -> ab; b -> ac; c -> a",
       "Tribonacci 1D substitution tiling — three-letter analogue of Fibonacci; tile lengths relate to the tribonacci constant (plastic number).",
       _REFS_BOURKE, aliases=["Tribonacci"]),
    _e("Rauzy Fractal Tiling",
       "substitution_rule rauzy: Tribonacci substitution a->ab, b->ac, c->a projected to plane",
       "Rauzy fractal — 2D tiling from tribonacci substitution projected onto the contracting plane. Self-similar fractal boundary.",
       [{"author": "G. Rauzy",
         "title": "Nombres algébriques et substitutions",
         "year": 1982, "url": "https://doi.org/10.24033/bsmf.1957",
         "doi": "10.24033/bsmf.1957"}],
       aliases=["Rauzy"]),
    _e("Thue-Morse 2D Tiling",
       "substitution_rule tm2d: a -> [[a,b],[b,a]]; b -> [[b,a],[a,b]]",
       "Thue-Morse 2D substitution tiling — 2x2 matrix substitution producing the Thue-Morse fractal surface pattern.",
       _REFS_BOURKE, aliases=["Thue-Morse tiling"]),
    _e("Stampfli Dodecagonal",
       "substitution_rule stampfli: 12-fold hierarchical tiling of squares + rhombi + triangles",
       "Stampfli dodecagonal tiling (1986) — 12-fold aperiodic tiling from squares, 30° rhombi and equilateral triangles; models dodecagonal quasicrystals.",
       [{"author": "P. Stampfli",
         "title": "A dodecagonal quasiperiodic lattice in two dimensions",
         "year": 1986,
         "url": "https://doi.org/10.1016/0378-4371(86)90021-5",
         "doi": "10.1016/0378-4371(86)90021-5"}]),
    _e("Danzer 7-Fold Tiling",
       "substitution_rule danzer7: 3 triangular prototiles with 7-fold symmetry",
       "Danzer 7-fold aperiodic tiling (1996) — three isoceles triangles producing a 7-fold-symmetric aperiodic tiling of the plane.",
       [{"author": "L. Danzer", "title": "A family of 4D-spacefillers not yet classified",
         "year": 1996, "url": "https://en.wikipedia.org/wiki/Danzer%27s_tiling"}]),
    _e("Cyrille Tiling",
       "substitution_rule cyrille: quintic aperiodic tile with 5-fold decoration",
       "Cyrille hexagonal aperiodic tile — Cyrille Tournier's 2020 hexagonal substitution tile with quasiperiodic 5-fold decoration.",
       _REFS_BOURKE),
    _e("Paul Bourke Fibonacci Tiling",
       "substitution_rule pb_fib: 2D Fibonacci tiling projecting onto cut-and-project 2D strip",
       "Paul Bourke's 2D Fibonacci cut-and-project tiling — higher-dimensional strip projected onto 2D gives quasiperiodic pattern.",
       _REFS_BOURKE),
    _e("Paul Bourke Hexagonal Random Tiling",
       "substitution_rule pb_hexrandom: stochastic hexagonal dimer substitution",
       "Paul Bourke's hexagonal stochastic substitution tiling — random-substitution variant producing quasiperiodic statistics.",
       _REFS_BOURKE),
    _e("Half-Hex Substitution",
       "substitution_rule halfhex: half-hexagon -> 4 half-hexagons rotated",
       "Half-hexagon substitution tiling — Conway's half-hex rep-4 tile producing aperiodic patterns.",
       _REFS_BOURKE),
    _e("Ammann Rhombic A1",
       "substitution_rule A1: golden-rhombi with Ammann bars matching rule 1",
       "Ammann rhombic set A1 — alternate rhombic variant with bar decoration; equivalent to Penrose P3 up to bar rules.",
       _REFS_AMMANN),
]


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
