import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/app/startup.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The platform interface lets this test hold real startup stores pending.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/types.dart';

class _DelayedPreferences extends InMemorySharedPreferencesStore {
  _DelayedPreferences() : super.empty();

  final ready = Completer<void>();

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    await ready.future;
    return super.getAllWithParameters(parameters);
  }
}

void main() {
  const channel = MethodChannel('com.fractalforge/deeplink');
  const codec = StandardMethodCodec();

  Future<ByteData?> deliverLink(WidgetTester tester, String query) async {
    final response = Completer<ByteData?>();
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      codec.encodeMethodCall(
        MethodCall('onDeepLink', 'fractalforge://view?$query'),
      ),
      response.complete,
    );
    return response.future;
  }

  testWidgets('a link received while startup is loading opens the viewer',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => SharedPreferences.setMockInitialValues({}));
    final preferences = _DelayedPreferences();
    SharedPreferencesStorePlatform.instance = preferences;
    final initialLink = Completer<String?>();
    var requestedInitialLink = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) {
      expect(call.method, 'getInitialLink');
      requestedInitialLink = true;
      return initialLink.future;
    });

    await tester.pumpWidget(const DeferredStartupApp());
    expect(find.text('Loading...'), findsOneWidget);
    expect(requestedInitialLink, isTrue);
    final response = await deliverLink(tester, 'type=julia&zoom=7');
    expect(codec.decodeEnvelope(response!), isNull);
    expect(find.byType(FractalViewerScreen), findsNothing);

    preferences.ready.complete();
    initialLink.complete(null); // Launched normally, not via a URI.
    await tester.pump();
    await tester.pumpAndSettle();

    final viewer = find.byType(FractalViewerScreen, skipOffstage: false);
    expect(viewer, findsOneWidget);
    final controller = tester.element(viewer).read<FractalController>();
    expect(controller.module.id, 'julia');
    expect(controller.view.zoom, 7);
  });

  testWidgets('timed out startup releases its link handler before Retry',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final timedOutLink = Completer<String?>();
    var attempts = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      expect(call.method, 'getInitialLink');
      return ++attempts == 1 ? timedOutLink.future : null;
    });

    await tester.pumpWidget(const DeferredStartupApp(
      startupTimeout: Duration(seconds: 1),
    ));
    expect(find.text('Loading...'), findsOneWidget);
    final previousOnError = FlutterError.onError;
    final reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    try {
      await tester.pump(const Duration(seconds: 1));
    } finally {
      FlutterError.onError = previousOnError;
    }
    expect(find.text('Startup failed'), findsOneWidget);
    expect(reportedErrors.single.exception, isA<TimeoutException>());
    expect(await deliverLink(tester, 'type=julia'), isNull);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Startup failed'), findsNothing);
    timedOutLink.complete('fractalforge://view?type=mandelbrot');
    await tester.pumpAndSettle();
    expect(find.byType(FractalViewerScreen), findsNothing);

    final response = await deliverLink(tester, 'type=julia');
    expect(codec.decodeEnvelope(response!), isNull);
    await tester.pumpAndSettle();
    expect(find.byType(FractalViewerScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await deliverLink(tester, 'type=julia'), isNull);
  });
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
