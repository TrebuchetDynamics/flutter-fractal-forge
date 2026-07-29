import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/permission_test_harness.dart';
import '../helpers/overflow_guard.dart';

void main() {
  group('palette picker', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late RendererSettingsService rendererSettings;
    late HistoryStore historyStore;
    late HistoryProvider historyProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      installDenyAllPermissionsHandler();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());
      historyStore = await HistoryStore.create();
      historyProvider = HistoryProvider(store: historyStore);
    });

    tearDown(() {
      historyProvider.dispose();
      controller.dispose();
      rendererSettings.dispose();
    });

    Widget buildTestWidget({double textScale = 1.0}) => MultiProvider(
          providers: [
            Provider.value(value: registry),
            ChangeNotifierProvider.value(value: controller),
            Provider.value(value: presetStore),
            ChangeNotifierProvider.value(value: rendererSettings),
            ChangeNotifierProvider.value(value: historyProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const FractalViewerScreen(),
          ),
        );

    Future<void> openPicker(WidgetTester tester, {double textScale = 1.0}) async {
      await tester.pumpWidget(buildTestWidget(textScale: textScale));
      await tester.pumpAndSettle();
      await tester
          .longPress(find.byKey(const ValueKey('viewerColorCycleButton')));
      await tester.pumpAndSettle();
    }

    testWidgets('marks exactly one palette as selected for screen readers',
        (tester) async {
      final handle = tester.ensureSemantics();
      await openPicker(tester);
      expect(find.byType(GridView), findsOneWidget);

      final selected = <String>[];
      void walk(SemanticsNode node) {
        if (!node.isMergedIntoParent) {
          final data = node.getSemanticsData();
          if (data.flagsCollection.isSelected == Tristate.isTrue) {
            selected.add(data.label);
          }
        }
        node.visitChildren((child) {
          walk(child);
          return true;
        });
      }

      // Semantics live on this pipeline owner; rootPipelineOwner.semanticsOwner
      // is null in a widget test. Matches test/a11y/semantics/.
      // ignore: deprecated_member_use
      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

      // The active palette is otherwise signalled only by a check icon and a
      // border colour, neither of which reaches a screen reader.
      expect(
        selected,
        hasLength(1),
        reason: 'the active palette carries no selected state',
      );
      expect(selected.single, isNotEmpty, reason: 'selected tile is unnamed');

      handle.dispose();
    });

    for (final scale in const [1.0, 1.5, 2.0]) {
      testWidgets('picker grid survives a ${scale}x text scale', (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await expectNoOverflow(
          () => openPicker(tester, textScale: scale),
          reason: 'at $scale x',
        );
      });
    }
  });
}
