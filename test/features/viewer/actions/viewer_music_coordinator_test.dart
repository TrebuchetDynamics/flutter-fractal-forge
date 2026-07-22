import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_music_coordinator.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

class _FakeMusicService extends FractalMusicService {
  _FakeMusicService({this.failPlay = false, this.playBarrier});
  bool failPlay;
  Object? playError;
  final Future<void>? playBarrier;
  int playCount = 0;
  int stopCount = 0;

  @override
  Future<void> play(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) async {
    playCount++;
    final barrier = playBarrier;
    if (barrier != null) await barrier;
    final error = playError;
    if (error != null) throw error;
    if (failPlay) throw StateError('no audio device');
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  void dispose() {}
}

void main() {
  late FractalController controller;

  setUp(() {
    controller = FractalController(ModuleRegistry());
  });

  tearDown(() {
    controller.dispose();
  });

  ViewerMusicCoordinator makeCoordinator({
    required ViewerEffectsController effects,
    List<bool>? syncCalls,
    List<Object>? stateCalls,
    int? captureCallCount,
    Duration? rescanDelay = const Duration(milliseconds: 1),
    Duration loopRefreshDelay = const Duration(seconds: 4),
    List<FractalMusicScanFrame?> scanFrames = const [null],
  }) {
    final syncs = syncCalls ?? [];
    final states = stateCalls ?? [];
    int captures = 0;
    Future<FractalMusicScanFrame?> captureFrame() async {
      final frame = scanFrames[captures.clamp(0, scanFrames.length - 1)];
      captures++;
      if (captureCallCount != null) captureCallCount = captures;
      return frame;
    }

    if (rescanDelay == null) {
      return ViewerMusicCoordinator(
        effects: effects,
        captureFrame: captureFrame,
        syncAnimation: syncs.add,
        notifyState: () => states.add(Object()),
        loopRefreshDelay: loopRefreshDelay,
      );
    }
    return ViewerMusicCoordinator(
      effects: effects,
      captureFrame: captureFrame,
      syncAnimation: syncs.add,
      notifyState: () => states.add(Object()),
      rescanDelay: rescanDelay,
      loopRefreshDelay: loopRefreshDelay,
    );
  }

  FractalMusicScanFrame frameWithValue(int value) {
    final rgba = Uint8List(4 * 4 * 4);
    for (var i = 0; i < 4 * 4; i++) {
      final offset = i * 4;
      rgba[offset] = value;
      rgba[offset + 1] = value;
      rgba[offset + 2] = value;
      rgba[offset + 3] = 255;
    }
    return FractalMusicScanFrame(rgba: rgba, width: 4, height: 4);
  }

  group('ViewerMusicCoordinator.scheduleRescan', () {
    test('no-op when music is disabled', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      // fractalMusicEnabled starts false
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(music.playCount, 0);
      expect(syncs, isEmpty);
      coord.dispose();
    });

    test('fires restart when music is enabled', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 1);
      expect(syncs, [true]);
      coord.dispose();
    });

