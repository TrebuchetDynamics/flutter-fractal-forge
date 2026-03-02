# Cross-Cutting Bug Analysis Report
# Flutter Fractal Forge

**Date:** 2026-02-13
**Analyst:** Scientist Agent (Claude Opus 4.6)
**Scope:** 13 source files spanning app initialization, error handling, auto-explore,
deep links, history, palette, controls, parameter models, presets, and persistence.

---

## Executive Summary

**31 cross-cutting bugs** identified across 9 categories spanning 13 subsystems.

### Severity Distribution

| Severity | Count | Proportion |
|----------|-------|------------|
| !!! CRITICAL | 2 | 6% |
| !!  HIGH | 10 | 32% |
| !   MEDIUM | 13 | 42% |
| .   LOW | 6 | 19% |
| **TOTAL** | **31** | **100%** |

### Category Distribution

| Category | Count | Max Severity |
|----------|-------|--------------|
| Error Handling Gap | 6 | CRITICAL |
| Race Condition | 5 | CRITICAL |
| Memory Leak | 4 | HIGH |
| Type Safety | 3 | HIGH |
| Navigation Edge Case | 3 | HIGH |
| Data Persistence | 3 | HIGH |
| Lifecycle Issue | 3 | HIGH |
| Null Safety | 2 | HIGH |
| Localization Gap | 2 | MEDIUM |

### Cross-Cutting Impact Matrix (Text)

```
Subsystem          | RC  EH  TS  ML  NS  NAV DP  L10 LC
-------------------|---------------------------------------
Auto-Explore       |  H  .  .  .  .  .  .  .  H 
Error Boundary     |  .  C  .  .  .  .  .  M  . 
Crash Reporter     |  .  M  .  L  .  .  .  .  . 
Deep Link          |  L  .  M  .  .  .  .  .  . 
History Prov.      |  M  M  H  .  .  .  M  .  . 
Palette Svc.       |  .  .  .  H  .  .  .  .  . 
Frac. Controls     |  .  .  H  .  .  .  .  .  . 
Frac. Provider     |  .  M  .  .  .  .  .  .  . 
Preset Store       |  .  .  .  .  .  .  H  .  . 
History Store      |  .  .  .  .  .  .  M  .  . 
Viewer Screen      |  C  .  .  M  H  M  .  M  H 
Main / App         |  .  .  .  .  .  .  .  .  . 

Legend: C=CRITICAL  H=HIGH  M=MEDIUM  L=LOW  .=not affected
Cols:  RC=Race Cond. EH=Error Handling TS=Type Safety ML=Memory Leak
       NS=Null Safety NAV=Navigation DP=Data Persist. L10=Localization LC=Lifecycle
```

---

## Top 5 Critical/High Priority Bugs

### 1. [EH-01] ErrorBoundary does not actually catch widget build errors (CRITICAL)

**Files:** lib/core/widgets/error_boundary.dart:224-249

**Description:** The _ErrorBoundaryWrapper at lines 235-249 simply renders 'child' without any error catching mechanism. The comment says 'error catching happens through the parent ErrorBoundary's build method and Flutter's error handling' but ErrorBoundary.build() at line 208 has no try-catch. The _handleError method at line 179 is only called by the ShaderErrorBoundary's fallbackBuilder (line 607-608), not by any automatic Flutter error interception. The ErrorBoundary widget is effectively a no-op - it wraps children but never catches their errors.

**Evidence:** Lines 224-249: _ErrorBoundaryWrapper.build() just returns 'child'. Line 208-228: ErrorBoundary.build() has no try-catch or error zone. Compare with Flutter's built-in ErrorWidget mechanism which requires overriding FlutterError.onError or using a custom ErrorWidget.builder.

**Impact:** All ErrorBoundary wrappers in the app (including .withErrorBoundary() extension) provide ZERO error protection. Errors propagate to the global error handler or crash the app.

**Recommendation:** Implement actual error catching by wrapping child builds in a zone or using Flutter's ErrorWidget.builder pattern. Consider using a Builder widget that catches errors in its builder callback.

### 2. [RC-02] GPU Health Check modifies live parameters without user consent (CRITICAL)

**Files:** lib/features/viewer/fractal_viewer_screen.dart:231-238

**Description:** The GPU health check at line 235-238 modifies the 'iterations' parameter on the LIVE controller to test if the GPU is working: controller.updateParam('iterations', ((controller.params['iterations'] as int?) ?? 220) + 24). This fires notifyListeners(), records to history, and is VISIBLE to the user. It also races with user interactions - the user may be adjusting parameters at the same time.

**Evidence:** Line 235-238: The health check bumps iterations by +24, waits 80ms, captures a frame, but NEVER RESTORES the original value. The iterations parameter is permanently changed by +24 every time the check runs.

**Impact:** User sees iteration count jump unexpectedly. History is polluted with health-check-induced parameter changes. If the check runs multiple times, iterations keep climbing.

