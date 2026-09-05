import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class Sprint3ReleaseBlockersTest(unittest.TestCase):
    def test_release_identity_comes_from_pubspec_not_upload_marker(self):
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        release_version = release.split("release_version() {", 1)[1].split("\n}", 1)[0]
        self.assertIn("pubspec_version", release_version)
        self.assertNotIn("LATEST_BUILD_INFO", release_version)

    def test_linux_and_windows_builds_are_bound_to_release_identity(self):
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        linux = release.split("stage_linux() {", 1)[1].split("stage_windows() {", 1)[0]
        windows = release.split("stage_windows() {", 1)[1].split("stage_evidence() {", 1)[0]
        for marker in ("--build-name", "--build-number", "RELEASE_COMMIT"):
            self.assertIn(marker, linux)
        self.assertIn('verify_artifact_provenance', windows)
        self.assertIn('fractal-forge-windows-x64.zip', windows)
        self.assertNotIn('gh workflow', release)

    def test_publish_preflight_runs_the_device_release_gate(self):
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        preflight = release.split("preflight_publish() {", 1)[1].split("\n}", 1)[0]
        self.assertIn('"$SCRIPT_DIR/pre-release-gate.sh"', preflight)
        self.assertIn('--build-name="$RESOLVED_ANDROID_VERSION"', preflight)
        self.assertIn('--build-number="$RESOLVED_ANDROID_BUILD_NUMBER"', preflight)

    def test_non_android_publish_requires_explicit_build_identity(self):
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        self.assertIn('--build-number=NUMBER', release)
        self.assertIn('PUBLISH_BUILD_NUMBER="${arg#--build-number=}"', release)
        self.assertIn('Non-Android publishing requires --build-number=NUMBER', release)

    def test_release_evidence_is_packaged_with_its_relative_layout(self):
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        evidence = release.split("stage_evidence() {", 1)[1].split("stage_github() {", 1)[0]
        self.assertIn('fractal-forge-release-evidence-v', release)
        self.assertIn('write_artifact_provenance', release)
        self.assertIn('verify_artifact_provenance', release)
        self.assertIn('artifact-provenance-', release)
        self.assertIn('tar -czf "$evidence_bundle"', evidence)

    def test_soak_requires_timeout_and_full_elapsed_duration(self):
        gate = (ROOT / "scripts/pre-release-gate.sh").read_text(encoding="utf-8")
        self.assertIn('soak_started_at=$SECONDS', gate)
        self.assertIn('[[ "$soak_status" -eq 124 ]]', gate)
        self.assertIn('(( soak_elapsed >= SOAK_SECONDS ))', gate)
        self.assertNotIn('0|124|130|143', gate)

    def test_soak_collection_and_pss_parser_failures_are_not_masked(self):
        gate = (ROOT / "scripts/pre-release-gate.sh").read_text(encoding="utf-8")
        self.assertIn('collection_failed=1', gate)
        self.assertNotIn('soak-memory.log" 2>&1 || true', gate)
        self.assertNotIn('soak-frames.log" 2>&1 || true', gate)
        self.assertIn("collect_soak_sample", gate)
        self.assertIn("'TOTAL PSS:'", gate)
        self.assertIn("'Janky frames:'", gate)
        self.assertIn("'Thermal Status:'", gate)
        self.assertIn('pss_output="$(', gate)
        self.assertNotIn('mapfile -t pss_samples < <(', gate)
        self.assertIn('MIN_JANKY_FRAME_COUNT="${MIN_JANKY_FRAME_COUNT:-10}"', gate)
        self.assertIn('frames >= min_frames', gate)
        self.assertIn('-v min_frames="$MIN_JANKY_FRAME_COUNT"', gate)

    def test_device_discovery_happens_after_the_long_host_gate(self):
        gate = (ROOT / "scripts/pre-release-gate.sh").read_text(encoding="utf-8")
        host = gate.index('run_gate "full host suite"')
        discovery = gate.index("discover_device", host)
        readiness = gate.index('adb_gate "device readiness"', discovery)
        self.assertLess(host, discovery)
        self.assertLess(discovery, readiness)

    def test_native_gitlab_builds_validate_identity_and_emit_provenance(self):
        native = (ROOT / "scripts/ci/native-build.sh").read_text()
        self.assertIn('source scripts/ci/identity.sh', native)
        self.assertIn('--build-name="$RELEASE_VERSION"', native)
        self.assertIn('--build-number="$RELEASE_BUILD_NUMBER"', native)
        self.assertIn('$archive.provenance', native)
        identity = (ROOT / "scripts/ci/identity.sh").read_text()
        self.assertIn('"$RELEASE_COMMIT" == "$CI_COMMIT_SHA"', identity)
        self.assertIn('"$(git rev-parse HEAD)"', identity)

    def test_deployed_privacy_policy_matches_canonical_release_contract(self):
        html = (ROOT / "web/privacy-policy.html").read_text(encoding="utf-8")
        for phrase in (
            "Effective date: 2026-08-09",
            "does not include advertising, remote analytics, behavioral tracking, or a remote crash-reporting SDK",
            "bounded in-memory diagnostic buffer",
            "https://fractal.trebuchetdynamics.com/view",
            "repository issue tracker",
        ):
            self.assertIn(phrase, html)
        release = (ROOT / "scripts/release.sh").read_text(encoding="utf-8")
        self.assertIn("verify_privacy_policy", release)


if __name__ == "__main__":
    unittest.main()
