import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.dark, AppTheme.highContrast, AppTheme.oled]) {
    testWidgets('modal width is consistent for ${theme.colorScheme.surface}',
        (tester) async {
      const size = Size(1440, 900);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          builder: (_, child) =>
              MediaQuery(data: const MediaQueryData(size: size), child: child!),
          home: Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const AppBottomSheet(
                              children: [SizedBox(height: 100)])),
                      child: const Text('Open'))))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppBottomSheet)).width, 720);
      expect(find.byType(SheetDragHandle), findsOneWidget);
    });
  }
  testWidgets('long dialog content scrolls above the keyboard', (tester) async {
    const size = Size(320, 568);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        builder: (_, child) => MediaQuery(
            data: const MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(2),
                viewInsets: EdgeInsets.only(bottom: 240)),
            child: child!),
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AppDialog(
                                icon: Icons.edit_outlined,
                                title: 'Edit a saved view',
                                content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (var i = 0; i < 5; i++)
                                        const Text(
                                            'Existing details stay available.'),
                                      const TextField(
                                          key: ValueKey('dialogLastField'))
                                    ]),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'))
                                ])),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('dialogLastField')));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('dialogLastField'))).bottom,
        lessThanOrEqualTo(size.height - 240));
  });
  testWidgets('shared dialogs retain the selected accessible surface',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.highContrast,
      home: const Scaffold(
          body: AppDialog(
              icon: Icons.info_outline,
              title: 'Information',
              content: Text('Details remain readable.'))),
    ));
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(dialog.backgroundColor, AppTheme.highContrast.colorScheme.surface);
  });
}
