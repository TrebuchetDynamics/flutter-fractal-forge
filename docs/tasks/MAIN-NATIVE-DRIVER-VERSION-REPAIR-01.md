# MAIN-NATIVE-DRIVER-VERSION-REPAIR-01

## Incident

Main is red at checked revision `c64405086b64f3b3cfe9ea814de7a29138fa32d5`
(`chore(toolchain): update Flutter to 3.47.9 (Dart 3.13.7)`). The last green
revision is `b6b46f88fd148dbfa3d852db36379a8d1a742c9a`.

The evidence bundle read in place
(`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/c64405086b64f3b3cfe9ea814de7a29138fa32d5`)
records `state=red`, `result_class=TEST_FAILURE`, `flaky=[]`,
`flaky_history={}`, `repair_pending=[]`, `main-check.exit` 1 and an empty
`main-check-reruns.log`. The five failures are:

- `test/scripts/test_reserved_native_driver.py::test_supported_command_and_private_outputs`
- `test/scripts/test_reserved_native_driver.py::test_nonzero_or_missing_protocol_is_not_success[fail-7]`
- `test/scripts/test_reserved_native_driver.py::test_nonzero_or_missing_protocol_is_not_success[missing-1]`
- `test/scripts/test_reserved_native_driver.py::test_owned_cleanup_on_timeout_or_signal[timeout]`
- `test/scripts/test_reserved_native_driver.py::test_owned_cleanup_on_timeout_or_signal[signal]`

The log shows every failing case exiting 2 with the driver error
`FLUTTER_ROOT must select the pinned fdroid/flutter.version SDK`; the other
seven cases in the file pass because the invalid-allocation cases refuse before
the SDK-version check.

## Root cause

`c6440508` changed `fdroid/flutter.version` from `3.44.6` to `3.47.9`.
`test/scripts/test_reserved_native_driver.py` builds a fake SDK whose
`bin/cache/flutter.version.json` hardcodes `"flutterVersion":"3.44.6"` (line 21).
`scripts/run-native-integration.sh` correctly refuses when the resolved SDK
version does not equal `fdroid/flutter.version`, so the stale fixture now fails
the driver before launch.

The failure is deterministic, not flaky: on this checkout
`/usr/bin/python3 -m pytest test/scripts/test_reserved_native_driver.py -q`
reproduces `5 failed, 7 passed` immediately, and `main_check.json` carries no
flaky classification.

## Repair contract

Update the test fixture to select the repository pin instead of a hardcoded
version, so the driver keeps its safety check and the test stays valid across
future toolchain updates: read `fdroid/flutter.version` (currently `3.47.9`)
when writing the fake `flutter.version.json`. Do not revert or relax
`fdroid/flutter.version`, and do not weaken the driver's mismatch refusal.

Keep all 12 cases and every assertion in the file. This is a test-fixture
correction that follows the already-committed toolchain update; it is not a
product, shader or driver-policy change.

## Verification

Run the pinned setup from `AGENTS.md#common-offline-integration-gate`
(`FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"`, `PUB_CACHE="$AUTOWORK_CACHE/pub-cache"`),
revalidate the `/usr/bin/python3` pytest/Jinja2/MarkupSafe imports, then:

1. `/usr/bin/python3 -m pytest test/scripts/test_reserved_native_driver.py -q`
   must report `12 passed`.
2. The complete unchanged full check must run to its results:
   `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`,
   comparing `pubspec.lock` SHA-256 before and after, with `git diff --check` clean.

Record the red-bundle failure lines above and the deterministic local
reproduction in the task Evidence. An isolated pass is not full-gate
qualification, and no goal, device, release or live qualification is inferred.

## Resolution and worker verification

The fixture now derives the fake SDK version from the repository pin instead of
hardcoding it:

```python
pinned = (ROOT / "fdroid/flutter.version").read_text().strip()
(sdk / "bin/cache/flutter.version.json").write_text(
    json.dumps({"flutterVersion": pinned, "frameworkRevision": "fake"})
)
```

Only `test/scripts/test_reserved_native_driver.py` changed. All 12 cases, every
assertion and the driver's version-mismatch refusal are unchanged; the
hardcoded `3.44.6` was the stale input after `c6440508`
(`fdroid/flutter.version` `3.44.6` -> `3.47.9`; that commit also changed
`AGENTS.md`, `analysis_options.yaml`, `docs/engineering/runbook.md`,
`docs/engineering/spec.md`, `pubspec.lock`, four catalog goldens and
`test/scripts/fdroid_pipeline.bats`, none of which this fixture change touches).

Worker results on the delivered bytes:

| Command | Actual result |
| --- | --- |
| `/usr/bin/python3 -m pytest test/scripts/test_reserved_native_driver.py -q` | Exit 0; **12 passed** (was 5 failed, 7 passed before the fixture fix) |
| Mismatch probe: fake SDK `flutterVersion` `0.0.0-not-the-pin`, repo pin `3.47.9`, run `scripts/run-native-integration.sh integration_test/flows/double_tap_anchor_test.dart` | Exit 2; stderr `FLUTTER_ROOT must select the pinned fdroid/flutter.version SDK`; no private work directory created. Refusal retained. |
| `/usr/bin/python3 -m pytest test/scripts -q` | Exit 0; **282 passed, 1 skipped, 148 subtests passed** |
| Flutter `--version` vs `fdroid/flutter.version`; `/usr/bin/python3` pytest/Jinja2/MarkupSafe imports | Flutter 3.47.9 / Dart 3.13.7 == pin; Python 3.12.3, pytest 9.0.2, Jinja2 3.1.6, `markupsafe.soft_str` callable |
| `git diff --check` | Clean |

`pubspec.lock` SHA-256 before and after worker checks:
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`
(unchanged; this fixture change does not touch dependencies).

Per [MAIN-CHECK-01](MAIN-CHECK-01.md), the complete unchanged offline gate on
the merged tree is coordinator/runner-owned and was **NOT_RUN** by this worker;
an isolated pass is not full-gate qualification. The pinned process-local preflight
`flutter pub get --offline --enforce-lockfile` could not resolve in this checkout:
the shared `$AUTOWORK_CACHE/pub-cache` is stale relative to the lock refreshed by
`c6440508`, holding `meta-1.18.0`/`intl-0.20.2`/`matcher-0.12.19`/`test_api-0.7.11`
while `pubspec.lock` pins `1.19.0`/`0.20.3`/`0.12.20`/`0.7.12` (exit 1,
`meta ^1.18.3 is forbidden`). No package was installed and the lockfile was not
changed; provisioning of the pinned cache is runner-owned, so this is recorded as
an environment limitation, not a repository or fixture failure.
