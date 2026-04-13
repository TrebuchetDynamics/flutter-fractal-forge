"""Orchestrator: runs all generator modules in sequence."""
from __future__ import annotations

from scripts.research.seed_data import (
    generate_sprott_attractors,
    generate_classic_attractors,
    generate_multibrot_family,
    generate_julia_c_values,
    generate_henon_family,
    generate_l_system_classics,
    generate_ifs_classics,
    generate_cellular_automata,
)


def main() -> None:
    for mod in (
        generate_sprott_attractors,
        generate_classic_attractors,
        generate_multibrot_family,
        generate_julia_c_values,
        generate_henon_family,
        generate_l_system_classics,
        generate_ifs_classics,
        generate_cellular_automata,
    ):
        mod.main()


if __name__ == "__main__":
    main()
