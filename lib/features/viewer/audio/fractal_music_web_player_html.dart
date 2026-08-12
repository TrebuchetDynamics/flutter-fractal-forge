import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

web.HTMLAudioElement? _audio;
String? _objectUrl;
int _playbackGeneration = 0;

Future<bool> playFractalMusicWeb(Uint8List bytes) async {
  final generation = ++_playbackGeneration;
  final previousAudio = _audio;
  final previousUrl = _objectUrl;
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'audio/wav'),
  );
  final url = web.URL.createObjectURL(blob);
  final audio = web.HTMLAudioElement()
    ..src = url
    ..loop = true;
  try {
    // Decode and start the replacement before retiring the current element.
    // This avoids an audible stop/decode/play hole during view rescans.
    await audio.play().toDart;
    if (generation != _playbackGeneration) {
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
      web.URL.revokeObjectURL(url);
      return false;
    }
    _audio = audio;
    _objectUrl = url;
    if (previousAudio != null) {
      previousAudio.pause();
      previousAudio.removeAttribute('src');
      previousAudio.load();
    }
    if (previousUrl != null) web.URL.revokeObjectURL(previousUrl);
    return true;
  } catch (_) {
    audio.pause();
    audio.removeAttribute('src');
    audio.load();
    web.URL.revokeObjectURL(url);
    return false;
  }
}

Future<void> stopFractalMusicWeb() async {
  _playbackGeneration++;
  final audio = _audio;
  _audio = null;
  if (audio != null) {
    audio.pause();
    audio.removeAttribute('src');
    audio.load();
  }
  final url = _objectUrl;
  _objectUrl = null;
  if (url != null) {
    web.URL.revokeObjectURL(url);
  }
}

/// Invalidates only a candidate that is decoding or starting. The currently
/// audible element remains untouched until a newer candidate commits.
Future<void> cancelPendingFractalMusicWeb() async {
  _playbackGeneration++;
}
