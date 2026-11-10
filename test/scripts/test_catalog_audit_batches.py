"""Disposable subprocess coverage for the catalog audit's merge boundary."""

import json
from pathlib import Path
import shutil
import subprocess
import sys

import pytest


ROOT = Path(__file__).resolve().parents[2]
MERGER = "scripts/research/doctor/merge_catalog_audit_batches.py"
LAUNCHER = "scripts/run_fractal_render_audit.sh"
IDS = ["mandelbrot", "julia"]


def entry(module_id):
    return {"moduleId": module_id, "catalogId": f"catalog.{module_id}"}


def report(ids):
    return {
        "selectedCount": len(ids),
        "selectedEntries": [entry(i) for i in ids],
        "generated": [{**entry(i), "path": f"{i}.png"} for i in ids],
        "renderMetrics": [
            {**entry(i), "verdict": "pass", "blackPixelRatio": .25,
             "transparentPixelRatio": .1} for i in ids
        ],
        "mathOracle": [{"moduleId": i, "verdict": "pass"} for i in ids],
        "renderHealthSummary": {"thresholds": {"maxBlackPixelRatio": .99}},
    }


@pytest.fixture
def audit(tmp_path):
    # Only these fixture scripts and sentinel executables can be invoked.
    for script in (MERGER, LAUNCHER):
        target = tmp_path / script
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / script, target)
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    for command in ("bash", "find", "wc", "mkdir", "mktemp", "cp", "rm", "sort"):
        (bin_dir / command).symlink_to(shutil.which(command))
    (bin_dir / "python3").symlink_to(sys.executable)
    flutter = bin_dir / "flutter"
    flutter.write_text('#!/usr/bin/env bash\nprintf invoked > "$PWD/flutter-invoked"\nexit 99\n')
    flutter.chmod(0o755)
    (tmp_path / "pubspec.yaml").write_text("fixture: sentinel\n")
    (tmp_path / "shaders").mkdir()
    chunks = tmp_path / "chunks"
    chunks.mkdir()
    (chunks / "catalog.json").write_text(json.dumps(report(IDS)))
    (chunks / "batches.txt").write_text("mandelbrot\njulia\n")
    output = tmp_path / "build/test_output/catalog_thumbs_seeded/thumbnail_report.json"
    output.parent.mkdir(parents=True)
    output.write_text("prior output\n")
    return tmp_path, chunks, output


def run(audit, seam, strict=True, validate_existing=False):
    root, chunks, output = audit
    env = {"PATH": str(root / "bin"), "TMPDIR": str(root),
           "PYTHONDONTWRITEBYTECODE": "1", "CATALOG_AUDIT_RESUME": "true",
           "CATALOG_AUDIT_CHUNKS_DIR": str(chunks),
           "STRICT_CATALOG_THUMBS": str(strict).lower()}
    command = ([sys.executable, MERGER, str(chunks), str(output), "8"]
               if seam == "helper" else [str(root / "bin/bash"), LAUNCHER])
    if validate_existing:
        command.append("--validate-existing")
    return subprocess.run(command, cwd=root, env=env, text=True,
                          capture_output=True, timeout=10)


def put(chunks, name, data):
    (chunks / name).write_text(json.dumps(data) + "\n")


def snapshot(chunks):
    return {p.name: p.read_bytes() for p in chunks.iterdir()}


@pytest.mark.parametrize("seam", ["helper", "shell"])
@pytest.mark.parametrize("case", ["empty-plan", "omitted-id", "duplicate-id", "unexpected-id"])
def test_false_green_coverage_is_rejected(audit, seam, case):
    root, chunks, output = audit
    put(chunks, "batch_0.json", report(["mandelbrot"]))
    put(chunks, "batch_1.json", report(["julia"]))
    if case == "empty-plan":
        (chunks / "batches.txt").write_text("")
    elif case == "omitted-id":
        (chunks / "batches.txt").write_text("mandelbrot\n")
        (chunks / "batch_1.json").unlink()
    else:
        put(chunks, "batch_1.json", report([
            "mandelbrot" if case == "duplicate-id" else "core.phoenix"
        ]))
    assert_rejected(audit, seam)


def assert_rejected(audit, seam, diagnostic="coverage"):
    root, chunks, output = audit
    before = snapshot(chunks)
    result = run(audit, seam)
    assert result.returncode != 0, result.stdout
    assert diagnostic.lower() in result.stderr.lower(), result.stderr
    assert "[fractal-audit] merged" not in result.stdout
    assert output.read_text() == "prior output\n"
    assert snapshot(chunks) == before
    assert not (root / "flutter-invoked").exists()


