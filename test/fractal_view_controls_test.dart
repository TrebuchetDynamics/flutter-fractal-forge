import 'package:flutter/material.dart';
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
  VoidCallback? onOpenPalettePicker,
  VoidCallback? onOpenRandomFractal,
  bool kaleidoscopeEnabled = false,
  bool fractalMusicEnabled = false,
  bool showFractalReport = false,
  VoidCallback? onToggleKaleidoscope,
  VoidCallback? onReportFractal,
  required VoidCallback onOpenWallpaper,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: _Host(
          (controller) => FractalViewControls(
            fabController: controller,
            isExporting: isExporting,
            kaleidoscopeEnabled: kaleidoscopeEnabled,
            fractalMusicEnabled: fractalMusicEnabled,
            showFractalReport: showFractalReport,
            actions: FractalViewControlActions(
              toggleFullscreen: () {},
              openRandomFractal: onOpenRandomFractal ?? () {},
              openControls: () {},
              randomizeParams: () {},
              cycleColorScheme: () {},
              openPalettePicker: onOpenPalettePicker ?? () {},
              toggleKaleidoscope: onToggleKaleidoscope ?? () {},
              openExport: onOpenExport ?? () {},
              shareLink: onShareLink ?? () {},
              shareImage: onShareImage ?? () {},
              openLooper: onOpenLooper ?? () {},
              toggleFractalMusic: onToggleFractalMusic ?? () {},
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
  testWidgets('export FAB opens export/wallpaper actions', (tester) async {
    var exported = false;
    var sharedLink = false;
    var shared = false;
    var wallpaper = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenExport: () => exported = true,
      onShareLink: () => sharedLink = true,
      onShareImage: () => shared = true,
      onOpenWallpaper: () => wallpaper = true,
    );

    final fab = find.byKey(const ValueKey('viewerExportButton'));
    expect(fab, findsOneWidget);
    expect(find.byKey(const ValueKey('viewerWallpaperButton')), findsNothing);

    await tester.ensureVisible(fab);
    await tester.pumpAndSettle();
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerExportMenuItem')));
    await tester.pumpAndSettle();
    expect(exported, isTrue);

    await tester.ensureVisible(fab);
    await tester.pumpAndSettle();
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerShareLinkMenuItem')));
    await tester.pumpAndSettle();
    expect(sharedLink, isTrue);

    await tester.ensureVisible(fab);
    await tester.pumpAndSettle();
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerShareMenuItem')));
    await tester.pumpAndSettle();
    expect(shared, isTrue);

    expect(find.byKey(const ValueKey('viewerLooperMenuItem')), findsNothing);

    await tester.ensureVisible(fab);
    await tester.pumpAndSettle();
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerWallpaperMenuItem')));
    await tester.pumpAndSettle();
    expect(wallpaper, isTrue);
  });

  testWidgets('quick control FABs are present', (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    expect(
        find.byKey(const ValueKey('viewerFullscreenButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerPresetsButton')), findsNothing);
    expect(find.byKey(const ValueKey('viewerResetButton')), findsNothing);
    expect(find.byKey(const ValueKey('viewerResetParamsButton')), findsNothing);
    expect(find.byKey(const ValueKey('viewerIterationsButton')), findsNothing);
    expect(
        find.byKey(const ValueKey('viewerColorCycleButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerKaleidoscopeButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerRandomParamsButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerRandomButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerLooperButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerFractalMusicButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerReportFractalButton')), findsNothing);
    expect(find.byKey(const ValueKey('viewerBailoutButton')), findsNothing);
  });

  testWidgets('linux report FAB appears when enabled', (tester) async {
    var reported = false;
    await _pumpControls(
      tester,
      isExporting: false,
      showFractalReport: true,
      onReportFractal: () => reported = true,
      onOpenWallpaper: () {},
    );

    final button = find.byKey(const ValueKey('viewerReportFractalButton'));
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    expect(reported, isTrue);
  });

  testWidgets('quick control FABs keep accessible tap targets', (tester) async {
    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    const fabKeys = [
      ValueKey('viewerFullscreenButton'),
      ValueKey('viewerControlsButton'),
      ValueKey('viewerColorCycleButton'),
      ValueKey('viewerKaleidoscopeButton'),
      ValueKey('viewerRandomParamsButton'),
      ValueKey('viewerRandomButton'),
      ValueKey('viewerLooperButton'),
      ValueKey('viewerFractalMusicButton'),
      ValueKey('viewerExportButton'),
    ];

    for (final key in fabKeys) {
      final size = tester.getSize(find.byKey(key));
      expect(size.width, greaterThanOrEqualTo(48.0), reason: '$key width');
      expect(size.height, greaterThanOrEqualTo(48.0), reason: '$key height');
    }
  });

  testWidgets('quick control FABs expose screen-reader labels', (tester) async {
    final semantics = tester.ensureSemantics();

    await _pumpControls(tester, isExporting: false, onOpenWallpaper: () {});

    for (final label in const [
      'Fullscreen view',
      'Controls',
      'Color Scheme. Long press for palette',
      'Kaleidoscope off',
      'Randomize',
      'Random Fractal',
      'Camera looper',
      'Fractal Music off',
      'Export / Wallpaper',
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
      'Kaleidoscopio desactivado',
      'Bucle de cámara',
      'Música fractal desactivada',
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

    await tester.tap(find.byKey(const ValueKey('viewerRandomButton')));
    await tester.pump();
    expect(randomFractal, isTrue);

    await tester.tap(find.byKey(const ValueKey('viewerLooperButton')));
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

    await tester.tap(find.byKey(const ValueKey('viewerKaleidoscopeButton')));
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

    await tester.tap(find.byKey(const ValueKey('viewerFractalMusicButton')));
    await tester.pump();
    expect(toggled, isTrue);
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
    expect(find.byKey(const ValueKey('viewerWallpaperMenuItem')), findsNothing);
  });
}
