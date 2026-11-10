import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/physical_events_oracle.dart';

void main() {
  testWidgets(
      'gesture clock defaults to now and only backs missing source time',
      (tester) async {
    const defaultRenderer = FractalRenderer();
    final before = DateTime.now();
    final observed = defaultRenderer.gestureClock();
    expect(observed.isBefore(before), isFalse);
    expect(observed.isAfter(DateTime.now()), isFalse);
    var reads = 0;
    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
            home: SizedBox(
                width: 300,
                height: 240,
                child: FractalRenderer(
                    overrideChild: const ColoredBox(color: Colors.black),
                    gestureClock: () {
                      reads++;
                      return DateTime.utc(2026);
                    })))));
    final detector = tester
        .widgetList<GestureDetector>(find.descendant(
            of: find.byType(FractalRenderer),
            matching: find.byType(GestureDetector)))
        .firstWhere((widget) => widget.onScaleUpdate != null);
    detector.onScaleStart!(ScaleStartDetails(pointerCount: 1));
    detector.onScaleUpdate!(ScaleUpdateDetails(
        pointerCount: 1,
        focalPoint: const Offset(100, 100),
        sourceTimeStamp: Duration.zero));
    expect(reads, 0,
        reason: 'Source timestamp takes precedence, including zero');
    detector.onScaleUpdate!(ScaleUpdateDetails(
        pointerCount: 1, focalPoint: const Offset(110, 100)));
    expect(reads, 1,
        reason: 'Missing source timestamp uses the injected clock');
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets(
      'ordered production physical oracle is deterministic and immutable',
      (tester) async {
    final file = File('migration/oracles/physical-events.json');
    final before = file.existsSync() ? file.readAsStringSync() : null;
    final actual = await buildPhysicalEventsOracle(tester);
    expect(canonicalJson(await buildPhysicalEventsOracle(tester)),
        canonicalJson(actual));
    final scenarios = (actual['scenarios'] as List).cast<Map>();
    Map scenario(String id) => scenarios.singleWhere((s) => s['id'] == id);
    Map checkpoint(String id, String label) =>
        (scenario(id)['expected'] as List)
            .cast<Map>()
            .singleWhere((c) => c['label'] == label);
    List callbacks(String id, String label) =>
        checkpoint(id, label)['callbacks'] as List;
    double zoom(String id, String label) =>
        checkpoint(id, label)['state']['view']['zoom'] as double;

    for (final ms in [219, 220, 221]) {
      for (final distance in [17.999, 18.0, 18.001]) {
        final id = 'two-finger/$ms/$distance';
        // At this movement Flutter starts a one-finger handoff on release,
        // cancelling the admitted tap animation. Preserve that source outcome.
        expect(callbacks(id, 'released').where((c) => c == 'start'),
            hasLength(ms <= 220 && distance <= 18 ? 2 : 1),
            reason: id);
        expect(zoom(id, 'settled'), 10, reason: id);
      }
    }
    for (final ms in [219, 220, 221]) {
      final id = 'two-finger/$ms/0.0';
      expect(callbacks(id, 'released').where((c) => c == 'start'),
          hasLength(ms <= 220 ? 2 : 1),
          reason: id);
      expect(zoom(id, 'settled'), 10, reason: id);
    }
    for (final ms in [279, 280, 281]) {
      for (final distance in [27.999, 28.0, 28.001]) {
        final id = 'raw-double/$ms/$distance';
        expect(zoom(id, 'settled'), ms <= 280 && distance <= 28 ? 20 : 10,
            reason: id);
      }
    }
    for (final ms in [119, 120, 121]) {
      expect(zoom('duplicate/$ms', 'settled'), ms < 120 ? 20 : 40);
    }
    for (final angle in [0.119999, 0.12, 0.120001]) {
      for (final locked in [false, true]) {
        final rotation = checkpoint('twist/$angle/$locked', 'twisted')['state']
            ['view']['rotation'][2] as double;
        expect(rotation, !locked && angle > .12 ? closeTo(angle, 1e-12) : 0);
      }
    }
    for (final module in ['mandelbrot', 'mandelbulb', 'quaternion_julia_3d']) {
      Map? reference;
      for (final cadence in [8333, 16667, 33333, 100000]) {
        final id = 'fling/$module/$cadence';
        final current =
            checkpoint(id, 'cadence-320000')['state']['view'] as Map;
        reference ??= current;
        for (final field in ['pan', 'rotation']) {
          final values = current[field] as List;
          final expected = reference[field] as List;
          for (var i = 0; i < values.length; i++) {
            expect(values[i], closeTo(expected[i] as num, 1e-8), reason: id);
          }
        }
        expect(callbacks(id, 'released').where((c) => c == 'end'), isEmpty);
        expect(callbacks(id, 'settled').where((c) => c == 'end'), hasLength(1));
        expect(callbacks(id, 'no-second-completion'), callbacks(id, 'settled'));
      }
    }
    for (final speed in [4.999, 5.0, 5.001]) {
      final id = 'fling-threshold/$speed';
      expect(
          callbacks(id, 'released'), speed > 5 ? ['start'] : ['start', 'end']);
      expect(callbacks(id, 'settled'), ['start', 'end']);
    }
    for (final module in ['mandelbrot', 'mandelbulb']) {
      final id = 'pinch-release/$module';
      expect(zoom(id, 'momentum'), greaterThan(zoom(id, 'released')));
      expect(callbacks(id, 'released'), ['start']);
      expect(callbacks(id, 'settled'), ['start', 'end']);
      expect(callbacks(id, 'no-second-completion'), ['start', 'end']);
    }
    for (final prefix in ['interruption', 'double-interruption']) {
      expect(callbacks('$prefix/new-input', 'old-owner-cannot-complete'),
          ['start', 'start']);
      expect(
          callbacks('$prefix/new-input', 'settled'), ['start', 'start', 'end']);
      for (final action in ['module', 'dispose']) {
        expect(callbacks('$prefix/$action', 'settled'), ['start']);
        expect(callbacks('$prefix/$action', 'no-second-completion'), ['start']);
      }
    }
    final nested = checkpoint('nested-controls', 'control-consumed');
    expect(nested['controlValue'], greaterThan(2));
    final nestedInitial =
        Map.from(scenario('nested-controls')['initial'] as Map)
          ..remove('viewport')
          ..remove('wallEpoch')
          ..remove('focus')
          ..remove('controlValue')
          ..remove('animationEnabled')
          ..remove('wallUs')
          ..remove('pumpUs');
    expect(nested['state'], nestedInitial);
    expect(nested['callbacks'], isEmpty);
    for (final s in scenarios
        .where((s) => (s['id'] as String).startsWith('viewer-keys/'))) {
      final outputs = (s['expected'] as List).cast<Map>();
      final control = outputs
          .where((o) => (o['routed'] as String).endsWith('control-handled'));
      expect(control, hasLength(physicalKeys.length * 3));
      expect(
          control.map((o) => o['state']), everyElement(control.first['state']));
      final repeats =
          outputs.where((o) => o['routed'] == 'KeyRepeatEvent/ignored');
      expect(repeats, hasLength(physicalKeys.length));
      if (s['id'] == 'viewer-keys/gaussian_prime_lattice') {
        expect(outputs.take(physicalKeys.length * 3).map((o) => o['routed']),
            everyElement(endsWith('/ignored')));
      }
    }

    void compare(Object? expected) => expect(actual, expected);
    if (physicalEventsOutput.isEmpty) {
      compare(jsonDecode(file.readAsStringSync()));
      expect(before, canonicalJson(actual));
    }
    final sourceMutation = jsonDecode(canonicalJson(actual)) as Map;
    sourceMutation['source_bindings'][
            'lib/features/renderer/widgets/renderer/input/gesture_handler.dart'] =
        'mutated';
    expect(() => compare(sourceMutation), throwsA(isA<TestFailure>()));
    final nestedMutation = jsonDecode(canonicalJson(actual)) as Map;
    nestedMutation['scenarios'][0]['expected'][0]['state']['view']['pan'][0] =
        999;
    expect(() => compare(nestedMutation), throwsA(isA<TestFailure>()));
    expect(file.existsSync() ? file.readAsStringSync() : null, before);

    expect(() => exportPhysicalEventsOracle(actual, 'relative'),
        throwsArgumentError);
    expect(() => exportPhysicalEventsOracle(actual, Directory.current.path),
        throwsArgumentError);
    expect(
        () => exportPhysicalEventsOracle(
            actual, '${Directory.current.path}/migration/oracles/forbidden'),
        throwsArgumentError);
    final scratch = Directory.systemTemp.createTempSync('physical-export-');
    try {
      final forbidden = Directory(
          '${Directory.current.path}/migration/oracles/forbidden-physical-export');
      final absentPrefix = Directory('${scratch.path}/absent');
      final parents = List.filled(
              scratch.uri.pathSegments.where((s) => s.isNotEmpty).length + 1,
              '..')
          .join('/');
      expect(forbidden.existsSync(), isFalse);
      expect(
          () => exportPhysicalEventsOracle(
              actual, '${absentPrefix.path}/$parents${forbidden.path}'),
          throwsArgumentError);
      expect(forbidden.existsSync(), isFalse);
      expect(absentPrefix.existsSync(), isFalse);
      exportPhysicalEventsOracle(actual, scratch.path);
      expect(File('${scratch.path}/physical-events.json').readAsStringSync(),
          canonicalJson(actual));
      expect(() => exportPhysicalEventsOracle(actual, scratch.path),
          throwsStateError);
      final link = Link('${scratch.path}/checkout')
        ..createSync(Directory.current.path);
      expect(() => exportPhysicalEventsOracle(actual, '${link.path}/forbidden'),
          throwsArgumentError);
    } finally {
      scratch.deleteSync(recursive: true);
    }
    exportPhysicalEventsOracle(actual, physicalEventsOutput);
  });
}