@pytest.mark.parametrize("seam", ["helper", "shell"])
@pytest.mark.parametrize("case", [
    "catalog-json", "catalog-object", "catalog-selection", "empty-selection",
    "duplicate-selection", "bad-module-id", "empty-plan-id", "duplicate-plan",
    "report-json", "report-selection", "wrong-selection", "selected-count",
    "list-shape", "record-shape", "outcome-id-shape", "duplicate-outcome",
    "unknown-outcome", "missing-outcome", "missing-metric", "duplicate-metric",
    "unknown-metric", "catalog-id", "outcome-catalog-id", "metric-catalog-id",
    "global-plugin-skip", "interrupted-plugin-skip", "unknown-diagnostic",
])
def test_malformed_or_incomplete_records_fail_closed(audit, seam, case):
    _, chunks, _ = audit
    (chunks / "batches.txt").write_text("mandelbrot,julia\n")
    data = report(IDS)
    catalog = report(IDS)
    if case == "catalog-object":
        catalog = []
    elif case == "catalog-selection":
        catalog["selectedEntries"] = {}
    elif case == "empty-selection":
        catalog["selectedEntries"] = []
    elif case == "duplicate-selection":
        catalog["selectedEntries"][1] = entry(IDS[0])
    elif case == "bad-module-id":
        catalog["selectedEntries"][0]["moduleId"] = 7
    elif case == "empty-plan-id":
        (chunks / "batches.txt").write_text("mandelbrot,,julia\n")
    elif case == "duplicate-plan":
        (chunks / "batches.txt").write_text("mandelbrot,mandelbrot\n")
    elif case == "report-selection":
        data["selectedEntries"] = [None]
    elif case == "wrong-selection":
        data["selectedEntries"][1] = entry("core.phoenix")
    elif case == "selected-count":
        data["selectedCount"] = 99
    elif case == "list-shape":
        data["qualityWarnings"] = {}
    elif case == "record-shape":
        data["generated"] = ["mandelbrot", "julia"]
    elif case == "outcome-id-shape":
        data["generated"][0]["moduleId"] = []
    elif case == "duplicate-outcome":
        data["generated"][1] = entry(IDS[0])
    elif case == "unknown-outcome":
        data["generated"][1] = entry("core.phoenix")
    elif case == "missing-outcome":
        data["generated"].pop()
    elif case == "missing-metric":
        data["renderMetrics"].pop()
    elif case == "duplicate-metric":
        data["renderMetrics"][1] = data["renderMetrics"][0]
    elif case == "unknown-metric":
        data["renderMetrics"][1] = entry("core.phoenix")
    elif case == "catalog-id":
        data["selectedEntries"][0]["catalogId"] = "wrong"
    elif case in ("outcome-catalog-id", "metric-catalog-id"):
        key = "generated" if case == "outcome-catalog-id" else "renderMetrics"
        data[key][0]["catalogId"] = "wrong"
    elif case in ("global-plugin-skip", "interrupted-plugin-skip"):
        data["generated"] = []
        data["renderMetrics"] = []
        data["skipped"] = [{"reason": "Screenshot plugin unavailable", "error": "MissingPluginException"}]
        if case == "interrupted-plugin-skip":
            data["skipped"][0].update(entry(IDS[0]))
    elif case == "unknown-diagnostic":
        data["flutterErrors"] = [{**entry("core.phoenix"), "errors": ["error"]}]
    put(chunks, "catalog.json", catalog)
    put(chunks, "batch_0.json", data)
    if case in ("catalog-json", "report-json"):
        (chunks / ("catalog.json" if case == "catalog-json" else "batch_0.json")).write_text('{"unfinished":')
    assert_rejected(audit, seam)


@pytest.mark.parametrize("seam", ["helper", "shell"])
@pytest.mark.parametrize("case", ["partial-retry", "extra-retry", "mixed", "extra-batch", "bad-filename", "wrong-retry-selection"])
def test_ambiguous_or_partial_batch_evidence_is_rejected(audit, seam, case):
    _, chunks, _ = audit
    (chunks / "batches.txt").write_text("mandelbrot,julia\n")
    if case in ("partial-retry", "extra-retry", "wrong-retry-selection"):
        put(chunks, "batch_0_0.json", report([IDS[0]]))
        if case != "partial-retry":
            put(chunks, "batch_0_1.json", report([IDS[1]]))
        if case == "extra-retry":
            put(chunks, "batch_0_2.json", report([IDS[1]]))
        if case == "wrong-retry-selection":
            put(chunks, "batch_0_1.json", report([IDS[0]]))
    else:
        put(chunks, "batch_0.json", report(IDS))
        extra = {"mixed": "batch_0_0.json", "extra-batch": "batch_1.json",
                 "bad-filename": "batch_stale.json"}[case]
        put(chunks, extra, report([IDS[0]]))
    assert_rejected(audit, seam)


