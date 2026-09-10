import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/platform/browser_view_url_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation, null);
  });

  testWidgets('coalesces edits into the latest state without growing history',
      (tester) async {
    var uri =
        Uri.parse('https://fractal.trebuchetdynamics.com/?type=julia&zoom=2');
    final sync = BrowserViewUrlSync(readUri: () => uri);
    sync.schedule();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, isEmpty);
    uri = uri.replace(query: 'type=julia&zoom=9');
    sync.schedule();
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, hasLength(1));
    expect(calls.single.method, 'routeInformationUpdated');
    expect(calls.single.arguments['uri'], '/?type=julia&zoom=9');
    expect(calls.single.arguments['replace'], isTrue);
    sync.schedule();
    await tester.pump(const Duration(milliseconds: 500));
    expect(calls, hasLength(1),
        reason: 'Unchanged state needs no history write');
    sync.dispose();
    await tester.pump();
  });

  testWidgets('closing cancels queued updates and restores the catalog URL',
      (tester) async {
    final sync = BrowserViewUrlSync(
      readUri: () =>
          Uri.parse('https://fractal.trebuchetdynamics.com/?type=julia'),
    );
    sync.schedule();
    sync.dispose();
    sync.schedule();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, hasLength(1));
    expect(calls.single.arguments['uri'], '/');
    expect(calls.single.arguments['replace'], isTrue);
  });
}
