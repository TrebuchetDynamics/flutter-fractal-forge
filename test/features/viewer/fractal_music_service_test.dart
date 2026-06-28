import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProcess implements Process {
  _FakeProcess(this.code);

  final int code;

  @override
  Future<int> get exitCode => Future.value(code);

  @override
  int get pid => 1234;

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildFractalMusicWav writes deterministic wav audio', () {
    final a = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120, 'colorScheme': 2},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'colorScheme': 2, 'iterations': 120},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final c = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120, 'colorScheme': 2},
      panX: 0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(String.fromCharCodes(a.take(4)), 'RIFF');
    expect(String.fromCharCodes(a.skip(8).take(4)), 'WAVE');
    expect(a.length, 44 + 8000 * 2);
    expect(a, b);
    expect(a, isNot(c));
  });

  test('play reports missing Linux audio players before starting playback',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final service = FractalMusicService(commandExists: (_) async => false);
    addTearDown(service.dispose);

    await expectLater(
      service.play(controller),
      throwsA(isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('No Linux audio player'),
      )),
    );
  });

  test('play reports audio device failure and cleans generated temp audio',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    Directory? createdDir;
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        createdDir = await tempRoot.createTemp(prefix);
        return createdDir!;
      },
      startProcess: (_, __) async => _FakeProcess(1),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.play(controller),
      throwsA(isA<StateError>().having(
        (error) => error.message,
        'message',
        contains('audio playback failed'),
      )),
    );

    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
  });

  test('web play sends generated wav bytes to browser audio player', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final calls = <String>[];
    Uint8List? playedBytes;
    final service = FractalMusicService(
      isWeb: true,
      isAndroid: false,
      isLinux: false,
      webPlay: (bytes) async {
        calls.add('play');
        playedBytes = bytes;
        return true;
      },
      webStop: () async => calls.add('stop'),
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();

    expect(calls, ['stop', 'play', 'stop']);
    expect(String.fromCharCodes(playedBytes!.take(4)), 'RIFF');
  });

  test('Android play sends generated wav bytes to the native audio channel',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    const channel = MethodChannel('test/fractal_music');
    final calls = <String>[];
    Uint8List? playedBytes;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'play') {
        playedBytes = (call.arguments as Map)['bytes'] as Uint8List;
        return true;
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final service = FractalMusicService(
      androidChannel: channel,
      isAndroid: true,
      isLinux: false,
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();

    expect(calls, ['stop', 'play', 'stop']);
    expect(String.fromCharCodes(playedBytes!.take(4)), 'RIFF');
  });

  test('play creates unique temp directories for separate sessions', () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final tempRoot = Directory.systemTemp.createTempSync('fractal_music_test_');
    addTearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });
    final created = <String>[];
    final service = FractalMusicService(
      commandExists: (_) async => true,
      createTempDir: (prefix) async {
        final dir = await tempRoot.createTemp(prefix);
        created.add(dir.path);
        return dir;
      },
      startProcess: (_, __) async => _FakeProcess(-1),
    );
    addTearDown(service.dispose);

    await service.play(controller);
    await service.stop();
    await service.play(controller);
    await service.stop();

    expect(created, hasLength(2));
    expect(created.toSet(), hasLength(2));
  });
}
