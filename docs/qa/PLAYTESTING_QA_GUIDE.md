# Automated Playtesting & QA Guide for Blind Developers
## Flutter on Android Emulators — Complete Tool Ecosystem

**Project:** Flutter Fractal Forge
**Last Updated:** 2026-02-27
**Audience:** Blind developers, CI/CD pipelines, headless environments

---

## Executive Summary

This guide documents the complete automated playtesting and QA strategy for Flutter apps, specifically optimized for blind developers and headless CI environments. The approach treats the **Semantics Tree as the source of truth**, replacing visual inspection with programmatic text-based validation. Tools are ranked by accessibility, with working code examples, CI pipeline configuration, and a phased implementation plan.

---

## Tool Ecosystem — Ranked for Blind Developers

### Tier 1: Essential (Highest Accessibility)

#### 1. `integration_test` (Flutter SDK) — Score: 10/10
**Why it's #1:** Full access to widget tree, semantics tree, and programmatic control. All output is text-based.

```dart
// integration_test/critical_journey_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_fractal_forge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Critical user journey: catalog → viewer → export', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify catalog loads with fractal entries
    expect(find.byKey(const ValueKey('catalogSearchField')), findsOneWidget);

    // Tap first fractal card
    await tester.tap(find.byKey(const ValueKey('catalogModuleCard_mandelbrot')));
    await tester.pumpAndSettle();

    // Verify viewer loads with controls
    expect(find.byKey(const ValueKey('viewerControlsButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerExportButton')), findsOneWidget);

    // Tap export
    await tester.tap(find.byKey(const ValueKey('viewerExportButton')));
    await tester.pumpAndSettle();

    // Verify export sheet
    expect(find.byKey(const ValueKey('exportSaveButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('exportShareButton')), findsOneWidget);
  });
}
```

**Key APIs:**
- `find.byKey(ValueKey(...))` — stable, non-visual selectors
- `find.text('...')` — content verification
- `tester.pumpAndSettle()` — wait for animations
- `tester.getSemantics(finder)` — access semantics node
- `tester.ensureSemantics()` — enable semantics tree

#### 2. Built-in Accessibility Validators — Score: 9/10
**Why:** Direct access to the semantics tree for programmatic screen reader simulation.

```dart
testWidgets('Verify semantic structure of catalog', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  final SemanticsHandle handle = tester.ensureSemantics();

  // Get semantics for a specific widget
  final semantics = tester.getSemantics(find.byType(ElevatedButton));
  expect(semantics.label, isNotEmpty);
  expect(semantics.hasAction(SemanticsAction.tap), isTrue);

  // Traverse full tree for narrative
  final rootNode = RendererBinding.instance.rootPipelineOwner
      .semanticsOwner?.rootSemanticsNode;
  final narrative = _buildNarrative(rootNode!);
  print(narrative); // Text-based "view" of the screen

  handle.dispose();
});

String _buildNarrative(SemanticsNode node, [int depth = 0]) {
  final buffer = StringBuffer();
  final indent = '  ' * depth;
  final data = node.getSemanticsData();

  if (data.label.isNotEmpty) buffer.writeln('$indent[${data.label}]');
  if (data.value.isNotEmpty) buffer.writeln('$indent  value: ${data.value}');
  if (data.hint.isNotEmpty) buffer.writeln('$indent  hint: ${data.hint}');

  final flags = <String>[];
  if (data.hasFlag(SemanticsFlag.isButton)) flags.add('button');
  if (data.hasFlag(SemanticsFlag.isTextField)) flags.add('textField');
  if (data.hasFlag(SemanticsFlag.isChecked)) flags.add('checked');
  if (data.hasFlag(SemanticsFlag.isFocusable)) flags.add('focusable');
  if (flags.isNotEmpty) buffer.writeln('$indent  flags: ${flags.join(', ')}');

  node.visitChildren((child) {
    buffer.write(_buildNarrative(child, depth + 1));
    return true;
  });
  return buffer.toString();
}
```

