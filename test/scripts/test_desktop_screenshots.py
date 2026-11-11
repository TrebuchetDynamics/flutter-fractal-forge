"""Exercise only collection: private checkouts and sentinel launchers, no native tools."""

import json
import os
from pathlib import Path
import shutil
import subprocess

import pytest


WRAPPER = Path(__file__).resolve().parents[2] / "scripts/desktop-screenshots.sh"


@pytest.fixture
def checkout(tmp_path):
    root = tmp_path / "checkout with spaces"
    (root / "scripts").mkdir(parents=True)
    (root / "build").mkdir()
    shutil.copy2(WRAPPER, root / "scripts/desktop-screenshots.sh")
    bin_dir = root / "sentinel bin"
    bin_dir.mkdir()
    # Deliberately exclude every native launcher from PATH. Intercept login bash
    # too, so host profile files cannot restore a real Flutter/Xvfb executable.
    for tool in ("dirname", "mkdir", "find", "wc", "tr", "cp", "basename", "ls", "sed", "stat", "sort"):
        (bin_dir / tool).symlink_to(shutil.which(tool))
    bash = bin_dir / "bash"
    bash.write_text('#!/bin/bash\nif [[ ${1:-} == -lc ]]; then shift; exec /bin/bash -c "$@"; fi\nexec /bin/bash "$@"\n')
    bash.chmod(0o755)
    flutter = bin_dir / "flutter"
    flutter.write_text('''#!/usr/bin/python3
import json, os, sys
from pathlib import Path
Path("invocation.json").write_text(json.dumps(sys.argv[1:]))
for name, content in json.loads(os.environ["CAPTURES"]).items():
    path = Path(name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content.encode())
sys.exit(int(os.environ["CAPTURE_EXIT"]))
''')
    flutter.chmod(0o755)

    def run(captures=None, *, headless=True, exit_code=0, custom=False, overrides=True):
        xvfb = bin_dir / "xvfb-run"
        if headless:
            xvfb.write_text('#!/bin/bash\nprintf sentinel > headless-used\n[[ "$1" == -a && "$2" == -s && "$3" == "-screen 0 1080x1920x24" ]] || exit 99\nshift 3\nexec "$@"\n')
            xvfb.chmod(0o755)
        elif xvfb.exists():
            xvfb.unlink()
        env = {**os.environ, "PATH": str(bin_dir), "CAPTURES": json.dumps(captures or {}),
               "CAPTURE_EXIT": str(exit_code), "DEVICE_ID": "sentinel device",
               "TEST_FILE": "integration_test/custom suite.dart"}
        env.pop("OUT_DIR", None)
        if not overrides:
            env.pop("DEVICE_ID")
            env.pop("TEST_FILE")
        if custom:
            env["OUT_DIR"] = str(root / "custom output")
        result = subprocess.run(
            ["/bin/bash", str(root / "scripts/desktop-screenshots.sh")],
            cwd=root, env=env, capture_output=True, text=True, timeout=10,
        )
        assert json.loads((root / "invocation.json").read_text()) == [
            "test", "integration_test/custom suite.dart" if overrides else
            "integration_test/screenshots/full_screenshots_test.dart",
            "-d", "sentinel device" if overrides else "linux",
            "--reporter", "expanded", "--dart-define=FORCE_GPU_RENDER=true",
        ]
        assert (root / "headless-used").exists() == headless
        return result

    return root, run


@pytest.mark.parametrize("source,custom", [
    ("screenshots/01_catalog.png", False),
    ("screenshots/01_catalog.png", True),
    ("build/nested path/screenshots/01_catalog.png", True),
])
def test_collect_current_capture(checkout, source, custom):
    root, run = checkout
    result = run({source: "new capture"}, custom=custom,
                 headless=not custom, overrides=custom)
    assert result.returncode == 0, result.stdout + result.stderr
    output = root / ("custom output" if custom else "screenshots") / "01_catalog.png"
    assert output.read_bytes() == b"new capture"
    assert "Collected 1" in result.stdout
    assert "01_catalog.png" in result.stdout
    assert "same file" not in result.stderr
    # An unchanged output from this successful run is not evidence next time.
    repeated = run(custom=custom, headless=not custom, overrides=custom)
    assert repeated.returncode != 0
    assert "No new suite screenshots" in repeated.stdout + repeated.stderr
    assert "Done" not in repeated.stdout
    assert output.read_bytes() == b"new capture"


@pytest.mark.parametrize("old_path,new_files", [
    (None, {}),
    (None, {"build/icon.png": "unrelated"}),
    ("build/old/01_catalog.png", {}),
    ("screenshots/01_catalog.png", {}),
])
def test_no_current_capture_fails_repeatedly(checkout, old_path, new_files):
    root, run = checkout
    if old_path:
        path = root / old_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"old capture")
    (root / "screenshots").mkdir(exist_ok=True)
    previous = root / "screenshots/keep.txt"
    previous.write_bytes(b"keep")
    for _ in range(2):
        result = run(new_files)
        assert result.returncode != 0
        assert "No new suite screenshots" in result.stdout + result.stderr
        assert "Done" not in result.stdout
        assert "keep.txt" not in result.stdout
        assert previous.read_bytes() == b"keep"
        for name, content in new_files.items():
            assert (root / name).read_bytes() == content.encode()
        if old_path:
            assert (root / old_path).read_bytes() == b"old capture"


def test_stale_fallback_cannot_replace_rewritten_direct_capture(checkout):
    root, run = checkout
    for name in ("build/old/01_catalog.png", "screenshots/01_catalog.png"):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"old")
    result = run({"screenshots/01_catalog.png": "new"})
    assert result.returncode == 0, result.stdout + result.stderr
    assert (root / "screenshots/01_catalog.png").read_bytes() == b"new"
    assert (root / "build/old/01_catalog.png").read_bytes() == b"old"
    assert "Collected 1" in result.stdout


@pytest.mark.parametrize("direct", [True, False])
def test_current_duplicates_have_visible_stable_winner(checkout, direct):
    root, run = checkout
    captures = {"build/z/01_catalog.png": "z", "build/a/01_catalog.png": "a"}
    if direct:
        captures["screenshots/01_catalog.png"] = "direct"
    result = run(captures, custom=True)
    assert result.returncode == 0, result.stdout + result.stderr
    assert (root / "custom output/01_catalog.png").read_text() == ("direct" if direct else "a")
    assert "Duplicate" in result.stdout + result.stderr
    assert "Collected 1" in result.stdout


@pytest.mark.parametrize("headless", [True, False])
def test_capture_failure_propagates_without_collection(checkout, headless):
    root, run = checkout
    result = run({"build/01_catalog.png": "partial"}, headless=headless, exit_code=7)
    assert result.returncode == 7
    assert not (root / "screenshots/01_catalog.png").exists()
    assert "Done" not in result.stdout
    assert "Collected" not in result.stdout
