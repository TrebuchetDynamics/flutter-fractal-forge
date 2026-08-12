import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_session.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';

class LooperMp4Execution {
  final int exitCode;
  final String diagnostics;

  const LooperMp4Execution({
    required this.exitCode,
    this.diagnostics = '',
  });
}

class LooperMp4EncodingException implements Exception {
  final String message;
  const LooperMp4EncodingException(this.message);

  @override
  String toString() => 'Looper MP4 encoding failed: $message';
}

typedef LooperMp4Executor = Future<LooperMp4Execution> Function(
  List<String> arguments,
  ExportCancellationToken? token,
);
typedef LooperMp4TempDirectoryFactory = Future<Directory> Function(
  String prefix,
);

class LooperMp4Encoder {
  final LooperMp4Executor _execute;
  final LooperMp4TempDirectoryFactory _createTempDirectory;

  LooperMp4Encoder({
    LooperMp4Executor? execute,
    LooperMp4TempDirectoryFactory? createTempDirectory,
  })  : _execute = execute ?? _executeFfmpegKit,
        _createTempDirectory = createTempDirectory ??
            ((prefix) => Directory.systemTemp.createTemp(prefix));

  Future<Uint8List> encode({
    required List<Uint8List> pngFrames,
    required int fps,
    Uint8List? wavAudio,
    ExportCancellationToken? token,
  }) async {
    token?.throwIfCancelled();
    if (pngFrames.isEmpty) {
      throw const LooperMp4EncodingException('no frames were captured');
    }
    if (fps <= 0) {
      throw const LooperMp4EncodingException('frame rate must be positive');
    }

    final temp = await _createTempDirectory('fractal_looper_mp4_');
    try {
      for (var index = 0; index < pngFrames.length; index++) {
        token?.throwIfCancelled();
        final filename = 'frame_${index.toString().padLeft(6, '0')}.png';
        await File('${temp.path}/$filename').writeAsBytes(pngFrames[index]);
      }
      final audio = wavAudio;
      final arguments = <String>[
        '-y',
        '-framerate',
        '$fps',
        '-i',
        '${temp.path}/frame_%06d.png',
      ];
      if (audio != null && audio.isNotEmpty) {
        final audioPath = '${temp.path}/music.wav';
        await File(audioPath).writeAsBytes(audio);
        arguments.addAll(['-i', audioPath]);
      }
      arguments.addAll([
        '-c:v',
        'mpeg4',
        '-q:v',
        '3',
        // yuv420p chroma subsampling requires even dimensions. Renderer
        // boundaries may legitimately capture an odd logical pixel edge.
        '-vf',
        'pad=ceil(iw/2)*2:ceil(ih/2)*2',
        '-pix_fmt',
        'yuv420p',
        '-movflags',
        '+faststart',
      ]);
      if (audio != null && audio.isNotEmpty) {
        arguments.addAll(['-c:a', 'aac', '-b:a', '160k', '-shortest']);
      }
      final output = '${temp.path}/looper.mp4';
      arguments.add(output);

      final execution = await _execute(arguments, token);
      token?.throwIfCancelled();
      if (execution.exitCode != 0) {
        throw LooperMp4EncodingException(
          execution.diagnostics.trim().isEmpty
              ? 'encoder exited with code ${execution.exitCode}'
              : execution.diagnostics.trim(),
        );
      }
      final file = File(output);
      if (!await file.exists()) {
        throw const LooperMp4EncodingException('encoder produced no output');
      }
      return file.readAsBytes();
    } finally {
      if (await temp.exists()) await temp.delete(recursive: true);
    }
  }
}

Future<LooperMp4Execution> _executeFfmpegKit(
  List<String> arguments,
  ExportCancellationToken? token,
) async {
  final completer = Completer<FFmpegSession>();
  final session = await FFmpegKit.executeWithArgumentsAsync(
    arguments,
    (completed) {
      if (!completer.isCompleted) completer.complete(completed);
    },
  );
  unawaited(token?.whenCancelled.then((_) => session.cancel()));
  final completed = await completer.future;
  final returnCode = await completed.getReturnCode();
  return LooperMp4Execution(
    exitCode: returnCode?.getValue() ?? -1,
    diagnostics: (await completed.getOutput()) ??
        (await completed.getFailStackTrace()) ??
        '',
  );
}