#### 3. `flutter_test` (Unit/Widget Tests) — Score: 9/10
**Why:** Fast, granular, text-output only. Catches regressions early.

```dart
testWidgets('Fractal card has correct semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: FractalCard(fractal: mandelbrotFractal)),
  );

  final semantics = tester.getSemantics(find.byType(FractalCard));
  expect(semantics, matchesSemantics(
    label: 'Mandelbrot Set',
    isButton: true,
    hasTapAction: true,
  ));
});
```

### Tier 2: High Value (Good Accessibility with Setup)

#### 4. Golden Tests with `alchemist` — Score: 8/10
**Why:** Automated visual regression detection. Failures are flagged in CI — you don't need to see the diff to know something changed.

```dart
// test/golden/catalog_golden_test.dart
import 'package:alchemist/alchemist.dart';

void main() {
  goldenTest(
    'Catalog screen renders correctly',
    fileName: 'catalog_screen',
    builder: () => GoldenTestGroup(
      scenarioConstraints: BoxConstraints(maxWidth: 400),
      children: [
        GoldenTestScenario(
          name: 'default',
          child: const CatalogScreen(),
        ),
        GoldenTestScenario(
          name: 'large_text',
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: const CatalogScreen(),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_mode',
          child: Theme(
            data: ThemeData.dark(),
            child: const CatalogScreen(),
          ),
        ),
      ],
    ),
  );
}
```

**For blind developers:** The value is in CI — test fails = visual regression detected. Use LLM vision to interpret the diff if needed.

#### 5. `golden_toolkit` — Score: 8/10
**Why:** Multi-device golden testing with `DeviceBuilder`.

```dart
testGoldens('Viewer handles multiple screen sizes', (tester) async {
  final builder = DeviceBuilder()
    ..overrideDevicesForAllScenarios([
      Device.phone,
      Device.iphone11,
      Device.tabletPortrait,
    ])
    ..addScenario(
      name: 'fractal_viewer',
      widget: const FractalViewer(fractalId: 'mandelbrot'),
    );

  await tester.pumpDeviceBuilder(builder);
  await screenMatchesGolden(tester, 'fractal_viewer_devices');
});
```

#### 6. Maestro — Score: 7/10
**Why:** YAML-based E2E test syntax. Simple, stable, works with Flutter via accessibility layer.

```yaml
# .maestro/critical_flow.yaml
appId: com.trebuchetdynamics.fractalforge
---
- launchApp
- assertVisible: "Search fractals"
- tapOn: "Mandelbrot"
- assertVisible: "Export"
- tapOn: "Export"
- assertVisible: "Save"
- assertVisible: "Share"
- pressKey: back
```

**Setup:**
```bash
# Install Maestro
curl -Ls "https://get.maestro.mobile.dev" | bash

# Run on connected device/emulator
maestro test .maestro/critical_flow.yaml

# Run in CI (headless)
maestro test --format junit .maestro/critical_flow.yaml
```

**Limitations:** Interacts via accessibility layer, so Flutter widgets need semantic annotations. Cannot access internal widget state directly.

### Tier 3: Advanced (Specialized Use Cases)

#### 7. LLM-Powered Screenshot Analysis — Score: 7/10
**Why:** An LLM with vision can describe golden test diffs in text, acting as "eyes" for the blind developer.

```python
# scripts/analyze_golden_diff.py
import anthropic
import base64

client = anthropic.Anthropic()

def analyze_golden_failure(baseline_path: str, actual_path: str) -> str:
    with open(baseline_path, "rb") as f:
        baseline_b64 = base64.standard_b64encode(f.read()).decode()
    with open(actual_path, "rb") as f:
        actual_b64 = base64.standard_b64encode(f.read()).decode()

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": [
                {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": baseline_b64}},
                {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": actual_b64}},
                {"type": "text", "text": "Compare these two Flutter app screenshots. The first is the baseline (expected) and the second is the actual (current). Describe ALL visual differences: layout shifts, color changes, text overflow, missing elements, alignment issues. Be specific about locations and severity."}
            ]
        }]
    )
    return response.content[0].text

# Usage in CI:
# python scripts/analyze_golden_diff.py test/golden/failures/catalog_screen.png test/golden/goldens/catalog_screen.png
```

