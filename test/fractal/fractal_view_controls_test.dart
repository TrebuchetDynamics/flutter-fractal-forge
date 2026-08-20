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
  VoidCallback? onToggleFractalMusic,
  VoidCallback? onToggleFourier,
  VoidCallback? onOpenFourierSettings,
  VoidCallback? onOpenPalettePicker,
  VoidCallback? onOpenRandomFractal,
  VoidCallback? onOpenControls,
  VoidCallback? onRandomizeParams,
  VoidCallback? onEditTextOverlay,
  bool kaleidoscopeEnabled = false,
  int kaleidoscopeSectors = 8,
  bool kaleidoscopeMirror = true,
  bool fractalMusicEnabled = false,
  bool fourierEnabled = false,
  bool textOverlayEnabled = false,
  bool showFractalReport = false,
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
            fractalMusicEnabled: fractalMusicEnabled,
            fourierEnabled: fourierEnabled,
            textOverlayEnabled: textOverlayEnabled,
            showFractalReport: showFractalReport,
            actions: FractalViewControlActions(
              toggleFullscreen: () {},
              openRandomFractal: onOpenRandomFractal ?? () {},
              openControls: onOpenControls ?? () {},
              randomizeParams: onRandomizeParams ?? () {},
              cycleColorScheme: () {},
              openPalettePicker: onOpenPalettePicker ?? () {},
              toggleKaleidoscope: onToggleKaleidoscope ?? () {},
              setKaleidoscopeSectors: (_) {},
              setKaleidoscopeMirror: (_) {},
              openExport: onOpenExport ?? () {},
              shareLink: onShareLink ?? () {},
              shareImage: onShareImage ?? () {},
              toggleTextOverlay: () {},
              editTextOverlay: onEditTextOverlay ?? () {},
              openLooper: onOpenLooper ?? () {},
              toggleFractalMusic: onToggleFractalMusic ?? () {},
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

void main() {
  testWidgets('export FAB opens export directly', (tester) async {
    var exported = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenExport: () => exported = true,
      onOpenWallpaper: () {},
    );

    final fab = find.byKey(const ValueKey('viewerExportButton'));
    expect(fab, findsOneWidget);
    expect(find.byKey(const ValueKey('viewerWallpaperButton')), findsNothing);

    await tester.ensureVisible(fab);
    await tester.pumpAndSettle();
    await tester.tap(fab);
    await tester.pumpAndSettle();
    expect(exported, isTrue);
    expect(find.byKey(const ValueKey('viewerExportMenuItem')), findsNothing);
  });

  testWidgets('all viewer actions render as direct FABs', (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    for (final key in const [
      'viewerFullscreenButton',
      'viewerColorCycleButton',
      'viewerRandomParamsButton',
      'viewerRandomFractalFab',
      'viewerLooperFab',
      'viewerFractalMusicFab',
      'viewerKaleidoscopeFab',
      'viewerTextOverlayFab',
      'viewerFourierFab',
      'viewerShareImageButton',
      'viewerExportButton',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }
    // The modal is gone: every action is a real FAB.
    for (final key in const [
      'viewerMoreActionsButton',
      'viewerTextOverlayButton',
      'viewerReportFractalButton',
      'viewerKaleidoscopeButton',
      'viewerRandomButton',
      'viewerLooperButton',
      'viewerFractalMusicButton',
      'viewerFourierButton',
    ]) {
      expect(find.byKey(ValueKey(key)), findsNothing, reason: key);
    }
  });

  testWidgets(
      'every FAB, including the report action, stays inside a phone viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpControls(
      tester,
      isExporting: false,
      showFractalReport: true,
      theme: AppTheme.dark,
      onOpenWallpaper: () {},
    );

    final viewportHeight = tester.getSize(find.byType(Scaffold).first).height;
    for (final key in const [
      'viewerRandomParamsButton',
      'viewerColorCycleButton',
      'viewerRandomFractalFab',
      'viewerLooperFab',
      'viewerFractalMusicFab',
      'viewerKaleidoscopeFab',
      'viewerTextOverlayFab',
      'viewerFourierFab',
      'viewerShareImageButton',
      'viewerExportButton',
      'viewerFullscreenButton',
      'viewerReportFractalFab',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.left, greaterThanOrEqualTo(0), reason: key);
      expect(
        rect.bottom,
        lessThanOrEqualTo(viewportHeight),
        reason: '$key rect=$rect viewportHeight=$viewportHeight',
      );
    }
  });

  testWidgets('Fourier FAB toggles on tap and opens settings on long press',
      (tester) async {
    var toggles = 0;
    var settings = 0;
    await _pumpControls(
      tester,
      isExporting: false,
      fourierEnabled: true,
      onToggleFourier: () => toggles++,
      onOpenFourierSettings: () => settings++,
      onOpenWallpaper: () {},
    );

    final fab = find.byKey(const ValueKey('viewerFourierFab'));
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump();
    expect(toggles, 1);
    expect(settings, 0);

    await tester.longPress(fab);
    await tester.pump();
    expect(toggles, 1);
    expect(settings, 1);
  });

  testWidgets('promoted FABs invoke their distinct primary actions',
      (tester) async {
    var random = 0;
    var looper = 0;
    var music = 0;
    var kaleidoscope = 0;
    var shareImage = 0;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenRandomFractal: () => random++,
      onOpenLooper: () => looper++,
      onToggleFractalMusic: () => music++,
      onToggleKaleidoscope: () => kaleidoscope++,
      onShareImage: () => shareImage++,
      onOpenWallpaper: () {},
    );

    for (final entry in const [
      (key: 'viewerRandomFractalFab', expected: [1, 0, 0, 0, 0]),
      (key: 'viewerLooperFab', expected: [1, 1, 0, 0, 0]),
      (key: 'viewerFractalMusicFab', expected: [1, 1, 1, 0, 0]),
      (key: 'viewerKaleidoscopeFab', expected: [1, 1, 1, 1, 0]),
      (key: 'viewerShareImageButton', expected: [1, 1, 1, 1, 1]),
    ]) {
      await tester.tap(find.byKey(ValueKey(entry.key)));
      await tester.pump();
      expect([random, looper, music, kaleidoscope, shareImage], entry.expected,
          reason: entry.key);
    }
  });

  testWidgets('customization affordances move to FAB long presses',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    // The overflow modal is gone; the same secondary actions live behind the
    // long press of their own FAB instead.
    await tester
        .longPress(find.byKey(const ValueKey('viewerRandomFractalFab')));
    await tester.pumpAndSettle();
    expect(find.text('Random options'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Random options'), findsNothing);

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();
    expect(find.text('Kaleidoscope sections'), findsOneWidget);
  });

  testWidgets('FAB long presses invoke their secondary actions',
      (tester) async {
    var editedText = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onEditTextOverlay: () => editedText = true,
      onOpenWallpaper: () {},
    );

    await tester.longPress(find.byKey(const ValueKey('viewerTextOverlayFab')));
    await tester.pump();
    expect(editedText, isTrue);

    await tester.longPress(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pumpAndSettle();
    expect(find.text('Kaleidoscope sections'), findsOneWidget);
  });

  testWidgets('FAB column remains usable at large text on a narrow phone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpControls(
      tester,
      isExporting: false,
      textScale: 3,
      onOpenWallpaper: () {},
    );

    expect(tester.takeException(), isNull);
    for (final key in const [
      'viewerRandomParamsButton',
      'viewerRandomFractalFab',
      'viewerTextOverlayFab',
      'viewerFourierFab',
      'viewerFullscreenButton',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.left, greaterThanOrEqualTo(0), reason: key);
      expect(rect.right, lessThanOrEqualTo(320), reason: key);
      expect(rect.top, greaterThanOrEqualTo(0), reason: key);
      expect(rect.bottom, lessThanOrEqualTo(568), reason: key);
    }
  });

  testWidgets('report FAB appears when enabled and fires the report',
      (tester) async {
    var reported = false;
    await _pumpControls(
      tester,
      isExporting: false,
      showFractalReport: true,
      onReportFractal: () => reported = true,
      onOpenWallpaper: () {},
    );

    final button = find.byKey(const ValueKey('viewerReportFractalFab'));
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(reported, isTrue);
  });

  testWidgets('quick control FABs keep accessible tap targets', (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    const fabKeys = [
      ValueKey('viewerRandomParamsButton'),
      ValueKey('viewerColorCycleButton'),
      ValueKey('viewerRandomFractalFab'),
      ValueKey('viewerLooperFab'),
      ValueKey('viewerFractalMusicFab'),
      ValueKey('viewerKaleidoscopeFab'),
      ValueKey('viewerTextOverlayFab'),
      ValueKey('viewerFourierFab'),
      ValueKey('viewerShareImageButton'),
      ValueKey('viewerExportButton'),
      ValueKey('viewerFullscreenButton'),
    ];

    for (final key in fabKeys) {
      final size = tester.getSize(find.byKey(key));
      expect(size.width, 48.0, reason: '$key width');
      expect(size.height, 48.0, reason: '$key height');
    }
  });

  testWidgets('quick control FABs move to bottom row in landscape',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    final first = tester
        .getTopLeft(find.byKey(const ValueKey('viewerRandomParamsButton')));
    final last =
        tester.getTopLeft(find.byKey(const ValueKey('viewerFullscreenButton')));
    expect((first.dy - last.dy).abs(), lessThan(1));
    expect(last.dx, greaterThan(first.dx));
  });

  testWidgets('keyboard traversal follows the visible action hierarchy',
      (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    for (final key in const [
      'viewerRandomParamsButton',
      'viewerColorCycleButton',
      'viewerRandomFractalFab',
      'viewerLooperFab',
      'viewerFractalMusicFab',
      'viewerKaleidoscopeFab',
      'viewerTextOverlayFab',
      'viewerFourierFab',
      'viewerShareImageButton',
      'viewerExportButton',
      'viewerFullscreenButton',
    ]) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final gesture = find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(GestureDetector),
      );
      expect(Focus.of(tester.element(gesture)).hasFocus, isTrue, reason: key);
    }
  });

  testWidgets('toggle FABs change color only when on', (tester) async {
    BoxDecoration decorationFor(String key) => tester
        .widgetList<Container>(find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Container),
        ))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((decoration) => decoration.shape == BoxShape.circle);

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    final textOff = decorationFor('viewerTextOverlayFab');
    final kaleidoscopeOff = decorationFor('viewerKaleidoscopeFab');
    final musicOff = decorationFor('viewerFractalMusicFab');
    final fourierOff = decorationFor('viewerFourierFab');

    await _pumpControls(
      tester,
      isExporting: false,
      textOverlayEnabled: true,
      kaleidoscopeEnabled: true,
      fractalMusicEnabled: true,
      fourierEnabled: true,
      onOpenWallpaper: () {},
    );

    expect(decorationFor('viewerTextOverlayFab').gradient,
        isNot(textOff.gradient));
    expect(decorationFor('viewerKaleidoscopeFab').gradient,
        isNot(kaleidoscopeOff.gradient));
    expect(decorationFor('viewerFractalMusicFab').gradient,
        isNot(musicOff.gradient));
    expect(
        decorationFor('viewerFourierFab').gradient, isNot(fourierOff.gradient));
  });

  testWidgets('promoted toggle FABs visibly expose their selected state',
      (tester) async {
    BoxDecoration decorationFor(String key) => tester
        .widgetList<Container>(find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Container),
        ))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((decoration) => decoration.shape == BoxShape.circle);

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    final musicOff = decorationFor('viewerFractalMusicFab');
    final kaleidoscopeOff = decorationFor('viewerKaleidoscopeFab');

    await _pumpControls(
      tester,
      isExporting: false,
      fractalMusicEnabled: true,
      kaleidoscopeEnabled: true,
      onOpenWallpaper: () {},
    );

    expect(decorationFor('viewerFractalMusicFab').gradient,
        isNot(musicOff.gradient));
    expect(decorationFor('viewerKaleidoscopeFab').gradient,
        isNot(kaleidoscopeOff.gradient));
  });

  testWidgets('quick control FABs expose screen-reader labels', (tester) async {
    final semantics = tester.ensureSemantics();

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    for (final label in const [
      'Randomize. Long press for Controls',
      'Color Scheme. Long press for palette',
      'Random Fractal',
      'Camera looper',
      'Fractal Music off',
      'Kaleidoscope off',
      'Text overlay off. Tap to add text.',
      'Fourier view off',
      'Share image',
      'Export / Wallpaper',
      'Fullscreen view',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }

    semantics.dispose();
  });

  testWidgets('quick control FAB labels localize to Spanish', (tester) async {
    final semantics = tester.ensureSemantics();

    await _pumpControls(
      tester,
      locale: const Locale('es'),
      isExporting: false,
      onOpenWallpaper: () {},
    );

    for (final label in const [
      'Esquema de color. Mantén presionado para paleta',
      'Fractal aleatorio',
      'Bucle de cámara',
      'Música fractal desactivada',
      'Kaleidoscopio desactivado',
      'Compartir imagen',
      'Exportar / Fondo de pantalla',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }

    semantics.dispose();
  });

  testWidgets('random fractal and looper are direct FAB actions',
      (tester) async {
    var randomFractal = false;
    var looper = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenRandomFractal: () => randomFractal = true,
      onOpenLooper: () => looper = true,
      onOpenWallpaper: () {},
    );

    await tester.tap(find.byKey(const ValueKey('viewerRandomFractalFab')));
    await tester.pump();
    expect(randomFractal, isTrue);

    await tester.tap(find.byKey(const ValueKey('viewerLooperFab')));
    await tester.pump();
    expect(looper, isTrue);
  });

  testWidgets('kaleidoscope FAB toggles kaleidoscope', (tester) async {
    var toggled = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onToggleKaleidoscope: () => toggled = true,
      onOpenWallpaper: () {},
    );

    await tester.tap(find.byKey(const ValueKey('viewerKaleidoscopeFab')));
    await tester.pump();
    expect(toggled, isTrue);
  });

  testWidgets('fractal music FAB toggles music', (tester) async {
    var toggled = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onToggleFractalMusic: () => toggled = true,
      onOpenWallpaper: () {},
    );

    await tester.tap(find.byKey(const ValueKey('viewerFractalMusicFab')));
    await tester.pump();
    expect(toggled, isTrue);
  });

  testWidgets('controls FAB randomizes on tap and opens controls on long press',
      (tester) async {
    var randomized = 0;
    var opened = 0;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenControls: () => opened++,
      onRandomizeParams: () => randomized++,
      onOpenWallpaper: () {},
    );

    final fab = find.byKey(const ValueKey('viewerRandomParamsButton'));
    await tester.tap(fab);
    await tester.pump();
    expect(randomized, 1);
    expect(opened, 0);

    await tester.longPress(fab);
    await tester.pump();
    expect(randomized, 1);
    expect(opened, 1);
  });

  testWidgets('controls FAB randomizes on Enter key when focused',
      (tester) async {
    var randomized = 0;
    await _pumpControls(
      tester,
      isExporting: false,
      onRandomizeParams: () => randomized++,
      onOpenWallpaper: () {},
    );

    final fabKey = const ValueKey('viewerRandomParamsButton');
    Focus.of(
      tester.element(
        find.descendant(
          of: find.byKey(fabKey),
          matching: find.byType(GestureDetector),
        ),
      ),
    ).requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(randomized, 1);
  });

  testWidgets(
      'controls FAB opens controls on Shift+Enter when focused (keyboard '
      'equivalent of long press)', (tester) async {
    var opened = 0;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenControls: () => opened++,
      onOpenWallpaper: () {},
    );

    final fabKey = const ValueKey('viewerRandomParamsButton');
    Focus.of(
      tester.element(
        find.descendant(
          of: find.byKey(fabKey),
          matching: find.byType(GestureDetector),
        ),
      ),
    ).requestFocus();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(opened, 1);
  });

  testWidgets('palette FAB long press opens palette picker', (tester) async {
    var opened = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenPalettePicker: () => opened = true,
      onOpenWallpaper: () {},
    );

    await tester
        .longPress(find.byKey(const ValueKey('viewerColorCycleButton')));
    await tester.pump();
    expect(opened, isTrue);
  });

  testWidgets('export FAB is disabled while exporting', (tester) async {
    var tapped = false;
    await _pumpControls(tester,
        isExporting: true, onOpenWallpaper: () => tapped = true);

    await tester.tap(
      find.byKey(const ValueKey('viewerExportButton')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, isFalse);
    expect(find.text('Export / Wallpaper'), findsNothing);
  });

  testWidgets('FABs dim while exporting so the inert state is visible',
      (tester) async {
    Finder dimmed(ValueKey<String> key) => find.descendant(
          of: find.byKey(key),
          matching: find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity < 1.0,
          ),
        );

    const fabKeys = [
      ValueKey('viewerExportButton'),
      ValueKey('viewerRandomParamsButton'),
      ValueKey('viewerTextOverlayFab'),
      ValueKey('viewerFourierFab'),
      ValueKey('viewerFullscreenButton'),
    ];

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    for (final key in fabKeys) {
      expect(dimmed(key), findsNothing, reason: '$key enabled');
    }

    await _pumpControls(tester, isExporting: true, onOpenWallpaper: () {});
    for (final key in fabKeys) {
      expect(dimmed(key), findsOneWidget, reason: '$key exporting');
    }
  });

  testWidgets('each FAB surfaces exactly one labelled screen-reader stop',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});
    await tester.pumpAndSettle();

    // Only nodes the platform surfaces: a node merged into an ancestor is not
    // a separate stop for TalkBack/VoiceOver.
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

    // Semantics live on this pipeline owner; rootPipelineOwner.semanticsOwner
    // is null in a widget test. Matches test/a11y/semantics/.
    // ignore: deprecated_member_use
    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

    expect(
      unlabeled,
      0,
      reason: 'the GestureDetector carrying onTap became its own bare stop',
    );
    expect(labels, hasLength(11), reason: 'one stop per visible FAB');
    expect(labels.toSet(), hasLength(11), reason: 'labels must be distinct');

    handle.dispose();
  });

  testWidgets('FAB taps keep firing haptics when reduced motion is on',
      (tester) async {
    final log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        log.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await _pumpControls(
      tester,
      isExporting: false,
      reduceMotion: true,
      onOpenWallpaper: () {},
    );

    await tester.tap(find.byKey(const ValueKey('viewerRandomParamsButton')));
    await tester.pump();

    expect(
      log.where((call) =>
          call.method == 'HapticFeedback.vibrate' &&
          call.arguments == 'HapticFeedbackType.mediumImpact'),
      isNotEmpty,
      reason: 'reduced motion must not suppress tap haptics',
    );
  });
}
