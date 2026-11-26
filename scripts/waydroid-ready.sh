#!/usr/bin/env bash
# Run as xel after coordinating access to the designated Waydroid instance.
set -euo pipefail

fail() { printf 'Waydroid: %s\n' "$*" >&2; exit 1; }
[[ $(id -un) == xel ]] || fail 'run as xel, not root'

# One-time setup (safe to repeat): bash scripts/waydroid-ready.sh --setup
# Normal agent runs never prompt for a password or modify sudoers.
case $#:${1-} in
  0:) ;;
  1:--setup)
    # Run only this fixed installer with privilege, never the full script.
    sudo -- /bin/sh -eu <<'INSTALL_RULE'
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
umask 077
dir=/etc/sudoers.d
dest=$dir/waydroid-agent-start
rule='xel ALL=(root) NOPASSWD: /usr/bin/systemctl start waydroid-container.service'
visudo -c >/dev/null
tmp=$(mktemp "$dir/.waydroid-agent-start.XXXXXXXX")
trap 'rm -f -- "$tmp"' EXIT
printf '%s\n' "$rule" > "$tmp"
chown root:root "$tmp"
chmod 0440 "$tmp"
visudo -cf "$tmp" >/dev/null
# Hard-link a validated file atomically; never replace an existing policy.
if ! ln -T -- "$tmp" "$dest" 2>/dev/null; then
  if [ -L "$dest" ] || [ ! -f "$dest" ] ||
     [ "$(stat -c '%u:%g:%a' "$dest")" != '0:0:440' ] || ! cmp -s "$tmp" "$dest"; then
    echo "Refusing to replace conflicting policy: $dest" >&2
    exit 1
  fi
fi
visudo -c >/dev/null
INSTALL_RULE
    ;;
  *) fail 'usage: waydroid-ready.sh [--setup]' ;;
esac

if ! systemctl is-active --quiet waydroid-container.service; then
  sudo -n /usr/bin/systemctl start waydroid-container.service ||
    fail 'container start failed; inspect systemctl status waydroid-container.service'
fi

# kit-waydroid.service is the only display/session owner (wayland-kit socket);
# it starts Weston and the session. Never start waydroid-headless-* beside it.
systemctl --user start kit-waydroid.service

ip=
for ((i=0; i<15; i++)); do
  status=$(timeout 3 waydroid status) || fail 'waydroid status failed'
  ip=$(awk '/^IP address:/ {print $3}' <<<"$status")
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && break
  ip=
  sleep 1
done
[[ -n $ip ]] || fail 'no IPv4 address reported by the designated session'

serial="$ip:5555"
timeout 10 waydroid adb connect
state=$(timeout 5 adb -s "$serial" get-state) ||
  fail "ADB get-state failed for $serial; do not reset or switch devices"
[[ $state == device ]] || fail "ADB state for $serial: $state"

model=$(timeout 5 adb -s "$serial" shell getprop ro.product.model | tr -d '\r')
[[ $model == 'WayDroid x86_64 Device' ]] || fail "unexpected model: $model"
for ((i=0; i<20; i++)); do
  boot=$(timeout 5 adb -s "$serial" shell getprop sys.boot_completed | tr -d '\r')
  if [[ $boot == 1 ]]; then
    printf 'Ready: %s (%s), boot completed\n' "$serial" "$model"
    exit 0
  fi
  sleep 1
done
fail 'ADB is authenticated, but Android did not report boot completion'
