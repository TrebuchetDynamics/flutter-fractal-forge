#!/usr/bin/env python3
"""Launch a command with source-bound, four-module native fixture inputs only."""

import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import zlib

ROOT = Path(__file__).resolve().parents[2]
MODULE_IDS = ("mandelbrot", "julia", "cantor_set", "recursive_sine_sphere")
ORIGINAL_SHA256 = {
    "modules": "571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3",
    "parameters": "5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517",
    "presets": "318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e",
    "capabilities": "5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa",
}
MAX_ENCODED_BYTES = 32768
PREFIX = "STATE_SESSION_"


class NumberToken(str):
    """Keep JSON number spelling without binary64 conversion or string coercion."""


def compact(value):
    if isinstance(value, NumberToken):
        return str(value)
    if isinstance(value, dict):
        return "{" + ",".join(
            json.dumps(key) + ":" + compact(value[key]) for key in sorted(value)
        ) + "}"
    if isinstance(value, list):
        return "[" + ",".join(map(compact, value)) + "]"
    return json.dumps(value, ensure_ascii=False, allow_nan=False, separators=(",", ":"))


def project(kind, raw):
    digest = hashlib.sha256(raw).hexdigest()
    if digest != ORIGINAL_SHA256[kind]:
        raise ValueError(f"{kind}: original SHA-256 mismatch")
    envelope = json.loads(raw, parse_int=NumberToken, parse_float=NumberToken)
    key = "id" if kind == "modules" else "module_id"
    records = [r for r in envelope["payload"]["records"] if r[key] in MODULE_IDS]
    if len(records) != 4 or {r[key] for r in records} != set(MODULE_IDS):
        raise ValueError(f"{kind}: missing or duplicate selected records")
    envelope["payload"]["records"] = records
    original = envelope["provenance"]
    sources = {f"migration/baseline/{kind}.json": digest}
    envelope["provenance"] = {
        **{k: original[k] for k in ("flutter_version", "hash_algorithm", "registry_mode")},
        "sources": sources,
        "source_set_sha256": hashlib.sha256(compact(sources).encode()).hexdigest(),
        "fixture_projection": {
            "selected_ids": list(MODULE_IDS),
            "original_source_set_sha256": original["source_set_sha256"],
        },
    }
    return compact(envelope).encode("utf-8")


def fixture_inputs():
    return {
        kind: project(kind, (ROOT / "migration/baseline" / f"{kind}.json").read_bytes())
        for kind in ORIGINAL_SHA256
    }


def flutter_encoded(defines):
    # Flutter build_info.dart encodeDartDefines: UTF-8, base64 per define, comma join.
    return b",".join(base64.b64encode(d.encode("utf-8")) for d in defines)


def launch(command):
    if not command:
        raise ValueError("expected -- COMMAND ARGS...")
    supplied = []
    args = iter(command)
    for arg in args:
        if arg.startswith("--dart-define-from-file"):
            raise ValueError("use explicit --dart-define flags so the aggregate is bounded")
        if arg in ("--dart-define", "--DartDefines", "-D"):
            value = next(args, None)
            if value is None:
                raise ValueError("missing --dart-define value")
            supplied.append(value)
        elif arg.startswith(("--dart-define=", "--DartDefines=")):
            supplied.append(arg.split("=", 1)[1])
        elif arg.startswith("-D"):
            supplied.append(arg[2:])
    if any(d.split("=", 1)[0].startswith(PREFIX) for d in supplied):
        raise ValueError("fixture define override refused")
    if os.environ.get("DART_DEFINES"):
        raise ValueError("inherited DART_DEFINES refused; supply explicit flags")
    inputs = fixture_inputs()
    defines = [
        f"{PREFIX}{kind.upper()}={base64.b64encode(zlib.compress(raw, 9)).decode('ascii')}"
        for kind, raw in inputs.items()
    ]
    size = len(flutter_encoded(supplied + defines))
    if size > MAX_ENCODED_BYTES:
        raise ValueError(f"Flutter encoded aggregate {size} exceeds {MAX_ENCODED_BYTES} bytes")
    for kind, raw in inputs.items():
        print(f"{kind}: original={ORIGINAL_SHA256[kind]} "
              f"projected={hashlib.sha256(raw).hexdigest()} bytes={len(raw)}", flush=True)
    print(f"Flutter encoded aggregate: {size}/{MAX_ENCODED_BYTES} bytes", flush=True)
    result = subprocess.run(command + [f"--dart-define={d}" for d in defines], check=False)
    return result.returncode if result.returncode >= 0 else 128 - result.returncode


def main():
    try:
        if len(sys.argv) < 3 or sys.argv[1] != "--":
            raise ValueError("usage: run_state_session_smoke.py -- COMMAND ARGS...")
        return launch(sys.argv[2:])
    except (ValueError, OSError) as error:
        print(f"state-session fixture: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