**Recommendation:** Save and restore the original iteration value after the check. Alternatively, use a separate offscreen render target for GPU validation.

### 3. [DP-01] PresetStore.saveUserPreset appends duplicates on repeated saves (HIGH)

**Files:** lib/core/services/preset_store.dart:19-23

**Description:** saveUserPreset() loads all presets, appends the new preset, and saves: 'final updated = [...presets, preset]'. If the same preset (by ID) is saved multiple times (e.g., user taps save twice quickly), duplicates accumulate. There is no deduplication by preset ID.

**Evidence:** Line 20-22: loadUserPresets then unconditionally append. No check for existing ID.

**Impact:** Duplicate presets in the list. UI shows the same preset multiple times. Storage grows unbounded with duplicates.

**Recommendation:** Before appending, filter out any existing preset with the same ID: 'final filtered = presets.where((p) => p.id != preset.id).toList(); final updated = [...filtered, preset];'

### 4. [EH-02] ShaderErrorBoundary creates infinite rebuild loop on error (HIGH)

**Files:** lib/core/widgets/error_boundary.dart:604-613

**Description:** When ShaderErrorBoundary has no error, it wraps its child in an ErrorBoundary with a fallbackBuilder (line 607). The fallbackBuilder calls _handleError(error, null) which calls setState, which triggers a rebuild, which creates a NEW ErrorBoundary with a new fallbackBuilder. But since ErrorBoundary itself doesn't catch errors (see EH-01), the fallbackBuilder is never actually invoked by the ErrorBoundary. If it WERE invoked, calling _handleError inside fallbackBuilder would trigger setState during build, causing a framework assertion error.

**Evidence:** Line 607-609: fallbackBuilder calls _handleError which calls setState (line 192). setState during build is illegal in Flutter.

**Impact:** If error catching is ever fixed in ErrorBoundary, ShaderErrorBoundary will crash with 'setState() or markNeedsBuild() called during build'.

**Recommendation:** Move error handling to a post-frame callback or use a separate error state mechanism that doesn't require setState during build.

### 5. [EH-03] FractalPreset.fromJson throws on corrupted data with no recovery (HIGH)

**Files:** lib/core/models/fractal_preset.dart:145-168

**Description:** fromJson() performs unchecked casts: json['id'] as String (line 148), json['moduleId'] as String (line 149), json['name'] as String (line 150). If any of these are null or wrong type (e.g., after a schema migration), a TypeError is thrown. The caller (listFromPrefs at line 178) has NO try-catch, so a single corrupted preset destroys ALL preset loading.

**Evidence:** Line 148-150: Unchecked 'as String' casts. Line 151: (json['params'] as Map) cast with no null check. Line 178-181: No try-catch in listFromPrefs.

**Impact:** One corrupted preset in SharedPreferences makes ALL user presets inaccessible. The user loses all saved presets with no way to recover.

**Recommendation:** Wrap individual preset deserialization in try-catch within listFromPrefs, skipping corrupted entries. Add null-coalescing defaults to fromJson.

---

## Full Bug Catalog

### Error Handling Gap

#### [EH-01] ErrorBoundary does not actually catch widget build errors -- CRITICAL

**Files:** lib/core/widgets/error_boundary.dart:224-249

**Description:** The _ErrorBoundaryWrapper at lines 235-249 simply renders 'child' without any error catching mechanism. The comment says 'error catching happens through the parent ErrorBoundary's build method and Flutter's error handling' but ErrorBoundary.build() at line 208 has no try-catch. The _handleError method at line 179 is only called by the ShaderErrorBoundary's fallbackBuilder (line 607-608), not by any automatic Flutter error interception. The ErrorBoundary widget is effectively a no-op - it wraps children but never catches their errors.

**Evidence:** Lines 224-249: _ErrorBoundaryWrapper.build() just returns 'child'. Line 208-228: ErrorBoundary.build() has no try-catch or error zone. Compare with Flutter's built-in ErrorWidget mechanism which requires overriding FlutterError.onError or using a custom ErrorWidget.builder.

**Impact:** All ErrorBoundary wrappers in the app (including .withErrorBoundary() extension) provide ZERO error protection. Errors propagate to the global error handler or crash the app.

**Recommendation:** Implement actual error catching by wrapping child builds in a zone or using Flutter's ErrorWidget.builder pattern. Consider using a Builder widget that catches errors in its builder callback.

#### [EH-02] ShaderErrorBoundary creates infinite rebuild loop on error -- HIGH

**Files:** lib/core/widgets/error_boundary.dart:604-613

**Description:** When ShaderErrorBoundary has no error, it wraps its child in an ErrorBoundary with a fallbackBuilder (line 607). The fallbackBuilder calls _handleError(error, null) which calls setState, which triggers a rebuild, which creates a NEW ErrorBoundary with a new fallbackBuilder. But since ErrorBoundary itself doesn't catch errors (see EH-01), the fallbackBuilder is never actually invoked by the ErrorBoundary. If it WERE invoked, calling _handleError inside fallbackBuilder would trigger setState during build, causing a framework assertion error.

