import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

// Reuse the locked hashing dependency and canonical oracle JSON writer.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import 'baseline_inventory.dart' show canonicalJson;
export 'baseline_inventory.dart' show canonicalJson;

const physicalEventsOutput =
    String.fromEnvironment('MIGRATION_PHYSICAL_EVENTS_OUT');

/// Only raw events and explicit clocks are inputs. No Scale*Details replay.
class PhysicalScenario {
  PhysicalScenario(this.id,
      {this.module = 'mandelbrot',
      this.locked = false,
      this.zoom = 10,
      this.pan = 0,
      this.rotation = 0});
  final String id;
  final String module;
  final bool locked;
  final double zoom, pan, rotation;
  final events = <Map<String, Object?>>[];
  int _sourceUs = 0;

  void add(String op, [Map<String, Object?> values = const {}]) => events.add({
        'seq': events.length,
        'op': op,
        if (op == 'key') 'sourceUs': 0,
        ...values
      });
  void wall(int us) => add('wall', {'us': us});
  void pump(int us) => add('pump', {'us': us});
  void check(String label) => add('checkpoint', {'label': label});
  void pointer(String op, int id, double x, double y, {int? sourceUs}) {
    _sourceUs = sourceUs ?? _sourceUs + 16000;
    add(op, {
      'pointer': id,
      'kind': 'touch',
      'buttons': op == 'down' || op == 'move' ? kPrimaryButton : 0,
      'local': [x, y],
      'sourceUs': _sourceUs
    });
  }

  void tap(int id, double x, double y) {
    pointer('down', id, x, y);
    pointer('up', id, x, y);
  }

  void finish() {
    pump(0);
    pump(2100000);
    check('settled');
    pump(2100000);
    check('no-second-completion');
  }
}

