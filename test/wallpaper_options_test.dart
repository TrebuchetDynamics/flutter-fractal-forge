import 'package:flutter_fractals/core/models/wallpaper_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WallpaperTarget contract', () {
    test('options import exposes platform channel target names', () {
      expect(WallpaperTarget.home.name, 'home');
      expect(WallpaperTarget.lock.name, 'lock');
      expect(WallpaperTarget.both.name, 'both');
    });
  });

  group('WallpaperOptions', () {
    test('defaults to home-optimized home wallpaper and saves a local copy',
        () {
      const options = WallpaperOptions();

      expect(options.target, WallpaperTarget.home);
      expect(options.style, WallpaperStyle.homeOptimized);
      expect(options.saveCopy, isTrue);
    });

    test('copyWith replaces provided fields and preserves omitted fields', () {
      const original = WallpaperOptions(
        target: WallpaperTarget.home,
        style: WallpaperStyle.homeOptimized,
      );

      final changed = original.copyWith(
        target: WallpaperTarget.lock,
        style: WallpaperStyle.lockOptimized,
        saveCopy: true,
      );

      expect(changed.target, WallpaperTarget.lock);
      expect(changed.style, WallpaperStyle.lockOptimized);
      expect(changed.saveCopy, isTrue);

      final preserved = changed.copyWith(style: WallpaperStyle.plain);
      expect(preserved.target, WallpaperTarget.lock);
      expect(preserved.style, WallpaperStyle.plain);
      expect(preserved.saveCopy, isTrue);
    });

    test('value equality includes target, style, and saveCopy', () {
      const a = WallpaperOptions(
        target: WallpaperTarget.both,
        style: WallpaperStyle.plain,
        saveCopy: true,
      );
      const b = WallpaperOptions(
        target: WallpaperTarget.both,
        style: WallpaperStyle.plain,
        saveCopy: true,
      );
      const c = WallpaperOptions(
        target: WallpaperTarget.lock,
        style: WallpaperStyle.plain,
        saveCopy: true,
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
