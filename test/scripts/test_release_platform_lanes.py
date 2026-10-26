import base64
import hashlib
import importlib.util
import io
import json
import os
import socket
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "release_platform_lanes", ROOT / "scripts/release_platform_lanes.py"
)
LANES = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(LANES)
NL = chr(10)


class ReleasePlatformLanesTest(unittest.TestCase):
    def setUp(self):
        # Allocate this fixture's loopback server port; never reuse a live app.
        with socket.socket() as probe:
            probe.bind(("127.0.0.1", 0))
            port = probe.getsockname()[1]
        self.assertLessEqual(port, 65436)
        allocation = mock.patch.dict(os.environ, {"AUTOWORK_PORT_BASE": str(port)})
        allocation.start()
        self.addCleanup(allocation.stop)

    def test_cli_prepare_records_all_lanes_and_stops_after_common_gate_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            fake_bin = temp / "bin"
            fake_bin.mkdir()
            flutter = fake_bin / "flutter"
            flutter.write_text("#!/bin/sh" + NL + "printf '%s' \"${GITLAB_CI:-unset}\" > \"$FAKE_GITLAB_MARKER\"" + NL + "echo sandbox-common-gate-failure >&2" + NL + "exit 97" + NL)
            flutter.chmod(0o755)
            campaign_path = temp / "campaign.json"
            env = os.environ.copy()
            env.pop("GITLAB_CI", None)
            marker = temp / "gitlab-env"
            env.update(PATH=str(fake_bin) + os.pathsep + env.get("PATH", ""), FLUTTER_BIN=str(flutter),
                       RELEASE_ARTIFACT_DIR=str(temp / "failed-artifacts"),
                       RELEASE_CAMPAIGN_FILE=str(campaign_path), FAKE_GITLAB_MARKER=str(marker), GITLAB_CI="true")
            result = subprocess.run(
                [str(ROOT / "release.sh"), "--best-effort", "--prepare=1.1.108", "--build-number=108"],
                cwd=ROOT, env=env, text=True, capture_output=True, timeout=30,
            )
            self.assertNotEqual(result.returncode, 0)
            campaign = json.loads(campaign_path.read_text())
            self.assertEqual(set(campaign["lanes"]), set(LANES.LANES))
            self.assertTrue(all(row["status"] == "skipped-failed" for row in campaign["lanes"].values()))
            self.assertFalse(campaign["publishers_called"])
            self.assertNotIn("GitLab", result.stdout + result.stderr)
            self.assertEqual(marker.read_text(), "unset")

    def test_cli_prepare_verifies_only_supported_web_subset_without_publishing(self):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            artifact_dir = temp / "artifacts"
            stale_gate_log = artifact_dir / "stage-logs" / "shared-gate.json"
            stale_gate_log.parent.mkdir(parents=True)
            stale_gate_log.write_text(json.dumps({"status": "failed", "stderr": "sandbox-common-gate-failure"}))
            campaign_path = temp / "campaign.json"
            fake_bin = temp / "bin"
            fake_bin.mkdir()
            flutter = fake_bin / "flutter"
            flutter_source = NL.join([
                "#!/usr/bin/env python3", "import pathlib,sys",
                "args=sys.argv[1:]",
                "if 'build' in args and 'web' in args:",
                " output=next(arg.split('=',1)[1] for arg in args if arg.startswith('--output='))",
                " root=pathlib.Path(output); root.mkdir(parents=True,exist_ok=True)",
                " (root/'index.html').write_text('<html>')",
                " (root/'main.dart.js').write_text('compiled')",
            ]) + NL
            flutter.write_text(flutter_source)
            flutter.chmod(0o755)
            npx = fake_bin / "npx"
            npx.write_text(NL.join([
                "#!/usr/bin/env python3", "import json,os,pathlib,sys",
                "case={'expectedStatus':'passed','status':'expected','projectName':'chromium','results':[{'status':'passed'}]}",
                "report={'stats': {'expected': 1, 'unexpected': 0, 'flaky': 0, 'skipped': 0}, 'errors': [], 'suites':[{'file':sys.argv[4], 'specs':[{'tests':[case]}]}]}",
                "pathlib.Path(os.environ['PLAYWRIGHT_JSON_OUTPUT_FILE']).write_text(json.dumps(report))",
            ]) + NL)
            npx.chmod(0o755)
            fake_bash = fake_bin / "bash"
            fake_bash.write_text(NL.join([
                "#!/bin/sh",
                "case \"$*\" in *'scripts/release.sh fdroid '*|*'scripts/release.sh linux '*) exit 77 ;; esac",
                "exec /bin/bash \"$@\"",
            ]) + NL)
            fake_bash.chmod(0o755)
            env = os.environ.copy()
            env.pop("GITLAB_CI", None)
            env.pop("ANDROID_SDK_ROOT", None)
            env.pop("ANDROID_HOME", None)
            env.update(PATH=str(fake_bin) + os.pathsep + env.get("PATH", ""), FLUTTER_BIN=str(flutter),
                       RELEASE_ARTIFACT_DIR=str(artifact_dir), RELEASE_CAMPAIGN_FILE=str(campaign_path))
            result = subprocess.run([str(ROOT / "release.sh"), "--best-effort", "--prepare=1.1.108",
                                     "--build-number=108"], cwd=ROOT, env=env, capture_output=True,
                                    text=True, timeout=120)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr + NL + campaign_path.read_text())
            campaign = json.loads(campaign_path.read_text())
            self.assertEqual(campaign["status"], "partial")
            self.assertTrue(campaign["publishers_called"] is False)
            self.assertEqual(set(campaign["lanes"]), set(LANES.LANES))
            for lane, row in campaign["lanes"].items():
                self.assertEqual(set(row["checks"]), set(LANES.REQUIRED_CHECKS[lane]))
                self.assertIn(row["candidate_verdict"], {"unknown", "passed", "failed"})
                self.assertIn(row["artifact_verdict"], {"unknown", "passed", "failed"})
                if row["status"] != "verified":
                    self.assertTrue(row["reason"])
            self.assertEqual([item["name"] for item in campaign["verified_artifacts"]],
                             ["fractal-forge-web-v1.1.108.tar.gz"])
            manifest = json.loads(Path(campaign["evidence"]["manifest"]).read_text())
            self.assertEqual([item["name"] for item in manifest["artifacts"]],
                             ["fractal-forge-web-v1.1.108.tar.gz"])
            self.assertEqual(campaign["lanes"]["web"]["checks"]["browser_journey"]["verdict"], "passed")
            self.assertNotIn(str(stale_gate_log), campaign["shared_stage_logs"])
            self.assertNotEqual(campaign["stage_log_directory"], str(stale_gate_log.parent))
            lane_logs = campaign["lanes"]["web"]["stage_logs"]
            self.assertTrue(lane_logs)
            self.assertTrue(all(Path(path).parent == Path(campaign["stage_log_directory"])
                                for path in lane_logs))

    def test_web_archive_inventory_uses_regular_members_and_rejects_tampering(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        files = {"index.html": b"<html>", "main.dart.js": b"compiled",
                 "assets/shaders/fractal.frag": b"shader"}
        for fault in (None, "extra", "hash", "symlink", "hardlink", "absolute", "parent",
                      "version", "build_number", "commit", "browser_failed", "browser_unavailable", "browser_timeout"):
            with self.subTest(fault=fault), tempfile.TemporaryDirectory() as directory:
                archive = Path(directory) / "web.tar.gz"
                manifest = {**identity, "files": {name: hashlib.sha256(data).hexdigest()
                                               for name, data in files.items()}}
                if fault == "hash":
                    manifest["files"]["assets/shaders/fractal.frag"] = "0" * 64
                elif fault in identity:
                    manifest[fault] = "wrong"
                contents = {**files, "release-identity.json": json.dumps(manifest).encode()}
                if fault == "extra":
                    contents["unlisted.js"] = b"unlisted"
                with tarfile.open(archive, "w:gz") as bundle:
                    for name in ("web", "web/assets", "web/assets/shaders"):
                        member = tarfile.TarInfo(name)
                        member.type = tarfile.DIRTYPE
                        bundle.addfile(member)
                    for name, data in contents.items():
                        member = tarfile.TarInfo(f"web/{name}")
                        member.size = len(data)
                        bundle.addfile(member, io.BytesIO(data))
                    if fault in ("symlink", "hardlink", "absolute", "parent"):
                        member = tarfile.TarInfo({"absolute": "/unsafe", "parent": "web/../unsafe"}.get(
                            fault, "web/unsafe-link"))
                        if fault in ("symlink", "hardlink"):
                            member.type = tarfile.SYMTYPE if fault == "symlink" else tarfile.LNKTYPE
                            member.linkname = "web/index.html"
                        bundle.addfile(member)
                with tarfile.open(archive, "r:gz") as bundle:
                    self.assertTrue(any(member.isdir() and member.name == "web/assets/shaders"
                                        for member in bundle.getmembers()))
                artifact = {"path": str(archive), "sha256": LANES.sha256_file(archive)}
                # Only browser execution is doubled; archive checks and HTTP serving are real.
                completed = subprocess.CompletedProcess([], 1 if fault == "browser_failed" else 0,
                                                        stdout="unit fixture only", stderr="fixture stderr")
                error = (FileNotFoundError("fixture unavailable") if fault == "browser_unavailable" else
                         subprocess.TimeoutExpired(["npx"], 1800, output=b"partial fixture", stderr=b"timeout stderr")
                         if fault == "browser_timeout" else None)
                def browser_result(command, **kwargs):
                    if error:
                        raise error
                    spec = next(arg for arg in command if arg.endswith('.spec.mjs'))
                    Path(kwargs["env"]["PLAYWRIGHT_JSON_OUTPUT_FILE"]).write_text(json.dumps({
                        "stats": {"expected": 1, "unexpected": 0, "flaky": 0, "skipped": 0}, "errors": [],
                        "suites": [{"file": spec, "specs": [{"tests": [{"expectedStatus": "passed",
                            "status": "expected", "projectName": "chromium", "results": [{"status": "passed"}]}]}]}]}))
                    return completed
                with mock.patch.object(LANES.subprocess, "run", side_effect=browser_result) as browser:
                    checks = LANES._web_qualification(identity, [artifact])
                if fault is None or fault.startswith("browser_"):
                    self.assertEqual(set(checks), set(LANES.REQUIRED_CHECKS["web"]))
                    self.assertEqual(checks["asset_validation"]["artifact_sha256"], [artifact["sha256"]])
                    self.assertEqual(browser.call_count, 2)
                    self.assertEqual([next(arg for arg in call.args[0] if arg.endswith('.spec.mjs'))
                                      for call in browser.call_args_list], [
                        "test/playwright/web-image-creation-journey.spec.mjs",
                        "test/playwright/production-saved-session.spec.mjs"])
                    expected = ("failed" if fault in {"browser_failed", "browser_timeout"} else
                                "unknown" if fault == "browser_unavailable" else "passed")
                    paths = []
                    for check in ("browser_journey", "saved_data"):
                        receipt = checks[check]
                        self.assertEqual(receipt["verdict"], expected)
                        evidence = Path(receipt["evidence_dir"])
                        self.assertFalse(evidence.is_relative_to(ROOT))
                        paths.append(evidence)
                        self.assertTrue((evidence / "stdout.log").is_file())
                        self.assertTrue((evidence / "stderr.log").is_file())
                        self.assertEqual(json.loads((evidence / "receipt.json").read_text()), receipt)
                        if fault == "browser_failed":
                            self.assertEqual(receipt["exit_code"], 1)
                            self.assertEqual((evidence / "stderr.log").read_text(), "fixture stderr")
                        elif fault == "browser_timeout":
                            self.assertEqual((evidence / "stdout.log").read_text(), "partial fixture")
                    self.assertNotEqual(*paths)
                    for call, evidence in zip(browser.call_args_list, paths):
                        self.assertIn(f"--output={evidence / 'results'}", call.args[0])
                        self.assertIn("--reporter=list,json,html", call.args[0])
                        self.assertEqual(call.kwargs["env"]["PLAYWRIGHT_JSON_OUTPUT_FILE"],
                                         str(evidence / "report.json"))
                        self.assertEqual(call.kwargs["env"]["PLAYWRIGHT_HTML_OUTPUT_DIR"],
                                         str(evidence / "html"))
                else:
                    self.assertEqual(checks, {})
                    browser.assert_not_called()

    def test_github_create_targets_frozen_commit_as_published_release(self):
        lane = {"identity": {"version": "1.1.108", "commit": "a" * 40},
                "artifacts": [{"path": "/sandbox/linux.tar.gz"}]}
        with mock.patch.object(LANES.shutil, "which", return_value="/sandbox/gh"), \
             mock.patch.object(LANES.subprocess, "run", side_effect=[
                 subprocess.CompletedProcess([], 1, stdout="", stderr="release not found"),
                 subprocess.CompletedProcess([], 0, stdout="", stderr=""),
                 subprocess.CompletedProcess([], 0, stdout="", stderr="")]) as run:
            self.assertEqual(LANES._github_write(lane), {"tag": "v1.1.108"})
        command = run.call_args.args[0]
        self.assertEqual(command[:4], ["gh", "release", "create", "v1.1.108"])
        self.assertIn("--target", command)
        self.assertEqual(command[command.index("--target") + 1], lane["identity"]["commit"])
        self.assertFalse(any(arg.startswith(("--draft", "--prerelease")) for arg in command))

    def test_github_existing_tag_must_match_frozen_commit_before_writing_or_readback(self):
        commit, tag = "a" * 40, "v1.1.108"
        lane = {"identity": {"version": "1.1.108", "commit": commit},
                "artifacts": [{"name": "linux.tar.gz", "path": "/sandbox/linux.tar.gz"}]}
        release = subprocess.CompletedProcess([], 0, stdout=json.dumps(
            {"isDraft": False, "isPrerelease": False, "assets": []}), stderr="")
        for annotated in (False, True):
            for matches in (False, True):
                for exists in (False, True):
                    with self.subTest(annotated=annotated, matches=matches, exists=exists):
                        ref = f"refs/tags/{tag}"
                        target = commit if matches else "b" * 40
                        output = (f"{'c' * 40}\t{ref}\n{target}\t{ref}^{{}}\n" if annotated
                                  else f"{target}\t{ref}\n")
                        remote = subprocess.CompletedProcess([], 0, stdout=output, stderr="")
                        view = release if exists else subprocess.CompletedProcess(
                            [], 1, stdout="", stderr="release not found")
                        with mock.patch.object(LANES.shutil, "which", return_value="/sandbox/gh"), \
                             mock.patch.object(LANES.subprocess, "run", side_effect=[
                                 view, remote, subprocess.CompletedProcess([], 0, stdout="", stderr="")]) as run:
                            if matches:
                                LANES._github_write(lane)
                                self.assertEqual(run.call_args.args[0][2], "upload" if exists else "create")
                                self.assertEqual(run.call_count, 3)
                            else:
                                with self.assertRaisesRegex(RuntimeError, "tag.*commit"):
                                    LANES._github_write(lane)
                                self.assertEqual(run.call_count, 2)
                        if exists:
                            with mock.patch.object(LANES.subprocess, "run", side_effect=[release, remote]) as run:
                                observed = LANES._github_readback(lane, None)
                            self.assertEqual(observed.get("conflict", False), not matches)
                            self.assertFalse(observed["found"])
                            self.assertEqual(run.call_count, 2)

    def test_verified_lane_reaches_publisher_when_an_independent_lane_fails(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "web.zip"
            artifact.write_bytes(b"verified web bundle")
            digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
            receipt = {"path": str(artifact), "name": artifact.name, "bytes": artifact.stat().st_size, "sha256": digest}
            Path(str(artifact) + ".provenance").write_text(NL.join([
                "version=1.1.108", "build_number=108", f"commit={identity['commit']}", f"sha256={digest}", ""
            ]))
            sent = []

            def valid_web(frozen):
                return {**frozen, "candidate": "web-candidate", "artifacts": [receipt],
                        "checks": {gate: {"check": gate, "verdict": "passed", "artifact_sha256": [receipt["sha256"]], **frozen}
                                   for gate in LANES.REQUIRED_CHECKS["web"]}}

            result = LANES.run_campaign(
                identity,
                {"web": valid_web, "linux": lambda frozen: (_ for _ in ()).throw(RuntimeError("build failed"))},
                {"web": (lambda lane: sent.append(lane["artifacts"]) or "deploy-7",
                          lambda lane, publication_id: ({"found": False} if publication_id is None
                                                        else {"found": True, "id": publication_id}))},
                lambda frozen: None,
            )
            self.assertEqual(result["status"], "partial")
            self.assertEqual(result["lanes"]["web"]["publication"], "published")
            self.assertEqual(result["lanes"]["linux"]["status"], "skipped-failed")
            self.assertEqual(result["lanes"]["windows"]["status"], "skipped-unavailable")
            self.assertEqual(len(sent), 1)

    def test_publish_cli_uses_lane_adapter_and_remote_readback_without_rebuilding(self):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            artifact_dir = temp / "artifacts"
            artifact_dir.mkdir()
            artifact = artifact_dir / "fractal-forge-web-v1.1.108.tar.gz"
            web_root = temp / "web"
            web_root.mkdir()
            (web_root / "index.html").write_text("sandbox web candidate")
            (web_root / "main.dart.js").write_text("compiled candidate")
            identity = LANES.frozen_identity("1.1.108", "108")
            file_hashes = {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
                           for path in sorted(web_root.iterdir()) if path.is_file()}
            remote_identity = {"version": identity["version"], "build_number": identity["build_number"],
                               "commit": identity["commit"], "files": file_hashes}
            (web_root / "release-identity.json").write_text(json.dumps(remote_identity, sort_keys=True) + NL)
            with tarfile.open(artifact, "w:gz") as bundle:
                bundle.add(web_root, arcname="web")
            digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
            Path(str(artifact) + ".provenance").write_text(NL.join([
                "version=1.1.108", "build_number=108", f"commit={identity['commit']}", f"sha256={digest}", ""
            ]))
            web = {"candidate": "web-candidate", "version": "1.1.108", "build_number": "108",
                   "commit": identity["commit"], "status": "verified", "publication": "not-attempted",
                   "artifacts": [{"name": artifact.name, "path": str(artifact), "bytes": artifact.stat().st_size, "sha256": digest}],
                   "checks": {name: {"check": name, "verdict": "passed", "artifact_sha256": [digest], "version": "1.1.108",
                                     "build_number": "108", "commit": identity["commit"]}
                              for name in LANES.REQUIRED_CHECKS["web"]}}
            rows = {lane: {"status": "skipped-unavailable", "reason": "fixture lane skipped",
                           "candidate": None, "artifacts": [], "checks": {}, "publication": "not-attempted"}
                    for lane in LANES.LANES}
            rows["web"] = web
            evidence_dir = artifact_dir / "evidence"
            evidence_dir.mkdir()
            sbom = evidence_dir / "sbom.cdx.json"
            notices = evidence_dir / "THIRD_PARTY_NOTICES.txt"
            inventory = evidence_dir / "ANDROID_NATIVE_INVENTORY.txt"
            sbom.write_text(json.dumps({"bomFormat": "CycloneDX", "components": [{"name": "fixture"}]}))
            notices.write_text("Fractal Forge third-party notices" + NL + "===== fixture =====" + NL + "MIT" + NL)
            inventory.write_text("Fractal Forge Android/native declaration inventory" + NL +
                                 "No checked-in native dependency declarations found." + NL)
            manifest = {"version": "1.1.108", "buildNumber": "108", "commit": identity["commit"],
                        "generatedAt": "2026-10-17T00:00:00Z",
                        "artifacts": [{"name": artifact.name, "path": "../" + artifact.name,
                                       "bytes": artifact.stat().st_size, "sha256": digest}],
                        "evidence": {"sbom": sbom.name, "androidNativeInventory": inventory.name,
                                     "thirdPartyNotices": notices.name, "checksums": "SHA256SUMS"}}
            manifest_path = evidence_dir / "release-manifest.json"
            manifest_path.write_text(json.dumps(manifest, indent=2) + NL)
            sums = [f"{digest}  ../{artifact.name}"]
            for path in (manifest_path, sbom, notices, inventory):
                sums.append(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}")
            (evidence_dir / "SHA256SUMS").write_text(NL.join(sums) + NL)
            campaign_path = temp / "campaign.json"
            campaign_path.write_text(json.dumps({"schemaVersion": 1, "mode": "best-effort-prepare",
                                                  "identity": identity, "lanes": rows, "status": "partial",
                                                  "evidence": {"status": "verified", "manifest": str(manifest_path)},
                                                  "verified_artifacts": [web["artifacts"][0]]}))
            fake_bin = temp / "bin"
            fake_bin.mkdir()
            calls = temp / "calls"
            state = temp / "deployed"
            wrangler = fake_bin / "wrangler"
            fake_curl = fake_bin / "curl"
            fake_curl.write_text(NL.join([
                "#!/usr/bin/env python3", "import os,sys,urllib.parse,pathlib",
                "path=urllib.parse.urlparse(sys.argv[-1]).path.rsplit('/',1)[-1]",
                "source=pathlib.Path(os.environ['FAKE_WEB_ROOT'])/path",
                "sys.stdout.buffer.write(source.read_bytes())",
            ]) + NL)
            fake_curl.chmod(0o755)
            wrangler_source = NL.join([
                "#!/usr/bin/env python3", "import json, os, sys",
                "open(os.environ['FAKE_CALLS'], 'a').write(' '.join(sys.argv[1:]) + '\\n')",
                "if sys.argv[1:3] == ['pages', 'deploy']:",
                " open(os.environ['FAKE_STATE'], 'w').write('deployed'); sys.exit(0)",
                "if sys.argv[1:4] == ['pages', 'deployment', 'list']:",
                " deployments = [{'id':'deploy-7','url':'https://example.pages.dev','commit_hash':os.environ['FAKE_COMMIT'],'commit_message':'1.1.108:'+os.environ['FAKE_SHA']}] if os.path.exists(os.environ['FAKE_STATE']) else []",
                " print(json.dumps(deployments))",
            ]) + NL
            wrangler.write_text(wrangler_source)
            wrangler.chmod(0o755)
            env = os.environ.copy()
            env.pop("GITLAB_CI", None)
            env.update(PATH=str(fake_bin) + os.pathsep + env.get("PATH", ""),
                       RELEASE_CAMPAIGN_FILE=str(campaign_path), RELEASE_ARTIFACT_DIR=str(artifact_dir),
                       CLOUDFLARE_API_TOKEN="sandbox-token", FAKE_CALLS=str(calls), FAKE_COMMIT=identity["commit"],
                       FAKE_SHA=digest, FAKE_STATE=str(state), FAKE_WEB_ROOT=str(web_root))
            result = subprocess.run([str(ROOT / "release.sh"), "--best-effort", "--publish=1.1.108",
                                     "--build-number=108"], cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr + NL + campaign_path.read_text())
            published = json.loads(campaign_path.read_text())
            self.assertEqual(published["lanes"]["web"]["publication"], "published")
            resumed = subprocess.run([str(ROOT / "release.sh"), "--best-effort", "--publish=1.1.108",
                                      "--build-number=108"], cwd=ROOT, env=env, capture_output=True,
                                     text=True, timeout=30)
            self.assertEqual(resumed.returncode, 0, resumed.stdout + resumed.stderr)
            commands = calls.read_text().splitlines()
            self.assertEqual(len(commands), 4)
            self.assertEqual(sum(command.startswith("pages deploy ") for command in commands), 1)
            self.assertTrue(commands[0].startswith("pages deployment list "))
            self.assertTrue(commands[1].startswith("pages deploy "))
            self.assertTrue(commands[2].startswith("pages deployment list "))
            self.assertTrue(commands[3].startswith("pages deployment list "))

    def test_web_formatted_cli_rows_still_require_full_manifest_and_asset_identity(self):
        identity = {"version": "1.1.110", "build_number": "110", "commit": "a" * 40}
        content = b"qualified app"
        expected = {**identity, "files": {"index.html": hashlib.sha256(content).hexdigest()}}
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / "web.tar.gz"
            encoded = json.dumps(expected).encode()
            with tarfile.open(archive, "w:gz") as bundle:
                member = tarfile.TarInfo("web/release-identity.json")
                member.size = len(encoded)
                bundle.addfile(member, io.BytesIO(encoded))
            lane = {"identity": identity, "artifacts": [{"path": str(archive), "sha256": "f" * 64}]}
            row = {"Id": "deployment-fixture", "Environment": "Production", "Branch": "main",
                   "Source": identity["commit"][:7], "Deployment": "https://fixture.pages.dev"}
            for fault in (None, "manifest", "asset", "preview", "mixed"):
                with self.subTest(fault=fault):
                    observed = {**expected, "commit": "b" * 40} if fault == "manifest" else expected
                    displayed = {**row, "Environment": "Preview"} if fault == "preview" else row
                    if fault == "mixed":
                        displayed = {**row, "commit_hash": "b" * 40}
                    replies = [subprocess.CompletedProcess([], 0, stdout=json.dumps([displayed]), stderr=""),
                               subprocess.CompletedProcess([], 0, stdout=json.dumps(observed), stderr=""),
                               subprocess.CompletedProcess([], 0, stdout=b"wrong" if fault == "asset" else content, stderr=b"")]
                    with mock.patch.object(LANES.subprocess, "run", side_effect=replies) as run:
                        result = LANES._web_readback(lane, None)
                    self.assertEqual(result["found"], fault is None)
                    if fault is None:
                        self.assertEqual(result["deployment_id"], row["Id"])
                        self.assertEqual(result["verified_file_count"], 1)
                    elif fault not in {"preview", "mixed"}:
                        self.assertTrue(result["conflict"])
                    else:
                        self.assertEqual(run.call_count, 1)

    def test_linux_native_qualification_rejects_exit_zero_without_protocol_proof(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        artifact = {"name": "linux.tar.gz", "path": "/sandbox/linux.tar.gz", "sha256": "f" * 64}
        completed = subprocess.CompletedProcess([], 0, stdout="full journey and decoded PNG passed", stderr="")
        with mock.patch.object(LANES.platform, "system", return_value="Linux"), \
             mock.patch.object(LANES.subprocess, "run", return_value=completed) as run:
            checks = LANES.run_native_qualification("linux", identity, [artifact])
        self.assertEqual(set(checks), {"native_journey", "export_validation"})
        self.assertTrue(all(check["verdict"] == "failed" for check in checks.values()))
        self.assertTrue(all("protocol" in check["reason"] for check in checks.values()))
        self.assertTrue(all(check["artifact_sha256"] == [artifact["sha256"]] for check in checks.values()))
        command = run.call_args.args[0]
        self.assertIn("integration_test/flows/user_flows_test.dart", command)
        self.assertNotIn("--plain-name", command)
        with self.assertRaisesRegex(ValueError, "required qualification is not verified"):
            LANES._validate_gate_receipts("linux", identity,
                                         {"checks": checks, "artifacts": [artifact]})

    def test_linux_native_journey_timeout_is_a_failed_receipt_with_a_log(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        artifact = {"name": "linux.tar.gz", "path": "/sandbox/linux.tar.gz", "sha256": "f" * 64}
        with (
            tempfile.TemporaryDirectory() as directory,
            mock.patch.object(LANES.platform, "system", return_value="Linux"),
            mock.patch.object(LANES.subprocess, "run", side_effect=subprocess.TimeoutExpired("flutter test", 3600)),
        ):
            checks = LANES.run_native_qualification("linux", identity, [artifact], Path(directory))
            log = json.loads((Path(directory) / "linux-native-journey.json").read_text())
        self.assertTrue(all(check["verdict"] == "failed" for check in checks.values()))
        self.assertEqual(log["status"], "timeout")
        self.assertIn("timed out", log["reason"])

    def test_evidence_timeout_retains_partial_stage_output(self):
        campaign = {"identity": {"version": "1.1.108", "build_number": "108", "commit": "a" * 40},
                    "lanes": {"web": {"status": "verified", "artifacts": []}}}
        for stage in ("evidence-generation", "evidence-verification"):
            with self.subTest(stage=stage), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                timeout = subprocess.TimeoutExpired("evidence", 600, output=b"partial output")
                results = ([subprocess.CompletedProcess([], 0, stdout="", stderr="")]
                           if stage == "evidence-verification" else []) + [timeout]
                with mock.patch.object(LANES.subprocess, "run", side_effect=results):
                    with self.assertRaises(subprocess.TimeoutExpired):
                        LANES._generate_subset_evidence(root / "campaign.json", root, campaign, root / "logs")
                log = json.loads((root / "logs" / f"{stage}.json").read_text())
                self.assertEqual(log["status"], "timeout")
                self.assertIn("partial output", log["stdout"])

    def test_release_stage_log_preserves_command_exit_and_complete_output(self):
        with tempfile.TemporaryDirectory() as directory:
            path = LANES._write_stage_log(
                Path(directory), "linux-native-journey",
                ["flutter", "test", "integration_test/flows/user_flows_test.dart"],
                status="passed", returncode=0, stdout="12 passed, 1 skipped\n", stderr="",
            )
            contents = path.read_text()
        self.assertIn('"returncode": 0', contents)
        self.assertIn('"status": "passed"', contents)
        self.assertIn("12 passed, 1 skipped", contents)


    def test_play_readback_requires_track_and_remote_bundle_hash_using_command_doubles(self):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            fake_bin = temp / "bin"
            fake_bin.mkdir()
            calls = temp / "curl.calls"
            curl = fake_bin / "curl"
            curl.write_text(NL.join([
                "#!/usr/bin/env python3", "import json,os,sys",
                "args=sys.argv[1:]; url=next(arg for arg in reversed(args) if arg.startswith('https://')); method=args[args.index('-X')+1] if '-X' in args else 'GET'",
                "open(os.environ['FAKE_CURL_CALLS'],'a').write(method+' '+url+'\\n')",
                "if 'oauth2.googleapis.com/token' in url: print(json.dumps({'access_token':'test-token'}))",
                "elif url.endswith('/edits') and method == 'POST': print(json.dumps({'id':'draft-edit'}))",
                "elif '/tracks/' in url: print(json.dumps({'releases':[{'versionCodes':['108'],'status':'completed'}]}))",
                "elif url.endswith('/bundles'): print(json.dumps({'bundles':[{'versionCode':'108','sha256':os.environ['FAKE_REMOTE_SHA']}]}))",
                "else: print('{}')",
            ]) + NL)
            curl.chmod(0o755)
            openssl = fake_bin / "openssl"
            openssl.write_text("#!/bin/sh" + NL + "if [ \"$1\" = dgst ]; then cat >/dev/null; printf signature; else exec /usr/bin/openssl \"$@\"; fi" + NL)
            openssl.chmod(0o755)
            credentials = temp / "service-account.json"
            credentials.write_text(json.dumps({"client_email": "release@example.invalid", "private_key": "test-key"}))
            artifact_hash = hashlib.sha256(b"verified AAB").digest()
            env = os.environ.copy()
            env.update(PATH=str(fake_bin) + os.pathsep + env.get("PATH", ""), TMPDIR=str(temp),
                       PLAY_SERVICE_ACCOUNT_JSON=str(credentials), PLAY_TRACK="production",
                       PLAY_RELEASE_STATUS="completed", FAKE_CURL_CALLS=str(calls),
                       FAKE_REMOTE_SHA=base64.b64encode(artifact_hash).decode())
            command = ["bash", str(ROOT / "scripts/ci/play-readback.sh"), "108", artifact_hash.hex()]
            matched = subprocess.run(command, cwd=ROOT, env=env, text=True, capture_output=True, timeout=15)
            self.assertEqual(matched.returncode, 0, matched.stderr)
            self.assertTrue(json.loads(matched.stdout)["found"])
            env["FAKE_REMOTE_SHA"] = base64.b64encode(hashlib.sha256(b"different bundle").digest()).decode()
            mismatched = subprocess.run(command, cwd=ROOT, env=env, text=True, capture_output=True, timeout=15)
            self.assertEqual(mismatched.returncode, 0, mismatched.stderr)
            self.assertFalse(json.loads(mismatched.stdout)["found"])
            requests = calls.read_text().splitlines()
            self.assertEqual(sum("POST https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.trebuchetdynamics.fractal.forge/edits" == request for request in requests), 2)
            self.assertFalse(any("upload" in request or "commit" in request for request in requests))
            self.assertEqual(sum("DELETE https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.trebuchetdynamics.fractal.forge/edits/draft-edit" == request for request in requests), 2)

    def test_native_unknown_receipts_remain_unqualified_and_never_reach_publishers(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        host = {"windows": "Windows", "macos": "Darwin", "ios": "Darwin"}
        for lane, system in host.items():
            with mock.patch.object(LANES.platform, "system", return_value=system), \
                 mock.patch.object(LANES.subprocess, "run") as run:
                receipts = LANES.run_native_qualification(lane, identity, [])
            self.assertTrue(all(receipt["verdict"] == "unknown" and receipt.get("reason")
                                for receipt in receipts.values()))
            run.assert_not_called()
        with tempfile.TemporaryDirectory() as directory:
            builders, publishers, writes = {}, {}, []
            for lane in ("linux", "windows", "macos", "ios"):
                artifact = Path(directory) / f"{lane}.zip"
                artifact.write_bytes(lane.encode())
                digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
                Path(f"{artifact}.provenance").write_text(NL.join([
                    f"version={identity['version']}", f"build_number={identity['build_number']}",
                    f"commit={identity['commit']}", f"sha256={digest}", ""
                ]))
                receipt = {"name": artifact.name, "path": str(artifact), "bytes": artifact.stat().st_size,
                           "sha256": digest}
                checks = {name: {"check": name, "verdict": "unknown", **identity}
                          for name in LANES.REQUIRED_CHECKS[lane]}
                builders[lane] = lambda frozen, lane=lane, receipt=receipt, checks=checks: {
                    **frozen, "candidate": f"{lane}-candidate", "artifacts": [receipt], "checks": checks}
                publishers[lane] = (lambda record: writes.append(record), lambda record, publication: None)
            result = LANES.run_campaign(identity, builders, publishers, lambda frozen: None)
        for lane in ("linux", "windows", "macos", "ios"):
            self.assertEqual(result["lanes"][lane]["status"], "skipped-unavailable")
            self.assertIn("required qualification is not verified", result["lanes"][lane]["reason"])
        self.assertEqual(writes, [])

    def test_wrong_android_certificate_is_rejected(self):
        pinned = "AA:BB:CC:DD"
        self.assertEqual(LANES.validate_certificate_fingerprint(pinned, "aabbccdd"), "AABBCCDD")
        with self.assertRaisesRegex(ValueError, "pinned upload certificate"):
            LANES.validate_certificate_fingerprint(pinned, "00:11:22:33")

    def test_missing_publisher_is_an_explicit_lane_skip(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "web.zip"
            artifact.write_bytes(b"bundle")
            digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
            Path(str(artifact) + ".provenance").write_text(NL.join([
                "version=1.1.108", "build_number=108", f"commit={identity['commit']}", f"sha256={digest}", ""
            ]))
            receipt = {"path": str(artifact), "name": artifact.name, "bytes": artifact.stat().st_size, "sha256": digest}
            result = LANES.run_campaign(
                identity,
                {"web": lambda frozen: {**frozen, "candidate": "web", "artifacts": [receipt],
                                        "checks": {name: {"check": name, "verdict": "passed", "artifact_sha256": [digest], **frozen}
                                                   for name in LANES.REQUIRED_CHECKS["web"]}}},
                {}, lambda frozen: None,
            )
            self.assertEqual(result["lanes"]["web"]["status"], "skipped-unavailable")
            self.assertEqual(result["lanes"]["web"]["reason"], "publisher unavailable")

    def test_stale_tampered_empty_and_wrong_identity_artifacts_are_rejected(self):
        identity = {"version": "1.1.108", "build_number": "108", "commit": "a" * 40}
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "bundle.zip"
            artifact.write_bytes(b"bundle")
            digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
            receipt = {"sha256": hashlib.sha256(b"other").hexdigest()}
            base = {**identity, "candidate": "web",
                    "checks": {g: {"check": g, "verdict": "passed", "artifact_sha256": [receipt["sha256"]], **identity} for g in LANES.REQUIRED_CHECKS["web"]},
                    "artifacts": [{"path": str(artifact), "name": artifact.name, "bytes": artifact.stat().st_size,
                                   "sha256": receipt["sha256"]}]}
            with self.assertRaisesRegex(ValueError, "hash"):
                LANES.verify_lane_candidate("web", identity, base)
            base["artifacts"][0]["sha256"] = digest
            receipt["sha256"] = digest
            for check in base["checks"].values():
                check["artifact_sha256"] = [digest]
            Path(str(artifact) + ".provenance").write_text(NL.join([
                f"version={identity['version']}", f"build_number={identity['build_number']}",
                f"commit={identity['commit']}", f"sha256={digest}", ""
            ]))
            wrong = {**base, "version": "1.1.107"}
            with self.assertRaisesRegex(ValueError, "identity"):
                LANES.verify_lane_candidate("web", identity, wrong)
            artifact.write_bytes(b"")
            with self.assertRaisesRegex(ValueError, "empty"):
                LANES.verify_lane_candidate("web", identity, base)
            artifact.unlink()
            with self.assertRaisesRegex(ValueError, "missing or linked artifact"):
                LANES.verify_lane_candidate("web", identity, base)

    def test_ambiguous_write_is_read_back_once_and_never_retried(self):
        record = {"status": "verified", "artifacts": [{"path": "bundle.zip", "sha256": "x"}]}
        writes, reads = [], []

        def publisher(lane):
            writes.append(lane)
            raise TimeoutError("response lost")

        def readback(lane, publication_id):
            reads.append(lane)
            return {"found": False} if publication_id is None else {"found": True, "id": "already-published"}

        result = LANES.publish_once(record, publisher, readback)
        self.assertEqual(result["publication"], "published")
        self.assertEqual((len(writes), len(reads)), (1, 2))


if __name__ == "__main__":
    unittest.main()
