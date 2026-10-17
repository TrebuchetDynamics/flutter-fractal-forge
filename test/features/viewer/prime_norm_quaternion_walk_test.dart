import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_fractals/features/viewer/prime_norm_quaternion_slice.dart';

void main() {
  testWidgets('fixed-d walk and captured PNG are available', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: PrimeNormQuaternionSliceView(onBack: _noop)),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('fixed d=0'), findsOneWidget);
    expect(find.text('Step'), findsOneWidget);
    expect(find.text('Undo step'), findsOneWidget);
    expect(find.text('Reset path'), findsOneWidget);
    expect(find.text('Capture PNG'), findsOneWidget);

    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .descendant(
            of: find.byType(PrimeNormQuaternionSliceView),
            matching: find.byType(RepaintBoundary))
        .first);
    final bytes = await tester.runAsync(() => captureQuaternionPng(boundary));
    expect(bytes, isNotNull);
    final decoded = image.decodePng(bytes!);
    expect(decoded, isNotNull);
    expect(decoded!.width, greaterThan(0));
    expect(decoded.height, greaterThan(0));

    final increase = find.byTooltip('Increase fixed d');
    await tester.tap(increase);
    await tester.tap(increase);
    await tester.pumpAndSettle();
    expect(find.text('d = 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