@pytest.mark.parametrize("missing", ["all", "one"])
def test_absent_reports_are_not_complete_coverage(audit, missing):
    _, chunks, output = audit
    if missing == "one":
        put(chunks, "batch_0.json", report([IDS[0]]))
    # Preflight permits wholly unstarted batches so a real capture can resume.
    result = run(audit, "helper", validate_existing=True)
    assert result.returncode == 0, result.stderr
    assert result.stdout == ""
    assert output.read_text() == "prior output\n"
    assert_rejected(audit, "helper", "missing batch evidence")


@pytest.mark.parametrize("seam", ["helper", "shell"])
@pytest.mark.parametrize("mode", ["aggregate", "retry"])
def test_complete_evidence_merges_in_numeric_order(audit, seam, mode):
    root, chunks, output = audit
    ids = [f"module.{i}" for i in range(12)]
    put(chunks, "catalog.json", report(ids))
    (chunks / "batches.txt").write_text(
        ("\n".join(ids) if mode == "aggregate" else ",".join(ids)) + "\n"
    )
    names = []
    for i, module_id in enumerate(ids):
        name = f"batch_{i}.json" if mode == "aggregate" else f"batch_0_{i}.json"
        data = report([module_id])
        for key in ("performance", "launchVisualMetrics", "flutterErrors"):
            data[key] = [{**entry(module_id), "diagnostic": key}]
        # Repeat diagnostics without confusing them with unique capture outcomes.
        data["flutterErrors"] *= 2
        if i == 0:
            data["renderMetrics"][0]["blackPixelRatio"] = .75
            data["mathOracle"][0]["verdict"] = "skipped"
        if i == 1:
            data["mathOracle"][0]["verdict"] = "fail"
        put(chunks, name, data)
        names.append(str(chunks / name))
    before = snapshot(chunks)
    result = run(audit, seam)
    assert result.returncode == 0, result.stderr
    merged = json.loads(output.read_text())
    assert merged["batchReports"] == names
    assert merged["selectedEntries"] == [entry(i) for i in ids]
    for key in ("generated", "renderMetrics", "mathOracle", "performance", "launchVisualMetrics"):
        assert [r["moduleId"] for r in merged[key]] == ids
    assert len(merged["flutterErrors"]) == 24
    assert merged["renderHealthSummary"] == {
        "selectedCount": 12, "evaluated": 12, "pass": 12, "allBlack": 0,
        "mostlyBlack": 0, "transparent": 0, "lowColor": 0, "flat": 0, "blank": 0,
        "maxBlackPixelRatio": .75, "maxTransparentPixelRatio": .1,
        "thresholds": {"maxBlackPixelRatio": .99},
    }
    assert merged["mathOracleSummary"] == {
        "selectedCount": 12, "evaluated": 12, "pass": 10, "fail": 1, "skipped": 1,
    }
    assert merged["isolatedBatches"] is True
    assert merged["batchSize"] == 8
    assert snapshot(chunks) == before
    assert not (root / "flutter-invoked").exists()


@pytest.mark.parametrize("problem", ["failed", "skipped", "qualityWarnings"])
def test_complete_diagnostics_merge_and_preserve_shell_strict_failure(audit, problem):
    root, chunks, output = audit
    (chunks / "batches.txt").write_text("mandelbrot,julia\n")
    data = report(IDS)
    diagnostic = {**entry(IDS[1]), "reason": "real capture problem", "error": "original error"}
    data[problem] = [diagnostic]
    if problem != "qualityWarnings":
        data["generated"].pop()
        data["renderMetrics"].pop()
        data["mathOracle"].pop()
    put(chunks, "batch_0.json", data)
    before = snapshot(chunks)
    for seam, strict in [("helper", True), ("shell", False), ("shell", True)]:
        result = run(audit, seam, strict=strict)
        if seam == "shell" and strict:
            assert result.returncode != 0
            assert "STRICT_CATALOG_THUMBS rejects" in result.stderr
        else:
            assert result.returncode == 0, result.stderr
        merged = json.loads(output.read_text())
        assert merged[problem] == [diagnostic]
        count = 2 if problem == "qualityWarnings" else 1
        assert merged["renderHealthSummary"]["evaluated"] == count
        assert merged["mathOracleSummary"]["evaluated"] == count
        assert snapshot(chunks) == before
        assert not (root / "flutter-invoked").exists()
