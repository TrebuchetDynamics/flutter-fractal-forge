import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

final fullLink = Uri.parse(
    'https://example.test/view?type=mandelbrot&defaults=true&state=${List.filled(150, 'aBc012_-').join()}#palette=0&zoom=1');

Future<void> pumpLink(WidgetTester tester,
    {String locale = 'en',
    double scale = 1,
    Uint8List? preview,
    bool insets = false,
    Future<void> Function(String, {String? subject})? share}) async {
  await tester.pumpWidget(MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewPadding: EdgeInsets.only(bottom: insets ? 32 : 0),
          systemGestureInsets: EdgeInsets.only(bottom: insets ? 48 : 0),
          viewInsets: EdgeInsets.only(
              bottom: insets &&
                      MediaQuery.sizeOf(context).width >
                          MediaQuery.sizeOf(context).height
                  ? 80
                  : 0),
        ),
        child: child!),
    home: Scaffold(
        body: Builder(
            builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ShareSheet(
                        uri: fullLink,
                        fractalName: 'Mandelbrot',
                        shareText: share,
                        previewBytes: preview)),
                child: const Text('Open')))),
  ));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  final png = Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 3)));
  for (final locale in ['en', 'es']) {
    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 720),
      const Size(640, 360)
    ]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        for (final preview in [null, png]) {
          testWidgets(
              '$locale $size ${scale}x preview=${preview != null}: equal reachable link actions',
              (tester) async {
            await tester.binding.setSurfaceSize(size);
            addTearDown(() => tester.binding.setSurfaceSize(null));
            await pumpLink(tester,
                locale: locale, scale: scale, preview: preview, insets: true);
            final l10n =
                AppLocalizations.of(tester.element(find.byType(ShareSheet)))!;
            expect(find.text(fullLink.toString()), findsNothing);
            if (preview == null) {
              expect(find.byType(Image), findsNothing);
              expect(find.text(l10n.shareViewLinkPreviewUnavailable),
                  findsOneWidget);
            } else {
              expect(
                  (tester.widget<Image>(find.byType(Image)).image
                          as MemoryImage)
                      .bytes,
                  same(preview));
              expect(find.text(l10n.shareViewLinkPreviewUnavailable),
                  findsNothing);
            }
            final copy =
                find.widgetWithText(OutlinedButton, l10n.shareViewLinkCopy);
            final share =
                find.widgetWithText(FilledButton, l10n.shareViewLinkShare);
            expect(tester.getSize(copy), tester.getSize(share));
            expect(tester.getSize(copy).height, greaterThanOrEqualTo(48));
            for (final action in [copy, share]) {
              await tester.ensureVisible(action);
              await tester.pumpAndSettle();
              expect(action.hitTestable(), findsOneWidget);
              expect(
                  tester.getRect(action).bottom,
                  lessThanOrEqualTo(
                      size.height - (size.width > size.height ? 80 : 48)));
            }
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('clipboard failures remain visible and do not dismiss the sheet',
      (tester) async {
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData')
        throw PlatformException(code: 'clipboard unavailable');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpLink(tester);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(find.textContaining('clipboard unavailable').hitTestable(),
        findsOneWidget,
        reason: 'Failure feedback must be inside the modal, not behind it.');
    expect(find.byType(ShareSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('same-frame share activation starts only one native operation',
      (tester) async {
    var shares = 0;
    final pending = Completer<void>();
    await pumpLink(tester, share: (_, {subject}) {
      shares++;
      return pending.future;
    });
    final action = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Share link'));
    // Both callbacks can arrive before Flutter rebuilds the disabled button.
    action.onPressed!();
    action.onPressed!();
    expect(shares, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('link context replaces the URL wall; full disclosure is optional',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLink(tester);
    expect(
        tester
            .getSemantics(find.widgetWithText(TextButton, 'Show full link'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.isFalse);
    expect(find.text('Share view link'), findsOneWidget);
    expect(find.text('Mandelbrot'), findsOneWidget);
    expect(find.text('example.test/view'), findsOneWidget);
    expect(find.text(fullLink.toString()), findsNothing);
    expect(find.text('Preview unavailable'), findsOneWidget);
    await tester.tap(find.text('Show full link'));
    await tester.pumpAndSettle();
    expect(find.text(fullLink.toString()), findsOneWidget);
    expect(
        tester
            .getSemantics(find.widgetWithText(TextButton, 'Hide full link'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('copy and native share retain the entire identical original URI',
      (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpLink(tester);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(clipboard, fullLink.toString());
    String? shared;
    await pumpLink(tester, share: (text, {subject}) async {
      shared = text;
    });
    await tester.tap(find.text('Share link'));
    await tester.pumpAndSettle();
    expect(shared, contains(clipboard!));
    expect(Uri.parse(shared!.substring(shared!.indexOf('https://'))), fullLink);
  });

  testWidgets(
      'closing a sheet during a pending share does not pop another route',
      (tester) async {
    final pending = Completer<void>();
    await pumpLink(tester, share: (_, {subject}) => pending.future);
    await tester.tap(find.text('Share link'));
    await tester.tap(find.byTooltip('Close'));
    // Resolve during the exit animation, while the old State is still mounted.
    await tester.pump();
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
