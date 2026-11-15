"""Regression coverage for the production process-restoration assertion."""

import importlib.util
from pathlib import Path

import pytest


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/verify-restored-viewer.py"
SPEC = importlib.util.spec_from_file_location("verify_restored_viewer", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


@pytest.mark.parametrize(
    "capture, expected",
    [
        ('<hierarchy><node content-desc="Interactive fractal canvas&#10;Julia"/></hierarchy>', True),
        ('<hierarchy><node content-desc="Interactive fractal canvas&#10;Julia"/></hierarchy>\nUI hierarchy dumped to: /dev/tty', True),
        ('<hierarchy><node content-desc="Julia fractal, 2D"/><node text="Edit fractal"/></hierarchy>', False),
        ('<hierarchy><node content-desc="Interactive fractal canvas&#10;Mandelbrot"/><node text="Julia"/></hierarchy>', False),
        ('<hierarchy><node content-desc="Interactive fractal canvas&#10;Julia Triplex"/></hierarchy>', False),
        ('<hierarchy><node text="Julia"/></hierarchy>', False),
        ('<hierarchy><broken></hierarchy>', False),
        ('uiautomator failed', False),
    ],
)
def test_restored_julia_canvas(capture, expected):
    assert MODULE.has_julia_canvas(capture) is expected
