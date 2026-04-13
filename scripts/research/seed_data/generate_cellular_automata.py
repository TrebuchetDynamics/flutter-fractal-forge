"""Cellular automata classics.

References: Wolfram "A New Kind of Science" (2002), Conway's Game of Life,
Langton's Ant, Brian's Brain, Wireworld.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "cellular_automata"
FAMILY = "ca"

_PARAMS = {
    "generations": {"default": 256, "range": [1, 10000]},
    "grid_size": {"default": 512, "range": [8, 4096]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]

_WOLFRAM = "https://mathworld.wolfram.com/ElementaryCellularAutomaton.html"


def _e(name: str, update: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None, init: str = "single cell (1)") -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "cellular",
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


def _elementary(rule: int) -> tuple[str, str]:
    """Return (update_string, aliases) for elementary rule N."""
    bits = [(rule >> i) & 1 for i in range(8)]
    return (f"new_cell = elementary_rule_{rule}(left, center, right) [rule_bits={bits}]",
            f"Wolfram rule {rule}")


ELEMENTARY_RULES = {
    30: "Rule 30 — Wolfram's class-3 chaotic rule, used as the default RNG in Mathematica; produces irregular triangular patterns from a single-cell seed.",
    45: "Rule 45 — chaotic elementary CA with class-3 behavior and apparent periodicity.",
    54: "Rule 54 — class-4 complex elementary CA with mobile particle-like structures.",
    62: "Rule 62 — class-2 periodic elementary CA with stable patterns.",
    73: "Rule 73 — class-2 elementary CA with rich periodic behavior.",
    90: "Rule 90 — XOR of neighbors; produces the Sierpinski triangle from a single-cell seed. Additive linear CA.",
    94: "Rule 94 — class-2 CA similar to Rule 90 but with different boundary symmetry.",
    102: "Rule 102 — class-2 elementary CA with simple periodic patterns.",
    110: "Rule 110 — Cook proved this elementary CA is Turing complete in 2004.",
    122: "Rule 122 — class-3 chaotic elementary CA.",
    126: "Rule 126 — class-3 chaotic elementary CA, XOR with left+right neighbors.",
    150: "Rule 150 — additive elementary CA (XOR of all three inputs); produces a Pascal-triangle-mod-2 pattern.",
    182: "Rule 182 — class-2 elementary CA.",
    184: "Rule 184 — class-2 elementary CA used as a model for traffic flow; particles move left consistently.",
    22: "Rule 22 — class-3 chaotic elementary CA with complex fractal patterns.",
    50: "Rule 50 — class-2 elementary CA with interesting periodic behavior.",
    60: "Rule 60 — left-shift XOR; produces the Sierpinski triangle when initialized with a single cell.",
    86: "Rule 86 — mirror-image of Rule 30 with similar chaotic output.",
    105: "Rule 105 — additive elementary CA similar to Rule 150.",
    169: "Rule 169 — complex elementary CA with diverse pattern behavior.",
    225: "Rule 225 — class-3 complex elementary CA.",
    250: "Rule 250 — class-2 elementary CA; simple filled triangle from seed.",
}


TABLE: list[dict] = []

for rule_num, desc in ELEMENTARY_RULES.items():
    update, alias = _elementary(rule_num)
    TABLE.append(_e(
        f"Elementary CA Rule {rule_num}",
        update,
        desc,
        [{"author": "S. Wolfram", "title": "A New Kind of Science",
          "year": 2002, "url": _WOLFRAM}],
        aliases=[alias],
    ))

# 2D CAs
TWO_D = [
    ("Conway's Game of Life",
     "new_cell = B3_S23(neighbors, current)",
     "Conway's Game of Life (1970) — B3/S23 rule: cell born with exactly 3 neighbors, survives with 2 or 3. Turing-complete with gliders, oscillators, and spaceships.",
     [{"author": "Martin Gardner",
       "title": "Mathematical Games: The fantastic combinations of John Conway's new solitaire game 'life'",
       "year": 1970, "url": "https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life"}],
     ["Game of Life", "B3/S23"]),
    ("Seeds CA",
     "new_cell = B2_S_(neighbors, current)",
     "Seeds (B2) — a cellular automaton where a dead cell becomes alive if it has exactly 2 live neighbors; live cells always die.",
     [{"author": "Mirek Wójtowicz", "title": "Seeds (cellular automaton)",
       "year": 1997, "url": "https://en.wikipedia.org/wiki/Seeds_(cellular_automaton)"}],
     ["B2", "B2/S_"]),
    ("Day and Night",
     "new_cell = B3678_S34678(neighbors, current)",
     "Day and Night (B3678/S34678) — symmetric CA where the rule is symmetric under cell inversion; gliders exist in both 'day' and 'night' phases.",
     [{"author": "Nathan Thompson",
       "title": "Day and Night (cellular automaton)", "year": 1997,
       "url": "https://en.wikipedia.org/wiki/Day_and_Night_(cellular_automaton)"}],
     ["B3678/S34678"]),
    ("HighLife",
     "new_cell = B36_S23(neighbors, current)",
     "HighLife (B36/S23) — variant of Life that supports replicators. Birth with 3 or 6, survives with 2 or 3.",
     [{"author": "Nathan Thompson", "title": "HighLife",
       "year": 1994, "url": "https://en.wikipedia.org/wiki/Highlife_(cellular_automaton)"}],
     ["B36/S23"]),
    ("Life without Death",
     "new_cell = B3_S012345678(neighbors, current)",
     "Life without Death (B3/S012345678) — Life variant where live cells never die; produces ladders and self-assembling patterns.",
     [{"author": "D. Griffeath, C. Moore", "title": "Life without death is P-complete",
       "year": 1996, "url": "https://en.wikipedia.org/wiki/Life_without_Death"}],
     ["B3/S012345678"]),
    ("Move",
     "new_cell = B368_S245(neighbors, current)",
     "Move (B368/S245) — Life-like CA with moving blocks; gliders emerge naturally.",
     [{"author": "Alan Hensel", "title": "Move CA", "year": 1998,
       "url": "https://www.conwaylife.com/wiki/OCA:Move"}],
     ["B368/S245"]),
    ("Replicator (2-color)",
     "new_cell = B1357_S1357(neighbors, current)",
     "Replicator (B1357/S1357) — any pattern replicates itself fractally at distance 8 (Edward Fredkin's replicator).",
     [{"author": "Edward Fredkin", "title": "Replicator CA",
       "year": 1960, "url": "https://en.wikipedia.org/wiki/Fredkin%27s_paradox"}],
     ["Fredkin replicator"]),
    ("Serviettes",
     "new_cell = B234_S_(neighbors, current)",
     "Serviettes (B234) — produces lacework-like growth; a pure-birth rule.",
     [{"author": "Mirek Wójtowicz", "title": "Serviettes CA",
       "year": 1999, "url": "https://www.conwaylife.com/wiki/OCA:Serviettes"}],
     ["B234/S_"]),
    ("Maze",
     "new_cell = B3_S12345(neighbors, current)",
     "Maze (B3/S12345) — life-like CA that grows maze-like corridors.",
     [{"author": "Mirek Wójtowicz", "title": "Maze CA",
       "year": 1999, "url": "https://www.conwaylife.com/wiki/OCA:Maze"}],
     ["B3/S12345"]),
    ("Wireworld",
     "new_cell = wireworld_transition(current, neighbors)",
     "Wireworld (Brian Silverman 1987) — 4-state CA simulating digital electronic circuits with electron heads, tails, and wires.",
     [{"author": "Brian Silverman", "title": "Wireworld cellular automaton",
       "year": 1987, "url": "https://en.wikipedia.org/wiki/Wireworld"}],
     []),
    ("Turing Drawings",
     "new_cell = turmite_transition(state, tape, direction)",
     "Turmite (generalized Turing drawings) — 2D Turing machines on a grid producing intricate self-drawn patterns.",
     [{"author": "A. K. Dewdney", "title": "Computer Recreations: Turmites",
       "year": 1989, "url": "https://en.wikipedia.org/wiki/Turmite"}],
     ["Turmite"]),
    ("Cyclic CA",
     "new_cell = cyclic_rule(current, neighbors, n_colors=14, threshold=3)",
     "Cyclic cellular automaton (Griffeath) — cells cycle through n colors and advance when a threshold of matching-next-color neighbors is reached; produces spiral-wave patterns.",
     [{"author": "D. Griffeath", "title": "Cyclic cellular automata",
       "year": 1988, "url": "https://psoup.math.wisc.edu/kitchen.html"}],
     ["Griffeath CCA"]),
    ("Lenia (orbium)",
     "new_cell = lenia_growth(neighborhood_convolution, mu=0.15, sigma=0.017)",
     "Lenia (Bert Chan 2018) — continuous-state, continuous-space generalization of Game of Life producing life-like 'orbium' creatures.",
     [{"author": "Bert Wang-Chak Chan", "title": "Lenia — Biology of Artificial Life",
       "year": 2019, "url": "https://arxiv.org/abs/1812.05433"}],
     ["Bert Chan Lenia"]),
    ("Nagel-Schreckenberg Traffic",
     "new_speed = min(speed+1, vmax); if gap <= new_speed: new_speed = gap - 1; if rand() < p: new_speed -= 1",
     "Nagel-Schreckenberg traffic-flow CA — 1D stochastic CA simulating highway traffic with acceleration, braking, and random deceleration.",
     [{"author": "K. Nagel, M. Schreckenberg",
       "title": "A cellular automaton model for freeway traffic", "year": 1992,
       "url": "https://doi.org/10.1051/jp1:1992277",
       "doi": "10.1051/jp1:1992277"}],
     ["NaSch traffic"]),
    ("Hodgepodge Machine",
     "new_cell = hodgepodge_next(current, neighbors, excitation_threshold)",
     "Hodgepodge machine (Gerhardt, Schuster, Tyson 1990) — excitable-medium CA producing spiral waves similar to Belousov-Zhabotinsky reaction.",
     [{"author": "M. Gerhardt, H. Schuster, J. J. Tyson",
       "title": "A cellular automaton model of excitable media including curvature",
       "year": 1990, "url": "https://doi.org/10.1016/0167-2789(90)90136-E",
       "doi": "10.1016/0167-2789(90)90136-E"}],
     []),
    ("Belousov-Zhabotinsky CA",
     "new_cell = bz_excitable(current, neighbors, refractory_period)",
     "Belousov-Zhabotinsky discrete model — 3-state excitable CA approximating the BZ chemical oscillator.",
     [{"author": "A. T. Winfree", "title": "Spiral waves of chemical activity",
       "year": 1972, "url": "https://doi.org/10.1126/science.175.4022.634",
       "doi": "10.1126/science.175.4022.634"}],
     ["BZ CA"]),
    ("Sand Pile Model (BTW)",
     "if cell >= 4: cell -= 4; neighbors += 1",
     "Bak-Tang-Wiesenfeld abelian sandpile model — archetypal self-organized criticality system; topples cells when exceeding a threshold.",
     [{"author": "P. Bak, C. Tang, K. Wiesenfeld",
       "title": "Self-organized criticality: An explanation of 1/f noise",
       "year": 1987, "url": "https://doi.org/10.1103/PhysRevLett.59.381",
       "doi": "10.1103/PhysRevLett.59.381"}],
     ["BTW sandpile", "sandpile model"]),
    ("Langton's Ant (multi-color)",
     "new_dir = rotation_rule(color); cell_color = (cell_color + 1) mod n_colors",
     "Multi-color Langton's ant — generalization with arbitrary rotation rules per color; produces highways and emergent paths.",
     [{"author": "Chris Langton", "title": "Studying artificial life with cellular automata",
       "year": 1986, "url": "https://doi.org/10.1016/0167-2789(86)90237-X",
       "doi": "10.1016/0167-2789(86)90237-X"}],
     ["generalized Langton's ant"]),
    ("Rule 184 (Traffic)",
     "new_cell = rule_184(left, center, right)",
     "Rule 184 reinterpreted as traffic model — cars (1s) move right-ward into empty cells (0s); first exactly-solvable traffic CA.",
     [{"author": "S. Wolfram", "title": "Rule 184 (traffic)", "year": 2002,
       "url": _WOLFRAM}],
     ["Rule 184"]),
]

for name, update, desc, refs, aliases in TWO_D:
    TABLE.append(_e(name, update, desc, refs, aliases=aliases))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