**Evidence:** Line 607-609: fallbackBuilder calls _handleError which calls setState (line 192). setState during build is illegal in Flutter.

**Impact:** If error catching is ever fixed in ErrorBoundary, ShaderErrorBoundary will crash with 'setState() or markNeedsBuild() called during build'.

**Recommendation:** Move error handling to a post-frame callback or use a separate error state mechanism that doesn't require setState during build.

#### [EH-03] FractalPreset.fromJson throws on corrupted data with no recovery -- HIGH

**Files:** lib/core/models/fractal_preset.dart:145-168

**Description:** fromJson() performs unchecked casts: json['id'] as String (line 148), json['moduleId'] as String (line 149), json['name'] as String (line 150). If any of these are null or wrong type (e.g., after a schema migration), a TypeError is thrown. The caller (listFromPrefs at line 178) has NO try-catch, so a single corrupted preset destroys ALL preset loading.

**Evidence:** Line 148-150: Unchecked 'as String' casts. Line 151: (json['params'] as Map) cast with no null check. Line 178-181: No try-catch in listFromPrefs.

**Impact:** One corrupted preset in SharedPreferences makes ALL user presets inaccessible. The user loses all saved presets with no way to recover.

**Recommendation:** Wrap individual preset deserialization in try-catch within listFromPrefs, skipping corrupted entries. Add null-coalescing defaults to fromJson.

#### [EH-04] HistoryEntry.fromJson throws on corrupted data with no individual recovery -- MEDIUM

**Files:** lib/features/history/history_entry.dart:106-129

**Description:** Same pattern as EH-03: fromJson() uses unchecked casts (json['id'] as String, json['moduleId'] as String). Although HistoryStore._parseEntries wraps the ENTIRE list in try-catch (line 85-92), a single corrupted entry causes ALL history to be silently discarded (returns empty list).

**Evidence:** history_store.dart line 85-92: catch (_) { return []; } discards all history if ANY single entry is corrupted.

**Impact:** All exploration history lost if any single entry is corrupted in storage.

**Recommendation:** Parse entries individually with per-item try-catch, preserving valid entries.

#### [EH-05] CrashReporter.instance throws before install() in error paths -- MEDIUM

**Files:** lib/core/services/crash_reporter.dart:43-49

**Description:** CrashReporter.instance throws StateError if install() hasn't been called. The CrashReporterExtension.withCrashReporting() (line 482) and CrashReporterMixin.recordError() (line 504) both access CrashReporter.instance unconditionally. If any code path using these runs before main() calls install(), they crash with StateError instead of the original error.

**Evidence:** Line 43-49: instance getter throws. Line 482-489: withCrashReporting catches the original error but then accesses instance which may throw a DIFFERENT error, masking the original.

**Impact:** Error masking - the original error is lost and replaced with a 'CrashReporter not initialized' StateError.

**Recommendation:** Use instanceOrNull with a null-check guard in extension methods and mixins.

#### [EH-06] FractalController.updateParam throws on unknown parameter ID -- MEDIUM

**Files:** lib/features/renderer/providers/fractal_provider.dart:199-206

**Description:** updateParam() uses firstWhere with no orElse: _module.parameters.firstWhere((param) => param.id == id). If a deep link, preset, or history entry references a parameter that doesn't exist in the current module (e.g., after a module change or app update), this throws StateError: 'No element'. The caller in home_screen.dart line 86 has no try-catch for this specific path.

**Evidence:** Line 200: firstWhere without orElse. home_screen.dart line 86: updateParam called in a loop with no individual error handling.

**Impact:** Deep links with unknown parameters crash the app instead of gracefully ignoring unrecognized parameters.

**Recommendation:** Add orElse: () => null to firstWhere and return early if schema is null.

---

### Race Condition

#### [RC-01] AutoExploreService Timer.periodic race with dispose -- HIGH

**Files:** lib/features/auto_explore/auto_explore_service.dart:207,291

**Description:** In _scheduleNext(), a Timer callback fires and calls _nextWanderTarget() which uses compute() (isolate). While awaiting the isolate result, the service may be disposed. The _animateTo() call at line 232 starts a Timer.periodic that checks _isExploring but does NOT check if the object is already disposed. If dispose() runs mid-animation, stop() cancels _anim, but the Completer may never complete, leaking the Future.

**Evidence:** Lines 291-314: Timer.periodic callback accesses controller.view after dispose could have been called. Line 302: controller.updatePan() called on potentially disposed controller.

**Impact:** Orphaned timers writing to a disposed FractalController, causing 'A ChangeNotifier was used after being disposed' exceptions.

**Recommendation:** Add a _disposed flag checked in _animateTo and _scheduleNext callbacks. Complete the Completer in dispose() if still pending.

