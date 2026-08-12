import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/diagnostics/performance_service.dart';
import 'package:flutter_fractals/features/debug/performance_overlay.dart';

void main() {
  testWidgets('full overlay labels real frame phases and process memory',
      (tester) async {
    final source = _FakeFrameTimingSource();
    final service = PerformanceService(
      frameTimingSource: source,
      memoryReader: () => 64 * 1024 * 1024,
    )..start();
    addTearDown(service.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FractalPerformanceOverlay(service: service),
      ),
    ));
    source.emit(List<FrameTiming>.filled(
      30,
      FrameTiming(
        vsyncStart: 0,
        buildStart: 1000,
        buildFinish: 5000,
        rasterStart: 6000,
        rasterFinish: 12000,
        rasterFinishWallTime: 12000,
      ),
    ));
    await tester.pump();

    expect(find.text('BUILD'), findsOneWidget);
    expect(find.text('4.0ms'), findsOneWidget);
    expect(find.text('RASTER'), findsOneWidget);
    expect(find.text('6.0ms'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('12.0ms'), findsNWidgets(2));
    expect(find.text('MEMORY'), findsOneWidget);
    expect(find.text('64.0 MB'), findsOneWidget);
  });

  testWidgets('full overlay says memory unavailable instead of fabricating it',
      (tester) async {
    final source = _FakeFrameTimingSource();
    final service = PerformanceService(
      frameTimingSource: source,
      memoryReader: () => null,
    )..start();
    addTearDown(service.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FractalPerformanceOverlay(service: service),
      ),
    ));
    source.emit(List<FrameTiming>.filled(
      30,
      FrameTiming(
        vsyncStart: 0,
        buildStart: 1000,
        buildFinish: 5000,
        rasterStart: 6000,
        rasterFinish: 12000,
        rasterFinishWallTime: 12000,
      ),
    ));
    await tester.pump();

    expect(find.text('MEMORY'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });
}

class _FakeFrameTimingSource implements FrameTimingSource {
  final List<TimingsCallback> _callbacks = [];

  @override
  void addTimingsCallback(TimingsCallback callback) => _callbacks.add(callback);

  @override
  void removeTimingsCallback(TimingsCallback callback) =>
      _callbacks.remove(callback);

  void emit(List<FrameTiming> timings) {
    for (final callback in List<TimingsCallback>.of(_callbacks)) {
      callback(timings);
    }
  }
}
