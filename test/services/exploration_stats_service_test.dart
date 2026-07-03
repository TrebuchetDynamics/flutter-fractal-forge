import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/exploration_stats.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';

void main() {
  group('ExplorationStats model', () {
    test('snapshots and freezes explored fractal IDs at construction', () {
      final ids = <String>{'mandelbrot'};
      final stats = ExplorationStats(uniqueFractalsExplored: ids);

      ids.add('julia');

      expect(stats.uniqueFractalsExplored, {'mandelbrot'});
      expect(
        () => stats.uniqueFractalsExplored.add('phoenix'),
        throwsUnsupportedError,
      );
    });

    test('decode skips stale fractal IDs without dropping valid stats', () {
      final stats = ExplorationStats.decode(jsonEncode({
        'totalZoomDistance': 2.5,
        'totalTimeSeconds': 60,
        'screenshotsTaken': 3,
        'uniqueFractalsExplored': ['mandelbrot', 42, null, '', 'julia'],
        'firstExplorationDate': '2024-01-01T00:00:00.000Z',
        'lastUpdated': '2024-01-02T00:00:00.000Z',
      }));

      expect(stats.totalZoomDistance, 2.5);
      expect(stats.totalTimeSeconds, 60);
      expect(stats.screenshotsTaken, 3);
      expect(stats.uniqueFractalsExplored, {'mandelbrot', 'julia'});
      expect(stats.firstExplorationDate, DateTime.utc(2024, 1, 1));
    });
  });

  group('ExplorationStatsService', () {
    late ExplorationStatsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = ExplorationStatsService();
      await service.init();
    });

    test('disposed service ignores stale record calls', () {
      service.dispose();

      expect(() => service.recordScreenshot(), returnsNormally);
      expect(() => service.recordTime(60), returnsNormally);
      expect(() => service.recordZoom(1.0, 2.0), returnsNormally);
      expect(
          () => service.recordFractalExplored('mandelbrot'), returnsNormally);
      expect(service.stats.screenshotsTaken, 0);
      expect(service.stats.totalTimeSeconds, 0);
      expect(service.stats.totalZoomDistance, 0.0);
      expect(service.stats.uniqueFractalsExplored, isEmpty);
    });

    test('starts with empty stats', () {
      expect(service.stats.totalZoomDistance, 0.0);
      expect(service.stats.totalTimeSeconds, 0);
      expect(service.stats.screenshotsTaken, 0);
      expect(service.stats.uniqueFractalsExplored, isEmpty);
    });

    test('recordZoom adds distance to total', () {
      service.recordZoom(1.0, 10.0);
      // log(10) - log(1) = ln(10) ≈ 2.302
      expect(service.stats.totalZoomDistance, greaterThan(0.0));

      final before = service.stats.totalZoomDistance;
      service.recordZoom(1.0, 100.0);
      expect(service.stats.totalZoomDistance, greaterThan(before));
    });

    test('ignores malformed zoom telemetry instead of corrupting progress', () {
      service.recordZoom(1.0, double.infinity);
      service.recordZoom(double.nan, 10.0);
      service.addZoomDistance(double.nan);
      service.addZoomDistance(double.infinity);

      expect(service.stats.totalZoomDistance, 0.0);
      expect(
          service.unlockedAchievements, isNot(contains(Achievement.firstZoom)));
      expect(service.getProgress(Achievement.firstZoom), 0.0);
    });

    test('recordTime accumulates total seconds', () {
      service.recordTime(60);
      expect(service.stats.totalTimeSeconds, equals(60));

      service.recordTime(120);
      expect(service.stats.totalTimeSeconds, equals(180));
    });

    test('ignores negative time telemetry instead of reducing totals', () {
      service.recordTime(60);
      service.recordTime(-120);
      service.addExploreTime(const Duration(seconds: -30));

      expect(service.stats.totalTimeSeconds, 60);
      expect(service.getProgress(Achievement.veteran), greaterThan(0.0));
    });

    test('recordScreenshot increments count', () {
      service.recordScreenshot();
      expect(service.stats.screenshotsTaken, equals(1));

      service.recordScreenshot();
      expect(service.stats.screenshotsTaken, equals(2));
    });

    test('recordFractalExplored adds unique module IDs', () {
      service.recordFractalExplored('mandelbrot');
      service.recordFractalExplored('julia');
      expect(service.stats.uniqueFractalsExplored,
          containsAll(['mandelbrot', 'julia']));
      expect(service.stats.uniqueFractalsExplored.length, equals(2));
    });

    test('recordFractalExplored deduplicates same module', () {
      service.recordFractalExplored('mandelbrot');
      service.recordFractalExplored('mandelbrot');
      expect(service.stats.uniqueFractalsExplored.length, equals(1));
    });

    test('getProgress returns 1.0 for unlocked achievements', () {
      // Unlock firstZoom by recording enough distance (threshold 0.25).
      // log(e^0.3) - log(1) = 0.3 > 0.25
      service.recordZoom(1.0, 1.35); // distance ≈ 0.3
      expect(service.unlockedAchievements, contains(Achievement.firstZoom));
      expect(service.getProgress(Achievement.firstZoom), equals(1.0));
    });

    test('getProgress returns fractional progress for partial achievement', () {
      // photographer threshold is 10 screenshots; take 5.
      for (var i = 0; i < 5; i++) {
        service.recordScreenshot();
      }
      final progress = service.getProgress(Achievement.photographer);
      expect(progress, closeTo(0.5, 0.01));
    });
  });
}
