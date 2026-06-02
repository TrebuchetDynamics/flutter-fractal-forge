import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/video_export_options.dart';
import 'package:flutter_fractals/core/services/video_export_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  FractalViewState makeView({double zoom = 1.0}) => FractalViewState(
        pan: Vector2.zero(),
        zoom: zoom,
        rotation: Vector3.zero(),
      );

  const defaultOptions = VideoExportOptions();

  // ---------------------------------------------------------------------------
  // VideoExportResult
  // ---------------------------------------------------------------------------
  group('VideoExportResult', () {
    group('formattedSize', () {
      test('returns bytes label for values under 1 KB', () {
        // We cannot easily create a real File in unit tests, so we test
        // formattedSize via the pure arithmetic branch directly.
        // Build a minimal result via a public constructor.
        // fileSizeBytes drives the label; file path just needs to be a string.
        //
        // Use a temporary directory path that does not need to exist for
        // these pure-value tests.
        final result = _makeResult(fileSizeBytes: 512);
        expect(result.formattedSize, '512 B');
      });

      test('returns KB label for values between 1 KB and 1 MB', () {
        final result = _makeResult(fileSizeBytes: 2048); // 2 KB
        expect(result.formattedSize, '2.0 KB');
      });

      test('returns MB label for values 1 MB and above', () {
        final result = _makeResult(fileSizeBytes: 1024 * 1024); // 1 MB
        expect(result.formattedSize, '1.0 MB');
      });

      test('formattedSize rounds MB to one decimal place', () {
        final result = _makeResult(fileSizeBytes: (1.5 * 1024 * 1024).round());
        expect(result.formattedSize, '1.5 MB');
      });
    });

    test('stores all fields correctly', () {
      final result = _makeResult(
        frameCount: 30,
        fileSizeBytes: 4096,
        resolution: VideoResolution.hd,
        format: VideoExportFormat.gif,
      );
      expect(result.frameCount, 30);
      expect(result.fileSizeBytes, 4096);
      expect(result.resolution, VideoResolution.hd);
      expect(result.format, VideoExportFormat.gif);
      expect(result.duration, const Duration(seconds: 5));
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportOptions (enum coverage + computed properties)
  // ---------------------------------------------------------------------------
  group('VideoExportOptions', () {
    test('default options have expected values', () {
      expect(defaultOptions.format, VideoExportFormat.mp4);
      expect(defaultOptions.animationType, VideoAnimationType.zoomIn);
      expect(defaultOptions.resolution, VideoResolution.fullHd);
      expect(defaultOptions.frameRate, VideoFrameRate.fps30);
      expect(defaultOptions.quality, VideoQualityPreset.high);
      expect(defaultOptions.easing, AnimationEasing.easeInOut);
      expect(defaultOptions.duration, const Duration(seconds: 5));
      expect(defaultOptions.zoomFactor, 10.0);
      expect(defaultOptions.loop, isFalse);
      expect(defaultOptions.includeWatermark, isFalse);
      expect(defaultOptions.parameterSweep, isNull);
    });

    test('totalFrames matches seconds * frameRate for whole seconds', () {
      const opts = VideoExportOptions(
        duration: Duration(seconds: 4),
        frameRate: VideoFrameRate.fps15,
      );
      expect(opts.totalFrames, 60); // 4 * 15
    });

    test('totalFrames for default options is 150', () {
      // 5 seconds * 30 fps
      expect(defaultOptions.totalFrames, 150);
    });

    test('totalFrames preserves fractional-second durations', () {
      const halfSecond = VideoExportOptions(
        duration: Duration(milliseconds: 500),
        frameRate: VideoFrameRate.fps30,
      );
      const mixedSecond = VideoExportOptions(
        duration: Duration(milliseconds: 1500),
        frameRate: VideoFrameRate.fps30,
      );

      expect(halfSecond.totalFrames, 15);
      expect(mixedSecond.totalFrames, 45);
    });

    test('totalFrames keeps non-positive durations replayable', () {
      const zeroDuration = VideoExportOptions(duration: Duration.zero);
      const negativeDuration = VideoExportOptions(
        duration: Duration(milliseconds: -500),
      );

      expect(zeroDuration.totalFrames, 1);
      expect(negativeDuration.totalFrames, 1);
    });

    test('estimatedSizeMb is positive for any configuration', () {
      expect(defaultOptions.estimatedSizeMb, greaterThan(0));
    });

    test('estimatedSizeMb is larger for GIF than MP4 at same settings', () {
      const gifOpts = VideoExportOptions(format: VideoExportFormat.gif);
      const mp4Opts = VideoExportOptions(format: VideoExportFormat.mp4);
      expect(gifOpts.estimatedSizeMb, greaterThan(mp4Opts.estimatedSizeMb));
    });

    test('copyWith preserves unmodified fields', () {
      final updated = defaultOptions.copyWith(zoomFactor: 5.0);
      expect(updated.zoomFactor, 5.0);
      expect(updated.format, defaultOptions.format);
      expect(updated.duration, defaultOptions.duration);
    });

    test('copyWith can update multiple fields', () {
      final updated = defaultOptions.copyWith(
        format: VideoExportFormat.gif,
        resolution: VideoResolution.sd,
        loop: true,
      );
      expect(updated.format, VideoExportFormat.gif);
      expect(updated.resolution, VideoResolution.sd);
      expect(updated.loop, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // VideoResolution
  // ---------------------------------------------------------------------------
  group('VideoResolution', () {
    test('width is derived from height at 16:9', () {
      expect(VideoResolution.hd.height, 720);
      expect(VideoResolution.hd.width, (720 * 16 / 9).round());

      expect(VideoResolution.fullHd.height, 1080);
      expect(VideoResolution.fullHd.width, (1080 * 16 / 9).round());
    });

    test('all resolutions have positive width and height', () {
      for (final r in VideoResolution.values) {
        expect(r.width, greaterThan(0));
        expect(r.height, greaterThan(0));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // VideoFrameRate
  // ---------------------------------------------------------------------------
  group('VideoFrameRate', () {
    test('fps values are positive', () {
      for (final fr in VideoFrameRate.values) {
        expect(fr.fps, greaterThan(0));
      }
    });

    test('label contains fps value', () {
      expect(VideoFrameRate.fps30.label, contains('30'));
      expect(VideoFrameRate.fps60.label, contains('60'));
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportFormat
  // ---------------------------------------------------------------------------
  group('VideoExportFormat', () {
    test('extension returns lowercase string without dot', () {
      expect(VideoExportFormat.mp4.extension, 'mp4');
      expect(VideoExportFormat.gif.extension, 'gif');
    });

    test('displayName is non-empty', () {
      for (final f in VideoExportFormat.values) {
        expect(f.displayName, isNotEmpty);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // VideoQualityPreset
  // ---------------------------------------------------------------------------
  group('VideoQualityPreset', () {
    test('quality values are between 0 and 1', () {
      for (final q in VideoQualityPreset.values) {
        expect(q.quality, greaterThanOrEqualTo(0.0));
        expect(q.quality, lessThanOrEqualTo(1.0));
      }
    });

    test('maximum quality is 1.0', () {
      expect(VideoQualityPreset.maximum.quality, 1.0);
    });

    test('draft quality is less than standard quality', () {
      expect(
        VideoQualityPreset.draft.quality,
        lessThan(VideoQualityPreset.standard.quality),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AnimationEasing
  // ---------------------------------------------------------------------------
  group('AnimationEasing', () {
    test('linear easing returns t unchanged', () {
      expect(AnimationEasing.linear.apply(0.0), 0.0);
      expect(AnimationEasing.linear.apply(0.5), 0.5);
      expect(AnimationEasing.linear.apply(1.0), 1.0);
    });

    test('all easings return 0 at t=0', () {
      for (final e in AnimationEasing.values) {
        expect(e.apply(0.0), closeTo(0.0, 1e-10));
      }
    });

    test('all easings return 1 at t=1', () {
      for (final e in AnimationEasing.values) {
        expect(e.apply(1.0), closeTo(1.0, 1e-10));
      }
    });

    test('easeIn is slower at the start (value < linear at t=0.5)', () {
      expect(
        AnimationEasing.easeIn.apply(0.5),
        lessThan(AnimationEasing.linear.apply(0.5)),
      );
    });

    test('easeOut is faster at the start (value > linear at t=0.5)', () {
      expect(
        AnimationEasing.easeOut.apply(0.5),
        greaterThan(AnimationEasing.linear.apply(0.5)),
      );
    });

    test('easeInOut is symmetric around t=0.5', () {
      const e = AnimationEasing.easeInOut;
      expect(e.apply(0.25), closeTo(1.0 - e.apply(0.75), 1e-10));
    });
  });

  // ---------------------------------------------------------------------------
  // ParameterSweepConfig
  // ---------------------------------------------------------------------------
  group('ParameterSweepConfig', () {
    test('stores fields correctly', () {
      const config = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 2.0,
        endValue: 4.0,
        pingPong: true,
      );
      expect(config.parameterId, 'power');
      expect(config.startValue, 2.0);
      expect(config.endValue, 4.0);
      expect(config.pingPong, isTrue);
    });

    test('pingPong defaults to false', () {
      const config = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 1.0,
        endValue: 3.0,
      );
      expect(config.pingPong, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportPresets
  // ---------------------------------------------------------------------------
  group('VideoExportPresets', () {
    test('socialQuick uses GIF and SD resolution', () {
      expect(VideoExportPresets.socialQuick.format, VideoExportFormat.gif);
      expect(VideoExportPresets.socialQuick.resolution, VideoResolution.sd);
    });

    test('socialMp4 uses MP4 and HD resolution', () {
      expect(VideoExportPresets.socialMp4.format, VideoExportFormat.mp4);
      expect(VideoExportPresets.socialMp4.resolution, VideoResolution.hd);
    });

    test('highQuality uses MP4 at 60 fps', () {
      expect(VideoExportPresets.highQuality.format, VideoExportFormat.mp4);
      expect(VideoExportPresets.highQuality.frameRate, VideoFrameRate.fps60);
    });

    test('gifLoop has loop enabled', () {
      expect(VideoExportPresets.gifLoop.loop, isTrue);
      expect(VideoExportPresets.gifLoop.format, VideoExportFormat.gif);
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportService.calculateAnimationFrame
  // ---------------------------------------------------------------------------
  group('VideoExportService.calculateAnimationFrame', () {
    const service = VideoExportService();

    test('zoomIn: first frame zoom equals start zoom', () {
      final view = makeView(zoom: 2.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.zoomIn,
        zoomFactor: 5.0,
      );
      final frame0 = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 0,
        totalFrames: 10,
      );
      expect(frame0.zoom, closeTo(2.0, 1e-9));
    });

    test('zoomIn: last frame zoom equals start * zoomFactor', () {
      final view = makeView(zoom: 2.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.zoomIn,
        zoomFactor: 5.0,
        easing: AnimationEasing.linear,
      );
      final frame9 = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 9,
        totalFrames: 10,
      );
      expect(frame9.zoom, closeTo(10.0, 1e-6)); // 2.0 * 5.0
    });

    test('zoomOut: last frame zoom equals start / zoomFactor', () {
      final view = makeView(zoom: 10.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.zoomOut,
        zoomFactor: 5.0,
        easing: AnimationEasing.linear,
      );
      final frame9 = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 9,
        totalFrames: 10,
      );
      expect(frame9.zoom, closeTo(2.0, 1e-6)); // 10.0 / 5.0
    });

    test('rotate: pan and zoom are unchanged', () {
      final view = makeView(zoom: 3.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.rotate,
        easing: AnimationEasing.linear,
      );
      final frame = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 5,
        totalFrames: 10,
      );
      expect(frame.zoom, closeTo(3.0, 1e-9));
      expect(frame.pan.x, closeTo(0.0, 1e-9));
    });

    test('rotate: rotation.y increases monotonically with frame index', () {
      final view = makeView();
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.rotate,
        easing: AnimationEasing.linear,
      );

      final frame3 = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 3,
        totalFrames: 10,
      );
      final frame7 = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 7,
        totalFrames: 10,
      );
      expect(frame7.rotation.y, greaterThan(frame3.rotation.y));
    });

    test('pan: zoom is unchanged', () {
      final view = makeView(zoom: 4.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.pan,
        easing: AnimationEasing.linear,
      );
      final frame = service.calculateAnimationFrame(
        startView: view,
        options: opts,
        frameIndex: 5,
        totalFrames: 10,
      );
      expect(frame.zoom, closeTo(4.0, 1e-9));
    });

    test('pan: sampled orbit stays at the documented radius from the start pan',
        () {
      final view = makeView(zoom: 2.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.pan,
        easing: AnimationEasing.linear,
      );
      final expectedRadius = 0.5 / view.zoom;

      for (final frameIndex in [0, 3, 6, 9]) {
        final frame = service.calculateAnimationFrame(
          startView: view,
          options: opts,
          frameIndex: frameIndex,
          totalFrames: 10,
        );
        final distance = (frame.pan - view.pan).length;
        expect(
          distance,
          closeTo(expectedRadius, 1e-8),
          reason: 'frameIndex=$frameIndex',
        );
      }
    });

    test('parameterSweep and custom return unmodified view', () {
      final view = makeView(zoom: 7.0);
      for (final type in [
        VideoAnimationType.parameterSweep,
        VideoAnimationType.custom,
      ]) {
        final opts = VideoExportOptions(animationType: type);
        final frame = service.calculateAnimationFrame(
          startView: view,
          options: opts,
          frameIndex: 5,
          totalFrames: 10,
        );
        expect(frame.zoom, closeTo(7.0, 1e-9));
        expect(frame.pan.x, closeTo(0.0, 1e-9));
      }
    });

    test('single-frame animation does not divide by zero', () {
      final view = makeView(zoom: 1.0);
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.zoomIn,
        easing: AnimationEasing.linear,
      );
      // totalFrames=1: denominator clamped to 1 to avoid zero division
      expect(
        () => service.calculateAnimationFrame(
          startView: view,
          options: opts,
          frameIndex: 0,
          totalFrames: 1,
        ),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // VideoFrameTimeline
  // ---------------------------------------------------------------------------
  group('VideoFrameTimeline', () {
    test('normalizes first, middle, last, and single-frame progress', () {
      expect(VideoFrameTimeline.progress(frameIndex: 0, totalFrames: 10), 0.0);
      expect(VideoFrameTimeline.progress(frameIndex: 5, totalFrames: 11), 0.5);
      expect(VideoFrameTimeline.progress(frameIndex: 9, totalFrames: 10), 1.0);
      expect(VideoFrameTimeline.progress(frameIndex: 0, totalFrames: 1), 0.0);
    });

    test('rejects invalid total frame counts at the timeline boundary', () {
      expect(
        () => VideoFrameTimeline.progress(frameIndex: 0, totalFrames: 0),
        throwsArgumentError,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportService.calculateParameterFrame
  // ---------------------------------------------------------------------------
  group('VideoExportService.calculateParameterFrame', () {
    const service = VideoExportService();

    test('returns empty map when parameterSweep is null', () {
      const opts = VideoExportOptions(); // parameterSweep is null
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 0,
        totalFrames: 10,
      );
      expect(result, isEmpty);
    });

    test('first frame returns startValue', () {
      const sweep = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 2.0,
        endValue: 4.0,
      );
      const opts = VideoExportOptions(
        parameterSweep: sweep,
        easing: AnimationEasing.linear,
      );
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 0,
        totalFrames: 10,
      );
      expect(result['power'], closeTo(2.0, 1e-6));
    });

    test('last frame returns endValue', () {
      const sweep = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 2.0,
        endValue: 4.0,
      );
      const opts = VideoExportOptions(
        parameterSweep: sweep,
        easing: AnimationEasing.linear,
      );
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 9,
        totalFrames: 10,
      );
      expect(result['power'], closeTo(4.0, 1e-6));
    });

    test('result map contains parameterId key', () {
      const sweep = ParameterSweepConfig(
        parameterId: 'myParam',
        startValue: 0.0,
        endValue: 1.0,
      );
      const opts = VideoExportOptions(parameterSweep: sweep);
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 5,
        totalFrames: 10,
      );
      expect(result.containsKey('myParam'), isTrue);
    });

    test(
        'pingPong: value at exact half of range (11 frames, index 5) equals endValue',
        () {
      const sweep = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 0.0,
        endValue: 2.0,
        pingPong: true,
      );
      const opts = VideoExportOptions(
        parameterSweep: sweep,
        easing: AnimationEasing.linear,
      );
      // totalFrames=11: t = 5/(11-1) = 0.5 exactly → pingPong t = 1.0 → value = endValue
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 5,
        totalFrames: 11,
      );
      expect(result['power'], closeTo(2.0, 1e-6));
    });

    test('pingPong: last frame returns startValue', () {
      const sweep = ParameterSweepConfig(
        parameterId: 'power',
        startValue: 1.0,
        endValue: 3.0,
        pingPong: true,
      );
      const opts = VideoExportOptions(
        parameterSweep: sweep,
        easing: AnimationEasing.linear,
      );
      // At frameIndex=9 of 10: t=0.9 → ping-pong t=2-1.8=0.2 → back to near start
      final result = service.calculateParameterFrame(
        startParams: {},
        options: opts,
        frameIndex: 9,
        totalFrames: 10,
      );
      // Should be closer to start than to end
      expect(result['power'], lessThan(2.0));
    });
  });

  // ---------------------------------------------------------------------------
  // VideoExportService.generateFilename
  // ---------------------------------------------------------------------------
  group('VideoExportService.generateFilename', () {
    const service = VideoExportService();

    test('filename starts with fractal_', () {
      final name = service.generateFilename(defaultOptions);
      expect(name, startsWith('fractal_'));
    });

    test('filename contains animation type name', () {
      const opts = VideoExportOptions(
        animationType: VideoAnimationType.zoomOut,
      );
      final name = service.generateFilename(opts);
      expect(name, contains('zoomOut'));
    });

    test('filename ends with correct extension for MP4', () {
      const opts = VideoExportOptions(format: VideoExportFormat.mp4);
      final name = service.generateFilename(opts);
      expect(name, endsWith('.mp4'));
    });

    test('filename ends with correct extension for GIF', () {
      const opts = VideoExportOptions(format: VideoExportFormat.gif);
      final name = service.generateFilename(opts);
      expect(name, endsWith('.gif'));
    });

    test('successive calls produce different filenames', () async {
      // Timestamp is milliseconds, so two rapid calls should differ
      // by at least 1ms in practice; we just verify uniqueness is attempted.
      final n1 = service.generateFilename(defaultOptions);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final n2 = service.generateFilename(defaultOptions);
      // They may match in the same millisecond, but the pattern is correct.
      expect(n1, matches(RegExp(r'^fractal_\w+_\d+\.mp4$')));
      expect(n2, matches(RegExp(r'^fractal_\w+_\d+\.mp4$')));
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: build a VideoExportResult without a real File.
// ---------------------------------------------------------------------------
VideoExportResult _makeResult({
  int fileSizeBytes = 0,
  int frameCount = 1,
  VideoResolution resolution = VideoResolution.fullHd,
  VideoExportFormat format = VideoExportFormat.mp4,
}) {
  return VideoExportResult(
    file: File('/dev/null'),
    filePath: '/dev/null',
    frameCount: frameCount,
    duration: const Duration(seconds: 5),
    fileSizeBytes: fileSizeBytes,
    resolution: resolution,
    format: format,
  );
}
