# KIFS Waydroid qualification — 2026-11-08

**KIFS journey: PASS (three cold starts). Android release gate: INCOMPLETE.**
This is emulator/container evidence, **not Adreno 610 hardware proof**, release
qualification, F-Droid acceptance, or publication.

## Candidate and receipts

- Tested source: `6ec81df95e936fb82c9a0a13f0aa4a80113de6c1`.
  Reviewed input: `25534a68cc43abb0bb4a409008d9e3378200ee55`.
  Production app/shader/Android sources and dependency files are unchanged from
  that input. The tested commit repairs only QA stimulus and log collection.
- Tested identity: instrumented debug `1.1.0+38`, not the F-Droid marker
  `1.1.122/122`. No new release identity was reserved. Cold-start/source defines
  produce different APKs; exact hashes are in each receipt. Only the third APK
  was retained privately before subsequent integration builds overwrote output.
  These are not three executions of one byte-identical production artifact.
- [Candidate/device/commands and gate outcomes](2026-11-08/receipt.json).
- Full renderer samples: [launch 1](2026-11-08/cold-1.json),
  [launch 2](2026-11-08/cold-2.json), [launch 3](2026-11-08/cold-3.json).

The designated instance was freshly verified as `192.168.240.112:5555`, model
`WayDroid x86_64 Device`, Android 13, boot complete. Container/session were
`RUNNING` on the existing headless display. ACAD-013 was closed; the execution
slot inventory showed only this worker running, and no Monkey process was
present. The task's typed live grant and matching `ANDROID_DEVICE` /
`ANDROID_DISPOSABLE_DEVICE` encoded standing app-replacement consent. No reset,
key enrollment, routing recovery, unrelated data deletion or publication occurred.

Flutter 3.47.9/Dart 3.13.7 came from the shared pinned cache. Python 3.12.3
pytest/Jinja2/MarkupSafe imports passed. Offline lockfile-enforced resolution
passed; `pubspec.lock` stayed SHA-256
`d919ab7eb6ad10b5939c81092b6f1657ba84642109ca677684184ccf30c55451`.

## Observed KIFS behavior

| Cold start | PID | Default soak | Cathedral soak | Samples | Exit |
| --- | --- | --- | --- | --- | --- |
| 1 | 27392 | 61,345 ms | 61,690 ms | 59 | 0 |
| 2 | 27584 | 61,115 ms | 61,624 ms | 59 | 0 |
| 3 | 27784 | 61,023 ms | 61,484 ms | 59 | 0 |

Each launch completed eight exact scale/fold/step boundary cases, rotation,
two-finger pan/zoom, leave/re-entry, Cross variant 1 and Mandelbulb controls.
All 177 renderer captures were opaque, nonblank and foreground-bearing at the
native 1600×2560 viewport, DPR 1.5. Sampled RGB hashes distinguish Sponge from
Cross. App logs identify the GPU shader path. SurfaceFlinger reports AMD Radeon
Graphics, Mesa 26.0.5, OpenGL ES 3.2—not Qualcomm/Adreno.

Internal PID checks and timestamped captures cover each scenario. No crash, ANR,
app death during the journey, or GPU submission/reset marker appeared in the
three bounded logcat intervals. Flutter force-stopped each process **after** its
successful `KIFS_COMPLETE`; post-run `pidof` was therefore empty. Receipts retain
these expected signal-9 exits, rather than treating them as survival after the
runner. System `OpenGLRenderer` swap-behavior warnings also occurred around
launch/teardown; they are not a new KIFS GPU submission/reset error.

The test keeps the existing 60-second durations and pixel/gesture assertions.
Initial diagnostic failures exposed below-slop pinch/drag input, repeated tap
zoom-out, a fixed-variant assertion against a noneditable parameter, and native
IME callbacks replacing injected search text. The repair uses real above-slop
gestures, registered test text input, and the existing uniform-default fallback.
It also records sampled RGB hashes. A diagnostic zoom-in moved Cathedral into a
uniform solid view; the final bounded inward pinch keeps geometry visible. This
is not certification of every possible camera pose. Automatic zoom adaptation
can report iterations 9; the unchanged shader still caps KIFS folds at 8.

## Android gate remains unqualified

1. The required full `pre-release-gate.sh` invocation exited **124** at its
   1,700-second bound, still in the host suite (`+3416 ~8` last progress).
   Analyzer passed; no host aggregate or device phase completed.
