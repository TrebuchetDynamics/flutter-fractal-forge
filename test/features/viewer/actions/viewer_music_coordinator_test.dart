import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_music_coordinator.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMusicService extends FractalMusicService {
  _FakeMusicService({this.failPlay = false});
  bool failPlay;
  int playCount = 0;
  int stopCount = 0;

  @override
  Future<void> play(FractalController controller,
      {FractalMusicScanFrame? scanFrame}) async {
    playCount++;
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
  }) {
    final syncs = syncCalls ?? [];
    final states = stateCalls ?? [];
    int captures = 0;
    return ViewerMusicCoordinator(
      effects: effects,
      captureFrame: () async {
        captures++;
        if (captureCallCount != null) captureCallCount = captures;
        return null;
      },
      syncAnimation: syncs.add,
      notifyState: () => states.add(Object()),
      rescanDelay: const Duration(milliseconds: 1),
    );
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
  });

  group('ViewerMusicCoordinator._doRestart outcome', () {
    test('failed play: notifies state and syncs animation to false', () async {
      final music = _FakeMusicService(failPlay: true);
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final states = <Object>[];
      final coord = makeCoordinator(
          effects: effects, syncCalls: syncs, stateCalls: states);

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(syncs, [false]);
      expect(states.length, 1);
      coord.dispose();
    });

    test('successful restart syncs animation to true', () async {
      final music = _FakeMusicService();
      final effects = ViewerEffectsController(musicService: music);
      effects.fractalMusicEnabled = true;
      final syncs = <bool>[];
      final states = <Object>[];
      final coord = makeCoordinator(
          effects: effects, syncCalls: syncs, stateCalls: states);

      coord.scheduleRescan(controller);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(syncs, [true]);
      expect(states, isEmpty); // no state notification on success
      coord.dispose();
    });
  });

  group('ViewerMusicCoordinator.cancelRescan', () {
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
