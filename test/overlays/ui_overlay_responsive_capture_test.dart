import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../helpers/overflow_guard.dart';
import '../helpers/ui_overlay_capture_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = jsonDecode(
    File('test/fixtures/ui_overlay_capture_matrix.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final rows = (manifest['rows'] as List).cast<Map<String, dynamic>>();

  test('schema1 inventory expands to exactly 119 component and 84 browser rows',
      () {
    expect(validateOverlayMatrix(manifest), isEmpty);
    expect(rows, hasLength(119));
    for (var index = 0; index < rows.length; index++) {
      final missing = jsonDecode(jsonEncode(manifest)) as Map<String, dynamic>;
      (missing['rows'] as List).removeAt(index);
      expect(validateOverlayMatrix(missing),
          contains('missing row ${rows[index]['id']}'));
    }
    final changed = jsonDecode(jsonEncode(manifest)) as Map<String, dynamic>;
    changed['rows'][0]['inputs']['text_scale'] = 3;
    expect(validateOverlayMatrix(changed), isNotEmpty);
  });

  test('missing row, PNG, measurement, overflow and error cannot pass', () {
    final row = rows.first;
    final result = OverlayCaptureResult(row);
    expect(result.failures, contains('image: NOT_RUN'));
    expect(result.failures, contains('measurements: NOT_RUN'));
    expect(overlayAuditFailures(rows, [result]),
        contains(contains('missing row')));
    result.png = img.encodePng(img.Image(width: 375, height: 667));
    result.measurements = validOverlayMeasurementsForGuardTest();
    expect(result.failures, isEmpty);
    result.errors.add('RenderFlex overflowed by 24 pixels');
    expect(result.failures, contains(contains('overflowed')));
    result.errors.clear();
    result.measurements!['overlay'] = null;
    expect(result.failures, contains(contains('overlay')));
    result.measurements = validOverlayMeasurementsForGuardTest();
    result.measurements!['actions'] = [];
    expect(result.failures, contains(contains('actions')));
    result.measurements = validOverlayMeasurementsForGuardTest();
    result.png = img.encodePng(img.Image(width: 1, height: 1));
    expect(result.failures, contains(contains('pixel size')));
  });

  testWidgets(
      'outer boundary includes modal and controlled progress cancellation',
      (tester) async {
    await loadOverlayCaptureFonts(tester);
    final row = rows
        .singleWhere((r) => r['id'] == 'export-progress--baseline--375x667');
    final result = await captureOverlayRow(tester, row);
    // A measurement audit may expose shipping target-size defects. This smoke
    // checks the capture/cancellation seam, not a fabricated layout pass.
    expect(result.errors, isEmpty);
    expect(result.measurements, isNotNull);
    expect(result.png, isNotEmpty);
  });

  testWidgets('modal preview is decoded and inside the outer capture boundary',
      (tester) async {
    await loadOverlayCaptureFonts(tester);
    final row =
        rows.singleWhere((r) => r['id'] == 'share-preview--baseline--375x667');
    final result = await captureOverlayRow(tester, row);
    expect(result.errors, isEmpty);
    expect(result.measurements!['decoded_preview_size'], [64, 32]);
    final image = img.decodePng(result.png!)!;
    final overlay = result.measurements!['overlay'] as List;
    final pixel = image.getPixel(30, (overlay[1] as num).toInt() + 80);
    expect(pixel.r + pixel.g + pixel.b, greaterThan(0),
        reason: 'A body-only black placeholder capture would miss the modal');
  });

  testWidgets('history measures its heading and uses a fixed sample date',
      (tester) async {
    await loadOverlayCaptureFonts(tester);
    final row = rows
        .singleWhere((r) => r['id'] == 'history-populated--baseline--375x667');
    final result = await captureOverlayRow(tester, row);
    expect(result.errors, isEmpty);
    final measurements = result.measurements!;
    final title = measurements['title'] as List;
    final action = (measurements['actions'] as List).single['rect'] as List;
    expect(title[1], lessThan(action[3]),
        reason: 'Measure the header beside Save favorite, not the History tab');
    expect(measurements['semantics'], contains('Jan 1 00:00'));
  });

  testWidgets('resolved theme styles use loaded fonts, not Ahem fallback',
      (tester) async {
    await loadOverlayCaptureFonts(tester);
    final row =
        rows.singleWhere((r) => r['id'] == 'export-options--oled--375x667');
    final result = await captureOverlayRow(tester, row);
    expect(result.errors, isEmpty);
    expect(result.measurements!['font_families'], isNotEmpty);
    expect(result.measurements!['theme']['requested'], 'oled');
  });

  testWidgets('real Flutter overflow is retained as a nonpassing result',
      (tester) async {
    final result = OverlayCaptureResult(rows.first);
    try {
      await expectNoOverflow(() async {
        await tester.pumpWidget(
            const MaterialApp(home: Row(children: [SizedBox(width: 5000)])));
      });
    } catch (error) {
      result.errors.add(error.toString());
    }
    expect(result.errors, isNotEmpty);
    expect(result.failures, contains(contains('overflowed')));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'setup failure retains the requested row with no fabricated evidence',
      (tester) async {
    final row = rows
        .singleWhere((r) => r['id'] == 'batch-selection--baseline--375x667');
    final result = await captureOverlayRow(tester, row);
    expect(result.png, isNull);
    expect(result.measurements, isNull);
    expect(result.errors,
        contains(contains('no shipping selection widget/launcher')));
    expect(overlayAuditFailures([row], [result]), isNotEmpty);
  });

  test('capture destination refuses relative paths and checkout outputs', () {
    expect(
        () => validateOverlayCaptureDirectory('captures'), throwsArgumentError);
    expect(() => validateOverlayCaptureDirectory(Directory.current.path),
        throwsArgumentError);
  });

  const output = String.fromEnvironment('UI_OVERLAY_CAPTURE_DIR');
  if (output.isNotEmpty) {
    testWidgets('explicit complete component capture audit', (tester) async {
      final directory = validateOverlayCaptureDirectory(output);
      final fonts = await loadOverlayCaptureFonts(tester);
      final results = <OverlayCaptureResult>[];
      final identity = await overlayCaptureIdentity(tester, fonts);
      // Never stop at the first layout failure: every requested row gets a result.
      for (final row in rows) {
        results.add(await captureOverlayRow(tester, row));
        await writeOverlayCaptureReport(directory, manifest, results, identity);
      }
      final failures = overlayAuditFailures(rows, results);
      expect(failures, isEmpty,
          reason: 'Complete audit retained at ${directory.path}/report.md. '
              'File UI follow-ups; do not omit rows or bless failed geometry.');
    }, timeout: const Timeout(Duration(minutes: 15)));
  }
}

Map<String, dynamic> validOverlayMeasurementsForGuardTest() => {
      'surface_visible': true,
      'overlay': [0, 100, 375, 667],
      'title': [24, 124, 300, 160],
      'content_viewports': <List<double>>[],
      'scroll_extents': <Map<String, dynamic>>[],
      'viewport': {
        'width': 375,
        'height': 667,
        'dpr': 1,
        'text_scale': 1,
        'view_insets_bottom': 0,
        'disable_animations': true,
        'padding': [0, 0, 0, 0],
        'locale': 'en',
        'platform': 'linux',
      },
      'semantics': 'Close',
      'font_families': ['Roboto'],
      'theme': {
        'requested': 'dark',
        'surface': 0,
        'primary': 0,
        'scaffold_background': 0
      },
      'actions': [
        {
          'name': 'Close',
          'rect': [300, 120, 348, 168],
          'reachable': true,
          'hit_testable': true
        },
      ],
    };
