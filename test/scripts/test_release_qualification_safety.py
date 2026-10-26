"""Fail-closed release adapter checks; no app/device execution."""
import hashlib
import importlib.util
import io
import json
import os
import socket
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("qualification_lanes", ROOT / "scripts/release_platform_lanes.py")
LANES = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(LANES)
IDENTITY = {"version": "1.1.112", "build_number": "112", "commit": "a" * 40,
            "flutter_version": "3.44.6"}
ARTIFACT = {"path": "/sandbox/linux.tar.gz", "sha256": "f" * 64}


def web_archive(directory):
    files = {"index.html": b"<html>", "main.dart.js": b"compiled"}
    manifest = {**IDENTITY, "files": {name: hashlib.sha256(data).hexdigest()
                                     for name, data in files.items()}}
    archive = Path(directory) / "web.tar.gz"
    with tarfile.open(archive, "w:gz") as bundle:
        for name, data in {**files, "release-identity.json": json.dumps(manifest).encode()}.items():
            member = tarfile.TarInfo("web/" + name)
            member.size = len(data)
            bundle.addfile(member, io.BytesIO(data))
    return {"path": str(archive), "sha256": hashlib.sha256(archive.read_bytes()).hexdigest()}


class QualificationSafetyTest(unittest.TestCase):
    def test_fdroid_availability_uses_the_explicit_isolated_tool_not_host_path(self):
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "build-tools").mkdir()
            with mock.patch.dict(os.environ, {"ANDROID_SDK_ROOT": directory,
                                              "FDROID_BIN": "/configured/fdroid-container"}), \
                 mock.patch.object(LANES.shutil, "which", side_effect=lambda name: name if name == "/configured/fdroid-container" else None):
                self.assertIsNone(LANES._host_unavailable("fdroid"))

    def test_device_gate_receives_only_the_explicit_disposable_target_consent(self):
        with tempfile.TemporaryDirectory() as directory, \
             mock.patch.dict(os.environ, {"ANDROID_DEVICE": "dedicated-test-target",
                                           "ANDROID_DISPOSABLE_DEVICE": "dedicated-test-target"}), \
             mock.patch.object(LANES, "_host_unavailable", return_value=None), \
             mock.patch.object(LANES, "verify_artifact_receipts", return_value=[ARTIFACT]), \
             mock.patch.object(LANES, "_android_certificate_check", return_value={"verdict": "passed"}), \
             mock.patch.object(LANES.subprocess, "run", side_effect=[
                 subprocess.CompletedProcess([], 0, stdout="built", stderr=""),
                 subprocess.CompletedProcess([], 1, stdout="fixture device gate failure", stderr="")]) as run:
            result = LANES._produce_lane("android_play", IDENTITY, Path(directory))
        command = run.call_args.args[0]
        self.assertIn("--device", command)
        self.assertIn("--disposable-device", command)
        self.assertEqual(command[command.index("--device") + 1], "dedicated-test-target")
        self.assertEqual(command[command.index("--disposable-device") + 1], "dedicated-test-target")
        self.assertEqual(result["checks"]["android_device_journey"]["verdict"], "failed")

    def test_missing_or_invalid_allocation_never_starts_native_or_web_listeners(self):
        for allocation in (None, "", "abc", "0", "1023", "65437", "65535"):
            with self.subTest(allocation=allocation), tempfile.TemporaryDirectory() as directory:
                environment = dict(os.environ)
                environment.pop("AUTOWORK_PORT_BASE", None)
                if allocation is not None:
                    environment["AUTOWORK_PORT_BASE"] = allocation
                with mock.patch.dict(os.environ, environment, clear=True), \
                     mock.patch.object(LANES.platform, "system", return_value="Linux"), \
                     mock.patch.object(LANES.subprocess, "run") as run, \
                     mock.patch.object(LANES.subprocess, "Popen") as popen:
                    native = LANES.run_native_qualification("linux", IDENTITY, [ARTIFACT])
                    web = LANES._web_qualification(IDENTITY, [web_archive(directory)])
                self.assertTrue(all(row["verdict"] == "unknown" for row in native.values()))
                self.assertTrue(all("allocation" in row["reason"] for row in native.values()))
                self.assertEqual(web["asset_validation"]["verdict"], "passed")
                self.assertEqual(web["browser_journey"]["verdict"], "unknown")
                self.assertEqual(web["saved_data"]["verdict"], "unknown")
                run.assert_not_called()
                popen.assert_not_called()

    def test_browser_zero_exit_without_executed_passing_cases_is_not_qualification(self):
        good = {"stats": {"expected": 1, "unexpected": 0, "flaky": 0, "skipped": 0}, "errors": [],
                "suites": [{"file": "web-image-creation-journey.spec.mjs", "specs": [{"tests": [
                    {"expectedStatus": "passed", "status": "expected", "projectName": "chromium",
                     "results": [{"status": "passed"}]}]}]}]}
        failed_expected = json.loads(json.dumps(good))
        failed_expected["suites"][0]["specs"][0]["tests"][0].update(
            expectedStatus="failed", results=[{"status": "failed"}])
        wrong_spec = json.loads(json.dumps(good))
        wrong_spec["suites"][0]["file"] = "unrelated.spec.mjs"
        reports = [{**good, "suites": []}, failed_expected, wrong_spec, None, "not-json", {},
                   {"stats": {"expected": 0, "unexpected": 0, "flaky": 0, "skipped": 3}},
                   {"stats": {"expected": 1, "unexpected": 1, "flaky": 0, "skipped": 0}},
                   {"stats": {"expected": 1, "unexpected": 0, "flaky": 1, "skipped": 0}}, good]
        for report in reports:
            with self.subTest(report=report), tempfile.TemporaryDirectory() as directory:
                with socket.socket() as probe:
                    probe.bind(("127.0.0.1", 0))
                    port = probe.getsockname()[1]
                self.assertLessEqual(port, 65436, "test fixture needs an OS-assigned port with room for the range")
                def browser(command, **kwargs):
                    path = Path(kwargs["env"]["PLAYWRIGHT_JSON_OUTPUT_FILE"])
                    if report is not None:
                        data = json.loads(json.dumps(report))
                        if report is good:
                            data["suites"][0]["file"] = Path(next(arg for arg in command if arg.endswith('.spec.mjs'))).name
                        path.write_text(data if isinstance(data, str) else json.dumps(data))
                    return subprocess.CompletedProcess(command, 0, stdout="runner exited", stderr="")
                with mock.patch.dict(os.environ, {"AUTOWORK_PORT_BASE": str(port)}), \
                     mock.patch.object(LANES.subprocess, "run", side_effect=browser) as run:
                    checks = LANES._web_qualification(IDENTITY, [web_archive(directory)])
                for name in ("browser_journey", "saved_data"):
                    self.assertEqual(checks[name]["verdict"], "passed" if report is good else "failed")
                    if report is good:
                        self.assertEqual(checks[name]["executed_tests"], 1)
                        self.assertEqual(checks[name]["served_bundle_sha256"], hashlib.sha256(b"compiled").hexdigest())
                self.assertEqual(run.call_count, 2)
                for call in run.call_args_list:
                    self.assertEqual(call.kwargs["env"]["PLAYWRIGHT_SKIP_WEBSERVER"], "1")

    def test_native_exit_zero_requires_bound_official_protocol_and_clean_owned_processes(self):
        for fault in (None, "missing_receipt", "protocol", "callback", "cleanup", "revision",
                      "port", "listener", "source", "sdk", "outside_scratch"):
            with self.subTest(fault=fault), tempfile.TemporaryDirectory() as directory, \
                 tempfile.TemporaryDirectory() as foreign:
                work = Path(foreign if fault == "outside_scratch" else directory) / "native-integration-fixture"
                work.mkdir()
                files = ["integration_test/flows/user_flows_test.dart", "test_driver/integration_test.dart",
                         "scripts/run-native-integration.sh"]
                receipt = {"revision": IDENTITY["commit"], "exit_code": 0, "protocol_success": True,
                           "cleanup": {"remaining_pids": []}, "port_range": [20200, 20299],
                           "listeners": [["tcp", "0100007F", 20200]],
                           "sdk": {"flutterVersion": "3.44.6"},
                           "sha256": {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in files}}
                if fault == "protocol": receipt["protocol_success"] = False
                if fault == "cleanup": receipt["cleanup"]["remaining_pids"] = [12345]
                if fault == "revision": receipt["revision"] = "b" * 40
                if fault == "port": receipt["port_range"] = [20300, 20399]
                if fault == "listener": receipt["listeners"] = [["tcp", "00000000", 20200]]
                if fault == "source": receipt["sha256"][files[0]] = "0" * 64
                if fault == "sdk": receipt["sdk"]["flutterVersion"] = "3.44.2"
                if fault != "missing_receipt":
                    (work / "run.json").write_text(json.dumps(receipt))
                (work / "protocol-success.json").write_text(json.dumps({"allTestsPassed": fault != "callback"}))
                result = subprocess.CompletedProcess([], 0, stdout=f"Native integration evidence: {work}\n", stderr="")
                with mock.patch.dict(os.environ, {"AUTOWORK_PORT_BASE": "20200", "TMPDIR": directory}), \
                     mock.patch.object(LANES.platform, "system", return_value="Linux"), \
                     mock.patch.object(LANES.subprocess, "run", return_value=result) as run:
                    checks = LANES.run_native_qualification("linux", IDENTITY, [ARTIFACT])
                command = run.call_args.args[0]
                self.assertEqual(command[1], "scripts/run-release-command.py")
                self.assertEqual(command[5:7], ["bash", "scripts/run-native-integration.sh"])
                self.assertIn("integration_test/flows/user_flows_test.dart", command)
                self.assertTrue(all(row["artifact_sha256"] == [ARTIFACT["sha256"]]
                                    for row in checks.values()))
                if fault is None:
                    self.assertTrue(all(row["verdict"] == "unknown" for row in checks.values()))
                    self.assertTrue(all(row["automated_command_exit_code"] == 0 for row in checks.values()))
                    self.assertTrue(all(row["protocol_receipt"] == receipt for row in checks.values()))
                    self.assertTrue(all("human" in row["reason"] for row in checks.values()))
                else:
                    self.assertTrue(all(row["verdict"] == "failed" for row in checks.values()), fault)
                    self.assertTrue(all("protocol" in row["reason"] for row in checks.values()))


if __name__ == "__main__":
    unittest.main()
