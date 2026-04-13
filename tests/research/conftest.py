from pathlib import Path

import pytest
from ruamel.yaml import YAML


@pytest.fixture
def yaml_rt() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    return y


@pytest.fixture
def tmp_registry(tmp_path, yaml_rt) -> Path:
    """A temporary minimal registry file with two legacy-shaped entries."""
    path = tmp_path / "fractal_registry.yaml"
    data = {
        "fractals": [
            {
                "id": "mandelbrot",
                "name": "Mandelbrot",
                "shader": "shaders/mandelbrot_gpu.frag",
                "category": "Escape-Time",
                "dimension": "2D",
                "defaultPower": 2.0,
                "defaultIterations": 500.0,
                "defaultSteps": 0.0,
                "defaultBailout": 2.0,
                "defaultColorScheme": 0,
                "hasThumbnail": True,
                "implemented": True,
                "presets": [],
                "variants": [],
                "references": [],
            },
            {
                "id": "burning_ship",
                "name": "Burning Ship",
                "shader": "shaders/burning_ship_gpu.frag",
                "category": "Escape-Time",
                "dimension": "2D",
                "defaultPower": 2.0,
                "defaultIterations": 500.0,
                "defaultSteps": 0.0,
                "defaultBailout": 2.0,
                "defaultColorScheme": 0,
                "hasThumbnail": False,
                "implemented": True,
                "presets": [],
                "variants": [],
                "references": [],
            },
        ]
    }
    with path.open("w") as f:
        yaml_rt.dump(data, f)
    return path
