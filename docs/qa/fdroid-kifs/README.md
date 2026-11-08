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
