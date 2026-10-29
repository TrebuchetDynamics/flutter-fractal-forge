# PRD - Flutter Fractals (Android, Free)

## 1) Product statement

Fractal Forge is a Flutter application for exploring mathematical systems, tuning views, and exporting images. The owner selected the current README/backlog as the active scope baseline on 2026-10-11. The accepted release contract below adds the shared Android/web/Linux journey. Older conflicting requirements remain historical or deferred until explicitly reaccepted.

## Active release contract

Status: Accepted

Owner decision: Juan Tamez accepted this contract in the 2026-10-11 repository interview. The current `README.md` and `TODO.md` govern active scope. Conflicting older PRD requirements remain historical or deferred until explicitly accepted again. This section records the newly accepted release outcome. It does not claim that qualification is complete.

### Outcome and users

People exploring Fractal Forge must be able to find a compelling system, customize its view, understand its mathematics or stated limits, and export an image. Visual appeal, trustworthy descriptions, and reliable precise controls are all required. None replaces the others.

### Acceptance example

On Android, web, and Linux desktop, a user can:

1. Browse and search the catalog, then open representative 2D and 3D systems.
2. Change parameters and navigate predictably.
3. Inspect accurate current-formula text or an explicit unverified/inspired qualification.
4. Export a nonblank PNG matching the edited view and selected export settings.

The journey must complete without a crash or silent placeholder substitution. Existing IDs, favorites, and saved presets must remain intact. An approximate catalog preview is not proof of an exported mathematical render.

### Scope and exclusions

