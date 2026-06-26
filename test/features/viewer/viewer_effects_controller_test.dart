import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/fractal_report_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMusicService extends FractalMusicService {
  _FakeMusicService({this.failPlay = false});

  final bool failPlay;
  int playCount = 0;
  int stopCount = 0;
  bool disposed = false;

  @override
  Future<void> play(FractalController controller) async {
    playCount++;
    if (failPlay) throw StateError('no audio');
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  test('toggles Fractal Music through the injected music service', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final music = _FakeMusicService();
    final effects = ViewerEffectsController(musicService: music);
    addTearDown(effects.dispose);

    final enabled = await effects.toggleFractalMusic(controller);
    expect(enabled.enabled, isTrue);
    expect(enabled.failed, isFalse);
    expect(effects.fractalMusicEnabled, isTrue);
    expect(music.playCount, 1);

    final disabled = await effects.toggleFractalMusic(controller);
    expect(disabled.enabled, isFalse);
    expect(effects.fractalMusicEnabled, isFalse);
    expect(music.stopCount, 1);
  });

  test('Fractal Music startup error resets state without throwing', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final effects = ViewerEffectsController(
      musicService: _FakeMusicService(failPlay: true),
    );
    addTearDown(effects.dispose);

    final result = await effects.toggleFractalMusic(controller);
    expect(result.failed, isTrue);
    expect(result.enabled, isFalse);
    expect(effects.fractalMusicEnabled, isFalse);
  });

  test('saves report through report service with sorted tags and visual state',
      () async {
    final dir = Directory.systemTemp.createTempSync('viewer_effects_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final effects = ViewerEffectsController(
      reportService: FractalReportService(issuesDirectory: dir.path),
      musicService: _FakeMusicService(),
    );
    addTearDown(effects.dispose);

    final file = await effects.saveFractalReport(
      controller: controller,
      moduleName: 'Mandelbrot',
      shareUrl: 'https://example.test/view',
      tags: const ['No image', 'Bad Thumbnail'],
      notes: 'dark frame',
    );

    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['moduleId'], controller.module.id);
    expect(json['tags'], ['Bad Thumbnail', 'No image']);
    expect((json['visualState'] as Map)['kaleidoscopeEnabled'], isFalse);
  });
}
