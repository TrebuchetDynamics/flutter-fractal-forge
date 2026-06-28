import 'dart:html' as html;
import 'dart:typed_data';

html.AudioElement? _audio;
String? _objectUrl;

Future<bool> playFractalMusicWeb(Uint8List bytes) async {
  await stopFractalMusicWeb();
  final blob = html.Blob([bytes], 'audio/wav');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final audio = html.AudioElement(url)..loop = true;
  _objectUrl = url;
  _audio = audio;
  try {
    await audio.play();
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
    html.Url.revokeObjectUrl(url);
  }
}
