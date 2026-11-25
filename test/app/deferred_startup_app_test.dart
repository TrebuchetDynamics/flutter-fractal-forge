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

class _DelayedPreferences extends InMemorySharedPreferencesStore {
  _DelayedPreferences() : super.empty();

  final ready = Completer<void>();
  bool requested = false;

  @override
  Future<Map<String, Object>> getAll() async {
    requested = true;
    await ready.future;
    return super.getAll();
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

  Future<void> expectStartupTimeout(WidgetTester tester) async {
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
  }

  FractalController viewerController(WidgetTester tester) {
    final viewer = find.byType(FractalViewerScreen, skipOffstage: false);
    expect(viewer, findsOneWidget);
    return tester.element(viewer).read<FractalController>();
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a link received while startup is loading opens the viewer',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
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
    expect(preferences.requested, isTrue);
    final response = await deliverLink(tester, 'type=julia&zoom=7');
    expect(codec.decodeEnvelope(response!), isNull);
    expect(find.byType(FractalViewerScreen), findsNothing);

    preferences.ready.complete();
    initialLink.complete(null); // Launched normally, not via a URI.
    await tester.pump();
    await tester.pumpAndSettle();

    final controller = viewerController(tester);
    expect(controller.module.id, 'julia');
    expect(controller.view.zoom, 7);
  });

  testWidgets('buffered links report busy while a link is being applied',
      (tester) async {
    final initialLink = Completer<String?>();
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) => initialLink.future);
    await tester.pumpWidget(const DeferredStartupApp());
    expect(find.text('Loading...'), findsOneWidget);
    await deliverLink(tester,
        'type=number_wall&param.prime=%2297%22&param.rows=4&param.columns=16');
    await deliverLink(tester, 'type=julia&zoom=7');
    initialLink.complete(null);
    await tester.pumpAndSettle();

    final controller = viewerController(tester);
    expect(controller.module.id, 'number_wall');
    expect(
      find.text('Finish the current operation, then open the link again.'),
      findsOneWidget,
    );
    await deliverLink(tester, 'type=julia&zoom=7');
    await tester.pumpAndSettle();
    expect(controller.module.id, 'julia');
    expect(controller.view.zoom, 7);
  });

  testWidgets('Retry retains runtime links while retrying the initial lookup',
      (tester) async {
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
    final response = await deliverLink(tester, 'type=julia&zoom=7');
    expect(codec.decodeEnvelope(response!), isNull);
    await expectStartupTimeout(tester);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Startup failed'), findsNothing);
    final controller = viewerController(tester);
    expect(controller.module.id, 'julia');
    expect(controller.view.zoom, 7);

    timedOutLink.complete('fractalforge://view?type=mandelbrot');
    await tester.pumpAndSettle();
    expect(controller.module.id, 'julia');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await deliverLink(tester, 'type=julia'), isNull);
  });

  testWidgets('Retry retains the launch link already consumed by native code',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = _DelayedPreferences();
    SharedPreferencesStorePlatform.instance = preferences;
    String? launchLink = 'fractalforge://view?type=julia&zoom=7';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      expect(call.method, 'getInitialLink');
      final result = launchLink;
      launchLink = null; // iOS returns the launch link only once.
      return result;
    });
    await tester.pumpWidget(const DeferredStartupApp(
      startupTimeout: Duration(seconds: 1),
    ));
    expect(find.text('Loading...'), findsOneWidget);
    expect(preferences.requested, isTrue);
    expect(launchLink, isNull);
    await expectStartupTimeout(tester);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    preferences.ready.complete();
    await tester.pumpAndSettle();
    final controller = viewerController(tester);
    expect(controller.module.id, 'julia');
    expect(controller.view.zoom, 7);
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
