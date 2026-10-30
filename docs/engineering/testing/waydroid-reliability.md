# Waydroid boot persistence and runtime reliability

Research and read-only host audit: **2026-10-30**. This is a recommended design,
not installed automation or a successful reboot qualification. The ongoing Play
release's device ownership was preserved; no unit, network, image, kernel,
permission, timer or host setting was changed during this audit.

For the established target and real test commands, use the
[Waydroid testing runbook](waydroid-headless.md). A physical phone is not a
replacement requirement for this designated target.

## Findings on BlueBlack

Versions observed: Ubuntu 24.04, Waydroid **1.6.2**, Weston **13.0.0**, systemd
**255.4**. These facts are host observations, not general upstream requirements.

| Layer | Existing state | Implication |
|---|---|---|
| System `waydroid-container.service` | Enabled for `multi-user.target`; running; vendor unit has `Restart=no` | Boot activation exists, but the vendor unit does not automatically restart its main process after failure. |
| User `waydroid-headless-compositor.service` | Enabled for `default.target`; Weston headless socket `waydroid-headless`; `Restart=on-failure`, 2-second delay | Persistent display and crash recovery already exist. |
| User `waydroid-headless-session.service` | Enabled; requires/starts after compositor; waits up to 30 seconds for its socket; `Restart=always`, 5-second delay | Persistent session supervision already exists; it can restart after a clean exit too. |
| User lingering | `loginctl show-user xel`: `Linger=yes` | The user manager is configured to run at boot and survive logout; an SSH session should not be necessary. |
| Runtime readiness/recovery | No Waydroid health timer found | Process supervision does not detect the observed live-but-unreachable Android network. |

Inspected with `systemctl cat/show/is-enabled`, `systemctl --user cat/show`,
`loginctl show-user`, process inventory and read-only journals. Unit files are
currently `/usr/lib/systemd/system/waydroid-container.service` and
`~/.config/systemd/user/waydroid-headless-{compositor,session}.service`.
Do not copy a new generic setup over these working units without comparing them.

**Boot autostart is already configured.** A fresh unattended cold-boot test was
not performed: the current boot began 2026-10-26, before this audit. Enabled units
and lingering are configuration evidence, not proof that the complete Android/ADB
stack becomes ready without login after every reboot.

## The recurring failure is not just missing autostart

