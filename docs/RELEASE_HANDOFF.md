# Release Handoff

Timestamp: 2026-03-06 07:36 CST
Branch: `main`
Commit: `17e98cb`

## Canonical release-lane command
- `scripts/verify-release-lane.sh`
- delegated runtime/artifact proof: `scripts/release-proof.sh`

## Verify gate assertions
- `analyze_issues == 0`
- `tests.failed == 0`
- `runtime_checks.fractal_render_audit_marker == true`
- `artifact_proof_match == true` (sha256 + size_bytes match APK)

## Under the hood
- `/home/xel/flutter/bin/flutter analyze`
- `/home/xel/flutter/bin/flutter test --reporter compact`
- `/home/xel/flutter/bin/flutter build apk --release`

## Validation results
- Analyze: 0 issues
- Tests: 848 passed, 0 failed, 4 skipped
- Build: success

## Artifact
- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: `37M` (38.2MB build output)
- SHA256: `d8ad0901bf9df9ae2fe4abab146bca25dc8040dec270a27d0afd71df8dfc1758`
