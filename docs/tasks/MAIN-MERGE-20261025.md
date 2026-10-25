# Main integration — 2026-10-25

## Scope and provenance

The owner requested “Merge all main” after scoped Git publication of the [refactor planning batch](../planning/refactor-plan.md#bounded-code-refactor-frontier-2026-10-25). This composition includes:

- Local main `641f3c675b45d77b50f5965843d8cb413c252e33`, including its fourteen previously unpublished commits: certified Number Walls replay/style/export, the bounded recursive sine sphere, their existing task records/receipts and the all-platform attempt report.
- Published main `f26392142083f6cbfc61ab68475f2a07ed47a53b`, preserving the two refactor task IDs, full contracts and actual Number Walls producer dependency.
- Catalog checkpoint `90505729`, containing the reviewed artwork-first UI, EN/ES labels, accessibility/focus regressions and four intentionally updated golden references. Its recorded 3,019-test result was an earlier component result, not the merged-tree gate below.

Native merges `48a3583e` and `2474e71d` assembled the histories without rebasing, resets, discarded tests or semantic conflict choices. Localization merged cleanly and was regenerated without further source changes. Archived, set-aside and unfinished worker branches were not merged merely because they exist. The active Number Walls qualification attempt and other jobs were not stopped, resumed or reconfigured.

## Blocking ownership gap repaired

Independent review identified a P1 gap in the newly composed asynchronous Number Walls ingress: Home checked navigation/export ownership before certification, but controller generation alone guarded the later state commit. Startup and direct-viewer snapshots could likewise publish a frame and visual flags after another route/export acquired ownership. This was a delivery blocker despite earlier green suites.

- `a9d2ed2e` adds a synchronous optional commit predicate at the controller transaction boundary, combines it with preparation cancellation, and rejects publication only while the rejected request still owns its generation. Snapshot application forwards it; Home captures route and viewer-route identity; direct-viewer restoration guards its own ownership. Rejection does not apply visual flags, reopen a dismissed viewer or cancel a newer request.
- Seven real widget regressions failed on the original source with valid prime-97 requests: modal/export/Back during accepted links, settings/export during startup restore, and modal/export during direct-viewer restoration. These are actual stale-module assertion failures, not source-string checks or mock-only observations. The initial invalid-fixture probe and its timeout are not counted as RED evidence.
- A first complete Flutter run on `a9d2ed2e` failed the existing first-frame pending-indicator test. Its Flutter result was 3,046 passed, 8 skipped, 1 failed; Python/Bats were not reached. A wrapper's trailing successful metadata check did not make that a passing gate.
- `01cc5a5d90ef14dac1e10794fea2c055111dfa9e` preserves that existing assertion by starting restoration exactly once in `didChangeDependencies`: route lookup is safe and pending status is visible in the first build. The ownership predicate still rejects superseded initial restoration. No assertion was weakened. The focused five-file rerun passed **239 tests**, including initial-link precedence, successful wall/chrome restoration, cancellation/supersession and the pending-indicator case.

Read-only review runs `72f57dc4` and `7a5ca163` found no remaining blocker in the transaction guard and lifecycle delta. Those reviews inspected source and supplied test output; they did not claim an independently rerun full suite.

## Merged-source verification

The complete failure-propagating gate ran against source `01cc5a5d90ef14dac1e10794fea2c055111dfa9e` with pinned Flutter **3.44.6**, Dart **3.12.2**, the existing offline package cache and `/usr/bin/python3`. Version matched `fdroid/flutter.version`; pytest/Jinja/MarkupSafe imports were checked. No package installation, shared-SDK modification or lockfile change was used.

Actual command families:

```sh
flutter pub get --offline --enforce-lockfile &&
flutter analyze --no-pub &&
flutter test --no-pub --reporter expanded &&
/usr/bin/python3 -m pytest test/research test/scripts -q &&
bats test/scripts/*.bats
```

All stages and the final whitespace/clean-source/lockfile/task-store checks exited **0**:

- Analyzer: no issues.
- Flutter: **3,047 passed, 8 existing opt-in skips**.
- Python: **282 passed, 1 existing capture skip, 103 subtests passed**.
- Bats: **25 passed**.
- Task store: **115 tasks, 20 goals, no drafts or pending edits**.
- Linux release build passed on the same application source. Required localization regeneration and formatting completed; `pubspec.lock` is unchanged.

Subsequent integration documentation does not constitute a new application implementation. Before publication, compare application/test/shader/asset/tool/dependency input blobs with the qualified source, rerun affected metadata/link checks, and preserve every source task/goal/evidence record outside the explicitly owned planning additions. An unchanged application input closure permits reuse of the recorded application checks; it is not a claim that the full suite ran on a later documentation commit.

## Render evidence and limits

Owned evidence lives under the retained integration checkout's ignored `release-artifacts/main-merge-20261025/`: the complete successful gate, the failed first run, valid RED logs, focused GREEN log, release build log and actual native Linux captures at 360×780, 390×844 and 1280×900, including formula details and the dimension menu. Final captures were inspected. They use fresh isolated XDG profiles, Xvfb with TCP disabled and Mesa/llvmpipe; they are not Android device screenshots.

Some complex cards displayed provisional gradient previews in the headless desktop captures, including an idle recapture. Layout evidence therefore does not certify every thumbnail or hardware image-health/performance behavior. Desktop accessibility-bus warnings also mean no screen-reader-device qualification is inferred. The catalog's explicit unverified/approximate-preview disclosures remain intact; no shader rewrite was folded into this merge.

The source inclusion satisfies the codec task's previously missing NUM-WALL-02 file prerequisite in this composition; its refactor remains **open and unimplemented**, as does the music refactor. Existing producer statuses and receipts are retained, not newly fabricated or repinned. Number Walls/sine-sphere device journeys and other live/platform qualification remain separate. This integration is not a new Play upload, release, deployment or production acceptance.

Canonical main alignment and remote publication require actual Git readback. Preserve dirty/untracked files and the live coordinator; do not force-update its branch or clear its locks. If coordination prevents a local fast-forward, report remote inclusion and that precise local hold separately.
