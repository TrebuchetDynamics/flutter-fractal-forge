
================================================================================
FLUTTER FRACTAL FORGE - EXPORT PIPELINE CORRECTNESS ANALYSIS
================================================================================
Project: /home/xel/git/flutter-fractal-forge
Date: 2026-02-13
Analyzed Files: 10 export-related service and UI files
Total Issues: 13 (excluding 3 INFO confirmations)

================================================================================
EXECUTIVE SUMMARY
================================================================================

CRITICAL FINDINGS (2):
1. Video export completely non-functional - saves only first frame as PNG
2. AR video GIF encoding uses wrong API - will crash at runtime

HIGH PRIORITY (2):
3. Video export RAM exhaustion - can require 4.8GB for 10s 1080p video
4. AR video RAM exhaustion - 300MB+ for 5s 720p video

MEDIUM PRIORITY (6):
5. WebP export produces corrupted files (PNG data with .webp extension)
6. JPG transparency handling has inverted logic
7. Batch export fails silently on first error
8. No cleanup of temp files on export failure
9. Frame render synchronization insufficient for complex fractals
10. AR video timeout doesn't cancel camera stream properly
11. Custom dimension input has no max bounds validation

LOW PRIORITY (3):
12. Division by zero risk for single-frame videos
13. Boundary null check error messages not specific enough

POSITIVE CONFIRMATIONS (3):
✅ export_service.dart compositeImage usage correct (image v4.x)
✅ ar_video_exporter.dart ChannelOrder.bgra usage correct (image v4.x)
✅ ar_export_service.dart compositeImage usage correct (image v4.x)

================================================================================
DETAILED FINDINGS
================================================================================

[FINDING] Video export only saves first frame, feature non-functional
[STAT:severity] CRITICAL
[STAT:category] Feature Failure
[STAT:location] lib/core/services/video_export_service.dart:188-189
[STAT:details] frameCount: frames.length reports all, fileSize: only first frame

[FINDING] AR GIF encoding uses Image.addFrame() which doesn't exist in v4.x
[STAT:severity] CRITICAL
[STAT:category] API Migration
[STAT:location] lib/core/services/ar_video_exporter.dart:82-86
[STAT:details] Will crash: NoSuchMethodError at runtime

[FINDING] Unbounded frame accumulation: 60fps 10s 1080p = 4.8GB RAM
[STAT:severity] HIGH
[STAT:category] Memory Safety
[STAT:location] lib/core/services/video_export_service.dart:143
[STAT:details] n=600 frames, effect_size: ~8MB per PNG frame

[FINDING] AR video accumulates decoded frames: 30fps 5s 720p = 300MB+
[STAT:severity] HIGH
[STAT:category] Memory Safety
[STAT:location] lib/core/services/ar_video_exporter.dart:59
[STAT:details] n=150 frames, effect_size: ~2MB per decoded image

[FINDING] WebP export returns PNG data with .webp extension - file corruption
[STAT:severity] MEDIUM
[STAT:category] Correctness
[STAT:location] lib/core/services/export_service.dart:236-238
[STAT:details] User impact: 100% of WebP exports are corrupted

[FINDING] JPG transparency logic inverted - keeps alpha when transparent=true
[STAT:severity] MEDIUM
[STAT:category] Correctness
[STAT:location] lib/core/services/export_service.dart:230-234
[STAT:details] Expected: always remove alpha for JPG; Actual: conditional removal

[FINDING] Batch export has no per-item error tracking - silent failures
[STAT:severity] MEDIUM
[STAT:category] Error Handling
[STAT:location] lib/core/services/batch_export_service.dart:58-95
[STAT:details] Limitation: First error stops entire batch, no error list

[FINDING] exportWithOptions has no try-catch - temp file disk leak on error
[STAT:severity] MEDIUM
[STAT:category] Error Handling
[STAT:location] lib/core/services/export_service.dart:280-325
[STAT:details] Limitation: Repeated 4K exports failures = disk exhaustion

[FINDING] Fixed 16ms frame delay - may capture half-rendered complex fractals
[STAT:severity] MEDIUM
[STAT:category] Correctness
[STAT:location] lib/core/services/video_export_service.dart:170
[STAT:details] Limitation: No render completion signal

[FINDING] AR timeout doesn't cancel camera stream - battery/memory waste
[STAT:severity] MEDIUM
[STAT:category] Error Handling
[STAT:location] lib/core/services/ar_video_exporter.dart:156-160
[STAT:details] Limitation: Stream continues after timeout

[FINDING] Custom dimensions accept unbounded input - OOM crash risk
[STAT:severity] MEDIUM
[STAT:category] UI State
[STAT:location] lib/features/export/export_options_sheet.dart:325-356
[STAT:details] Limitation: No max validation (e.g., 8192x8192)

