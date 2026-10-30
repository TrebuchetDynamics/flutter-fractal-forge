# Waydroid over SSH: Android test target

Use the existing Waydroid container as an Android test target without a physical
phone or access to the host desktop. A headless Wayland compositor supplies the
display; ADB supplies test, shell and file access. These steps configure local
testing, not Play publication or signing access.

For reboot persistence and recurring live-but-unreachable failures, see
[the boot/reliability audit and recommended hardening](waydroid-reliability.md).
This host already has enabled container, compositor and user-session services
with user lingering; do not mistake another autostart recipe for a routing fix.

## Working Android test sequence

**Use this sequence for Android testing and release preparation. Waydroid is
already selected.** Do not look for a phone or ask the owner to select a device.
The previously successful recovery was **guest routing diagnosis → restart the
existing session/container → reconnect → enroll the host public key only if
unauthorized → verify boot/model → run tests**. A successful connection-helper
message alone was never the readiness check.

### 1. Reuse a healthy instance; diagnose a broken one

Coordinate with active device workers, then run:

```bash
waydroid status
waydroid adb connect
adb devices -l
```

If the designated instance appears as `device`, skip recovery and go to step 3.
If it is `unauthorized`, use [the existing public-key enrollment recipe](#authorize-adb-without-a-visible-prompt),
not a container restart or authentication bypass. If its transport is absent,
use [the host/guest routing probe](#recovery-ip-exists-but-networking-is-unreachable)
to determine whether this is the previously observed guest-routing failure.

### 2. Recover the diagnosed guest-routing failure

The earlier incident had an address on `eth0` but Android policy routing ended in
`unreachable`. Restarting **the existing** session/container restored it. With
exclusive access and that diagnosis, run as the session user:

```bash
waydroid session stop
sudo systemctl restart waydroid-container
WAYLAND_DISPLAY=waydroid-headless waydroid session start
```

The final command may stay attached: use a second terminal for step 3. This is
not container reinitialization, a factory reset, data deletion or a new instance;
it does close Android apps and must not interrupt another worker. Do not apply
this recovery blindly to every ADB error. An unavailable sudo session blocks
this privileged repair, not the settled Waydroid target choice; an administrator
runs the existing commands locally, without sharing credentials in chat.

### 3. Rediscover the serial and verify actual readiness

The restart can change the IP. In the second terminal, run:

```bash
waydroid status
WAYDROID_IP="$(waydroid status | awk '$1 == "IP" && $2 == "address:" {print $3}')"
[[ "$WAYDROID_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || {
  echo 'No current Waydroid IPv4 address; return to routing diagnostics.' >&2
  exit 1
}
export ANDROID_DEVICE="$WAYDROID_IP:5555"
export ANDROID_DISPOSABLE_DEVICE="$ANDROID_DEVICE"
waydroid adb connect
adb devices -l
test "$(adb -s "$ANDROID_DEVICE" get-state)" = device &&
  test "$(adb -s "$ANDROID_DEVICE" shell getprop ro.product.model | tr -d '\r')" = 'WayDroid x86_64 Device' &&
  test "$(adb -s "$ANDROID_DEVICE" shell getprop sys.boot_completed | tr -d '\r')" = 1
```

The native `ro.product.model` value contains spaces: `WayDroid x86_64 Device`.
`adb devices -l` renders that same model as `WayDroid_x86_64_Device`; do not compare
its sanitized display name directly with the native property.

**All three final checks must exit zero.** If the serial is unauthorized, enroll
only the existing host's public key using the linked recipe, then repeat these
checks. Do not install or run tests when they fail. A pending boot is not a new
device; wait for that instance to finish booting and recheck.

### 4. Run the selected candidate's tests

Keep both exported IDs in the test terminal. Select pinned Flutter 3.44.6 and its
provisioned cache, regenerate dependencies offline with the lockfile enforced,
then use [the direct release-gate invocation](#standing-owner-designation-use-this-waydroid-target)
or [the focused test commands](#run-tests-without-confusing-setup-with-qualification).
Retain source/build identity, real gate output and new PNG/MediaStore/gallery
readback. The [prior passing journeys and complete gate](waydroid-export-verification.md)
show the established workflow; they do not qualify a different candidate.

## Standing owner designation: use this Waydroid target

**Owner reaffirmed 2026-10-26:** “We already set Waydroid as device for testing.”
The existing headless Waydroid instance is the project's **designated Android test
environment**, not an undecided device choice. Use it for routine Android
integration and release-gate testing; do not ask the owner to designate it again.
The [previous complete gate rerun](waydroid-export-verification.md#thumbnaillayout-repair-and-complete-gate-rerun-2026-10-25-utc)
and [Play 1.1.111 record](../release/PLAY_1.1.111.md) already document its use for
instrumented tests, production-mode app installation/reinstallation and soak.

Read-only inventory on 2026-10-26 confirmed:

| Field | Observed value |
|---|---|
| ADB serial | `192.168.240.112:5555` |
| State | `device` |
| Model | `WayDroid_x86_64_Device` |
| Product / device | `lineage_waydroid_x86_64` / `waydroid_x86_64` |

The IP/ADB transport can change. Revalidate with `waydroid status` and
`adb devices -l`, identify this Waydroid instance, and substitute its **current**
serial. Never substitute another connected device just because it is available.
A release-signed app installed inside this test container is a test artifact;
its presence alone does not turn Waydroid into an unauthorized personal device.

The standing designation covers the documented app test/install/reinstall/uninstall
cycle in this instance. It does **not** authorize a container/factory reset,
deleting unrelated data, changing another profile/device, interrupting another
active worker, or publication outside the separately approved release scope.
Serialize device-changing runs. If another worker owns the target, coordinate
access rather than treating that temporary contention as missing owner approval.

For the current safety gate, explicitly encode this **existing** designation:

```bash
# After confirming this is still the designated Waydroid instance's current serial:
export ANDROID_DEVICE=192.168.240.112:5555
export ANDROID_DISPOSABLE_DEVICE="$ANDROID_DEVICE"

# Direct gate: require the selected candidate's identity and private evidence path.
: "${RELEASE_VERSION:?Set the chosen candidate version first}"
: "${RELEASE_BUILD_NUMBER:?Set its matching build number first}"
: "${LOG_DIR:?Set a private evidence directory first}"
bash scripts/pre-release-gate.sh --device "$ANDROID_DEVICE" \
  --disposable-device "$ANDROID_DISPOSABLE_DEVICE" \
  --build-name "$RELEASE_VERSION" --build-number "$RELEASE_BUILD_NUMBER" \
  --log-dir "$LOG_DIR"
```

The campaign forwards both environment variables to the gate. Supplying the
matching acknowledgement here records the standing Waydroid authorization; it
is not permission to acknowledge arbitrary discovered devices. Preserve explicit
selection and safety checks. See [the gate contract](../release/ANDROID_GATE_SAFETY.md).
This documentation pass ran only `adb devices -l`, not the example gate.

Waydroid is emulator/container evidence, **not physical-device or hardware-GPU
proof**. Availability/authorization does not mean tests passed: retain the exact
source, SDK, build, device/backend, commands and outcomes for every new run.
Earlier reports asking for a newly authorized Android target are superseded on
that selection question; their historical test failures and missing qualification
remain historical facts, not retroactive passes.

Start here: check connectivity, repair networking only if necessary, then authorize
ADB if needed. Do not restart or re-enroll keys in a healthy session merely to
repeat this setup.

## Release preflight and exact blocker reporting

**Waydroid is the target, not a fallback pending a physical phone.** Its existing
owner designation supplies target consent for Android integration/release tests.
Passing those tests supplies Waydroid evidence; it does not make separate
physical-device or hardware-GPU claims. A transport problem changes neither the
target choice nor that standing consent.

Before declaring Android blocked:

1. Coordinate exclusive device access with active workers. Read `waydroid status`
   and `adb devices -l`; take the current IP from this instance, not a historical
   report or an arbitrary connected device.
2. If its transport is absent, run `waydroid adb connect` once. Then verify
   `adb -s "$ANDROID_DEVICE" get-state`. The helper can exit zero and print
   “Established ADB connection” **while the serial is still absent**.
3. If state is `device`, verify the model and `sys.boot_completed` before the
   source-bound gate. Set matching `ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE`
   as shown above; do not ask for target approval again.
4. Otherwise classify the actual state below. Collect diagnostics first; do not
   loop reconnects, change the target or reset the container to manufacture a pass.

| Observed state | Required next action / precise report |
|---|---|
| `device`, expected model, boot complete | Proceed with the designated-target gate; connectivity is not qualification. |
| `unauthorized` | Existing target's host key is unaccepted; follow [public-key enrollment](#authorize-adb-without-a-visible-prompt) through an authorized administrator. Do not disable authentication. |
| `offline` | Try the documented stale-transport reconnect, then recheck this serial. Retain failure if it stays offline. |
| Serial absent or connection fails | Check `ip -4 addr show waydroid0`, `ip route get <current-IP>` and `ip neigh show <current-IP>`; then collect the [guest routing probe](#recovery-ip-exists-but-networking-is-unreachable). Do not infer guest health from host routes alone. |
| Guest probe requires unavailable sudo authentication | Report **Waydroid guest diagnostics blocked by local sudo authentication**, including the failed command. Have an administrator run that command locally; never request a password in chat or claim another device designation is needed. |
| Target owned by another worker | Report the actual contention and coordinate handoff; do not kill its tests or reinterpret existing consent as absent. |

A terminal Android report must identify: candidate source/version/build; current
Waydroid IP/serial and container/session state; actual ADB result/error; commands
and exits; whether any installation/test ran; and the next concrete diagnostic or
access requirement. “Device unavailable” alone is not an adequate explanation.
Keep Android/Play and dependent F-Droid qualification failures scoped to those
lanes; do not suppress qualified web/desktop work.

### Verified recovery — 2026-10-30

The owner ran the step-2 existing-session/container restart. Fresh assistant
readback then confirmed `192.168.240.112:5555` in state `device`, native model
`WayDroid x86_64 Device`, `sys.boot_completed=1`, Android 13, and host neighbor
`REACHABLE`. No key enrollment or physical phone was needed for this recovery.
This confirms restored connectivity, not a passing current-candidate release gate.
Retain the earlier diagnostic failure below rather than treating it as permanent
unavailability or retroactively marking its skipped tests passed.

### Observed transport failure — 2026-10-29

This is a dated diagnostic record, **not a permanent target status**. Revalidate
before each new run. Commands were read-only except the normal ADB connection
helper; no app install/uninstall, key enrollment, container restart or network
configuration change occurred.

- `waydroid status`: session/container `RUNNING`, IP `192.168.240.112`, existing
  `waydroid-headless` display.
- `waydroid adb connect`: exit 0, “Established ADB connection…”; nevertheless
  `adb devices -l` had no devices and
  `adb -s 192.168.240.112:5555 get-state` exited 1, `device … not found`.
- Host bridge: `192.168.240.1/24`; host route selected `waydroid0`; neighbor state
  for `192.168.240.112` was `FAILED`. This does not establish the guest's route.
- The guest probe below exited 1 with `sudo: a password is required`. The missing
  input was local administrator authentication for **diagnosis**, not target
  selection, physical hardware, or another release approval:

  ```sh
  sudo -n waydroid shell -- sh -c \
    'ip -4 addr show eth0; ip rule; ip route show table all; ip route get 192.168.240.1'
  ```

An administrator can run the same probe with interactive `sudo` locally. Inspect
its output before choosing any recovery; the historical restart recipe below is
not automatic authorization to interrupt workers or reset this instance.

## Prerequisites and display

- Existing Waydroid installation/container, Weston, Android platform-tools (`adb`)
  and an SSH login as the Linux user that owns the Waydroid session.
- `sudo` access for container restart, root Android shell and public-key enrollment.
  Enter passwords locally; never paste them into logs or chat.
- An existing headless Wayland display named `waydroid-headless`. The inspected
  running compositor used the following arguments (startup recipe not rerun during
  this troubleshooting session):

  ```bash
  weston --backend=headless-backend.so --socket=waydroid-headless \
    --idle-time=0 --width=1080 --height=1920 --use-pixman --no-config
  ```

  If provisioning a new display, run it as the session user with a valid
  `XDG_RUNTIME_DIR`, in a separate persistent terminal or an approved local service.
  Reuse an existing compositor rather than starting another on the same socket.
  This page does not install packages or create services.

Start a stopped Waydroid session as the normal user, not with `sudo`:

```bash
WAYLAND_DISPLAY=waydroid-headless waydroid session start
```

The command may remain attached; use another SSH terminal for diagnostics. No
`show-full-ui`, desktop display switch or visible debugging dialog is required
when using the explicit public-key enrollment below.

## Check the target

```bash
waydroid status
adb devices -l
```

Use the current IP reported by `waydroid status`; it can change. If it reports
`UNKNOWN`, inspect the container directly:

```bash
sudo waydroid shell -- ip -4 addr
sudo waydroid shell -- ip route get 192.168.240.1
```

`192.168.240.1` was this host's Waydroid bridge address. Confirm your bridge with
`ip -4 addr show waydroid0` and substitute its address if different. Put `--` before
Android commands containing options, e.g.:

```bash
sudo waydroid shell -- ping -c 2 192.168.240.1
```

Without the separator, Waydroid can interpret `-c` itself and reject the command.

### Recovery: IP exists but networking is unreachable

Observed symptoms were `IP address: UNKNOWN`, ADB `No route to host`, and Android
`Network is unreachable` despite an address on `eth0`. Collect policy-routing
information before changing anything:

```bash
sudo waydroid shell -- sh -c \
  'ip -4 addr show eth0; ip rule; ip route show table all; ip route get 192.168.240.1'
```

In this incident the connected subnet route existed only in `main`, while Android
policy rules consulted other tables and ended with `unreachable`. Restarting the
existing container/session restored routing. This is a recovery for that observed
state, not a fix for every network error. It closes Android apps and interrupts
other tests: coordinate ownership and preserve needed data first.

```bash
waydroid session stop
sudo systemctl restart waydroid-container
WAYLAND_DISPLAY=waydroid-headless waydroid session start
```

In another terminal, repeat `waydroid status` and the route probe. The recovered
probe selected `eth0_local` and the container IP. Do not add ad hoc routing rules,
flush firewall rules or disable Android authentication to hide the failure.

## Authorize ADB without a visible prompt

```bash
waydroid adb connect
adb devices -l
```

The helper's “Established ADB connection” message is not authorization proof.
`unauthorized` means Android has not accepted the host key. `offline` is also not
ready; `adb reconnect offline` can refresh a stale transport, but cannot authorize
it.

For an owned container, an authorized administrator can enroll this Linux user's
existing **public** ADB key through the root Android shell. This preserves ADB
authentication and existing authorized keys. It grants this host debugging access
to the container, so use only a trusted host/user. Never copy the private `adbkey`.

Run as the same normal Linux user that runs `adb` (only `waydroid shell` uses sudo):

```bash
test -s "$HOME/.android/adbkey.pub" || {
  echo 'Missing ADB public key; stop and provision the intended host key first.'
  exit 1
}
sudo waydroid shell -- sh -c '
set -e
f=/data/misc/adb/adb_keys
if ! grep -qxF "$1" "$f" 2>/dev/null; then
  printf "%s\n" "$1" >> "$f"
fi
chown system:shell "$f"
chmod 640 "$f"
restorecon "$f"
setprop ctl.restart adbd
' sh "$(cat "$HOME/.android/adbkey.pub")"
```

Reconnect using the current address; substitute your IP below:

```bash
ANDROID_DEVICE=192.168.240.112:5555
adb disconnect "$ANDROID_DEVICE"
waydroid adb connect
adb devices -l
adb -s "$ANDROID_DEVICE" get-state
adb -s "$ANDROID_DEVICE" shell getprop sys.boot_completed
adb -s "$ANDROID_DEVICE" shell getprop ro.build.version.release
```

Readiness signals: `device`, boot completion `1`, and the expected Android version.
The successful session reported a WayDroid x86_64 device on Android 13. Do not expose
ADB through a public interface/router or turn off authentication.

## Run tests without confusing setup with qualification

Use the repository-pinned Flutter SDK from [`../../../fdroid/flutter.version`](../../../fdroid/flutter.version)
and its provisioned package cache, not an ambient SDK. Follow the
[root offline setup instructions](../../../AGENTS.md#common-offline-integration-gate)
for selecting those tools and preserving `pubspec.lock`.

**Device-data warning:** Flutter integration tests install instrumented debug
packages. In the observed run a version-code downgrade (38 versus installed 105)
caused Flutter to automatically uninstall the existing app and retry installation.
Uninstalling can delete private app data. This project's designated Waydroid
instance is the approved test container described above; its documented app
replacement cycle is already authorized. Do not assume test-app data survives,
extend that authority to another device, or delete unrelated container data.

After that preflight, an existing navigation/export-sheet test is:

```bash
flutter pub get --offline --enforce-lockfile
flutter test --no-pub --no-uninstall integration_test/flows/critical_journey_test.dart \
  -d "$ANDROID_DEVICE" --dart-define=FORCE_GPU_RENDER=true --reporter expanded
```

`--no-uninstall` retains the instrumented app for follow-up inspection; default
Flutter integration-test teardown uninstalls it and removes app-scoped exports.
It does not prevent a pre-test uninstall/replacement when installation conflicts.

This test does not establish actual saved PNGs in MediaStore/gallery. The broader
[`scripts/pre-release-gate.sh`](../../../scripts/pre-release-gate.sh) requires
`--device "$ANDROID_DEVICE" --disposable-device "$ANDROID_DISPOSABLE_DEVICE"`;
it no longer auto-discovers a device for execution. The matching acknowledgement
is already supported by the standing Waydroid designation above. The gate installs
apps, changes device/network state and runs a long soak: coordinate exclusive use,
inspect its `--help`, and retain actual results. It is not the common offline gate.

### Observed outcome and remaining gates (2026-10-24)

The initial failed test below was subsequently repaired. See the
[export-journey repair and fresh PNG/gallery verification](waydroid-export-verification.md)
for the passing device reruns and the still-incomplete full-suite/release gates.
These bullets retain the initial setup attempt's results, not the final rerun.

- Container/session restart repaired the observed routing failure.
- Public-key enrollment restored authenticated, booted Android 13 ADB access over
  SSH, verified independently with `get-state` and `sys.boot_completed`.
- Flutter 3.44.6 lockfile-enforced offline dependency resolution succeeded; the
  critical-journey debug APK built and installed after the automatic uninstall.
- The critical journey **failed** at `critical_journey_test.dart:170`: expected
  `Share & export`, found no matching text after tapping the export FAB. Logs
  recorded a Mandelbrot GPU first frame; that is not a complete journey pass.
- No current-candidate edited Mandelbrot/Mandelbulb PNG gallery/readback check
  passed. Historical MediaStore entries do not qualify the current candidate.
- No Play status query, upload, production publication, or signing-material use
  was performed by these setup/test steps.

Retain commands, source/build identity, device ID, backend and actual results for
future checks. Qualification still needs fresh edited-view exports, MediaStore
records with completed persistence, gallery visibility/readability, and decoded
PNGs at the selected dimensions. Waydroid evidence must remain distinct from
physical-device/hardware GPU evidence; this page does not waive existing release
gates. See the [Android journey requirements](../test-plan.md#accepted-cross-platform-release-journey)
and [release lane map](../release/MULTIPLATFORM.md).

Sources: installed Waydroid CLI help; observed SSH troubleshooting and ADB/test
output from this session; the repository's integration test and release-gate
script linked above. Revalidate this recipe when Waydroid/Android, ADB key handling,
headless compositor setup, Flutter installation behavior or export tests change.
