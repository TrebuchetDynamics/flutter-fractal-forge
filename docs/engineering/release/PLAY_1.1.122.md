# Google Play publication: 1.1.122 (122)

## Confirmed production operation

- Existing package: `com.trebuchetdynamics.fractal.forge`.
- Published to the existing **production** track with API status **completed**.
- Committed Play edit: `16086799263151284983`.
- Receipt timestamp: `2026-11-06T22:30:08.148930+00:00`.
- Release source: `63fd0d6a` (`chore(release): prepare 1.1.122`) on `main`,
  based on `0b1ecfcd`.
- AAB: 73,464,994 bytes, SHA-256
  `5e939a0900f6e291a762647f88f89ef5b0b85e9d4d684aefdacc7e8703407db7`.

Independent readback:

```json
{"found": true, "conflict": false, "versionCode": "122", "track": "production",
 "status": "completed",
 "aabSha256": "5e939a0900f6e291a762647f88f89ef5b0b85e9d4d684aefdacc7e8703407db7"}
```

A fresh `scripts/ci/play-status.sh` lists release `122 completed` and latest
consumed version code `122`.

Google review status, storefront propagation and end-user availability are
separate observations; see the snapshot below.

## Why 1.1.122

Play production carried **1.1.121 (121)** from `d2046cf7`. Version code 121 is
consumed, so this release takes 122 from the then-current `main`. The 122 bundle
hash differs from the 121 hash, so it is a new artifact.

## What changed since 1.1.121

- Viewer tools use labeled buttons; the random actions explain themselves.
- Labeled-toolbar reachability and accessibility regressions repaired.
- Store screenshots and listing copy refreshed and committed (not yet uploaded
  to the listing).

## Qualification

Pinned Flutter **3.47.9**, Dart **3.13.7**, lockfile SHA-256
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.

- **Shared offline gate**: passed on `63fd0d6a` in a separate invocation of the
  same commit (pub get, analyzer, Flutter host tests, Python tests, Bats; lock
  unchanged). Receipt:
  `/tmp/release-play-artifacts-1.1.122/offline-gate-pass-63fd0d6a.json`.
  The publishing invocation skipped the rerun with `--skip-gate` so the device
  gate would start on a fresh connection. The evidence records
  `shared_offline_gate: skipped`, not passed.
- **Device gate**: passed on Waydroid `192.168.240.112:5555`, Android 13,
  x86_64. Container evidence, not physical-device or hardware-GPU proof.
  - Combined integration suite: **12 passed, 8 skipped**.
  - Rapid-scroll catalog thumbnails: **1 passed**.
  - Production-mode artifact: built, installed and exercised.
  - 300-second soak: PSS first 132,426 KiB, last 208,518 KiB, peak 209,649 KiB,
    growth 76,092 KiB; final janky frames **0 %** (limit 10 %); thermal status
    **0**; no crash or ANR.

### Host contention

The first two publishing attempts failed on timing-sensitive device tests while
the host was oversubscribed (load 17–25, including a 900 %-CPU training job):
once the soak produced no mature jank sample, once the catalog thumbnail
placeholder missed its 5-second budget. Both failures stopped before upload. The
passing run completed at load near 16 with a fresh device session.

## Post-publication observation (2026-11-06)

Observed with `scripts/ci/play-observe.sh --expected-version 1.1.122
--expected-date "Nov 6, 2026"` minutes after the upload.

- Official track: production `completed`, versionCodes `["122"]`.
- Country availability: **177** targeted countries plus `restOfWorld: true`.
- Storefront probe (12 countries): all listed, but every page still shows
  **1.1.121**, `Updated on` Nov 6, 2026. Inference:
  **`not-yet-visible`** (pending 12/12). This is the expected review and
  propagation lag, not a publication failure.
- Google review: **not observable** through the public API; not confirmed by
  this agent. Console Publishing overview and the review email remain the direct
  sources.
- Evidence: `/tmp/release-play-artifacts-1.1.122/play-observe-122.json`.

Re-run `play-observe.sh` later and expect the version to become 1.1.122 in the
storefronts; use `play-live-check.sh` for a pass/fail verdict once it does.

## Limits

- Google review, per-device and per-account availability are not observed.
- Waydroid results are container evidence.
- The shared offline gate was not rerun inside the publishing invocation; the
  skip is recorded and the earlier pass on the same commit is cited.
- Store screenshots and listing copy committed in this source are not yet
  uploaded to the Play listing.
