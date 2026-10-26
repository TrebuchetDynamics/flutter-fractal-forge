# Android pre-release gate safety

`scripts/pre-release-gate.sh` now refuses execution by default, before Flutter,
ADB, or device cleanup. Selecting a device alone is **not consent** to erase it.
The old gate uninstalled any installed Fractal Forge package, despite calling it
an “instrumented app”; Flutter integration can also replace/uninstall the package
before that explicit uninstall. Removing only the explicit uninstall is unsafe.

## Supported route: an entirely disposable test device

Execution requires both an explicit `--device ID` (or `ANDROID_DEVICE`) and a
matching `--disposable-device ID` argument. This is an operator acknowledgement
that the **entire named device** is dedicated to testing, with no production app
or valuable data in any Android user/profile. The script cannot verify that
human assertion. Do not acknowledge a personal or production device. No device is
auto-selected for execution; an Android secondary/work profile alone is not a
supported isolation boundary for the Flutter integration runner.

Example for an operator-provisioned disposable target (not a command executed by
this change):

```sh
scripts/pre-release-gate.sh --device DISPOSABLE_SERIAL \
  --disposable-device DISPOSABLE_SERIAL
```

This explicitly authorizes instrumented/debug installation, package removal and
production-mode installation on that device, including loss of app data. Existing
foreground protection, process-death, offline/network restoration, performance
and wall-clock soak checks remain required; opt-in does not make them pass.
Cleanup is armed only when the device-mutation phase starts, not on host failures.

There is no established same-signature update/restore route for an installed
release-signed app in this gate. If a wholly disposable target cannot be provided,
the gate must remain blocked. It does not inspect signing credentials, back up or
restore production user data, or claim release-signature qualification.

## Inspection versus qualification

`--help` and `--dry-run` execute no Flutter/ADB/device commands and create no
evidence directory. Dry-run output is a **conditional plan, not qualification
evidence**; its ABI is illustrative until real execution probes the named device.
A successful dry run or command-double regression test cannot qualify Android.

Actual release qualification still needs an explicitly authorized disposable
Android target, its real ABI/runtime, the intended artifact/build identity, and
passing real host, integration, offline, performance, restoration and full-duration
soak evidence. This change neither runs those device checks nor authorizes
installation/publication on an existing production device.
