# MAIN-CHECK-01 — Provisioned Python binding

This is the source-bound diagnosis and local verification record for the
[common offline gate](../../AGENTS.md#common-offline-integration-gate).
The worker baseline is `d39cc3da50a996607f29a1ca6481272877e453cf`.
Only gate documentation changes; no application, shader, test, dependency or SDK
source is changed. ACAD-008-74 remains completed.

## Scope and verification checklist

- [x] Inspect the retained failed-main bundle in place and the intentional fixture.
- [x] Reproduce missing pytest under ambient Python; verify the existing alternative.
- [x] Retain every gate family and the checkout-local offline dependency preflight.
- [x] Exercise the selected imports and focused existing Python tests.
- [ ] Full gate on the merged tree: coordinator-owned, NOT_RUN by this worker.

The worker execution instructions explicitly reserve the full gate for the
coordinator's merged-tree run. Neither the checks below nor the historical bundle
qualifies this candidate as a passing full gate. Retain the coordinator's actual
output, aggregates, stage exits and before/after lockfile hash with that run.
If an upstream failure short-circuits it, report the combined command as failed
and run the remaining unchanged families separately for diagnosis.

## Reproducible process-local invocation

From a fresh execution checkout root, use the existing provisioned cache; install
nothing and do not copy another checkout's `.dart_tool` metadata. On this Linux
host, enclose setup and execution in one subshell so the parent shell/profile is
unchanged:

```sh
(
  export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
  export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
  export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"

  flutter --version
  /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' &&
  sha256sum pubspec.lock &&
  flutter pub get --offline --enforce-lockfile &&
  flutter analyze --no-pub &&
  flutter test --no-pub &&
  /usr/bin/python3 -m pytest test/research test/scripts -q &&
  bats test/scripts/*.bats
  gate_exit=$?
  sha256sum pubspec.lock
  exit "$gate_exit"
)
```

Before executing, verify Flutter against [`fdroid/flutter.version`](../../fdroid/flutter.version)
(3.44.6) and its bundled Dart (3.12.2), and revalidate the module bindings below.
The explicit interpreter selects pytest; the `/usr/bin` PATH prefix also binds
child `python3` commands and `#!/usr/bin/env python3` scripts. No `PYTHONPATH`
override was needed for the successful probes on this host. Do not assume another
host has these modules; report unavailable tooling rather than install packages,
change constraints/lockfiles, alter SDK sources or suppress failures. Preserve
and compare the lockfile hashes even if a stage fails. Device/browser/GPU and
production/live qualification remain separate; this invocation grants none.

## Retained failed-main evidence

Inspected all five original files in the runner's private
`main-evidence/52654fa75f77e97c9ab356097bf5a5672fa3ba23/` bundle, without copying or
modifying them: `main_check.json`, `main-check.log`, `main-check.exit`,
`main-check-reruns.log` and `flaky_history.json`.

- Metadata identifies checked revision `52654fa75f77e97c9ab356097bf5a5672fa3ba23`,
  state `broken`, class `INCOMPLETE`, no green revision and exit 1.
- The log reports clean analysis (line 53), then **2,896 Flutter tests passed,
  8 skipped**, ending `All tests passed!` (line 13570). The next and final line
  reports Python 3.14.7: `No module named pytest`. Python tests did not run and
  Bats was not reached in that chained invocation.
- `[FF_CRASH][FATAL][test] Exception: Fatal error` (line 13217) is consistent with
  the intentional `records fatal events` fixture in
  [`test/diagnostics/crash_reporter_test.dart:49–59`](../../test/diagnostics/crash_reporter_test.dart).
  The fixture deliberately records `fatal: true` and asserts the resulting event
  count; that marker alone does not establish a tool crash or failed test.
- Metadata's two ViewerMusicCoordinator failures name an earlier scratch checkout
  than the terminal log. The isolated-reruns log is empty and flaky history is
  `{}`. Preserve those records without treating them as terminal failures in
  this run or inventing a passing rerun. No product/test repair follows from them.

The completed [ACAD-008-74 export-preparation repair](../engineering/runbook.md#offline-check-export-preparation)
addressed checkout-local dependency metadata and recorded different source inputs;
it does not qualify this revision or require reopening that task.

## Worker terminal results

All successful checks below ran on this baseline's unchanged executable inputs.
The exact commands and exit classifications accompany the worker report; scratch
output remains under the task's `$TMPDIR`, not in the repository.

| Check | Actual result |
| --- | --- |
| Ambient `python3 -c 'import sys; print(sys.executable); print(sys.version); import pytest'` | Expected diagnostic reproduction: exit 1, Python 3.14.7, missing pytest. Not the selected gate tool. |
| Selected Flutter `--version --machine`, compared programmatically with `fdroid/flutter.version` | Exit 0; Flutter 3.44.6, framework `ee80f08bbf97172ec030b8751ceab557177a34a6`, Dart 3.12.2. Root `$AUTOWORK_CACHE/flutter-3.44.6`. |
| Selected Python/module probe, callable `soft_str` and Jinja2 template render | Exit 0; `/usr/bin/python3`, Python 3.12.3; pytest 9.0.2, Jinja2 3.1.6, MarkupSafe 3.0.3. |
| `/usr/bin/python3 -m pytest test/research/test_emit_dart.py test/scripts/test_generate_release_evidence.py -q` with the bindings above | Exit 0; **35 passed in 6.68s**, no skips. Existing focused tests only, not either complete Python family. |
| `bats --version` | Exit 0; Bats 1.13.0, resolved executable `$HOME/.local/bin/bats` after setup. No Bats suite result claimed. |

The selected Python modules resolve beneath
`$HOME/.local/lib/python3.12/site-packages/`: `pytest/__init__.py`,
`jinja2/__init__.py` and `markupsafe/__init__.py`. Both direct pytest and child
`python3` resolution were checked. These are existing host bindings, not new
repository dependencies.

`pubspec.lock` SHA-256 before and after worker checks:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
This unchanged hash is not a substitute for the coordinator's before/after hash.

## Documentation handoff

Scoped Docs Sync Maintain updates `AGENTS.md` and this evidence owner. The existing
[runbook](../engineering/runbook.md#offline-check-export-preparation) and
[test plan](../engineering/test-plan.md#common-offline-gate) were inspected; their
shared procedure/history is not rewritten by this worker. The test plan still
spells the Python stage as ambient `python3` without the new setup. The docs
maintainer should synchronize that recipe with the selected bindings and link
this record after the coordinator's merged-tree gate, retaining its real result
and the historical run's source limits. No task-store or shared history edit is
part of this worker change. Revisit these bindings when host provisioning or the
pinned SDK changes.
