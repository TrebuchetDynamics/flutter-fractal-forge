# Bounded local F-Droid tool adapter

`scripts/ci/fdroid-container.sh` supplies the official F-Droid tool without a
host package install or changes to host PATH/profiles. It uses the same immutable
image as the GitLab F-Droid scan job:

```text
registry.gitlab.com/fdroid/docker-executable-fdroidserver@sha256:2ad114edee50aad92fcc83fe7d801d8922780a021db070ae9f4c49f6f647c037
```

## Preconditions and safe probe

Local **rootless Podman** and that exact image must already be available to the
invoking user. The adapter forces local execution (`--remote=false`), checks
rootless mode and the cached image, and uses `--pull=never`. Missing prerequisites
are errors; it does not install tools, authenticate to registries or pull images.

From the checkout, the only qualification-free probe is:

```bash
scripts/ci/fdroid-container.sh --version
```

`--version` and `--help` accept no additional arguments. Both request **no host
bind mounts**, use `--network=none`, and limit container execution to 30 seconds.
The cached-image version probe during adapter implementation exited **0** with
stdout **`399ac60`**. This establishes tool availability, not scanner acceptance.

## Select the adapter explicitly

The existing scan script still defaults to the host `fdroid`. For an authorized
scan with release metadata already generated and bound to the intended source
commit, select the adapter using its **absolute** executable path:

```bash
FDROID_BIN="$PWD/scripts/ci/fdroid-container.sh" bash scripts/ci/fdroid-scan.sh
```

This example is not a request to run a scan. Normal release identity/environment
requirements still apply. For a local lane, the existing `RELEASE_LOCAL_STAGE`,
`RELEASE_COMMIT`, `RELEASE_VERSION`, `RELEASE_BUILD_NUMBER` and
`RELEASE_ARTIFACT_DIR` inputs must describe that source-bound release. Do not
fabricate or bypass identity checks to make the tool run. `FDROID_BIN` is one
quoted executable path, not a shell command or arguments; a relative path into
the checkout will not work after the script changes directory.

The scan script fetches public `fdroiddata` into a separate temporary checkout.
It creates a fresh scan workspace containing only the generated app recipe,
`srclibs/flutter.yml`, `config/categories.yml`, and regular
`config/category_*.png` assets. Required symlinks and special files are rejected.
Unrelated app metadata, Git internals and root `config.yml` are not mounted.
Only the scan workspace is exposed to the container, **not** the project checkout
or its parent. Both temporary trees are removed after the command. Public source
downloads still need network access; no credentials are passed to the container.
Use a trusted, credential-free host Git setup for the public definitions fetch.

The pinned scanner can report source preparation or scan problems while exiting
zero despite `--exit-code`. The caller therefore also requires exactly one
terminal `0 problems found` summary. Missing, duplicate, malformed or nonzero
summaries fail qualification; a zero process exit alone is insufficient.

## Deliberate restrictions

The adapter accepts only:

- `--version` or `--help` alone;
- `lint --force-yamllint com.trebuchetdynamics.fractal.forge`;
- `scanner --exit-code com.trebuchetdynamics.fractal.forge:CODE [...]`, with
  one to three positive numeric version codes.

It cannot execute a shell, build, publish, accept arbitrary tool flags or change
its image/runtime configuration. Lint/scanner require a dedicated **public**
metadata workspace containing a real `metadata/` directory. Root, home,
project-shaped directories (`pubspec.yaml` or `android/`), root `config.yml` or
`config.py`, symlinks/special files, and common secret markers such as `.env*`,
Android signing stores/properties, SSH/cloud credential directories and
`.git-credentials`/`.netrc` are refused before Podman starts. Paths containing a
colon are refused to keep bind-mount syntax unambiguous.

These checks are conservative guardrails, **not secret detection or certification
of arbitrary directories**. Do not point the adapter at an existing private
checkout, copy secrets into the temporary directory, add nested host mounts, or
modify it concurrently. Public metadata, recipes and downloaded sources must be
trusted to execute inside the isolated container; scanner preparation may execute
recipe commands. The adapter is not a sandbox for hostile local users or recipes.

Lint requests no network. Scanner uses rootless `--network=bridge` for public
source downloads, not host networking. Each tool container is removed after exit,
has a 1,800-second execution limit, drops capabilities, enables
`no-new-privileges`, and limits PIDs to 512. The only requested bind mount is the
validated cwd at `/repo`, writable for scanner outputs. No home, project root,
Podman socket, device, host credentials or host environment flags are supplied.
Podman's automatic proxy-environment forwarding is explicitly disabled to avoid
leaking credential-bearing proxy URLs. Container execution returns the tool's
exit status (or Podman's own failure/timeout status), without success fallback.

## Verification and remaining release gates

Run the isolated subprocess tests without a container or network:

```bash
/usr/bin/python3 -m pytest test/scripts/test_fdroid_container_adapter.py -q
```

They check the real wrapper's Podman argv, mount/network boundaries, directory
refusals, missing prerequisites and exit-code forwarding. The real scan script is
also exercised with explicit `FDROID_BIN`; only remote clone and Podman are
doubled, while its source-commit identity check remains real. This is **not** an
official source-scan result.

The initial adapter implementation did not run a full official scan. A later
2026-10-29 repair ran official lint and source preparation/scanning for all three
1.1.113 ABI codes against app source
`8fa9b06cc1bc2fa22b21b7da77c884e816ab5714`: the pinned tool reported
`0 problems found`, and owned cleanup completed. See the
[repair record](QUALIFICATION_ADAPTER_REPAIR.md#follow-up-unblock-repairs--2026-10-29).
Earlier failed and false-zero-exit attempts remain failures, not passing proof.

Reproducible source builds, signed-reference verification, Android
device/accessibility qualification and external maintainer acceptance remain
separate requirements. An explicit release request supplies publication authority
under the [standing defaults](../../../PRD.md#standing-release-defaults), not a
waiver of those requirements. No device or publication action is part of the tool
adapter itself.
