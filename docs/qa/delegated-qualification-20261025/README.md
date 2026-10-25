# Delegated qualification evidence — 2026-10-25

**Start here:** this is QUAL-EVIDENCE-01's **failed-capture evidence packet**, not qualification or human acceptance. Two unchanged native runs and one diagnostic-only run saved actual edited **Mandelbrot** PNGs, then failed before Mandelbulb. **No successful complete 2D/3D journey, Mandelbulb export, or human verdict exists in this packet. All 23 holds remain.**

The [machine-readable manifest](manifest.json) links private retained bytes, source/SDK/backend fingerprints, exact observed state, failures and each retained task's missing inputs. The authority is [the delegated decisions](../../tasks/DELEGATED-DECISIONS-20261025.md#execution-and-release-of-holds); the [task contract](../../../tasks/items/QUAL-EVIDENCE-01.md) permits capture/provenance only and requires preservation of an unavailable route's exact failure. A failed execution is not converted into a passed check.

## Retention and private readback

Artifacts are **outside TMPDIR and the disposable worktree**, in the repository's private Git common directory:

```text
autowork-execution/slot-data/QUAL-EVIDENCE-01/attempt-1/retained/
```

Resolve that suffix against `git rev-parse --git-common-dir`, **not** the worktree's `.git` file. Files are owner-readable only; no upload, public asset link or credential is required. Private artifacts do not travel with a clone or this commit. Preserve this slot directory during coordinator cleanup and arrange separately authorized retention if the host is decommissioned. Missing private files invalidate readback; this manifest is not a substitute for bytes.

Contents include all three `run.json` receipts, driver logs and official driver output; three actual PNG/state pairs; an immutable baseline source archive; the exact diagnostic patch/harness; SDK hashes; and owned-process library maps/hashes plus same-display GL probes. The diagnostic logging was removed after observation: the final integration test is byte-identical to the baseline. No assertions, waits, selection logic or product behavior were changed.

From a checkout with the private directory present and the existing Pillow decoder:

```sh
common=$(git rev-parse --git-common-dir)
retained="$common/autowork-execution/slot-data/QUAL-EVIDENCE-01/attempt-1/retained"
/usr/bin/python3 "$retained/verify-evidence.py" "$PWD"
```

The verifier checks every retained file hash/size, source-archive bindings, actual PNG decode/content/state, failed protocol outcomes, reserved listeners, cleanup and exact 23-task hold coverage. Its pass means **the failure packet reconciles**, never that the journey passed. No packages should be installed to replay it.

## Actual native execution

Source baseline: `5f77b348bd7907cd5e7776b5b05f6be48157bb20`. Flutter **3.44.6**, framework `ee80f08bbf97172ec030b8751ceab557177a34a6`, engine `83675ed27633283e7fc296c8bca22e841224c096`, Dart **3.12.2**. Offline lockfile-enforced package resolution completed without changing `pubspec.lock`.

