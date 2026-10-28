# Android pre-release gate safety

`scripts/pre-release-gate.sh` now refuses execution by default, before Flutter,
ADB, or device cleanup. Selecting a device alone is **not consent** to erase it.
The old gate uninstalled any installed Fractal Forge package, despite calling it
an “instrumented app”; Flutter integration can also replace/uninstall the package
before that explicit uninstall. Removing only the explicit uninstall is unsafe.

## Established project target: the existing Waydroid instance

The owner has **already designated Waydroid for testing**, reaffirmed on
2026-10-26. See the [standing target contract](../testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
for identity, current-serial checks, approved app-replacement scope and invocation.
Do not ask for a new device designation merely because a release-signed app is
installed there: production-mode builds are part of that test workflow. Historical
[complete gate results](../testing/waydroid-export-verification.md#thumbnaillayout-repair-and-complete-gate-rerun-2026-10-25-utc)
are evidence of its established use, not a pass for a later candidate.

Execution still requires explicit `--device ID` (or `ANDROID_DEVICE`) and matching
`--disposable-device ID`. For the designated Waydroid target this encodes existing
owner authorization, not a fresh approval question. The campaign maps an explicitly
supplied `ANDROID_DISPOSABLE_DEVICE` to the latter flag. Revalidate the current
serial and coordinate exclusive use; neither device discovery nor matching IDs
alone authorizes another device.

The dedicated instance may contain release-signed **test** builds; that does not
make it a personal/production-use device. The standing designation covers the
documented app install/reinstall/uninstall test cycle, not container/factory
resets, unrelated data deletion or other profiles/devices. A different personal
device still needs its own authority. No device is auto-selected for execution;
a secondary Android profile alone is not an established Flutter-runner isolation
boundary.

Generic direct-gate syntax (use the designated Waydroid instance's current serial
and the selected candidate's build/evidence options; not executed by this doc edit):

```sh
scripts/pre-release-gate.sh --device DISPOSABLE_SERIAL \
  --disposable-device DISPOSABLE_SERIAL
```

This explicitly authorizes instrumented/debug installation, package removal and
production-mode installation on that device, including loss of app data. Existing
foreground protection, process-death, offline/network restoration, performance
and wall-clock soak checks remain required; opt-in does not make them pass.
Cleanup is armed only when the device-mutation phase starts, not on host failures.

There is no established same-signature update/restore route for personal production
app data in this gate. That limitation does not revoke the existing Waydroid test
designation or prohibit its approved test-app replacement cycle. If Waydroid is
unavailable or busy, record the actual access/contention issue; do not reopen the
settled device-choice question. The gate does not back up/restore personal data or
claim release-signature qualification.

## Interaction-soak input boundary

The [gate's `run_device_soak`](../../../scripts/pre-release-gate.sh) disables
Monkey's random system/navigation keys, app switches, flips and catch-all
`--pct-anyevent` category. The [ACAD-013 recovery record](../../../tasks/items/ACAD-013-4142ef42.md)
reports that Android 13's catch-all generated arbitrary system/window keys despite
the other exclusions, triggering a Waydroid launcher freeform-window exception.
Arbitrary-key coverage is deliberately excluded from this app-interaction soak.
The deterministic lifecycle/navigation gates remain required. Real execution and
the dry-run plan use the same input boundary.

The approved default is **300 seconds (five minutes)**. Use `--soak-seconds 1800`
when a run requires the previous thirty-minute duration. Five minutes gives less
evidence for slow memory leaks; it does not satisfy an explicit 1,800-second check.
The gate still requires the configured wall-clock duration, zero crash/ANR markers,
60-second sampling, at least two PSS samples, and the existing PSS, jank and thermal
limits. The [executable safety regression](../../../test/scripts/test_pre_release_gate_safety.py)
covers both duration selections and rejection of a fast, empty soak. The
[dry-run regression](../../../test/scripts/pre_release_gate.bats) checks the input
exclusions. These tests are not live-device evidence.

For a recovery rerun, record the current serial/model/boot state and installed APK
identity before comparing results. A different APK, even with the same version,
is not the preserved candidate. Keep the original failed outcome and its evidence;
a focused installed-candidate soak does not supersede a failed campaign or prove
a complete release-gate pass. If historical raw logs are unavailable, label the
old result as reported history, not freshly verified evidence. Do not reset the
container or stop another worker's Monkey process to obtain a clean result.

## Inspection versus qualification

`--help` and `--dry-run` execute no Flutter/ADB/device commands and create no
evidence directory. Dry-run output is a **conditional plan, not qualification
evidence**; its ABI is illustrative until real execution probes the named device.
A successful dry run or command-double regression test cannot qualify Android.

Actual release qualification still needs the designated target's real ABI/runtime,
the intended artifact/build identity, and passing real host, integration, offline,
performance, restoration and full-duration soak evidence. Waydroid is already the
authorized Android test target; physical-device/hardware claims remain separate.
This documentation correction does not run tests, fabricate qualification or
authorize publication or installation on another production-use device.
