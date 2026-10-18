import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/models/prime_norm_quaternion_model.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/gaussian_moat_map.dart';
import 'package:flutter_fractals/features/viewer/prime_norm_quaternion_slice.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Gaussian companion opens, walks, and captures the selected slice',
      (tester) async {
    Uint8List? exportedPng;
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(Provider<ModuleRegistry>.value(
      value: ModuleRegistry(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GaussianMoatMap(
            boundaryKey: boundaryKey,
            onExplore: () {},
            onExport: () {},
            onQuaternionCaptured: (png) async => exportedPng = png,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quaternion slice'));
    await tester.pumpAndSettle();
    expect(find.text('Prime-norm quaternion slice'), findsOneWidget);
    expect(find.textContaining('fixed d=0'), findsOneWidget);

    final canvas = find.byType(CustomPaint).last;
    await tester.drag(canvas, const Offset(36, 18));
    await tester.pump();
    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .descendant(
          of: find.byType(PrimeNormQuaternionSliceView),
          matching: find.byType(RepaintBoundary),
        )
        .first);
    final beforeWalk =
        await tester.runAsync(() => captureQuaternionPng(boundary));
    expect(beforeWalk, isNotNull);
    await tester.ensureVisible(find.text('Coordinate list'));
    await tester.tap(find.text('Coordinate list'));
    await tester.pumpAndSettle();
    final captureButton = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Capture PNG'));
    expect(captureButton.onPressed, isNull);
    expect(
        find.text('Switch to 3D view to capture a plot PNG.'), findsOneWidget);

    final slice = await PrimeNormQuaternionSlice.generate(6, d: 0);
    final start = slice.points.first;
    final next = slice.points.firstWhere(
      (point) => slice.isAdjacent(start, point, 2),
    );
    final norm = next.a * next.a + next.b * next.b + next.c * next.c;
    final row = find.text(
      '(${next.a}, ${next.b}, ${next.c}, ${next.d}) · N=$norm',
    );
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pump();
    expect(find.textContaining('Selected ('), findsOneWidget);
    await tester.ensureVisible(find.text('Step'));
    await tester.tap(find.text('Step'));
    await tester.pump();
    expect(find.textContaining('Walk: 1 steps'), findsOneWidget);

    await tester.ensureVisible(find.text('3D view'));
    await tester.tap(find.text('3D view'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Capture PNG'));
    await tester.tap(find.text('Capture PNG'));
    await tester.pumpAndSettle();
    expect(find.text('Captured fixed-d view as PNG'), findsOneWidget);

    expect(exportedPng, isNotNull);
    final decoded = image.decodePng(exportedPng!);
    expect(decoded, isNotNull);
    expect(decoded!.width, greaterThan(0));
    expect(decoded.height, greaterThan(0));
    var paintedPixels = 0;
    for (var y = 0; y < decoded.height; y += 4) {
      for (var x = 0; x < decoded.width; x += 4) {
        if (decoded.getPixel(x, y).a > 0) paintedPixels++;
      }
    }
    expect(paintedPixels, greaterThan(0),
        reason: 'captured PNG should include the rendered slice');
    expect(_pngPixelsDiffer(beforeWalk!, exportedPng!), isTrue,
        reason: 'the exported frame should reflect the selected walk path');
    expect(tester.takeException(), isNull);
  });
}

bool _pngPixelsDiffer(Uint8List first, Uint8List second) {
  final a = image.decodePng(first)!;
  final b = image.decodePng(second)!;
  if (a.width != b.width || a.height != b.height) return true;
  for (var y = 0; y < a.height; y += 2) {
    for (var x = 0; x < a.width; x += 2) {
      final left = a.getPixel(x, y);
      final right = b.getPixel(x, y);
      if (left.r != right.r ||
          left.g != right.g ||
          left.b != right.b ||
          left.a != right.a) {
        return true;
      }
    }
  }
  return false;
}