List<PhysicalScenario> physicalScenarios() {
  final result = <PhysicalScenario>[];
  // Same physical release, independently pumped cadences (1e-8 comparison).
  for (final module in ['mandelbrot', 'mandelbulb', 'quaternion_julia_3d']) {
    for (final cadence in [8333, 16667, 33333, 100000]) {
      final s = PhysicalScenario('fling/$module/$cadence', module: module);
      s.wall(0);
      s.pointer('down', 1, 80, 80);
      for (var i = 0; i < 8; i++) {
        s.pointer('move', 1, 110.0 + i * 15, 95.0 + i * 5);
      }
      s.check('drag');
      s.pointer('up', 1, 215, 130);
      s.check('released');
      s.pump(0);
      var elapsed = 0;
      while (elapsed < 320000) {
        final dt = math.min(cadence, 320000 - elapsed);
        s.pump(dt);
        elapsed += dt;
      }
      s.check('cadence-320000');
      s.finish();
      result.add(s);
    }
  }
  for (final speed in [4.999, 5.0, 5.001]) {
    final s = PhysicalScenario('fling-threshold/$speed');
    s.wall(0);
    s.pointer('down', 1, 80, 100, sourceUs: 0);
    s.pointer('move', 1, 120, 100, sourceUs: 16000);
    s.pointer('move', 1, 120 + speed, 100, sourceUs: 32000);
    s.pointer('up', 1, 120 + speed, 100, sourceUs: 48000);
    s.check('released');
    s.finish();
    result.add(s);
  }
  for (final module in ['mandelbrot', 'mandelbulb']) {
    final s = PhysicalScenario('bounds/$module',
        module: module, zoom: 1e-9, pan: 2.99);
    s.wall(0);
    s.pointer('down', 1, 140, 100);
    s.pointer('move', 1, 50, 200);
    s.pointer('move', 1, -1000, 1000);
    s.check('bounded-drag');
    s.pointer('up', 1, -1000, 1000);
    s.finish();
    result.add(s);
  }
  for (final module in ['mandelbrot', 'mandelbulb']) {
    for (final locked in [false, true]) {
      final s = PhysicalScenario('pinch-handoff/$module/$locked',
          module: module, locked: locked);
      s.wall(0);
      s.pointer('down', 1, 80, 110);
      s.pointer('down', 2, 180, 110);
      s.pointer('move', 1, 40, 90);
      s.pointer('move', 2, 240, 150);
      s.check('pinched');
      s.pointer('up', 2, 240, 150);
      s.pointer('move', 1, 50, 95);
      s.check('handoff');
      s.pointer('move', 1, 85, 125);
      s.check('resumed');
      s.pointer('up', 1, 85, 125);
      s.finish();
      result.add(s);
    }
  }
  for (final module in ['mandelbrot', 'mandelbulb']) {
    final s = PhysicalScenario('pinch-release/$module', module: module);
    s.wall(0);
    s.pointer('down', 1, 90, 100);
    s.pointer('down', 2, 190, 100);
    s.pointer('move', 1, 50, 100);
    s.pointer('move', 2, 230, 100);
    s.pointer('move', 1, 20, 100);
    s.pointer('move', 2, 270, 100);
    s.check('pinched');
    s.pointer('up', 1, 20, 100);
    s.pointer('up', 2, 270, 100);
    s.check('released');
    s.pump(0);
    s.pump(320000);
    s.check('momentum');
    s.finish();
    result.add(s);
  }
  // Activate recognizer with a large pinch first, then vary only the twist.
  for (final angle in [0.119999, 0.12, 0.120001]) {
    for (final locked in [false, true]) {
      final s = PhysicalScenario('twist/$angle/$locked', locked: locked);
      s.wall(0);
      s.pointer('down', 1, 220, 120);
      s.pointer('down', 2, 60, 120);
      s.pointer('move', 1, 260, 120);
      s.pointer('move', 2, 20, 120);
      s.pointer(
          'move', 2, 260 - 240 * math.cos(angle), 120 - 240 * math.sin(angle));
      s.check('twisted');
      s.pointer('cancel', 1, 260, 120);
      s.pointer('cancel', 2, 260 - 240 * math.cos(angle),
          120 - 240 * math.sin(angle));
      s.finish();
      result.add(s);
    }
  }
  for (final ms in [219, 220, 221]) {
    for (final distance in [0.0, 17.999, 18.0, 18.001]) {
      final s = PhysicalScenario('two-finger/$ms/$distance');
      s.wall(0);
      s.pointer('down', 1, 80, 100);
      s.pointer('down', 2, 180, 100);
      if (distance != 0) s.pointer('move', 1, 80 + distance, 100);
      s.wall(ms * 1000);
      s.pointer('up', 1, 80 + distance, 100);
      s.pointer('up', 2, 180, 100);
      s.check('released');
      s.finish();
      result.add(s);
    }
  }
  for (final ms in [279, 280, 281]) {
    for (final distance in [27.999, 28.0, 28.001]) {
      final s = PhysicalScenario('raw-double/$ms/$distance');
      s.wall(0);
      s.tap(1, 100, 100);
      // Pump recognizer time separately: these pairs deliberately exercise the
      // raw fallback, not Flutter's own 300ms double-tap recognizer.
      s.pump(400000);
      s.wall(ms * 1000);
      s.tap(2, 100 + distance, 100);
      s.check('second-tap');
      s.finish();
      result.add(s);
    }
  }
  for (final ms in [119, 120, 121]) {
    final s = PhysicalScenario('duplicate/$ms');
    s.wall(0);
    s.tap(1, 100, 100);
    s.pump(400000);
    s.wall(10000);
    s.tap(2, 100, 100);
    s.pump(0);
    s.pump(210000);
    s.check('first-double');
    s.tap(3, 100, 100);
    s.pump(400000);
    s.wall(10000 + ms * 1000);
    s.tap(4, 100, 100);
    s.check('duplicate-request');
    s.finish();
    result.add(s);
  }
  for (final interruption in ['cancel', 'new-input', 'module', 'dispose']) {
    final s = PhysicalScenario('interruption/$interruption');
    s.wall(0);
    s.pointer('down', 1, 50, 80);
    s.pointer('move', 1, 100, 80);
    s.pointer('move', 1, 160, 80);
    s.pointer('move', 1, 220, 80);
    s.pointer(interruption == 'cancel' ? 'cancel' : 'up', 1, 220, 80);
    s.pump(0);
    s.pump(16000);
    s.check('in-flight');
    if (interruption == 'new-input') {
      s.pointer('down', 2, 60, 100);
      s.pointer('move', 2, 100, 100);
      s.check('replacement');
      s.pump(2100000);
      s.check('old-owner-cannot-complete');
      s.pointer('cancel', 2, 100, 100);
    } else if (interruption == 'module') {
      s.add('module', {'id': 'julia'});
    } else if (interruption == 'dispose') {
      s.add('dispose');
    }
    s.finish();
    result.add(s);
  }
  for (final interruption in ['new-input', 'module', 'dispose']) {
    final s = PhysicalScenario('double-interruption/$interruption');
    s.wall(0);
    s.tap(1, 100, 100);
    s.pump(400000);
    s.wall(10000);
    s.tap(2, 100, 100);
    s.pump(0);
    s.pump(50000);
    s.check('in-flight');
    if (interruption == 'new-input') {
      s.pointer('down', 3, 140, 100);
      s.pointer('move', 3, 190, 100);
      s.check('replacement');
      s.pump(500000);
      s.check('old-owner-cannot-complete');
      s.pointer('cancel', 3, 190, 100);
    } else if (interruption == 'module') {
      s.add('module', {'id': 'julia'});
    } else {
      s.add('dispose');
    }
    s.finish();
    result.add(s);
  }
  for (final module in ['mandelbrot', 'mandelbulb', 'cantor_set']) {
    final s = PhysicalScenario('wheel/$module', module: module);
    for (final delta in [-200.0, 200.0, -1e8, 1e8]) {
      s.add('wheel', {
        'local': [200.0, 90.0],
        'delta': [0.0, delta],
        'kind': 'mouse',
        'buttons': 0,
        'sourceUs': 12345
      });
      s.check('wheel-$delta');
    }
    result.add(s);
  }
  final nested = PhysicalScenario('nested-controls');
  nested.add('focus', {'target': 'control'});
  nested.add('key', {'type': 'down', 'key': 'right'});
  nested.add('key', {'type': 'repeat', 'key': 'right'});
  nested.add('key', {'type': 'up', 'key': 'right'});
  nested.pointer('down', 1, 35, 25);
  nested.pointer('move', 1, 70, 25);
  nested.pointer('move', 1, 90, 25);
  nested.pointer('up', 1, 90, 25);
  nested.check('control-consumed');
  nested.finish();
  result.add(nested);
  return result;
}

