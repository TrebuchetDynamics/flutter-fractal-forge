import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal host that supplies the [AnimationController] FractalViewControls
/// needs for its entrance transition.
class _Host extends StatefulWidget {
  const _Host(this.build);
  final Widget Function(AnimationController controller) build;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1.0,
    duration: const Duration(milliseconds: 1),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(_controller);
}

Future<bool> _pumpControls(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  required bool isExporting,
  VoidCallback? onOpenExport,
  VoidCallback? onShareLink,
  VoidCallback? onShareImage,
  VoidCallback? onOpenLooper,
  VoidCallback? onToggleBreathing,
  VoidCallback? onToggleFourier,
  VoidCallback? onOpenFourierSettings,
  VoidCallback? onOpenPalettePicker,
  VoidCallback? onOpenRandomFractal,
  VoidCallback? onOpenControls,
  VoidCallback? onRandomizeParams,
  VoidCallback? onCycleColorScheme,
  VoidCallback? onToggleFullscreen,
  VoidCallback? onToggleTextOverlay,
  VoidCallback? onEditTextOverlay,
  bool kaleidoscopeEnabled = false,
  int kaleidoscopeSectors = 8,
  bool kaleidoscopeMirror = true,
  bool breathingPlaying = false,
  bool fourierEnabled = false,
  bool textOverlayEnabled = false,
  bool showFractalReport = false,
  bool supportsAuxiliaryTools = true,
  bool reduceMotion = false,
  double textScale = 1,
  ThemeData? theme,
  VoidCallback? onToggleKaleidoscope,
  VoidCallback? onReportFractal,
  required VoidCallback onOpenWallpaper,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: _Host(
          (controller) => FractalViewControls(
            fabController: controller,
            isExporting: isExporting,
            kaleidoscopeEnabled: kaleidoscopeEnabled,
            kaleidoscopeSectors: kaleidoscopeSectors,
            kaleidoscopeMirror: kaleidoscopeMirror,
            breathingPlaying: breathingPlaying,
            fourierEnabled: fourierEnabled,
            textOverlayEnabled: textOverlayEnabled,
            showFractalReport: showFractalReport,
            supportsAuxiliaryTools: supportsAuxiliaryTools,
            actions: FractalViewControlActions(
              toggleFullscreen: onToggleFullscreen ?? () {},
              openRandomFractal: onOpenRandomFractal ?? () {},
              openControls: onOpenControls ?? () {},
              randomizeParams: onRandomizeParams ?? () {},
              cycleColorScheme: onCycleColorScheme ?? () {},
              openPalettePicker: onOpenPalettePicker ?? () {},
              toggleKaleidoscope: onToggleKaleidoscope ?? () {},
              setKaleidoscopeSectors: (_) {},
              setKaleidoscopeMirror: (_) {},
              openExport: onOpenExport ?? () {},
              shareLink: onShareLink ?? () {},
              shareImage: onShareImage ?? () {},
              toggleTextOverlay: onToggleTextOverlay ?? () {},
              editTextOverlay: onEditTextOverlay ?? () {},
              openLooper: onOpenLooper ?? () {},
              toggleBreathing: onToggleBreathing ?? () {},
              toggleFourier: onToggleFourier ?? () {},
              openFourierSettings: onOpenFourierSettings ?? () {},
              reportFractal: onReportFractal ?? () {},
              openWallpaper: onOpenWallpaper,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return true;
}

const _primaryKeys = [
  'viewerBreathingButton',
  'viewerControlsButton',
  'viewerPaletteButton',
  'viewerRandomFractalFab',
  'viewerOverflowMenu',
];
const _secondaryKeys = [
  'viewerRandomParamsButton',
  'viewerColorCycleButton',
  'viewerLooperFab',
  'viewerKaleidoscopeFab',
  'viewerFourierFab',
  'viewerTextOverlayFab',
  'viewerFullscreenButton',
];

Finder _key(String key) => find.byKey(ValueKey(key));
Future<void> _openMore(WidgetTester tester) async {
  if (find.byType(BottomSheet).evaluate().isEmpty) {
    await tester.ensureVisible(_key('viewerOverflowMenu'));
    await tester.tap(_key('viewerOverflowMenu'));
    await tester.pumpAndSettle();
  }
}

Future<Finder> _reveal(WidgetTester tester, String key) async {
  final sheet = find.byType(BottomSheet);
  if (_primaryKeys.contains(key) &&
      sheet.evaluate().isNotEmpty &&
      find.descendant(of: sheet, matching: _key(key)).evaluate().isEmpty) {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }
  if (_key(key).evaluate().isEmpty || !_primaryKeys.contains(key))
    await _openMore(tester);
  final tool = _key(key);
  await tester.ensureVisible(tool);
  await tester.pumpAndSettle();
  return tool;
}

Future<void> _tapTool(WidgetTester tester, String key,
    {bool secondary = false}) async {
  final tool = await _reveal(tester, key);
  if (secondary) {
    await tester.longPress(tool);
  } else {
    await tester.tap(tool);
  }
  await tester.pumpAndSettle();
}

Future<void> _focus(WidgetTester tester, String key) async {
  final tool = await _reveal(tester, key);
  final gesture =
      find.descendant(of: tool, matching: find.byType(GestureDetector));
  Focus.of(tester.element(gesture)).requestFocus();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('exact walls retain ordinary tools but omit auxiliary tools',
      (tester) async {
    for (final supported in [false, true]) {
      await _pumpControls(tester,
          isExporting: false,
          supportsAuxiliaryTools: supported,
          onOpenWallpaper: () {});
      await _openMore(tester);
      for (final key in [
        'viewerLooperFab',
        'viewerKaleidoscopeFab',
        'viewerTextOverlayFab',
        'viewerFourierFab',
        'viewerAutoExploreButton'
      ]) {
        // This harness has no AutoExploreService; its row is absent in either mode.
        expect(
            _key(key),
            supported && key != 'viewerAutoExploreButton'
                ? findsOneWidget
                : findsNothing);
      }
      for (final key in [
        'viewerRandomParamsButton',
        'viewerColorCycleButton',
        'viewerOpenExportAction',
        'viewerFullscreenButton'
      ]) {
        expect(_key(key), findsOneWidget);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
      'NumberWall ordinary color and parameter callbacks retain their full action path',
      (tester) async {
    final calls = <String>[];
    await _pumpControls(tester,
        isExporting: false,
        supportsAuxiliaryTools: false,
        onCycleColorScheme: () => calls.add('color'),
        onRandomizeParams: () => calls.add('params'),
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerColorCycleButton');
    await _tapTool(tester, 'viewerRandomParamsButton');
    expect(calls, ['color', 'params']);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('text and fullscreen primary row callbacks remain distinct',
      (tester) async {
    var text = 0;
    var fullscreen = 0;
    await _pumpControls(tester,
        isExporting: false,
        onToggleTextOverlay: () => text++,
        onToggleFullscreen: () => fullscreen++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerTextOverlayFab');
    expect(text, 1);
    expect(fullscreen, 0);
    await _tapTool(tester, 'viewerFullscreenButton');
    expect(text, 1);
    expect(fullscreen, 1);
  });

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final highContrast in [false, true]) {
      testWidgets(
          'More keyboard and named export actions ${locale.languageCode} contrast=$highContrast',
          (tester) async {
        final calls = <String>[];
        await _pumpControls(tester,
            locale: locale,
            theme: highContrast ? AppTheme.highContrast : AppTheme.dark,
            isExporting: false,
            onOpenExport: () => calls.add('export'),
            onShareLink: () => calls.add('link'),
            onShareImage: () => calls.add('image'),
            onOpenWallpaper: () => calls.add('wallpaper'));
        await _focus(tester, 'viewerOverflowMenu');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(find.byType(BottomSheet), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        for (final entry in const {
          'viewerOpenExportAction': 'export',
          'viewerShareLinkAction': 'link',
          'viewerShareImageAction': 'image',
          'viewerWallpaperAction': 'wallpaper'
        }.entries) {
          await _focus(tester, 'viewerOverflowMenu');
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          await _focus(tester, entry.key);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(calls.last, entry.value);
          expect(find.byType(BottomSheet), findsNothing);
        }
        expect(calls, ['export', 'link', 'image', 'wallpaper']);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('More omits wallpaper on Linux', (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    await _openMore(tester);
    expect(_key('viewerWallpaperAction'), findsNothing);
    for (final key in [
      'viewerOpenExportAction',
      'viewerShareLinkAction',
      'viewerShareImageAction'
    ]) {
      expect(_key(key), findsOneWidget);
    }
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  for (final method in ['pointer', 'keyboard', 'semantics']) {
    testWidgets(
        'short landscape More scrolls to and activates report via $method',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 240);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final semantics = tester.ensureSemantics();

      var reports = 0;
      await _pumpControls(tester,
          isExporting: false,
          showFractalReport: true,
          onReportFractal: () => reports++,
          onOpenWallpaper: () {});
      await _openMore(tester);
      final report = _key('viewerReportFractalFab');
      expect(report.hitTestable(), findsNothing);
      await tester.ensureVisible(report);
      await tester.pumpAndSettle();
      expect(report.hitTestable(), findsOneWidget);
      expect(reports, 0);
      if (method == 'pointer') {
        await tester.tap(report);
      } else if (method == 'keyboard') {
        await _focus(tester, 'viewerReportFractalFab');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else {
        final node =
            tester.getSemantics(find.bySemanticsLabel('Report fractal'));
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        tester.binding.renderViews.single.owner!.semanticsOwner!
            .performAction(node.id, SemanticsAction.tap);
      }
      await tester.pumpAndSettle();
      expect(reports, 1);
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets(
      'adaptive primaries replace the rail without a duplicate share FAB',
      (tester) async {
    var exported = false;
    await _pumpControls(tester,
        isExporting: false,
        onOpenExport: () => exported = true,
        onOpenWallpaper: () {});
    final visible =
        _primaryKeys.where((key) => _key(key).evaluate().isNotEmpty).toList();
    expect(visible, contains('viewerOverflowMenu'));
    for (final key in _secondaryKeys) {
      expect(_key(key), findsNothing);
    }
    expect(_key('viewerShareImageButton'), findsNothing);
    await tester.tap(_key('viewerExportButton'));
    await tester.pumpAndSettle();
    expect(exported, isFalse);
    for (final key in _primaryKeys.where((key) => !visible.contains(key))) {
      expect(_key(key), findsOneWidget,
          reason: 'suppressed $key remains reachable');
    }
    for (final label in ['Export', 'Copy view link', 'Share image']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final key in _secondaryKeys) {
      expect(_key(key), findsOneWidget);
    }
    expect(find.text('Share & export'), findsNothing);
  });

  testWidgets(
      'primary controls and scrollable More stay usable at 3x phone text scale',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpControls(tester,
        isExporting: false,
        textScale: 3,
        showFractalReport: true,
        onOpenWallpaper: () {});
    for (final key in _primaryKeys) {
      await _reveal(tester, key);
      final rect = tester.getRect(_key(key));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(568));
    }
    await _openMore(tester);
    expect(
        find.ancestor(
            of: find.text('Export'),
            matching: find.byType(SingleChildScrollView)),
        findsOneWidget);
    for (final key in [..._secondaryKeys, 'viewerReportFractalFab']) {
      await tester.ensureVisible(_key(key));
      await tester.pumpAndSettle();
      final rect = tester.getRect(_key(key));
      expect(rect.left, greaterThanOrEqualTo(0), reason: key);
      expect(rect.right, lessThanOrEqualTo(320), reason: key);
      expect(rect.top, greaterThanOrEqualTo(0), reason: key);
      expect(rect.bottom, lessThanOrEqualTo(568), reason: key);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fourier row separates toggle, long press, and explicit Options',
      (tester) async {
    var toggles = 0;
    var settings = 0;
    await _pumpControls(tester,
        isExporting: false,
        fourierEnabled: true,
        onToggleFourier: () => toggles++,
        onOpenFourierSettings: () => settings++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerFourierFab');
    expect(toggles, 1);
    expect(settings, 0);
    await _tapTool(tester, 'viewerFourierFab', secondary: true);
    expect(toggles, 1);
    expect(settings, 1);
    await _tapTool(tester, 'viewerFourierFabOptions');
    expect(toggles, 1);
    expect(settings, 2);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
      'random, looper, breathing and kaleidoscope keep distinct callbacks',
      (tester) async {
    var random = 0;
    var looper = 0;
    var breathing = 0;
    var kaleidoscope = 0;
    await _pumpControls(tester,
        isExporting: false,
        onOpenRandomFractal: () => random++,
        onOpenLooper: () => looper++,
        onToggleBreathing: () => breathing++,
        onToggleKaleidoscope: () => kaleidoscope++,
        onOpenWallpaper: () {});
    for (final entry in const [
      (key: 'viewerRandomFractalFab', expected: [1, 0, 0, 0]),
      (key: 'viewerLooperFab', expected: [1, 1, 0, 0]),
      (key: 'viewerBreathingButton', expected: [1, 1, 1, 0]),
      (key: 'viewerKaleidoscopeFab', expected: [1, 1, 1, 1]),
    ]) {
      await _tapTool(tester, entry.key);
      expect([random, looper, breathing, kaleidoscope], entry.expected);
    }
  });

  testWidgets('random and kaleidoscope options retain their sheets',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerRandomFractalFab', secondary: true);
    expect(find.text('Random options'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await _tapTool(tester, 'viewerKaleidoscopeFab', secondary: true);
    expect(find.text('Kaleidoscope sections'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await _tapTool(tester, 'viewerRandomOptionsAction');
    expect(find.text('Random options'), findsOneWidget);
  });

  testWidgets('text row long press edits and report stays conditional',
      (tester) async {
    var edits = 0;
    var reports = 0;
    await _pumpControls(tester,
        isExporting: false,
        onEditTextOverlay: () => edits++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerTextOverlayFab', secondary: true);
    expect(edits, 1);
    await _openMore(tester);
    expect(_key('viewerReportFractalFab'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await _pumpControls(tester,
        isExporting: false,
        showFractalReport: true,
        onReportFractal: () => reports++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerReportFractalFab');
    expect(reports, 1);
  });

  testWidgets('all primary and secondary tools keep minimum 48dp tap targets',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    for (final key in [..._primaryKeys, ..._secondaryKeys]) {
      final tool = await _reveal(tester, key);
      final size = tester.getSize(tool);
      expect(size.width, greaterThanOrEqualTo(48), reason: key);
      expect(size.height, greaterThanOrEqualTo(48), reason: key);
    }
  });

  testWidgets('primary controls stay in a compact bottom row in landscape',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    final first = tester.getTopLeft(_key(_primaryKeys.first));
    final last = tester.getTopLeft(_key(_primaryKeys.last));
    expect((first.dy - last.dy).abs(), lessThan(1));
    expect(last.dx, greaterThan(first.dx));
    expect(
        tester.getSize(_key('viewerFabColumn')).width, lessThanOrEqualTo(440));
  });

  testWidgets('keyboard traversal follows the visible primary actions',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    for (final key
        in _primaryKeys.where((key) => _key(key).evaluate().isNotEmpty)) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final gesture = find.descendant(
          of: _key(key), matching: find.byType(GestureDetector));
      expect(Focus.of(tester.element(gesture)).hasFocus, isTrue, reason: key);
    }
  });

  testWidgets(
      'More tab order retains secondary shortcuts and scrolls to fullscreen',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    await _focus(tester, 'viewerOpenExportAction');
    final menuTools = tester
        .widgetList<FloatingActionButtonWidget>(find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(FloatingActionButtonWidget)))
        .map((tool) => (tool.key! as ValueKey<String>).value)
        .toList();
    expect(
        menuTools,
        containsAll([
          'viewerShareLinkAction',
          'viewerShareImageAction',
          'viewerWallpaperAction',
          'viewerRandomOptionsAction',
          'viewerRandomParamsButton',
          'viewerRandomParamsButtonOptions',
          'viewerColorCycleButton',
          'viewerColorCycleButtonOptions',
          'viewerLooperFab',
          'viewerKaleidoscopeFab',
          'viewerKaleidoscopeFabOptions',
          'viewerFourierFab',
          'viewerFourierFabOptions',
          'viewerTextOverlayFab',
          'viewerTextOverlayFabOptions',
          'viewerFullscreenButton'
        ]));
    for (final key in menuTools.skip(1)) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final gesture = find.descendant(
          of: _key(key), matching: find.byType(GestureDetector));
      expect(Focus.of(tester.element(gesture)).hasFocus, isTrue, reason: key);
      expect(_key(key).hitTestable(), findsOneWidget, reason: key);
    }
  });

  testWidgets(
      'toggle rows expose selected semantics and a changed neutral surface',
      (tester) async {
    final handle = tester.ensureSemantics();

    final offColors = <String, Color?>{};
    Color? surface(String key) => tester
        .widgetList<Container>(find.descendant(
            of: find
                .ancestor(of: _key(key), matching: find.byType(Stack))
                .first,
            matching: find.byType(Container)))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.borderRadius != null)
        .last
        .color;
    for (final selected in [false, true]) {
      await _pumpControls(tester,
          theme: AppTheme.dark,
          isExporting: false,
          textOverlayEnabled: selected,
          kaleidoscopeEnabled: selected,
          breathingPlaying: selected,
          fourierEnabled: selected,
          onOpenWallpaper: () {});
      await _openMore(tester);
      for (final key in [
        'viewerTextOverlayFab',
        'viewerKaleidoscopeFab',
        'viewerBreathingButton',
        'viewerFourierFab'
      ]) {
        await _reveal(tester, key);
        final button = tester.widget<FloatingActionButtonWidget>(_key(key));
        expect(button.selected, selected);
        final data = tester
            .getSemantics(find.bySemanticsLabel(button.tooltip))
            .getSemanticsData();
        // ignore: deprecated_member_use
        expect(data.hasFlag(SemanticsFlag.isSelected), selected);
        if (!selected) {
          offColors[key] = surface(key);
        } else {
          expect(surface(key), isNot(offColors[key]));
        }
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
    handle.dispose();
  });

  for (final locale in const [Locale('en'), Locale('es')]) {
    testWidgets(
        'primary and secondary screen-reader labels ${locale.languageCode}',
        (tester) async {
      final handle = tester.ensureSemantics();

      await _pumpControls(tester,
          locale: locale, isExporting: false, onOpenWallpaper: () {});
      final labels = locale.languageCode == 'en'
          ? const {
              'viewerBreathingButton': 'Play parameter animation',
              'viewerControlsButton': 'Controls',
              'viewerPaletteButton': 'Palette',
              'viewerRandomFractalFab': 'Random',
              'viewerOverflowMenu': 'More',
            }
          : const {
              'viewerBreathingButton': 'Reproducir animación de parámetros',
              'viewerControlsButton': 'Controles',
              'viewerPaletteButton': 'Paleta',
              'viewerRandomFractalFab': 'Aleatorio',
              'viewerOverflowMenu': 'Más',
            };
      for (final entry in labels.entries) {
        await _reveal(tester, entry.key);
        final button =
            tester.widget<FloatingActionButtonWidget>(_key(entry.key));
        final inMore = find
            .ancestor(
              of: _key(entry.key),
              matching: find.byType(BottomSheet),
            )
            .evaluate()
            .isNotEmpty;
        final expectedLabel = entry.key == 'viewerRandomFractalFab' && inMore
            ? (locale.languageCode == 'en'
                ? 'Random Fractal'
                : 'Fractal aleatorio')
            : entry.value;
        expect(button.tooltip, expectedLabel, reason: entry.key);
        expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
      }
      await _openMore(tester);
      for (final key in _secondaryKeys) {
        await _reveal(tester, key);
        final button = tester.widget<FloatingActionButtonWidget>(_key(key));
        expect(button.tooltip, isNotEmpty);
        expect(find.bySemanticsLabel(button.tooltip), findsOneWidget);
      }
      handle.dispose();
    });
  }

  testWidgets(
      'randomize separates tap from Controls secondary and direct Controls',
      (tester) async {
    var randomized = 0;
    var opened = 0;
    await _pumpControls(tester,
        isExporting: false,
        onOpenControls: () => opened++,
        onRandomizeParams: () => randomized++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerRandomParamsButton');
    expect(randomized, 1);
    expect(opened, 0);
    await _tapTool(tester, 'viewerRandomParamsButton', secondary: true);
    expect(randomized, 1);
    expect(opened, 1);
    await _tapTool(tester, 'viewerControlsButton');
    expect(opened, 2);
  });

  for (final secondary in [false, true]) {
    testWidgets(
        'randomize keyboard ${secondary ? 'Shift+Enter secondary' : 'Enter primary'}',
        (tester) async {
      var randomized = 0;
      var opened = 0;
      await _pumpControls(tester,
          isExporting: false,
          onOpenControls: () => opened++,
          onRandomizeParams: () => randomized++,
          onOpenWallpaper: () {});
      await _focus(tester, 'viewerRandomParamsButton');
      if (secondary)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      if (secondary) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(randomized, secondary ? 0 : 1);
      expect(opened, secondary ? 1 : 0);
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  testWidgets('color secondary and direct Palette open the picker',
      (tester) async {
    var opened = 0;
    await _pumpControls(tester,
        isExporting: false,
        onOpenPalettePicker: () => opened++,
        onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerColorCycleButton', secondary: true);
    expect(opened, 1);
    await _tapTool(tester, 'viewerPaletteButton');
    expect(opened, 2);
  });

  testWidgets(
      'export disables callbacks, More pointer and keyboard, semantics and dimming',
      (tester) async {
    final handle = tester.ensureSemantics();

    var tapped = false;
    await _pumpControls(tester,
        isExporting: true,
        onOpenControls: () => tapped = true,
        onOpenWallpaper: () => tapped = true);
    for (final key
        in _primaryKeys.where((key) => _key(key).evaluate().isNotEmpty)) {
      final button = tester.widget<FloatingActionButtonWidget>(_key(key));
      expect(button.onPressed, isNull);
      expect(button.onLongPress, isNull);
      await tester.tap(_key(key), warnIfMissed: false);
      await tester.pump();
      final node = tester
          .getSemantics(find.bySemanticsLabel(button.tooltip))
          .getSemanticsData();
      expect(node.hasAction(SemanticsAction.tap), isFalse);
      expect(node.hasAction(SemanticsAction.longPress), isFalse);
      // ignore: deprecated_member_use
      expect(node.hasFlag(SemanticsFlag.isEnabled), isFalse);
      final visualStack =
          find.ancestor(of: _key(key), matching: find.byType(Stack)).first;
      expect(
          find.descendant(
              of: visualStack,
              matching: find
                  .byWidgetPredicate((w) => w is Opacity && w.opacity == 0.38)),
          findsWidgets);
    }
    await _focus(tester, 'viewerOverflowMenu');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tapped, isFalse);
    for (final key in _secondaryKeys) {
      expect(_key(key), findsNothing);
    }
    handle.dispose();
  });

  testWidgets('each primary has exactly one labeled screen-reader stop',
      (tester) async {
    final handle = tester.ensureSemantics();

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    final labels = <String>[];
    var unlabeled = 0;
    void walk(SemanticsNode node) {
      if (!node.isMergedIntoParent) {
        final data = node.getSemanticsData();
        if (data.actions != 0) {
          if (data.label.isEmpty) {
            unlabeled++;
          } else {
            labels.add(data.label);
          }
        }
      }
      node.visitChildren((child) {
        walk(child);
        return true;
      });
    }

    // ignore: deprecated_member_use
    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(unlabeled, 0);
    final visibleCount =
        _primaryKeys.where((key) => _key(key).evaluate().isNotEmpty).length;
    expect(labels, hasLength(visibleCount));
    expect(labels.toSet(), hasLength(visibleCount));
    handle.dispose();
  });

  testWidgets('taps keep haptics under reduced motion', (tester) async {
    final log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      log.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await _pumpControls(tester,
        isExporting: false, reduceMotion: true, onOpenWallpaper: () {});
    await _tapTool(tester, 'viewerRandomParamsButton');
    expect(
        log.where((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.mediumImpact'),
        isNotEmpty);
  });
}
