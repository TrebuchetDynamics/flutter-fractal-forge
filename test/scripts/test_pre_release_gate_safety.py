"""Exercise the real gate with isolated command doubles; never contact Android."""

import json
import os
from pathlib import Path
import subprocess
import textwrap

import pytest


ROOT = Path(__file__).resolve().parents[2]
DEVICE = "disposable-emulator-5554"


@pytest.fixture
def gate(tmp_path):
    (tmp_path / "scripts").mkdir()
    (tmp_path / "scripts/pre-release-gate.sh").write_bytes(
        (ROOT / "scripts/pre-release-gate.sh").read_bytes()
    )
    (tmp_path / "pubspec.yaml").write_text("version: 1.2.3+45\n")
    lifecycle = tmp_path / "integration_test/flows/lifecycle_restoration_test.dart"
    lifecycle.parent.mkdir(parents=True)
    lifecycle.touch()
    commands = tmp_path / "commands.jsonl"
    installed = tmp_path / "production-app-and-user-data"
    installed.write_text("release-signed app with irreplaceable presets")
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    double = bin_dir / "double"
    double.write_text(
        "#!/usr/bin/python3\n" + textwrap.dedent('''\
        import json, os, pathlib, sys
        name = pathlib.Path(sys.argv[0]).name
        args = sys.argv[1:]
        with open(os.environ["COMMANDS"], "a") as log:
            log.write(json.dumps([name, *args]) + "\\n")
        installed = pathlib.Path(os.environ["INSTALLED"])
        if name == "adb":
            if args[:2] == ["-s", os.environ["TEST_DEVICE"]]:
                args = args[2:]
            if args == ["shell", "getprop", "ro.product.cpu.abi"]:
                print("x86_64")
            elif args[:3] == ["shell", "pm", "path"] and installed.exists():
                print("package:/data/app/release-signed/base.apk")
            elif args[:1] == ["uninstall"]:
                installed.unlink(missing_ok=True)
            elif args[:1] == ["install"]:
                installed.write_text("disposable release artifact")
            elif args[:4] == ["shell", "settings", "get", "global"]:
                print("1")
            elif args == ["shell", "dumpsys", "activity", "activities"]:
                print("ResumedActivity: ActivityRecord{123 u0 com.trebuchetdynamics.fractal.forge/.MainActivity t1}")
            elif args[:2] == ["exec-out", "uiautomator"]:
                print('<hierarchy text="Julia Controls"/>')
        elif name == "flutter":
            if "integration_test" in " ".join(args):
                # Flutter may uninstall/reinstall the production package itself.
                installed.write_text("debug-signed instrumented package")
            if os.environ.get("FAIL_GATE", "NEVER") in " ".join(args):
                sys.exit(17)
        elif name == "timeout":
            # No soak evidence: the real gate must reject this fast/empty run.
            sys.exit(0)
        ''')
    )
    double.chmod(0o755)
    for name in ("adb", "flutter", "waydroid", "sleep", "timeout"):
        (bin_dir / name).symlink_to(double)
    env = os.environ.copy()
    for name in ("ANDROID_DEVICE", "FLUTTER_BIN", "RELEASE_BUILD_NAME", "RELEASE_BUILD_NUMBER"):
        env.pop(name, None)
    env.update(PATH=f"{bin_dir}:/usr/bin:/bin", COMMANDS=str(commands),
               INSTALLED=str(installed), TEST_DEVICE=DEVICE)

    def run(*args, fail_gate=None, android_device=None):
        run_env = env.copy()
        if android_device is not None:
            run_env["ANDROID_DEVICE"] = android_device
        if fail_gate:
            run_env["FAIL_GATE"] = fail_gate
        result = subprocess.run(
            ["bash", str(tmp_path / "scripts/pre-release-gate.sh"),
             "--log-dir", str(tmp_path / "evidence"), *args],
            cwd=tmp_path, env=run_env, text=True, capture_output=True, timeout=20,
        )
        calls = [json.loads(line) for line in commands.read_text().splitlines()] if commands.exists() else []
        return result, calls, installed

    return run


@pytest.mark.parametrize("args", [[], ["--device", DEVICE], ["--skip-host", "--device", DEVICE]])
def test_default_refuses_before_touching_installed_production_app(gate, args):
    result, calls, installed = gate(*args)
    assert result.returncode != 0
    assert installed.read_text() == "release-signed app with irreplaceable presets"
    assert calls == [], "Refusal must precede Flutter, ADB, and EXIT cleanup"
    assert "disposable" in result.stderr.lower()
    assert not (installed.parent / "evidence").exists()


