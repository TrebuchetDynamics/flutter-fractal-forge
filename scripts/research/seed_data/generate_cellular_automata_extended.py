"""Extended cellular automata — more elementary rules + Life-like rules + multi-state.

Sources:
  - S. Wolfram, "A New Kind of Science" (2002).
  - Mirek Wójtowicz, "Mirek's Cellebration" Life-like CA database.
  - LifeWiki (https://www.conwaylife.com/wiki/Main_Page).
  - E. F. Codd "Cellular Automata" (1968).
  - Langton's loops 1984.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "cellular_automata_extended"
FAMILY = "ca_ext"

_PARAMS = {
    "generations": {"default": 256, "range": [1, 10000]},
    "grid_size": {"default": 512, "range": [8, 4096]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]

_WOLFRAM = "https://mathworld.wolfram.com/ElementaryCellularAutomaton.html"
_LIFEWIKI = "https://www.conwaylife.com/wiki/"
_MIREK = "https://www.mirekw.com/ca/"


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


# Elementary rules from the 256 rule space — pick all those NOT yet admitted.
# Already in registry: 22, 30, 45, 50, 54, 60, 62, 73, 86, 90, 94, 102, 105,
# 110, 122, 126, 150, 169, 182, 184, 225, 250.
EXTENDED_RULES: list[int] = [
    2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 26, 28, 32, 34, 36, 38, 40, 42, 44,
    46, 56, 58, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 88, 92, 96, 98, 100,
    104, 106, 108, 112, 114, 118, 120, 124, 128, 130, 132, 134, 136, 138, 140,
    142, 144, 146, 148, 152, 154, 156, 158, 160, 162, 164, 166, 168, 170, 172,
    174, 176, 178, 180, 186, 188, 190, 192, 194, 196, 198, 200, 202, 204, 206,
    208, 210, 212, 214, 218, 220, 222, 226, 230, 232, 234, 238, 242, 246, 254,
]


def _elementary_desc(rule: int) -> str:
    bits = [(rule >> i) & 1 for i in range(8)]
    cls = "class-2 periodic" if rule in {0, 4, 8, 36, 72} else (
        "class-3 chaotic" if rule in {18, 22, 30, 45, 60, 90, 105, 122, 126, 146, 150} else (
            "class-4 complex" if rule in {54, 110} else "elementary"
        )
    )
    return (
        f"Wolfram elementary CA rule {rule} (rule_bits={bits}). "
        f"{cls} 1D binary CA with 3-cell radius-1 neighborhood."
    )


TABLE: list[dict] = []

for rule in EXTENDED_RULES:
    update = f"new_cell = elementary_rule_{rule}(left, center, right)"
    TABLE.append(_e(
        f"Elementary CA Rule {rule}",
        update,
        _elementary_desc(rule),
        [{"author": "S. Wolfram", "title": "A New Kind of Science",
          "year": 2002, "url": _WOLFRAM}],
        aliases=[f"Wolfram rule {rule}"],
    ))


# ---- Life-like 2D B/S-rule cellular automata
LIFE_LIKE = [
    ("Replicator (B1357/S1357)",
     "B1357/S1357",
     "Replicator (Fredkin 1960) — any pattern self-replicates at distance 8 every 8 generations.",
     ["Fredkin replicator"]),
    ("Fredkin's Replicator (B1357/S02468)",
     "B1357/S02468",
     "Fredkin's stricter replicator — preserves cells that already have an even number of neighbours.",
     ["Fredkin"]),
    ("Live Free or Die (B2/S0)",
     "B2/S0",
     "Live Free or Die (B2/S0) — birth on 2 neighbours, survive only with no neighbours; chaotic with very small still-lifes.",
     []),
    ("Mazectric (B3/S1234)",
     "B3/S1234",
     "Mazectric (B3/S1234) — Maze rule with extra-tight survival; produces straight maze corridors.",
     []),
    ("Coagulations B378",
     "B378/S235678",
     "Coagulations CA (B378/S235678) — chaotic-growth CA forming amoeba-like blobs.",
     []),
    ("2x2 (B36/S125)",
     "B36/S125",
     "2x2 (B36/S125) — Life-like CA with 2×2 block-symmetry; supports sliding 2×2 patterns.",
     []),
    ("Gnarl (B1/S1)",
     "B1/S1",
     "Gnarl (B1/S1) — strict-self-organising rule producing twisted gnarled structures.",
     []),
    ("Stains (B3678/S235678)",
     "B3678/S235678",
     "Stains (B3678/S235678) — chaotic-growth CA forming stable irregular stain-like blobs.",
     []),
    ("Pseudo Life (B357/S238)",
     "B357/S238",
     "Pseudo Life (B357/S238) — Life-like rule with similar gliders to Life but different stable structures.",
     ["pseudo-life"]),
    ("Long Life (B345/S5)",
     "B345/S5",
     "Long Life (B345/S5) — long-lived patterns with very high spaceship/oscillator densities.",
     []),
    ("Anneal (B4678/S35678)",
     "B4678/S35678",
     "Anneal CA — anti-Life rule producing annealing-like grain coarsening.",
     []),
    ("Diamoeba (B35678/S5678)",
     "B35678/S5678",
     "Diamoeba (B35678/S5678) — diamond-shaped amoeba colonies with stable interior.",
     []),
    ("Dot Life (B3/S023)",
     "B3/S023",
     "Dot Life — Life variant with extra survival on lonely cells; produces persistent dots.",
     []),
    ("Flock (B3/S12)",
     "B3/S12",
     "Flock (B3/S12) — bird-flock-like CA with rapid stabilisation.",
     []),
    ("Iceballs (B25678/S5678)",
     "B25678/S5678",
     "Iceballs CA — produces growing ice-crystal patterns.",
     []),
    ("Replicator 4 (B1357/S03567)",
     "B1357/S03567",
     "Replicator-4 variant — four-fold-symmetric replicator with different replication period.",
     []),
    ("Walled Cities (B45678/S2345)",
     "B45678/S2345",
     "Walled Cities (B45678/S2345) — produces enclosed wall-like structures with chaotic interiors.",
     []),
    ("Vote CA (B45678/S345678)",
     "B45678/S345678",
     "Vote majority CA — used in image-processing as noise filter; cell becomes 1 if majority of neighbors are 1.",
     []),
    ("3-4 Life (B34/S34)",
     "B34/S34",
     "3-4 Life (B34/S34) — symmetric-rule CA with rich glider zoo.",
     []),
    ("Move (B368/S245)",
     "B368/S245",
     "Move CA (B368/S245) — Life-like with naturally emerging gliders that move blocks.",
     []),
    ("Snowflakes (B1/S12345678)",
     "B1/S12345678",
     "Snowflakes (B1/S12345678) — radial-growth CA producing snowflake-like crystalline structures.",
     []),
    ("Slow Blob (B367/S23478)",
     "B367/S23478",
     "Slow Blob (B367/S23478) — slowly-growing blob-like CA with internal structure.",
     []),
    ("Bugs (B3567/S15678)",
     "B3567/S15678",
     "Bugs CA (B3567/S15678) — produces small bug-like spaceships.",
     []),
    ("Plow World (B378/S012345678)",
     "B378/S012345678",
     "Plow World CA — never-die CA with explosive growth carving plough-like patterns.",
     []),
    ("Land Rush (B35/S234578)",
     "B35/S234578",
     "Land Rush CA — chaotic land-grab pattern formation.",
     []),
    ("Maze with Mice (B37/S12345)",
     "B37/S12345",
     "Maze with Mice — Maze variant with mobile mouse-like patterns inside corridors.",
     []),
    ("Slow Stains (B36/S378)",
     "B36/S378",
     "Slow stains variant (B36/S378) — slowly-spreading stain CA with delayed growth.",
     []),
    ("HighFlock (B36/S12)",
     "B36/S12",
     "HighFlock (B36/S12) — Highlife variant with flock-like dynamics.",
     []),
    ("Honey Life (B38/S238)",
     "B38/S238",
     "Honey Life (B38/S238) — honeycomb-like patterns reminiscent of Life with extra births.",
     []),
    ("EightLife (B3/S238)",
     "B3/S238",
     "EightLife (B3/S238) — Life with extra survival on 8 neighbours.",
     []),
    ("Pedestrian Life (B38/S23)",
     "B38/S23",
     "Pedestrian Life — Life with B at 3 or 8 neighbours.",
     []),
    ("LowLife (B3/S13)",
     "B3/S13",
     "LowLife (B3/S13) — Life with reduced survival range.",
     []),
    ("Drigh Life (B367/S23)",
     "B367/S23",
     "Drigh Life (B367/S23) — Life variant with extra births at 6 and 7.",
     []),
    ("Inverse Life (B0123478/S34678)",
     "B0123478/S34678",
     "Inverse Life — anti-Life: works on the dual (background-flipping) version.",
     []),
]


for name, bs, desc, aliases in LIFE_LIKE:
    # Prepend literal rule string with semicolon so sympy can't parse and falls
    # back to raw-string hashing, ensuring uniqueness per rule.
    update = f"rule_string = '{bs}'; new_cell = life_like_rule(neighbors, current, rule={bs!r})"
    TABLE.append(_e(
        name, update, desc + f" Rule notation: {bs}.",
        [{"author": "Mirek Wójtowicz", "title": "Mirek's Cellebration database",
          "year": 1999, "url": _MIREK}],
        aliases=aliases or [bs.replace("/", "-")],
    ))


# ---- Multi-state CAs
TABLE.append(_e("Wireworld",
    "new_cell = wireworld_4state(current, electron_head, electron_tail, conductor)",
    "Wireworld (Brian Silverman 1987) — 4-state CA simulating digital electronic circuits with electron heads, tails and wires. Turing-complete.",
    [{"author": "B. Silverman", "title": "Wireworld cellular automaton",
      "year": 1987, "url": "https://en.wikipedia.org/wiki/Wireworld"}],
    aliases=["Silverman wireworld"]))
TABLE.append(_e("Langton's Loops",
    "new_cell = langton_loops_8state(current, neighbors, signal_state)",
    "Langton's loops (1984) — 8-state self-reproducing CA loops; first practical demonstration of artificial self-replication.",
    [{"author": "C. Langton", "title": "Self-reproduction in cellular automata",
      "year": 1984, "url": "https://doi.org/10.1016/0167-2789(84)90256-2",
      "doi": "10.1016/0167-2789(84)90256-2"}],
    aliases=["Langton loops"]))
TABLE.append(_e("Codd's CA",
    "new_cell = codd_8state(current, neighbors, signal)",
    "Edgar Codd's 8-state CA (1968) — simplification of von Neumann's 29-state self-reproducing CA. Genesis of practical self-replicating CAs.",
    [{"author": "E. F. Codd", "title": "Cellular Automata",
      "year": 1968, "url": "https://en.wikipedia.org/wiki/Codd%27s_cellular_automaton"}],
    aliases=["Codd"]))
TABLE.append(_e("Byl's Self-Reproducer",
    "new_cell = byl_loop_6state(current, neighbors, signal)",
    "Byl's self-reproducing CA (1989) — 6-state variant of Langton's loops with simplified replication mechanism.",
    [{"author": "J. Byl", "title": "Self-reproduction in small cellular automata",
      "year": 1989, "url": "https://doi.org/10.1016/0167-2789(89)90185-5",
      "doi": "10.1016/0167-2789(89)90185-5"}]))
TABLE.append(_e("Sayama's Evoloop",
    "new_cell = evoloop_9state(current, neighbors, evolutionary_signal)",
    "Sayama's evoloop (1999) — 9-state CA implementing self-reproducing loops that evolve via mutation and selection.",
    [{"author": "H. Sayama", "title": "A new structurally dissolvable self-reproducing loop evolving in a simple cellular automata space",
      "year": 1999, "url": "https://doi.org/10.1162/106454699568665",
      "doi": "10.1162/106454699568665"}]))
TABLE.append(_e("Greenberg-Hastings Excitable",
    "new_cell = greenberg_hastings_3state(current, neighbors, threshold)",
    "Greenberg-Hastings 3-state excitable-medium CA (1978) — quiescent/excited/refractory model for spiral waves.",
    [{"author": "J. M. Greenberg, S. P. Hastings",
      "title": "Spatial patterns for discrete models of diffusion in excitable media",
      "year": 1978, "url": "https://doi.org/10.1137/0134046",
      "doi": "10.1137/0134046"}]))
TABLE.append(_e("Brian's Brain",
    "new_cell = brians_brain_3state(current, alive_neighbors)",
    "Brian's Brain (Brian Silverman) — 3-state (alive/dying/dead) CA with B2/S- rule producing interlocking gliders and spirals.",
    [{"author": "B. Silverman", "title": "Brian's Brain cellular automaton",
      "year": 1990, "url": "https://en.wikipedia.org/wiki/Brian%27s_Brain"}],
    aliases=["BrianBrain"]))
TABLE.append(_e("Cyclic CA (n=4)",
    "new_cell = cyclic_rule_n4(current, neighbors, threshold=1)",
    "Cyclic CA with 4 colours and threshold 1 — produces large concentric coloured spirals (Griffeath 1988).",
    [{"author": "D. Griffeath", "title": "Cyclic cellular automata",
      "year": 1988, "url": "https://psoup.math.wisc.edu/kitchen.html"}]))
TABLE.append(_e("Cyclic CA (n=16)",
    "new_cell = cyclic_rule_n16(current, neighbors, threshold=3)",
    "Cyclic CA with 16 colours and threshold 3 — finer spirals with rainbow colour bands.",
    [{"author": "D. Griffeath", "title": "Primordial soup kitchen",
      "year": 1996, "url": "https://psoup.math.wisc.edu/kitchen.html"}]))
TABLE.append(_e("Hodgepodge Machine (Spiral)",
    "new_cell = hodgepodge_spiral_5state(current, neighbors, infect_threshold=2, decay=3)",
    "Hodgepodge machine spiral regime — Gerhardt-Schuster-Tyson excitable-medium CA producing rotating spirals like BZ reaction.",
    [{"author": "M. Gerhardt, H. Schuster",
      "title": "A cellular automaton describing the formation of spatially ordered structures in chemical systems",
      "year": 1989, "url": "https://doi.org/10.1016/0167-2789(89)90147-8",
      "doi": "10.1016/0167-2789(89)90147-8"}]))
TABLE.append(_e("Forest Fire CA",
    "new_cell = forest_fire(empty=0, tree=1, fire=2, p_grow=0.05, p_lightning=1e-5)",
    "Forest fire CA (Drossel-Schwabl 1992) — 3-state stochastic CA exhibiting self-organised criticality with power-law fire-size distribution.",
    [{"author": "B. Drossel, F. Schwabl",
      "title": "Self-organized critical forest-fire model",
      "year": 1992, "url": "https://doi.org/10.1103/PhysRevLett.69.1629",
      "doi": "10.1103/PhysRevLett.69.1629"}],
    aliases=["Drossel-Schwabl"]))
TABLE.append(_e("SIR Epidemic CA",
    "new_cell = sir_3state(susceptible, infected, recovered, beta=0.3, gamma=0.1)",
    "SIR epidemic spreading CA — 3-state discretisation of compartmental epidemic model on a 2D lattice.",
    [{"author": "W. O. Kermack, A. G. McKendrick",
      "title": "A contribution to the mathematical theory of epidemics",
      "year": 1927, "url": "https://doi.org/10.1098/rspa.1927.0118",
      "doi": "10.1098/rspa.1927.0118"}]))
TABLE.append(_e("Margolus Block CA (HPP gas)",
    "new_block = margolus_HPP_4state(2x2_block, parity)",
    "HPP lattice gas (Hardy-Pomeau-de Pazzis 1973) on Margolus block neighborhood — exactly-conservative momentum-conserving 4-state CA.",
    [{"author": "J. Hardy, Y. Pomeau, O. de Pazzis",
      "title": "Time evolution of two-dimensional model system. I. Invariant states and time correlation functions",
      "year": 1973, "url": "https://doi.org/10.1063/1.1666197",
      "doi": "10.1063/1.1666197"}]))
TABLE.append(_e("FHP Lattice Gas",
    "new_block = fhp_lattice_gas_6state(hex_block)",
    "Frisch-Hasslacher-Pomeau (FHP) lattice gas — hexagonal-neighbour 6-direction lattice gas recovering Navier-Stokes hydrodynamics in continuum limit.",
    [{"author": "U. Frisch, B. Hasslacher, Y. Pomeau",
      "title": "Lattice-gas automata for the Navier-Stokes equation",
      "year": 1986, "url": "https://doi.org/10.1103/PhysRevLett.56.1505",
      "doi": "10.1103/PhysRevLett.56.1505"}],
    aliases=["FHP gas"]))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