#### [RC-02] GPU Health Check modifies live parameters without user consent -- CRITICAL

**Files:** lib/features/viewer/fractal_viewer_screen.dart:231-238

**Description:** The GPU health check at line 235-238 modifies the 'iterations' parameter on the LIVE controller to test if the GPU is working: controller.updateParam('iterations', ((controller.params['iterations'] as int?) ?? 220) + 24). This fires notifyListeners(), records to history, and is VISIBLE to the user. It also races with user interactions - the user may be adjusting parameters at the same time.

**Evidence:** Line 235-238: The health check bumps iterations by +24, waits 80ms, captures a frame, but NEVER RESTORES the original value. The iterations parameter is permanently changed by +24 every time the check runs.

**Impact:** User sees iteration count jump unexpectedly. History is polluted with health-check-induced parameter changes. If the check runs multiple times, iterations keep climbing.

**Recommendation:** Save and restore the original iteration value after the check. Alternatively, use a separate offscreen render target for GPU validation.

#### [RC-03] HistoryProvider recordLocation debounce races with goBack/goForward -- MEDIUM

**Files:** lib/features/history/history_provider.dart:108-146

**Description:** recordLocation() uses a 500ms debounce timer. If the user triggers goBack() while a debounced recordLocation is pending, the timer fires and calls _doRecordLocation() which truncates forward history at the OLD _currentIndex (before goBack decremented it). This destroys the just-navigated-to history.

**Evidence:** Line 114: Timer fires _doRecordLocation after goBack already moved _currentIndex. Line 136-138: _history is truncated based on stale _currentIndex state.

**Impact:** Going back in history and then waiting 500ms causes forward history to be silently destroyed even though the user hasn't made a new exploration move.

**Recommendation:** Cancel the debounce timer in goBack() and goForward().

#### [RC-04] DeepLinkService _handleMethodCall processes links after dispose -- LOW

**Files:** lib/core/services/deep_link_service.dart:159-167

**Description:** The MethodChannel handler set at line 143 (_channel.setMethodCallHandler) is never cleared on dispose(). After dispose() closes the StreamController, a late-arriving deep link will call _linkController.add() on a closed controller, throwing a StateError.

**Evidence:** Line 143: Handler installed but never removed. Line 315: dispose() only closes the stream controller, doesn't reset the method channel handler.

**Impact:** Crash on receiving a deep link after the service is disposed.

**Recommendation:** Set _channel.setMethodCallHandler(null) in dispose(), and guard _linkController.add with an _isDisposed check.

#### [RC-05] FractalViewerScreen._onControllerChanged uses context.read after potential unmount -- MEDIUM

**Files:** lib/features/viewer/fractal_viewer_screen.dart:266-309

**Description:** _onControllerChanged() is a listener callback that calls context.read<FractalController>() at line 269. Although it checks 'mounted' at line 267, there is a TOCTOU gap: the widget can be unmounted between the check and the context.read call. Additionally, _scheduleGpuHealthCheck() at line 272 schedules a 3-second timer that accesses context.read at line 222 without a mounted check.

**Evidence:** Line 267-269: mounted check followed by context.read - no synchronization. Line 217-222: Timer callback at line 222 uses context.read without mounted guard.

**Impact:** FlutterError 'Looking up a deactivated widget's ancestor' if the widget tree changes between the mounted check and the context access.

**Recommendation:** Cache the controller reference in a local variable at listener registration time instead of re-reading from context in callbacks.

---

### Memory Leak

#### [ML-01] PaletteService texture cache never disposed on palette update -- HIGH

**Files:** lib/core/services/palette_service.dart:120-154

**Description:** paletteTexture() caches ui.Image objects in _paletteTexCache (line 144). When a palette is updated via updatePalette() (line 70), the old cached texture is NOT disposed - only invalidatePaletteTextures() does that. But invalidatePaletteTextures() is never called automatically after updatePalette(). It requires explicit manual calls.

**Evidence:** Line 70-78: updatePalette() calls _store.savePalettes and notifyListeners but does NOT invalidate the texture cache. Line 149-154: invalidatePaletteTextures() exists but is never called from within the service.

**Impact:** GPU texture memory leak: every palette edit accumulates stale ui.Image objects that are never freed. On devices with limited GPU memory, this can cause out-of-memory crashes during extended palette editing sessions.