Map<String, Object?> physicalSnapshot(FractalController controller) => {
      'module': controller.module.id,
      'view': {
        'zoom': controller.view.zoom,
        'pan': [controller.view.pan.x, controller.view.pan.y],
        'rotation': [
          controller.view.rotation.x,
          controller.view.rotation.y,
          controller.view.rotation.z
        ]
      },
      'params': Map<String, Object>.from(controller.params),
      'effects': {
        'rotationLocked': controller.rotationLocked,
        'fluidMode': controller.fluidModeEnabled,
        'transparentBackground': controller.transparentBackground
      },
    };

final physicalKeys = <String, LogicalKeyboardKey>{
  'left': LogicalKeyboardKey.arrowLeft,
  'right': LogicalKeyboardKey.arrowRight,
  'up': LogicalKeyboardKey.arrowUp,
  'down': LogicalKeyboardKey.arrowDown,
  'plus': LogicalKeyboardKey.equal,
  'minus': LogicalKeyboardKey.minus,
  'reset': LogicalKeyboardKey.keyR,
  'unknown': LogicalKeyboardKey.keyQ,
};

Future<void> sendPhysicalKey(WidgetTester tester, Map event) async {
  // Flutter's key simulator supplies Duration.zero, unlike pointer timestamps.
  expect(event['sourceUs'], 0);
  final key = physicalKeys[event['key']]!;
  switch (event['type']) {
    case 'down':
      await tester.sendKeyDownEvent(key);
    case 'repeat':
      await tester.sendKeyRepeatEvent(key);
    case 'up':
      await tester.sendKeyUpEvent(key);
    default:
      throw StateError('Unknown key type');
  }
}

