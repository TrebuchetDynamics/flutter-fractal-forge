# Release Handoff

> Point-in-time release artifact note. This file records one release-lane run and should not be treated as the current repo status.

Timestamp: 2026-03-06 16:40 CST
Branch: `main`
Commit: `de92184`

## Canonical release-lane command
- `scripts/verify-release-lane.sh`
- delegated runtime/artifact proof: `scripts/release-proof.sh`

## Verify gate assertions
- `analyze_issues == 0`
- `tests.failed == 0`
- `runtime_checks.fractal_render_audit_marker == true`
- `artifact_proof_match == true` (sha256 + size_bytes match APK)
- `proof_test_*` counters are machine-output totals and may differ from compact `flutter test` display counts

## Under the hood
- `/home/xel/flutter/bin/flutter analyze`
- `/home/xel/flutter/bin/flutter test --reporter compact`
- `/home/xel/flutter/bin/flutter build apk --release`

## Validation results
- Analyze: 0 issues
- Tests: 842 passed, 0 failed, 4 skipped
- Build: success

## Artifact
- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: `37M` (38.2MB build output)
- SHA256: `a27b3dc3dcd60952e82585c3786e5b17bd15e06c79b6545c9b4fd39a03d40b42`