**Recommendation:** Call invalidatePaletteTextures() (or at least dispose the specific palette's cached texture) inside updatePalette(), deletePalette(), and addPalette().

#### [ML-02] PaletteService singleton instance never disposed -- MEDIUM

**Files:** lib/core/services/palette_service.dart:11-19

**Description:** PaletteService uses a static singleton (_instance) created via create(). There is no dispose() method and no way to clean up the _paletteTexCache. The singleton outlives the widget tree and holds references to GPU textures indefinitely.

**Evidence:** Line 11-19: Static _instance with no cleanup path. Line 27: Map<String, ui.Image> _paletteTexCache is never cleared on app lifecycle events.

**Impact:** GPU memory held indefinitely even if the palette subsystem is no longer needed.

**Recommendation:** Add a dispose() method that clears the cache and nulls _instance. Call it from app lifecycle handlers or make PaletteService non-singleton.

#### [ML-03] CrashReporter StreamController never disposed in normal app lifecycle -- LOW

**Files:** lib/core/services/crash_reporter.dart:63-64,268-269

**Description:** CrashReporter has a dispose() method (line 268) that closes _eventController, but it's a singleton and dispose() is never called by any app lifecycle code. The StreamController lives for the entire app session, which is expected for a crash reporter, but eventStream subscribers may accumulate without cleanup.

**Evidence:** Line 268-269: dispose() exists but is never invoked. Any eventStream listeners that don't cancel their subscriptions will leak.

**Impact:** Minor memory leak if eventStream is subscribed to from widgets that are rebuilt without canceling subscriptions.

**Recommendation:** Document that eventStream subscribers must manage their own lifecycle, or make the singleton auto-dispose on app termination.

#### [ML-04] FractalViewerScreen creates new AutoExploreService on every controller change -- MEDIUM

**Files:** lib/features/viewer/fractal_viewer_screen.dart:178-179

**Description:** In didChangeDependencies(), when _lastController != controller, a new AutoExploreService is created (line 179). The old one is disposed (line 178), but didChangeDependencies can be called multiple times during the widget lifecycle (e.g., on MediaQuery changes, theme changes). If the controller reference hasn't changed but didChangeDependencies fires, the guard at line 159 prevents recreation. However, if Provider rebuilds cause a new controller reference, the auto-explore state (visited points, spiral state) is lost.

**Evidence:** Line 159: _lastController != controller check. Line 178-179: dispose old, create new. Auto-explore animation state is lost on controller change.

**Impact:** Auto-explore mid-animation is interrupted and restarted from scratch when the controller reference changes.

**Recommendation:** Preserve auto-explore state across controller changes, or prevent unnecessary controller re-creation.

---

### Type Safety

#### [TS-01] FractalParameter.defaultValue typed as Object defeats type safety -- HIGH

**Files:** lib/core/models/fractal_parameter.dart:130, lib/features/controls/fractal_controls.dart:293

**Description:** FractalParameter.defaultValue is typed as Object (line 130). This propagates throughout the codebase: FractalController._params is Map<String, Object>, FractalPreset.params is Map<String, Object>, HistoryEntry.params is Map<String, Object>. Every consumer must do runtime type checks. The project memory notes this exact issue: 'Class fields typed as Object do NOT get type-promoted in if/ternary'.

**Evidence:** fractal_controls.dart line 306-307: 'final v = value; final doubleValue = v is num ? v.toDouble() : param.min;' - local variable workaround needed for type promotion. fractal_provider.dart line 468: 'if (value is num)' check needed in _clampValue.

**Impact:** Every parameter access requires defensive casting. Missing casts cause runtime TypeError crashes. The pattern is error-prone and has already required fixes documented in project memory.

**Recommendation:** Consider a sealed union type for parameter values (e.g., FractalParamValue with IntValue, DoubleValue, BoolValue, EnumValue variants) to get exhaustive switch checking.

#### [TS-02] Preset params deserialization loses int/double distinction -- HIGH

**Files:** lib/core/models/fractal_preset.dart:151, lib/features/history/history_entry.dart:123-124

**Description:** JSON deserialization of params maps uses: (json['params'] as Map).map((key, value) => MapEntry(key as String, value as Object)). JSON numbers decoded by jsonDecode are either int or double depending on whether they have a decimal point. An 'iterations' value serialized as 100 comes back as int, but 100.0 comes back as double. The _clampValue method in FractalController handles this (line 468-474), but direct comparisons like 'option.value == value' (fractal_controls.dart line 358) fail when comparing int 2 with double 2.0.

**Evidence:** fractal_preset.dart line 151: value as Object preserves whatever jsonDecode returns. fractal_controls.dart line 358: option.value == value uses Object equality, which means int(2) != double(2.0).

**Impact:** Enumeration parameters saved as presets may not show as 'selected' in the UI after loading because the Object equality check fails across int/double boundary.

**Recommendation:** Normalize numeric types during deserialization: convert all to the type expected by the parameter schema (int for integer params, double for float params).

#### [TS-03] Deep link parameter type mismatch with controller expectations -- MEDIUM

**Files:** lib/core/services/deep_link_service.dart:81-92, lib/features/home/home_screen.dart:84-87

**Description:** DeepLinkData.toParams() returns iterations as int? and colorScheme as int?, but other params as double?. When applied to the controller via updateParam(), the controller's _clampValue handles num types, but enumeration parameters (like colorScheme) are validated by checking 'optionValues.contains(value)' (fractal_provider.dart line 465). If the option values in the module schema are defined as int but the deep link provides a double (or vice versa), the contains check fails and the default value is used instead.

**Evidence:** deep_link_service.dart line 86: colorScheme is int. Module option values may be defined as int in the FractalParamOption. But after JSON round-trip, types can shift.

**Impact:** Deep links may silently fail to apply colorScheme or other enumeration parameters.

**Recommendation:** Cast enum parameter values to the exact type used in the module schema options.

---

### Navigation Edge Case

#### [NAV-01] Deep link navigation pushes viewer without checking current route -- HIGH

**Files:** lib/features/home/home_screen.dart:67-125

**Description:** _handleDeepLink() at line 90 unconditionally pushes a new FractalViewerScreen via Navigator.of(context).push(). If a viewer is already open, a second instance is pushed on top. If multiple deep links arrive in quick succession (e.g., from a messaging app), multiple viewer screens stack up. There is no deduplication.

**Evidence:** Line 90: Navigator.of(context).push() called without checking Navigator.canPop() or whether a viewer is already visible.

**Impact:** Multiple FractalViewerScreen instances stacked, each with its own GPU health check timer, auto-explore service, and performance service. Memory bloat and confused navigation state.

**Recommendation:** Track whether a viewer is already open and either replace it or ignore duplicate deep links. Use pushReplacement or popUntil before pushing.

#### [NAV-02] Deep link with unknown fractal type shows SnackBar on wrong context -- LOW

**Files:** lib/features/home/home_screen.dart:116-124

**Description:** When a deep link references an unknown module type, the catch block at line 117 shows a SnackBar via ScaffoldMessenger.of(context). But if the error occurs during initial link handling (line 57-60, inside addPostFrameCallback), the Scaffold may not be fully built yet, causing 'ScaffoldMessenger.of() called with a context that does not contain a ScaffoldMessenger'.

**Evidence:** Line 56-60: addPostFrameCallback fires _handleDeepLink which may call ScaffoldMessenger before the Scaffold is available in the widget tree.

**Impact:** Unhandled exception instead of graceful error display.

**Recommendation:** Wrap SnackBar display in a try-catch or verify ScaffoldMessenger availability.

#### [NAV-03] Deep link to 3D fractal navigates to a dead-end screen -- MEDIUM

**Files:** lib/features/viewer/fractal_viewer_screen.dart:473-481, lib/features/home/home_screen.dart:72-75

**Description:** When a deep link specifies type='mandelbulb' (a 3D fractal), _handleDeepLink navigates to FractalViewerScreen. But line 473-481 shows that 3D fractals render as a static text message: 'const Text("3D fractals are disabled on this device")'. The user is navigated to a screen with no interactive content and no way to understand why or go back to something useful.

**Evidence:** home_screen.dart line 72-75: selectModule(registry.byId(data.type)) succeeds for mandelbulb. fractal_viewer_screen.dart line 473: 3D fractals show static text.

**Impact:** Deep links to 3D fractals land on a dead-end screen with no fractal rendering.

**Recommendation:** Validate deep link type against renderable fractals before navigation. Show a meaningful error if the fractal type is not renderable on this device.

---

### Data Persistence

#### [DP-01] PresetStore.saveUserPreset appends duplicates on repeated saves -- HIGH

**Files:** lib/core/services/preset_store.dart:19-23

**Description:** saveUserPreset() loads all presets, appends the new preset, and saves: 'final updated = [...presets, preset]'. If the same preset (by ID) is saved multiple times (e.g., user taps save twice quickly), duplicates accumulate. There is no deduplication by preset ID.

**Evidence:** Line 20-22: loadUserPresets then unconditionally append. No check for existing ID.

**Impact:** Duplicate presets in the list. UI shows the same preset multiple times. Storage grows unbounded with duplicates.

**Recommendation:** Before appending, filter out any existing preset with the same ID: 'final filtered = presets.where((p) => p.id != preset.id).toList(); final updated = [...filtered, preset];'

#### [DP-02] No schema versioning for SharedPreferences data -- MEDIUM

**Files:** lib/core/services/preset_store.dart, lib/core/services/history_store.dart

**Description:** Both PresetStore and HistoryStore serialize data to SharedPreferences as JSON with no version field. If the data schema changes in a future app update (e.g., new required fields, renamed fields), the deserialization will fail and all data will be lost. HistoryStore silently returns empty list on error (line 90), PresetStore propagates the exception.

**Evidence:** preset_store.dart: No version field in serialized data. history_store.dart line 90: catch (_) { return []; } silently discards data.

**Impact:** App updates that change model schemas will cause silent data loss.

**Recommendation:** Add a 'version' field to serialized data and implement migration logic.

#### [DP-03] HistoryStore unlimited favorites with no size bound -- LOW

**Files:** lib/core/services/history_store.dart:8-9,47-55

**Description:** The comment on line 10 says 'Favorites (unlimited, user-managed)'. History is capped at maxHistoryEntries=100, but favorites have no limit. Each favorite contains a full params map and view state. Over time, this can grow large enough to cause SharedPreferences performance issues (especially on Android where SharedPreferences loads the entire XML file into memory at startup).

**Evidence:** Line 47-55: saveFavorites has no size limit. Line 18: maxHistoryEntries=100 only applies to history.

**Impact:** Gradual SharedPreferences bloat leading to slow app startup.

**Recommendation:** Add a reasonable cap (e.g., 500 favorites) with oldest-first eviction.

---

### Lifecycle Issue

#### [LC-01] No AppLifecycleObserver for pause/resume handling -- HIGH

**Files:** lib/main.dart, lib/features/auto_explore/auto_explore_service.dart, lib/features/viewer/fractal_viewer_screen.dart

**Description:** The app has no WidgetsBindingObserver or AppLifecycleListener registered anywhere in the widget tree. When the app goes to background (paused state), the following continue running: 1) AutoExploreService timers continue firing, consuming CPU in background. 2) GPU health check timer (3-second delay) fires and modifies controller state. 3) PerformanceService ticker continues ticking. 4) CpuFallbackPane heartbeat timer (450ms) continues firing. None of these are paused when the app is backgrounded.

