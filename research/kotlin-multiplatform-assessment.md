# Kotlin Multiplatform versus Flutter for Fractal Forge

Status: Research recommendation; no migration or implementation approved.
Retrieved: 2026-10-17. Official documentation is current live evidence, not a benchmark or pinned migration toolchain.

## Recommendation

Keep Flutter for the current Android/web/Linux product. Kotlin Multiplatform (KMP) has real advantages for Android-native integration and sharing Kotlin domain logic with native frontends, but those advantages do not presently establish a return on a full rewrite of this graphics-heavy app. A narrowly scoped comparison would be a sensible next decision if a measured Flutter limitation or an Android-first product strategy motivates it; this research does not authorize that experiment.

## What is being compared

KMP shares Kotlin logic and platform-specific implementations. Compose Multiplatform is the optional shared UI framework; it is not synonymous with KMP. A migration can choose shared Kotlin logic with separate native UIs, or shared Kotlin logic and Compose UI. The former increases frontend work; the latter still needs rendering and integration qualification on each target. Existing Flutter widgets/Provider/controller code does not become Compose code automatically.

## Repository evidence

Inspected `pubspec.yaml`, `lib/core/modules/fractal_module.dart` and `lib/features/renderer/widgets/renderer/fractal_renderer.dart`. The tree contains 577 `.frag` files, including diagnostics/legacy assets: this is a source-file count, not a runtime module count or a count of files that all need unique manual ports. Shader declarations, uniform bindings, FragmentProgram/FragmentShader integration, CPU fallbacks and renderer routing are Flutter-specific. The dependencies include Provider, image, shared_preferences, path_provider, file_selector, share_plus and web. Equivalent Kotlin/platform capabilities must be selected and verified rather than assuming the Dart packages transfer.

Current Android/web/Linux journey, saved preset/history compatibility, localization/accessibility, exact-number computation and PNG export remain product requirements. Migrating frameworks does not solve unsupported mathematical claims or formula mistakes.

## Advantages that could matter

- Android-native integration: Kotlin can use Android APIs directly in the Android source set. This may simplify MediaStore/gallery, lifecycle/background-work, wallpaper and platform-service integration compared with maintaining Dart-to-platform boundaries. Flutter can also invoke Kotlin through platform channels, so this is a degree-of-integration advantage, not an unavailable capability.
- Kotlin ecosystem and shared domain code: one Kotlin implementation can serve Android, an iOS frontend and desktop/server targets. Coroutines and existing Kotlin/Java libraries can help where supported; JVM libraries are not automatically usable in common/iOS/Wasm code. The benefit is larger if future companion products or the team already standardize on Kotlin.
- Native UI choice: share mathematical/domain logic while using Jetpack Compose on Android and a native iOS frontend, or use Compose Multiplatform for shared screens. This flexibility matters if native platform behavior becomes more important than one shared custom-rendered UI.
- Explicit platform graphics backends: Kotlin source sets can integrate custom graphics implementations. That can enable a purpose-built renderer, but also creates maintenance work. It is not evidence of faster fractals merely from changing language.

## Main disadvantages for this app

1. Graphics portability is the central cost. Flutter currently compiles registered GLSL fragment assets and provides their runtime API. Kotlin/Compose requires an actual replacement rendering path and validation of coordinate conventions, uniforms, color encoding, numerical precision, capture and export. The equations and substantial shader bodies may be reusable; drop-in compatibility is unproven. Android AGSL RuntimeShader is available on Android 13+, not every Android version supported by Compose, and is not a universal iOS/desktop/web backend.
2. Web deserves independent consideration. The retrieved official stability documentation labels Compose Multiplatform web and Kotlin/Wasm Beta; Android, iOS and desktop Compose are Stable. Kotlin/JS being Stable does not make Compose/Wasm UI Stable. The compatibility page requires WasmGC-capable browsers for the documented Compose web target. Browser matrix, accessibility and downloads need real tests.
3. Linux remains supported, but the usual Compose desktop target is JVM. A Kotlin migration does not imply a Kotlin/Native Linux application or removal of runtime overhead. Packaging, startup, memory and rendering must be measured rather than assumed better.
4. State and tests are migration work. Preserve IDs, presets, favorites, history, restoration/deep links, edited-state export and EN/ES accessibility. Existing numeric datasets/oracles may transfer; widget/integration assertions need new harnesses. Exact large integers must be qualified on every backend; do not assume JVM BigInteger is a common Kotlin API or silently substitute floating point.
5. No measured speed/size/battery advantage has been established. GPU shader work, precision, sample counts, caching, synchronization and readback often dominate this app. Neither framework name predicts those outcomes. This assessment contains no migration cost estimate or benchmark.

## Alternatives

- Stay with Flutter and add a focused Kotlin plugin for an actual Android API bottleneck. Lowest disruption when the problem is a platform integration rather than the renderer or language.
- Evaluate a Kotlin mathematical core only if multiple Kotlin/native clients will genuinely consume it; a bridge adds complexity otherwise. Consider a platform-neutral native core only if a demonstrated compute need warrants one, not as speculative infrastructure.
- Full KMP/Compose rewrite only after a bounded experiment proves an important advantage while preserving the product's actual target matrix.

## Proposed experiment — not authorized or run

Compare the same Mandelbrot/Julia workload, one 3D raymarcher, one exact number-wall computation, pan/zoom/color edits and a decoded edited-state PNG. Use the same devices, resolution, iteration/sample/precision settings and mathematical fixtures. Verify save/load of representative legacy records and EN/ES keyboard/screen-reader behavior. Record cold start, application/package/runtime footprint, generation and cached-frame p50/p95, sustained responsiveness, peak memory and export time. Measure energy only with a suitable reproducible method. Android-only results cannot qualify Linux or browser parity. Set success thresholds from an actual bottleneck before committing to migration.

## Sources and confidence

All external sources below are official vendor documentation retrieved on 2026-10-17. Claims of comparative benefit are project-specific inferences, not vendor benchmark results. Versions/platform requirements can change; pin the toolchain and recheck before any experiment.

1. KMP/Compose platform stability: https://kotlinlang.org/docs/multiplatform/supported-platforms.html
2. Compose compatibility, JVM desktop packaging and browser requirements: https://kotlinlang.org/docs/multiplatform/compose-compatibility-and-versioning.html
3. KMP versus shared Compose UI and native-UI options: https://kotlinlang.org/docs/multiplatform/faq.html
4. Relationship to Android Jetpack Compose: https://kotlinlang.org/docs/multiplatform/compose-multiplatform-and-jetpack-compose.html
5. Android AGSL/RuntimeShader, Android 13+ boundary: https://developer.android.com/develop/ui/views/graphics/agsl
6. Flutter GLSL asset compilation and FragmentProgram API: https://docs.flutter.dev/ui/design/graphics/fragment-shaders
7. Flutter native platform integration: https://docs.flutter.dev/platform-integration/platform-channels

The web extractor was rate-limited for Flutter documentation; its official pages were retrieved directly over HTTPS instead. No Kotlin toolchain, renderer port, benchmark, paper acquisition or application change was executed.