- Owner update: skip GitLab for the current full release, until explicitly resumed. GitLab login, mirroring, CI execution and GitLab release publication are deferred, not completed. Preserve all existing build, device, cross-platform journey and evidence gates; a non-GitLab execution path must satisfy them before publication. This update does not itself authorize publication or scheduling.
- Owner release policy: all releases target production by default. Play defaults to the production track with completed status; GitHub releases default to published rather than draft. Nonproduction/draft output requires an explicit override. An explicit release request supplies publication authority under the [standing release defaults](#standing-release-defaults), but never waives qualification.
- Android, web, and Linux must each meet the complete journey bar. Platform-specific save mechanisms can differ.
- Unverified and inspired entries can remain available with clear qualifications. Do not imply that they are certified formulas or exact geometric constructions.
- This contract does not require certification of every shader, macOS/Windows qualification, new historical MVP features, or a product rename.
- Existing accepted backlog work, privacy policy, compatibility guarantees, and active ownership remain in force. The interview does not authorize implementation, publication, or deployment of the new qualification tasks.

### Standing release defaults

Owner decision (2026-10-29): “Yes always. Those are the defaults. Document this.” The owner confirmed production publication of the qualified subset without another approval when other requested platforms remain blocked.

- An explicit request to release authorizes preparation and production publication through the existing configured destinations. After verification, publish every qualified requested platform without a second confirmation. Do not ask again solely because the result is a partial release.
- Production is the default: Play production/completed, published non-prerelease GitHub releases, and the existing production website. Use draft or nonproduction output only when explicitly requested.
- Attempt requested platforms independently. A lane-local failure or unavailable prerequisite blocks that lane, not other qualified lanes. Report each platform's actual build, qualification and publication result, with exact failure or unavailability reasons.
- Keep preparation and publication as separate verified invocations. Reuse the frozen source/version/artifacts and preserve all source-integrity, signing, device/browser, privacy, compatibility, evidence, hardware/human-review and remote-readback requirements. Missing proof never becomes a pass. Reconcile ambiguous remote writes before retrying.
- GitLab remains excluded until explicitly resumed. No new destination, paid runner, credential change or destructive action outside existing consent is implied.
- Ordinary coding, planning, documentation and prepare-only requests do not authorize publication. Existing task-specific exclusions and user pauses remain in force.

This decision supersedes the separate post-preparation owner-approval requirement in older release plans for an explicit release request. It does not retroactively qualify an old candidate, alter historical evidence or change any technical gate.

### Legacy requirement classification

| Requirement or historical claim | Current classification |
|---|---|
| Browse, customize, mathematical descriptions and PNG export | Active release outcome. Verify through `REL-JOURNEY-01-WEB`, `REL-JOURNEY-02-LINUX`, and `REL-JOURNEY-03-ANDROID` in `TODO.md`. |
| Stable IDs, favorites and saved presets | Active compatibility constraint in those same tasks. |
| Parameter locking, a premultiplied-alpha UI toggle, and at least five built-in presets for each required fractal | Historical requirements unless independently present in the current backlog. This decision adds no new implementation obligation. Existing controls and presets remain supported. |
| Startup shader compilation below 200 ms and ten-minute animation memory stability | Historical numerical gates. Reliable controls and crash-free completion remain active, but this interview accepts no new latency or endurance threshold. |
| Remote usage analytics/Firebase Crashlytics | Historical proposal, not approved. The current README privacy promise remains active. |
| Camera overlays, short-video/MP4 export and deferred AR work | Historical or deferred. Not added to this release journey. Existing implemented tools are not removed. |
| Physical Android PNG destination/gallery verification | Active verification for the Android journey. Existing MediaStore behavior must be observed rather than inferred from widget tests. |
| Wallpaper verification and expanded viewer-history integration | Preserve their existing backlog classification. They are not newly required by this image-export journey. |
| Human Spanish review | Historical qualification remains unclaimed. Existing EN/ES support is preserved. This interview does not add a human-review release gate. |
| Every catalog fractal individually certified before release | Superseded for this release by the owner's explicit permission to retain clearly qualified unverified/inspired entries. New-formula quality gates in the current backlog remain unchanged. |

### Independent platform release policy

Status: Accepted

Owner request (2026-10-17): plan a release for all platforms; skip a specific platform if it errors. This is planning authority only, not permission to implement, publish, deploy, change schedules or spend money. Production remains the default destination. The earlier explicit GitLab deferral remains in force; later operating notes claiming resumption conflict with this PRD and do not supply new owner authority.

For this campaign, attempt Android/Play, web, Linux, Windows, macOS and iOS, with F-Droid as an independently assessed Android distribution lane. This prospectively expands the attempted platform set without claiming existing Windows/Apple qualification. Preserve existing platform journey, saved-state, accessibility, security, signing and artifact-evidence requirements. A platform-local build, test, runner, signing, credential or publication failure skips that lane with an exact reason; it does not suppress successful independent lanes or become a passed check. Android device checks gate Android distribution, not unrelated desktop/web publication; F-Droid reproducibility and source scans gate F-Droid, not unrelated publishers. Shared source-identity, integrity, secret/privacy or compatibility failures stop every affected lane, not merely the first one to reveal them.

Planner's call: freeze one reviewed source commit, SDK/lockfile, version/build identity and candidate inventory. Reuse the existing builders, qualification targets, provenance/checksum/SBOM tools and publisher adapters; add the smallest explicit best-effort orchestration policy rather than a second release framework. A verified non-GitLab execution route is required while GitLab is deferred; current flags do not provide one. Use available authorized native hosts, skip unsupported/unavailable hosts without pretending to cross-compile Apple/Windows on Linux, and do not purchase runners or bypass authentication.

Every requested lane needs an explicit terminal record: verified/published, skipped-failed, skipped-unavailable, or publication-unknown. Keep separate build, qualification, artifact and publication verdicts. An ambiguous remote write must be read back before retry; it is never a safe-to-repeat failure. Report partial delivery honestly, list every omitted platform, and never label an unsigned Apple archive or an F-Droid metadata submission as a production store release. If no lane qualifies, publish nothing and report failure. For an explicit release request, the standing release defaults authorize publication of the verified subset without another approval. A planning or prepare-only request still does not authorize publication.

### Release continuation plan — 2026-10-23

Status: Historical planning continuation of the accepted independent-platform policy. The plan alone grants no execution or publication authority. For a later explicit release request, the standing release defaults supersede its separate approval checkpoint without changing qualification requirements.

**User outcome:** plan a production release across Android/Play, F-Droid, web, Linux, Windows, macOS and iOS. Keep the accepted best-effort policy: a lane-local failure does not block qualified independent lanes. GitLab remains excluded. In this planning conversation the owner explicitly retained `tasks/` as the authoritative queue; do not recreate `TODO.md` or `goals.json` from the older queue preamble. Preserve task IDs, ordering, active owners, history and every qualification gate.

**Current evidence, not a fresh release verdict:** inspection started on main `8d841916`. The runner is already working on `RELEASE-002-75`; do not launch a competing prepare/build session or change its admitted contract. Its retained task text still contains historical `1.1.108`/108 commands, whereas committed `fdroid/version.properties` is `1.1.110`/110. Those examples are not permission to downgrade or reuse consumed version codes. The current runner's main-check record reports three failures: `auto_explore_service_test.dart` (module-switch replanning) and two `viewer_music_coordinator_test.dart` loop-refresh cases. No repair or test rerun was performed by planning. The runner owns recovery; a later green result must bind the exact final candidate, not merely a prior tree.

A retained production receipt, inspected during planning, records web **1.1.110**, app source `e0079934bcad2b2a14af2599d07dbe484ee9cfe3`, at <https://fractal.trebuchetdynamics.com/view>. It records one of seven destinations published, three production browser passes and 629 served files matching their archive hashes. This is historical evidence, not a live readback in this planning pass or qualification of current main. Preserve its failed automated confirmation separately: non-browser HTTP 403, provider-consumed `_headers`, and bootstrap cache TTL observed at 14400 seconds rather than configured 300 seconds. Do not redeploy the already-published artifact merely to replace a failed receipt. Private evidence owner: the existing release directory's `observed-release-result.json` and original campaign/logs; retain its deployment identity and rollback anchor without copying credentials into docs.

**Planner's choice:** continue the existing local/native, prepare-then-publish route and reuse the existing tasks below. Reject the strict legacy GitLab route because it violates the current exclusion, and reject new CI/store infrastructure as unnecessary scope. No new catalog work, storage changes, dependency installation, paid runners, signing setup, credential changes, schedules or queue-priority changes are part of this plan. Feature candidates, including unfinished menu polish, enter a release only after separate verification and integration; do not inject private work into a frozen candidate.

#### Preparation and version selection

1. Under the existing `RELEASE-002-75` owner, reconcile the failed shared check and any current worker result against fresh main. Do not overwrite retained attempts or fabricate a passing campaign. Freeze one reviewed source commit, exact Flutter 3.44.6/Dart toolchain, `pubspec.lock`, source inventory, version/build, artifacts and provenance. A source-integrity, secret/privacy, saved-state compatibility or shared-check failure stops every affected lane.
2. Before reserving a new identity in a later authorized execution, inspect live consumed Play version codes and existing production/tag/deployment identities. Select an unused monotonic version/build; do not assume 108, reuse 110 for a different source, or assume 111 is available. An unavailable live version inventory blocks the affected Android publication, not an independently qualified desktop/web lane. Update the release identity and matching base-build F-Droid changelog together before freezing; that metadata is required by the common tests even if F-Droid itself is skipped.
3. The existing common check remains the prerequisite, planned/unrun here:

   ```sh
   flutter pub get --offline --enforce-lockfile &&
   flutter analyze --no-pub &&
   flutter test --no-pub &&
   python3 -m pytest test/research test/scripts -q &&
   bats test/scripts/*.bats
   ```

4. On that candidate, the supported prepare command is `./release.sh --best-effort --prepare=<selected-version> --build-number=<selected-build>` with isolated artifact/campaign output. Angle-bracket values are explicit placeholders, not executable defaults. Exercise `python3 test/scripts/test_release_platform_lanes.py` before trusting lane selection. Reuse the production saved-data verifier `test/playwright/production-saved-session.spec.mjs`; the diagnostic `smoke-session-conflict.spec.mjs` requires its own matching diagnostic build and is not ordinary-production evidence. Keep per-check browser reports/downloads separate. No commands in this subsection were run by this planning pass.

#### Every requested destination and its existing work owner

| Destination | Proof and access needed before admission | Existing task IDs and remaining condition |
| --- | --- | --- |
| Android / Google Play | Named Android device, real edited 2D/3D PNG MediaStore/gallery readback, accessibility/saved-state checks, signing/certificate validation, unused live version code; production/completed readback under the standing release defaults | `RELEASE-002-75`, `REL-JOURNEY-03-ANDROID-LIVE`, `RELEASE-003-ae`; prior campaign lacked signing/device qualification. Recheck access during execution; never paste credentials into chat. |
| F-Droid | Relevant Android qualification, twice-built reproducible unsigned APKs, official lint/source scans, version metadata and legal notices; external maintainer acceptance | `RELEASE-002-75`, `RELEASE-001-23-LIVE`, `RELEASE-003-ae`; prior official CLI unavailable. Metadata/submission alone is not publication. |
| Web / Cloudflare production | Frozen production bundle; actual edited PNG browser journey and production saved sessions/favorites/presets; complete served-asset/full-source identity and response-policy checks | `RELEASE-002-75`, `RELEASE-003-ae`; `REL-JOURNEY-01-WEB` remains historical completed work. Preserve existing 1.1.110 publication and resolve confirmation/cache-policy gaps before a fresh web admission; no WAF/cache/security weakening to pass a check. |
| Linux / GitHub release | Native launch and full journey file; retained edited-view PNGs with provenance, view/export comparison, EN/ES and inspired-entry coverage; attributable composition/readability review; archive, checksum/SBOM/notices and downloaded-byte validation | `RELEASE-002-75`, `REL-JOURNEY-02-LINUX-LIVE`, `RELEASE-003-ae`; historical 12 passes/one explicit skip do not supply the missing human/coverage verdicts. Reuse actual retained images where their source and state match. |
| Windows / GitHub release | Supported native Windows executor, native journey/export, package and downloaded-byte validation | `RELEASE-002-75`, `RELEASE-001-23-LIVE`, `RELEASE-003-ae`; prior native executor unavailable. Wine is not native Windows qualification. |
| macOS / configured production distribution | Supported macOS host, real native journey/export, distribution signing/notarization and exact artifact readback through an existing approved route | `RELEASE-002-75`, `RELEASE-001-23-LIVE`, `RELEASE-003-ae`; prior host unavailable. An unsigned archive is not a production release; absent an approved publisher, record unavailable rather than build new infrastructure. |
| iOS / production App Store submission | macOS/Xcode executor, named iOS target journey/export, signing/provisioning, store prerequisites and observable submission/release state | `RELEASE-002-75`, `RELEASE-001-23-LIVE`, `RELEASE-003-ae`; prior host unavailable. Submission and actual store availability are distinct outcomes. |

The platform-independent proof owner is `RELEASE-001-23-LIVE`; preserve its external gates. The completed offline parent tasks are not evidence that these live follow-ups passed. Existing target availability is historical until checked on authorized hosts; this plan does not acquire hosts or signing access. Shared file/host contention constrains scheduling, not product dependencies. Run independent lanes with separate output when their actual resources permit it; unavailable Windows/Apple/Android prerequisites must not stop otherwise qualified web/Linux work.

#### Publication, readback and recovery

`RELEASE-002-75` produces the existing campaign plus immutable artifact/evidence manifests, checksums/SBOM/notices for the admitted subset and an explicit terminal row for all seven destinations. Preparation itself publishes nothing. The publication step consumes those exact source/version/artifact-bound records. An explicit release request supplies standing authority to publish the qualified subset without a second approval. This policy does not edit task status or ownership. Keep the existing preparation dependency rather than adding cross-platform dependency chains.

Every requested destination ends as verified/published, skipped-failed, skipped-unavailable or publication-unknown, with build, qualification and publication reported separately. Missing receipts and all-skipped runs are not success. For an explicit release request, proceed with the existing best-effort publisher once the selected identity/campaign passes its gates; do not add another approval checkpoint. Never use the no-argument legacy launcher. Bind any new release tag to the qualified commit explicitly and reject an existing mismatching tag rather than force-moving it. Read back each release asset, store state and deployment at its exact target; a timeout or failed confirmation triggers read-only reconciliation before any retry, not a duplicate upload/deployment.

Keep the previously verified web deployment as the recovery anchor until a new release qualifies. Recovery after a later incident follows the existing platform-supported procedure and separate operational authority: web/desktop restoration only through supported verified artifacts; mobile rollout halt and a higher-version tested replacement, not a promised installed-app downgrade. Do not run rollback or monitoring setup during planning.

**Pre-mortem guards:** (1) stale version/source or truncated archive: require live version inventory, immutable hashes, archive decode/inventory and exact tag/source checks; (2) false platform parity: require all seven terminal rows and keep native/human checks unknown until observed; (3) duplicate publication after ambiguous confirmation: preserve original failures and reconcile exact remote state before retry. The existing lane regression suite and acceptance gates own these checks; no guard was waived or reported freshly passed here.

**Handoff:** use `RELEASE-002-75` for the existing active prepare-only continuation, `REL-JOURNEY-02-LINUX-LIVE` and `REL-JOURNEY-03-ANDROID-LIVE` for their retained target/review gaps, `RELEASE-001-23-LIVE` for the other live platform requirements, and `RELEASE-003-ae` for publication governed by the standing release defaults. No duplicate task, worker, execution lease or schedule is created. The builder must not guess a version, artifact identity, human verdict, new destination or publication authority; unavailable inputs stay scoped to their affected lane. Current source checks and signing/host/reviewer availability remain execution work, not claimed results of planning.

### Execution frontier

- Web first within this plan: the backend matrix records browser export as unqualified. Prove the complete journey rather than another build-only smoke.
- Linux next: reuse native integration and export checks, then verify actual saved artifacts and current-formula behavior.
- Android next: verify the same journey and actual device storage/gallery output. An emulator-only result must not be presented as physical-device qualification.
- These platform slices are independent and have no fabricated cross-platform dependencies. Existing global queue priorities and active workers are unchanged.
- Completion requires recorded per-platform results. A source check, passing widget test, or successful build alone does not close this release goal.

### Evidence and remaining gaps

`docs/engineering/test-plan.md#accepted-cross-platform-release-journey` owns the acceptance checks. `docs/engineering/rendering/renderer_backend_matrix.md` records dated backend evidence, not current full parity. The new journey is unverified on all three targets as a complete release contract.

Graph evidence: a fresh local code-only Graphify scan of `lib/features/export/` queried `ExportOptionsSheet`, `ExportOptions`, `ExportResolutionSummary`, and `ExportSheetSubmission`. It found the option/submission/summary relationships at `export_options_sheet.dart:13,28,46` and `export_resolution_summary.dart:8,19`. Coverage is partial: services, journey tests, and document semantics are outside that graph. The extractor reported duplicate labels and two self-loops. Source checks, not graph inference, establish the qualification gaps.

Skill application: `interview-me` resolved the scope, combined outcome, platform set and review threshold one question at a time. `spec-driven-development` turns the owner-approved PNG example and failure boundaries into an observable acceptance contract without adding a competing spec. `documentation-and-adrs` records these product decisions here without a new architectural ADR. `planning-and-task-breakdown` creates bounded platform outcome tasks with artifact checks. `frontend-ui-engineering` preserves responsive interaction, honest captions and saved-state compatibility. `repo-docs` reconciles the canonical ledger and runs its consumer gate. The optional `hard-blockers` skill was unavailable, so blocker reconciliation uses the installed repo-docs contract and existing entry format.

## Quality-first planning priority

Owner decision from the current repository interview: prioritize existing quality, with viewer fixes first and a diverse polished catalog pilot next. `VIEW-UI-001` is now the primary milestone; follow with `CAT-QUALITY-01` and `CAT-QUALITY-02`. Preserve Gaussian implementation/review evidence and existing tasks; do not cancel workers or reopen completed work. OpenAI-math candidates remain Proposed/Needs decision. This answer changes planning priority only, not implementation, publication or timed-scheduling authority. Pilot success, explicitly selected by the owner: each selected entry opens at an attractive default, offers useful exploration controls, and exports a matching PNG without requiring the user to hunt for good settings. Mathematical honesty, accessibility, supported-platform qualification and saved-state compatibility remain mandatory. Attractive framing requires artifact-based visual assessment; colorful/nonblank pixel metrics alone are insufficient.

## Catalog quality and variety

Status: Accepted

Owner outcome: improve catalog quality without losing variety, requested through `/autoresearch plan`. Preserve the supported catalog, stable identities and saved state. The accepted release journey already requires visual appeal, truthful mathematical descriptions, reliable controls and accurate PNG export.

The [quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety) separates recorded coverage from actual quality. Assess a bounded diverse pilot, then repair demonstrated first-impression defects. Curated discovery, the precise promotion rubric and intake policy remain Proposed. This is planning authorization only; it does not approve a new UI, numeric release threshold, implementation, scheduling or focus change.

Existing `VIS-006` qualification and `MEDIA-002` marketing-selection tasks are reused. `CAT-QUALITY-01` and `CAT-QUALITY-02` cover the new bounded assessment/repair outcomes; `CAT-QUALITY-03` records the proposed discovery decision. The existing Gaussian priority and active workers remain intact.

## Gaussian moat walking visualization

Status: Accepted

Source: Owner request in this conversation: `/autoresearch_plan /repo_docs we need to add gaussian moat walking on primes visualization to our app`.

Accepted outcome: extend the app with a Gaussian-prime map that lets a user explore bounded-step walking and reachable clusters. This is planned work, not an implemented or released feature. Preserve the pending Play release obligation separately; this request does not add an unimplemented feature to a release candidate.

- Reuse the existing `gaussian_prime_lattice` catalog identity, favorites and normal viewer navigation. Do not create a second Gaussian lattice or promote the historical spiral candidate as a separate system.
- Show exact Gaussian primes within an explicitly bounded integer domain. Let a user select a prime, set a maximum Euclidean step, follow a path without revisiting points, undo/reset it, and inspect the starting prime's full reachable component.
- Label the computation domain separately from the visible viewport. A trapped chosen path, an exhausted finite search and a search cut off at the domain limit are different outcomes. No finite image or search proves the infinite Gaussian moat theorem.
- Preserve Android, web and Linux support, local/offline processing, EN/ES descriptions, keyboard/screen-reader alternatives, existing view controls, and PNG export of the displayed primes and overlays.
- Explain Gaussian primes, fixed step lengths and the moat question. Attribute the linked OpenAI manuscript and reported formal verification without claiming an independently rebuilt Lean proof or established peer review.

Acceptance: exact positive/negative primality fixtures pass; every accepted path step meets the inclusive distance bound and avoids repeats; reachable-component results match independent small-domain fixtures; boundary status is honest; navigation, accessibility and PNG artifact checks pass separately on the supported targets.

Refined experience: separate candidate selection from the Step action; preserve pan/zoom gestures; use the existing mobile HUD/sheets and a responsive wide-screen control panel. Show computation-boundary and component states continuously. Apply finite work caps, cancellable chunks and serialized radius playback. Export one completed, paused graph snapshot. The [UI and performance contract](docs/engineering/spec.md#ui-layout-and-interaction-contract) is planned engineering detail, not measured device qualification.

Implementation defaults, bounded architecture, planned checks and research sources are in [the feature specification](docs/engineering/spec.md#gaussian-moat-walking-visualization). Ordered tasks are `GAUSS-MOAT-01-MAP`, `GAUSS-MOAT-02-WALK`, `GAUSS-MOAT-04-GROWTH`, and `GAUSS-MOAT-03-QUALIFY` in `TODO.md`. Existing focus, queue priorities, active workers and release gates remain unchanged.

## Prime-norm quaternion companion

Status: Accepted

Source: the owner's follow-up `/autoresearch_plan` requests a 2D-to-higher-dimensional prime-walking exploration. Deliver bounded Gaussian radius growth first, followed by a companion prime-norm Lipschitz-integer slice.

Show integer quaternions `a+bi+cj+dk` with ordinary-prime norm in a fixed-d, rotatable 3D slice. Make the chosen predicate and slice value visible. Users can select a point, make bounded nonrepeating steps, inspect a component, and export the visible graph. This is not a claim to classify all quaternion primes or demonstrate a Gaussian-style moat theorem in 4D. Half-integer Hurwitz points and full 4D walking are deferred.

Refined companion: display a fixed-d orthographic slice with manual rotation, deterministic depth-aware candidate selection and a coordinate-list alternative. Keep graph distances independent of the camera. Reuse the same selection/Step/status/export behavior and bounded scheduling, with the smaller quaternion limits. The [quaternion layout contract](docs/engineering/spec.md#quaternion-layout-and-picking-details) preserves slice-only disclosure.

Reuse app navigation, styling, localization and capture. Preserve existing quaternion Julia/Mandelbrot identities; an iteration fractal is not this prime cloud. The [companion specification](docs/engineering/spec.md#prime-norm-quaternion-companion) owns finite bounds, transforms, dependencies and planned proof. Tasks `QUAT-NORM-01-SLICE`, `QUAT-NORM-02-WALK`, and `QUAT-NORM-03-QUALIFY` remain planned/unimplemented and do not change release gates or existing focus.

## 2) Goals / Non-goals (historical MVP)
### Goals
- Large catalog of fractal "modes" with consistent UI patterns.
- Smooth navigation (pan/zoom/rotate) + responsive parameter changes.
- Presets + "randomize" to get good-looking results quickly.
- Auto-animate parameters (looping, easing, tempo).
- Export/share images and short videos.
- EN + ES localization at launch.
- High-performance rendering using GLSL fragment shaders (Skia/Impeller via `flutter_shaders` or `ImageShader`).
- Parameter locking to allow granular randomization (e.g., randomize geometry but keep colors).
- Share flow that creates a standardized filename (e.g., `FractalName_Date.png`).

### Non-goals (for MVP)
- iOS release.
- Accounts/cloud sync.
- Community marketplace.

## 3) Target users & use cases
- Casual users: "Show me cool fractals" -> presets + autoplay.
- Hobbyists: tweak parameters precisely, save favorites, export high-res.

## 4) Key user flows
1. Open app -> Explore fractal catalog.
2. Select a fractal -> Viewer.
3. Explore: gestures + sliders + palette + auto-animate.
4. Save preset.
5. Export/share image.

## 5) MVP scope (must ship)

### 5.1 Fractal catalog
Minimum required fractals:
- Mandelbrot (2D)
- Julia (2D)
- Newton fractal (2D)
- Burning Ship (2D)
- Mandelbulb (3D)

Additionally in MVP:
- Include other fractals already present in `flutter_fractals/`, but standardize them behind a common module interface (see section 9).

### 5.2 Viewer
- 2D: pan + pinch-zoom.
- 3D (Mandelbulb): rotate/orbit (implementation-dependent) + zoom.
- Controls (bottom sheet):
  - Per-fractal parameter sliders (schema-driven)
  - Quality control (iterations / steps / samples)
  - Palette selector
  - Reset view
  - Randomize
  - Parameter locking (lock icons next to Geometry vs Styling/Palette groups)
  - Undo/Redo (history stack for last 10 parameter changes)
  - Snapshot button (quick save to gallery without full export menu)
- Progressive rendering:
  - Dynamic resolution scaling: render at 0.5x pixel ratio during gestures, snap to 1.0x or 2.0x (high quality) when static
- Auto-animate:
  - Play/pause
  - Speed
  - Select animated parameters
  - Loop: wrap + ping-pong
  - Easing: linear + smooth (at least)

### 5.3 Presets
- Built-in presets: >= 5 per required fractal.
- User presets stored locally (name + params + camera + palette + thumbnail).

### 5.4 Export (images)
- PNG export at selectable resolution (e.g., 1080p/1440p; 4K optional).
- Transparent export:
  - Background = Opaque / Transparent.
  - Transparent PNG preserves alpha.
  - Shaders must support an alpha output channel (not just `vec3` color).
  - UI toggle: "Premultiplied Alpha" (on/off).
- Share sheet integration with standardized filename (e.g., `FractalName_Date.png`).


### 6.1 Definition

### 6.2 Features
- Camera preview background.
- Fractal overlay above camera.
- Overlay transform gestures:
  - Drag to move
  - Pinch to scale
  - Two-finger rotate (2D rotation)
- Overlay controls:
  - Opacity slider
  - Lock overlay toggle
  - Background mode: opaque/transparent (for overlay-only exports)
- (Optional) Checkerboard preview when transparent enabled.

### 6.3 Permissions
- Camera permission with clear rationale.

## 7) Short video export (MVP)

- Method: capture the composite Flutter view (camera texture + shader layer) via a view recorder / surface frame grabber.
- Constraint: resolution matches the device screen aspect ratio.
- Duration: max 15s. Presets: 5s / 10s / 15s.
- Resolution: 720p default; 1080p optional if the device can sustain it.
- Audio: muted (MVP).

### 7.2 Nice-to-have: overlay-only alpha video
- Only if straightforward; otherwise defer.

- Method: deferred. If revisited, use a platform-native video encoder rather than bundling FFmpeg.
- Benefit: perfect 60fps loops even if the device lags during live preview.
- Format: MP4 (H.264), seamless loop.

## 8) Localization (EN/ES)
- All UI strings via Flutter localization (ARB) for `en` and `es`.
- Module `id` is stable and language-independent.

## 9) Architecture requirements (refined for shaders)
Rendering must use GLSL fragment shaders (Skia/Impeller) via `FragmentProgram` / `GlslFragmentProgram`. Avoid `CustomPainter`/Canvas paths for fractal rendering.

Suggested `FractalModule` interface:
- `String id`, `String name`
- `FractalDimension dimension` (2D/3D)
- `String fragmentShaderPath`
- `List<UniformParam> params` (Float, Color, Vec2, Vec3)
- `Preset defaultPreset`, `List<Preset> builtInPresets`
- `Preset thumbnailPreset` (consistent catalog thumbs)
- `Widget controlBuilder(...)` (optional: custom widget for complex inputs like Mandelbulb rotation)

`UniformParam`:
- `name`, `uniformLocation`
- `min`, `max`, `default`
- `isInteger` (for iterations)

## 10) Quality bar / acceptance criteria
- Shader compilation time < 200ms on startup.
- No crashes during rapid slider scrubbing + zooming.
- Auto-animate runs 10+ minutes without memory growth.
- Exported images match framing and palette.
- Transparent exports composite cleanly (no black halos; correct premultiplied-alpha handling).
- Visuals: no banding artifacts in gradients (dither in shader or use 32-bit color where supported).
- UX: Android Back gesture closes the Palette/Settings sheet before exiting the Viewer.
  - Camera starts reliably on common devices.
  - Overlay transforms feel responsive.

## 11) Risks / constraints
- GPU-heavy fractals + camera can overheat devices -> implement quality presets + throttling.
- Android device camera quirks -> need robust start/stop + fallback.
- Native MP4 export is deferred; if revisited, platform encoder integration will require device-specific tuning.

## 12) Analytics & Privacy
- Privacy: no collection of camera data or personal images. All processing is on-device.
- Analytics: track "Most Used Fractal" and crash reports (Firebase Crashlytics) to prioritize optimization.

Current implementation differs: `CrashReporter` stores local diagnostics, and `pubspec.yaml` declares no remote analytics or crash-reporting SDK. The owner resolved `BLK-20261005-004` in favor of the current README/backlog. The remote-analytics proposal is historical and remains unapproved.

## 13) Implementation priority (MVP roadmap)
1. Core engine: set up `GlslFragmentProgram` boilerplates and the `FractalModule` architecture.
2. Fractals: port Mandelbrot and Julia first to test the engine.
3. UI: build the dynamic slider system based on the schema.
4. Export: implement image export (easy).
6. Video: evaluate platform-native MP4 encoding after the GIF workflow proves insufficient.

## 14) Fractal Catalog Roadmap (100+ Fractals)

Long-term goal: Comprehensive fractal encyclopedia. Each fractal validated individually before release.

### Historical implementation checklist (not current catalog coverage)
- ✅ Mandelbrot (2D)
- ✅ Julia (2D)
- ✅ Burning Ship (2D)
- ✅ Phoenix (2D)
- ✅ Mandelbulb (3D)
- ⬜ 100 more planned...

### Category Breakdown

**I. Escape-Time (Complex Plane) - 25 fractals**
Mandelbrot, Julia, Burning Ship, Phoenix, Tricorn, Celtic, Buffalo, Perpendicular, Lambda, Magnet I/II, Nova, Druid, Multibrot, Inverse Mandelbrot, Glynn, Simonbrot, Talis, Manowar, Spider, Shark Fin, Zircon Zity, Collatz, Eisenstein, Popcorn

**II. Newton/Root-Finding - 10 fractals**
Newton (z³-1), Newton (sin), Newton (General), Halley's, Schröder's, Secant, Fatou, Nova Julia, Magnet Newton, Householder

**III. Strange Attractors - 20 fractals**
Lorenz, Rössler, Hénon, Ikeda, Tinkerbell, Clifford, Peter de Jong, Svensson, Gumowski-Mira, Pickover, Thomas', Halvorsen, Rabinovich-Fabrikant, Dadras, Chen, Lü Chen, Aizawa, Duffing, Gingerbreadman, Lozi

**IV. IFS & Geometric - 26 fractals**
Sierpinski (Triangle/Carpet/Pentagon/Tetrahedron), Menger Sponge, Jerusalem Cube, Koch (Snowflake/Anti/Quadratic), Cesàro, Dragon Curves, Levy C, Barnsley Fern, Cyclosorus, Canopy, Pythagorean Tree, Cantor, Vicsek, Hexaflake, Pentaflake, Apollonian Gasket, Ford Circles, Steiner Chain

**V. L-Systems & Space-Filling - 9 fractals**
Hilbert (2D/3D), Peano, Moore, Gosper, Sierpinski Arrowhead, McWorter's, Penrose Tiling, Ammann-Beenker

**VI. 3D Raymarching - 10 fractals**
Mandelbulb, Mandelbox, KIFS, Quaternion Julia, Cubic Mandelbrot, Bulbils, Hartverdrahtet, Kleinian, Menger (DE), Hybrids

**VII. Stochastic & Cellular - 5 fractals**
Buddhabrot, Anti-Buddhabrot, Nebulabrot, DLA, Wolfram Rule 30

### Implementation Priority

🎯 **Immediate** (reuse Mandelbulb raymarcher):
1. Mandelbox - box folding, similar distance estimation
2. KIFS - kaleidoscopic mirrors, stunning visuals

**Phase 1** (2D escape-time, minimal changes):
Tricorn, Multibrot, Celtic, Buffalo, Nova

**Phase 2** (Newton-type, new coloring):
Newton z³-1, Halley's

**Phase 3** (Attractors, particle rendering):
Lorenz, Clifford, de Jong

**Phase 4** (IFS, CPU/compute shader):
Sierpinski, Koch, Barnsley Fern

**Phase 5** (Stochastic):
Buddhabrot, Nebulabrot

### Validation Process
Each new fractal must pass:
1. `flutter analyze` - zero errors
2. `flutter test` - all tests pass
3. Emulator visual validation (screenshot)
4. Real device testing
5. Performance check (60fps target)
6. Export verification (PNG/video)

---

## 15) Status (as of 2026-08-25)

### Implemented
- 1014 production fractal modules plus 1 scientific visualization in the live catalog (1022 debug/test registry modules including 7 diagnostics), including Mandelbrot, Julia, Burning Ship, Phoenix, Mandelbulb, and many more (counts are locked by `test/catalog/catalog_id_integrity_test.dart`)
- Camera Looper GIF export; native MP4 encoding is deferred
- Android image export uses MediaStore (Pictures/FractalForge); physical-device gallery verification remains unverified
- Schema-driven controls per fractal
- No minimap feature is present in the current tree
- Debug overlay for shader troubleshooting
- Live Fourier analysis and finite-grid uncertainty laboratory. Fourier Music was later removed and replaced by silent parameter animation.
- 50+ sub-agent improvements (haptics, stats, video export, accessibility)

### Known Issues
- ~~**CRITICAL: Flutter 3.38+ Impeller shader rendering**~~ — **RESOLVED** (2026-04-05). The black-screen was caused by SkSL-incompatible `%` and `clamp(int, int, int)` operators in shaders; replaced with integer-division modulo and `float(clamp(...))` patterns. All 3D and escape-time shaders compile and render on GPU.

### Remaining / TODO
- See `TODO.md` for current gaps and `docs/planning/PRD.md` for the historical readiness snapshot; this status section is dated 2026-08-25
- Evaluate platform-native Android MP4 encoding only if GIF export proves insufficient
- Physical Android device verification of MediaStore export and gallery visibility

### Open question: active product scope

**Resolved 2026-10-11:** the owner chose the current backlog/README as the active baseline. Conflicting older requirements remain historical or deferred. See [Active release contract](#active-release-contract), resolved `BLK-20261005-004` in `BLOCKERS.md`, and `DOC-PRD-001` in `TODO.md`.

## Number walls catalog category

Status: Accepted

Owner scope: research and plan a Number Walls category inspired by Mathologer’s sequence/divisibility patterns, including multiple sequences, custom prime selection, exploration parameters, optional manual randomization and foreground/background shader-style colouring. The follow-up explicitly expands prime choice beyond a fixed small-prime list. Persist the plan; do not implement, commit, publish or resume cron from this request.

Planner calls: begin with one stable mathematical construction and six sequence choices; genuine exact modular computation with separate shader presentation; custom decimal primes validated exactly with visible resource limits/cancellation; manual rather than continuous randomization. The randomizer wording was dictated and is interpreted as optional manual control, not autoplay. Very large prime validation can remain unverified, never silently rounded or substituted. These implementation defaults are recommendations within the requested outcome, not claims of owner selection or existing capability.

Success: find the category, open attractive honest defaults, change sequence/prime, inspect divisibility windows, colour/randomize/restore settings and export the same completed wall on Android, web and Linux. Preserve existing IDs/favorites/presets and viewer/pilot order. Do not promise all walls are fractals or all input sizes finish instantly. See [the decided plan](docs/engineering/spec.md#number-walls-and-modular-windows) and NUM-WALL-01 through NUM-WALL-05 in TODO.md.

## Academic research library

Status: Accepted

Owner request: improve academic research across all catalog fractals; plan a dedicated research folder gathering articles/references and connecting their mathematics to implementation, using a specialized tool such as the owner's ResearchForge or the likely Feynman open-source research agent. The request is planning/documentation authority, not installation, full-text acquisition approval, paid computation, shader implementation, publication or scheduling.

Planner recommendation: use `research/academic/` as the shared paper/evidence hub, ResearchForge as the primary retrieval/provenance workflow, and Feynman only as optional source-checked synthesis/review assistance. Preserve existing topic packages and the 200-definition library. Map sources and exact equations to effective formulas/builders/shaders/CPU paths and tests; distinguish discovery, accessible text, human-reviewed claims, numerical fidelity and visual quality. Account for every scoped stable identity without pretending that a filled coverage row certifies its mathematics. Reuse existing IDs, source groups and visual-quality evidence.

See [the library plan](research/academic/README.md), [integration contract](docs/engineering/spec.md#academic-source-to-renderer-evidence) and ACAD-01 through ACAD-05 in TODO.md. Initial rollout is a representative pilot followed by bounded family batches, not an unbounded all-papers scrape. Existing viewer/pilot and Number Walls priorities remain intact. ResearchForge's human screening, legal acquisition and accepted-claim gates remain; no owner approval is invented.

## MCP-assisted architecture and UI improvement

Status: Accepted

Owner request: plan the use of Flutter MCPs to improve the whole app architecture and UI. The owner delegated priorities with “Plan for me”. Acceptance here covers this planning outcome; it is not permission to install servers, change another profile, rewrite the app, dispatch workers, publish or schedule work.

Planner call: retain Flutter, Provider/FractalController, existing app/core/features boundaries, visual identity and B/open-spiral artwork. Use the official SDK-bundled Dart/Flutter MCP as a local inspection/verification aid, not an application dependency or a substitute for engineering judgment. Work app-wide through a bounded first batch: usable MCP inspection, single-owner accessible navigation, visible-only auto-explore, localized accessible settings/export controls, then composed verification. Preserve saved views, favorites/catalog browsing, mathematical identity, exports, EN/ES and existing live gates. Existing queue order and primary milestone do not change.

Success means the specific regressions and UI gaps in [the implementation plan](docs/engineering/spec.md#mcp-assisted-app-quality) are corrected and verified. A connected server, clean analyzer, screenshot alone or source inspection does not establish whole-app quality. Broader visual redesign and additional architecture changes require demonstrated findings, not speculative abstractions or another state-management framework. Runtime/device gaps remain explicit; no store qualification is inferred from desktop or widget tests.

## Recursive sine-warped sphere

Status: Accepted

Owner request: study the supplied Quílez video as a new fractal type to add. Plan one source-attributed 3D recursive sine-warped sphere with bounded detail/strength/radius/phase controls, saved-state restoration and matching PNG export. This books implementation and qualification in the existing queue; the study does not implement or dispatch them. Preserve earlier app-quality/release/academic work and all existing identities. No new rendering framework, copied artwork, paid services or publication is authorized.

See [the source study](research/recursive-sine-sphere.md) and [bounded implementation contract](docs/engineering/spec.md#recursive-sine-warped-sphere). Finite multiscale detail is not mathematical certification or a claim of exact infinite self-similarity.

## Failure-safe native image exports

Status: Accepted

The owner requested gaps in existing plans be closed and additional bounded plans saved. Native single-image, batch-image and contact-sheet exports must not leave incomplete bytes under a completed filename or destroy an existing destination when a write fails. Preserve current filenames, image/metadata content, user-chosen directories and platform distinctions. This is a completion safeguard for the existing image-creation journey, not a resumable-export system, general storage redesign or release authority. See [the commit boundary](docs/engineering/spec.md#native-export-commit-boundary).

The owner separately deferred favorites/history/viewer-session preference-save failure changes; that finding remains documented and non-executable in this pass. Human academic approval and existing device/production gates remain unchanged.

## Optional looper-point randomizer

Status: Accepted

Add optional random camera points to the existing Camera looper, retaining manual A/B and additional-point workflows. Per-point rerolls must leave other saved points and the live viewer untouched. Generated points must be repeatable for preview/export and remain under existing camera/GIF/accessibility limits. [Bounded design and delegated planner defaults](docs/engineering/spec.md#optional-randomized-camera-looper-points) keep parameter randomization and automatic playback out of this first slice. This is future implementation, not part of the release already frozen.

## Fibonacci prime-degree Julia fractal

Status: Accepted

Owner outcome: research and plan implementation of the Fibonacci prime-degree Julia fractal. This `/plan-for-me` occurrence saves the plan, not implementation or a timed schedule. Preserve TODO.md as the central queue and synchronize goals.json, as explicitly requested; do not migrate formats, reset historical slots or change the existing focus/order to make this work run.

Deliver one native `fibonacci_complex_julia` identity using the published complex Fibonacci map H_c(z,w)=(zw+c,z), initially sliced by (z,w)=(p,p). Highlight prime Fibonacci polynomial degrees truthfully, support genuine GPU and native CPU paths, explain finite-budget/numeric uncertainty, and preserve saved states and PNG ownership. Two complex coordinates mean four real state coordinates, not a new full-4D viewer. The recurrence, proof, sources and planner choices are in [the spec](docs/engineering/spec.md#fibonacci-prime-degree-julia); [the research note](research/fibonacci-prime-degree-julia.md) separates evidence from proposals.

Planner defaults: one diagonal slice, existing 2D controls and fixed complex-c controls, at most 45 updates, always-on prime-degree accents (no new toggle/CPU parameter plumbing), time-static classification, no generic complex-space engine or dependencies. A later fixed-memory/3D section remains optional and outside this batch. Success means an actual useful nonzero-c render, honest prime legend and same-state decodable PNG, not merely a circle, shader compilation or number-theory decoration. Existing spiral/word/cone identities and B artwork remain unchanged.

Tasks: FIB-PRIME-01 -> FIB-PRIME-02; FIB-PRIME-03 separately owns real-target qualification. No infinitude proof, runtime primality search, academic claim/acquisition self-approval, release, publication or runner restart is authorized.
