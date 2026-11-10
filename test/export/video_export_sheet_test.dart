import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/video_export_options.dart';
import 'package:flutter_fractals/features/export/video_export_sheet.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('short large-text video sheet scrolls and closes before export',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const options = VideoExportOptions();
    VideoExportOptions? exported;
    var routeClosedAtExport = false;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(3),
          viewPadding: const EdgeInsets.only(bottom: 24),
        ),
        child: child!,
      ),
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () => showAppBottomSheet<void>(
                      context: context,
                      builder: (sheetContext) => VideoExportSheet(
                        initialOptions: options,
                        fractalType: 'mandelbrot',
                        availableParameters: const [],
                        parameterRanges: const {},
                        onExport: (value) {
                          exported = value;
                          routeClosedAtExport =
                              !ModalRoute.of(sheetContext)!.isCurrent;
                        },
                      ),
                    ),
                    child: const Text('Open'),
                  ))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final export = find.widgetWithText(ElevatedButton, 'Export');
    await tester.ensureVisible(export);
    await tester.pumpAndSettle();
    expect(tester.getRect(export).bottom, lessThanOrEqualTo(216));
    await tester.tap(export);
    await tester.pumpAndSettle();
    expect(exported, same(options));
    expect(routeClosedAtExport, isTrue);
    expect(find.byType(BottomSheet), findsNothing);
  });
}