Future<Map<String, Object?>> replayPhysicalScenario(
    WidgetTester tester, PhysicalScenario scenario) async {
  final controller = FractalController(ModuleRegistry());
  controller.selectModule(controller.registry.byId(scenario.module),
      animate: false);
  controller.updateView(controller.view.copyWith(
      zoom: scenario.zoom,
      pan: Vector2.all(scenario.pan),
      rotation: Vector3(0, 0, scenario.rotation)));
  controller.setRotationLocked(scenario.locked);
  final initial = physicalSnapshot(controller);
  final callbacks = <String>[];
  final routedKeys = <String>[];
  final controlFocus = FocusNode(debugLabel: 'oracle-control');
  final canvasFocus = FocusNode(debugLabel: 'oracle-canvas');
  var wallUs = 0;
  var clockReads = 0;
  var controlValue = 0.0;
  final positions = <int, Offset>{};
  final checkpoints = <Map<String, Object?>>[];
  var disposed = false;
  try {
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
            home: Scaffold(
          body: Focus(
              focusNode: canvasFocus,
              onKeyEvent: (_, event) {
                routedKeys.add('canvas/${event.runtimeType}');
                return KeyEventResult.ignored;
              },
              child: SizedBox(
                  width: 300,
                  height: 240,
                  child: FractalRenderer(
                    animationEnabled: false,
                    gestureClock: () {
                      clockReads++;
                      return DateTime.utc(2026)
                          .add(Duration(microseconds: wallUs));
                    },
                    onUserInteractionStart: () => callbacks.add('start'),
                    onUserInteractionEnd: () => callbacks.add('end'),
                    onUserInteraction: () => callbacks.add('correction'),
                    overrideChild: ColoredBox(
                        color: Colors.black,
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            width: 100,
                            height: 50,
                            child: Focus(
                                focusNode: controlFocus,
                                onKeyEvent: (_, event) {
                                  routedKeys.add(
                                      'control/${event.runtimeType}/handled');
                                  if (event is KeyDownEvent ||
                                      event is KeyRepeatEvent) controlValue++;
                                  return KeyEventResult.handled;
                                },
                                child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onHorizontalDragUpdate: (details) =>
                                        controlValue += details.delta.dx,
                                    child:
                                        const ColoredBox(color: Colors.blue))),
                          ),
                        ])),
                  ))),
        ))));
    canvasFocus.requestFocus();
    await tester.pump();
    for (final event in scenario.events) {
      switch (event['op']) {
        case 'wall':
          wallUs = event['us'] as int;
        case 'pump':
          await tester.pump(Duration(microseconds: event['us'] as int));
        case 'focus':
          controlFocus.requestFocus();
          await tester.pump();
        case 'key':
          await sendPhysicalKey(tester, event);
        case 'module':
          controller.selectModule(
              controller.registry.byId(event['id'] as String),
              animate: false);
        case 'dispose':
          await tester.pumpWidget(const SizedBox.shrink());
          disposed = true;
        case 'checkpoint':
          checkpoints.add({
            'seq': event['seq'],
            'label': event['label'],
            'state': physicalSnapshot(controller),
            'callbacks': [...callbacks],
            'controlValue': controlValue,
            'keys': [...routedKeys],
            'clockReads': clockReads,
            'disposed': disposed
          });
        case 'wheel':
          final p = (event['local'] as List).cast<double>();
          final d = (event['delta'] as List).cast<double>();
          final wheel = PointerScrollEvent(
              kind: PointerDeviceKind.values.byName(event['kind'] as String),
              position: Offset(p[0], p[1]),
              scrollDelta: Offset(d[0], d[1]),
              timeStamp: Duration(microseconds: event['sourceUs'] as int));
          expect(wheel.kind.name, event['kind']);
          expect(wheel.buttons, event['buttons']);
          await tester.sendEventToBinding(wheel);
        case 'down' || 'move' || 'up' || 'cancel':
          final id = event['pointer'] as int;
          final p = (event['local'] as List).cast<double>();
          final position = Offset(p[0], p[1]);
          final time = Duration(microseconds: event['sourceUs'] as int);
          final kind = PointerDeviceKind.values.byName(event['kind'] as String);
          final buttons = event['buttons'] as int;
          final PointerEvent pointer = switch (event['op']) {
            'down' => PointerDownEvent(
                kind: kind,
                buttons: buttons,
                pointer: id,
                position: position,
                timeStamp: time),
            'move' => PointerMoveEvent(
                kind: kind,
                buttons: buttons,
                pointer: id,
                position: position,
                delta: position - positions[id]!,
                timeStamp: time),
            'up' => PointerUpEvent(
                kind: kind,
                buttons: buttons,
                pointer: id,
                position: position,
                timeStamp: time),
            _ => PointerCancelEvent(
                kind: kind,
                buttons: buttons,
                pointer: id,
                position: position,
                timeStamp: time),
          };
          expect(pointer.kind.name, event['kind']);
          expect(pointer.buttons, event['buttons']);
          positions[id] = position;
          await tester.sendEventToBinding(pointer);
        default:
          throw StateError('Unknown physical event: $event');
      }
    }
    return {
      'id': scenario.id,
      'initial': {
        ...initial,
        'viewport': [300, 240],
        'focus': 'canvas',
        'controlValue': 0.0,
        'animationEnabled': false,
        'wallUs': 0,
        'pumpUs': 0,
        'wallEpoch': '2026-01-01T00:00:00.000Z'
      },
      'input': scenario.events,
      'expected': checkpoints
    };
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    controlFocus.dispose();
    canvasFocus.dispose();
    controller.dispose();
  }
}

