import base64
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import zlib

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "run_state_session_smoke.py"
spec = importlib.util.spec_from_file_location("state_session_smoke", SCRIPT)
smoke = importlib.util.module_from_spec(spec)
spec.loader.exec_module(smoke)


@pytest.mark.parametrize("extended", [False, True, "trajectory"])
def test_projection_preserves_complete_source_records_and_provenance(extended):
    trajectory, extended = extended == "trajectory", extended is True
    inputs = smoke.fixture_inputs(extended=extended, trajectory=trajectory)
    assert inputs == smoke.fixture_inputs(extended=extended, trajectory=trajectory)
    ids = smoke.TRAJECTORY_MODULE_IDS if trajectory else (smoke.EXTENDED_MODULE_IDS if extended else smoke.MODULE_IDS)
    target = ("rust_state_trajectory_smoke_test.dart" if trajectory else
              ("rust_state_extended_smoke_test.dart" if extended else "rust_state_session_smoke_test.dart"))
    dart = (smoke.ROOT / "integration_test/migration" / target).read_text()
    for kind, projected in inputs.items():
        path = f"migration/baseline/{kind}.json"
        raw = (smoke.ROOT / path).read_bytes()
        # NumberToken equality includes the original lexical number representation.
        load = lambda data: json.loads(data, parse_int=smoke.NumberToken,
                                       parse_float=smoke.NumberToken)
        original, derived = load(raw), load(projected)
        key = "id" if kind == "modules" else "module_id"
        expected = [r for r in original["payload"]["records"] if r[key] in ids]
        assert len(expected) == (3 if trajectory else (7 if extended else 4))
        assert smoke.compact(derived["payload"]["records"]) == smoke.compact(expected)
        assert [r[key] for r in expected] == [r[key] for r in derived["payload"]["records"]]
        assert {k: v for k, v in derived.items() if k not in ("payload", "provenance")} == {
            k: v for k, v in original.items() if k not in ("payload", "provenance")}
        sources = {path: hashlib.sha256(raw).hexdigest()}
        assert derived["provenance"] == {
            **{k: original["provenance"][k] for k in ("flutter_version", "hash_algorithm", "registry_mode")},
            "sources": sources,
            "source_set_sha256": hashlib.sha256(smoke.compact(sources).encode()).hexdigest(),
            "fixture_projection": {
                "selected_ids": list(ids),
                "original_source_set_sha256": original["provenance"]["source_set_sha256"],
            },
        }
        assert hashlib.sha256(projected).hexdigest() in dart


@pytest.mark.parametrize("extended", [False, True, "trajectory"])
def test_argv_protocol_round_trip_and_command_exit(tmp_path, extended):
    trajectory, extended = extended == "trajectory", extended is True
    output = tmp_path / "argv.json"
    command = [sys.executable, "-c",
               "import json,sys; open(sys.argv[1], 'w').write(json.dumps(sys.argv[2:])); sys.exit(19)",
               str(output), "literal ; $(never-run)", "--dart-define=UNICODE=λ"]
    mode = ["--trajectory"] if trajectory else (["--extended"] if extended else [])
    result = subprocess.run([sys.executable, str(SCRIPT), *mode, "--", *command], capture_output=True)
    assert result.returncode == 19, result.stderr
    argv = json.loads(output.read_text())
    assert argv[:2] == command[-2:]
    defines = [arg.split("=", 1)[1] for arg in argv[1:]]
    inputs = smoke.fixture_inputs(extended=extended, trajectory=trajectory)
    assert len(defines) == 5
    for define, (kind, raw) in zip(defines[1:], inputs.items()):
        key, encoded = define.split("=", 1)
        assert key == f"STATE_SESSION_{kind.upper()}"
        decoded = zlib.decompress(base64.b64decode(encoded, validate=True))
        assert decoded == raw
        assert hashlib.sha256(decoded).hexdigest().encode() in result.stdout
    actual = b",".join(base64.b64encode(d.encode()) for d in defines)
    assert smoke.flutter_encoded(defines) == actual
    assert f"aggregate: {len(actual)}/32768".encode() in result.stdout


