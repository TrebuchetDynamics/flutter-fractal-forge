import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/app/startup.dart';

void main() {
  testWidgets('DeferredStartupApp shows retry UI instead of hanging forever',
      (tester) async {
    final previousOnError = FlutterError.onError;
    final reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(DeferredStartupApp(
      fullAppLoader: () => Completer<Widget>().future,
      startupTimeout: const Duration(milliseconds: 1),
    ));

    expect(find.text('Loading...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();

    expect(find.text('Loading...'), findsNothing);
    expect(find.text('Startup failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(reportedErrors, isNotEmpty);
  });

  testWidgets('DeferredStartupApp retry can recover after startup failure',
      (tester) async {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = previousOnError);

    var attempts = 0;
    await tester.pumpWidget(DeferredStartupApp(
      fullAppLoader: () async {
        attempts += 1;
        if (attempts == 1) {
          throw StateError('first startup failed');
        }
        return const MaterialApp(home: Text('Recovered app'));
      },
      startupTimeout: const Duration(seconds: 1),
    ));

    await tester.pump();

    expect(find.text('Startup failed'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Recovered app'), findsOneWidget);
  });
}
