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

## Test

```bash
pytest tests/research -v
```
