import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/viewer/chrome/viewer_overlay_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext host;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        host = context;
        return const Scaffold(body: Text('host'));
      }),
    ));
    return host;
  }

  testWidgets('presentCommand pauses motion once, then runs one command',
      (tester) async {
    var pauses = 0;
    var ran = 0;
    final host = await pumpHost(tester);
    final flow = ViewerOverlayFlow(context: host, pauseMotion: () => pauses++);

    unawaited(flow.presentCommand(
      builder: (sheetContext) => ElevatedButton(
        onPressed: () => Navigator.of(sheetContext).pop(() => ran++),
        child: const Text('choose'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(pauses, 1, reason: 'the flow pauses motion before presenting');
    expect(ran, 0, reason: 'the command runs after the sheet closes');

    await tester.tap(find.text('choose'));
    await tester.pumpAndSettle();
    expect(ran, 1, reason: 'one chosen command runs exactly once');
  });

  testWidgets('a dismissed command sheet runs nothing', (tester) async {
    var pauses = 0;
    var ran = 0;
    final host = await pumpHost(tester);
    final flow = ViewerOverlayFlow(context: host, pauseMotion: () => pauses++);

    unawaited(flow.presentCommand(
      builder: (sheetContext) => ElevatedButton(
        onPressed: () => Navigator.of(sheetContext).pop(() => ran++),
        child: const Text('choose'),
      ),
    ));
    await tester.pumpAndSettle();

    Navigator.of(host).pop();
    await tester.pumpAndSettle();
    expect(ran, 0);
  });

  testWidgets('present returns the typed result', (tester) async {
    final host = await pumpHost(tester);
    final flow = ViewerOverlayFlow(context: host);

    final result = flow.present<String>(
      builder: (sheetContext) => ElevatedButton(
        onPressed: () => Navigator.of(sheetContext).pop('value'),
        child: const Text('return'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('return'));
    await tester.pumpAndSettle();
    expect(await result, 'value');
  });
}