@pytest.mark.parametrize("extended", [False, True, "trajectory"])
def test_aggregate_budget_rejects_without_launch_or_truncation(monkeypatch, extended):
    trajectory, extended = extended == "trajectory", extended is True
    launched = []
    monkeypatch.setattr(smoke.subprocess, "run", lambda argv, **kw: launched.append(argv) or
                        subprocess.CompletedProcess(argv, 0))
    monkeypatch.delenv("DART_DEFINES", raising=False)
    # Exercise the inclusive boundary and actual budget with both supported flag forms.
    base = len(smoke.flutter_encoded([
        f"STATE_SESSION_{k.upper()}={base64.b64encode(zlib.compress(v, 9)).decode()}"
        for k, v in smoke.fixture_inputs(extended=extended, trajectory=trajectory).items()]))
    monkeypatch.setattr(smoke, "MAX_ENCODED_BYTES", base)
    assert smoke.launch(["command"], extended=extended, trajectory=trajectory) == 0
    monkeypatch.setattr(smoke, "MAX_ENCODED_BYTES", base - 1)
    with pytest.raises(ValueError, match="exceeds"):
        smoke.launch(["command"], extended=extended, trajectory=trajectory)
    monkeypatch.setattr(smoke, "MAX_ENCODED_BYTES", 32768)
    for flag in (["--dart-define=" + "X=" + "λ" * 13000],
                 ["--dart-define", "X=" + "x" * 26000],
                 ["--DartDefines=X=" + "x" * 26000],
                 ["--DartDefines", "X=" + "x" * 26000],
                 ["-D", "X=" + "x" * 26000],
                 ["-DX=" + "x" * 26000]):
        with pytest.raises(ValueError, match="exceeds"):
            smoke.launch(["command", *flag], extended=extended, trajectory=trajectory)
    assert len(launched) == 1


@pytest.mark.parametrize("extended", [False, True, "trajectory"])
def test_invalid_inputs_and_launch_errors_fail_closed(tmp_path, monkeypatch, extended):
    trajectory, extended = extended == "trajectory", extended is True
    raw = (smoke.ROOT / "migration/baseline/modules.json").read_bytes()
    for tampered in (b"{}", raw[:len(raw) // 2], raw + b" "):
        with pytest.raises(ValueError, match="SHA-256 mismatch"):
            smoke.project("modules", tampered, extended=extended, trajectory=trajectory)
    monkeypatch.setattr(smoke, "ROOT", tmp_path)
    with pytest.raises(FileNotFoundError):
        smoke.fixture_inputs(extended=extended, trajectory=trajectory)
    mode = ["--trajectory"] if trajectory else (["--extended"] if extended else [])
    for argv in ([], ["--", "missing-executable"],
                 ["--", "command", "--dart-define=STATE_SESSION_MODULES=override"],
                 ["--", "command", "-DSTATE_SESSION_MODULES=override"],
                 ["--", "command", "--DartDefines=STATE_SESSION_MODULES=override"],
                 ["--", "command", "--dart-define-from-file=hidden.json"],
                 ["--", "command", "--dart-define"]):
        result = subprocess.run([sys.executable, str(SCRIPT), *mode, *argv], capture_output=True)
        assert result.returncode == 2
        assert b"state-session fixture:" in result.stderr
    if trajectory:
        for invalid in ("missing", "duplicate"):
            envelope = json.loads(raw)
            records = envelope["payload"]["records"]
            selected = next(r for r in records if r["id"] in smoke.TRAJECTORY_MODULE_IDS)
            if invalid == "missing":
                records.remove(selected)
            else:
                records.append(selected)
            data = json.dumps(envelope).encode()
            monkeypatch.setitem(smoke.ORIGINAL_SHA256, "modules", hashlib.sha256(data).hexdigest())
            with pytest.raises(ValueError, match="missing or duplicate"):
                smoke.project("modules", data, trajectory=True)
        with pytest.raises(ValueError, match="mutually exclusive"):
            smoke.fixture_inputs(extended=True, trajectory=True)
        result = subprocess.run([sys.executable, str(SCRIPT), "--extended", "--trajectory",
                                 "--", "command"], capture_output=True)
        assert result.returncode == 2
    monkeypatch.setenv("DART_DEFINES", "inherited")
    with pytest.raises(ValueError, match="inherited DART_DEFINES refused"):
        smoke.launch(["command"], extended=extended, trajectory=trajectory)
