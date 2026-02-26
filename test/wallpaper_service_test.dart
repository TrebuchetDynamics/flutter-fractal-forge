import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/wallpaper_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WallpaperTarget', () {
    test('enum has expected values', () {
      expect(WallpaperTarget.values.length, 3);
      expect(WallpaperTarget.values, contains(WallpaperTarget.home));
      expect(WallpaperTarget.values, contains(WallpaperTarget.lock));
      expect(WallpaperTarget.values, contains(WallpaperTarget.both));
    });

    test('name returns correct string for each target', () {
      expect(WallpaperTarget.home.name, 'home');
      expect(WallpaperTarget.lock.name, 'lock');
      expect(WallpaperTarget.both.name, 'both');
    });
  });

  group('WallpaperService construction', () {
    test('can be constructed with const constructor', () {
      const service = WallpaperService();
      expect(service, isA<WallpaperService>());
    });

    test('multiple instances are equal via const identity', () {
      const a = WallpaperService();
      const b = WallpaperService();
      // Both are const instances; no state difference expected
      expect(identical(a, b), isTrue);
    });
  });

  group('WallpaperService.setWallpaper – channel mocked (Android path)', () {
    const channel = MethodChannel('com.fractalforge/wallpaper');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        if (call.method == 'setWallpaper') return true;
        if (call.method == 'saveToPhotos') return true;
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('setWallpaper invokes channel with correct method name', () async {
      const service = WallpaperService();
      final bytes = Uint8List.fromList([0, 1, 2, 3]);

      final result = await service.setWallpaper(
        bytes,
        target: WallpaperTarget.home,
      );

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, 'setWallpaper');
    });

    test('setWallpaper passes bytes argument to channel', () async {
      const service = WallpaperService();
      final bytes = Uint8List.fromList([10, 20, 30]);

      await service.setWallpaper(bytes, target: WallpaperTarget.home);

      final args = log.first.arguments as Map;
      expect(args['bytes'], bytes);
    });

    test('setWallpaper passes target.name to channel', () async {
      const service = WallpaperService();
      final bytes = Uint8List.fromList([1]);

      await service.setWallpaper(bytes, target: WallpaperTarget.lock);
      expect((log.first.arguments as Map)['target'], 'lock');

      log.clear();

      await service.setWallpaper(bytes, target: WallpaperTarget.both);
      expect((log.first.arguments as Map)['target'], 'both');
    });

    test('setWallpaper returns false when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      const service = WallpaperService();
      final result = await service.setWallpaper(
        Uint8List.fromList([0]),
        target: WallpaperTarget.home,
      );

      expect(result, isFalse);
    });

    test('saveToPhotos invokes channel with correct method name', () async {
      const service = WallpaperService();
      final bytes = Uint8List.fromList([5, 6, 7]);

      final result = await service.saveToPhotos(bytes);

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, 'saveToPhotos');
    });

    test('saveToPhotos passes bytes argument to channel', () async {
      const service = WallpaperService();
      final bytes = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);

      await service.saveToPhotos(bytes);

      final args = log.first.arguments as Map;
      expect(args['bytes'], bytes);
    });

    test('saveToPhotos returns false when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      const service = WallpaperService();
      final result = await service.saveToPhotos(Uint8List.fromList([0]));

      expect(result, isFalse);
    });
  });

  group('WallpaperService – channel propagates exceptions', () {
    const channel = MethodChannel('com.fractalforge/wallpaper');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'PERMISSION_DENIED', message: 'denied');
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('setWallpaper surfaces PlatformException from channel', () async {
      const service = WallpaperService();
      expect(
        () => service.setWallpaper(
          Uint8List.fromList([0]),
          target: WallpaperTarget.home,
        ),
        throwsA(isA<PlatformException>()),
      );
    });

    test('saveToPhotos surfaces PlatformException from channel', () async {
      const service = WallpaperService();
      expect(
        () => service.saveToPhotos(Uint8List.fromList([0])),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