2. An explicitly partial `--skip-host` continuation exited **124** at 600 seconds,
   while building `perf_smoke_test.dart`. Last device progress was `+10 ~8`.
   This did not reach accessibility, runtime-thumbnail performance, release APK,
   restoration, offline journey, or the five-minute production soak.

Neither timeout is a passing gate or a product failure. No production APK hash,
signing proof, completed soak metrics or complete Android receipt exists here.
Private raw logs remain in this attempt's `$TMPDIR/evidence`; public receipts
retain their hashes and sanitized app/GPU/terminal excerpts, not unrelated logs.
The gate now preserves shared logcat and uses a validated device-time bound
instead of clearing buffers. Safety regressions passed: 48 Python cases and two
Bats cases; analyzer, formatting and shell syntax passed.

**Resume:** revalidate the serial/model/boot and exclusive ownership, preserve the
candidate and pinned environment, then execute the recorded full gate with a
scheduler budget sufficient for its host suite and device phases. A device-only
continuation cannot replace its missing full result. Freeze/hash the eventual
production artifact and rerun affected checks on any source/version change.
Keep FDROID-002 qualification pending; FDROID-003 owns the separate candidate-bound
Adreno verdict, and FDROID-004 owns final F-Droid identity/build qualification.

## FDROID-003 Adreno reviewer evidence — unresolved

**Hardware verdict: PENDING. FDROID-003 must remain open, not done.**
This is a sanitized discussion readback, not a hardware test or crash-resolution
receipt. Execution baseline: `ca0c54efb405a246a6699a8efead55669d81389d`.

### Discussion readback

At `2026-11-08T02:38:04Z`, the following read-only command returned all 30
current discussions successfully:

```sh
glab api projects/fdroid%2Ffdroiddata/merge_requests/46920/discussions --paginate
```

