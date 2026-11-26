# Google Play publication: 1.1.126 (126)

`com.trebuchetdynamics.fractal.forge` was uploaded once to production, status `completed`. Receipt time: `2026-11-23T00:56:09.013018Z`; edit `08788985708217140187`. Clean source: `acdcbfdd89c0f27f8694e6e3a475c85dfdcae431`.

The signed AAB is 75,416,329 bytes. Its locally recomputed SHA-256 matches the independent production/completed/126 readback: `ecc9c4ce607c826a92283adddf25d00773bcaa7c61a05be100db8362954f9503`. Upload certificate SHA-1: `1F:01:3D:4F:BE:48:4B:DA:4B:1F:49:3F:DF:0C:F0:37:1D:46:E0:58`.

Compared with 125, holding Edit opens Controls directly; a tap still randomizes. Phones can expose one selected parameter slider. History entries remain reachable in short landscape layouts, and small overlay actions have larger hit areas.

The first preflight stopped before testing: Waydroid reported an unknown IP and no ADB transport. No upload occurred. On resumption, the network report succeeded and the current designated target passed ADB state, native model and boot checks. Neither qualification gate was skipped. Rust: 127 passed; analyzer clean; Flutter: 3662 passed, 9 skipped; Python: 734 passed, 1 skipped and 204 subtests passed; Bats: 34 passed. Device suites: 12 passed with 8 skipped, then 1 and 1 passed. The 300-second soak passed with 2% final jank (10% limit), peak PSS 207316 KiB, growth 72824 KiB, thermal status 0 and no crash evidence. The thermal HAL was not ready; these are container observations, not hardware qualification.

At 00:56:32Z all 12 storefront probes still showed 125. The observer completed; the live checker did not confirm propagation or Google review approval. No reupload is needed. No other platform was published.

Private artifact, publication receipt, readback, observation and live-check results: `/home/xel/play-126-resume.4uqyWfgW/artifacts/`. Gate evidence: `scratch/release-play-1.1.126-1mSsWd/gates/` under the same private root.
