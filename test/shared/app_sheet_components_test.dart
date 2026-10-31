import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/app_sheet_actions.dart';
import 'package:flutter_fractals/shared/widgets/app_sheet_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the shared modal frame and footer that feature sheets now reuse.
void main() {
  Widget host(Widget child, {double width = 390}) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      );

  group('AppSheetScaffold', () {
    testWidgets('renders header, scrollable body and pinned actions',
        (tester) async {
      await tester.pumpWidget(host(const AppSheetScaffold(
        icon: Icons.tune_rounded,
        title: 'Controls',
        subtitle: 'Mandelbrot',
        body: SizedBox(height: 2000, child: Text('parameter body')),
        actions: AppSheetActions(
          actions: [Text('action')],
        ),
      )));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('parameter body'), findsOneWidget);
      expect(find.text('action'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AppSheetScaffold),
              matching: find.byType(SingleChildScrollView)),
          findsOneWidget);
      expect(tester.getRect(find.byType(AppBottomSheetHeader)).top,
          lessThan(tester.getRect(find.text('parameter body')).top));
    });

    testWidgets('closes through the header button', (tester) async {
      var closed = false;
      await tester.pumpWidget(host(AppSheetScaffold(
        icon: Icons.tune_rounded,
        title: 'Controls',
        body: const Text('body'),
        onClose: () => closed = true,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });
  });

  group('AppSheetActions', () {
    Widget action(String label, Key key) =>
        AppActionButton(key: key, label: label, onPressed: () {});

    testWidgets('one action fills the footer width', (tester) async {
      const key = ValueKey('single');
      await tester
          .pumpWidget(host(AppSheetActions(actions: [action('Apply', key)])));
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byKey(key));
      expect(size.width, closeTo(390 - 2 * AppSpacing.md, 0.1));
      expect(
          size.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
    });

    testWidgets('two actions share a row on wide footers', (tester) async {
      const first = ValueKey('first');
      const second = ValueKey('second');
      await tester.pumpWidget(host(
        AppSheetActions(
            actions: [action('Cancel', first), action('Save', second)]),
        width: 520,
      ));
      await tester.pumpAndSettle();

      final a = tester.getRect(find.byKey(first));
      final b = tester.getRect(find.byKey(second));
      expect(a.center.dy, closeTo(b.center.dy, 0.1));
      expect(a.right, lessThan(b.left));
      expect(a.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
    });

    testWidgets('two actions stack on phone footers', (tester) async {
      const first = ValueKey('first');
      const second = ValueKey('second');
      await tester.pumpWidget(host(
        AppSheetActions(
            actions: [action('Cancel', first), action('Save', second)]),
        width: 320,
      ));
      await tester.pumpAndSettle();

      final a = tester.getRect(find.byKey(first));
      final b = tester.getRect(find.byKey(second));
      expect(a.top, lessThan(b.top));
      expect(a.width, closeTo(320 - 2 * AppSpacing.md, 0.1));
      expect(b.height, greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
    });

    testWidgets('extra action takes its own full-width row', (tester) async {
      const share = ValueKey('share');
      const save = ValueKey('save');
      const wallpaper = ValueKey('wallpaper');
      await tester.pumpWidget(host(
        AppSheetActions(
          actions: [action('Share', share), action('Save', save)],
          extra: action('Set as wallpaper', wallpaper),
        ),
        width: 520,
      ));
      await tester.pumpAndSettle();

      final shareRect = tester.getRect(find.byKey(share));
      final saveRect = tester.getRect(find.byKey(save));
      final wallpaperRect = tester.getRect(find.byKey(wallpaper));
      expect(wallpaperRect.top, greaterThan(shareRect.bottom));
      expect(wallpaperRect.width, closeTo(520 - 2 * AppSpacing.md, 0.1));
      expect(wallpaperRect.height,
          greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
      expect(shareRect.top, closeTo(saveRect.top, 0.1));
    });

    testWidgets('pinned footer paints a top border', (tester) async {
      await tester.pumpWidget(host(AppSheetActions(
        pinned: true,
        actions: [action('Save', const ValueKey('save'))],
      )));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(AppSheetActions),
              matching: find.byType(Container))
          .first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border! as Border).top.width, greaterThan(0));
    });
  });

  group('AppActionButton', () {
    testWidgets('primary and secondary use filled and outlined buttons',
        (tester) async {
      await tester.pumpWidget(host(Column(children: [
        AppActionButton(
            key: const ValueKey('primary'), label: 'Save', onPressed: () {}),
        AppActionButton(
            key: const ValueKey('secondary'),
            emphasis: AppActionEmphasis.secondary,
            label: 'Cancel',
            onPressed: () {}),
      ])));
      await tester.pumpAndSettle();

      expect(
          find.descendant(
              of: find.byKey(const ValueKey('primary')),
              matching: find.byType(FilledButton)),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('secondary')),
              matching: find.byType(OutlinedButton)),
          findsOneWidget);
    });

    testWidgets('disabled action keeps its target and reports disabled',
        (tester) async {
      await tester.pumpWidget(host(AppActionButton(
        key: const ValueKey('disabled'),
        label: 'Save',
        onPressed: null,
      )));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.descendant(
          of: find.byKey(const ValueKey('disabled')),
          matching: find.byType(FilledButton)));
      expect(button.onPressed, isNull);
      expect(tester.getSize(find.byKey(const ValueKey('disabled'))).height,
          greaterThanOrEqualTo(AccessibleSizing.minTouchTarget));
    });
  });

  group('AppDialog shared actions', () {
    testWidgets('builds cancel then confirm and calls both callbacks',
        (tester) async {
      var cancelled = false;
      var confirmed = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: AppDialog(
              icon: Icons.edit_rounded,
              title: 'Rename',
              cancelLabel: 'Cancel',
              onCancel: () => cancelled = true,
              confirmLabel: 'Save',
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.tap(find.text('Save'));
      expect(cancelled, isTrue);
      expect(confirmed, isTrue);
    });

    testWidgets('destructive confirm uses the error fill', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: AppDialog(
              icon: Icons.delete_rounded,
              title: 'Delete',
              cancelLabel: 'Cancel',
              onCancel: () {},
              confirmLabel: 'Delete',
              destructiveConfirm: true,
              onConfirm: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.style?.backgroundColor?.resolve(<WidgetState>{}),
          AppColors.error);
    });

    testWidgets('custom actions replace the shared pair', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: AppDialog(
              icon: Icons.info_rounded,
              title: 'Info',
              cancelLabel: 'Cancel',
              confirmLabel: 'Save',
              actions: [
                TextButton(onPressed: () {}, child: const Text('Close')),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Save'), findsNothing);
    });
  });
}
