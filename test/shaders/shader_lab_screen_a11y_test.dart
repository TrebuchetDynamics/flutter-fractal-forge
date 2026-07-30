import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/debug/shader_lab_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../a11y/semantics/interactive_name_audit.dart';
import '../helpers/overflow_guard.dart';

Future<void> _pumpLab(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const ShaderLabScreen(),
    ),
  );
  // initState schedules the FragmentProgram load behind a 400ms delay. The
  // clock has to clear it, or the test ends with a pending timer; loading the
  // shader asset fails under test, which exercises the error branch of the
  // status line.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

void main() {
  group('ShaderLabScreen accessibility', () {
    testWidgets('its control is named', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpLab(tester);
      final root = semanticsRoot(tester);

      expect(operableControlNames(root), contains('Run test'),
          reason: 'nothing rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      handle.dispose();
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpLab(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // Three stacked previews on a short landscape screen is the tight case:
    // the caption above each one grows with the text scale and the previews
    // have to give way rather than clip.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
      ]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await expectNoOverflow(
            () => _pumpLab(tester, textScale: scale, size: size),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('the previews keep height at a 3x text scale', (tester) async {
      await _pumpLab(tester, textScale: 3.0, size: const Size(640, 360));

      // Each preview is a RepaintBoundary the dark-ratio measurement reads from.
      // If one collapses the diagnostic silently measures nothing, so a floor
      // matters more here than the clipping did.
      final previews = find.byType(RepaintBoundary);
      expect(previews, findsWidgets);
      var measured = 0;
      for (final element in previews.evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        if (size.height > 0 && size.width > 0) measured++;
      }
      expect(measured, greaterThanOrEqualTo(3),
          reason: 'a shader preview collapsed to nothing');
    });
  });
}