[FINDING] Division by (totalFrames-1) can divide by zero if totalFrames=1
[STAT:severity] LOW
[STAT:category] Correctness
[STAT:location] lib/core/services/video_export_service.dart:49,96
[STAT:details] Edge case: Very short duration + low FPS

[FINDING] Boundary null check error message not specific after retry
[STAT:severity] LOW
[STAT:category] Null Safety
[STAT:location] lib/core/services/export_service.dart:116-124
[STAT:details] Limitation: Same error for initial and post-wait failure

================================================================================
RECOMMENDED FIXES (PRIORITY ORDER)
================================================================================

PHASE 1 - CRITICAL (Ship Blockers):
──────────────────────────────────────────────────────────────────────────────
1. Fix ar_video_exporter.dart GIF encoding (15 min)
   - Replace: firstFrame.addFrame(frames[i])
   - With: animation = img.Animation(); animation.addFrame(frame)
   - File: lib/core/services/ar_video_exporter.dart:82-86

2. Fix video_export_service.dart frame encoding (2 hours)
   - Option A: Implement GIF encoding for all frames (short term)
   - Option B: Remove MP4 from UI until FFmpeg integration (5 min)
   - File: lib/core/services/video_export_service.dart:188-189

PHASE 2 - HIGH (Memory Safety):
──────────────────────────────────────────────────────────────────────────────
3. Add frame streaming for video export (4 hours)
   - Stream frames to temporary files during capture
   - Encode incrementally or batch-encode from disk
   - File: lib/core/services/video_export_service.dart:143-179

4. Limit AR video max frames or resolution (1 hour)
   - Add max frame count (e.g., 300 frames)
   - Or: reduce capture resolution for AR mode
   - File: lib/core/services/ar_video_exporter.dart

PHASE 3 - MEDIUM (Correctness):
──────────────────────────────────────────────────────────────────────────────
5. Remove WebP from UI (5 min)
   - Comment out WebP option in export_options_sheet.dart
   - Or: Add proper WebP encoding library
   - File: lib/features/export/export_options_sheet.dart:234

6. Fix JPG alpha handling (10 min)
   - Always call _removeAlpha() for JPG, ignore transparentBackground
   - File: lib/core/services/export_service.dart:230-234

7. Add per-item error tracking to batch export (1 hour)
   - Track List<Result<preset, file|error>>
   - Continue on individual failures
   - File: lib/core/services/batch_export_service.dart

8. Add try-catch to exportWithOptions (30 min)
   - Wrap export pipeline in try-catch
   - Clean up temp files in finally block
   - File: lib/core/services/export_service.dart:280-325

9. Improve frame render sync (2 hours)
   - Add render completion callback or wait for vsync
   - Make delay configurable per fractal complexity
   - File: lib/core/services/video_export_service.dart:170

10. Fix AR timeout camera cleanup (30 min)
    - Store StreamSubscription, cancel on timeout
    - File: lib/core/services/ar_video_exporter.dart:156-160

PHASE 4 - LOW (Robustness):
──────────────────────────────────────────────────────────────────────────────
11. Add custom dimension validation (15 min)
    - Max 8192x8192, show error dialog
    - File: lib/features/export/export_options_sheet.dart:325-356

12. Fix single-frame division by zero (10 min)
    - Guard: if (totalFrames <= 1) return startView;
    - File: lib/core/services/video_export_service.dart:49,96

13. Improve boundary error messages (5 min)
    - Add retry count to error message
    - File: lib/core/services/export_service.dart:116-124

================================================================================
TEST COVERAGE GAPS
================================================================================

Current coverage: Basic unit tests for helpers only
Missing coverage (0% tested):
  ❌ Image capture pipeline (capturePng, captureWithOptions)
  ❌ Format encoding (_encodeToFormat, _removeAlpha)
  ❌ Metadata embedding (_embedMetadata, _addWatermark)
  ❌ Video export (entire service)
  ❌ AR export (entire service)
  ❌ Batch export (entire service)
  ❌ Wallpaper service (entire service)

Recommended test additions:
  1. Integration tests for full export pipeline
  2. Widget tests for RenderRepaintBoundary capture
  3. Memory stress tests for video export
  4. Format validation tests (PNG/JPG/WebP magic bytes)

================================================================================
LIMITATIONS ACKNOWLEDGED
================================================================================

[LIMITATION] Video export requires FFmpeg for MP4 encoding
  - Pure Dart GIF encoding is the only current option
  - MP4 requires native platform integration

[LIMITATION] WebP encoding not available in image package
  - Need external package or remove from UI
  - Users may be confused by missing option

[LIMITATION] No progress cancellation for in-flight exports
  - Once started, export must complete or error
  - UI doesn't provide cancel button

[LIMITATION] AR video quality limited by camera frame rate
  - Camera API provides ~15-30 fps on most devices
  - Can't achieve 60fps for AR video
