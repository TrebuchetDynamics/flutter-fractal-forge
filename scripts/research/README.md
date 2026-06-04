# Fractal Research Pipeline Tooling

Python tooling for the fractal catalog research pipeline.
See `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md`.

## Install

```bash
python3 -m venv .venv-research
source .venv-research/bin/activate
pip install -r scripts/research/requirements.txt
```

## Run

```bash
python3 scripts/research/forge.py --help
```

Validate registry invariants:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor
```

Audit the app-facing catalog admission seam (shader declarations, Dart catalog
shader paths, and implemented registry shader paths):

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --app-catalog
```

Use strict mode when the current app-catalog drift has been cleaned up and the
audit should become a failing CI gate:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog
```

## Test

```bash
pytest tests/research -v
```
