import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_view_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLayout(
    WidgetTester tester, {
    required Size size,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FourierViewLayout(
            spatial: ColoredBox(
              key: ValueKey('spatialFixture'),
              color: Colors.blue,
            ),
            spectrum: ColoredBox(
              key: ValueKey('spectrumFixture'),
              color: Colors.purple,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses stacked labeled panes in portrait', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpLayout(tester, size: const Size(400, 800));

      expect(
          find.byKey(const ValueKey('fourierPortraitSplit')), findsOneWidget);
      expect(find.bySemanticsLabel('Spatial view'), findsOneWidget);
      expect(find.bySemanticsLabel('Fourier magnitude'), findsOneWidget);
      expect(
          tester.getSize(find.byKey(const ValueKey('spatialFixture'))).height,
          closeTo(400, 1));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('uses side-by-side labeled panes in landscape', (tester) async {
    await pumpLayout(tester, size: const Size(800, 400));

    expect(find.byKey(const ValueKey('fourierLandscapeSplit')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('spatialFixture'))).width,
        closeTo(400, 1));
    expect(tester.getSize(find.byKey(const ValueKey('spectrumFixture'))).width,
        closeTo(400, 1));
  });
}
