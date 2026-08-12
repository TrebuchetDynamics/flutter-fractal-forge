import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/app/flutter_fractals_app.dart';
import 'package:flutter_fractals/core/services/diagnostics/performance_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts and disposes its frame telemetry callback',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final source = _FakeFrameTimingSource();
    final service = PerformanceService(
      frameTimingSource: source,
      memoryReader: () => null,
    );

    await tester.pumpWidget(FlutterFractalsApp(
      presetStore: await PresetStore.create(),
      accessibilityService: await AccessibilityService.create(),
      rendererSettingsService: await RendererSettingsService.create(),
      performanceServiceFactory: () => service,
      locale: const Locale('en'),
      skipSplash: true,
    ));

    expect(source.callbackCount, 1);
    expect(service.isRunning, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(source.callbackCount, 0);
    expect(service.isRunning, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(source.callbackCount, 1);
    expect(service.isRunning, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(source.callbackCount, 0);
    expect(service.isRunning, isFalse);
  });
}

class _FakeFrameTimingSource implements FrameTimingSource {
  final List<TimingsCallback> _callbacks = [];

  int get callbackCount => _callbacks.length;

  @override
  void addTimingsCallback(TimingsCallback callback) => _callbacks.add(callback);

  @override
  void removeTimingsCallback(TimingsCallback callback) =>
      _callbacks.remove(callback);
}