@pytest.mark.parametrize("args", [
    ["--disposable-device", DEVICE],
    ["--device", DEVICE, "--disposable-device", "another-device"],
    ["--device", DEVICE, "--disposable-device", ""],
])
def test_opt_in_must_name_the_explicit_selected_device(gate, args):
    result, calls, installed = gate(*args)
    assert result.returncode != 0
    assert calls == []
    assert installed.read_text() == "release-signed app with irreplaceable presets"


@pytest.mark.parametrize("args", [
    ["--help"], ["--dry-run"], ["--dry-run", "--device", DEVICE],
    ["--dry-run", "--device", DEVICE, "--disposable-device", DEVICE],
])
def test_help_and_dry_run_execute_no_commands(gate, args):
    result, calls, installed = gate(*args)
    assert result.returncode == 0, result.stderr
    assert calls == []
    assert installed.read_text() == "release-signed app with irreplaceable presets"
    assert "disposable" in result.stdout.lower()
    assert not (installed.parent / "evidence").exists()
    if "--dry-run" in args:
        assert "not qualification evidence" in result.stdout.lower()


@pytest.mark.parametrize("host_gate, expected", [
    ("analyze", [["flutter", "analyze"]]),
    ("test", [["flutter", "analyze"], ["flutter", "test"]]),
])
def test_host_failure_does_not_trigger_device_cleanup(gate, host_gate, expected):
    result, calls, installed = gate("--device", DEVICE, "--disposable-device", DEVICE,
                                  fail_gate=host_gate)
    assert result.returncode == 17
    assert calls == expected
    assert installed.read_text() == "release-signed app with irreplaceable presets"


@pytest.mark.parametrize("failing_test", [
    "--concurrency=1", "catalog_thumbnail_performance_test.dart",
    "lifecycle_restoration_test.dart", "integration_test/flows/critical_journey_test.dart -d",
    "build apk",
])
def test_disposable_opt_in_still_propagates_integration_failures(gate, failing_test):
    result, calls, _ = gate("--device", DEVICE, "--disposable-device", DEVICE,
                            fail_gate=failing_test)
    assert result.returncode == 17, result.stdout + result.stderr
    assert any(call[0] == "flutter" and failing_test in " ".join(call) for call in calls)
    assert not any(call[0] == "timeout" for call in calls)
    assert "completed successfully" not in result.stdout


def test_android_device_environment_is_not_disposal_consent(gate):
    result, calls, installed = gate(android_device=DEVICE)
    assert result.returncode == 2
    assert calls == []
    assert installed.read_text() == "release-signed app with irreplaceable presets"


def test_android_device_environment_accepts_only_explicit_matching_consent(gate):
    result, calls, installed = gate(f"--disposable-device={DEVICE}",
                                    android_device=DEVICE, fail_gate="analyze")
    assert result.returncode == 17
    assert calls == [["flutter", "analyze"]]
    assert installed.read_text() == "release-signed app with irreplaceable presets"


def test_disposable_route_runs_mandatory_gates_and_rejects_missing_soak(gate):
    result, calls, _ = gate("--device", DEVICE, "--disposable-device", DEVICE)
    assert result.returncode != 0
    assert "Soak ended without the expected wall-clock timeout" in result.stderr
    flutter = [call[1:] for call in calls if call[0] == "flutter"]
    assert flutter[:2] == [["analyze"], ["test"]]
    for test in ("user_flows_test.dart", "critical_journey_test.dart", "render_validation_test.dart",
                 "shader_family_validation_test.dart", "perf_smoke_test.dart", "semantics_audit_test.dart",
                 "catalog_thumbnail_performance_test.dart", "lifecycle_restoration_test.dart"):
        assert any(test in " ".join(call) for call in flutter)
    offline = ["adb", "-s", DEVICE, "shell", "svc", "wifi", "disable"]
    assert offline in calls
    offline_index = calls.index(offline)
    assert any(call[0] == "flutter" and "critical_journey_test.dart" in " ".join(call)
               for call in calls[offline_index + 1:])
    assert sum(call == ["adb", "-s", DEVICE, "install", "build/app/outputs/flutter-apk/app-release.apk"]
               for call in calls) == 2
    assert any(call[:2] == ["timeout", "--signal=INT"] for call in calls)
    assert "completed successfully" not in result.stdout
