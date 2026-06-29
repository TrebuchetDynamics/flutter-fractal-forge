import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_test/flutter_test.dart';

bool _pcmHasSignal(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  for (var offset = 44; offset + 1 < wav.length; offset += 2) {
    if (data.getInt16(offset, Endian.little) != 0) return true;
  }
  return false;
}

int _pcmSample(Uint8List wav, int sampleIndex) =>
    ByteData.sublistView(wav).getInt16(44 + sampleIndex * 2, Endian.little);

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

  test('buildFractalMusicWav handles short loops below step count', () {
    final wav = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {},
      panX: 0,
      panY: 0,
      zoom: 1,
      sampleRate: 8,
      seconds: 1,
    );

    expect(String.fromCharCodes(wav.take(4)), 'RIFF');
    expect(wav.length, 44 + 8 * 2);
    expect(_pcmHasSignal(wav), isTrue);
  });

  test('generated loops start and end silent to avoid loop clicks', () {
    final stateLoop = buildFractalMusicWav(
      moduleId: 'mandelbrot',
      params: const {'iterations': 120},
      panX: -0.5,
      panY: 0.1,
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );
    final scanLoop = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(
        rgba: Uint8List.fromList(List.filled(8 * 8 * 4, 180)),
        width: 8,
        height: 8,
      ),
      zoom: 3,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(_pcmSample(stateLoop, 0), 0);
    expect(_pcmSample(stateLoop, 7999), 0);
    expect(_pcmSample(scanLoop, 0), 0);
    expect(_pcmSample(scanLoop, 7999), 0);
  });

  test('buildFractalMusicScanWav leaves empty space silent', () {
    final dark = Uint8List(4 * 4 * 4);
    final bright = Uint8List.fromList(List.filled(4 * 4 * 4, 255));

    final a = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: dark, width: 4, height: 4),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: bright, width: 4, height: 4),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(String.fromCharCodes(a.take(4)), 'RIFF');
    expect(a.length, 44 + 8000 * 2);
    expect(_pcmHasSignal(a), isFalse);
    expect(_pcmHasSignal(b), isTrue);
  });

  test('scan profile follows the scanner cross-section angle', () {
    final frame = Uint8List(11 * 11 * 4);
    for (var x = 5; x < 11; x++) {
      final offset = (5 * 11 + x) * 4;
      frame[offset] = 255;
      frame[offset + 1] = 255;
      frame[offset + 2] = 255;
      frame[offset + 3] = 255;
    }

    final right = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 11, height: 11),
      step: 8,
      steps: 32,
    );
    final up = debugFractalMusicScanProfile(
      scanFrame: FractalMusicScanFrame(rgba: frame, width: 11, height: 11),
      step: 0,
      steps: 32,
    );

    expect(right.brightness, greaterThan(0.4));
    expect(up.brightness, lessThan(0.2));
  });

  test('buildFractalMusicScanWav samples to the visible edge on wide views',
      () {
    final dark = Uint8List(100 * 11 * 4);
    final edgeBright = Uint8List(100 * 11 * 4);
    for (var y = 0; y < 11; y++) {
      for (var x = 80; x < 100; x++) {
        final offset = (y * 100 + x) * 4;
        edgeBright[offset] = 255;
        edgeBright[offset + 1] = 255;
        edgeBright[offset + 2] = 255;
        edgeBright[offset + 3] = 255;
      }
    }

    final a = buildFractalMusicScanWav(
      scanFrame: FractalMusicScanFrame(rgba: dark, width: 100, height: 11),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );
    final b = buildFractalMusicScanWav(
      scanFrame:
          FractalMusicScanFrame(rgba: edgeBright, width: 100, height: 11),
      zoom: 1,
      sampleRate: 8000,
      seconds: 1,
    );

    expect(a, isNot(b));
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

  test('play cleans temp audio when Linux player process cannot start',
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
      startProcess: (_, __) async => throw StateError('cannot start player'),
    );
    addTearDown(service.dispose);

    await expectLater(service.play(controller), throwsStateError);

    expect(createdDir, isNotNull);
    expect(createdDir!.existsSync(), isFalse);
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
