import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/overflow_guard.dart';
import '../helpers/ui_overlay_capture_harness.dart'
    show loadOverlayCaptureFonts;

/// Pumps the sheet with one recorded location and one favourite, so the entry
/// tiles, count badges and the position label are all present.
Future<void> _pumpSheet(
  WidgetTester tester, {
  double textScale = 1.0,
  FractalController? controllerOverride,
  void Function(HistoryProvider)? onReady,
}) async {
  SharedPreferences.setMockInitialValues({});
  final registry = ModuleRegistry();
  final controller = controllerOverride ?? FractalController(registry);
  addTearDown(controller.dispose);
  final provider = HistoryProvider(store: await HistoryStore.create());
  addTearDown(provider.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: registry),
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: HistorySheet()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // recordLocation debounces through a Timer, so the fake clock has to be
  // pumped past the delay rather than awaited.
  final classic = controllerOverride == null
      ? registry
          .byId('mandelbrot')
          .builtInPresets
          .singleWhere((preset) => preset.id == 'mandelbrot-classic')
      : null;
  provider.recordLocation(
    moduleId: controller.module.id,
    view: classic?.view ?? controller.view,
    params: Map<String, Object>.from(classic?.params ?? controller.params),
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
  await provider.saveCurrentAsFavorite('Favourite One');
  onReady?.call(provider);
  await tester.pumpAndSettle();
}

/// Uses the shipping modal route, not a sheet embedded directly in a Scaffold.
Future<(HistoryProvider, FractalController)> _pumpHistoryRoute(
    WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final controller = FractalController(ModuleRegistry());
  final store = await HistoryStore.create();
  final entries = List.generate(
      8,
      (index) => HistoryEntry(
            id: 'view-$index',
            name: 'Vista $index',
            moduleId: controller.module.id,
            view: controller.view.copyWith(zoom: index + 2.0),
            params: controller.params,
            visitedAt: DateTime.utc(2026, 1, 1, 0, index),
          ));
  await store.saveHistory(entries);
  await store.saveFavorites([entries[0].copyWith(name: 'Mi favorito')]);
  final history = HistoryProvider(store: store);
  addTearDown(controller.dispose);
  addTearDown(history.dispose);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: controller),
      ChangeNotifierProvider.value(value: history),
    ],
    child: MaterialApp(
      theme: AppTheme.highContrast,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(3),
          highContrast: true,
          disableAnimations: true,
          accessibleNavigation: true,
        ),
        child: child!,
      ),
      home: Builder(
          builder: (context) => Scaffold(
                  body: TextButton(
                onPressed: () => showAppBottomSheet<void>(
                    context: context, builder: (_) => const HistorySheet()),
                child: const Text('Abrir historial'),
              ))),
    ),
  ));
  await tester.tap(find.text('Abrir historial'));
  await tester.pumpAndSettle();
  return (history, controller);
}

Future<void> _tabTo(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final context = FocusManager.instance.primaryFocus?.context;
    if (context != null &&
        find
            .descendant(
              of: find
                  .byElementPredicate((element) => identical(element, context)),
              matching: target,
              matchRoot: true,
            )
            .evaluate()
            .isNotEmpty) return;
  }
  fail('Keyboard could not reach $target');
}

class _ControlledReplayController extends FractalController {
  _ControlledReplayController() : super(ModuleRegistry());

  Completer<void>? gate;

  @override
  Future<bool> loadState({
    FractalModule? module,
    String? moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
    bool transparentBackground = false,
    bool animateModule = false,
    void Function()? onCommitted,
    bool Function()? shouldCommit,
  }) async {
    final pending = gate;
    if (pending != null) await pending.future;
    return super.loadState(
      module: module,
      moduleId: moduleId,
      params: params,
      view: view,
      transparentBackground: transparentBackground,
      animateModule: animateModule,
      onCommitted: onCommitted,
      shouldCommit: shouldCommit,
    );
  }
}