**Cost breakdown (Claude Sonnet vision):**
| Scenario | Images/Run | Cost/Image | Cost/Run |
|----------|-----------|------------|----------|
| 5 golden failures | 10 (pairs) | ~$0.01 | ~$0.10 |
| 20 golden failures | 40 (pairs) | ~$0.01 | ~$0.40 |
| Daily CI (5 failures avg) | 10 | ~$0.01 | ~$3/month |

#### 8. Appium + Flutter Driver — Score: 6/10
**Why:** Cross-platform server for broader device coverage. Works with Flutter ValueKeys.

```python
# Appium test example
from appium import webdriver
from appium.options.flutter import FlutterOptions

options = FlutterOptions()
options.app = "build/app/outputs/flutter-apk/app-debug.apk"
options.automation_name = "Flutter"

driver = webdriver.Remote("http://localhost:4723", options=options)

# Find by ValueKey
catalog_search = driver.find_element("key", "catalogSearchField")
catalog_search.send_keys("Mandelbrot")

# Find by semantics label
export_btn = driver.find_element("semantics label", "Export")
export_btn.click()
```

**Not recommended as primary:** Complex setup, slower than native Flutter tests. Use only for cross-device matrix testing.

---

## Overflow Detection (Programmatic)

```dart
// test/golden/overflow_detection_test.dart
testWidgets('No overflow at max text scale', (tester) async {
  final errors = <FlutterErrorDetails>[];
  final oldHandler = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details);

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
      child: const MaterialApp(home: CatalogScreen()),
    ),
  );
  await tester.pumpAndSettle();

  FlutterError.onError = oldHandler;

  final overflows = errors.where(
    (e) => e.toString().contains('overflowed'),
  );
  expect(overflows, isEmpty, reason: 'Found ${overflows.length} overflow errors at 3x text scale');
});
```

---

## GitHub Actions CI Pipeline (with Emulator Caching)

```yaml
# .github/workflows/flutter_qa.yml
name: Flutter QA Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.38.x'

jobs:
  # Job 1: Fast feedback (< 2 min)
  unit_widget_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ~/.pub-cache
            .dart_tool
          key: pub-${{ hashFiles('pubspec.lock') }}
      - run: flutter pub get
      - run: flutter analyze --no-fatal-infos
      - run: flutter test --reporter=expanded

  # Job 2: Golden/snapshot tests
  golden_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter test test/golden/ --reporter=expanded
      - name: Upload golden failures
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: golden-failures
          path: test/golden/failures/

  # Job 3: Integration tests on emulator
  integration_tests:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - name: Cache Android SDK
        uses: actions/cache@v4
        with:
          path: |
            ~/.android/avd
            ~/Android/Sdk
          key: android-sdk-34-x86_64
      - name: Setup Android emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          ram-size: 4096M
          heap-size: 1024M
          disable-animations: true
          script: |
            flutter pub get
            flutter test integration_test/ --reporter=expanded

  # Job 4: Semantic narrative diff
  semantic_check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter test test/semantics/ --reporter=expanded
      - name: Check semantic narrative baselines
        run: |
          if [ -d "test/semantics/baselines" ]; then
            flutter test test/semantics/ 2>&1 | tee semantic_report.txt
            echo "## Semantic Narrative Report" >> $GITHUB_STEP_SUMMARY
            cat semantic_report.txt >> $GITHUB_STEP_SUMMARY
          fi
```