Following the [owned-runtime runbook](../../engineering/runbook.md#owned-linux-runtime-with-reserved-ports), with the actual assigned `AUTOWORK_PORT_BASE=20200`, task TMPDIR, pinned `FLUTTER_ROOT`, provisioned `PUB_CACHE`, and SDK-first `/usr/bin`-bound PATH:

```sh
autowork-run timeout --kill-after=10s 960 bash scripts/run-native-integration.sh \
  integration_test/flows/user_flows_test.dart --timeout 900 \
  --dart-define=FORCE_GPU_RENDER=true
```

The wrapper fixed Linux/debug, `--no-pub --no-dds --no-devtools --no-publish-port --no-keep-app-running`, both VM-service ports to **20200**, and Xvfb TCP off. Each run observed only `127.0.0.1:20200` within **20200–20299**. Every receipt records **exit 1**, **`protocol_success: false`**, and **`cleanup.remaining_pids: []`**. No success callback file was produced. The raw terminal counter `+12 ~1 -1` includes teardown: **11 product cases passed, 1 failed, 1 pre-existing Barnsley Fern default-view skip**. This is neither a green suite nor a newly waived skip.

The existing journey (`integration_test/flows/user_flows_test.dart:217–373`) edits a view by gesture, checks formula/qualification, selects HD export, decodes PNG dimensions/content, verifies unchanged edited view and writes observed preset/viewport state. In each attempt the Mandelbrot PNG and state sidecar were written before `StateError: Bad state: No element` at the next module's `scrollUntilVisible` (`:270`). The third run added only catalog diagnostic output: when requesting Mandelbulb it observed query **Mandelbrot**, the previous cards and **26** results. The exact diagnostic bytes and failure remain private and hash-bound.

**Diagnosis limit:** native test-input focus/reconnection after returning from the viewer is a source-supported hypothesis, not a runtime-proven cause or repaired behavior. More scrolling/debounce delay is not evidence of a fix. Scope review agreed to preserve the failure rather than change synchronization within this capture-only task. A separately scoped repair must reproduce this stale-query behavior, preserve the existing journey assertions, and obtain a fresh complete official-protocol run. No new task or hold release is created by this document; the coordinator owns that follow-up.

The official adapter only writes success after decoding the terminal binding response (`test_driver/integration_test.dart:7–12`); the supervisor preserves missing-response/nonzero failure and records owned cleanup (`scripts/run-native-integration.sh:160–192`). Console progress or an existing partial PNG cannot replace this gate. GDK monitor/cursor and OpenGL resize warnings remain in the logs.

## Measured artifacts and state limits

| Artifact | Actual decoded pixels | Every-fourth-pixel RGB samples | Status |
|---|---|---|---|
| Mandelbrot, each of 3 attempts | 1280 × 720, RGBA, all alpha 255 | 57,600 samples; 975 distinct colors; 48,189 nonblack | Actual partial-run exports, not synthetic replacements |
| Mandelbulb | **Absent** | Not measured | Failed before capture; no inferred state or image |

All three decoded RGBA buffers have SHA-256 `ce761c16e8e8fe541805b69974d305915b9ceb5157f8a9866632b052fc576a73`. Their encoded PNG hashes differ; the manifest retains each separately. Dimensions and varied samples satisfy only these numerical properties, not composition, readability or formula fidelity.

Each original `.png.state.json` is retained byte-for-byte and decoded into the manifest. It observed viewport `[1280,900]`, Mandelbrot params `{iterations:350, bailout:4.0, colorScheme:0}`, pan `[-0.6523809523809524,-0.0761904761904762]`, zoom `0.35`, and zero XYZ rotation. This is the **post-export edited state**, not a reconstruction from defaults. The existing test's edited-view assertions passed before the later navigation failure. Its `createdAt` is a runtime preset-serialization timestamp, not an independently measured export timestamp; do not infer cross-clock duration/performance.

Original unedited state, effects toggles, transparency settings, animation/capture timing and complete renderer state were **not observed in these sidecars**. Opaque decoded pixels do not prove the selected transparency option. If any review requires those inputs, capture them in a fresh permitted run; do not fill gaps from defaults or the historical receipts. Spanish, inspired/unverified samples and human composition/readability are also absent.

## Target and backend classification

- **Owned Linux/Xvfb:** application logs report the shader `gpu` path, but the same owned display's `glxinfo -B` reports **Mesa llvmpipe (LLVM 20.1.2, 256 bits), Mesa 25.2.8, `Accelerated: no`**. This is **software rendering**, not a physical hardware-GPU session or the app's CPU-formula fallback. The GL probe corroborates the display; it is not an in-app `GL_RENDERER` query. Each run's owned `/proc` mapping and engine/Mesa/LLVM hashes are retained.
- **Read-only Android inventory:** `adb devices -l` against an existing server observed **Waydroid x86_64**, an emulator/container, **not a physical device**. No device session was attached, no shell/install/uninstall/reset ran, and installed app/build, MediaStore bytes, gallery visibility and accessibility were not verified. Inventory is not installation consent or a journey pass.
- No hardware-GPU, physical-screen-reader/rotation, production-font, signing, credential, remote-service, publication or human-review checks ran.

## All 23 retained holds

These are missing inputs, **not reopened product choices**. Exact original hold text, task-source hashes and dependencies are in `manifest.json.retained_tasks`. This packet neither clears a hold nor grants another task this worker's now-ended allocation.

| Retained task | Still missing |
|---|---|
| [ACAD-01-LIVE](../../../tasks/items/ACAD-01-LIVE.md) | Attributable human identity/alias adjudication of the draft packet. |
| [ACAD-02-LIVE](../../../tasks/items/ACAD-02-LIVE.md) | Per-source human relevance/version/rights decisions; no full-text approval. |
| [ACAD-03](../../../tasks/items/ACAD-03.md) | Exact human-approved identity/source subset, lawful access evidence and separate claim acceptance. |
| [ACAD-04](../../../tasks/items/ACAD-04.md) | Qualified ACAD-03 pilot and per-subset human approvals. |
| [CAT-QUALITY-01-LIVE](../../../tasks/items/CAT-QUALITY-01-LIVE.md) | Named physical target, attributable reviewer and control/export/performance verdicts. |
| [CAT-QUALITY-02-LIVE](../../../tasks/items/CAT-QUALITY-02-LIVE.md) | Mobile/physical journey, human review and missing independent formula reference. |
| [FIB-PRIME-03](../../../tasks/items/FIB-PRIME-03.md) | Its own named permitted Linux/browser execution/allocation and actual journey; Android and reviewer inputs stay separate. This worker's software target is inventory only. |
| [GAUSS-MOAT-02-WALK-LIVE](../../../tasks/items/GAUSS-MOAT-02-WALK-LIVE.md) | Suitable physical device and visual/accessibility/performance reviewer. |
| [GAUSS-MOAT-03-QUALIFY-LIVE](../../../tasks/items/GAUSS-MOAT-03-QUALIFY-LIVE.md) | Authorized target, B=128 telemetry, actual MediaStore/gallery readback and human accessibility/composition review. |
| [GAUSS-MOAT-04-GROWTH-LIVE](../../../tasks/items/GAUSS-MOAT-04-GROWTH-LIVE.md) | GAUSS-MOAT-03 live device verdicts and growth-state export evidence. |
| [ICON-ZJ-02](../../../tasks/items/ICON-ZJ-02.md) | VIS-003 installed-launcher verdict on a separately authorized Android target; no repeated upload. |
| [QUAT-NORM-01-SLICE-LIVE](../../../tasks/items/QUAT-NORM-01-SLICE-LIVE.md) | Named device and attributable visual/screen-reader/list-selection verdict. |
| [QUAT-NORM-02-WALK-LIVE](../../../tasks/items/QUAT-NORM-02-WALK-LIVE.md) | Physical gestures/accessibility/native-export qualification. |
| [QUAT-NORM-03-QUALIFY-LIVE](../../../tasks/items/QUAT-NORM-03-QUALIFY-LIVE.md) | Authorized Android target, decoded exports and remaining physical-GPU qualification. |
| [RELEASE-001-23-LIVE](../../../tasks/items/RELEASE-001-23-LIVE.md) | Missing lane hosts/target verdicts; separate signing/credentialed-operation authority and external Apple/F-Droid acceptance. |
| [RELEASE-003-ae](../../../tasks/items/RELEASE-003-ae.md) | Immutable prepared subset/digests/destinations and attributable candidate-bound production approval. No production check attempted. |
| [REL-JOURNEY-02-LINUX-LIVE](../../../tasks/items/REL-JOURNEY-02-LINUX-LIVE.md) | Complete source-bound edited export packet (Mandelbulb and successful protocol still absent) and attributable human composition/readability verdict. Partial Mandelbrot files are available, not accepted. |
| [REL-JOURNEY-03-ANDROID-LIVE](../../../tasks/items/REL-JOURNEY-03-ANDROID-LIVE.md) | Separately authorized install-safe named target, actual MediaStore bytes/gallery verification and reviewer. |
| [SMOOTH-001-INVENTORY-01-LIVE](../../../tasks/items/SMOOTH-001-INVENTORY-01-LIVE.md) | Named hardware-GPU render/performance session and visual reviewer. |
| [SMOOTH-001-INVENTORY-02-LIVE](../../../tasks/items/SMOOTH-001-INVENTORY-02-LIVE.md) | Named hardware-GPU Multibrot render/performance session and visual reviewer. |
| [VIEW-UI-01-LIVE](../../../tasks/items/VIEW-UI-01-LIVE.md) | Physical screen-reader/rotation, hardware-GPU and production-font verdicts. |
| [VIEW-UI-02-LIVE](../../../tasks/items/VIEW-UI-02-LIVE.md) | Actual same-state native screenshots/SDK/typography evidence plus physical screen-reader reviewer verdict; exported fractal pixels are not viewer-chrome screenshots. |
| [VIS-003](../../../tasks/items/VIS-003.md) | Actual installed approved-B Android launcher presentation and attributable reviewer; no install/upload authorized here. |

## Scoped Docs Sync Maintain and update triggers

Maintained this evidence owner (`README.md` and `manifest.json`) against the actual receipts, the 23 task records and delegated decisions. Verified the existing runbook's invocation and historical [test-plan](../../engineering/test-plan.md#accepted-cross-platform-release-journey) without relabeling historical supplemental execution as official-protocol success. No product/spec, shared history or task-store edits are required for this failed evidence-only result; the coordinator owns follow-up task/closeout maintenance.

Readback checks: the private verifier reconciles all file bindings, decoded content/state, ports, cleanup, exact held-task IDs and local Markdown links/anchors; `autowork tasks validate --worktree .` preserves the unchanged valid store; `git diff --check` checks the final patch. Bundled Docs Sync `docs.py check`/`stale` report no role manifest, so explicit scoped checks supply link/content verification instead. The full offline gate is reserved for the coordinator's merged tree and was not run here.

Revisit this packet after any source/harness/SDK/backend/state change, a private-retention move, a fresh complete journey, new target authority or an attributable verdict. Keep new observations separately source-bound; do not repin the failed receipts or silently replace absent state. All external-evidence holds remain until their exact original inputs and checks exist.
