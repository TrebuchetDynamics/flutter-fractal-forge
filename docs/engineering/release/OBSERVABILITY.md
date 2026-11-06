# Observing a published Play release

Status: current. Companion to [PIPELINE.md](PIPELINE.md). A green pipeline is a
prerequisite for publication, not proof of review, propagation or availability.

## What you can observe

| Signal | Source | Observed | Not observed |
| --- | --- | --- | --- |
| Rollout state | Play Developer API `edits.tracks.get` | release name, status, version codes, user fraction | Google review state |
| Declared availability | `edits.countryavailability.get` | targeted countries and `restOfWorld` | whether a storefront currently lists it |
| Storefront listing | Public Play page per country | HTTP status, availability, `Updated on`, version when exposed | installation on a specific device or account |
| Review state (direct) | Play Console publishing page | review phrase: changes in review, in review, ready to publish, rejected, approved, published | a supported API contract |
| Review state (inferred) | Storefront probes | published, partially propagated, not yet visible | Google approval |

Google publishes no app-review API. Google's own developer support confirms that
the review status must be read in Play Console.

## Observe once

```bash
scripts/ci/play-observe.sh \
  --expected-version 1.1.121 \
  --expected-date "Nov 6, 2026" \
  --output release-artifacts/play-1.1.121/play-observe.json
```

| Option | Meaning |
| --- | --- |
| `--countries US,GB,...` | countries to probe (default: up to 12 targeted countries, US first) |
| `--expected-version X.Y.Z` | default: `versionName` in `fdroid/version.properties` |
| `--expected-date "Nov 6, 2026"` | storefront `Updated on` value that counts as propagated |
| `--console-html FILE` | parse a saved Play Console publishing page |
| `--console-url URL` + `--console-cookies FILE` | fetch the Console page with an authorized session |
| `--output FILE` | write the JSON document |

The JSON has four parts:

- `official`: `track`, `country_availability`, `details` from the Developer API.
- `storefront`: one row per country and a `summary` of `propagated`, `pending`,
  `unavailable`, `errors`.
- `review.inferred_from_storefront`: `published-to-probed-storefronts`,
  `partially-propagated`, `not-yet-visible` or `unknown`, with caveats.
- `review.console`: the parsed Console state, or `null` when no page was given.

Exit code 0 means the observation was produced. It does not mean the release is
good; use the checker for policy.

## Check it (reusable gate)

```bash
scripts/ci/play-live-check.sh \
  --input release-artifacts/play-1.1.121/play-observe.json \
  --expected-version 1.1.121 \
  --require-review approved
```

Without `--input` the checker runs the observer first (network and Play
credentials required). With `--input` it evaluates a saved observation and needs
no network or credentials.

| Check | Passes when |
| --- | --- |
| `track_completed` | production release status is `completed` |
| `version_code` | the track carries `1.1.121` or code `121` |
| `storefront_available` | at least `--min-available` storefronts list the app (default: all probed) and no probe raised a transport error |
| `propagation` | no probed storefront shows an older build, unless `--allow-pending` |
| `review` | only with `--require-review`: the Console state is `approved` or `published` |

| Option | Meaning |
| --- | --- |
| `--allow-pending` | tolerate storefronts that still show the previous build |
| `--min-available N` | tolerate a number of unlisted storefronts (probe errors still fail) |
| `--console-html`, `--console-url`, `--console-cookies` | passed to the observer |
| `--output FILE` | write the check JSON |

Exit codes: `0` pass, `1` a check failed, `2` bad input or prerequisites.

Use it after a release, in a scheduled check, or before announcing:

```bash
# Nightly: re-probe and fail the job when propagation or review regresses.
scripts/ci/play-live-check.sh --expected-version 1.1.121 \
  --expected-date "Nov 6, 2026" --require-review approved
```

## Review: direct and inferred

Direct state needs an authorized Play Console session. Two input modes exist:

1. Save the rendered page in the browser (Play Console uses XHR; the plain HTTP
   response can omit the state), then pass `--console-html`.
2. Pass `--console-url` with a Netscape cookie file from an authorized developer
   session. The file is read-only input and is never printed or committed.
   Missing or expired cookies return HTTP 401/403 and exit 2.

The parser reports the first known phrase and a short context. It is unofficial;
wording and layout can change. Keep the fixtures in
`test/scripts/test_play_console_review.py` current.

The storefront inference is always available and is not the same claim. A live
previous version and a newer change in review can coexist: the storefront then
lists the old build while the Console shows `changes_in_review`. Keep
`review.console` and `review.inferred_from_storefront` separate in reports.

## Availability: three different questions

1. **Declared**: which countries the track targets. From the API. It does not
   prove the storefront lists the build.
2. **Listed**: whether the public store page exists in a country. A probe per
   country. This is propagation evidence.
3. **Installable**: whether a specific account and device can install. Not
   observable here. Device compatibility and account state are outside the
   public page.

A `200` page with the expected date proves the listing reached that storefront.
It does not prove an install.

## Evidence

Store the observation and check JSON next to the release record, for example
`release-artifacts/play-<version>/play-observe.json` and `play-live-check.json`.
Include `observed_at_utc` and the probe country list. A sample of 12 countries is
one page per country, not one user per country.

## Limits

- The storefront page is not an official API. Geo/IP, consent walls, A/B tests,
  bot handling and markup changes can alter it.
- The Console page can omit review state from the HTTP response. Save the
  rendered DOM when that happens.
- Review outcomes can change after publication (policy actions). One observation
  is a snapshot, not a guarantee.
- Staged rollout and country targeting can hide a version in some storefronts.
- Per-device and per-account availability require that device or account.

## Maintenance

- Parser fixtures: `test/scripts/test_play_storefront.py`,
  `test/scripts/test_play_console_review.py`, and
  `test/scripts/test_play_live_check.py`.
- Run `pytest test/scripts -q` after changing a parser or the checker.
- If Play changes the page markup, update the fixture first, then the pattern.
