import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _builtIns = find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_PresetChip',
);
final _saved = find.byKey(const ValueKey('userPresetChip_keyboard-saved'));

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 50),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key,
    {bool reverse = false}) async {
  if (reverse) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  if (reverse) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await _settle(tester);
}

bool _focused(WidgetTester tester, Finder target) {
  final text = find.descendant(of: target, matching: find.byType(Text)).first;
  return Focus.maybeOf(tester.element(text))?.hasPrimaryFocus ?? false;
}

Future<void> _tabTo(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 30 && !_focused(tester, target); i++) {
    await _key(tester, LogicalKeyboardKey.tab);
  }
  expect(_focused(tester, target), isTrue, reason: 'Tab must reach $target');
}

Future<({FractalController controller, PresetStore store, FractalPreset saved})>
    _openSheet(WidgetTester tester, String language, double scale) async {
  SharedPreferences.setMockInitialValues({});
  final controller = FractalController(ModuleRegistry());
  addTearDown(controller.dispose);
  final store = await PresetStore.create();
  final saved = controller.module.builtInPresets.last.copyWith(
    id: 'keyboard-saved',
    name: 'Saved keyboard view',
    view: controller.view.copyWith(zoom: 7.25),
  );
  await store.saveUserPreset(saved);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: controller),
      Provider.value(value: store),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: scale == 3,
        ),
        child: child!,
      ),
      initialRoute: '/viewer',
      routes: {
        '/': (_) => const Scaffold(body: Text('Root route')),
        '/viewer': (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAppBottomSheet<void>(
                  context: context,
                  builder: (_) => const PresetSheet(),
                ),
                child: const Text('Viewer route'),
              ),
            ),
      },
    ),
  ));
  await _settle(tester);
  await tester.tap(find.text('Viewer route'));
  await _settle(tester);
  return (controller: controller, store: store, saved: saved);
}

void _expectApplied(FractalController controller, FractalPreset preset) {
  for (final entry in preset.params.entries) {
    expect(controller.params[entry.key], entry.value);
  }
  expect(controller.view.zoom, preset.view.zoom);
  expect(controller.view.pan, preset.view.pan);
  expect(controller.view.rotation, preset.view.rotation);
  expect(find.byType(PresetSheet), findsNothing);
  expect(find.text('Viewer route').hitTestable(), findsOneWidget);
}

