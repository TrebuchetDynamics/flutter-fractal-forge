#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
from ruamel.yaml import YAML
from scripts.research.admit.emit_dart import emit

repo = Path.cwd()
fixtures = repo / "test" / "research" / "fixtures" / "sample_candidates"
probe_root = repo  # emit into the real app so imports of base_classes resolve

iter_map = {
    "f_sample_mandelbrot.yaml": "escape_time",
    "f_sample_burning_ship.yaml": "escape_time",
    "f_sample_mandelbulb.yaml": "raymarch_3d",
    "f_sample_lorenz.yaml": "strange_attractor",
    "f_sample_sierpinski.yaml": "ifs",
    "f_sample_koch.yaml": "l_system",
}

for fname, iter_type in iter_map.items():
    with (fixtures / fname).open() as f:
        cand = YAML(typ="safe").load(f)
    name = cand["proposed_name"]
    id_ = "ci_probe_" + name.lower().replace(" ", "_").replace("'", "").replace("-", "_")
    reg_entry = {
        "id": id_,
        "name": name,
        "category": "CI Probe",
        "shader": f"shaders/{id_}_gpu.frag",
        "family": None,
        "aliases": cand.get("aliases", []),
        "defaultPower": 2.0,
        "defaultBailout": 2.0,
        "defaultIterations": 500,
        "defaultSteps": 120,
    }
    emit(cand, reg_entry, iter_type, probe_root)
    print(f"emitted: {id_}")
PY

flutter analyze lib/core/modules/
