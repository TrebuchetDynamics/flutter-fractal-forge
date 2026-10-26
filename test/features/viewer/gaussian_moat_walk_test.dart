import 'dart:async';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/viewer/gaussian_moat_map.dart';
import 'package:flutter_fractals/features/viewer/gaussian_moat_plot.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

void main() {
  late ModuleRegistry registry;
  late FractalController controller;
  late PresetStore presets;
  late RendererSettingsService settings;
  late HistoryProvider history;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    registry = ModuleRegistry();
    controller = FractalController(registry)
      ..selectModule(registry.byId('gaussian_prime_lattice'), animate: false);
    presets = await PresetStore.create();
    settings = RendererSettingsService(await SharedPreferences.getInstance());
    history = HistoryProvider(store: await HistoryStore.create());
  });
  tearDown(() {
    history.dispose();
    settings.dispose();
    controller.dispose();
  });

  Future<void> open(WidgetTester tester,
      {String locale = 'en',
      double scale = 1,
      bool reducedMotion = false,
      GaussianMoatMapGenerator? mapGenerator}) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        if (mapGenerator != null)
          Provider<GaussianMoatMapGenerator>.value(value: mapGenerator),
        Provider.value(value: registry),
        ChangeNotifierProvider.value(value: controller),
        Provider.value(value: presets),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: history),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: reducedMotion),
            child: child!),
        home: const FractalViewerScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    final walk = find.text(locale == 'en' ? 'Walk' : 'Caminar');
    expect(walk, findsOneWidget);
    await tester.tap(walk);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gaussianMoatPlot')), findsOneWidget);
  }

  GaussianMoatPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(find.byKey(const Key('gaussianMoatPlot')))
      .painter! as GaussianMoatPainter;

  testWidgets('pausing before the initial map completes preserves that job',
      (tester) async {
    final completed =
        await tester.runAsync(() => GaussianPrimeMap.generate(32));
    final result = Completer<GaussianPrimeMap?>();
    bool Function()? cancelled;
    var calls = 0;
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      expect(bound, 32);
      cancelled = isCancelled;
      return result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    expect(cancelled, isNotNull);
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump();

    expect(cancelled!(), isFalse,
        reason: 'Pausing playback must not cancel required initial map work');
    result.complete(completed!);
    await tester.pumpAndSettle();
    expect(painter(tester).map.bound, 32);
    expect(calls, 1, reason: 'Pause preserves the already-required map job');
    await tester.pump(const Duration(seconds: 2));
    final slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    expect(slider.value, 4,
        reason: 'A paused initial-map completion must not restart playback');
    expect(slider.onChanged, isNotNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('background cancellation never retries map work on resume',
      (tester) async {
    final completed =
        await tester.runAsync(() => GaussianPrimeMap.generate(32));
    final jobs =
        <({Completer<GaussianPrimeMap?> result, bool Function()? cancelled})>[];
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      expect(bound, 32);
      final job =
          (result: Completer<GaussianPrimeMap?>(), cancelled: isCancelled);
      jobs.add(job);
      return job.result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    expect(jobs, hasLength(1));
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(jobs.single.cancelled!(), isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(jobs, hasLength(1));

    jobs.single.result.complete(completed!);
    await tester.pump();
    await tester.pump();
    expect(jobs, hasLength(1),
        reason: 'A background-cancelled job must not be retried on resume');
    expect(find.textContaining('Computing'), findsOneWidget,
        reason:
            'The cancelled result must not publish into the resumed viewer');
    await tester.pump(const Duration(seconds: 2));
    final slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    expect(slider.value, 4,
        reason: 'Returning to the foreground must not restart playback');
    expect(slider.onChanged, isNotNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('export cannot take ownership while the initial map is pending',
      (tester) async {
    final result = Completer<GaussianPrimeMap?>();
    bool Function()? cancelled;
    var calls = 0;
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      cancelled = isCancelled;
      return result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    final plot = find.byKey(const Key('gaussianMoatPlot'));
    final exportLabel = AppLocalizations.of(tester.element(plot))!.exportTitle;
    final exportButton = find
        .ancestor(of: find.text(exportLabel), matching: find.byType(TextButton))
        .first;
    expect(tester.widget<TextButton>(exportButton).onPressed, isNull);
    await tester.tap(find.text(exportLabel));
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 1,
        reason: 'Disabled export must not trigger a map retry or replacement');
    expect(cancelled!(), isFalse,
        reason: 'Pending required work remains owned by the active viewer');
    result.complete(null);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('export stops playback without scheduling map work',
      (tester) async {
    var calls = 0;
    Future<GaussianPrimeMap?> countedGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      return GaussianPrimeMap.generate(bound, isCancelled: isCancelled);
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: countedGenerator);
    expect(calls, 1);
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    final plot = find.byKey(const Key('gaussianMoatPlot'));
    final exportLabel = AppLocalizations.of(tester.element(plot))!.exportTitle;
    await tester.tap(find.text(exportLabel).last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 1, reason: 'Export must not enqueue a map recomputation');
    final slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    expect(slider.value, 4,
        reason: 'Export ownership loss must stop growth playback');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('navigation disposes pending map work without retry',
      (tester) async {
    final result = Completer<GaussianPrimeMap?>();
    bool Function()? cancelled;
    var calls = 0;
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      cancelled = isCancelled;
      return result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(cancelled!(), isTrue);
    result.complete(null);
    await tester.pump();
    await tester.pump();
    expect(calls, 1, reason: 'Disposed viewer must never restart map work');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'existing Gaussian viewer opens the exact bounded map and retains Explore',
      (tester) async {
    final params = Map.of(controller.params);
    final view = controller.view;
    await open(tester);
    expect(find.textContaining('B=32'), findsOneWidget);
    expect(find.textContaining('uncomputed'), findsWidgets);
    expect(controller.module.id, 'gaussian_prime_lattice');
    expect(painter(tester).map.bound, 32);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    expect(controller.params, params);
    expect(controller.view.pan, view.pan);
    expect(controller.view.zoom, view.zoom);
    expect(controller.view.rotation, view.rotation);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
    for (final locale in ['en', 'es']) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('MAP layout width=$width locale=$locale scale=$scale',
            (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await open(tester, locale: locale, scale: scale);
          expect(tester.takeException(), isNull);
          final controls = find.text(locale == 'en' ? 'Controls' : 'Controles');
          if (width < 768 || scale > 1.3) {
            await tester.tap(controls);
            await tester.pumpAndSettle();
          }
          final bound = find.text(locale == 'en'
              ? 'Domain half-width B (1–128)'
              : 'Semiancho del dominio B (1–128)');
          await tester.ensureVisible(bound);
          await tester.tap(bound);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('gaussianBoundInput')), findsOneWidget);
          await tester.enterText(
              find.byKey(const Key('gaussianBoundInput')), '129');
          await tester.tap(find.text(locale == 'en' ? 'Apply' : 'Aplicar'));
          await tester.pumpAndSettle();
          expect(painter(tester).map.bound, 32);
          expect(
              find.text(locale == 'en'
                  ? 'Enter an integer from 1 to 128.'
                  : 'Introduce un entero de 1 a 128.'),
              findsOneWidget);
          await tester.enterText(
              find.byKey(const Key('gaussianBoundInput')), '1');
          await tester.tap(find.text(locale == 'en' ? 'Apply' : 'Aplicar'));
          await tester.pumpAndSettle();
          expect(painter(tester).map.points.length, 4);
          expect(find.textContaining('B=1:'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('growth honors dwell and pause without queued ticks',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final toggle = find.byKey(const Key('gaussianGrowthToggle'));
    await tester.tap(toggle);
    await tester.pump(const Duration(milliseconds: 599));
    expect(find.textContaining('Maximum squared step: 4'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.textContaining('Maximum squared step: 8'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(toggle);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Maximum squared step: 8'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('slow map work cannot accumulate growth timer ticks',
      (tester) async {
    final completed =
        await tester.runAsync(() => GaussianPrimeMap.generate(32));
    final result = Completer<GaussianPrimeMap?>();
    var calls = 0;
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      return result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(seconds: 5));
    expect(find.textContaining('Maximum squared step: 16'), findsOneWidget,
        reason: 'Paced ticks complete without exceeding the bounded schedule');
    expect(calls, 1);

    result.complete(completed!);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 599));
    expect(find.textContaining('Maximum squared step: 16'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.textContaining('Maximum squared step: 16'), findsOneWidget);
    expect(calls, 1, reason: 'Radius progression does not enqueue map work');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('scrubbing previews without computing and commits last radius',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final initialComponent = painter(tester).component;
    var slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChanged!(12);
    await tester.pump();
    slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChanged!(6);
    await tester.pump();
    slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    expect(slider.value, 6);
    expect(find.textContaining('Maximum squared step: 4'), findsOneWidget);
    expect(identical(painter(tester).component, initialComponent), isTrue,
        reason: 'Preview values must not recompute the component');

    slider.onChangeEnd!(6);
    await tester.pump();
    expect(find.textContaining('Maximum squared step: 6'), findsOneWidget);
    expect(identical(painter(tester).component, initialComponent), isFalse);
    expect(painter(tester).component,
        painter(tester).map.component((a: 1, b: 1), maxSquaredStep: 6));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'radius committed during delayed B128 work matches captured graph',
      (tester) async {
    final initial = await tester.runAsync(() => GaussianPrimeMap.generate(32));
    final completed =
        await tester.runAsync(() => GaussianPrimeMap.generate(128));
    final result = Completer<GaussianPrimeMap?>();
    var calls = 0;
    Future<GaussianPrimeMap?> heldGenerator(int bound,
        {bool Function()? isCancelled}) {
      calls++;
      if (bound == 32) return Future.value(initial);
      expect(bound, 128);
      return result.future;
    }

    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, mapGenerator: heldGenerator);
    await tester.ensureVisible(find.text('Domain half-width B (1–128)'));
    await tester.tap(find.text('Domain half-width B (1–128)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('gaussianBoundInput')), '128');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    var slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChanged!(11);
    await tester.pump();
    slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChanged!(8);
    await tester.pump();
    slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChangeEnd!(8);
    await tester.pump();
    expect(find.textContaining('Maximum squared step: 8'), findsOneWidget);
    expect(calls, 2);

    result.complete(completed!);
    await tester.pumpAndSettle();
    final activePainter = painter(tester);
    expect(identical(activePainter.map, completed), isTrue);
    expect(activePainter.component,
        completed.component((a: 1, b: 1), maxSquaredStep: 8));
    expect(find.textContaining('Maximum squared step: 8'), findsOneWidget);

    final plot = find.byKey(const Key('gaussianMoatPlot'));
    tester.element(plot).read<FractalController>().updateZoom(4);
    await tester.pump();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.ancestor(of: plot, matching: find.byType(RepaintBoundary)).first);
    final image = await tester.runAsync(() => boundary.toImage());
    final capturedImage = image!;
    final bytes = await tester.runAsync(
        () => capturedImage.toByteData(format: ui.ImageByteFormat.png));
    final decoded = img.decodePng(bytes!.buffer.asUint8List());
    expect(decoded, isNotNull);
    final decodedPng = decoded!;
    expect(decodedPng.width, capturedImage.width);
    expect(decodedPng.height, capturedImage.height);
    final previous = completed.component((a: 1, b: 1), maxSquaredStep: 4);
    // B128 points are four times denser than B32 at the default zoom.
    // Choose an isolated, visible new marker rather than overlapping circles.
    final addedPoint = activePainter.component.difference(previous).firstWhere(
        (p) =>
            p.a.abs() < 30 && p.b.abs() < 30 && p.a.abs() > 2 && p.b.abs() > 2);
    final transform = GaussianMapTransform(
        tester.getSize(plot), painter(tester).view, activePainter.map.bound);
    final center = transform
        .toScreen(Offset(addedPoint.a.toDouble(), addedPoint.b.toDouble()));
    final pixel = decodedPng.getPixel(center.dx.round(), center.dy.round());
    int blend(double overlay, double base) =>
        (overlay * 0.35 + base * 0.65).round();
    expect(
        pixel.r,
        closeTo(
            blend(activePainter.highlight.r * 255,
                activePainter.foreground.r * 255),
            5));
    expect(
        pixel.g,
        closeTo(
            blend(activePainter.highlight.g * 255,
                activePainter.foreground.g * 255),
            5));
    expect(
        pixel.b,
        closeTo(
            blend(activePainter.highlight.b * 255,
                activePainter.foreground.b * 255),
            5));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('growth terminates at its configured maximum', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final slider =
        tester.widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')));
    slider.onChangeEnd!(8);
    await tester.pump();
    await tester.tap(find.byKey(const Key('gaussianGrowthToggle')));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.textContaining('Maximum squared step: 16'), findsOneWidget);
    expect(
        tester
            .widget<TextButton>(find.byKey(const Key('gaussianGrowthToggle')))
            .onPressed,
        isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion prevents growth playback', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester, reducedMotion: true);
    expect(
        tester
            .widget<TextButton>(find.byKey(const Key('gaussianGrowthToggle')))
            .onPressed,
        isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('shared signed transform round-trips pan, zoom and pane resize', () {
    for (final size in [
      const Size(320, 480),
      const Size(724, 600),
      const Size(600, 320)
    ]) {
      for (final zoom in [0.25, 1.0, 4.0]) {
        final view = FractalViewState.initial()
            .copyWith(pan: Vector2(0.12, -0.23), zoom: zoom);
        final transform = GaussianMapTransform(size, view, 32);
        for (final p in [
          const Offset(-32, 32),
          const Offset(3, -3),
          Offset.zero,
          const Offset(32, -32)
        ]) {
          final actual = transform.toLattice(transform.toScreen(p));
          expect(actual.dx, closeTo(p.dx, 1e-9));
          expect(actual.dy, closeTo(p.dy, 1e-9));
          expect(transform.pick(transform.toScreen(p)),
              (a: p.dx.toInt(), b: p.dy.toInt()));
        }
      }
    }
  });

  testWidgets('pane taps select only; dragging and wheel do not select',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final plot = find.byKey(const Key('gaussianMoatPlot'));
    final origin = tester.getTopLeft(plot);
    final size = tester.getSize(plot);
    var transform = GaussianMapTransform(size, painter(tester).view, 32);
    await tester.tapAt(origin + transform.toScreen(const Offset(1, -1)));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(painter(tester).candidate, (a: 1, b: -1));
    expect(painter(tester).root, (a: 1, b: 1));
    await tester.drag(plot, const Offset(80, 20));
    await tester.pumpAndSettle();
    expect(painter(tester).candidate, (a: 1, b: -1));
    expect(painter(tester).view.pan.length, greaterThan(0));
    final renderer = tester.element(plot);
    final camera = renderer.read<FractalController>();
    final zoom = camera.view.zoom;
    final center = tester.getCenter(plot);
    tester.binding.handlePointerEvent(PointerScrollEvent(
        position: center, scrollDelta: const Offset(0, -60)));
    await tester.pumpAndSettle();
    expect(camera.view.zoom, greaterThan(zoom));
    expect(painter(tester).candidate, (a: 1, b: -1));
    transform =
        GaussianMapTransform(tester.getSize(plot), painter(tester).view, 32);
    final target = transform.toScreen(const Offset(3, 0));
    await tester.tapAt(tester.getTopLeft(plot) + target);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(painter(tester).candidate, (a: 3, b: 0));
    expect(controller.view.pan.length, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'keyboard candidate controls retain focus and reject unknown/composite roots',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final a = find.byKey(const Key('gaussianCoordinateA'));
    final b = find.byKey(const Key('gaussianCoordinateB'));
    await tester.enterText(a, '3');
    await tester.enterText(b, '0');
    final select = find.text('Select candidate');
    await tester.ensureVisible(select);
    final focus = Focus.of(tester.element(select));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(painter(tester).candidate, (a: 3, b: 0));
    expect(FocusManager.instance.primaryFocus, focus);
    expect(painter(tester).root, (a: 1, b: 1));
    await tester.tap(find.text('Set start'));
    await tester.pumpAndSettle();
    expect(painter(tester).root, (a: 3, b: 0));
    for (final coordinate in ['2', '1000']) {
      await tester.ensureVisible(a);
      await tester.enterText(a, coordinate);
      await tester.ensureVisible(select);
      await tester.tap(select);
      await tester.pumpAndSettle();
      expect(painter(tester).root, (a: 3, b: 0));
      final startButton = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Set start'));
      expect(startButton.onPressed, isNull);
    }
    expect(find.textContaining('uncomputed — outside domain'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('candidate selection does not move until a valid Step',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final a = find.byKey(const Key('gaussianCoordinateA'));
    final b = find.byKey(const Key('gaussianCoordinateB'));
    await tester.enterText(a, '-1');
    await tester.enterText(b, '1');
    await tester.ensureVisible(find.text('Select candidate'));
    await tester.tap(find.text('Select candidate'));
    await tester.pumpAndSettle();
    expect(painter(tester).root, (a: 1, b: 1));
    expect(find.textContaining('Path: 0 steps'), findsOneWidget);
    await tester.ensureVisible(find.text('Step to candidate'));
    await tester.tap(find.text('Step to candidate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Path: 1 steps'), findsOneWidget);
    for (final point in [(1, 1), (2, 0), (1000, -1)]) {
      await tester.enterText(a, '${point.$1}');
      await tester.enterText(b, '${point.$2}');
      final select = find.text('Select candidate');
      await tester.ensureVisible(select);
      Focus.of(tester.element(select)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(painter(tester).candidate, (a: point.$1, b: point.$2));
      final step = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Step to candidate'));
      expect(step.onPressed, isNull,
          reason: 'Repeated, composite and outside points cannot extend path');
      expect(find.textContaining('Path: 1 steps'), findsOneWidget);
    }
    await tester.ensureVisible(find.text('Undo step'));
    await tester.tap(find.text('Undo step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Path: 0 steps'), findsOneWidget);
    await tester.ensureVisible(find.text('Step to candidate'));
    expect(
        tester
            .widget<TextButton>(
                find.widgetWithText(TextButton, 'Step to candidate'))
            .onPressed,
        isNull,
        reason:
            'Undo restores the origin path and the current outside choice is invalid');
    await tester.ensureVisible(find.text('Reset path'));
    await tester.tap(find.text('Reset path'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Path: 0 steps'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('coordinate limits reject both axes without changing selection',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await open(tester);
    final a = find.byKey(const Key('gaussianCoordinateA'));
    final b = find.byKey(const Key('gaussianCoordinateB'));
    final select = find.text('Select candidate');
    for (final axis in [a, b]) {
      for (final coordinate in ['-1000000', '1000000']) {
        await tester.ensureVisible(a);
        await tester.enterText(a, '1');
        await tester.enterText(b, '1');
        await tester.enterText(axis, coordinate);
        await tester.ensureVisible(select);
        await tester.tap(select);
        await tester.pumpAndSettle();
        final candidate = painter(tester).candidate;
        expect(
            candidate,
            axis == a
                ? (a: int.parse(coordinate), b: 1)
                : (a: 1, b: int.parse(coordinate)));
        for (final invalid in [
          '-9223372036854775808',
          '9223372036854775807',
          '-1000001',
          '1000001',
        ]) {
          await tester.ensureVisible(axis);
          await tester.enterText(axis, invalid);
          await tester.ensureVisible(select);
          await tester.tap(select);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(painter(tester).candidate, candidate);
          expect(painter(tester).root, (a: 1, b: 1));
          expect(
              find.text(
                  AppLocalizations.of(tester.element(a))!.gaussianCoordinates),
              findsOneWidget);
        }
      }
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'real host capture contains the exact plot, domain and selected overlay',
      (tester) async {
    await open(tester);
    await tester.ensureVisible(find.text('Domain half-width B (1–128)'));
    await tester.tap(find.text('Domain half-width B (1–128)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('gaussianBoundInput')), '1');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    final plot = find.byKey(const Key('gaussianMoatPlot'));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.ancestor(of: plot, matching: find.byType(RepaintBoundary)).first);
    var transform = GaussianMapTransform(
        tester.getSize(plot), painter(tester).view, painter(tester).map.bound);
    await tester.tapAt(
        tester.getTopLeft(plot) + transform.toScreen(const Offset(1, -1)));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Step to candidate'));
    await tester.tap(find.text('Step to candidate'));
    await tester.pumpAndSettle();
    expect(painter(tester).path, [(a: 1, b: 1), (a: 1, b: -1)]);
    expect(painter(tester).component, {
      (a: 1, b: 1),
      (a: 1, b: -1),
      (a: -1, b: 1),
      (a: -1, b: -1),
    });
    expect(find.textContaining('boundary may continue'), findsOneWidget);
    final coordinateA = find.byKey(const Key('gaussianCoordinateA'));
    final coordinateB = find.byKey(const Key('gaussianCoordinateB'));
    await tester.enterText(coordinateA, '1');
    await tester.enterText(coordinateB, '-1');
    final select = find.text('Select candidate');
    await tester.ensureVisible(select);
    Focus.of(tester.element(select)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(painter(tester).candidate, (a: 1, b: -1));
    final image = await tester.runAsync(() => boundary.toImage());
    final capturedImage = image!;
    final bytes = await tester.runAsync(
        () => capturedImage.toByteData(format: ui.ImageByteFormat.rawRgba));
    final pixels = bytes!.buffer.asUint8List();
    final colors = <int>{};
    for (var i = 0; i < pixels.length; i += 4) {
      colors.add((pixels[i] << 24) |
          (pixels[i + 1] << 16) |
          (pixels[i + 2] << 8) |
          pixels[i + 3]);
    }
    expect(colors.length, greaterThan(3));
    final png = await tester.runAsync(
        () => capturedImage.toByteData(format: ui.ImageByteFormat.png));
    final decoded = img.decodePng(png!.buffer.asUint8List());
    expect(decoded, isNotNull);
    final decodedPng = decoded!;
    expect(decodedPng.width, capturedImage.width);
    expect(decodedPng.height, capturedImage.height);
    final captureTransform = GaussianMapTransform(
        tester.getSize(plot), painter(tester).view, painter(tester).map.bound);
    final componentCenter = captureTransform.toScreen(const Offset(-1, -1));
    final componentPixel = decodedPng.getPixel(
        componentCenter.dx.round(), componentCenter.dy.round());
    final activePainter = painter(tester);
    int blendChannel(double overlay, double base) =>
        (overlay * 0.35 + base * 0.65).round();
    expect(
        componentPixel.r,
        closeTo(
            blendChannel(activePainter.highlight.r * 255,
                activePainter.foreground.r * 255),
            5));
    expect(
        componentPixel.g,
        closeTo(
            blendChannel(activePainter.highlight.g * 255,
                activePainter.foreground.g * 255),
            5));
    expect(
        componentPixel.b,
        closeTo(
            blendChannel(activePainter.highlight.b * 255,
                activePainter.foreground.b * 255),
            5));
    final center = captureTransform.toScreen(const Offset(1, -1));
    final color = painter(tester).highlight;
    var markedPixels = 0;
    for (var y = center.dy.round() - 10; y <= center.dy.round() + 10; y++) {
      for (var x = center.dx.round() - 10; x <= center.dx.round() + 10; x++) {
        final i = (y * capturedImage.width + x) * 4;
        if ((pixels[i] - (color.r * 255).round()).abs() < 3 &&
            (pixels[i + 1] - (color.g * 255).round()).abs() < 3 &&
            (pixels[i + 2] - (color.b * 255).round()).abs() < 3) markedPixels++;
      }
    }
    expect(markedPixels, greaterThan(0),
        reason: 'Candidate ring must be in the captured plot');
    expect(capturedImage.width, tester.getSize(plot).width.round());
    capturedImage.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}