**Evidence:** No WidgetsBindingObserver found via grep in any file. AutoExploreService timers at lines 207,291 run unconditionally. fractal_viewer_screen.dart line 1443: Timer.periodic(Duration(milliseconds: 450)) runs indefinitely.

**Impact:** Background CPU drain: timers keep firing when app is minimized. On Android, this can cause the system to kill the app, losing unsaved state. On iOS, background execution violations may cause app rejection.

**Recommendation:** Add WidgetsBindingObserver to HomeScreen or FlutterFractalsApp. Pause all timers on AppLifecycleState.paused, resume on AppLifecycleState.resumed.

#### [LC-02] Exploration stats session time not recorded on app background/kill -- MEDIUM

**Files:** lib/features/viewer/fractal_viewer_screen.dart:316-319

**Description:** Exploration session time is only recorded in dispose() at lines 316-319: 'final elapsed = DateTime.now().difference(start); _statsService?.addExploreTime(elapsed);'. If the app is killed by the OS (which skips dispose), the session time is lost. Even on normal background, dispose may not be called immediately.

**Evidence:** Line 316-319: Stats recording only in dispose(). No lifecycle observer to flush stats on background.

**Impact:** Exploration time stats are underreported because background/kill exits skip the dispose path.

**Recommendation:** Periodically flush stats (e.g., every 60 seconds) and also flush on AppLifecycleState.paused.

