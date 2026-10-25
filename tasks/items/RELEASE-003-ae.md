+++
schema = 1
id = "RELEASE-003-ae"
title = "Publish the verified platform subset after scoped production approval.**"
short = "Publish the verified platform subset after scoped production approval.**"
status = "open"
goal = "REL-JOURNEY-001"
section = "Next"
rank = 18000
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

- Previous section: Needs decision.
- Sources: [Accepted policy](PRD.md#independent-platform-release-policy), [implementation contract](docs/engineering/spec.md#independent-platform-release-orchestration), [lane map](docs/engineering/release/MULTIPLATFORM.md#independent-platform-release-campaign), [verification](docs/engineering/test-plan.md#independent-platform-release-verification).
- Prior ownership: Owner approval of the concrete prepared production subset is required; signing/store access cannot be self-approved. Keep non-executable until actual decisions exist.
- Prior next action: Present the prepare report and exact missing access/authority; request only genuinely missing production approval for that subset. This planning request is not that approval.
- Planning handoff: 2026-10-23 plan: PRD.md#release-continuation-plan--2026-10-23. Consume the existing prepare owner's exact immutable seven-lane campaign; retain the separate approval/live gates and current dependency. Preserve historical web 1.1.110 publication and reconcile ambiguous remote state before any retry. Do not infer a new publish approval from /plan-for-me or reuse consumed version identities.
- Held by: EVIDENCE-GATE: immutable prepared subset/digests/destinations and separately attributable candidate-bound production approval
- Owner decision: 2026-10-25: Delegated by user to assistant. Do not publish now. Require exact prepared subset, digests, destinations and separately scoped production approval; no new production authority. Decision resolved; remaining input: immutable prepared subset/digests/destinations and separately attributable candidate-bound production approval. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until immutable prepared subset/digests/destinations and separately attributable candidate-bound production approval. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