The observed failure had a running container/session and a valid guest IPv4
address, but Android's subnet route was in `main` while policy rules selected
other tables and eventually `unreachable`. ADB could not reach the guest. The
owner's existing-container restart restored ADB, boot completion and host neighbor
reachability on 2026-10-30. See the runbook's
[dated recovery record](waydroid-headless.md#verified-recovery--2026-10-30).

Upstream [Waydroid issue #2318](https://github.com/waydroid/waydroid/issues/2318)
is a close symptom match: 1.6.2 on a Linux 7.0 kernel, loss of IPv4 connectivity
after running for a while, ARP requests received without replies, and networking
restored by an existing-session/container restart. The issue was open when
inspected. This is corroboration, **not proof of an identical root cause here**.

The [June comment](https://github.com/waydroid/waydroid/issues/2318#issuecomment-4755806076)
also reports problems on 1.6.3 and notes that a DHCP lease/status IP can differ
from actual guest interface readiness. The
[August comment](https://github.com/waydroid/waydroid/issues/2318#issuecomment-5162510727)
reports that a full session/container restart helps temporarily whereas a guest
`reboot` does not. Consequently, neither an upgrade to 1.6.3 nor periodic guest
reboots is an established permanent fix from these reports.

A [May comment](https://github.com/waydroid/waydroid/issues/2318#issuecomment-4520094892)
reports recovery after terminating Android's network-stack process. That is an
unverified workaround for this host, not a command to run during release testing.
Do not hard-code Android routes, disable IPv6/firewalls/authentication, purge data,
or reset the instance based on an issue comment.

## Recommended changes, in order

### 1. Keep one owner of the persistent session

Use the existing user service rather than starting a second manual session.
The current journal contains `Session is already running` during recovery; the
5-second `Restart=always` loop can race a manual `waydroid session start/stop`.

For the previously diagnosed routing failure, with exclusive device access, the
**proposed service-aware recovery sequence** is:

```sh
systemctl --user stop waydroid-headless-session.service
sudo systemctl restart waydroid-container.service
systemctl --user start waydroid-headless-session.service
```

This stops session supervision before repairing the container and then restores
it, while leaving the healthy compositor alone. It restarts the existing instance;
it must not initialize/reset/delete it. This exact service-managed sequence still
needs an idle maintenance verification; the already successful owner recovery
used direct session commands. Never execute it while another worker owns a test.

### 2. Add bounded process-failure recovery

Consider a reversible **systemd drop-in**, not edits to the vendor service:
`Restart=on-failure`, a restart delay and a finite start-rate limit for the system
container service. Compare behavior with Waydroid's own lifecycle first. This
addresses exited processes only; it does not repair a live Android routing fault.

Keep the existing headless display, explicit `XDG_RUNTIME_DIR`,
`WAYLAND_DISPLAY=waydroid-headless`, user D-Bus address and socket-readiness wait.
User and system service managers are separate: adding `After=` for a system unit
to a user unit is not a sufficient cross-manager readiness protocol. Check the
real system container/D-Bus readiness explicitly before starting the user session.

### 3. Add real readiness checks and idle-only recovery

Use a small health-check service plus timer, rather than assuming that `active`,
`RUNNING` or a connection-helper success message means usable Android. A suitable
initial proposal is a 60-second check, a bounded boot grace, three consecutive
failures before recovery, and a recovery cooldown/budget. These values are design
defaults to test, not measured reliability guarantees.

A probe should discover this instance's **current** IP and verify:

- compositor socket and system/user service state;
- exact ADB serial `get-state=device` and `sys.boot_completed=1`;
- native model `WayDroid x86_64 Device` (ADB's display uses underscores);
- guest route to the actual host bridge address, not just DHCP/status metadata.

If ADB is unavailable, privileged guest diagnostics must use a narrowly scoped,
root-owned recovery mechanism. Do not grant an agent arbitrary passwordless sudo
or store an administrator password in a script. Keep ADB authentication enabled.

The recovery path and **every device-changing test runner must share an exclusive
lease/lock**. When tests hold it, health monitoring may report failure but must
not restart Android. Also suppress recovery during intentional offline/network
and process-death tests; otherwise a watchdog could invalidate the tests it is
supposed to protect. PID guessing alone is not a reliable ownership contract.

On failure while idle: preserve service/guest routing/ADB diagnostics, execute one
bounded service-aware recovery, rediscover the current IP, then recheck actual
readiness. On repeated failure: stop retrying and report/alert rather than creating
an endless restart loop. Do not mark the failed release gate passed after recovery;
rerun its actual source-bound checks.

`WatchdogSec=` alone is not a health check: systemd's watchdog requires a service
that sends watchdog notifications. No such support was established for the
installed Waydroid service. An external probe/timer is the simpler explicit design.

### 4. Verify reboot persistence and prolonged health

After the active Play/device run, in an authorized maintenance window:

1. Cold reboot, then verify all three services, socket, ADB, model, boot completion
   and guest routing **before an interactive user login**.
2. Disconnect/reconnect SSH and verify the same instance remains ready.
3. Exercise process-failure recovery and a controlled idle recovery; retain exits,
   timing, logs and restart counters. Do not inject networking faults during tests.
4. Hold the device test lease and prove the monitor does not restart the container,
   including during intentional offline checks.
5. Observe health over several DHCP renewal periods and at least the multi-hour
   failure window reported upstream. Do not call a one-minute pass an endurance
   qualification.

Retain the existing image, package and kernel versions with every result. Investigate
updates separately with an actual backup/recovery plan and regression evidence;
research alone does not authorize image upgrades or a kernel replacement.

## Sources

- [Waydroid installation/manual container and non-root session startup](https://docs.waydro.id/usage/install-on-desktops).
- [Waydroid CLI lifecycle commands](https://docs.waydro.id/usage/waydroid-command-line-options).
- [systemd loginctl: lingering starts the user manager at boot and retains it after logout](https://www.man7.org/linux/man-pages/man1/loginctl.1.html).
- [systemd service supervision/readiness/watchdog semantics](https://man7.org/linux/man-pages/man5/systemd.service.5.html).
- [Open upstream intermittent-network failure and reports](https://github.com/waydroid/waydroid/issues/2318).

GitHub's rendered page reader was rate-blocked; issue state/body/comments were
inspected through the public GitHub API using the existing CLI. The local service
inventory is a separate primary observation, not inferred from those web sources.