#### [LC-03] ModuleRegistry recreated on every build in FlutterFractalsApp -- MEDIUM

**Files:** lib/main.dart:347

**Description:** In _FlutterFractalsAppState.build() at line 347: 'final registry = ModuleRegistry()'. A new ModuleRegistry is created on every rebuild of the app widget. This means every time the accessibility service notifies (line 367 Consumer<AccessibilityService>), a new registry is created. If ModuleRegistry holds any cached state or if widgets compare registry identity, this causes unnecessary rebuilds downstream.

**Evidence:** Line 347: ModuleRegistry() called inside build(). The Consumer at line 367 rebuilds whenever AccessibilityService changes (e.g., high contrast toggle).

**Impact:** Unnecessary object creation on every build. If modules have initialization cost, this is also a performance issue.

**Recommendation:** Move ModuleRegistry creation to initState() or make it a final field.

---

### Null Safety

#### [NS-01] HistoryStore/HistoryProvider conditionally provided but accessed without null check -- HIGH

**Files:** lib/main.dart:353-358, lib/features/viewer/fractal_viewer_screen.dart:948-957

**Description:** In main.dart, HistoryStore and HistoryProvider are conditionally provided: 'if (widget.historyStore != null) Provider<HistoryStore>.value(...)' (line 353-358). In FractalViewerScreen._recordHistory(), it safely reads 'context.read<HistoryProvider?>()', but the HistorySheet and other history consumers use context.read<HistoryProvider>() (non-nullable). If historyStore is null (e.g., creation failed), navigating to history-related features will throw ProviderNotFoundException.

**Evidence:** main.dart line 353: Conditional provider registration. fractal_viewer_screen.dart line 893: context.read<HistoryProvider?>() with null check. But other codepaths may access HistoryProvider without the nullable variant.

**Impact:** ProviderNotFoundException crash if HistoryStore.create() fails during startup.

**Recommendation:** Always register HistoryProvider (even with empty state) or guard ALL access points with the nullable variant.

#### [NS-02] OnboardingService force-unwrapped in _FlutterFractalsAppState -- LOW

**Files:** lib/main.dart:327-329,384-386

