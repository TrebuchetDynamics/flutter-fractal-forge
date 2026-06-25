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
  required bool isExporting,
  VoidCallback? onOpenExport,
  VoidCallback? onShareImage,
  VoidCallback? onOpenLooper,
  VoidCallback? onOpenPalettePicker,
  VoidCallback? onOpenRandomFractal,
  VoidCallback? onResetParams,
  VoidCallback? onDecreaseIterations,
  bool kaleidoscopeEnabled = false,
  VoidCallback? onToggleKaleidoscope,
  required VoidCallback onOpenWallpaper,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: _Host(
          (controller) => FractalViewControls(
            fabController: controller,
            isExporting: isExporting,
            onToggleFullscreen: () {},
            onOpenRandomFractal: onOpenRandomFractal ?? () {},
            onOpenControls: () {},
            onOpenPresets: () {},
            onResetView: () {},
            onResetParams: onResetParams ?? () {},
            onRandomizeParams: () {},
            onDecreaseIterations: onDecreaseIterations ?? () {},
            onIncreaseIterations: () {},
            onCycleColorScheme: () {},
            onOpenPalettePicker: onOpenPalettePicker ?? () {},
            kaleidoscopeEnabled: kaleidoscopeEnabled,
            onToggleKaleidoscope: onToggleKaleidoscope ?? () {},
            onOpenExport: onOpenExport ?? () {},
            onShareImage: onShareImage ?? () {},
            onOpenLooper: onOpenLooper ?? () {},
            onOpenWallpaper: onOpenWallpaper,
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
    var shared = false;
    var looper = false;
    var wallpaper = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onOpenExport: () => exported = true,
      onShareImage: () => shared = true,
      onOpenLooper: () => looper = true,
      onOpenWallpaper: () => wallpaper = true,
    );

    final fab = find.byKey(const ValueKey('viewerExportButton'));
    expect(fab, findsOneWidget);
    expect(find.byKey(const ValueKey('viewerWallpaperButton')), findsNothing);

    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerExportMenuItem')));
    await tester.pumpAndSettle();
    expect(exported, isTrue);

    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerShareMenuItem')));
    await tester.pumpAndSettle();
    expect(shared, isTrue);

    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('viewerLooperMenuItem')));
    await tester.pumpAndSettle();
    expect(looper, isTrue);

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
    expect(find.byKey(const ValueKey('viewerPresetsButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerResetButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerResetParamsButton')), findsNothing);
    expect(
        find.byKey(const ValueKey('viewerIterationsButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerIterationsDownButton')), findsNothing);
    expect(
        find.byKey(const ValueKey('viewerIterationsUpButton')), findsNothing);
    expect(
        find.byKey(const ValueKey('viewerColorCycleButton')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('viewerKaleidoscopeButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewerBailoutButton')), findsNothing);
  });

  testWidgets('merged FABs expose long-press secondary actions',
      (tester) async {
    var resetParams = false;
    var decreaseIterations = false;
    var randomFractal = false;
    await _pumpControls(
      tester,
      isExporting: false,
      onResetParams: () => resetParams = true,
      onDecreaseIterations: () => decreaseIterations = true,
      onOpenRandomFractal: () => randomFractal = true,
      onOpenWallpaper: () {},
    );

    await tester.longPress(find.byKey(const ValueKey('viewerResetButton')));
    await tester.pump();
    expect(resetParams, isTrue);

    await tester
        .longPress(find.byKey(const ValueKey('viewerIterationsButton')));
    await tester.pump();
    expect(decreaseIterations, isTrue);

    await tester.longPress(find.byKey(const ValueKey('viewerRandomButton')));
    await tester.pump();
    expect(randomFractal, isTrue);
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
