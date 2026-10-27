#!/usr/bin/env python3
"""Isolated best-effort release preparation and publication coordinator."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import tarfile
import tempfile
import time
from pathlib import Path
from typing import Any, Callable
from urllib.parse import quote
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
LANES = ("android_play", "fdroid", "web", "linux", "windows", "macos", "ios")
REQUIRED_CHECKS = {
    "android_play": ("signed_artifacts", "android_device_journey"),
    "fdroid": ("reproducible_build", "official_source_scan", "android_qualification"),
    "web": ("browser_journey", "saved_data", "asset_validation"),
    "linux": ("native_journey", "export_validation"),
    "windows": ("native_journey", "export_validation"),
    "macos": ("native_journey", "signing_notarization"),
    "ios": ("ios_journey", "store_prerequisites"),
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _write_stage_log(log_dir: Path | None, name: str, command: list[str] | str | None, *,
                     status: str, returncode: int | None = None, stdout: str = "",
                     stderr: str = "", reason: str | None = None,
                     elapsed_seconds: float | None = None) -> Path | None:
    if log_dir is None:
        return None
    log_dir.mkdir(parents=True, exist_ok=True)
    path = log_dir / f"{name}.json"
    path.write_text(json.dumps({
        "command": command,
        "status": status,
        "returncode": returncode,
        "elapsed_seconds": elapsed_seconds,
        "reason": reason,
        "stdout": stdout,
        "stderr": stderr,
    }, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def _git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def frozen_identity(version: str, build_number: str) -> dict[str, str]:
    commit = _git("rev-parse", "HEAD")
    digest = hashlib.sha256()
    digest.update(subprocess.check_output(["git", "diff", "--binary", "HEAD"], cwd=ROOT))
    for relative in _git("ls-files", "--others", "--exclude-standard").splitlines():
        path = ROOT / relative
        if path.is_file() and not path.is_symlink():
            digest.update(relative.encode())
            digest.update(path.read_bytes())
    lock = (ROOT / "pubspec.lock").read_bytes()
    return {"version": version, "build_number": build_number, "commit": commit,
            "source_digest": digest.hexdigest(), "lock_sha256": hashlib.sha256(lock).hexdigest(),
            "flutter_version": (ROOT / "fdroid/flutter.version").read_text().strip()}


def common_gate(identity: dict[str, str], stage_log_dir: Path | None = None) -> dict[str, str]:
    required_privacy = (
        "Effective date: 2026-08-09",
        "does not include advertising, remote analytics, behavioral tracking, or a remote crash-reporting SDK",
        "bounded in-memory diagnostic buffer",
        "https://fractal.trebuchetdynamics.com/view",
        "repository issue tracker",
    )
    privacy = ROOT / "web/privacy-policy.html"
    privacy_text = privacy.read_text(errors="replace") if privacy.is_file() else ""
    missing_privacy = [item for item in required_privacy if item not in privacy_text]
    _write_stage_log(stage_log_dir, "privacy-policy", "required privacy-policy text checks",
                     status="passed" if not missing_privacy else "failed",
                     returncode=0 if not missing_privacy else 1,
                     stdout=json.dumps({"path": str(privacy), "required": list(required_privacy),
                                        "missing": missing_privacy}, sort_keys=True))
    if missing_privacy:
        raise RuntimeError("shared privacy-policy gate failed")
    current_commit = _git("rev-parse", "HEAD")
    current_identity = frozen_identity(identity["version"], identity["build_number"])
    source_matches = identity["commit"] == current_commit and current_identity == identity
    _write_stage_log(stage_log_dir, "source-integrity", "git source and frozen version/SDK/lock identity",
                     status="passed" if source_matches else "failed",
                     returncode=0 if source_matches else 1,
                     stdout=json.dumps({"expected": identity, "commit": current_commit,
                                        "observed": current_identity}, sort_keys=True))
    if identity["commit"] != current_commit:
        raise RuntimeError("frozen source commit changed during campaign")
    if current_identity != identity:
        raise RuntimeError("frozen source/lock identity changed during campaign")
    flutter = os.environ.get("FLUTTER_BIN", "flutter")
    results = {}
    for check, arguments in (("flutter_analyze", ["analyze", "--no-pub"]),
                             ("flutter_host_tests", ["test", "--no-pub"])):
        command = [flutter, *arguments]
        started = time.monotonic()
        try:
            run = subprocess.run(command, cwd=ROOT, env=_lane_environment("common"),
                                 text=True, capture_output=True, timeout=1800)
        except (OSError, subprocess.SubprocessError) as error:
            _write_stage_log(stage_log_dir, check, command,
                             status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                             stdout=str(getattr(error, "stdout", "") or ""),
                             stderr=str(getattr(error, "stderr", "") or ""), reason=str(error),
                             elapsed_seconds=time.monotonic() - started)
            raise RuntimeError(f"shared {check} unavailable: {error}") from error
        _write_stage_log(stage_log_dir, check, command,
                         status="passed" if run.returncode == 0 else "failed",
                         returncode=run.returncode, stdout=run.stdout, stderr=run.stderr,
                         elapsed_seconds=time.monotonic() - started)
        if run.returncode:
            raise RuntimeError(f"shared {check} failed ({run.returncode}): {(run.stderr or run.stdout)[-1000:]}")
        results[check] = "passed"
    results.update(source_integrity="passed", privacy_policy="passed")
    return results


def _host_unavailable(lane: str) -> str | None:
    machine = platform.system().lower()
    host = {"linux": "linux", "windows": "windows", "macos": "darwin", "ios": "darwin"}.get(lane)
    if host and machine != host:
        return f"required native host unavailable: {host}"
    if lane == "fdroid":
        sdk_roots = [os.environ.get("ANDROID_SDK_ROOT", ""), os.environ.get("ANDROID_HOME", ""), "/usr/lib/android-sdk"]
        if not any(root and (Path(root) / "build-tools").is_dir() for root in sdk_roots):
            return "Android SDK build tools unavailable for F-Droid source builds"
        if not shutil.which(os.environ.get("FDROID_BIN", "fdroid")):
            return "F-Droid CLI unavailable for official source scan (configure FDROID_BIN for an isolated tool)"
    if lane == "android_play":
        if not (os.environ.get("ANDROID_KEYSTORE_BASE64") and os.environ.get("ANDROID_KEY_PROPERTIES_FILE")):
            return "Android signing credentials unavailable"
        if not shutil.which("adb"):
            return "adb unavailable"
        try:
            devices = subprocess.check_output(["adb", "devices"], text=True, stderr=subprocess.DEVNULL)
        except (OSError, subprocess.SubprocessError):
            return "Android device inventory unavailable"
        if not any(line.rstrip().endswith("device") for line in devices.splitlines()[1:] if line.strip()):
            return "qualified Android device unavailable"
    return None


def _allocated_port_base() -> int:
    value = os.environ.get("AUTOWORK_PORT_BASE", "")
    if not re.fullmatch(r"[0-9]{1,5}", value) or not 1024 <= int(value) <= 65436:
        raise ValueError("a valid AUTOWORK_PORT_BASE allocation of 100 non-privileged ports is required")
    return int(value)


def _native_protocol_receipt(output: str, environment: dict[str, str],
                             identity: dict[str, str], port: int) -> dict[str, Any]:
    paths = [line.removeprefix("Native integration evidence: ")
             for line in output.splitlines() if line.startswith("Native integration evidence: ")]
    if len(paths) != 1 or not environment.get("TMPDIR"):
        raise ValueError("missing unique native protocol evidence directory or private TMPDIR")
    work = Path(paths[0]).resolve()
    if not work.is_relative_to(Path(environment["TMPDIR"]).resolve()) or not work.name.startswith("native-integration-"):
        raise ValueError("native protocol evidence is outside private scratch")
    receipt = json.loads((work / "run.json").read_text())
    callback = json.loads((work / "protocol-success.json").read_text())
    inputs = ("integration_test/flows/user_flows_test.dart", "test_driver/integration_test.dart",
              "scripts/run-native-integration.sh")
    valid = (receipt.get("revision") == identity["commit"] and
             receipt.get("exit_code") == 0 and receipt.get("protocol_success") is True and
             callback == {"allTestsPassed": True} and
             receipt.get("cleanup") == {"remaining_pids": []} and
             receipt.get("port_range") == [port, port + 99] and
             receipt.get("listeners") == [["tcp", "0100007F", port]] and
             receipt.get("sdk", {}).get("flutterVersion") ==
             identity.get("flutter_version", (ROOT / "fdroid/flutter.version").read_text().strip()) and
             receipt.get("sha256") == {name: sha256_file(ROOT / name) for name in inputs})
    if not valid:
        raise ValueError("native protocol/source/SDK/allocation/cleanup evidence does not match the candidate")
    return receipt


def run_native_qualification(lane: str, identity: dict[str, str],
                              artifacts: list[dict[str, Any]],
                              stage_log_dir: Path | None = None) -> dict[str, dict[str, Any]]:
    if lane not in {"linux", "windows", "macos", "ios"}:
        raise ValueError(f"native qualification does not support lane: {lane}")
    checks = REQUIRED_CHECKS[lane]
    reason = "no supported lane-local native journey/export receipt adapter is available"
    unknown = {name: {"check": name, "verdict": "unknown", **identity, "reason": reason}
               for name in checks}
    if lane != "linux":
        return unknown
    if platform.system().lower() != "linux":
        return {name: {**receipt, "reason": "Linux journey requires a Linux host"}
                for name, receipt in unknown.items()}
    try:
        port = _allocated_port_base()
    except ValueError as error:
        return {name: {**receipt, "reason": str(error)} for name, receipt in unknown.items()}
    command = ["bash", "scripts/run-native-integration.sh", "integration_test/flows/user_flows_test.dart",
               "--timeout", "1200", "--dart-define=FORCE_GPU_RENDER=true"]
    environment = _lane_environment("common")
    started = time.monotonic()
    try:
        command = [sys.executable, "scripts/run-release-command.py", "--timeout", "1210", "--", *command]
        result = subprocess.run(command, cwd=ROOT, env=environment,
                                capture_output=True, text=True, timeout=1240)
    except (OSError, subprocess.SubprocessError) as error:
        timed_out = isinstance(error, subprocess.TimeoutExpired)
        log_path = _write_stage_log(stage_log_dir, "linux-native-journey", command,
                                    status="timeout" if timed_out else "unavailable",
                                    reason=str(error),
                                    stdout=str(getattr(error, "stdout", "") or ""),
                                    stderr=str(getattr(error, "stderr", "") or ""),
                                    elapsed_seconds=time.monotonic() - started)
        return {name: {"check": name, "verdict": "failed" if timed_out else "unknown", **identity,
                       "reason": f"native journey/export {'timed out' if timed_out else 'unavailable'}: {error}",
                       "command": command, "stage_log": str(log_path) if log_path else None}
                for name in checks}
    output = result.stdout + result.stderr
    log_path = _write_stage_log(stage_log_dir, "linux-native-journey", command,
                                status="passed" if result.returncode == 0 else "failed",
                                returncode=result.returncode, stdout=result.stdout, stderr=result.stderr,
                                elapsed_seconds=time.monotonic() - started)
    if result.returncode:
        reason = f"native journey/export failed ({result.returncode}): {(result.stderr or result.stdout)[-1200:]}"
        return {name: {"check": name, "verdict": "failed", **identity, "reason": reason,
                       "command": command, "stage_log": str(log_path) if log_path else None} for name in checks}
    try:
        protocol = _native_protocol_receipt(result.stdout, environment, identity, port)
    except (OSError, ValueError, TypeError, AttributeError) as error:
        reason = f"native protocol verification failed: {error}"
        _write_stage_log(stage_log_dir, "linux-native-protocol", command,
                         status="failed", reason=reason)
        return {name: {**_passed_check(name, identity, artifacts, " ".join(command), output),
                       "verdict": "failed", "reason": reason,
                       "stage_log": str(log_path) if log_path else None} for name in checks}
    # An official automated success still does not supply accepted visual evidence.
    reason = ("Full flow command completed, but retained edited-view PNG comparisons, "
              "EN/ES and inspired-entry coverage, and attributable human review remain unverified")
    return {name: {**_passed_check(name, identity, artifacts, " ".join(command), output),
                   "verdict": "unknown", "reason": reason, "automated_command_exit_code": 0,
                   "protocol_receipt": protocol,
                   "stage_log": str(log_path) if log_path else None}
            for name in checks}


def _build_command(lane: str, version: str, build_number: str) -> list[str]:
    stage = {"android_play": "android-build", "fdroid": "fdroid", "linux": "linux", "web": "web-build"}.get(lane)
    if stage:
        return ["bash", "scripts/release.sh", stage, f"--prepare={version}", f"--build-number={build_number}"]
    native = {"windows": "windows", "macos": "macos", "ios": "ios"}.get(lane)
    if native:
        return ["bash", "scripts/ci/native-build.sh", native]
    raise ValueError(f"unknown lane {lane}")


def _lane_artifact_patterns(lane: str, version: str) -> tuple[str, ...]:
    return {
        "android_play": (f"fractal-forge-android-v{version}.aab", f"fractal-forge-android-*-v{version}.apk"),
        "fdroid": (f"fdroid/fractal-forge-fdroid-v{version}-*-unsigned.apk",),
        "web": (f"fractal-forge-web-v{version}.tar.gz",),
        "linux": (f"fractal-forge-linux-x64-v{version}.tar.gz",),
        "windows": ("fractal-forge-windows-x64.zip",),
        "macos": ("fractal-forge-macos-unsigned.zip",),
        "ios": ("fractal-forge-ios-unsigned.zip",),
    }[lane]


def verify_artifact_receipts(lane: str, identity: dict[str, str], artifact_dir: Path) -> list[dict[str, Any]]:
    expected_count = {"android_play": 4, "fdroid": 3}.get(lane, 1)
    candidates: dict[str, Path] = {}
    for pattern in _lane_artifact_patterns(lane, identity["version"]):
        for path in artifact_dir.glob(pattern):
            if path.is_file() and not path.is_symlink() and path.stat().st_size > 0:
                candidates[path.name] = path
    if len(candidates) != expected_count:
        return []
    receipts = []
    for path in sorted(candidates.values()):
        provenance = Path(f"{path}.provenance")
        if not provenance.is_file() or provenance.is_symlink():
            return []
        fields = dict(line.split("=", 1) for line in provenance.read_text().splitlines() if "=" in line)
        digest = sha256_file(path)
        recorded_build = fields.get("base_build_number", fields.get("build_number"))
        if (fields.get("version") != identity["version"] or
                recorded_build != identity["build_number"] or
                fields.get("commit") != identity["commit"] or fields.get("sha256") != digest):
            return []
        receipts.append({"name": path.name, "path": str(path.resolve()), "bytes": path.stat().st_size, "sha256": digest})
    return receipts


def _produce_lane(lane: str, identity: dict[str, str], artifact_dir: Path,
                  stage_log_dir: Path | None = None) -> dict[str, Any]:
    unavailable = _host_unavailable(lane)
    if unavailable:
        raise LookupError(unavailable)
    log_dir = stage_log_dir or artifact_dir / "stage-logs"
    logs: list[str] = []
    environment = os.environ.copy()
    environment.pop("GITLAB_CI", None)
    secrets = {"ANDROID_KEYSTORE_BASE64", "ANDROID_KEY_PROPERTIES_FILE", "PLAY_SERVICE_ACCOUNT_JSON",
               "CLOUDFLARE_API_TOKEN", "CLOUDFLARE_API_KEY", "CLOUDFLARE_EMAIL", "GH_TOKEN"}
    for key in secrets:
        if lane != "android_play" or key not in {"ANDROID_KEYSTORE_BASE64", "ANDROID_KEY_PROPERTIES_FILE"}:
            environment.pop(key, None)
    environment.update(RELEASE_LOCAL_STAGE="1", RELEASE_ARTIFACT_DIR=str(artifact_dir),
                       RELEASE_VERSION=identity["version"], RELEASE_BUILD_NUMBER=identity["build_number"],
                       RELEASE_COMMIT=identity["commit"])
    build_command = _build_command(lane, identity["version"], identity["build_number"])
    started = time.monotonic()
    try:
        result = subprocess.run(build_command, cwd=ROOT, env=environment, text=True,
                                capture_output=True, timeout=3600)
    except (OSError, subprocess.SubprocessError) as error:
        log_path = _write_stage_log(log_dir, f"{lane}-build", build_command,
                                    status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                                    reason=str(error), stdout=str(getattr(error, "stdout", "") or ""),
                                    stderr=str(getattr(error, "stderr", "") or ""),
                                    elapsed_seconds=time.monotonic() - started)
        raise RuntimeError(f"builder unavailable: {error}; stage log: {log_path}") from error
    log_path = _write_stage_log(log_dir, f"{lane}-build", build_command,
                                status="passed" if result.returncode == 0 else "failed",
                                returncode=result.returncode, stdout=result.stdout, stderr=result.stderr,
                                elapsed_seconds=time.monotonic() - started)
    if log_path:
        logs.append(str(log_path))
    if result.returncode:
        raise RuntimeError(f"builder failed ({result.returncode}): {(result.stderr or result.stdout)[-1200:]}; stage log: {log_path}")
    artifacts = verify_artifact_receipts(lane, identity, artifact_dir)
    artifact_output = json.dumps(artifacts, indent=2, sort_keys=True)
    artifact_log = _write_stage_log(log_dir, f"{lane}-artifact-verification", "verify artifact size/hash/provenance",
                                   status="passed" if artifacts else "failed",
                                   returncode=0 if artifacts else 1, stdout=artifact_output)
    if artifact_log:
        logs.append(str(artifact_log))
    checks = {name: {"check": name, "verdict": "unknown", **identity} for name in REQUIRED_CHECKS[lane]}
    if lane == "android_play":
        try:
            checks["signed_artifacts"] = _android_certificate_check(identity, artifacts)
            certificate_log = _write_stage_log(log_dir, "android-certificate-verification",
                                               "keytool/apksigner pinned certificate verification",
                                               status="passed", returncode=0,
                                               stdout=json.dumps(checks["signed_artifacts"], sort_keys=True))
            if certificate_log:
                logs.append(str(certificate_log))
        except (OSError, subprocess.SubprocessError, LookupError, ValueError) as error:
            certificate_log = _write_stage_log(log_dir, "android-certificate-verification",
                                               "keytool/apksigner pinned certificate verification",
                                               status="failed", reason=str(error))
            if certificate_log:
                logs.append(str(certificate_log))
            raise
    elif lane == "fdroid":
        checks["reproducible_build"] = _passed_check("reproducible_build", identity, artifacts,
                                                      "scripts/build-fdroid.sh --reproducible")
        scan_command = ["bash", "scripts/ci/fdroid-scan.sh"]
        started = time.monotonic()
        try:
            scan = subprocess.run(scan_command, cwd=ROOT, env=environment,
                                  capture_output=True, text=True, timeout=1800)
            scan_log = _write_stage_log(log_dir, "fdroid-source-scan", scan_command,
                                        status="passed" if scan.returncode == 0 else "failed",
                                        returncode=scan.returncode, stdout=scan.stdout, stderr=scan.stderr,
                                        elapsed_seconds=time.monotonic() - started)
            if scan_log:
                logs.append(str(scan_log))
            if scan.returncode == 0:
                checks["official_source_scan"] = _passed_check("official_source_scan", identity, artifacts,
                                                               "scripts/ci/fdroid-scan.sh", scan.stdout + scan.stderr)
            else:
                checks["official_source_scan"] = {"check": "official_source_scan", "verdict": "failed",
                                                   **identity, "reason": f"fdroid scan exited {scan.returncode}",
                                                   "stage_log": str(scan_log) if scan_log else None}
        except (OSError, subprocess.SubprocessError) as error:
            scan_log = _write_stage_log(log_dir, "fdroid-source-scan", scan_command,
                                        status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                                        reason=str(error),
                                        stdout=str(getattr(error, "stdout", "") or ""),
                                        stderr=str(getattr(error, "stderr", "") or ""),
                                        elapsed_seconds=time.monotonic() - started)
            if scan_log:
                logs.append(str(scan_log))
    if lane in ("android_play", "fdroid"):
        device_env = environment.copy()
        gate_command = ["bash", "scripts/pre-release-gate.sh", "--build-name", identity["version"],
                        "--build-number", identity["build_number"], "--log-dir",
                        str(artifact_dir / "final-device-gate"), "--skip-host"]
        for variable, option in (("ANDROID_DEVICE", "--device"),
                                 ("ANDROID_DISPOSABLE_DEVICE", "--disposable-device")):
            if os.environ.get(variable):
                gate_command.extend([option, os.environ[variable]])
        started = time.monotonic()
        try:
            gate = subprocess.run(gate_command, cwd=ROOT, env=device_env,
                                  capture_output=True, text=True, timeout=3600)
            gate_log = _write_stage_log(log_dir, f"{lane}-device-gate", gate_command,
                                        status="passed" if gate.returncode == 0 else "failed",
                                        returncode=gate.returncode, stdout=gate.stdout, stderr=gate.stderr,
                                        elapsed_seconds=time.monotonic() - started)
            if gate_log:
                logs.append(str(gate_log))
            if gate.returncode == 0:
                gate_name = "android_device_journey" if lane == "android_play" else "android_qualification"
                checks[gate_name] = _passed_check(gate_name, identity, artifacts,
                                                  "scripts/pre-release-gate.sh --skip-host", gate.stdout)
            else:
                gate_name = "android_device_journey" if lane == "android_play" else "android_qualification"
                checks[gate_name] = {"check": gate_name, "verdict": "failed", **identity,
                                     "reason": f"device gate exited {gate.returncode}",
                                     "stage_log": str(gate_log) if gate_log else None}
        except (OSError, subprocess.SubprocessError) as error:
            gate_log = _write_stage_log(log_dir, f"{lane}-device-gate", gate_command,
                                        status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                                        reason=str(error),
                                        stdout=str(getattr(error, "stdout", "") or ""),
                                        stderr=str(getattr(error, "stderr", "") or ""),
                                        elapsed_seconds=time.monotonic() - started)
            if gate_log:
                logs.append(str(gate_log))
    elif lane == "web":
        checks.update(_web_qualification(identity, artifacts, log_dir))
        logs.extend(str(check["stage_log"]) for check in checks.values()
                    if check.get("stage_log") and str(check["stage_log"]) not in logs)
    elif lane in {"linux", "windows", "macos", "ios"}:
        checks.update(run_native_qualification(lane, identity, artifacts, log_dir))
        logs.extend(str(check["stage_log"]) for check in checks.values()
                    if check.get("stage_log") and str(check["stage_log"]) not in logs)
    result = {"candidate": f"{lane}:{identity['version']}+{identity['build_number']}@{identity['commit']}",
              "version": identity["version"], "build_number": identity["build_number"], "commit": identity["commit"],
              "artifacts": artifacts, "checks": checks, "stage_logs": logs}
    if lane == "linux":
        native = checks["native_journey"]
        result["full_journey"] = {"verdict": "passed" if native.get("automated_command_exit_code") == 0 else native["verdict"],
                                  "command": native.get("command"),
                                  "stage_log": native.get("stage_log"),
                                  "output_sha256": native.get("output_sha256"),
                                  "reason": native.get("reason")}
        result["retained_image_human_review"] = {
            "verdict": "pending",
            "reason": "The integration test removes its temporary exports; retain an image before human composition review.",
        }
    return result


def _normalize_fingerprint(value: str) -> str:
    return value.replace(":", "").replace(" ", "").strip().upper()


def validate_certificate_fingerprint(expected: str, actual: str) -> str:
    normalized_expected, normalized_actual = _normalize_fingerprint(expected), _normalize_fingerprint(actual)
    if not normalized_expected or normalized_actual != normalized_expected:
        raise ValueError("Android signing certificate does not match the pinned upload certificate")
    return normalized_actual


def _android_certificate_check(identity: dict[str, str], artifacts: list[dict[str, Any]]) -> dict[str, Any]:
    expected_file = ROOT / "android/play-upload-cert-sha1.txt"
    if not expected_file.is_file():
        raise ValueError("pinned Android upload certificate fingerprint is missing")
    expected = _normalize_fingerprint(expected_file.read_text())
    roots = [os.environ.get("ANDROID_SDK_ROOT", ""), os.environ.get("ANDROID_HOME", ""), "/usr/lib/android-sdk"]
    aapt_tools = [Path(root) / "build-tools" for root in roots if root]
    apksigner = next((binary for root in aapt_tools for binary in sorted(root.glob("*/apksigner")) if binary.is_file()), None)
    if apksigner is None:
        found = shutil.which("apksigner")
        apksigner = Path(found) if found else None
    if apksigner is None:
        raise LookupError("Android apksigner unavailable for certificate evidence")
    observed = []
    for item in artifacts:
        path = Path(item["path"])
        if path.suffix == ".aab":
            result = subprocess.run(["keytool", "-printcert", "-jarfile", str(path)], capture_output=True, text=True)
            match = re.search(r"^[ \t]*SHA1:[ \t]*([0-9A-Fa-f:]+)", result.stdout, re.M)
        else:
            result = subprocess.run([str(apksigner), "verify", "--print-certs", str(path)], capture_output=True, text=True)
            match = re.search(r"Signer #1 certificate SHA-1 digest:[ \t]*([0-9A-Fa-f:]+)", result.stdout)
        if result.returncode or not match:
            raise ValueError(f"could not inspect Android signing certificate: {path.name}")
        observed.append(validate_certificate_fingerprint(expected, match.group(1)))
    return _passed_check("signed_artifacts", identity, artifacts,
                         "existing apksigner/keytool verifier plus pinned SHA-1", ",".join(observed)) | {"certificate_sha1": expected}


def _passed_check(name: str, identity: dict[str, str], artifacts: list[dict[str, Any]], command: str,
                  output: str = "") -> dict[str, Any]:
    return {"check": name, "verdict": "passed", **identity, "command": command,
            "artifact_sha256": [item["sha256"] for item in artifacts],
            "output_sha256": hashlib.sha256(output.encode()).hexdigest()}


def _browser_report_count(path: Path, spec: str) -> int:
    report = json.loads(path.read_text())
    stats = report.get("stats", {})
    keys = ("expected", "unexpected", "flaky", "skipped")
    if (not isinstance(stats, dict) or
            any(type(stats.get(key)) is not int or stats[key] < 0 for key in keys) or
            stats["expected"] < 1 or stats["unexpected"] or stats["flaky"] or
            report.get("errors") != []):
        raise ValueError("browser report must contain executed passing cases and no failures, flakes or errors")
    cases = []

    def collect(suites, inherited_file=None):
        for suite in suites:
            filename = suite.get("file", inherited_file)
            for row in suite.get("specs", []):
                cases.extend((row.get("file", filename), test) for test in row.get("tests", []))
            collect(suite.get("suites", []), filename)
    collect(report.get("suites", []))
    expected = (ROOT / spec).resolve()
    passed = skipped = 0
    for filename, test in cases:
        if not isinstance(filename, str) or expected not in {
                (ROOT / filename).resolve(), (ROOT / "test/playwright" / filename).resolve()}:
            raise ValueError("browser report case is not from the requested spec")
        if test.get("projectName", test.get("projectId")) != "chromium":
            raise ValueError("browser report case is not from Chromium")
        results = test.get("results", [])
        if test.get("status") == "skipped" and results and all(r.get("status") == "skipped" for r in results):
            skipped += 1
        elif (test.get("expectedStatus") == "passed" and test.get("status") == "expected" and
              len(results) == 1 and results[0].get("status") == "passed"):
            passed += 1
        else:
            raise ValueError("browser case has no actual passing result")
    if not passed or passed != stats["expected"] or skipped != stats["skipped"]:
        raise ValueError("browser case results do not reconcile with report counters")
    return passed


def _web_qualification(identity: dict[str, str], artifacts: list[dict[str, Any]],
                       stage_log_dir: Path | None = None) -> dict[str, Any]:
    receipts: dict[str, Any] = {}
    archive = Path(artifacts[0]["path"]) if artifacts else None
    if archive is None:
        return receipts
    try:
        with tarfile.open(archive, "r:gz") as bundle:
            members = bundle.getmembers()
            names = {member.name.lstrip("./") for member in members}
            safe = all(not member.issym() and not member.islnk() and not Path(member.name).is_absolute()
                       and ".." not in Path(member.name).parts for member in members)
            valid_assets = safe and "web/index.html" in names and "web/main.dart.js" in names
            if not valid_assets:
                return receipts
            release_identity = json.load(bundle.extractfile("web/release-identity.json"))
            if any(str(release_identity.get(field, "")) != str(identity[field])
                   for field in ("version", "build_number", "commit")):
                return receipts
            expected_files = release_identity.get("files")
            archived_files = {member.name.lstrip("./").removeprefix("web/") for member in members
                              if member.isfile() and member.name.lstrip("./").startswith("web/")
                              and member.name.lstrip("./") != "web/release-identity.json"}
            inventory = {"archived_files": sorted(archived_files),
                         "archive_directory_entries": sum(member.isdir() for member in members),
                         "manifest_files": sorted(expected_files) if isinstance(expected_files, dict) else None}
            if not isinstance(expected_files, dict) or archived_files != set(expected_files):
                _write_stage_log(stage_log_dir, "web-asset-validation", "tar archive inventory",
                                 status="failed", reason="archive file inventory differs from manifest",
                                 stdout=json.dumps(inventory, sort_keys=True))
                return receipts
            for relative, expected_hash in expected_files.items():
                stream = bundle.extractfile(f"web/{relative}")
                if stream is None or hashlib.sha256(stream.read()).hexdigest() != expected_hash:
                    _write_stage_log(stage_log_dir, "web-asset-validation", "tar archive SHA-256 manifest",
                                     status="failed", reason=f"missing or mismatched asset: {relative}",
                                     stdout=json.dumps(inventory, sort_keys=True))
                    return receipts
            asset_log = _write_stage_log(stage_log_dir, "web-asset-validation",
                                         "tar archive inventory and file SHA-256 manifest",
                                         status="passed", returncode=0,
                                         stdout=json.dumps(inventory, sort_keys=True))
            receipts["asset_validation"] = _passed_check(
                "asset_validation", identity, artifacts,
                "web archive inventory and file SHA-256 manifest verified",
                json.dumps(inventory, sort_keys=True)) | {"stage_log": str(asset_log) if asset_log else None}
            with tempfile.TemporaryDirectory(prefix="release-web-check-") as directory:
                bundle.extractall(directory, filter="data")
                web_root = Path(directory) / "web"
                try:
                    port_base = _allocated_port_base()
                except ValueError as error:
                    _write_stage_log(stage_log_dir, "web-http-server", "validate allocated loopback HTTP range",
                                     status="unavailable", reason=str(error))
                    for check in ("browser_journey", "saved_data"):
                        receipts[check] = {"check": check, "verdict": "unknown", **identity,
                                           "reason": str(error)}
                    return receipts
                server = None
                port = None
                for candidate in range(port_base, port_base + 100):
                    probe = socket.socket()
                    try:
                        probe.bind(("127.0.0.1", candidate))
                        port = candidate
                        break
                    except OSError:
                        probe.close()
                if port is None:
                    _write_stage_log(stage_log_dir, "web-http-server", "bind loopback HTTP server",
                                     status="unavailable", reason="no authorized free port in configured range")
                    return receipts
                probe.close()
                server = subprocess.Popen([sys.executable, "-m", "http.server", str(port), "--bind", "127.0.0.1",
                                           "--directory", str(web_root)], cwd=ROOT,
                                          env=_lane_environment("common"), stdout=subprocess.DEVNULL,
                                          stderr=subprocess.DEVNULL)
                try:
                    server_ready = False
                    for _ in range(30):
                        try:
                            with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                                server_ready = True
                                break
                        except OSError:
                            if server.poll() is not None:
                                break
                            time.sleep(0.1)
                    if not server_ready:
                        _write_stage_log(stage_log_dir, "web-http-server", "bind loopback HTTP server",
                                         status="failed", reason="HTTP server did not accept connections")
                        return receipts
                    base_url = f"http://127.0.0.1:{port}"
                    try:
                        with urlopen(f"{base_url}/release-identity.json", timeout=5) as response:
                            served_identity = json.load(response)
                        with urlopen(f"{base_url}/main.dart.js", timeout=5) as response:
                            served_hash = hashlib.sha256(response.read()).hexdigest()
                        if (server.poll() is not None or served_identity != release_identity or
                                served_hash != expected_files["main.dart.js"]):
                            raise ValueError("served bundle differs from the verified release archive")
                    except (OSError, ValueError) as error:
                        _write_stage_log(stage_log_dir, "web-http-server", "verify owned served bundle",
                                         status="failed", reason=str(error))
                        return receipts
                    for check, spec in (("browser_journey", "test/playwright/web-image-creation-journey.spec.mjs"),
                                        ("saved_data", "test/playwright/production-saved-session.spec.mjs")):
                        evidence = Path(tempfile.mkdtemp(prefix=f"web-{check}-"))
                        env = _lane_environment("common")
                        env.update(PLAYWRIGHT_BASE_URL=base_url, PLAYWRIGHT_SKIP_WEBSERVER="1",
                                   PLAYWRIGHT_JSON_OUTPUT_FILE=str(evidence / "report.json"),
                                   PLAYWRIGHT_HTML_OUTPUT_DIR=str(evidence / "html"),
                                   PLAYWRIGHT_HTML_OPEN="never")
                        command = [sys.executable, "scripts/run-release-command.py", "--timeout", "1800", "--",
                                   "npx", "--no-install", "playwright", "test", spec,
                                   "--project=chromium", "--workers=1", "--reporter=list,json,html",
                                   f"--output={evidence / 'results'}"]
                        stdout, stderr = "", ""
                        receipt = {**_passed_check(check, identity, artifacts, " ".join(command)),
                                   "evidence_dir": str(evidence), "exit_code": None,
                                   "served_bundle_sha256": served_hash}
                        try:
                            result = subprocess.run(command, cwd=ROOT, env=env, text=True,
                                                    capture_output=True, timeout=1830)
                            stdout, stderr = result.stdout, result.stderr
                            receipt.update(exit_code=result.returncode,
                                           verdict="failed" if result.returncode else "passed")
                            if result.returncode:
                                receipt["reason"] = f"browser check failed ({result.returncode})"
                            else:
                                try:
                                    receipt["executed_tests"] = _browser_report_count(evidence / "report.json", spec)
                                except (OSError, ValueError, TypeError, AttributeError) as error:
                                    receipt.update(verdict="failed", reason=f"browser report verification failed: {error}")
                        except subprocess.TimeoutExpired as error:
                            stdout, stderr = error.stdout or "", error.stderr or ""
                            receipt.update(verdict="failed", reason="browser check timed out after 1800 seconds")
                        except (OSError, subprocess.SubprocessError) as error:
                            stderr = str(error)
                            receipt.update(verdict="unknown", reason=f"browser execution unavailable: {error}")
                        stdout = stdout.decode(errors="replace") if isinstance(stdout, bytes) else stdout
                        stderr = stderr.decode(errors="replace") if isinstance(stderr, bytes) else stderr
                        (evidence / "stdout.log").write_text(stdout)
                        (evidence / "stderr.log").write_text(stderr)
                        receipt["output_sha256"] = hashlib.sha256((stdout + stderr).encode()).hexdigest()
                        log_path = _write_stage_log(stage_log_dir, check, command,
                                                    status=receipt["verdict"], returncode=receipt["exit_code"],
                                                    stdout=stdout, stderr=stderr, reason=receipt.get("reason"))
                        receipt["stage_log"] = str(log_path) if log_path else None
                        (evidence / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
                        receipts[check] = receipt
                finally:
                    server.terminate()
                    try:
                        server.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        server.kill()
                        server.wait()
    except (OSError, tarfile.TarError):
        return receipts
    return receipts


def _validate_gate_receipts(lane: str, identity: dict[str, str], record: dict[str, Any]) -> None:
    checks = record.get("checks")
    if not isinstance(checks, dict) or set(checks) != set(REQUIRED_CHECKS[lane]):
        raise ValueError("lane checks do not match the mapped qualification gate set")
    expected_hashes = [item.get("sha256") for item in record.get("artifacts", [])]
    for required in REQUIRED_CHECKS[lane]:
        receipt = checks.get(required)
        if not isinstance(receipt, dict) or receipt.get("verdict") != "passed":
            verdict = receipt.get("verdict", "unknown") if isinstance(receipt, dict) else "unknown"
            reason = receipt.get("reason") if isinstance(receipt, dict) else None
            suffix = f" ({reason})" if reason else ""
            raise ValueError(f"required qualification is not verified ({verdict}): {required}{suffix}")
        if any(str(receipt.get(field, "")) != str(identity[field]) for field in ("version", "build_number", "commit")):
            raise ValueError(f"qualification identity mismatch: {required}")
        if receipt.get("check") != required:
            raise ValueError(f"qualification check-name mismatch: {required}")
        if receipt.get("artifact_sha256") != expected_hashes:
            raise ValueError(f"qualification artifact identity mismatch: {required}")
        if lane == "android_play" and required == "signed_artifacts":
            expected_certificate = _normalize_fingerprint((ROOT / "android/play-upload-cert-sha1.txt").read_text())
            if receipt.get("certificate_sha1") != expected_certificate:
                raise ValueError("Android qualification certificate does not match the pinned upload certificate")


def verify_lane_candidate(lane: str, identity: dict[str, str], record: dict[str, Any], *,
                          verify_checks: bool = True) -> list[dict[str, Any]]:
    if lane not in LANES:
        raise ValueError(f"unknown lane: {lane}")
    if not record.get("candidate") or any(str(record.get(field, "")) != str(identity[field]) for field in ("version", "build_number", "commit")):
        raise ValueError("candidate identity mismatch")
    if verify_checks:
        _validate_gate_receipts(lane, identity, record)
    artifacts = record.get("artifacts")
    expected_count = {"android_play": 4, "fdroid": 3}.get(lane, 1)
    if not isinstance(artifacts, list) or len(artifacts) != expected_count:
        raise ValueError("missing or incomplete artifact set")
    validated = []
    for receipt in artifacts:
        path = Path(receipt.get("path", ""))
        if path.is_symlink() or not path.is_file():
            raise ValueError(f"missing or linked artifact: {path}")
        if path.stat().st_size == 0:
            raise ValueError(f"empty artifact: {path}")
        if receipt.get("name") != path.name or receipt.get("bytes") != path.stat().st_size:
            raise ValueError(f"artifact metadata mismatch: {path}")
        digest = sha256_file(path)
        if receipt.get("sha256") != digest:
            raise ValueError(f"artifact hash mismatch: {path.name}")
        sidecar = Path(f"{path}.provenance")
        if not sidecar.is_file() or sidecar.is_symlink():
            raise ValueError(f"missing artifact provenance: {path.name}")
        provenance = dict(line.split("=", 1) for line in sidecar.read_text().splitlines() if "=" in line)
        provenance_build = provenance.get("base_build_number", provenance.get("build_number"))
        if (provenance.get("version") != identity["version"] or provenance_build != identity["build_number"] or
                provenance.get("commit") != identity["commit"] or provenance.get("sha256") != digest):
            raise ValueError(f"artifact provenance mismatch: {path.name}")
        validated.append({"name": path.name, "path": str(path.resolve()), "bytes": path.stat().st_size, "sha256": digest})
    return validated


def _lane_environment(destination: str) -> dict[str, str]:
    environment = os.environ.copy()
    environment.pop("GITLAB_CI", None)
    credentials = {"ANDROID_KEYSTORE_BASE64", "ANDROID_KEY_PROPERTIES_FILE", "PLAY_SERVICE_ACCOUNT_JSON",
                   "CLOUDFLARE_API_TOKEN", "CLOUDFLARE_API_KEY", "CLOUDFLARE_EMAIL", "GH_TOKEN"}
    allowed = {"common": set(), "github": {"GH_TOKEN"},
               "web": {"CLOUDFLARE_API_TOKEN", "CLOUDFLARE_API_KEY", "CLOUDFLARE_EMAIL"},
               "play": {"PLAY_SERVICE_ACCOUNT_JSON"}}[destination]
    for key in credentials - allowed:
        environment.pop(key, None)
    return environment


def _github_write(lane: dict[str, Any]) -> dict[str, Any]:
    version = lane["identity"]["version"]
    tag = f"v{version}"
    artifacts = [item["path"] for item in lane["artifacts"]]
    if not shutil.which("gh"):
        raise LookupError("GitHub CLI unavailable")
    view = subprocess.run(["gh", "release", "view", tag, "--json", "isDraft,isPrerelease,assets"],
                          cwd=ROOT, text=True, capture_output=True, env=_lane_environment("github"))
    ref = f"refs/tags/{tag}"
    remote = subprocess.run(["git", "ls-remote", os.environ.get("GITHUB_RELEASE_REMOTE", "origin"), ref, f"{ref}^{{}}"],
                            cwd=ROOT, check=True, text=True, capture_output=True, env=_lane_environment("github"))
    refs = {name: commit for commit, name in (line.split() for line in remote.stdout.splitlines())}
    commit = refs.get(f"{ref}^{{}}", refs.get(ref))
    if (commit is not None or view.returncode == 0) and commit != lane["identity"]["commit"]:
        raise RuntimeError("existing GitHub tag does not point to the frozen release commit")
    if view.returncode == 0:
        release = json.loads(view.stdout)
        if release.get("isDraft") or release.get("isPrerelease"):
            raise RuntimeError("existing GitHub release is not a published non-prerelease")
        existing = {asset.get("name") for asset in release.get("assets", [])}
        missing = [path for path in artifacts if Path(path).name not in existing]
        if missing:
            subprocess.run(["gh", "release", "upload", tag, *missing], cwd=ROOT, check=True, capture_output=True, text=True,
                           env=_lane_environment("github"))
    else:
        subprocess.run(["gh", "release", "create", tag, *artifacts, "--title", f"Fractal Forge {version}",
                        "--notes", f"Fractal Forge {version}", "--target", lane["identity"]["commit"]],
                       cwd=ROOT, check=True, capture_output=True, text=True,
                       env=_lane_environment("github"))
    return {"tag": tag}


def _github_readback(lane: dict[str, Any], publication: Any) -> dict[str, Any] | None:
    tag = (publication.get("tag") if isinstance(publication, dict) else None) or f"v{lane['identity']['version']}"
    view = subprocess.run(["gh", "release", "view", tag, "--json", "isDraft,isPrerelease,assets"],
                          cwd=ROOT, capture_output=True, text=True, env=_lane_environment("github"))
    if view.returncode:
        message = (view.stderr or view.stdout).lower()
        return {"found": False} if "release not found" in message else None
    data = json.loads(view.stdout)
    if data.get("isDraft") or data.get("isPrerelease"):
        return None
    ref = f"refs/tags/{tag}"
    remote = subprocess.run(["git", "ls-remote", os.environ.get("GITHUB_RELEASE_REMOTE", "origin"), ref, f"{ref}^{{}}"],
                            cwd=ROOT, check=True, text=True, capture_output=True, env=_lane_environment("github"))
    refs = {name: commit for commit, name in (line.split() for line in remote.stdout.splitlines())}
    if refs.get(f"{ref}^{{}}", refs.get(ref)) != lane["identity"]["commit"]:
        return {"found": False, "conflict": True,
                "publication_reason": "existing GitHub tag does not point to the frozen release commit"}
    names = {asset.get("name") for asset in data.get("assets", [])}
    for artifact in lane["artifacts"]:
        if artifact["name"] not in names:
            return {"found": False}
        with tempfile.TemporaryDirectory(prefix="release-readback-") as directory:
            download = subprocess.run(["gh", "release", "download", tag, "--pattern", artifact["name"], "--dir", directory],
                                      cwd=ROOT, capture_output=True, text=True, env=_lane_environment("github"))
            downloaded = Path(directory) / artifact["name"]
            if download.returncode or not downloaded.is_file() or sha256_file(downloaded) != artifact["sha256"]:
                return None
    return {"found": True, "tag": tag, "verified_assets": [item["name"] for item in lane["artifacts"]]}


def _web_write(lane: dict[str, Any]) -> dict[str, Any]:
    archive = Path(lane["artifacts"][0]["path"])
    project = os.environ.get("CLOUDFLARE_PAGES_PROJECT", "flutter-fractal-forge")
    if not os.environ.get("CLOUDFLARE_API_TOKEN") and not (os.environ.get("CLOUDFLARE_API_KEY") and os.environ.get("CLOUDFLARE_EMAIL")):
        raise LookupError("Cloudflare credentials unavailable")
    with tempfile.TemporaryDirectory(prefix="release-web-") as directory:
        with tarfile.open(archive, "r:gz") as bundle:
            bundle.extractall(directory, filter="data")
        web_root = Path(directory) / "web"
        if not web_root.is_dir():
            raise ValueError("verified web archive has no web/ root")
        result = subprocess.run(["wrangler", "pages", "deploy", str(web_root), "--project-name", project,
                                 "--branch", "main", "--commit-hash", lane["identity"]["commit"],
                                 "--commit-message", f"{lane['identity']['version']}:{lane['artifacts'][0]['sha256']}"],
                                cwd=ROOT, capture_output=True, text=True, check=True,
                                env=_lane_environment("web"))
    return {"project": project, "output": result.stdout[-1000:]}


def _web_readback(lane: dict[str, Any], publication: Any) -> dict[str, Any] | None:
    try:
        with tarfile.open(lane["artifacts"][0]["path"], "r:gz") as bundle:
            expected = json.load(bundle.extractfile("web/release-identity.json"))
        if any(str(expected.get(field, "")) != str(lane["identity"][field])
               for field in ("version", "build_number", "commit")):
            return None
    except (OSError, KeyError, TypeError, tarfile.TarError, json.JSONDecodeError):
        return None
    project = publication.get("project", os.environ.get("CLOUDFLARE_PAGES_PROJECT", "flutter-fractal-forge")) if isinstance(publication, dict) else os.environ.get("CLOUDFLARE_PAGES_PROJECT", "flutter-fractal-forge")
    result = subprocess.run(["wrangler", "pages", "deployment", "list", "--project-name", project, "--json"],
                            cwd=ROOT, capture_output=True, text=True, env=_lane_environment("web"))
    if result.returncode:
        return None
    try:
        deployments = json.loads(result.stdout)
    except json.JSONDecodeError:
        return None
    commit = lane["identity"]["commit"]
    expected_note = f"{lane['identity']['version']}:{lane['artifacts'][0]['sha256']}"
    matching = [item for item in deployments
                if ((item.get("deployment_trigger", {}).get("metadata", {}).get("commit_hash") == commit
                    or item.get("commit_hash") == commit)
                and (item.get("deployment_trigger", {}).get("metadata", {}).get("commit_message") == expected_note
                     or item.get("commit_message") == expected_note))
                # Wrangler's table SHA is truncated; full identity and all assets are verified below.
                or ("deployment_trigger" not in item and "commit_hash" not in item
                    and item.get("Source") == commit[:7] and item.get("Environment") == "Production"
                    and item.get("Branch") == "main")]
    if not matching:
        return {"found": False}
    url = matching[0].get("url", matching[0].get("Deployment"))
    if not isinstance(url, str) or not url.startswith("https://") or any(char.isspace() for char in url):
        return None
    try:
        remote = subprocess.run(["curl", "-fsS", "--max-time", "20", f"{url.rstrip('/')}/release-identity.json"],
                                cwd=ROOT, env=_lane_environment("common"), capture_output=True,
                                text=True, timeout=25)
        if remote.returncode:
            return None
        observed = json.loads(remote.stdout)
    except (OSError, json.JSONDecodeError, subprocess.SubprocessError):
        return None
    if observed != expected:
        return {"found": False, "conflict": True,
                "publication_reason": "deployment metadata matches but deployed release identity does not"}
    for relative, expected_hash in expected.get("files", {}).items():
        path = Path(relative)
        if path.is_absolute() or ".." in path.parts or not isinstance(expected_hash, str):
            return None
        try:
            remote_file = subprocess.run(["curl", "-fsS", "--max-time", "30",
                                          f"{url.rstrip('/')}/{quote(relative, safe='/')}"],
                                         cwd=ROOT, env=_lane_environment("common"),
                                         capture_output=True, timeout=35)
        except (OSError, subprocess.SubprocessError):
            return None
        if remote_file.returncode:
            return None
        if hashlib.sha256(remote_file.stdout).hexdigest() != expected_hash:
            return {"found": False, "conflict": True,
                    "publication_reason": f"deployed web asset differs from qualified bundle: {relative}"}
    return {"found": True, "deployment_id": matching[0].get("id", matching[0].get("Id")), "url": url,
            "identity_sha256": hashlib.sha256(json.dumps(expected, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
            "verified_file_count": len(expected.get("files", {}))}


def _play_write(lane: dict[str, Any]) -> dict[str, Any]:
    artifact = next((item for item in lane["artifacts"] if item["name"].endswith(".aab")), None)
    if artifact is None:
        raise ValueError("verified Android lane is missing its AAB")
    if not os.environ.get("PLAY_SERVICE_ACCOUNT_JSON"):
        raise LookupError("Play credentials unavailable")
    receipt_path = Path(lane["artifact_dir"]) / "play-publication-receipt.json"
    environment = _lane_environment("play")
    environment.update(PLAY_TRACK=os.environ.get("PLAY_TRACK") or "production",
                       PLAY_RELEASE_STATUS=os.environ.get("PLAY_RELEASE_STATUS") or "completed",
                       PLAY_RECEIPT_PATH=str(receipt_path))
    subprocess.run(["bash", "scripts/build-upload-playstore.sh", "--prebuilt-aab", artifact["path"],
                    "--expected-version", lane["identity"]["version"], "--expected-build-number", lane["identity"]["build_number"]],
                   cwd=ROOT, env=environment, check=True, capture_output=True, text=True)
    return {"receipt": str(receipt_path)}


def _play_readback(lane: dict[str, Any], publication: Any) -> dict[str, Any] | None:
    aab = next((item for item in lane["artifacts"] if item["name"].endswith(".aab")), None)
    if aab is None:
        return None
    environment = _lane_environment("play")
    environment.update(PLAY_TRACK=os.environ.get("PLAY_TRACK") or "production",
                       PLAY_RELEASE_STATUS=os.environ.get("PLAY_RELEASE_STATUS") or "completed")
    try:
        result = subprocess.run(["bash", "scripts/ci/play-readback.sh",
                                 lane["identity"]["build_number"], aab["sha256"]],
                                cwd=ROOT, env=environment, capture_output=True, text=True, timeout=300)
        if result.returncode:
            return None
        receipt = json.loads(result.stdout.splitlines()[-1])
    except (OSError, IndexError, json.JSONDecodeError, subprocess.SubprocessError):
        return None
    if receipt.get("aabSha256") != aab["sha256"]:
        return None
    return receipt if receipt.get("found") is True or receipt.get("conflict") is True else {"found": False}


def publisher_adapters() -> dict[str, tuple[Callable[..., Any], Callable[..., Any]]]:
    github = (_github_write, _github_readback)
    return {"android_play": (_play_write, _play_readback), "web": (_web_write, _web_readback),
            "linux": github, "windows": github, "macos": github}


def publish_once(record: dict[str, Any], publisher: Callable[..., Any], readback: Callable[..., Any]) -> dict[str, Any]:
    if record.get("status") != "verified" or not record.get("artifacts"):
        raise ValueError("publisher requires a verified nonempty lane")
    before = readback(record, None)
    if isinstance(before, dict) and before.get("found") is True:
        return {"publication": "published", "publication_id": before,
                "readback": before, "publication_reason": "existing write confirmed before retry"}
    if isinstance(before, dict) and before.get("conflict") is True:
        return {"publication": "publication-unknown", "publication_id": before,
                "publication_reason": before.get("publication_reason", "remote identity conflicts with candidate; refusing another write")}
    if not (isinstance(before, dict) and before.get("found") is False):
        return {"publication": "publication-unknown", "publication_id": None,
                "publication_reason": "remote state could not be established; refusing a duplicate write"}
    result = None
    error = None
    try:
        result = publisher(record)
    except Exception as caught:
        error = caught
    try:
        observed = readback(record, result if result is not None else {"write_attempted": True})
    except Exception as caught:
        observed = None
        error = error or caught
    if isinstance(observed, dict) and observed.get("found") is True:
        return {"publication": "published", "publication_id": result, "readback": observed}
    return {"publication": "publication-unknown", "publication_id": result,
            "publication_reason": str(error or "remote readback did not confirm exact publication")}


def run_campaign(identity: dict[str, str], builders: dict[str, Any], publishers: dict[str, tuple[Any, Any]],
                 shared_gate: Callable[..., Any]) -> dict[str, Any]:
    shared_error = None
    try:
        shared_gate(identity)
    except Exception as error:
        shared_error = str(error) or error.__class__.__name__
    records: dict[str, dict[str, Any]] = {}
    for lane in LANES:
        record: dict[str, Any] = {"candidate": None, "candidate_verdict": "unknown", "artifacts": [],
                                  "artifact_verdict": "unknown", "checks": {check: {"check": check, "verdict": "unknown", **identity}
                                                                         for check in REQUIRED_CHECKS[lane]},
                                  "status": "pending", "reason": None, "publication": "not-attempted"}
        records[lane] = record
        if shared_error:
            record.update(status="skipped-failed", reason=f"shared gate failed: {shared_error}")
            continue
        builder = builders.get(lane)
        if not builder:
            record.update(status="skipped-unavailable", reason="builder or host unavailable")
            continue
        try:
            built = builder(identity)
            record.update({k: built.get(k, record.get(k)) for k in ("candidate", "version", "build_number", "commit", "checks", "artifacts")})
            record["candidate_verdict"] = "passed" if record["candidate"] else "failed"
            artifacts = verify_lane_candidate(lane, identity, record, verify_checks=False)
            record["artifacts"] = artifacts
            record["artifact_verdict"] = "passed"
            _validate_gate_receipts(lane, identity, record)
            record["status"] = "verified"
        except Exception as error:
            unknown = (record.get("candidate_verdict") == "passed" and record.get("artifact_verdict") == "passed"
                       and any(record["checks"].get(name, {}).get("verdict") == "unknown"
                               for name in REQUIRED_CHECKS[lane]))
            record.update(status="skipped-unavailable" if unknown else "skipped-failed",
                          reason=str(error) or error.__class__.__name__)
            continue
        adapter = publishers.get(lane)
        if not adapter:
            record.update(status="skipped-unavailable", reason="publisher unavailable")
            continue
        record.update(publish_once(record, adapter[0], adapter[1]))
    published = sum(row.get("publication") == "published" for row in records.values())
    state = "failed" if not published else "complete" if published == len(LANES) else "partial"
    return {"identity": dict(identity), "status": state, "lanes": records,
            "published_lanes": published, "lane_count": len(LANES)}


def _write_campaign(path: Path, campaign: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(campaign, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(temp, path)
    path.chmod(0o400)


def _generate_subset_evidence(campaign_path: Path, artifact_dir: Path, campaign: dict[str, Any],
                              stage_log_dir: Path | None = None) -> dict[str, Any] | None:
    admitted = [(lane, row) for lane, row in campaign["lanes"].items() if row.get("status") == "verified"]
    if not admitted:
        return None
    output = artifact_dir / "evidence"
    command = [sys.executable, str(ROOT / "scripts/generate_release_evidence.py"), "--project-root", str(ROOT),
               "--output-dir", str(output), "--version", campaign["identity"]["version"],
               "--build-number", campaign["identity"]["build_number"], "--commit", campaign["identity"]["commit"],
               "--evidence", f"campaign-record={campaign_path}"]
    n = 0
    for _, lane in admitted:
        for item in lane["artifacts"]:
            command += ["--artifact", item["path"], "--evidence", f"provenance-{n}={item['path']}.provenance"]
            n += 1
    started = time.monotonic()
    try:
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=600)
    except (OSError, subprocess.SubprocessError) as error:
        _write_stage_log(stage_log_dir, "evidence-generation", command,
                         status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                         reason=str(error), stdout=str(getattr(error, "stdout", "") or ""),
                         stderr=str(getattr(error, "stderr", "") or ""),
                         elapsed_seconds=time.monotonic() - started)
        raise
    generation_log = _write_stage_log(stage_log_dir, "evidence-generation", command,
                                      status="passed" if result.returncode == 0 else "failed",
                                      returncode=result.returncode, stdout=result.stdout, stderr=result.stderr,
                                      elapsed_seconds=time.monotonic() - started)
    if result.returncode:
        raise RuntimeError(f"subset evidence generation failed ({result.returncode}): {(result.stderr or result.stdout)[-1200:]}; stage log: {generation_log}")
    manifest = output / "release-manifest.json"
    verify_command = [sys.executable, str(ROOT / "scripts/generate_release_evidence.py"), "--verify", str(manifest)]
    started = time.monotonic()
    try:
        verified = subprocess.run(verify_command, cwd=ROOT, capture_output=True, text=True, timeout=600)
    except (OSError, subprocess.SubprocessError) as error:
        _write_stage_log(stage_log_dir, "evidence-verification", verify_command,
                         status="timeout" if isinstance(error, subprocess.TimeoutExpired) else "unavailable",
                         reason=str(error), stdout=str(getattr(error, "stdout", "") or ""),
                         stderr=str(getattr(error, "stderr", "") or ""),
                         elapsed_seconds=time.monotonic() - started)
        raise
    verify_log = _write_stage_log(stage_log_dir, "evidence-verification", verify_command,
                                  status="passed" if verified.returncode == 0 else "failed",
                                  returncode=verified.returncode, stdout=verified.stdout, stderr=verified.stderr,
                                  elapsed_seconds=time.monotonic() - started)
    if verified.returncode:
        raise RuntimeError(f"subset evidence verification failed ({verified.returncode}): {(verified.stderr or verified.stdout)[-1200:]}; stage log: {verify_log}")
    return {"status": "verified", "manifest": str(manifest),
            "stage_logs": [str(path) for path in (generation_log, verify_log) if path]}


def prepare(version: str, build_number: str, artifact_dir: Path, campaign_path: Path) -> dict[str, Any]:
    identity = frozen_identity(version, build_number)
    stage_log_dir = artifact_dir / "stage-logs" / f"{identity['commit']}-{time.time_ns()}"
    stage_log_dir.mkdir(parents=True, exist_ok=True)
    try:
        shared = common_gate(identity, stage_log_dir)
        shared_error = None
    except Exception as error:
        shared = {check: "unknown" for check in ("flutter_analyze", "flutter_host_tests", "source_integrity", "privacy_policy")}
        shared_error = str(error) or error.__class__.__name__
        _write_stage_log(stage_log_dir, "shared-gate", "source/integrity/privacy/analyze/host-test gates",
                         status="failed", reason=shared_error)
    lanes = {}
    for lane in LANES:
        row = {"candidate": None, "candidate_verdict": "unknown", "artifacts": [], "artifact_verdict": "unknown",
               "checks": {check: {"check": check, "verdict": "unknown", **identity}
                           for check in REQUIRED_CHECKS[lane]},
               "stage_logs": [], "status": "pending", "stage": None,
               "reason": None, "publication": "not-attempted"}
        lanes[lane] = row
        if shared_error:
            row.update(status="skipped-failed", stage="shared-gate", reason=shared_error)
            row["stage_logs"] = [str(path) for path in sorted(stage_log_dir.glob("*.json"))]
            continue
        unavailable = _host_unavailable(lane)
        if unavailable:
            log_path = _write_stage_log(stage_log_dir, f"{lane}-availability", "native host/credentials/device inventory",
                                        status="skipped-unavailable", reason=unavailable)
            row.update(status="skipped-unavailable", stage="host-or-credentials", reason=unavailable,
                       stage_logs=[str(log_path)] if log_path else [])
            continue
        try:
            candidate = _produce_lane(lane, identity, artifact_dir, stage_log_dir)
            row.update(candidate)
            row["candidate_verdict"] = "passed"
            if not row["artifacts"]:
                row.update(status="skipped-failed", artifact_verdict="failed", stage="artifact-verification",
                           reason="no complete current provenance-verified artifact set")
                continue
            row["artifact_verdict"] = "passed"
            row["stage"] = "qualification"
            try:
                _validate_gate_receipts(lane, identity, row)
                row.update(status="verified", reason=None)
            except ValueError as error:
                unknown = any(row["checks"].get(name, {}).get("verdict") == "unknown"
                              for name in REQUIRED_CHECKS[lane])
                row.update(status="skipped-unavailable" if unknown else "skipped-failed", reason=str(error))
        except LookupError as error:
            row.update(status="skipped-unavailable", stage="builder", reason=str(error) or error.__class__.__name__)
            row["stage_logs"] = [str(path) for path in sorted(stage_log_dir.glob(f"{lane}-*.json"))]
        except Exception as error:
            row.update(status="skipped-failed", stage="builder", reason=str(error) or error.__class__.__name__)
            row["stage_logs"] = [str(path) for path in sorted(stage_log_dir.glob(f"{lane}-*.json"))]
    qualified = [row for row in lanes.values() if row.get("status") == "verified"]
    campaign = {"schemaVersion": 1, "mode": "best-effort-prepare", "identity": identity,
                "shared_checks": shared,
                "shared_stage_logs": [str(path) for path in sorted(stage_log_dir.iterdir())
                                      if path.name in {"privacy-policy.json", "source-integrity.json",
                                                       "flutter_analyze.json", "flutter_host_tests.json",
                                                       "shared-gate.json"}],
                "stage_log_directory": str(stage_log_dir.resolve()),
                "status": "failed" if not qualified else ("complete" if len(qualified) == len(LANES) else "partial"),
                "lanes": lanes,
                "verified_artifacts": [item for row in qualified for item in row["artifacts"]],
                "publishers_called": False, "evidence": None}
    _write_campaign(campaign_path, campaign)
    try:
        campaign["evidence"] = _generate_subset_evidence(campaign_path, artifact_dir, campaign, stage_log_dir)
    except Exception as error:
        for row in campaign["lanes"].values():
            if row.get("status") == "verified":
                row.update(status="skipped-failed", stage="evidence", reason=str(error))
        campaign["verified_artifacts"] = []
        campaign["status"] = "failed"
        campaign["evidence"] = {"status": "failed", "reason": str(error)}
    _write_campaign(campaign_path, campaign)
    return campaign


def _read_campaign(path: Path, version: str, build_number: str) -> tuple[dict[str, Any], dict[str, Any]]:
    try:
        campaign = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read prepared campaign: {error}") from error
    if campaign.get("schemaVersion") != 1 or campaign.get("mode") not in {"best-effort-prepare", "best-effort-publish"}:
        raise ValueError("unsupported campaign record")
    identity = frozen_identity(version, build_number)
    if any(str(campaign.get("identity", {}).get(key, "")) != value for key, value in identity.items()):
        raise ValueError("prepared campaign does not match the frozen source/version/lock identity")
    lanes = campaign.get("lanes")
    if not isinstance(lanes, dict) or set(lanes) != set(LANES):
        raise ValueError("campaign must retain exactly seven lane records")
    admitted = []
    for lane in LANES:
        row = lanes[lane]
        if row.get("status") == "verified":
            admitted.extend(verify_lane_candidate(lane, identity, row))
    if not admitted:
        raise ValueError("prepared campaign has no verified artifact subset")
    evidence = campaign.get("evidence")
    manifest_path = Path(evidence.get("manifest", "")) if isinstance(evidence, dict) else Path()
    if not manifest_path.is_file():
        raise ValueError("verified subset evidence manifest is missing")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if (str(manifest.get("version")) != version or str(manifest.get("buildNumber")) != build_number or
            manifest.get("commit") != identity["commit"]):
        raise ValueError("subset evidence identity mismatch")
    manifest_items = {record.get("name"): (record.get("bytes"), record.get("sha256"))
                      for record in manifest.get("artifacts", [])}
    admitted_items = {item["name"]: (item["bytes"], item["sha256"]) for item in admitted}
    if manifest_items != admitted_items:
        raise ValueError("evidence manifest artifact set differs from verified lanes")
    verify_command = [sys.executable, str(ROOT / "scripts/generate_release_evidence.py"),
                      "--list-assets", str(manifest_path), "--version", version,
                      "--build-number", build_number, "--commit", identity["commit"]]
    verified = subprocess.run(verify_command, cwd=ROOT, capture_output=True, text=True, timeout=600)
    if verified.returncode:
        raise ValueError(f"prepared evidence verification failed: {(verified.stderr or verified.stdout)[-1200:]}")
    campaign["verified_artifacts"] = admitted
    return campaign, identity


def _publisher_unavailable(lane: str) -> str | None:
    if lane == "fdroid":
        return "F-Droid has no APK publication API; maintainer acceptance is external"
    if lane == "ios":
        return "no approved signed iOS store publisher is configured"
    if lane == "android_play":
        if not os.environ.get("PLAY_SERVICE_ACCOUNT_JSON"):
            return "Play credentials unavailable"
    elif lane == "web":
        if not os.environ.get("CLOUDFLARE_API_TOKEN") and not (os.environ.get("CLOUDFLARE_API_KEY") and os.environ.get("CLOUDFLARE_EMAIL")):
            return "Cloudflare credentials unavailable"
        if not shutil.which("wrangler"):
            return "Wrangler unavailable"
    elif lane in ("linux", "windows", "macos"):
        if not shutil.which("gh"):
            return "GitHub CLI unavailable"
        if not os.environ.get("GH_TOKEN"):
            auth = subprocess.run(["gh", "auth", "status"], cwd=ROOT, capture_output=True, text=True,
                                  env=_lane_environment("github"))
            if auth.returncode:
                return "GitHub credentials unavailable"
    return None


def publish(version: str, build_number: str, artifact_dir: Path, campaign_path: Path) -> dict[str, Any]:
    campaign, identity = _read_campaign(campaign_path, version, build_number)
    # The prepare mode normally leaves unqualified lanes out. Revalidate only
    # those explicitly admitted and then publish them through lane-scoped adapters.
    adapters = publisher_adapters()
    writes = 0
    for lane in LANES:
        row = campaign["lanes"][lane]
        if row.get("status") != "verified":
            continue
        artifacts = verify_lane_candidate(lane, identity, row)
        envelope = {**row, "status": "verified", "publication_state": row.get("publication"), "artifacts": artifacts,
                    "identity": {key: identity[key] for key in ("version", "build_number", "commit")},
                    "artifact_dir": str(artifact_dir)}
        unavailable = _publisher_unavailable(lane)
        adapter = adapters.get(lane)
        if unavailable or adapter is None:
            row.update(publication="skipped-unavailable", publication_reason=unavailable or "no supported publisher for this lane")
            continue
        row.update(publish_once(envelope, adapter[0], adapter[1]))
        writes += 1
    campaign["mode"] = "best-effort-publish"
    campaign["publishers_called"] = writes > 0
    campaign["status"] = "failed" if not any(row.get("publication") == "published" for row in campaign["lanes"].values()) else "partial"
    _write_campaign(campaign_path, campaign)
    return campaign


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--best-effort", action="store_true", required=True)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--prepare", metavar="X.Y.BUILD")
    modes.add_argument("--publish", metavar="X.Y.BUILD")
    parser.add_argument("--build-number", required=True)
    parser.add_argument("--artifact-dir", type=Path, default=Path(os.environ.get("RELEASE_ARTIFACT_DIR", "release-artifacts")))
    parser.add_argument("--campaign-file", type=Path, default=Path(os.environ.get("RELEASE_CAMPAIGN_FILE", "release-artifacts/campaign.json")))
    args = parser.parse_args(argv)
    version = args.prepare or args.publish
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[1-9][0-9]*", version) or version.rsplit(".", 1)[-1] != args.build_number:
        parser.error("version must be numeric X.Y.BUILD and BUILD must match --build-number")
    artifact_dir, campaign_path = args.artifact_dir.resolve(), args.campaign_file.resolve()
    if args.prepare:
        result = prepare(version, args.build_number, artifact_dir, campaign_path)
    else:
        result = publish(version, args.build_number, artifact_dir, campaign_path)
    print(json.dumps({"status": result["status"], "campaign": str(campaign_path),
                      "verified_lanes": sum(row.get("status") == "verified" for row in result["lanes"].values()),
                      "published_lanes": sum(row.get("publication") == "published" for row in result["lanes"].values())}))
    return 0 if result["status"] in ("complete", "partial") else 1


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print(f"release-campaign: {error}", file=sys.stderr)
        raise SystemExit(1)
