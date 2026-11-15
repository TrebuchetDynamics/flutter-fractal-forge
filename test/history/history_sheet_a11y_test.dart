import 'dart:async';
import 'package:flutter/material.dart';
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
  provider.recordLocation(
    moduleId: controller.module.id,
    view: controller.view,
    params: Map<String, Object>.from(controller.params),
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
  await provider.saveCurrentAsFavorite('Favourite One');
  onReady?.call(provider);
  await tester.pumpAndSettle();
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

    testWidgets('the tab body keeps height at a 3x text scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpSheet(tester, textScale: 3.0);

      // The header is a fixed child of the sheet's Column, so an unbounded one
      // takes its space from the tab body instead of scrolling. Uncapped it
      // reached 412px inside a 341px sheet and the body collapsed to zero,
      // hiding every entry until the sheet was dragged taller.
      expect(
        tester.getSize(find.byType(TabBarView).first).height,
        greaterThan(0),
        reason: 'tab body collapsed to nothing',
      );
    });
  });
}
