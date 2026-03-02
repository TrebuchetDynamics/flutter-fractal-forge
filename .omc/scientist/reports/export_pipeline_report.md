# Export Pipeline Correctness Analysis Report

**Project:** Flutter Fractal Forge  
**Date:** 2026-02-13  
**Files Analyzed:** 13  
**Total Issues Found:** 15  

---

## Executive Summary

The export pipeline has **3 critical broken features** that will cause runtime crashes or complete feature failure. The overall confidence score is **53.3%**, with only 3 out of 9 export features rated as highly reliable.

**Overall Status:** 🔴 **CRITICAL ISSUES BLOCKING PRODUCTION**

### Issue Breakdown
- 🔴 Critical: 2 (runtime crashes)
- 🟡 High: 4 (common failure scenarios)
- 🟠 Medium: 6 (edge cases, silent failures)
- 🟢 Low: 3 (minor quality issues)

---

## Critical Bugs (Must Fix Immediately)

### 1. AR Video Export Uses Invalid API ❌
**File:** `ar_video_exporter.dart:82-86`  
**Problem:** Attempts to use `firstFrame.addFrame()` which doesn't exist in image v4.x  
**Impact:** Runtime crash with `NoSuchMethodError` when user tries AR video export  
**Fix:** Migrate to proper image v4.x GIF encoding API

```dart
// BROKEN CODE:
final firstFrame = frames.first;
for (var i = 1; i < frames.length; i++) {
  firstFrame.addFrame(frames[i]);  // ❌ Method doesn't exist
}
final bytes = img.encodeGif(firstFrame);

// SHOULD BE:
final bytes = img.encodeGif(
  frames.first,
  // Add other frames and duration parameter per v4.x API
);
```

### 2. Video Export Feature Non-Functional ❌
**File:** `video_export_service.dart:188-189`  
**Problem:** Captures all frames but only saves first frame as PNG  
**Impact:** Users get 1 PNG image instead of MP4/GIF video  
**Fix:** Either implement proper video encoding (FFmpeg) or remove feature from UI

```dart
// BROKEN: Only saves first frame
final outputFile = File(outputPath.replaceAll('.${options.format.extension}', '.png'));
await outputFile.writeAsBytes(frames.first);  // ❌ Loses all other frames
```

---

## High Priority Issues

### 1. Division by Zero Risk
**File:** `video_export_service.dart:49`  
Single-frame videos will crash with division by zero.

### 2. Export Capture Race Condition
**File:** `export_service.dart:116-124`  
Waiting one frame may not be enough; exports can fail on first attempt.

### 3. Batch Export Frame Stability
**File:** `batch_export_service.dart:64-65`  
May capture incomplete/blank frames due to GPU pipeline delays.

### 4. Wallpaper Silent Failures
**File:** `wallpaper_service.dart:36-41`  
Platform errors are masked; users see "failed" with no debugging info.

---

## Working Features ✅

These features are **correctly implemented** and verified:

1. ✅ PNG Export - Proper image v4.x API usage
2. ✅ JPG Export - Alpha removal working correctly  
3. ✅ compositeImage usage - Migrated from old `copyInto` API
4. ✅ ChannelOrder.bgra - Proper v4.x channel ordering
5. ✅ Metadata embedding - PNG text chunks working
6. ✅ Pixel ratio calculations - Aspect ratio handling correct

---

## Feature Reliability Scores

| Feature | Score | Status | Notes |
|---------|-------|--------|-------|
| PNG Export | 95% | 🟢 GOOD | Verified correct |
| JPG Export | 90% | 🟢 GOOD | Working |
| Metadata | 90% | 🟢 GOOD | Text chunks OK |
| AR Screenshot | 75% | 🟡 RISKY | Camera handling fragile |
| Batch Export | 70% | 🟡 RISKY | Frame timing issues |
| Wallpaper | 60% | 🟡 RISKY | Silent failures |
| **WebP Export** | **0%** | 🔴 **BROKEN** | Silently becomes PNG |
| **Video Export** | **0%** | 🔴 **BROKEN** | Non-functional |
| **AR Video** | **0%** | 🔴 **BROKEN** | Crashes on use |

**Average Confidence: 53.3%**

---

## Immediate Action Plan

### Phase 1: Block Production Release 🔴
1. Fix AR video GIF encoding API migration
2. Remove video export feature from UI OR implement proper encoding

### Phase 2: High Priority Fixes 🟡
1. Fix division by zero in video calculations
2. Add retry logic for render boundary capture  
3. Add frame stabilization delay in batch export
4. Improve wallpaper error reporting

### Phase 3: Quality Improvements 🟢
1. Implement WebP or remove from UI
2. Add file I/O error handling
3. Log camera errors
4. Report contact sheet failures

---

## Risk Assessment

**Risk Categories Identified:**
- Silent Failures: 5 instances
- Runtime Crashes: 2 instances
- Data Loss: 1 instance
- User Confusion: 1 instance
- Performance: 1 instance

**Most Affected Files:**
1. `export_service.dart` - 4 issues
2. `video_export_service.dart` - 3 issues
3. `ar_video_exporter.dart` - 3 issues
4. `batch_export_service.dart` - 3 issues

---

## Migration Status: image v4.x

| Item | Status |
|------|--------|
| ✅ compositeImage (export_service.dart) | DONE |
| ✅ compositeImage (ar_export_service.dart) | DONE |
| ✅ ChannelOrder.bgra | DONE |
| ✅ PNG encoding | DONE |
| ✅ Image text metadata | DONE |
| ❌ GIF encoding (ar_video_exporter.dart) | **BROKEN** |

5 out of 6 migration items complete. GIF encoding still uses old Animation API.

---

## Recommendations

1. **Disable broken features in UI** until fixed (WebP, Video, AR Video)
2. **Add integration tests** for all export formats
3. **Improve error messages** - replace silent failures with user feedback
4. **Add frame timing debug mode** for batch export troubleshooting
5. **Document platform channel contracts** for wallpaper service

---

*Full JSON data saved to: `.omc/scientist/reports/export_pipeline_analysis.json`*
