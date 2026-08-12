import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/looper_mp4_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encodes ordered PNG frames and optional WAV into a real MP4 command',
      () async {
    late List<String> arguments;
    final encoder = LooperMp4Encoder(
      createTempDirectory: (prefix) =>
          Directory.systemTemp.createTemp('looper_mp4_test_'),
      execute: (args, _) async {
        arguments = List.of(args);
        final output = File(args.last);
        await output.writeAsBytes(const [0, 0, 0, 24, 102, 116, 121, 112]);
        return const LooperMp4Execution(exitCode: 0);
      },
    );

    final bytes = await encoder.encode(
      pngFrames: [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ],
      fps: 8,
      wavAudio: Uint8List.fromList([82, 73, 70, 70]),
    );

    expect(
        arguments,
        containsAllInOrder([
          '-framerate',
          '8',
          '-i',
          contains('frame_%06d.png'),
          '-i',
          contains('music.wav'),
        ]));
    expect(
        arguments, containsAll(['-c:v', 'mpeg4', '-c:a', 'aac', '-shortest']));
    expect(
      arguments,
      containsAllInOrder([
        '-vf',
        'pad=ceil(iw/2)*2:ceil(ih/2)*2',
        '-pix_fmt',
        'yuv420p',
      ]),
      reason: 'yuv420p rejects odd-width or odd-height renderer captures',
    );
    expect(bytes.sublist(4, 8), [102, 116, 121, 112]);
  });

  test('cancellation reaches the active encoder and removes temporary files',
      () async {
    Directory? temp;
    final token = ExportCancellationToken();
    final encoderStarted = Completer<void>();
    final encoder = LooperMp4Encoder(
      createTempDirectory: (prefix) async {
        temp = await Directory.systemTemp.createTemp('looper_mp4_test_');
        return temp!;
      },
      execute: (_, activeToken) async {
        encoderStarted.complete();
        await activeToken!.whenCancelled;
        throw const ExportCancelledException();
      },
    );

    final future = encoder.encode(
      pngFrames: [
        Uint8List.fromList([1])
      ],
      fps: 8,
      token: token,
    );
    await encoderStarted.future;
    token.cancel();

    await expectLater(future, throwsA(isA<ExportCancelledException>()));
    expect(temp!.existsSync(), isFalse);
  });

  test('cancelled token deletes a file persisted during cancellation',
      () async {
    final temp = await Directory.systemTemp.createTemp('cancelled_export_');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });
    final file = File('${temp.path}/orphan.mp4');
    await file.writeAsBytes([1, 2, 3]);
    final token = ExportCancellationToken()..cancel();

    await expectLater(
      token.retainSavedFileUnlessCancelled(file),
      throwsA(isA<ExportCancelledException>()),
    );
    expect(file.existsSync(), isFalse);
  });

  test('reports encoder diagnostics and always removes temporary files',
      () async {
    Directory? temp;
    final encoder = LooperMp4Encoder(
      createTempDirectory: (prefix) async {
        temp = await Directory.systemTemp.createTemp('looper_mp4_test_');
        return temp!;
      },
      execute: (arguments, token) async => const LooperMp4Execution(
        exitCode: 1,
        diagnostics: 'codec unavailable',
      ),
    );

    await expectLater(
      encoder.encode(
        pngFrames: [
          Uint8List.fromList([1])
        ],
        fps: 8,
      ),
      throwsA(isA<LooperMp4EncodingException>().having(
        (error) => error.toString(),
        'message',
        contains('codec unavailable'),
      )),
    );
    expect(temp!.existsSync(), isFalse);
  });
}
