+++
schema = 1
id = "RELEASE-003-ae"
title = "Publish the verified platform subset after scoped production approval.**"
short = "Publish the verified platform subset after scoped production approval.**"
status = "open"
goal = "REL-JOURNEY-001"
section = "Needs decision"
rank = 44000
depends_on = ["RELEASE-002-75"]
touches = ["release-artifacts/", "fdroid/version.properties", "fastlane/metadata/android/", "CHANGELOG.md", "docs/engineering/release/"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "After explicit scoped production authority and the verified prepare report, publish only its immutable eligible subset; skip lane-local errors and continue independent eligible lanes. Defaults: GitHub published/non-prerelease, Play production/completed, existing Cloudflare production project. No GitLab action, new destination, internal/test release or broader credential authority. Retain Apple/F-Droid external acceptance limits."
acceptance = ["Read back every successful external effect at its exact release asset/deployment/store target with matching candidate/artifact identity. Report complete/partial/failure and every omitted or publication-unknown lane explicitly. Reconcile ambiguous writes before retry. Never rebuild/swap qualified artifacts, force tags, publish empty releases or label unsigned Apple/maintainer-pending F-Droid output production-delivered. No survivors/failed common validation means no publication. Preserve supported halt/higher-version replacement recovery limits."]
checks = ["Before the separately authorized publish command, verify attributable approval, live consumed Android versions and current tag/release/deployment state; bind exact manifests/digests and read back each target afterward. Exercise retry safety with mocks before any real write and retain actual outcomes. All publication/readback checks are NOT_RUN by planning."]
exclusions = []
+++

- Section: Needs decision.
- Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign), [verification](docs/engineering/test-plan.md#independent-platform-release-verification).
- Ownership: Owner approval of the concrete prepared production subset is required; signing/store access cannot be self-approved. Keep non-executable until actual decisions exist.
- Next action: Present the prepare report and exact missing access/authority; request only genuinely missing production approval for that subset. This planning request is not that approval.
