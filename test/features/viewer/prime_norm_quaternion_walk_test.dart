import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_fractals/features/viewer/prime_norm_quaternion_slice.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  testWidgets('fixed-d walk and captured PNG are available', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: PrimeNormQuaternionSliceView(onBack: _noop)),
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
    await tester.ensureVisible(increase);
    await tester.tap(increase);
    await tester.ensureVisible(increase);
    await tester.tap(increase);
    await tester.pumpAndSettle();
    expect(find.text('d = 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive controls survive enlarged high-contrast layouts',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
            highContrast: true, disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('es')]) {
          tester.view.physicalSize = Size(width, 800);
          await tester.pumpWidget(MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(colorScheme: const ColorScheme.dark()),
            highContrastTheme:
                ThemeData(colorScheme: const ColorScheme.highContrastDark()),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                highContrast: true,
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const Scaffold(
                body: PrimeNormQuaternionSliceView(onBack: _noop)),
          ));
          await tester.pumpAndSettle();

          final capture = find.text(
              locale.languageCode == 'es' ? 'Capturar PNG' : 'Capture PNG');
          await tester.ensureVisible(capture);
          expect(
              tester
                  .getRect(capture)
                  .overlaps(Offset.zero & tester.view.physicalSize),
              isTrue,
              reason: 'capture action should be reachable at width $width, '
                  'text scale $scale, locale ${locale.languageCode}');
          expect(Theme.of(tester.element(capture)).colorScheme.primary,
              const ColorScheme.highContrastDark().primary);
          if (width == 320 && scale == 1 && locale.languageCode == 'en') {
            final boundary = tester.renderObject<RenderRepaintBoundary>(find
                .descendant(
                    of: find.byType(PrimeNormQuaternionSliceView),
                    matching: find.byType(RepaintBoundary))
                .first);
            final still =
                await tester.runAsync(() => captureQuaternionPng(boundary));
            await tester.pump(const Duration(seconds: 1));
            final afterMotionInterval =
                await tester.runAsync(() => captureQuaternionPng(boundary));
            expect(_pngPixelsDiffer(still!, afterMotionInterval!), isFalse,
                reason:
                    'reduced motion keeps the manually rotated slice still');
          }
          expect(tester.takeException(), isNull,
              reason: 'layout should not overflow at width $width, '
                  'text scale $scale, locale ${locale.languageCode}');
        }
      }
    }
  });

  testWidgets('quaternion disclosure and actions localize in Spanish',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PrimeNormQuaternionSliceView(onBack: _noop)),
    ));
    await tester.pumpAndSettle();
    final semantics = tester.ensureSemantics();

    expect(
        find.text('Rebanada de cuaterniones de norma prima'), findsOneWidget);
    expect(find.textContaining('solo la rebanada fija d'), findsOneWidget);
    expect(find.text('Lista de coordenadas'), findsOneWidget);
    expect(find.byTooltip('Disminuir d fijo'), findsOneWidget);
    expect(
        find.bySemanticsLabel(
            'Puntos de cuaterniones de norma prima; usa las flechas para rotar y Lista de coordenadas para elegir puntos superpuestos'),
        findsOneWidget);

    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .descendant(
            of: find.byType(PrimeNormQuaternionSliceView),
            matching: find.byType(RepaintBoundary))
        .first);
    final before = await tester.runAsync(() => captureQuaternionPng(boundary));
    final plot = find.byType(CustomPaint).last;
    final plotRect = tester.getRect(plot);
    final plotFocus = tester
        .widget<Focus>(
            find.ancestor(of: plot, matching: find.byType(Focus)).first)
        .focusNode!;
    await tester.tapAt(plotRect.topLeft + const Offset(1, 1));
    expect(plotFocus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    final after = await tester.runAsync(() => captureQuaternionPng(boundary));
    expect(_pngPixelsDiffer(before!, after!), isTrue);

    await tester.ensureVisible(find.text('Lista de coordenadas'));
    await tester.tap(find.text('Lista de coordenadas'));
    await tester.pumpAndSettle();
    expect(
        find.bySemanticsLabel(
            'Coordenadas de cuaterniones de norma prima; activa una fila para previsualizar un punto'),
        findsOneWidget);
    expect(find.text('Cambia a la vista 3D para capturar el gráfico PNG.'),
        findsOneWidget);
    semantics.dispose();
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

void _noop() {}
