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
            autoExploreService: null,
            isExporting: isExporting,
            backTooltip: 'Back',
            onGoBack: () {},
            onToggleFullscreen: () {},
            onOpenAutoExploreSettings: () {},
            onOpenRandomFractal: () {},
            onOpenControls: () {},
            onOpenExport: () {},
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
  testWidgets('wallpaper FAB is present and fires its callback',
      (tester) async {
    var tapped = false;
    await _pumpControls(tester,
        isExporting: false, onOpenWallpaper: () => tapped = true);

    final fab = find.byKey(const ValueKey('viewerWallpaperButton'));
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('wallpaper FAB is disabled while exporting', (tester) async {
    var tapped = false;
    await _pumpControls(tester,
        isExporting: true, onOpenWallpaper: () => tapped = true);

    await tester.tap(
      find.byKey(const ValueKey('viewerWallpaperButton')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, isFalse);
  });
}
