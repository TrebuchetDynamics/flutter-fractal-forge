# Fractal Research Pipeline Tooling

Python tooling for the fractal catalog research pipeline.
The former pipeline-design snapshot is no longer tracked. Use the [actual CLI](forge.py), [research registry](../../docs/catalog/fractal_registry.yaml) and [documentation/workflow owners](../../docs/README.md#queues-and-history). Setup below is optional standalone setup, not permission for offline workers to install packages; use the [provisioned offline gate](../../AGENTS.md#common-offline-integration-gate) for repository checks.

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
pytest test/research -v
```
