import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Looper remains GIF-only and the app does not bundle FFmpeg', () {
    final root = Directory.current;
    final files = <String>[
      'pubspec.yaml',
      'pubspec.lock',
      'android/app/proguard-rules.pro',
      'lib/features/looper/looper_sheet.dart',
      'lib/features/viewer/dialogs/viewer_dialogs.dart',
      'lib/features/viewer/export/viewer_export_actions.dart',
    ];

    final source = files
        .map((path) => File('${root.path}/$path').readAsStringSync())
        .join('\n');

    expect(source.toLowerCase(), isNot(contains('ffmpeg')));
    expect(source, isNot(contains('looperExportMp4')));
    expect(source, isNot(contains('onExportMp4')));
    expect(source, contains('looperExportGif'));
  });
}
