part of 'fractal_music_service.dart';

abstract class _FractalMusicPlaybackAdapter {
  const _FractalMusicPlaybackAdapter();

  Future<void> play(
    Uint8List bytes, {
    bool Function()? shouldCommit,
    Future<void> Function()? beforePublish,
  });
  Future<void> cancelPending();
  Future<void> stop();

  void dispose() {
    unawaited(stop());
  }

  factory _FractalMusicPlaybackAdapter.forPlatform({
    required Future<bool> Function(String command)? commandExists,
    required FractalMusicProcessStart? startProcess,
    required FractalMusicTempDirFactory? createTempDir,
    required MethodChannel androidChannel,
    required FractalMusicWebPlay webPlay,
    required FractalMusicWebStop webStop,
    required FractalMusicWebCancelPending webCancelPending,
    required bool? isWeb,
    required bool? isAndroid,
    required bool? isLinux,
  }) {
    final web = isWeb ?? kIsWeb;
    if (web) {
      return _WebFractalMusicPlayer(webPlay, webStop, webCancelPending);
    }

    final android = isAndroid ?? Platform.isAndroid;
    if (android) return _AndroidFractalMusicPlayer(androidChannel);

    final linux = isLinux ?? Platform.isLinux;
    if (linux) {
      return _LinuxFractalMusicPlayer(
        commandExists: commandExists,
        startProcess: startProcess,
        createTempDir: createTempDir,
      );
    }

    return _UnsupportedFractalMusicPlayer();
  }
}

class _WebFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  final FractalMusicWebPlay _play;
  final FractalMusicWebStop _stop;
  final FractalMusicWebCancelPending _cancelPending;
  bool _playing = false;

  _WebFractalMusicPlayer(this._play, this._stop, this._cancelPending);

  @override
  Future<void> play(
    Uint8List bytes, {
    bool Function()? shouldCommit,
    Future<void> Function()? beforePublish,
  }) async {
    if (beforePublish != null) await beforePublish();
    if (shouldCommit != null && !shouldCommit()) return;
    final ok = await _play(bytes);
    if (!ok) {
      if (shouldCommit != null && !shouldCommit()) return;
      throw StateError(
          'Web audio playback failed; tap the music button again.');
    }
    _playing = true;
  }

  @override
  Future<void> cancelPending() => _cancelPending();

  @override
  Future<void> stop() async {
    if (!_playing) {
      await _stop();
      return;
    }
    _playing = false;
    await _stop();
  }
}

class _AndroidFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  final MethodChannel _channel;
  bool _playing = false;

  _AndroidFractalMusicPlayer(this._channel);

  @override
  Future<void> play(
    Uint8List bytes, {
    bool Function()? shouldCommit,
    Future<void> Function()? beforePublish,
  }) async {
    if (beforePublish != null) await beforePublish();
    if (shouldCommit != null && !shouldCommit()) return;
    final ok = await _channel.invokeMethod<bool>('play', {'bytes': bytes});
    if (ok != true) {
      if (shouldCommit != null && !shouldCommit()) return;
      throw StateError('Android audio playback failed; check audio device.');
    }
    _playing = true;
  }

  @override
  Future<void> cancelPending() => _channel.invokeMethod<void>('cancelPending');

  @override
  Future<void> stop() async {
    if (!_playing) {
      await _channel.invokeMethod<void>('stop');
      return;
    }
    _playing = false;
    await _channel.invokeMethod<void>('stop');
  }
}

class _LinuxFractalMusicPlayer implements _FractalMusicPlaybackAdapter {
  final Future<bool> Function(String command)? _commandExistsOverride;
  final FractalMusicProcessStart _startProcess;
  final FractalMusicTempDirFactory _createTempDir;
  Process? _player;
  File? _wavFile;
  int _generation = 0;

  _LinuxFractalMusicPlayer({
    required Future<bool> Function(String command)? commandExists,
    required FractalMusicProcessStart? startProcess,
    required FractalMusicTempDirFactory? createTempDir,
  })  : _commandExistsOverride = commandExists,
        _startProcess = startProcess ??
            ((executable, arguments) => Process.start(executable, arguments)),
        _createTempDir = createTempDir ??
            ((prefix) => Directory.systemTemp.createTemp(prefix));

  Future<void> ensurePlayerAvailable() async {
    if (!await _commandExists('paplay') && !await _commandExists('aplay')) {
      throw StateError('No Linux audio player found (paplay or aplay).');
    }
  }

