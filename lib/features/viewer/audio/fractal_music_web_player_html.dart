import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

web.HTMLAudioElement? _audio;
String? _objectUrl;

Future<bool> playFractalMusicWeb(Uint8List bytes) async {
  await stopFractalMusicWeb();
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'audio/wav'),
  );
  final url = web.URL.createObjectURL(blob);
  final audio = web.HTMLAudioElement()
    ..src = url
    ..loop = true;
  _objectUrl = url;
  _audio = audio;
  try {
    await audio.play().toDart;
    return true;
  } catch (_) {
    await stopFractalMusicWeb();
    return false;
  }
}

Future<void> stopFractalMusicWeb() async {
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
