import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

void downloadExportBytes(
  Uint8List bytes, {
  required String filename,
  required String mimeType,
}) {
  final blob = Blob(
    [bytes.buffer.toJS].toJS,
    BlobPropertyBag()..type = mimeType,
  );
  final url = URL.createObjectURL(blob);
  final anchor = document.createElement('a') as HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  document.body!.children.add(anchor);
  anchor.click();
  anchor.remove();
}
