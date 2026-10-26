#!/usr/bin/env bash
# A deliberately narrow adapter, not a general-purpose container launcher.
set -euo pipefail
image='registry.gitlab.com/fdroid/docker-executable-fdroidserver@sha256:2ad114edee50aad92fcc83fe7d801d8922780a021db070ae9f4c49f6f647c037'
app='com.trebuchetdynamics.fractal.forge'
fail() { printf 'F-Droid container: %s\n' "$*" >&2; exit 1; }
unsupported() { fail 'supported commands: --version, --help, lint --force-yamllint APP, scanner --exit-code APP:CODE [...]'; }

network=none
seconds=1800
mount_args=()
case "${1:-}" in
  --version|--help)
    [[ $# == 1 ]] || unsupported
    seconds=30
    ;;
  lint)
    [[ $# == 3 && "$2" == --force-yamllint && "$3" == "$app" ]] || unsupported
    ;;
  scanner)
    [[ $# -ge 3 && $# -le 5 && "$2" == --exit-code ]] || unsupported
    for target in "${@:3}"; do
      [[ "$target" =~ ^com\.trebuchetdynamics\.fractal\.forge:[1-9][0-9]*$ ]] || unsupported
    done
    network=bridge
    ;;
  *) unsupported ;;
esac

if [[ "$1" == lint || "$1" == scanner ]]; then
  workspace="$(pwd -P)"
  home="$(realpath -- "${HOME:?}")"
  [[ "$workspace" != / && "$workspace" != "$home" && "$workspace" != *:* &&
     -d metadata && ! -L metadata && ! -e pubspec.yaml && ! -e android &&
     ! -e config.yml && ! -e config.py ]] || fail 'unsafe workspace: use a dedicated public metadata directory, not the project or home'
  # Refuse secret-bearing trees and links/special files, even below metadata.
  # This is a guardrail, not a way to certify arbitrary files as public.
  hazard="$(find . \( \( ! -type f ! -type d \) -o \
    -name '.env' -o -name '.env.*' -o -name '*.jks' -o -name '*.keystore' -o \
    -name 'key.properties' -o -name 'local.properties' -o -name '.ssh' -o \
    -name '.gnupg' -o -name '.aws' -o -name '.kube' -o -name '.docker' -o \
    -name '.git-credentials' -o -name '.netrc' \) -print -quit)" || fail 'cannot inspect workspace'
  [[ -z "$hazard" ]] || fail 'unsafe workspace: secret markers, links or special files found'
  mount_args=(--volume "$workspace:/repo:rw" --workdir=/repo)
fi

podman_bin="$(type -P podman)" || fail 'local rootless Podman is unavailable'
[[ "$("$podman_bin" --remote=false info --format '{{.Host.Security.Rootless}}')" == true ]] || fail 'local rootless Podman is required'
"$podman_bin" --remote=false image exists "$image" || fail 'pinned image is not cached; this adapter never pulls images'
# Podman normally propagates proxy variables; disable that to avoid forwarding
# credential-bearing proxy URLs. No host env, auth, home or socket is mounted.
exec "$podman_bin" --remote=false run --rm --pull=never "--network=$network" \
  --http-proxy=false --cap-drop=ALL --security-opt=no-new-privileges \
  --pids-limit=512 "--timeout=$seconds" "${mount_args[@]}" "$image" "$@"