/// Mount the real viewer to obtain its existing Focus callback, then keep that
/// state alive offstage while routing keys through a minimal nested Focus tree.
Future<List<Map<String, Object?>>> captureViewerKeys(
    WidgetTester tester) async {
  final results = <Map<String, Object?>>[];
  for (final module in ['mandelbrot', 'mandelbulb', 'gaussian_prime_lattice']) {
    SharedPreferences.setMockInitialValues({});
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    controller.selectModule(registry.byId(module), animate: false);
    final presets = await PresetStore.create();
    final history = HistoryProvider(store: await HistoryStore.create());
    final settings =
        RendererSettingsService(await SharedPreferences.getInstance());
    final viewerKey = GlobalKey();
    final outer = FocusNode();
    final inner = FocusNode();
    final keyResults = <String>[];
    var value = 0;
    final inputs = <Map<String, Object?>>[];
    final outputs = <Map<String, Object?>>[];
    FocusOnKeyEventCallback? viewerHandler;
    Widget tree({bool minimal = false}) => MultiProvider(
            providers: [
              Provider.value(value: registry),
              ChangeNotifierProvider.value(value: controller),
              Provider.value(value: presets),
              ChangeNotifierProvider.value(value: history),
              ChangeNotifierProvider.value(value: settings),
            ],
            child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Stack(children: [
                  ExcludeFocus(
                      excluding: minimal,
                      child: Offstage(
                          offstage: minimal,
                          child: FractalViewerScreen(
                              key: viewerKey, restoreViewerSession: false))),
                  if (minimal)
                    Focus(
                        focusNode: outer,
                        onKeyEvent: (node, event) {
                          final result = viewerHandler!(node, event);
                          keyResults.add('${event.runtimeType}/${result.name}');
                          return result;
                        },
                        child: Focus(
                            focusNode: inner,
                            onKeyEvent: (_, event) {
                              if (event is KeyDownEvent ||
                                  event is KeyRepeatEvent) value++;
                              keyResults
                                  .add('${event.runtimeType}/control-handled');
                              return KeyEventResult.handled;
                            },
                            child: const SizedBox(width: 100, height: 50))),
                ])));
    try {
      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      if (module == 'gaussian_prime_lattice') {
        await tester.tap(find.text('Walk'));
        await tester.pumpAndSettle();
      }
      viewerHandler = tester
          .widgetList<Focus>(find.descendant(
              of: find.byKey(viewerKey), matching: find.byType(Focus)))
          .firstWhere((focus) => focus.onKeyEvent != null)
          .onKeyEvent;
      await tester.pumpWidget(tree(minimal: true));
      await tester.pumpAndSettle();
      controller.updateView(controller.view.copyWith(
          zoom: 10, pan: Vector2.zero(), rotation: Vector3(0, 0, math.pi / 2)));
      final initial = {
        ...physicalSnapshot(controller),
        'viewport': [
          tester.view.physicalSize.width / tester.view.devicePixelRatio,
          tester.view.physicalSize.height / tester.view.devicePixelRatio
        ],
        'routing': {
          'viewerMode': module == 'gaussian_prime_lattice' ? 'walk' : 'explore',
          'walkWidgetFocusExcluded': module == 'gaussian_prime_lattice'
        }
      };
      for (final target in ['canvas', 'control']) {
        inputs.add({'seq': inputs.length, 'op': 'focus', 'target': target});
        (target == 'canvas' ? outer : inner).requestFocus();
        await tester.pump();
        for (final key in physicalKeys.keys) {
          for (final type in ['down', 'repeat', 'up']) {
            final event = <String, Object?>{
              'seq': inputs.length,
              'op': 'key',
              'sourceUs': 0,
              'type': type,
              'key': key
            };
            inputs.add(event);
            expect((target == 'canvas' ? outer : inner).hasPrimaryFocus, isTrue,
                reason:
                    '$module/$target/$type/$key: ${FocusManager.instance.primaryFocus}');
            await sendPhysicalKey(tester, event);
            expect(keyResults, isNotEmpty,
                reason: '$module/$target/$type/$key');
            outputs.add({
              'seq': event['seq'],
              'state': physicalSnapshot(controller),
              'routed': keyResults.removeLast(),
              'controlValue': value
            });
          }
        }
      }
      results.add({
        'id': 'viewer-keys/$module',
        'initial': initial,
        'input': inputs,
        'expected': outputs
      });
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      outer.dispose();
      inner.dispose();
      history.dispose();
      settings.dispose();
      controller.dispose();
    }
  }
  return results;
}