**Caching strategy:**
| Cache Target | Key | Savings |
|-------------|-----|---------|
| Flutter SDK | Built into `flutter-action` | ~60s |
| pub dependencies | `pubspec.lock` hash | ~15s |
| Android SDK/AVD | API level + arch | ~120s |
| Gradle | `gradle-wrapper.properties` hash | ~45s |

---

## Phased Implementation Plan

### Phase 0: Minimum Viable Setup (4 hours)

| Hour | Task | Deliverable |
|------|------|-------------|
| 1 | Add `integration_test` to pubspec, write 1 smoke test | `integration_test/app_test.dart` |
| 2 | Add ValueKeys to 10 most important widgets | Stable selectors for testing |
| 3 | Create semantics test helper + 1 semantic audit test | `test/helpers/semantics_test_helper.dart` |
| 4 | Set up GitHub Actions workflow (unit tests only) | `.github/workflows/flutter_qa.yml` |

### Phase 1: Foundation (Week 1-2)
- Write integration tests for all critical user journeys
- Assign ValueKeys to ALL interactive widgets
- Implement `Semantics.identifier` for i18n-safe selectors
- Run full semantic audit

### Phase 2: Semantic Verification (Week 3-4)
- Golden narrative baselines for all screens
- MergeSemantics/ExcludeSemantics optimization
- Focus order validation
- Semantic label validation for all UI elements

### Phase 3: Visual Regression (Week 5-6)
- Integrate golden_toolkit/alchemist
- Multi-device golden tests
- Text scaling (1.0x, 2.0x, 3.0x) overflow detection
- Dark/light theme golden tests

### Phase 4: Performance (Week 7-8)
- `traceAction` in integration tests
- Frame build time assertions (< 16ms)
- Memory leak detection
- FPS monitoring (> 55fps)

### Phase 5: Advanced (Week 9+)
- LLM-powered golden diff analysis
- Maestro E2E flows
- Cross-platform matrix via Appium
- CI pipeline with emulator caching

---

## Tools NOT Recommended

| Tool | Reason |
|------|--------|
| **Detox** | No Flutter support. React Native only. |
| **Espresso/UIAutomator** | Cannot see inside Flutter's Skia canvas. Only sees FlutterSurfaceView. |
| **XCUITest** | iOS only, same canvas limitation as Espresso. |
| **Selenium/Playwright** | Web-only, not applicable to native Flutter. |

---

## Key Concepts Reference

### Semantics Tree vs Widget Tree vs Render Tree
- **Widget Tree:** Declarative UI description (your code)
- **Render Tree:** Layout + paint instructions (framework-managed)
- **Semantics Tree:** Accessibility/meaning layer (your primary QA target)

### Semantic Merging
Flutter merges child semantics nodes into parents to simplify screen reader navigation. This can hide elements from tests. Control with:
- `MergeSemantics` — explicitly merge children
- `ExcludeSemantics` — hide from accessibility
- `explicitChildNodes: true` — prevent merging (expose all children)
- `Semantics.identifier` (Flutter 3.19+) — stable non-visual ID

### ValueKey Best Practices
```dart
// DO: Descriptive, unique, prefixed by context
ValueKey('catalogSearchField')
ValueKey('viewerExportButton')
ValueKey('dockZoomIn')

// DON'T: Generic, duplicated, or index-based
ValueKey('button1')
ValueKey(0)
ValueKey('field')
```

---

## Limitations & Tradeoffs

1. **Golden tests are "blind" to you:** They detect regressions but diagnosing why requires LLM vision or sighted help
2. **Semantics ≠ visual layout:** The tree shows logical structure/order but not spacing, padding, or centering
3. **Maintenance overhead:** Golden images need manual approval when intentional UI changes occur
4. **LLM hallucination:** Generated test scripts may have incorrect selectors or steps
5. **Emulator ≠ real device:** GPU shaders, performance, and touch behavior may differ

---

*Generated as part of the Semantic-First QA Framework implementation.*
*See also: TODO.md (implementation checklist), test/helpers/semantics_test_helper.dart (test utilities)*