  @override
  Future<void> play(
    Uint8List bytes, {
    bool Function()? shouldCommit,
    Future<void> Function()? beforePublish,
  }) async {
    final request = ++_generation;
    final dir = await _createTempDir('fractal_music_');
    final file = File('${dir.path}/loop.wav');
    try {
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      await _deleteAudioFile(file);
      rethrow;
    }

    if (request != _generation || (shouldCommit != null && !shouldCommit())) {
      await _deleteAudioFile(file);
      return;
    }

    if (beforePublish != null) await beforePublish();
    if (request != _generation || (shouldCommit != null && !shouldCommit())) {
      await _deleteAudioFile(file);
      return;
    }

    // paplay/aplay cannot preload a paused buffer. Start the candidate while the
    // old loop still owns playback, then revalidate the generation before the
    // synchronous ownership handoff. A canceled Process.start result is killed
    // without touching the old loop.
    final Process player;
    try {
      player = await _startProcess('sh', [
        '-c',
        'child=; cleanup() { status=\$?; [ -n "\$child" ] && kill "\$child" 2>/dev/null; exit "\$status"; }; trap cleanup TERM INT EXIT; while true; do (paplay "\$1" 2>/dev/null || aplay "\$1" 2>/dev/null) & child=\$!; wait "\$child" || exit 1; child=; done',
        'fractal-music',
        file.path,
      ]);
    } catch (_) {
      await _deleteAudioFile(file);
      rethrow;
    }
    if (request != _generation || (shouldCommit != null && !shouldCommit())) {
      player.kill();
      await _deleteAudioFile(file);
      return;
    }

    final previousPlayer = _player;
    final previousFile = _wavFile;
    if (previousPlayer != null && !previousPlayer.kill()) {
      player.kill();
      await _deleteAudioFile(file);
      throw FractalMusicStopFailure(
        StateError('Linux audio player could not be stopped.'),
      );
    }
    // No await is allowed between the final guard above and publication.
    _player = player;
    _wavFile = file;
    if (previousFile != null) await _deleteAudioFile(previousFile);

    final int earlyExitCode;
    try {
      earlyExitCode = await player.exitCode.timeout(
        const Duration(milliseconds: 250),
        onTimeout: () => -1,
      );
    } catch (_) {
      final stale =
          request != _generation || (shouldCommit != null && !shouldCommit());
      if (stale && identical(_player, player)) {
        // The candidate committed before cancellation. Keep the audible owner
        // alive while the queued replacement composes.
        return;
      }
      player.kill();
      _clearOwnership(player, file);
      await _deleteAudioFile(file);
      if (stale) return;
      rethrow;
    }
    final stale =
        request != _generation || (shouldCommit != null && !shouldCommit());
    if (stale) {
      if (earlyExitCode == -1 && identical(_player, player)) {
        // A healthy, published candidate is current playback even though its
        // caller was superseded. cancelPending must not turn that into silence.
        return;
      }
      player.kill();
      _clearOwnership(player, file);
      await _deleteAudioFile(file);
      return;
    }
    if (earlyExitCode != -1) {
      _clearOwnership(player, file);
      await _deleteAudioFile(file);
      throw StateError('Linux audio playback failed; check audio device.');
    }
  }

  @override
  Future<void> cancelPending() async {
    _generation++;
  }

  @override
  Future<void> stop() async {
    _generation++;
    final player = _player;
    _player = null;
    Object? killError;
    StackTrace? killStackTrace;
    try {
      if (player != null && !player.kill()) {
        throw StateError('Linux audio player could not be stopped.');
      }
    } catch (error, stackTrace) {
      killError = error;
      killStackTrace = stackTrace;
    }
    await _deleteTempAudio();
    if (killError != null) {
      Error.throwWithStackTrace(killError, killStackTrace!);
    }
  }

  @override
  void dispose() {
    _generation++;
    final player = _player;
    _player = null;
    try {
      player?.kill();
    } catch (_) {
      // Player shutdown is best-effort during synchronous disposal.
    }
    try {
      final file = _wavFile;
      if (file != null) {
        final parent = file.parent;
        if (parent.existsSync()) parent.deleteSync(recursive: true);
      }
    } catch (_) {
      // Temp cleanup best-effort only.
    }
    _wavFile = null;
  }

  void _clearOwnership(Process player, File file) {
    if (identical(_player, player)) _player = null;
    if (identical(_wavFile, file)) _wavFile = null;
  }

  Future<void> _deleteTempAudio() async {
    final file = _wavFile;
    _wavFile = null;
    if (file != null) await _deleteAudioFile(file);
  }

  Future<void> _deleteAudioFile(File file) async {
    try {
      final parent = file.parent;
      if (await parent.exists()) await parent.delete(recursive: true);
    } catch (_) {
      // Temp cleanup best-effort only.
    }
  }

  Future<bool> _commandExists(String command) async {
    final override = _commandExistsOverride;
    if (override != null) return override(command);

    final result = await Process.run('sh', [
      '-c',
      'command -v "$command" >/dev/null 2>&1',
    ]);
    return result.exitCode == 0;
  }
}

class _UnsupportedFractalMusicPlayer extends _FractalMusicPlaybackAdapter {
  @override
  Future<void> play(
    Uint8List bytes, {
    bool Function()? shouldCommit,
    Future<void> Function()? beforePublish,
  }) async {
    throw StateError(
        'Fractal Music playback is supported on Web, Android, and Linux.');
  }

  @override
  Future<void> cancelPending() async {}

  @override
  Future<void> stop() async {}
}