/// Explicit transitive local renderer/input/viewer graph, plus Flutter's input
/// owners (selected files, not the full SDK dependency graph).
Map<String, String> physicalSourceBindings() {
  final hashes = <String, String>{};
  void visit(String path) {
    if (hashes.containsKey(path)) return;
    final source = File(path).readAsStringSync();
    hashes[path] = sha256.convert(utf8.encode(source)).toString();
    for (final match in RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''')
        .allMatches(
            source.replaceAll(RegExp(r'/\*[\s\S]*?\*/|//[^\n]*'), ''))) {
      final uri = match[1]!;
      if (uri.startsWith('package:flutter_fractals/')) {
        visit(uri.replaceFirst('package:flutter_fractals/', 'lib/'));
      } else if (!uri.contains(':')) {
        visit(File.fromUri(File(path).uri.resolve(uri)).path);
      }
    }
  }

  for (final path in [
    'lib/features/renderer/widgets/renderer/fractal_renderer.dart',
    'lib/features/viewer/fractal_viewer_screen.dart',
    'test/migration/support/physical_events_oracle.dart',
    'test/migration/physical_events_oracle_test.dart',
    'pubspec.lock',
    'fdroid/flutter.version',
  ]) {
    visit(path);
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('Select pinned FLUTTER_ROOT');
  for (final path in [
    'gestures/binding.dart',
    'gestures/arena.dart',
    'gestures/scale.dart',
    'gestures/tap.dart',
    'gestures/multitap.dart',
    'gestures/recognizer.dart',
    'gestures/constants.dart',
    'gestures/events.dart',
    'gestures/velocity_tracker.dart',
    'gestures/monodrag.dart',
    'gestures/pointer_router.dart',
    'widgets/gesture_detector.dart',
    'animation/animation_controller.dart',
    'scheduler/ticker.dart',
    'widgets/focus_manager.dart',
    'widgets/focus_scope.dart',
    'services/hardware_keyboard.dart'
  ]) {
    hashes['flutter-sdk/$path'] = sha256
        .convert(File('$root/packages/flutter/lib/src/$path').readAsBytesSync())
        .toString();
  }
  hashes['flutter-test/event_simulation.dart'] = sha256
      .convert(File('$root/packages/flutter_test/lib/src/event_simulation.dart')
          .readAsBytesSync())
      .toString();
  return hashes;
}

Future<Map<String, Object?>> buildPhysicalEventsOracle(
        WidgetTester tester) async =>
    {
      'schema': 1,
      'kind': 'ordered-physical-events',
      'runtime': {
        'dart': Platform.version.split(' ').first,
        'flutter': File('fdroid/flutter.version').readAsStringSync().trim(),
        'target': 'Flutter widget-test VM; not browser/hardware qualification'
      },
      'source_bindings': physicalSourceBindings(),
      'scenarios': [
        for (final scenario in physicalScenarios())
          await replayPhysicalScenario(tester, scenario),
        ...await captureViewerKeys(tester)
      ],
    };

/// Explicit scratch export; no fixture is ever rewritten by a test run.
void exportPhysicalEventsOracle(Map<String, Object?> document, String output) {
  if (output.isEmpty) return;
  final directory = Directory(output);
  if (!directory.isAbsolute) throw ArgumentError('Output must be absolute');
  if (output.split(Platform.pathSeparator).contains('..')) {
    throw ArgumentError('Output must not contain parent traversal');
  }
  final scratch = Directory.systemTemp.resolveSymbolicLinksSync();
  if (Platform.isLinux && Directory(scratch).statSync().mode & 0x3f != 0) {
    throw ArgumentError('Select a private TMPDIR (mode 0700)');
  }
  final root = Directory.current.resolveSymbolicLinksSync();
  // Check the nearest existing ancestor before creating anything in checkout.
  var ancestor = directory.absolute;
  while (!ancestor.existsSync()) {
    ancestor = ancestor.parent;
  }
  final resolvedAncestor = ancestor.resolveSymbolicLinksSync();
  if (resolvedAncestor == root || resolvedAncestor.startsWith('$root/')) {
    throw ArgumentError('Output must be outside checkout');
  }
  if (resolvedAncestor != scratch &&
      !resolvedAncestor.startsWith('$scratch/')) {
    throw ArgumentError('Output must be within private TMPDIR');
  }
  directory.createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  if (resolved == root || resolved.startsWith('$root/')) {
    throw ArgumentError('Output must be outside checkout');
  }
  if (directory.listSync().isNotEmpty) throw StateError('Output must be empty');
  File('$resolved/physical-events.json')
      .writeAsStringSync(canonicalJson(document));
}
