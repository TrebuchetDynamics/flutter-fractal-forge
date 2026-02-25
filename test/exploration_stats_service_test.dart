import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/exploration_stats_service.dart';

void main() {
  group('ExplorationStatsService', () {
    late ExplorationStatsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = ExplorationStatsService();
      await service.init();
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

    test('recordTime accumulates total seconds', () {
      service.recordTime(60);
      expect(service.stats.totalTimeSeconds, equals(60));

      service.recordTime(120);
      expect(service.stats.totalTimeSeconds, equals(180));
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
      expect(service.stats.uniqueFractalsExplored, containsAll(['mandelbrot', 'julia']));
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
