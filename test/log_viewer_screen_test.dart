import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/features/debug/log_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LogViewerScreen(),
    );

void main() {
  setUp(() {
    AppLogger.instance.clear();
  });

  tearDown(() {
    AppLogger.instance.clear();
  });

  group('LogViewerScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(LogViewerScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AppBar has correct l10n title when empty', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // logViewerTitle(filtered, total) -> 'Log (0/0)' when no entries
      expect(find.text('Log (0/0)'), findsOneWidget);
    });

    testWidgets('AppBar title updates to reflect entry count', (tester) async {
      AppLogger.instance.info('test', 'hello');
      AppLogger.instance.warn('test', 'world');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // 2 entries, no filter => Log (2/2)
      expect(find.text('Log (2/2)'), findsOneWidget);
    });

    testWidgets('filter button is visible in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // PopupMenuButton uses filter_list_rounded icon
      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('filter popup shows All, Debug, Info, Warn, Error items',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Debug+'), findsOneWidget);
      expect(find.text('Info+'), findsOneWidget);
      expect(find.text('Warn+'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('export action button is present', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
    });

    testWidgets('clear action button is present', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('shows "No log entries" when logger is empty', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('No log entries'), findsOneWidget);
    });

    testWidgets('log entries display when logs exist', (tester) async {
      AppLogger.instance.info('action', 'user tapped zoom reset');
      AppLogger.instance.warn('render', 'frame dropped');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('No log entries'), findsNothing);
      expect(find.text('user tapped zoom reset'), findsOneWidget);
      expect(find.text('frame dropped'), findsOneWidget);
    });

    testWidgets('log entries show category label', (tester) async {
      AppLogger.instance.info('mycat', 'some message');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('mycat'), findsOneWidget);
    });

    testWidgets('filter to Warn+ hides Info entries', (tester) async {
      AppLogger.instance.info('cat', 'info only message');
      AppLogger.instance.warn('cat', 'warn message');
      AppLogger.instance.error('cat', 'error message');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Open filter menu and select Warn+
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warn+'));
      await tester.pumpAndSettle();

      expect(find.text('info only message'), findsNothing);
      expect(find.text('warn message'), findsOneWidget);
      expect(find.text('error message'), findsOneWidget);
    });

    testWidgets('filter to Error hides Info and Warn entries', (tester) async {
      AppLogger.instance.info('cat', 'info msg');
      AppLogger.instance.warn('cat', 'warn msg');
      AppLogger.instance.error('cat', 'error msg');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle();

      expect(find.text('info msg'), findsNothing);
      expect(find.text('warn msg'), findsNothing);
      expect(find.text('error msg'), findsOneWidget);
    });

    testWidgets('default (All) filter shows all log levels', (tester) async {
      // No filter selected — all entries visible by default
      AppLogger.instance.debug('cat', 'debug msg');
      AppLogger.instance.info('cat', 'info msg');
      AppLogger.instance.warn('cat', 'warn msg');
      AppLogger.instance.error('cat', 'error msg');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // All four entries should be visible without opening the filter menu
      expect(find.text('debug msg'), findsOneWidget);
      expect(find.text('info msg'), findsOneWidget);
      expect(find.text('warn msg'), findsOneWidget);
      expect(find.text('error msg'), findsOneWidget);
    });

    testWidgets('title count updates after filter selection', (tester) async {
      AppLogger.instance.info('cat', 'info msg');
      AppLogger.instance.error('cat', 'error msg');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Initially 2/2
      expect(find.text('Log (2/2)'), findsOneWidget);

      // Filter to Error only → 1 filtered, 2 total
      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle();

      expect(find.text('Log (1/2)'), findsOneWidget);
    });

    testWidgets('clear button removes all entries', (tester) async {
      AppLogger.instance.info('cat', 'will be cleared');

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('will be cleared'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No log entries'), findsOneWidget);
      expect(find.text('will be cleared'), findsNothing);
    });

    testWidgets('auto-scroll: new log entry triggers scroll attempt',
        (tester) async {
      // Seed 30 entries to ensure the list is scrollable
      for (int i = 0; i < 30; i++) {
        AppLogger.instance.info('cat', 'entry $i');
      }

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // The list should be present (not showing "No log entries")
      expect(find.text('No log entries'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);

      // Add a new entry after widget is mounted – listener fires setState + scroll
      AppLogger.instance.info('cat', 'new entry after mount');
      await tester.pumpAndSettle();

      // Screen stays intact with updated entry count
      expect(find.text('Log (31/31)'), findsOneWidget);
    });
  });
}