void main() {
  testWidgets('modal traversal and Enter/Space apply publish once and return',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    for (final language in ['en', 'es']) {
      for (final scale in [1.0, 3.0]) {
        for (final key in [
          LogicalKeyboardKey.enter,
          LogicalKeyboardKey.space
        ]) {
          for (final selection in [0, 1, -1]) {
            final fixture = await _openSheet(tester, language, scale);
            final presets = fixture.controller.module.builtInPresets;
            expect(presets.length, greaterThanOrEqualTo(2));
            expect(presets[0].params, isNot(equals(presets[1].params)));
            await fixture.controller
                .applyPreset(selection < 0 ? presets.first : fixture.saved);
            var publications = 0;
            fixture.controller.addListener(() => publications++);
            // Actual traversal must scroll every apply surface into view.
            await _tabTo(tester, _builtIns.first);
            for (var i = 0; i < presets.length; i++) {
              expect(_focused(tester, _builtIns.at(i)), isTrue);
              expect(_builtIns.at(i).hitTestable(), findsOneWidget);
              if (i > 0) {
                await _key(tester, LogicalKeyboardKey.tab, reverse: true);
                expect(_focused(tester, _builtIns.at(i - 1)), isTrue);
                await _key(tester, LogicalKeyboardKey.tab);
              }
              await _key(tester, LogicalKeyboardKey.tab);
            }
            expect(_focused(tester, _saved), isTrue);
            expect(_saved.hitTestable(), findsOneWidget);
            await _key(tester, LogicalKeyboardKey.tab, reverse: true);
            expect(_focused(tester, _builtIns.last), isTrue);
            await _key(tester, LogicalKeyboardKey.tab);
            final target = selection < 0 ? _saved : _builtIns.at(selection);
            await _tabTo(tester, target);
            final label = tester
                .widget<Text>(find
                    .descendant(of: target, matching: find.byType(Text))
                    .first)
                .data!;
            final node = tester.getSemantics(find.text(label));
            expect(node.label, label);
            expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
            expect(
                node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
            // Only rename/delete have their own tap semantics beneath apply.
            expect(
              node
                  .debugListChildrenInOrder(
                      DebugSemanticsDumpOrder.traversalOrder)
                  .where((child) =>
                      child.getSemanticsData().hasAction(SemanticsAction.tap))
                  .length,
              selection < 0 ? 2 : 0,
            );
            final container = tester.widget<AnimatedContainer>(find
                .descendant(
                    of: target, matching: find.byType(AnimatedContainer))
                .first);
            final border =
                (container.decoration! as BoxDecoration).border! as Border;
            expect(border.top.color,
                isNot(AppColors.border.withValues(alpha: 0.4)));
            await _key(tester, key);
            expect(publications, 1);
            _expectApplied(fixture.controller,
                selection < 0 ? fixture.saved : presets[selection]);
            expect(
                ModalRoute.of(tester.element(find.text('Viewer route')))!
                    .isCurrent,
                isTrue);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    }
    semantics.dispose();
  });

  testWidgets('saved child actions remain separate; pointer apply still works',
      (tester) async {
    final fixture = await _openSheet(tester, 'en', 1);
    var publications = 0;
    fixture.controller.addListener(() => publications++);
    final l10n = AppLocalizations.of(tester.element(find.byType(PresetSheet)))!;
    for (final pointer in [false, true]) {
      for (final rename in [true, false]) {
        final action = find.byTooltip(
            rename ? l10n.tooltipRenamePreset : l10n.tooltipDeletePreset);
        if (pointer) {
          await tester.ensureVisible(action);
          await _settle(tester);
          await tester.tap(action);
          await _settle(tester);
        } else {
          await _tabTo(tester, _saved);
          await _key(tester, LogicalKeyboardKey.tab);
          if (!rename) await _key(tester, LogicalKeyboardKey.tab);
          await _key(tester,
              rename ? LogicalKeyboardKey.enter : LogicalKeyboardKey.space);
        }
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(PresetSheet), findsOneWidget);
        expect(publications, 0);
        if (rename) {
          await tester.enterText(
              find.descendant(
                  of: find.byType(Dialog), matching: find.byType(TextField)),
              'Renamed view');
          await tester.tap(find.text(l10n.buttonSave));
        } else {
          await tester
              .tap(find.text(pointer ? l10n.buttonDelete : l10n.buttonCancel));
        }
        await _settle(tester);
        expect(publications, 0);
        expect(find.byType(PresetSheet), findsOneWidget);
        if (rename) {
          final stored =
              await fixture.store.loadUserPresets(fixture.saved.moduleId);
          expect(stored.single.id, fixture.saved.id);
          expect(stored.single.name, 'Renamed view');
        }
      }
    }
    expect(
        await fixture.store.loadUserPresets(fixture.saved.moduleId), isEmpty);
    await fixture.store.saveUserPreset(fixture.saved);
    Navigator.of(tester.element(find.byType(PresetSheet))).pop();
    await _settle(tester);
    for (final saved in [true, false]) {
      await tester.tap(find.text('Viewer route'));
      await _settle(tester);
      final target = saved ? _saved : _builtIns.at(1);
      await tester.ensureVisible(target);
      await _settle(tester);
      await tester
          .tap(find.descendant(of: target, matching: find.byType(Text)).first);
      await _settle(tester);
      expect(publications, saved ? 1 : 2);
      _expectApplied(fixture.controller,
          saved ? fixture.saved : fixture.controller.module.builtInPresets[1]);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