- Crash discussion: `6463a324c55d25d0d6dd342eee3232d014c674bd`.
  [MiggiV2 note 3986993227](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920#note_3986993227)
  was created and last updated at `2026-10-09T19:05:43.105Z`.
  It reports v1.1.104 (1042, arm64-v8a), Redmi Note 8T, Android 13/API 33,
  Adreno 610. Opening KIFS Menger Sponge reproduced
  `IOCTL_KGSL_GPU_COMMAND failed: errno 35` and SIGKILL twice.
  Menger Cross 3D and Mandelbulb rendered correctly. This is **historical crash
  evidence**, not a retest of the mitigation.
- The only reply in that thread is linsui's “Thanks!”
  ([note 3988567642](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920#note_3988567642),
  `2026-10-10T05:59:41.258Z`). The crash remains unresolved.
- [Existing follow-up 4185349142](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920#note_4185349142)
  by XelHaku was created and last updated at `2026-11-07T22:14:50.928Z`.
  It acknowledges the outstanding crash and says the MR still targets v1.1.104.
  No newer candidate-bound reviewer reply appears in the discussion inventory.
- Separate GETs of `discussions/6463a324c55d25d0d6dd342eee3232d014c674bd`
  and `notes/4185349142`, under the same MR API path, confirmed these records.
  No new note was created, so there is no created-note readback or retest reply.

The private discussion response has SHA-256
`dcd1d093f95868312dea486dbb416776a3fa686d5629fecae622d7fd7032ef2c`.
Only relevant public identifiers and findings are retained here, not account
metadata, unrelated review content or raw device logs.

### Missing binding and resume condition

| Required evidence | Current gap |
| --- | --- |
| Same candidate source, APK SHA-256 and version | Reviewer tested v1.1.104. No mitigated candidate identity or APK hash was confirmed. |
| Safe test artifact | FDROID-002 supplies instrumented debug hashes, not a qualified production APK or safe public download location. The F-Droid marker is not its tested version. |
| Device, OS and rendering backend | Historical Redmi Note 8T/Adreno 610/Android 13 identity exists. No new run or backend/log identity is confirmed. |
| Default and Cathedral, three cold starts, at least 60 seconds per state | No reviewer retest timings or repetitions are supplied. The historical two crash reproductions do not meet this scenario. |
| Supported extremes, rotation, pan/zoom, leave/re-entry and controls | No candidate-bound hardware journey or visible-frame evidence is supplied. Historical working controls cannot qualify the new candidate. |
| Liveness and timestamp-bounded app/GPU logs | No candidate-bound evidence excludes IOCTL_KGSL failure, SIGKILL, ANR or GPU reset. |

**Request posting: NOT_RUN.** The prerequisite Android release gate remains
incomplete. No reviewed, distributable production artifact with a safe URL and
SHA-256 is supplied by the consumed receipts. Posting the debug hashes or the
1.1.122/122 marker as a qualified candidate would misstate that evidence.
Existing scoped deployment authority is retained; no new owner approval or
physical target is requested. No device, publication, pipeline or MR mutation
was performed, and no external-response wait retains a resource lease.

**Resume:** complete the pending FDROID-002 Android gate and bind the reviewed
source/version to the exact distributable APK, SHA-256 and safe artifact URL.
Under coordinator admission and exclusive candidate/MR ownership, reread the
crash thread to avoid a duplicate request. Post one truthful retest request in
that existing thread, with those identities and the acceptance scenarios above.
Read back the created note, then release operation leases while awaiting feedback.
Accept only the original reviewer or an already-authorized comparable Adreno 610
target, with hardware/OS/backend differences recorded. Compare the reply and
sanitized logs/visible frames against every required row before a hardware pass.
A v1.1.104 or different-APK reply remains historical/unbound, not a pass.
A later FDROID-004 source/artifact change requires renewed binding and affected
hardware retesting before FDROID-005 final submission. Waydroid, host raster and
pipeline #2832429861 cannot replace this confirmation.

## FDROID-004 source-build and scan evidence — unqualified

**Local unsigned reproducibility and source scan: PASS. Release qualification:
INCOMPLETE.** This pass tested source
`0e4d9338ee581a555da86293cae7a4768bff769f`. It did not freeze a qualified
release, reserve a new version, sign/distribute an APK or mutate !46920.
The mitigation and catalog retain the SHA-256 values recorded in
[FDROID-001](../../engineering/release/FDROID.md#fdroid-001-local-regression-evidence).
Reuse the existing builders and adapter. No source, recipe, SDK, dependency,
lockfile or signing-policy change was needed.

### Identity and live inventory

- Local marker: `1.1.122/122`, unchanged. Matching Fastlane `122.txt` exists
  and passes the builder's metadata limits. Derived ABI codes are 1221/1222/1223.
- SDK: Flutter 3.47.9, framework `c197ca5199`, engine `89c39edfdf`, Dart 3.13.7.
  The shared provisioned SDK matches `fdroid/flutter.version`.
- Lockfile SHA-256: `d919ab7eb6ad10b5939c81092b6f1657ba84642109ca677684184ccf30c55451`.
  Offline enforced resolution passed; the build and scan left it unchanged.
- Android SDK: existing `/usr/lib/android-sdk`, compile/target 36,
  NDK `28.2.13676358`. No host tooling install, image pull or validation bypass ran.
- Read-only remote inventory at `2026-11-08T03:41:16Z`: GitHub's latest
  [published release](https://github.com/TrebuchetDynamics/flutter-fractal-forge/releases/tag/v1.1.112)
  is v1.1.112, tag/source `988a7145fc9a5fbd4995bf8804a7d5a509707f86`.
  All three ABI reference assets exist there. They are a different source/version,
  not references for this checkout. Their API digests were read, not downloaded
  and certificate-verified. A v1.1.122 release lookup returned `release not found`.
- Public GitLab source tags still stop at v1.1.104. Existing
  [!46920](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920)
  remains opened, source project `85800484`, branch
  `new-app-com-trebuchetdynamics-fractal-forge`, head
  `16238180cb87bc3e488bfa0bc461ca99e51eea67`.
  Its recipe still binds app source `987eb6764b51520df74566068132fb29971ccb99`,
  version 1.1.104, codes 1041/1042/1043. The successful
  [pipeline 2832429861](https://gitlab.com/fdroid/fdroiddata/-/pipelines/2832429861)
  and its nine successful jobs, including `fdroid build`, apply only to that head.
- Version 122 is above these observed GitHub/F-Droid identities. That comparison
  does not reserve it or prove that every distribution has never consumed it.
  Re-read inventory before final freeze. Older artifacts cannot qualify current source.

Inventory used `gh release list`, `gh api` release/tag/commit endpoints, and
`glab api` public source tags, MR head/recipe and pipeline jobs. The tested full
source commit was also readable through GitHub's commits API. No remote write ran.

### Executed checks and artifacts

The following commands used the root AGENTS.md pinned environment, with
`RELEASE_COMMIT=0e4d9338ee581a555da86293cae7a4768bff769f`,
`RELEASE_VERSION=1.1.122`, `RELEASE_BUILD_NUMBER=122` and
`RELEASE_ARTIFACT_DIR="$PWD/release-artifacts"`:

```sh
autowork-run timeout --signal=TERM --kill-after=30 1700 \
  bash scripts/build-fdroid.sh --version="$RELEASE_VERSION" \
  --build-number="$RELEASE_BUILD_NUMBER" --commit="$RELEASE_COMMIT" \
  --reproducible --output-dir="$RELEASE_ARTIFACT_DIR/fdroid" \
  --flutter-bin="$FLUTTER_ROOT/bin/flutter"

export RELEASE_LOCAL_STAGE=1
export FDROID_BIN="$PWD/scripts/ci/fdroid-container.sh"
autowork-run timeout --signal=TERM --kill-after=30 1700 \
  bash scripts/ci/fdroid-scan.sh
```

Both exited **0**. Each build round verified the package
`com.trebuchetdynamics.fractal.forge`, version, ABI, derived code and absence of
signatures. The builder reported byte-for-byte equality for all three clean
rebuilds. Generated APKs, per-ABI `.sha256`/`.provenance` files and metadata bundle
remain in this worker's ignored `release-artifacts/fdroid/`, not in Git or a
published release. Preserve these outputs before worktree cleanup, or reproduce
them from the exact source. **Do not distribute unsigned verification APKs.**

| Unsigned ABI | Code | APK SHA-256 |
| --- | --- | --- |
| armeabi-v7a | 1221 | `3ab16d7abdefae34050776165e32515421030851a96e6c976d774400553b59a0` |
| arm64-v8a | 1222 | `ffd8752a9635095872f5ea5de60eb0de4fef425a29ab496aedd77bd0b269db30` |
| x86_64 | 1223 | `00695f89a9c89e98146112af3940b187afcd22a5eacf7ed608873bca0ecfdd76` |

All provenance files bind that full source, Flutter 3.47.9, base 122 and source
epoch `1794109104`. The metadata bundle SHA-256 is
`bcd70f0461bbb5d24b45b9fb4891e0d2e18e78fe68f0f2808af29fe04d3a0389`.
A second metadata-only render matched the archive byte-for-byte; all four staged
checksum files verified. The generated recipe contains the full tested commit,
three reference URL templates and allowed certificate
`8d5f69b91dd44476ceaad141f1fa9f6abeccdfa20cd3f7bcdfe709df623878fd`.
A recipe pin is not evidence that a reference APK has that certificate.

The already-cached rootless adapter reported tool version `399ac60` using the
[pinned image](../../engineering/release/FDROID_CONTAINER.md).
Lint exited zero. Source preparation/scanning ran for all three derived codes and
ended with exactly one `0 problems found` summary. Dependency font/WASM warnings
remain warnings, not a signed-APK scan verdict. The adapter's owned temporary
workspace was removed on exit. No unsupported adapter command ran.

Additional checks passed: Python pytest/Jinja2/MarkupSafe imports; eight
`fdroid_pipeline.bats` cases; 80 container-adapter pytest cases; and all six
`kifs_menger_gpu_safety_test.dart` host tests. No new test was needed because this
pass changed only evidence/docs. The coordinator owns the final merged-tree
offline integration gate; this receipt does not claim it ran here.

Private full build/scan log SHA-256 values, respectively:
`bc7d6176efd68a66619b5a01c04e66fde56708168848c839d3f4eaaa14e95d35` and
`0a5dc5def3f3222e7123f5dff0466fde5391d0c5d9405894dcf9744e609a0fdc`.
These logs remain task scratch, not durable published evidence.

### Remaining qualification and resume

1. Bind one reviewed final source/version/artifact identity. The previous
   FDROID-002 debug `1.1.0+38` journeys at `6ec81df9` do not qualify these release
   APKs. Rerun the focused installed journey and full Android gate on the final
   candidate using the designated Waydroid target and matching consent variables.
   Retain the prior timeouts. Waydroid evidence is not Adreno confirmation.
2. Produce three signed reproducible references through the existing signing
   workflow. This isolated checkout has no `android/key.properties`; no signing
   was attempted or key accessed. Verify package/version/ABI, pinned certificate
   and reproducibility. Do not substitute historical references or debug signing.
3. The host has no `fdroid` executable or discovered official fdroiddata/buildserver
   workspace. Official `readmeta`, `rewritemeta`, `checkupdates --auto`,
   `build --test --no-tarball` and signed-reference APK scans are **NOT_RUN**.
   Local container lint/source scans cannot replace them. Under coordinator
   admission and candidate/MR leases, update existing !46920 and request explicitly
   **unqualified** candidate build verification during FDROID-004, not FDROID-005.
   Bind the actual head/source/hash and every pending gate. Do not claim missing
   references exist. Read back the new head, pipeline and three verified builds.
   Release operation leases while awaiting maintainers. No request was posted here.
4. Before reference publication, require source/legal/privacy/compatibility,
   Android and signing gates. After publication, download all three exact URLs and
   compare SHA-256, certificate and package identities. None of these publication
   or signed-reference readbacks ran here. Do not infer them from unsigned hashes.
5. Keep FDROID-003's candidate-bound Adreno confirmation and F-Droid maintainer
   acceptance/public catalog readback separate. This partial receipt is not a
   qualified handoff to FDROID-005 and cannot close combined release acceptance.

## FDROID-005 submission disposition — 2026-11-08

**Final submission: NOT_RUN. Catalog publication: NOT_VERIFIED. Acceptance
remains open.** This disposition inspects the receipts at execution baseline
`f081af5d1a70c5a3f8c46701879927a59f6ac16c`; it is not a fresh remote readback.
The task-store closure of FDROID-003/004 does not supply their missing live
qualification. Their retained evidence explicitly leaves these gates pending:

| Prerequisite | Consumed evidence and remaining gap |
| --- | --- |
| FDROID-003 hardware confirmation | The [discussion readback](#discussion-readback) contains the historical v1.1.104 crash, not a candidate-bound Adreno retest. No bound request or reply exists in that receipt. |
| FDROID-004 release qualification | The [source-build receipt](#fdroid-004-source-build-and-scan-evidence--unqualified) proves local unsigned reproducibility and source scans at `0e4d9338ee581a555da86293cae7a4768bff769f`, not signed references, official verification or final-candidate Android qualification. |

The saved FDROID-005 live scope requires both qualifications before final MR
review/submission and catalog readback. No live operation ran here.
No MR body, checklist, thread, branch, pipeline or reference asset was changed.
This worker requested no operation lease for an external wait. Reuse the existing
MR and evidence owners; no duplicate submission, runner, polling schedule, code,
recipe, dependency or generated asset is needed for this disposition.

### Separate delivery verdicts

| Stage | Verdict supported by the consumed receipts |
| --- | --- |
| Existing submission | Last read at `2026-11-08T03:41:16Z`: [!46920](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/46920) opened, source project `85800484`, branch `new-app-com-trebuchetdynamics-fractal-forge`, head `16238180cb87bc3e488bfa0bc461ca99e51eea67`. Recipe: v1.1.104, codes 1041/1042/1043, app source `987eb6764b51520df74566068132fb29971ccb99`. Not the mitigated candidate. |
| Maintainer CI | [Pipeline 2832429861](https://gitlab.com/fdroid/fdroiddata/-/pipelines/2832429861) succeeded on that old MR head only. No final-candidate CI result is supplied. |
| Maintainer acceptance/merge | Not established for a qualified mitigated candidate. Current review/merge state was not queried in this pass. |
| Public catalog | Package/version/source/APK SHA-256/signer comparison is NOT_RUN. No qualified signed reference set exists in the consumed receipts to compare against. This is not evidence of catalog absence or publication. |

### Resume after qualification

Complete the pending final-candidate Android, signing/reference and official
verification gates in FDROID-004, then obtain/rebind FDROID-003 hardware evidence
to those exact source/APK identities. The explicitly unqualified maintainer
build-verification request remains FDROID-004 work, not final submission here.

Once those gates pass, the coordinator must bind the candidate/artifact hashes
and acquire the applicable operation leases. Read the current MR and all
paginated discussions with `glab api` before writing. Verify source project,
branch and head ownership; retain the exact metadata diff and remote head.
Update only !46920 with the same candidate's evidence and accurate checklist.
Read back the body, note, diff SHA and pipeline before any retry. Request missing
official checks only when needed. Release leases while awaiting external replies.

F-Droid maintainer acceptance/merge and public build/index publication remain
external. On an actual response, read the current MR head/review/pipeline and
[public package metadata](https://f-droid.org/en/packages/com.trebuchetdynamics.fractal.forge/).
Compare every published ABI's version code, source tag/commit, APK hash and signer
against the qualified references. Until both acceptance and matching catalog
readback are observed, keep FDROID-005 and goal FDROID-KIFS-001 unaccepted.
Submission, successful CI or merge alone cannot establish catalog publication.
