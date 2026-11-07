# RUST-M2-PRIME — Resumable exact prime certification

## Scope and API

This implements the prime preparation slice of
[RUST-PLAN-04](RUST-PLAN-04.md#decided-implementation-seams), from baseline
`dfa45147e49604797ae9ac8d87fa0121dde52bb9`.
The [Number Walls replay validation boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
remains normative and unchanged. This is an offline core API, not an app owner switch.

[`fractal_core::number_wall_prime`](../../rust/crates/fractal-core/src/number_wall_prime.rs)
exports:

- `MAX_DECIMAL_DIGITS = 256` and `DEFAULT_MAX_TRIAL_DIVISIONS = 100_000`.
- `NumberWallPrimeJob::new(input: &str, max_trial_divisions: u32)` checks raw
  ASCII digits and length before removing leading zeros. Empty input, malformed
  input, oversized input and values below two finish as `Invalid`.
- `advance(&AtomicBool)` performs the small-prime screen once, then at most 1024
  odd trials. `None` means pending. The flag is Rust-local and can be shared with
  another thread. There is no Dart callback or asynchronous executor.
- `result()` returns an immutable terminal `NumberWallPrimeCheck` reference.
  Job `divisions()` exposes progress without certifying pending input.
- Check getters `status()`, `prime()` and `divisions()` expose the typed result.
  Status is `VerifiedPrime`, `Composite`, `Invalid`, `Unverified` or `Cancelled`.
  Only `VerifiedPrime` carries canonical exact decimal text in `prime()`.
  Small-prime checks do not contribute to the division count.

The budget applies to the entire job, not each advance. `Unverified` is terminal.
A caller can start a new job with a larger budget, but cannot promote syntax,
replayed flags or an unfinished check to a certificate. After completion,
subsequent advances return the same result, including after cancellation.

## Algorithm equivalence and bounds

The algorithm follows
[`NumberWallPrimeValidator`](../../lib/core/models/number_wall_model.dart)
and its [existing tests](../../test/modules/number_wall_model_test.dart):

1. Reject invalid raw input before cancellation. Leading zeros count toward the
   original 256-digit limit. ASCII-only acceptance makes Rust byte length and
   Dart string length equivalent for all potentially accepted input.
2. Check cancellation before each small prime, in source order from 2 through 47.
   Equality verifies that small prime. A zero remainder proves composite.
3. Try odd candidates from 53. Compare the canonical decimal input with the
   candidate squared, by decimal length and lexicographic order. This is exactly
   `candidate <= floor(sqrt(value))`, without computing a floating-point root.
4. Within the root, check cancellation before the total trial budget. An exhausted
   budget returns `Unverified`. Each attempted odd division counts once, including
   a successful factor test. A root already passed wins over budget exhaustion.
5. Return pending after each full 1024-trial chunk, even at the root or budget
   boundary. The next advance checks cancellation at the next trial or final
   completion, matching Dart's post-chunk yield. Final cancellation wins over
   verification. Completed results are never revised.

Remainders scan decimal digits exactly. A `u128` intermediate holds
`remainder * 10 + digit` for a `u64` divisor. The full input is never parsed into
machine integers. A `u32` total budget bounds the next `u64` candidate by
`53 + 2 * u32::MAX = 8589934643`. Its square fits `u128`. Candidate, count and
square arithmetic use checked operations. Internal invariant exhaustion panics
instead of wrapping; valid public inputs cannot reach it under these bounds.

Reuse: original replay operands and the source trial-division algorithm, standard
Rust strings and atomics, and the locked dependency graph. No bigint dependency,
manifest, lockfile, schema, saved format or generated bridge output is added.
Generic normalization remains separate and unchanged.

## Executed offline evidence

Setup used pinned Flutter 3.47.9/Dart 3.13.7, matching `fdroid/flutter.version`,
and the existing Pub cache. `/usr/bin/python3` successfully imported pytest,
Jinja2 and MarkupSafe (`soft_str` callable). Rust used the existing 1.95.0 toolchain
and `CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`. Temporary evidence used private
`TMPDIR`. No tools, targets or packages were installed or upgraded.

| Check | Result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test number_wall_prime --locked --offline` | Pass: four public-seam tests. |
| `autowork-run timeout --kill-after=10s 900 scripts/ci/rust-check.sh` | Pass: fmt, clippy with denied warnings, 26 workspace tests and doc-test targets. |
| `flutter pub get --offline --enforce-lockfile` | Pass: checkout-local metadata prepared, lockfile unchanged. |
| `flutter test --no-pub test/modules/number_wall_model_test.dart test/migration/state_replay_test.dart` | Pass: 10 unchanged Dart model/replay tests. |
| `dart "$TMPDIR/number_wall_prime_oracle.dart"` | Pass: 75 scratch checks against the unchanged Dart validator, including status, canonical text, counts and yield cancellation. The scratch script is not a new repository test or fixture. |
| `git diff --exit-code -- migration/baseline lib rust/Cargo.lock rust/Cargo.toml pubspec.lock && git diff --check` | Pass: original inputs, Dart owners and locks unchanged. |

The [public tests](../../rust/crates/fractal-core/tests/number_wall_prime.rs)
compare uninterrupted advance loops with inspected chunks. Direct equality checks
bind statuses, certified text and counts, so an altered expectation fails.
They read the original replay operands at events 47–49, 51–58, 61 and 64.
These are isolated validator outcomes, not the replay's retained committed prime
or first cell. Coverage includes malformed/non-ASCII ingress, leading zeros,
256/257 digits, Carmichael composites, `2^53 + 1`, the 127-bit unverified operand,
zero/limited/default budgets, square-boundary neighbors and cancellation before
screening, between chunks and after the last root-bounded chunk.
A 256-digit operand also reaches odd division without full-value integer parsing.
Each inspected advance counts at most 1024 odd trials. Terminal results stay stable.

## Remaining proof and documentation maintenance

No `number_wall` Session support, exact grid/NumberWallFrame port, prime-cache
authority, randomizer or bridge/app routing is enabled. Exact asynchronous ingress,
pending/error/last-good state, superseding requests, navigation/edit cancellation,
editor/preset/history/deep-link integration and the full **68-event** Rust replay
remain unported. Running the original Dart replay does not close those Rust gaps.
No native execution, browser/device qualification, performance gain or broader
mathematical claim follows from this result. The runner's merged-tree full gate
is separate and was not run by this worker.

Scoped Docs Sync Maintain updates only this designated API/check/gap note.
The specification and planning owners were inspected, not changed. Source/test
readback verifies API names, status/count precedence and the remaining scope.
Scoped local-link/anchor and whitespace checks pass. Bundled `docs.py stale .`
and `docs.py check .` exit 0 with no `docs/roles.json` manifest, so they supply no
repository-wide link coverage. The coordinator owns task/changelog integration
and closeout documentation maintenance.
