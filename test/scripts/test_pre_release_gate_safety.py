"""Exercise the real gate with isolated command doubles; never contact Android."""

import json
import os
import re
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
    (tmp_path / "scripts/verify-restored-viewer.py").write_bytes(
        (ROOT / "scripts/verify-restored-viewer.py").read_bytes()
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
        import json, os, pathlib, sys, time
        name = pathlib.Path(sys.argv[0]).name
        args = sys.argv[1:]
        with open(os.environ["COMMANDS"], "a") as log:
            log.write(json.dumps([name, *args]) + "\\n")
        installed = pathlib.Path(os.environ["INSTALLED"])
        if name == "adb":
            if args[:2] == ["-s", os.environ["TEST_DEVICE"]]:
                args = args[2:]
            if "SOAK_DONE" in os.environ and pathlib.Path(os.environ["SOAK_DONE"]).exists():
                failure = os.environ.get("TERMINAL_FAILURE", "").split(":")
                if args[:3] == ["shell", "dumpsys", failure[0]]:
                    print("collector returned no required marker")
                    sys.exit(19 if failure[-1] == "exit" else 0)
            if args == ["shell", "date", "+%m-%d_%H:%M:%S.000"]:
                print("11-08_00:00:00.000")
            elif args == ["shell", "getprop", "ro.product.cpu.abi"]:
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
            elif args[:3] == ["shell", "dumpsys", "meminfo"]:
                print("TOTAL PSS: 100000")
            elif args[:3] == ["shell", "dumpsys", "gfxinfo"]:
                terminal = pathlib.Path(os.environ["SOAK_DONE"]).exists() if "SOAK_DONE" in os.environ else False
                frames = 20 if terminal or os.environ.get("TERMINAL_FAILURE") or os.environ.get("TERMINAL_JANK") else 4
                jank = os.environ.get("TERMINAL_JANK", "0.00") if terminal else "0.00"
                janky_frames = int(frames * float(jank) / 100)
                print(f"Total frames rendered: {frames}\\nJanky frames: {janky_frames} ({jank}%)")
            elif args == ["shell", "dumpsys", "battery"]:
                print("level: 85")
            elif args == ["shell", "dumpsys", "thermalservice"]:
                print("Thermal Status: 0")
            elif args[:2] == ["exec-out", "uiautomator"]:
                print(os.environ.get("RESTORED_UI", '<hierarchy><node content-desc="Interactive fractal canvas&#10;Julia"/></hierarchy>'))
        elif name == "flutter":
            if "integration_test" in " ".join(args):
                # Flutter may uninstall/reinstall the production package itself.
                installed.write_text("debug-signed instrumented package")
            if os.environ.get("FAIL_GATE", "NEVER") in " ".join(args):
                sys.exit(17)
        elif name == "timeout":
            if "SOAK_DONE" in os.environ:
                # Synchronize with a complete periodic snapshot, then simulate
                # expiry of the unchanged 300-second deadline (no real device).
                ready = pathlib.Path(os.environ["SOAK_READY"])
                deadline = time.monotonic() + 5
                while not ready.exists():
                    assert time.monotonic() < deadline, "periodic sample never completed"
                    time.sleep(0.01)
                pathlib.Path(os.environ["SOAK_DONE"]).touch()
                sys.exit(124)
            # No soak evidence: the real gate must reject this fast/empty run.
            sys.exit(0)
        elif name == "sleep" and args == ["60"] and "SOAK_DONE" in os.environ:
            pathlib.Path(os.environ["SOAK_READY"]).touch()
            while not pathlib.Path(os.environ["SOAK_DONE"]).exists():
                time.sleep(0.01)
            time.sleep(0.1)
        ''')
    )
    # Advance Bash's clock only when the timeout double has completed.
    clock = tmp_path / "clock.bash"
    clock.write_text("set -T\ntrap 'if [[ -e \"$SOAK_DONE\" ]]; then SECONDS=300; else SECONDS=0; fi' DEBUG\n")
    double.chmod(0o755)
    for name in ("adb", "flutter", "waydroid", "sleep", "timeout"):
        (bin_dir / name).symlink_to(double)
    env = os.environ.copy()
    for name in ("ANDROID_DEVICE", "FLUTTER_BIN", "RELEASE_BUILD_NAME", "RELEASE_BUILD_NUMBER"):
        env.pop(name, None)
    env.update(PATH=f"{bin_dir}:/usr/bin:/bin", COMMANDS=str(commands),
               INSTALLED=str(installed), TEST_DEVICE=DEVICE)

    def run(*args, fail_gate=None, android_device=None, restored_ui=None,
            complete_soak=False, terminal_failure=None, terminal_jank=None,
            through_release=False, scratch_base=None):
        run_env = env.copy()
        if scratch_base is not None:
            scratch_base.mkdir()
            run_env["TMPDIR"] = str(scratch_base)
        if complete_soak:
            subprocess.run(["git", "init", "-q", str(tmp_path)], check=True)
            run_env.update(BASH_ENV=str(clock), SOAK_DONE=str(tmp_path / "soak-done"),
                           SOAK_READY=str(tmp_path / "soak-ready"))
        if terminal_failure:
            run_env["TERMINAL_FAILURE"] = terminal_failure
        if terminal_jank:
            run_env["TERMINAL_JANK"] = terminal_jank
        if restored_ui is not None:
            run_env["RESTORED_UI"] = restored_ui
        if android_device is not None:
            run_env["ANDROID_DEVICE"] = android_device
        if fail_gate:
            run_env["FAIL_GATE"] = fail_gate
        if through_release:
            from test_release_play_pipeline import make_project, release, status_file

            lane = tmp_path / "lane"
            lane.mkdir()
            project, lane_env, _ = make_project(lane)
            for script in ("pre-release-gate.sh", "verify-restored-viewer.py"):
                (project / "scripts" / script).write_bytes((tmp_path / "scripts" / script).read_bytes())
            lane_env.update(run_env)
            result = release(project, lane_env, "--allow-dirty", *args,
                             status=status_file(lane, [], uploaded=[]))
        else:
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
    ["--device", "another-device", f"--device={DEVICE}", "--disposable-device", DEVICE],
    [f"--device=another-device", "--device", DEVICE, "--disposable-device", DEVICE],
    ["--device", DEVICE, "--disposable-device", "another-device", f"--disposable-device={DEVICE}"],
    ["--device", DEVICE, "--disposable-device=another-device", "--disposable-device", DEVICE],
    ["--device", "--disposable-device", "--disposable-device=--disposable-device"],
    ["--device=-s", "--disposable-device=-s"],
    ["--device", "-s", "--disposable-device", "-s"],
    ["--device"], ["--disposable-device"],
    ["--device="], ["--disposable-device="],
    ["--device", "", "--disposable-device", DEVICE],
])
@pytest.mark.parametrize("plan_only", [False, True])
def test_ambiguous_or_missing_device_arguments_refuse_before_commands(gate, args, plan_only):
    result, calls, installed = gate(*args, *(["--dry-run"] if plan_only else []),
                                    fail_gate="analyze")
    assert result.returncode == 2, result.stdout + result.stderr
    assert calls == []
    assert installed.read_text() == "release-signed app with irreplaceable presets"
    assert not (installed.parent / "evidence").exists()


@pytest.mark.parametrize("args", [["--disposable-device=-s"], ["--dry-run"]])
def test_option_like_android_device_environment_refuses_before_commands(gate, args):
    result, calls, installed = gate(*args, android_device="-s", fail_gate="analyze")
    assert result.returncode == 2
    assert calls == []
    assert installed.read_text() == "release-signed app with irreplaceable presets"


def test_identical_repeated_device_arguments_are_unambiguous(gate):
    result, calls, installed = gate(
        "--device", DEVICE, f"--device={DEVICE}",
        "--disposable-device", DEVICE, f"--disposable-device={DEVICE}", fail_gate="analyze",
    )
    assert result.returncode == 17
    assert calls == [["flutter", "analyze"]]
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


@pytest.mark.parametrize("restored_ui", [
    '<hierarchy><node text="Julia"/></hierarchy>',
    '<hierarchy><node text="Edit fractal"/></hierarchy>',
    '<hierarchy><node text="Julia Controls"/></hierarchy>',
    '<hierarchy><node text="Julia Edit fractal"/></hierarchy>',
])
def test_restoration_requires_julia_canvas(gate, restored_ui):
    result, calls, _ = gate("--device", DEVICE, "--disposable-device", DEVICE,
                            restored_ui=restored_ui)
    assert result.returncode != 0
    assert "Process-death restoration did not return to the Julia viewer" in result.stderr
    assert not any(call[0] == "timeout" for call in calls)
    assert not any("lifecycle_restoration_test.dart" in " ".join(call) for call in calls)


@pytest.mark.parametrize("soak_args, expected_deadline", [
    ([], "300s"),
    (["--soak-seconds", "1800"], "1800s"),
], ids=["default-five-minutes", "explicit-thirty-minutes"])
def test_disposable_route_runs_mandatory_gates_and_rejects_missing_soak(
        gate, soak_args, expected_deadline):
    result, calls, _ = gate("--device", DEVICE, "--disposable-device", DEVICE, *soak_args)
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
    assert ["adb", "-s", DEVICE, "shell", "date", "+%m-%d_%H:%M:%S.000"] in calls
    assert not any(call[3:5] == ["logcat", "-c"] for call in calls)
    soak = next(call for call in calls if call[:2] == ["timeout", "--signal=INT"])
    assert soak[3] == expected_deadline
    # Arbitrary keys can bypass the disabled system/navigation categories.
    assert "--pct-anyevent" in soak
    assert soak[soak.index("--pct-anyevent") + 1] == "0"
    assert soak[soak.index("monkey") + 3:soak.index("monkey") + 7] == ["-s", "1", "-v", "-v"]
    assert "completed successfully" not in result.stdout


def test_terminal_snapshot_completes_real_soak_parser(gate):
    result, calls, installed = gate("--device", DEVICE, "--disposable-device", DEVICE,
                                    complete_soak=True)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "Soak final janky frames: 0% (limit 10%)" in result.stdout
    assert "Monkey seed: 1 (fixed); verbosity: -v -v" in result.stdout
    evidence = installed.parent / "evidence"
    for metric in ("memory", "frames", "battery", "thermal"):
        raw = (evidence / f"soak-{metric}.log").read_text()
        assert len(re.findall(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$", raw, re.M)) == 2
    frames = (evidence / "soak-frames.log").read_text()
    assert re.findall(r"Total frames rendered: (\d+)", frames) == ["4", "20"]
    # Exactly one periodic and one terminal framestats collection; the final
    # post-validation evidence command does not request framestats.
    samples = [i for i, call in enumerate(calls) if call[-1:] == ["framestats"]]
    assert len(samples) == 2
    cleanup = [i for i, call in enumerate(calls)
               if call == ["adb", "-s", DEVICE, "shell", "ps", "-A"]]
    assert any(samples[0] < i < samples[1] for i in cleanup)
    timeout = next(call for call in calls if call[0] == "timeout")
    assert timeout[3] == "300s"


@pytest.mark.parametrize("metric", ["meminfo", "gfxinfo", "battery", "thermalservice"])
@pytest.mark.parametrize("failure", ["exit", "marker"])
@pytest.mark.parametrize("external_scratch", [False, True])
def test_terminal_collector_failure_blocks_real_release_upload(
        gate, metric, failure, external_scratch, tmp_path):
    result, calls, installed = gate("--device", DEVICE, "--disposable-device", DEVICE,
                                    complete_soak=True, terminal_failure=f"{metric}:{failure}",
                                    through_release=True,
                                    scratch_base=tmp_path / "ambient-scratch" if external_scratch else None)
    assert result.returncode != 0
    assert "Terminal soak evidence collection failed" in result.stdout + result.stderr
    assert "completed successfully" not in result.stdout
    lane_calls = (installed.parent / "lane/calls.log").read_text()
    assert "offline-gate" in lane_calls
    assert "upload" not in lane_calls
    assert "readback" not in lane_calls
    # An earlier mature success must never mask a failed terminal collector.
    frames_calls = [call for call in calls if call[-1:] == ["framestats"]]
    assert len(frames_calls) == 2
    # Follow the wrapper's reported path: ambient TMPDIR can place evidence
    # outside the lane fixture, just as it does in the real offline pipeline.
    evidence = re.search(r"^\[release-play\] gate evidence dir: (.+)$", result.stderr, re.M)
    assert evidence is not None, result.stderr
    evidence_dir = Path(evidence.group(1))
    if external_scratch:
        assert evidence_dir.is_relative_to(tmp_path / "ambient-scratch")
    raw_frames = (evidence_dir / "device/soak-frames.log").read_text()
    assert "Total frames rendered: 20\nJanky frames: 0 (0.00%)" in raw_frames


def test_terminal_jank_cannot_fall_back_to_earlier_mature_success(gate):
    result, _, installed = gate("--device", DEVICE, "--disposable-device", DEVICE,
                                complete_soak=True, terminal_jank="15.00")
    assert result.returncode != 0
    assert "Final janky frames exceeded 10% (15%)" in result.stderr
    raw = (installed.parent / "evidence/soak-frames.log").read_text()
    assert re.findall(r"Janky frames: .*", raw) == [
        "Janky frames: 0 (0.00%)", "Janky frames: 3 (15.00%)"]