**Description:** In initState() line 327-329: 'if (widget.onboardingService != null) _showOnboarding = !widget.onboardingService!.isOnboardingComplete;'. The force-unwrap is safe here due to the null check. But in build() line 384-386, the onboardingService is force-unwrapped again: 'widget.onboardingService!' inside a conditional that checks '_showOnboarding && widget.onboardingService != null'. If _showOnboarding was set to true but onboardingService becomes null (impossible with final field, but demonstrates defensive coding concern), this would crash.

**Evidence:** Line 384-386: Double condition with force-unwrap is safe but brittle.

**Impact:** Low risk since the field is final, but pattern encourages unsafe copy-paste.

**Recommendation:** Use a local variable: 'final svc = widget.onboardingService; if (svc != null && _showOnboarding)'.

---

### Localization Gap

#### [L10N-01] Hardcoded English strings in error/debug UI -- MEDIUM

**Files:** lib/core/widgets/error_boundary.dart:289,330,397,429,502, lib/features/viewer/fractal_viewer_screen.dart:477,674,1386,1504

**Description:** Multiple hardcoded English strings found: error_boundary.dart line 289: 'An Error Occurred', line 330: 'Something went wrong. Please try again.', line 397: 'Try Again', line 429: 'Show Details'/'Hide Details'. fractal_viewer_screen.dart line 477: '3D fractals are disabled on this device.', line 1386: 'CPU fallback enabled (GPU output appeared black).', line 1504: 'Stable renderer active'. ShaderErrorBoundary line 675-685: 'Shader Failed to Load', 'Failed to compile the shader.'

**Evidence:** All strings above are raw English literals, not going through AppLocalizations.

**Impact:** Non-English users see mixed-language UI: localized controls alongside English error messages and debug banners.

**Recommendation:** Extract all user-visible strings to the ARB localization files.

#### [L10N-02] ErrorBoundaryConfig static constants contain hardcoded English -- LOW

**Files:** lib/core/widgets/error_boundary.dart:54-81

**Description:** The static config constants (shader, network, critical) at lines 54-81 contain hardcoded English strings for title and message. These are class-level constants, so they cannot access AppLocalizations which requires a BuildContext.

**Evidence:** Line 56: 'Shader Error', line 57: 'Failed to compile or load the shader.', Line 65: 'Connection Error', line 75: 'Something Went Wrong'.

**Impact:** Error screens always show English regardless of locale.

**Recommendation:** Change ErrorBoundaryConfig to use LocalizedText callbacks (like FractalParameter.label) instead of static strings, or resolve the strings at build time.

---

## Prioritized Recommendations

### Immediate (CRITICAL -- fix before next release)

1. **RC-02**: GPU health check must save/restore iteration parameter value.
2. **EH-01**: ErrorBoundary is a no-op -- implement actual error catching or remove the false safety net.
3. **EH-03**: Wrap individual preset deserialization in try-catch to prevent total data loss.

### High Priority (HIGH -- fix in current sprint)

4. **RC-01**: Add disposed-guard to AutoExploreService timer callbacks.
5. **EH-02**: Fix ShaderErrorBoundary setState-during-build hazard.
6. **LC-01**: Add WidgetsBindingObserver to pause all timers on app background.
7. **ML-01**: Invalidate palette texture cache on palette CRUD operations.
8. **DP-01**: Deduplicate presets by ID in PresetStore.saveUserPreset().
9. **NAV-01**: Prevent duplicate viewer screens from deep link storms.
10. **NS-01**: Always register HistoryProvider (non-conditional).
11. **TS-01/TS-02**: Normalize parameter value types after JSON deserialization.

### Medium Priority (MEDIUM -- schedule for next iteration)

12. **RC-03**: Cancel history debounce timer on back/forward navigation.
13. **RC-05**: Cache controller references instead of reading from context in callbacks.
14. **EH-06**: Add orElse guard to updateParam's firstWhere.
15. **LC-02**: Periodically flush exploration stats.
16. **LC-03**: Move ModuleRegistry creation out of build().
17. **L10N-01**: Extract hardcoded English strings to ARB files.
18. **DP-02**: Add schema versioning to SharedPreferences data.

### Low Priority (LOW -- address when convenient)

19. **RC-04**: Clear MethodChannel handler in DeepLinkService.dispose().
20. **ML-03**: Document CrashReporter eventStream subscriber lifecycle requirements.
21. **L10N-02**: Make ErrorBoundaryConfig use LocalizedText callbacks.
22. **DP-03**: Add size cap to favorites storage.

---

## Limitations

- This analysis is based on static code review of 13 source files. Runtime behavior 
  was not verified through execution or testing.
- Some potential issues (e.g., shader compilation failures, platform-specific deep link 
  behavior) depend on device/OS combinations that cannot be assessed from code alone.
- The ErrorBoundary analysis (EH-01) assumes Flutter's standard error propagation model; 
  custom error zones set up elsewhere could change the behavior.
- Type safety issues (TS-01/TS-02) are inherent to the Map<String, Object> design pattern 
  and would require significant refactoring to fully resolve.
