import 'dart:io';

import 'package:share_plus/share_plus.dart';

typedef ShareTextCallback = Future<void> Function(
  String text, {
  String? subject,
});

typedef ShareFileCallback = Future<void> Function(
  File file, {
  String? text,
});

/// App-owned boundary around the platform share sheet.
///
/// Keep direct `share_plus` API use here so plugin upgrades only touch one
/// surface. Callers should handle failures according to their UX contract; for
/// example, export save success must remain success even if sharing fails.
class AppShareService {
  const AppShareService();

  Future<void> shareFile(File file, {String? text}) {
    return Share.shareXFiles([XFile(file.path)], text: text);
  }

  Future<void> shareText(String text, {String? subject}) {
    return Share.share(text, subject: subject);
  }
}
