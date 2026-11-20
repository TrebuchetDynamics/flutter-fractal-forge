import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/ui_overlay_capture_harness.dart';

void main() {
  final manifest = jsonDecode(
    File('test/fixtures/ui_overlay_capture_matrix.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  const states = {
    'theme-selector',
    'about-dialog',
    'preset-rename',
    'favorite-rename',
    'save-share',
    'export-options',
    'export-progress',
    'share-preview',
    'share-fallback',
    'video-options',
    'wallpaper-options',
    'looper-ready',
    'text-editor',
    'report-notes',
  };
  final rows = (manifest['rows'] as List).cast<Map<String, dynamic>>().where(
        (row) =>
            states.contains(row['state']) &&
            (row['category'] == 'keyboard' ||
                (row['category'] == 'baseline' &&
                    (row['inputs']['width'] == 375 ||
                        const {
                          'theme-selector',
                          'text-editor',
                          'export-options'
                        }.contains(row['state'])))),
      );
  final expandedRows = [
    ...rows,
    for (final row in rows.where(
        (r) => r['category'] == 'baseline' && r['inputs']['width'] == 375))
      {
        ...row,
        'id': '${row['id']}--large-targets',
        'inputs': {...row['inputs'] as Map, 'large_targets': true}
      },
  ];
  for (final row in expandedRows) {
    testWidgets('enabled action hit edges ${row['id']}', (tester) async {
      await loadOverlayCaptureFonts(tester);
      final result =
          await captureOverlayRow(tester, row, inspectAction: (name, action) {
        final rect = tester.getRect(action);
        final minimum = row['inputs']['large_targets'] == true ? 56 : 48;
        expect(rect.width, greaterThanOrEqualTo(minimum), reason: name);
        expect(rect.height, greaterThanOrEqualTo(minimum), reason: name);
        final target = tester.renderObject(action);
        // These are the input box's edges, including Material's invisible
        // padding, not the inner painted Material or just the text's center.
        for (final point in [
          Offset(rect.left + 1, rect.center.dy),
          Offset(rect.right - 1, rect.center.dy),
          Offset(rect.center.dx, rect.top + 1),
          Offset(rect.center.dx, rect.bottom - 1),
        ]) {
          expect(
              tester
                  .hitTestOnBinding(point)
                  .path
                  .any((entry) => identical(entry.target, target)),
              isTrue,
              reason: '${row['id']} $name input edge $point');
        }
      });
      expect(result.errors, isEmpty);
      expect(result.failures, isEmpty);
      final output = Platform.environment['OVERLAY_HIT_CAPTURE_DIR'];
      if (output != null) {
        final directory = Directory(output)..createSync(recursive: true);
        File('${directory.path}/${row['id']}.png')
            .writeAsBytesSync(result.png!);
        File('${directory.path}/${row['id']}.json').writeAsStringSync(
            const JsonEncoder.withIndent('  ').convert(result.toJson()));
      }
    });
  }
}
