import hashlib
import importlib.util
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


class ReleaseEvidenceTest(unittest.TestCase):
    def test_release_pipeline_stages_and_attaches_evidence(self):
        root = Path(__file__).resolve().parents[2]
        release_script = (root / "scripts" / "release.sh").read_text()
        evidence_script = (
            root / "scripts" / "generate_release_evidence.py"
        ).read_text()
        self.assertIn("stage_evidence", release_script)
        self.assertIn("generate_release_evidence.py", release_script)
        self.assertIn('artifacts+=("$ARTIFACT_DIR"/*.aab', release_script)
        for target in (
            "android-arm:armeabi-v7a",
            "android-arm64:arm64-v8a",
            "android-x64:x86_64",
        ):
            self.assertIn(target, release_script)
        self.assertIn('--target-platform="$target"', release_script)
        self.assertIn('--build-number "$build_number"', release_script)
        android_build_stage = release_script.split(
            "stage_android_build() {", 1
        )[1].split("stage_play() {", 1)[0]
        play_stage = release_script.split("stage_play() {", 1)[1].split(
            "stage_android() {", 1
        )[0]
        self.assertLess(
            android_build_stage.index("build-play-console.sh"),
            android_build_stage.index('build apk --release --target-platform="$target"'),
        )
        self.assertIn("--verify", android_build_stage)
        self.assertNotIn("build-upload-playstore.sh", android_build_stage)
        self.assertIn('verify_android_aab "$staged_aab"', android_build_stage)
        self.assertIn('bundletool-all-${version}.jar', release_script)
        self.assertIn('validate --bundle="$aab"', release_script)
        self.assertIn('dump manifest --bundle="$aab"', release_script)
        self.assertIn('keytool -printcert -jarfile "$aab"', release_script)
        self.assertIn('jarsigner -verify "$aab"', release_script)
        self.assertIn('android/play-upload-cert-sha1.txt', release_script)
        self.assertIn('verify_android_apk "$artifact" "$abi"', android_build_stage)
        self.assertIn('--android-project-arg="release-abi=$abi"', android_build_stage)
        self.assertIn('dump badging "$apk"', release_script)
        self.assertIn('"$apksigner" verify --print-certs "$apk"', release_script)
        self.assertIn('native_abis', release_script)
        self.assertIn('Signer #1 certificate SHA-1 digest:', release_script)
        self.assertIn('--prebuilt-aab "$staged_aab"', play_stage)
        self.assertIn('--expected-version "$RESOLVED_ANDROID_VERSION"', play_stage)
        self.assertIn(
            '--expected-build-number "$RESOLVED_ANDROID_BUILD_NUMBER"', play_stage
        )
        github_stage = release_script.split("stage_github() {", 1)[1].split(
            "stage_website() {", 1
        )[0]
        self.assertIn('--snapshot-assets "$manifest"', github_stage)
        self.assertIn('--snapshot-dir "$snapshot_dir"', github_stage)
        self.assertIn('manifest_bytes = manifest_path.read_bytes()', evidence_script)
        self.assertIn('snapshot_manifest.write_bytes(manifest_bytes)', evidence_script)
        self.assertNotIn(
            'shutil.copyfile(manifest_path, snapshot_evidence / manifest_path.name)',
            evidence_script,
        )
        self.assertIn('mapfile -t assets', github_stage)
        self.assertNotIn('assets+=("$ARTIFACT_DIR"/*.aab', github_stage)
        self.assertIn('--log-dir "$FINAL_DEVICE_EVIDENCE_DIR"', release_script)
        self.assertIn('device-gate-${evidence_name}', release_script)
        upload_script = (root / "scripts" / "build-upload-playstore.sh").read_text()
        self.assertIn('--prebuilt-aab', upload_script)
        self.assertIn('--expected-version', upload_script)
        self.assertIn('--expected-build-number', upload_script)
        self.assertIn('VERSION_NAME" == "$EXPECTED_VERSION', upload_script)
        self.assertIn('BUILD_NUMBER" == "$EXPECTED_BUILD_NUMBER', upload_script)
        self.assertIn('VERSION_CODE" == "$EXPECTED_BUILD_NUMBER', upload_script)
        self.assertIn('UPLOAD_SNAPSHOT', upload_script)
        self.assertIn('--bundle="$AAB_PATH" --xpath', upload_script)
        self.assertIn('AAB_VERSION_NAME" == "$EXPECTED_VERSION', upload_script)
        self.assertIn('AAB_VERSION_CODE" == "$EXPECTED_BUILD_NUMBER', upload_script)
        self.assertIn('AAB_PACKAGE" == "$PACKAGE_NAME', upload_script)
        self.assertIn('actual_package" == "com.trebuchetdynamics.fractal.forge', release_script)
        self.assertIn("package: name='com.trebuchetdynamics.fractal.forge'", release_script)
        self.assertIn('Authorization: Bearer $' + 'ACCESS_TOKEN', upload_script)
        self.assertNotIn('Authorization: Bearer ' + '*' * 3, upload_script)
        self.assertIn('TRACK="${PLAY_TRACK:-internal}"', upload_script)
        self.assertIn('RELEASE_STATUS="${PLAY_RELEASE_STATUS:-draft}"', upload_script)

    def test_all_builds_and_evidence_before_any_publication(self):
        root = Path(__file__).resolve().parents[2]
        release_script = (root / "scripts" / "release.sh").read_text()

        self.assertIn(
            "all) STAGES+=(android_build linux windows evidence github website play)",
            release_script,
        )
        android_build_stage = release_script.split(
            "stage_android_build() {", 1
        )[1].split("stage_play() {", 1)[0]
        play_stage = release_script.split("stage_play() {", 1)[1].split(
            "stage_android() {", 1
        )[0]
        self.assertNotIn("build-upload-playstore.sh", android_build_stage)
        self.assertIn("release-manifest.json", play_stage)
        self.assertIn('generate_release_evidence.py" --verify', play_stage)
        self.assertIn("build-upload-playstore.sh", play_stage)

    def test_generates_and_verifies_bound_release_evidence(self):
        root = Path(__file__).resolve().parents[2]
        script = root / "scripts" / "generate_release_evidence.py"
        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            (temp / "pubspec.yaml").write_text(
                "name: fixture\nversion: 2.3.4+56\n", encoding="utf-8"
            )
            (temp / "pubspec.lock").write_text(
                """packages:
  alpha:
    dependency: "direct main"
    description:
      name: alpha
      sha256: abc123
      url: "https://pub.dev"
    source: hosted
    version: "1.2.3"
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
""",
                encoding="utf-8",
            )
            artifact = temp / "app-release.aab"
            artifact.write_bytes(b"verified-aab")
            output = temp / "evidence"
            license_dir = temp / ".pub-cache/hosted/pub.dev/alpha-1.2.3"
            license_dir.mkdir(parents=True)
            (license_dir / "LICENSE").write_text("Alpha fixture license\n")
            # Gradle creates this directory; inventory discovery must not try
            # to read a directory whose name happens to end in `.gradle`.
            (temp / "android/.gradle").mkdir(parents=True)

            subprocess.run(
                [
                    "python3",
                    str(script),
                    "--project-root",
                    str(temp),
                    "--artifact",
                    str(artifact),
                    "--output-dir",
                    str(output),
                    "--commit",
                    "deadbeef",
                    "--build-number",
                    "56",
                ],
                check=True,
                env={**os.environ, "HOME": str(temp)},
            )

            manifest = json.loads((output / "release-manifest.json").read_text())
            sbom = json.loads((output / "sbom.cdx.json").read_text())
            expected_hash = hashlib.sha256(b"verified-aab").hexdigest()
            self.assertEqual(manifest["version"], "2.3.4+56")
            self.assertEqual(manifest["buildNumber"], "56")
            self.assertEqual(manifest["commit"], "deadbeef")
            self.assertEqual(manifest["artifacts"][0]["sha256"], expected_hash)
            self.assertFalse(Path(manifest["artifacts"][0]["path"]).is_absolute())
            self.assertEqual(sbom["bomFormat"], "CycloneDX")
            self.assertEqual(
                sbom["metadata"]["properties"][1],
                {
                    "name": "fractal-forge:sbom-scope",
                    "value": "Dart/Flutter packages from pubspec.lock; Android and native inventories are separate evidence files",
                },
            )
            self.assertEqual(sbom["components"][0]["name"], "alpha")
            self.assertIn("alpha 1.2.3", (output / "THIRD_PARTY_NOTICES.txt").read_text())
            checksums = (output / "SHA256SUMS").read_text()
            self.assertIn(expected_hash, checksums)
            self.assertIn("release-manifest.json", checksums)
            self.assertIn("sbom.cdx.json", checksums)
            self.assertTrue((output / "ANDROID_NATIVE_INVENTORY.txt").is_file())

            subprocess.run(
                [
                    "python3",
                    str(script),
                    "--verify",
                    str(output / "release-manifest.json"),
                ],
                cwd=Path(temp_dir).parent,
                check=True,
            )

            listed = subprocess.run(
                [
                    "python3",
                    str(script),
                    "--list-assets",
                    str(output / "release-manifest.json"),
                    "--version",
                    "2.3.4+56",
                    "--build-number",
                    "56",
                    "--commit",
                    "deadbeef",
                ],
                capture_output=True,
                text=True,
                check=True,
            )
            self.assertEqual(
                set(listed.stdout.splitlines()),
                {
                    str(artifact.resolve()),
                    str((output / "release-manifest.json").resolve()),
                    str((output / "sbom.cdx.json").resolve()),
                    str((output / "ANDROID_NATIVE_INVENTORY.txt").resolve()),
                    str((output / "THIRD_PARTY_NOTICES.txt").resolve()),
                    str((output / "SHA256SUMS").resolve()),
                },
            )
            snapshot = temp / "snapshot"
            snapped = subprocess.run(
                [
                    "python3",
                    str(script),
                    "--snapshot-assets",
                    str(output / "release-manifest.json"),
                    "--snapshot-dir",
                    str(snapshot),
                    "--version",
                    "2.3.4+56",
                    "--build-number",
                    "56",
                    "--commit",
                    "deadbeef",
                ],
                capture_output=True,
                text=True,
                check=True,
            )
            snapshot_assets = {Path(line) for line in snapped.stdout.splitlines()}
            self.assertTrue(snapshot_assets)
            self.assertTrue(
                all(path.is_relative_to(snapshot) for path in snapshot_assets)
            )
            snapshot_artifact = snapshot / artifact.name
            self.assertEqual(snapshot_artifact.read_bytes(), b"verified-aab")
            artifact.write_bytes(b"changed-after-snapshot")
            self.assertEqual(snapshot_artifact.read_bytes(), b"verified-aab")
            artifact.write_bytes(b"verified-aab")

            wrong_identity = subprocess.run(
                [
                    "python3",
                    str(script),
                    "--list-assets",
                    str(output / "release-manifest.json"),
                    "--version",
                    "9.9.9",
                    "--build-number",
                    "56",
                    "--commit",
                    "deadbeef",
                ],
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(wrong_identity.returncode, 0)

            for evidence_name in (
                "release-manifest.json",
                "sbom.cdx.json",
                "THIRD_PARTY_NOTICES.txt",
            ):
                evidence_path = output / evidence_name
                original = evidence_path.read_bytes()
                evidence_path.write_bytes(original + b"tampered\n")
                tampered = subprocess.run(
                    [
                        "python3",
                        str(script),
                        "--verify",
                        str(output / "release-manifest.json"),
                    ],
                    capture_output=True,
                    text=True,
                )
                self.assertNotEqual(
                    tampered.returncode, 0, f"tampering {evidence_name} must fail"
                )
                evidence_path.write_bytes(original)

    def test_snapshot_uses_the_single_manifest_read_even_if_source_changes(self):
        root = Path(__file__).resolve().parents[2]
        script = root / "scripts" / "generate_release_evidence.py"
        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            (temp / "pubspec.yaml").write_text(
                "name: fixture\nversion: 2.3.4+56\n"
            )
            (temp / "pubspec.lock").write_text(
                """packages:
  alpha:
    dependency: "direct main"
    description:
      name: alpha
      sha256: abc123
      url: "https://pub.dev"
    source: hosted
    version: "1.2.3"
"""
            )
            (temp / "LICENSE").write_text("fixture license\n")
            license_dir = temp / ".pub-cache/hosted/pub.dev/alpha-1.2.3"
            license_dir.mkdir(parents=True)
            (license_dir / "LICENSE").write_text("Alpha fixture license\n")
            for name in ("a.bin", "b.bin"):
                (temp / name).write_bytes(name.encode())
            output = temp / "evidence"
            subprocess.run(
                [
                    "python3",
                    str(script),
                    "--project-root",
                    str(temp),
                    "--output-dir",
                    str(output),
                    "--version",
                    "2.3.4+56",
                    "--build-number",
                    "56",
                    "--commit",
                    "deadbeef",
                    "--artifact",
                    str(temp / "a.bin"),
                    "--artifact",
                    str(temp / "b.bin"),
                ],
                check=True,
                env={**os.environ, "HOME": str(temp)},
            )
            specification = importlib.util.spec_from_file_location(
                "release_evidence_under_test", script
            )
            if specification is None or specification.loader is None:
                self.fail("could not load release evidence module")
            module = importlib.util.module_from_spec(specification)
            specification.loader.exec_module(module)
            manifest = output / "release-manifest.json"
            real_copyfile = module.shutil.copyfile
            changed = False

            def racing_copyfile(source, destination):
                nonlocal changed
                if not changed:
                    changed = True
                    replacement = json.loads(manifest.read_text())
                    replacement["artifacts"] = replacement["artifacts"][:1]
                    manifest.write_text(json.dumps(replacement))
                return real_copyfile(source, destination)

            module.shutil.copyfile = racing_copyfile
            assets = module.snapshot_asset_paths(
                manifest,
                temp / "snapshot",
                expected_version="2.3.4+56",
                expected_build_number="56",
                expected_commit="deadbeef",
            )
            self.assertEqual(
                {"a.bin", "b.bin"},
                {path.name for path in assets if path.suffix == ".bin"},
            )

    def test_asset_selection_rejects_duplicate_remote_basenames(self):
        root = Path(__file__).resolve().parents[2]
        script = root / "scripts" / "generate_release_evidence.py"
        specification = importlib.util.spec_from_file_location(
            "release_evidence_duplicate_name_test", script
        )
        if specification is None or specification.loader is None:
            self.fail("could not load release evidence module")
        module = importlib.util.module_from_spec(specification)
        specification.loader.exec_module(module)

        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            evidence = temp / "evidence"
            evidence.mkdir()
            for parent in (temp / "first", temp / "second"):
                parent.mkdir()
                (parent / "same.zip").write_bytes(b"fixture")
            manifest = {
                "artifacts": [
                    {"path": "../first/same.zip"},
                    {"path": "../second/same.zip"},
                ],
                "evidence": {},
            }
            with self.assertRaisesRegex(ValueError, "duplicate GitHub asset basename"):
                module._asset_paths_for_manifest(
                    evidence / "release-manifest.json", manifest
                )

    def test_missing_dependency_license_blocks_evidence_generation(self):
        root = Path(__file__).resolve().parents[2]
        script = root / "scripts" / "generate_release_evidence.py"
        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            (temp / "pubspec.yaml").write_text("name: fixture\nversion: 1.0.0+1\n")
            (temp / "pubspec.lock").write_text(
                """packages:
  definitely_missing_license_fixture:
    dependency: "direct main"
    source: hosted
    version: "9.9.9"
"""
            )
            artifact = temp / "artifact.zip"
            artifact.write_bytes(b"artifact")
            generated = subprocess.run(
                ["python3", str(script), "--project-root", str(temp),
                 "--artifact", str(artifact), "--output-dir", str(temp / "out"),
                 "--commit", "deadbeef"],
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(generated.returncode, 0)
            self.assertIn("Missing license text", generated.stderr)

    def test_verification_rejects_empty_semantically_invalid_evidence(self):
        root = Path(__file__).resolve().parents[2]
        script = root / "scripts" / "generate_release_evidence.py"
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir)
            manifest = {
                "version": "1.0.0",
                "buildNumber": "1",
                "commit": "deadbeef",
                "generatedAt": "2026-08-09T00:00:00Z",
                "artifacts": [],
                "evidence": {
                    "sbom": "sbom.cdx.json",
                    "androidNativeInventory": "ANDROID_NATIVE_INVENTORY.txt",
                    "thirdPartyNotices": "THIRD_PARTY_NOTICES.txt",
                    "checksums": "SHA256SUMS",
                },
            }
            (output / "release-manifest.json").write_text(json.dumps(manifest))
            (output / "sbom.cdx.json").write_text("{}")
            (output / "THIRD_PARTY_NOTICES.txt").write_text("none\n")
            (output / "ANDROID_NATIVE_INVENTORY.txt").write_text("none\n")
            checksums = []
            for name in (
                "release-manifest.json",
                "sbom.cdx.json",
                "THIRD_PARTY_NOTICES.txt",
                "ANDROID_NATIVE_INVENTORY.txt",
            ):
                checksums.append(
                    f"{hashlib.sha256((output / name).read_bytes()).hexdigest()}  {name}"
                )
            (output / "SHA256SUMS").write_text("\n".join(checksums) + "\n")

            verified = subprocess.run(
                ["python3", str(script), "--verify", str(output / "release-manifest.json")],
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(verified.returncode, 0)
            self.assertIn("at least one artifact", verified.stderr)


if __name__ == "__main__":
    unittest.main()