    test('debounces: rapid calls only trigger one restart', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      coord.scheduleRescan(controller);
      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 1);
      expect(syncs.length, 1);
      coord.dispose();
    });

    test('default rescan waits for visual state to settle', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(
        effects: effects,
        syncCalls: syncs,
        rescanDelay: null,
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(music.playCount, 0);
      expect(syncs, isEmpty);
      coord.dispose();
    });

    test('module changes bypass the generic rescan debounce', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final coord = makeCoordinator(effects: effects, rescanDelay: null);

      coord.scheduleRescan(controller, moduleChanged: true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(music.playCount, 1);
      coord.dispose();
    });

    test(
      'module morph updates cannot cancel the immediate module rescan',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final coord = makeCoordinator(
          effects: effects,
          rescanDelay: const Duration(milliseconds: 200),
        );

        coord.scheduleRescan(controller, moduleChanged: true);
        coord.scheduleRescan(controller);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(music.playCount, 1);
        coord.dispose();
      },
    );

    test('stale capture cannot replace a newer rescan', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final captures = <Completer<FractalMusicScanFrame?>>[];
      final coord = ViewerMusicCoordinator(
        effects: effects,
        captureFrame: () {
          final capture = Completer<FractalMusicScanFrame?>();
          captures.add(capture);
          return capture.future;
        },
        syncAnimation: (_) {},
        notifyState: () {},
        rescanDelay: Duration.zero,
        loopRefreshDelay: const Duration(seconds: 1),
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(Duration.zero);
      coord.scheduleRescan(controller);
      await Future<void>.delayed(Duration.zero);
      expect(captures, hasLength(2));

      captures[1].complete(frameWithValue(200));
      await Future<void>.delayed(Duration.zero);
      captures[0].complete(frameWithValue(40));
      await Future<void>.delayed(Duration.zero);

      expect(music.playCount, 1);
      coord.dispose();
    });
  });

  group('ViewerMusicCoordinator._doRestart outcome', () {
    test('failed play: notifies state and syncs animation to false', () async {
      final music = _FakeMusicService(failPlay: true);
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final states = <Object>[];
      final coord = makeCoordinator(
        effects: effects,
        syncCalls: syncs,
        stateCalls: states,
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(syncs, [false]);
      expect(states.length, 1);
      coord.dispose();
    });

    test('stop failure keeps the enabled scanner running', () async {
      final music = _FakeMusicService()
        ..playError = FractalMusicStopFailure(StateError('cannot stop'));
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final states = <Object>[];
      final coord = makeCoordinator(
        effects: effects,
        syncCalls: syncs,
        stateCalls: states,
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(effects.fractalMusicEnabled, isTrue);
      expect(states, hasLength(1));
      expect(syncs, isEmpty);
      coord.dispose();
    });

    test('successful restart syncs animation to true', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final states = <Object>[];
      final coord = makeCoordinator(
        effects: effects,
        syncCalls: syncs,
        stateCalls: states,
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(syncs, [true]);
      expect(states, isEmpty); // no state notification on success
      coord.dispose();
    });

    test(
      'successful restart refreshes once per music loop while enabled',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
          scanFrames: [frameWithValue(40), frameWithValue(120)],
        );

        coord.scheduleRescan(controller);
        await Future<void>.delayed(const Duration(milliseconds: 18));

        expect(music.playCount, greaterThanOrEqualTo(2));
        expect(syncs.length, greaterThanOrEqualTo(2));
        coord.dispose();
      },
    );

    test(
      'unchanged full rotation neither restarts nor resets the scanner',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final frame = frameWithValue(90);
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
          scanFrames: [frame, frame],
        );

        coord.scheduleRescan(controller);
        await Future<void>.delayed(const Duration(milliseconds: 12));

        expect(music.playCount, 1);
        expect(syncs, [true]);
        coord.dispose();
      },
    );

    test(
      'rescan fallback keeps retrying until visual capture succeeds',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
          scanFrames: [null, frameWithValue(180)],
        );

        coord.scheduleRescan(controller);
        await Future<void>.delayed(const Duration(milliseconds: 18));

        expect(music.playCount, 2);
        expect(syncs, contains(true));
        coord.dispose();
      },
    );
  });

  group('ViewerMusicCoordinator.startLoopRefresh', () {
    test(
      'checks for visual changes immediately after initial startup',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final initialFrame = frameWithValue(40);
        final coord = makeCoordinator(
          effects: effects,
          loopRefreshDelay: const Duration(seconds: 1),
          scanFrames: [frameWithValue(200)],
        );

        coord.startLoopRefresh(controller, scanFrame: initialFrame);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(music.playCount, 1);
        coord.dispose();
      },
    );

    test('invalid scans do not suppress fallback updates', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final invalidFrame = FractalMusicScanFrame(
        rgba: Uint8List(0),
        width: 1,
        height: 1,
      );
      final coord = makeCoordinator(
        effects: effects,
        scanFrames: [invalidFrame],
      );

      coord.startLoopRefresh(controller, scanFrame: invalidFrame);
      controller.updatePan(Vector2(0.5, 0));
      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 1);
      coord.dispose();
    });

    test('same pixels regenerate music when zoom changes', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final frame = frameWithValue(100);
      final coord = makeCoordinator(effects: effects, scanFrames: [frame]);

      coord.startLoopRefresh(controller, scanFrame: frame);
      controller.updateZoom(4);
      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 1);
      coord.dispose();
    });

    test(
      'retries once after initial enable when scan frame was missing',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
          scanFrames: [frameWithValue(140)],
        );

        coord.startLoopRefresh(controller);
        await Future<void>.delayed(const Duration(milliseconds: 12));

        expect(music.playCount, 1);
        expect(syncs, contains(true));
        coord.dispose();
      },
    );

    test(
      'does not restart fallback audio when retry still has no scan frame',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
        );

        coord.startLoopRefresh(controller);
        await Future<void>.delayed(const Duration(milliseconds: 12));

        expect(music.playCount, 0);
        expect(syncs, isEmpty);
        coord.dispose();
      },
    );

    test(
      'keeps refresh loop alive after a transient missing scan frame',
      () async {
        final music = _FakeMusicService();
        final effects = ViewerEffectsController(musicService: music);
        effects.fractalMusicEnabled = true;
        final syncs = <bool>[];
        final coord = makeCoordinator(
          effects: effects,
          syncCalls: syncs,
          loopRefreshDelay: const Duration(milliseconds: 5),
          scanFrames: [null, frameWithValue(220)],
        );

        coord.startLoopRefresh(controller, scanFrame: frameWithValue(40));
        await Future<void>.delayed(const Duration(milliseconds: 18));

        expect(music.playCount, 1);
        expect(syncs, contains(true));
        coord.dispose();
      },
    );
  });

  group('ViewerMusicCoordinator.cancelRescan', () {
    test('invalidates a restart already waiting on playback', () async {
      final barrier = Completer<void>();
      final music = _FakeMusicService(playBarrier: barrier.future);
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(music.playCount, 1);

      coord.cancelRescan();
      barrier.complete();
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(syncs, isEmpty);
      coord.dispose();
    });

    test('prevents pending restart from firing', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      coord.cancelRescan();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 0);
      expect(syncs, isEmpty);
      coord.dispose();
    });

    test('prevents loop refresh after a successful restart', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(
        effects: effects,
        syncCalls: syncs,
        loopRefreshDelay: const Duration(milliseconds: 5),
        scanFrames: [frameWithValue(40), frameWithValue(120)],
      );

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 3));
      expect(music.playCount, 1);
      coord.cancelRescan();
      await Future<void>.delayed(const Duration(milliseconds: 12));

      expect(music.playCount, 1);
      expect(syncs, [true]);
      coord.dispose();
    });
  });

  group('ViewerMusicCoordinator.dispose', () {
    test('cancels pending timer so restart does not fire', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final coord = makeCoordinator(effects: effects, syncCalls: syncs);

      coord.scheduleRescan(controller);
      coord.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(music.playCount, 0);
      expect(syncs, isEmpty);
    });
  });
}