void main() {
  group('HistorySheet accessibility', () {
    testWidgets(
        'real sheet handlers commit Back Forward entry and favorite only on acceptance',
        (tester) async {
      final controller = _ControlledReplayController();
      late HistoryProvider history;
      await _pumpSheet(tester,
          controllerOverride: controller, onReady: (value) => history = value);
      final first = history.currentEntry!;
      controller.updateZoom(2);
      history.recordLocation(
          moduleId: controller.module.id,
          params: controller.params,
          view: controller.view);
      await tester.pump(const Duration(milliseconds: 501));
      await tester.pumpAndSettle();
      controller.gate = Completer<void>();
      await tester.tap(find.byTooltip('Go back'));
      await tester.pump();
      expect(history.currentPosition, 2);
      expect(controller.view.zoom, 2);
      controller.gate!.complete();
      await tester.pumpAndSettle();
      expect(history.currentPosition, 1);
      expect(controller.view.zoom, first.view.zoom);
      controller.gate = Completer<void>();
      await tester.tap(find.byTooltip('Go forward'));
      await tester.pump();
      expect(history.currentPosition, 1);
      controller.gate!.complete();
      await tester.pumpAndSettle();
      expect(history.currentPosition, 2);
      controller.gate = Completer<void>();
      await tester.tap(find.text(first.displayLabel).last);
      await tester.pump();
      expect(history.currentPosition, 2);
      controller.gate!.complete();
      await tester.pumpAndSettle();
      expect(history.currentPosition, 1);
      controller.gate = null;
      await history.replayForward(controller);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      controller.gate = Completer<void>();
      await tester.tap(find.text('Favourite One'));
      await tester.pump();
      expect(history.historyCount, 2);
      expect(history.currentPosition, 2);
      controller.gate!.complete();
      await tester.pumpAndSettle();
      expect(history.historyCount, 3);
      expect(history.currentEntry!.params, controller.params);
      expect(controller.view.zoom, first.view.zoom);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'sheet Back entry and favorite reject invalid composite without moving history',
        (tester) async {
      final controller = _ControlledReplayController();
      late HistoryProvider history;
      await _pumpSheet(tester,
          controllerOverride: controller, onReady: (value) => history = value);
      history.recordLocation(
          moduleId: 'number_wall',
          view: controller.view,
          params: const {'prime': '15'});
      await tester.pump(const Duration(milliseconds: 501));
      final invalid = history.currentEntry!;
      await history.saveAsFavorite(invalid, 'Invalid composite');
      controller.updateZoom(2);
      history.recordLocation(
          moduleId: controller.module.id,
          view: controller.view,
          params: controller.params);
      await tester.pump(const Duration(milliseconds: 501));
      await tester.pumpAndSettle();
      final committed = history.currentEntry;
      for (final action in ['back', 'entry', 'favorite']) {
        if (action == 'favorite') {
          await tester.tap(find.text('Favorites'));
          await tester.pumpAndSettle();
        }
        controller.gate = Completer<void>();
        await tester.tap(action == 'back'
            ? find.byTooltip('Go back')
            : find.text(action == 'entry'
                ? invalid.displayLabel
                : 'Invalid composite'));
        await tester.pump();
        expect(history.currentEntry, same(committed));
        controller.gate!.complete();
        await tester.pumpAndSettle();
        expect(history.currentEntry, same(committed));
        expect(history.historyCount, 3);
        expect(controller.module.id, 'mandelbrot');
        expect(controller.view.zoom, 2);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
        'popping a modal sheet revokes replay before its exit animation',
        (tester) async {
      final controller = _ControlledReplayController();
      late HistoryProvider history;
      await _pumpSheet(tester,
          controllerOverride: controller, onReady: (value) => history = value);
      controller.updateZoom(2);
      history.recordLocation(
          moduleId: controller.module.id,
          view: controller.view,
          params: controller.params);
      await tester.pump(const Duration(milliseconds: 501));
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: controller),
          ChangeNotifierProvider.value(value: history),
        ],
        child: MaterialApp(
            theme: AppTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const HistorySheet()),
                        child: const Text('Open history'))))),
      ));
      await tester.tap(find.text('Open history'));
      await tester.pumpAndSettle();
      controller.gate = Completer<void>();
      await tester.tap(find.byTooltip('Go back'));
      await tester.pump();
      final sheetContext = tester.element(find.byType(HistorySheet));
      Navigator.of(sheetContext).pop();
      expect(
          sheetContext.mounted, isTrue); // Still animating out, not disposed.
      controller.gate!.complete();
      await tester.pump();
      expect(history.currentPosition, 2);
      expect(controller.view.zoom, 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final loss in ['unmount', 'controller']) {
      testWidgets(
          'closing sheet or replacing controller cancels pending replay: $loss',
          (tester) async {
        final controller = _ControlledReplayController();
        late HistoryProvider history;
        await _pumpSheet(tester,
            controllerOverride: controller,
            onReady: (value) => history = value);
        controller.updateZoom(2);
        history.recordLocation(
            moduleId: controller.module.id,
            params: controller.params,
            view: controller.view);
        await tester.pump(const Duration(milliseconds: 501));
        await tester.pumpAndSettle();
        controller.gate = Completer<void>();
        await tester.tap(find.byTooltip('Go back'));
        await tester.pump();
        if (loss == 'unmount') {
          await tester.pumpWidget(const SizedBox.shrink());
        } else {
          final element = tester.element(find.byType(HistorySheet));
          final replacement = FractalController(ModuleRegistry());
          addTearDown(replacement.dispose);
          // Replace the actual ancestor binding while keeping sheet State mounted.
          await tester.pumpWidget(MultiProvider(
            providers: [
              Provider.value(value: ModuleRegistry()),
              ChangeNotifierProvider<FractalController>.value(
                  value: replacement),
              ChangeNotifierProvider.value(value: history),
            ],
            child: MaterialApp(
                theme: AppTheme.dark,
                locale: const Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(1)),
                    child: child!),
                home: const Scaffold(body: HistorySheet())),
          ));
          expect(tester.element(find.byType(HistorySheet)), same(element));
        }
        controller.gate!.complete();
        await tester.pumpAndSettle();
        expect(history.currentPosition, 2);
        expect(controller.view.zoom, 2);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('text meets the AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('every control meets the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every control is named', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await expectNoOverflow(
            () => _pumpSheet(tester, textScale: scale),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('the tab body is reachable at a 3x text scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpSheet(tester, textScale: 3.0);

      // Header and tabs may initially fill a short viewport, but they must
      // scroll away so the recorded location can be reached without resizing.
      final entry = find.text('mandelbrot @ 0.3x');
      for (var attempt = 0;
          attempt < 10 && entry.hitTestable().evaluate().isEmpty;
          attempt++) {
        await tester.drag(find.byType(HistorySheet), const Offset(0, -100));
        await tester.pumpAndSettle();
      }
      expect(entry.hitTestable(), findsOneWidget);
      expect(tester.getSize(find.byType(TabBarView)).height, greaterThan(0));
    });

    // Match the capture harness's deterministic SDK font substitution. Keep
    // these after the Ahem-based guideline checks: font registration is global.
    for (final size in [const Size(667, 375), const Size(375, 667)]) {
      testWidgets('populated Spanish 3x actual modal is reachable on $size',
          (tester) async {
        await loadOverlayCaptureFonts(tester);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        late HistoryProvider history;
        late FractalController controller;
        await expectNoOverflow(() async {
          (history, controller) = await _pumpHistoryRoute(tester);
        });
        expect(find.byType(ModalBarrier), findsWidgets);
        // Scroll the real route by touch to an older, uniquely named entry.
        for (var attempt = 0;
            attempt < 25 &&
                find.text('Vista 1').hitTestable().evaluate().isEmpty;
            attempt++) {
          await tester.drag(find.byType(HistorySheet), const Offset(0, -100));
          await tester.pumpAndSettle();
        }
        expect(find.text('Vista 1').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Vista 1'));
        await tester.pumpAndSettle();
        expect(history.currentEntry!.id, 'view-1');
        expect(controller.view.zoom, 3);

        // Keyboard traversal must reveal offscreen tabs and list entries too.
        await _tabTo(tester, find.text('Favoritos'));
        expect(find.text('Favoritos').hitTestable(), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await _tabTo(tester, find.text('Mi favorito'));
        expect(find.text('Mi favorito').hitTestable(), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(history.historyCount, 3);
        expect(history.currentPosition, 3);
        expect(controller.view.zoom, 2);
        await history.removeFavorite(history.favorites.single.id);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Sin favoritos'));
        expect(find.text('Sin favoritos'), findsOneWidget);
        await _tabTo(tester, find.text('Historial').last);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        final close = find.byIcon(Icons.close_rounded);
        await _tabTo(tester, find.byIcon(Icons.close_rounded));
        expect(close.hitTestable(), findsOneWidget);
        expect(find.text('Historial').first.hitTestable(), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(HistorySheet), findsNothing);
        // Reopen the same real route and replay a specific history entry using
        // only traversal and activation keys, as well as the touch path above.
        await tester.tap(find.text('Abrir historial'));
        await tester.pumpAndSettle();
        await _tabTo(tester, find.text('Vista 1'));
        expect(find.text('Vista 1').hitTestable(), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(history.currentPosition, 2);
        expect(controller.view.zoom, 3);
        await _tabTo(tester, find.byIcon(Icons.close_rounded));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(HistorySheet), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
