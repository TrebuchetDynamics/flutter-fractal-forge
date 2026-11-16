// Component fixtures only. Never import this harness into the shipping app.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/models/video_export_options.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/export/video_export_sheet.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/settings/settings_screen.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/semantics/interactive_name_audit.dart';
import '../a11y/shared/a11y_test_helpers.dart';
import 'overflow_guard.dart';
import 'semantics_test_helper.dart';

const overlayStateIds = <String>[
  'edit-menu',
  'controls-2d',
  'controls-3d',
  'palette-top',
  'palette-last-selected',
  'presets-built-in',
  'presets-user-empty',
  'presets-user-populated',
  'preset-rename',
  'history-empty',
  'history-populated',
  'favorite-rename',
  'save-share',
  'export-options',
  'export-progress',
  'share-preview',
  'share-fallback',
  'looper-empty',
  'looper-ready',
  'wallpaper-options',
  'video-options',
  'batch-selection',
  'fourier-settings',
  'text-editor',
  'report-notes',
  'random-options',
  'random-categories',
  'auto-explore-settings',
  'kaleidoscope-options',
  'theme-selector',
  'about-dialog',
  'gpu-report',
];
const _stressStates = <String>[
  'controls-2d',
  'presets-user-populated',
  'palette-last-selected',
  'export-options',
  'export-progress',
  'text-editor',
  'report-notes',
  'history-populated',
  'looper-ready',
  'theme-selector',
];
const _componentOnly = <String>[
  'history-empty',
  'history-populated',
  'favorite-rename',
  'wallpaper-options',
  'video-options',
  'export-progress',
  'share-fallback',
  'gpu-report',
  'report-notes',
];

/// Independent expansion of the issue's contract; does not trust fixture counts.
List<String> validateOverlayMatrix(Map<String, dynamic> manifest) {
  final errors = <String>[];
  if (manifest['schema'] != 1) errors.add('expected schema1');
  final states = (manifest['states'] as List).cast<Map<String, dynamic>>();
  if (states.length != 32 ||
      !overlayStateIds
          .every((id) => states.where((s) => s['id'] == id).length == 1)) {
    errors.add('expected exactly the 32 named states');
  }
  for (final state in states) {
    final browser = state['browser'] as Map;
    final available = !_componentOnly.contains(state['id']);
    if (browser['available'] != available ||
        (available
            ? browser['exclusion_reason'] != null
            : (browser['exclusion_reason'] is! String ||
                (browser['exclusion_reason'] as String).isEmpty))) {
      errors.add('${state['id']}: browser capability/reason');
    }
    if (!listEquals((state['required_actions'] as List).cast<String>(),
        requiredOverlayActions(state['id'] as String))) {
      errors.add('${state['id']}: required action contract mismatch');
    }
    if ((state['setup'] as String).isEmpty ||
        (state['component_setup_mode'] as String).isEmpty ||
        !File(state['owner']['path'] as String).existsSync() ||
        (state['owner']['symbol'] as String).isEmpty) {
      errors.add('${state['id']}: missing setup/owner');
    }
  }
  final expected = <String, Map<String, Object>>{};
  void add(String state, String category, int width, int height,
      {String locale = 'en',
      String theme = 'dark',
      int scale = 1,
      int ime = 0}) {
    expected['$state--$category--${width}x$height'] = {
      'width': width,
      'height': height,
      'dpr': 1,
      'locale': locale,
      'theme': theme,
      'text_scale': scale,
      'view_insets_bottom': ime,
      'reduced_motion': true,
      'large_targets': false,
      'platform': 'linux',
    };
  }

  for (final state in overlayStateIds) {
    for (final size in const [(375, 667), (768, 1024), (1440, 900)]) {
      add(state, 'baseline', size.$1, size.$2);
    }
  }
  for (final state in _stressStates) {
    for (final size in const [(320, 568), (667, 375)]) {
      add(state, 'stress', size.$1, size.$2,
          locale: 'es', theme: 'highContrast', scale: 3);
    }
  }
  for (final state in const ['text-editor', 'preset-rename']) {
    add(state, 'keyboard', 375, 667, locale: 'es', scale: 2, ime: 300);
  }
  add('export-options', 'oled', 375, 667, theme: 'oled');
  final seen = <String>{};
  var browserRows = 0;
  for (final row in (manifest['rows'] as List).cast<Map<String, dynamic>>()) {
    final id = row['id'] as String;
    final inputs = row['inputs'] as Map;
    final contract = expected[id];
    if (!seen.add(id) ||
        contract == null ||
        row['capture_kind'] != 'component-fixture/placeholder-background' ||
        id !=
            '${row['state']}--${row['category']}--${inputs['width']}x${inputs['height']}' ||
        inputs.length != contract.length ||
        !contract.entries.every((e) => inputs[e.key] == e.value)) {
      errors.add('$id: undeclared/duplicate/mutated row inputs');
    }
    if (!_componentOnly.contains(row['state']) &&
        row['category'] != 'keyboard') {
      browserRows++;
    }
  }
  for (final id in expected.keys.where((id) => !seen.contains(id))) {
    errors.add('missing row $id');
  }
  if (browserRows != 84 || manifest['browser_derivation']['text_scale'] != 1) {
    errors.add('expected independent browser84 at text scale1');
  }
  return errors;
}

List<String> requiredOverlayActions(String state) => switch (state) {
      'batch-selection' => ['Cancel'],
      'preset-rename' || 'favorite-rename' => ['Cancel', 'Save'],
      'history-empty' || 'history-populated' => ['Save favorite'],
      'export-progress' => ['Cancel'],
      'text-editor' => ['Close', 'Cancel', 'Apply'],
      'report-notes' => ['Close', 'Cancel', 'Save'],
      'export-options' => ['Close', 'Save', 'Save & share (not invoked)'],
      'wallpaper-options' => ['Close', 'Apply (not invoked)'],
      'video-options' => ['Close', 'Export (not invoked)'],
      'looper-ready' => ['Close', 'Export GIF (not invoked)'],
      'theme-selector' => ['Close', 'Cancel'],
      'share-preview' || 'share-fallback' => [
          'Close',
          'Copy (not invoked)',
          'Share (not invoked)'
        ],
      _ => ['Close'],
    };

List<int>? overlayPngSize(Uint8List? png) {
  if (png == null ||
      png.length < 24 ||
      !listEquals(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]) ||
      !listEquals(png.sublist(12, 16), [73, 72, 68, 82])) return null;
  final data = ByteData.sublistView(png);
  return [data.getUint32(16), data.getUint32(20)];
}

bool _rect(dynamic value) =>
    value is List &&
    value.length == 4 &&
    value.every((v) => v is num && v.isFinite) &&
    value[2] > value[0] &&
    value[3] > value[1];

class OverlayCaptureResult {
  OverlayCaptureResult(this.row);
  final Map<String, dynamic> row;
  Uint8List? png;
  Uint8List? _decodedBytes;
  bool _decoded = false;
  String? imageHash;
  Map<String, dynamic>? measurements;
  final errors = <String>[];

  List<String> get failures {
    final failures = [...errors];
    final inputs = row['inputs'] as Map;
    final width = inputs['width'] as num;
    final height = inputs['height'] as num;
    final size = overlayPngSize(png);
    if (!identical(_decodedBytes, png)) {
      _decodedBytes = png;
      try {
        _decoded = png != null && img.decodePng(png!) != null;
      } catch (_) {
        _decoded =
            false; // Corrupt input is a reported image failure, not a lost audit.
      }
    }
    if (size == null) {
      failures.add('image: NOT_RUN');
    } else if (size[0] != width || size[1] != height || !_decoded) {
      failures.add(
          'image: pixel size/decoding mismatch: $size vs [$width, $height]');
    }
    final m = measurements;
    if (m == null) return [...failures, 'measurements: NOT_RUN'];
    if (m['surface_visible'] != true)
      failures.add('surface visibility: NOT_RUN');
    for (final name in ['overlay', 'title']) {
      if (!_rect(m[name])) failures.add('$name rectangle: NOT_RUN');
    }
    final viewports = m['content_viewports'];
    if (viewports is! List) {
      failures.add('content viewport measurement: NOT_RUN');
    } else {
      for (final rect in [m['overlay'], ...viewports]) {
        if (!_rect(rect)) {
          failures.add('overlay/content viewport empty or unmeasured: $rect');
        } else if (rect[0] < -1 || rect[2] > width + 1) {
          failures
              .add('overlay/content outside horizontal safe viewport: $rect');
        }
      }
    }
    final scrolls = m['scroll_extents'];
    if (scrolls is! List ||
        scrolls.any((s) =>
            s is! Map ||
            !['min', 'max', 'pixels', 'viewport']
                .every((k) => s[k] is num && (s[k] as num).isFinite))) {
      failures.add('scroll extents: NOT_RUN');
    }
    final viewport = m['viewport'];
    if (viewport is! Map ||
        viewport['width'] != width ||
        viewport['height'] != height ||
        viewport['dpr'] != 1 ||
        viewport['text_scale'] != inputs['text_scale'] ||
        viewport['view_insets_bottom'] != inputs['view_insets_bottom'] ||
        viewport['disable_animations'] != true ||
        viewport['locale'] != inputs['locale'] ||
        viewport['platform'] != inputs['platform'] ||
        viewport['padding'] is! List ||
        (viewport['padding'] as List).length != 4 ||
        m['theme'] is! Map ||
        m['theme']['requested'] != inputs['theme'] ||
        m['theme']['surface'] is! int ||
        m['theme']['primary'] is! int ||
        m['theme']['scaffold_background'] is! int)
      failures.add('actual inputs: NOT_RUN or mismatch');
    final actions = m['actions'];
    if (actions is! List || actions.isEmpty) {
      failures.add('actions: NOT_RUN');
    } else {
      final required = requiredOverlayActions(row['state'] as String);
      if (actions.length != required.length ||
          !required.every(
              (name) => actions.where((a) => a['name'] == name).length == 1)) {
        failures
            .add('required action measurements missing/duplicated: $required');
      }
      for (final action in actions) {
        final rect = action['rect'];
        if (!_rect(rect)) {
          failures.add('${action['name']} rectangle: NOT_RUN');
          continue;
        }
        if (rect[2] - rect[0] < 48 || rect[3] - rect[1] < 48) {
          failures.add('${action['name']} pointer target below 48: $rect');
        }
        if (action['hit_testable'] != true ||
            action['reachable'] != true ||
            rect[0] < -1 ||
            rect[2] > width + 1 ||
            rect[1] < -1 ||
            rect[3] > height - (inputs['view_insets_bottom'] as num) + 1) {
          failures.add('${action['name']} unreachable: $action');
        }
      }
    }
    final families = m['font_families'];
    if (families is! List ||
        families.isEmpty ||
        families.any((f) => ![
              'Roboto',
              'Inter',
              'Poppins',
              'JetBrains Mono',
              'monospace',
              'MaterialIcons'
            ].contains(f))) {
      failures.add('test-font identity: NOT_RUN or unbound font');
    }
    if (m['semantics'] is! String || (m['semantics'] as String).isEmpty) {
      failures.add('semantics: NOT_RUN');
    }
    if (inputs['view_insets_bottom'] != 0 &&
        (m['keyboard_field_visible'] != true ||
            !_rect(m['keyboard_field']) ||
            m['keyboard_field'][1] < -1 ||
            m['keyboard_field'][3] >
                height - (inputs['view_insets_bottom'] as num) + 1 ||
            m['dismissal_focus_restored'] != true)) {
      failures
          .add('keyboard field/action/focus restoration: NOT_RUN or failed');
    }
    return failures;
  }

  Map<String, dynamic> toJson() => {
        ...row,
        'expected_pixel_size': [
          row['inputs']['width'],
          row['inputs']['height']
        ],
        'actual_pixel_size': overlayPngSize(png),
        'image': png == null ? null : '${row['id']}.png',
        'measurements': measurements,
        'errors': failures,
        'status': failures.isEmpty ? 'PASSED' : 'FAILED',
      };
}

List<String> overlayAuditFailures(
    List<Map<String, dynamic>> rows, List<OverlayCaptureResult> results) {
  final failures = <String>[];
  for (final row in rows) {
    final matching = results.where((r) => r.row['id'] == row['id']).toList();
    if (matching.length != 1) {
      failures.add('missing row or duplicate ${row['id']}');
    } else {
      failures.addAll(matching.single.failures.map((e) => '${row['id']}: $e'));
    }
  }
  if (results.any((r) => !rows.any((row) => row['id'] == r.row['id']))) {
    failures.add('undeclared result');
  }
  return failures;
}

String _command(String command, List<String> arguments) {
  final result = Process.runSync('timeout', ['30', command, ...arguments]);
  if (result.exitCode != 0) throw StateError('$command: ${result.stderr}');
  return (result.stdout as String).trim();
}

String _hash(File file) => _command('sha256sum', [file.path]).split(' ').first;
Map<String, dynamic>? _fonts;
Future<Map<String, dynamic>> loadOverlayCaptureFonts(
    WidgetTester tester) async {
  if (_fonts != null) return _fonts!;
  return (await tester.runAsync(() async {
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root == null)
      throw StateError('FLUTTER_ROOT required: select pinned SDK');
    final directory = Directory('$root/bin/cache/artifacts/material_fonts');
    final files = directory
        .listSync()
        .whereType<File>()
        .where((f) =>
            f.uri.pathSegments.last.startsWith('Roboto-') &&
            f.path.endsWith('.ttf'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    if (files.length != 12)
      throw StateError('Expected 12 pinned Roboto faces at $directory');
    for (final family in [
      'Roboto',
      'monospace',
      AppTypography.titleFont,
      AppTypography.bodyFont,
      AppTypography.monoFont
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        loader.addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
      await loader.load();
    }
    final icons = File('${directory.path}/MaterialIcons-Regular.otf');
    await (FontLoader('MaterialIcons')
          ..addFont(
              Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
        .load();
    return _fonts = {
      'policy':
          'Explicit SDK Roboto test-font substitution for Roboto/Poppins/Inter/JetBrains Mono/monospace '
              'and theme text styles without a family; SDK MaterialIcons. '
              'Not Ahem, native font parity, browser or production typography',
      'directory': directory.path,
      'files': [
        for (final file in [...files, icons])
          {'filename': file.uri.pathSegments.last, 'sha256': _hash(file)}
      ],
    };
  }))!;
}

Directory validateOverlayCaptureDirectory(String path) {
  if (!path.startsWith('/'))
    throw ArgumentError(
        'UI_OVERLAY_CAPTURE_DIR must be absolute and outside checkout');
  final checkout = Directory.current.resolveSymbolicLinksSync();
  final absolute = Directory(path).absolute.path;
  if (absolute == checkout || absolute.startsWith('$checkout/')) {
    throw ArgumentError('UI_OVERLAY_CAPTURE_DIR must be outside checkout');
  }
  final directory = Directory(path)..createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  if (resolved == checkout || resolved.startsWith('$checkout/')) {
    throw ArgumentError('UI_OVERLAY_CAPTURE_DIR must be outside checkout');
  }
  if (directory.listSync().isNotEmpty) {
    throw ArgumentError(
        'UI_OVERLAY_CAPTURE_DIR must be empty; choose a fresh private directory, retain prior evidence');
  }
  _command('chmod', ['700', resolved]);
  return Directory(resolved);
}

Future<Map<String, dynamic>> overlayCaptureIdentity(
        WidgetTester tester, Map<String, dynamic> fonts) async =>
    {
      'run_id': '3e39bd4d',
      'source_base': '8021e74785e4d196d2c6f7a6310c031d48260f58',
      'source_head': _command('git', ['rev-parse', 'HEAD']),
      'dirty_status': _command('git', ['status', '--porcelain']),
      'dirty_diff': _command('git', ['diff', '--binary', 'HEAD']),
      'files': {
        for (final path in [
          'test/fixtures/ui_overlay_capture_matrix.json',
          'test/overlays/ui_overlay_responsive_capture_test.dart',
          'test/helpers/ui_overlay_capture_harness.dart',
          'docs/engineering/test-plan.md',
          'pubspec.lock',
          'rust/Cargo.lock',
        ])
          path: _hash(File(path))
      },
      'flutter': _command(
          '${Platform.environment['FLUTTER_ROOT']}/bin/flutter', ['--version']),
      'dart': Platform.version,
      'backend':
          'flutter_tester software component raster; normal placeholder background (CPU banner fixture for gpu-report)',
      'fonts': fonts,
    };

Future<void> writeOverlayCaptureReport(
    Directory directory,
    Map<String, dynamic> manifest,
    List<OverlayCaptureResult> results,
    Map<String, dynamic> identity) async {
  final expected = (manifest['rows'] as List).cast<Map<String, dynamic>>();
  final failures = overlayAuditFailures(expected, results);
  final images = <String, String>{};
  for (final result in results) {
    if (result.png == null) continue;
    final file = File('${directory.path}/${result.row['id']}.png');
    if (result.imageHash == null) {
      file.writeAsBytesSync(result.png!, flush: true);
      result.imageHash = _hash(file);
    }
    images[result.row['id'] as String] = result.imageHash!;
  }
  final report = {
    'schema': 1,
    'identity': identity,
    'qualification': manifest['qualification'],
    'expected': expected.length,
    'captured': images.length,
    'failed': results.where((r) => r.failures.isNotEmpty).length,
    'not_run': expected.length - results.length,
    'layout_qualified': failures.isEmpty,
    'verdict': failures.isEmpty ? 'PASSED' : 'NONPASSING',
    'image_sha256': images,
    'results': [
      for (final row in expected)
        results.where((r) => r.row['id'] == row['id']).isEmpty
            ? {
                ...row,
                'status': 'NOT_RUN',
                'image': null,
                'measurements': null,
                'errors': ['NOT_RUN']
              }
            : results.singleWhere((r) => r.row['id'] == row['id']).toJson()
    ],
  };
  File('${directory.path}/captures.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  final markdown = StringBuffer('# Responsive overlay component audit\n\n')
    ..writeln('run_id=3e39bd4d; ${manifest['qualification']}\n')
    ..writeln('Expected ${expected.length}; captured ${images.length}; '
        'failed ${report['failed']}; NOT_RUN ${report['not_run']}. '
        '**${report['verdict']}; layout-qualified=${report['layout_qualified']}**.\n')
    ..writeln(
        'Source/font/tool identities and full geometry/errors: captures.json. '
        'Inputs are synthetic fixture metrics, not OS settings. '
        'Rectangles are [left, top, right, bottom], logical px; horizontal tolerance 1px.\n')
    ..writeln(
        '| Row | Status | Actual PNG | Evidence/errors |\n|---|---|---|---|');
  for (final row in report['results'] as List) {
    markdown.writeln(
        '| ${row['id']} | ${row['status']} | ${row['actual_pixel_size']} | '
        '${(row['errors'] as List).isEmpty ? 'Measured geometry/actions/scroll extents in JSON' : (row['errors'] as List).join('; ').replaceAll('\n', ' ').replaceAll('|', '/')} |');
  }
  File('${directory.path}/report.md').writeAsStringSync(markdown.toString());
}

class _ReportExportService extends ExportService {
  int captures = 0;
  final saved = <String>[];
  @override
  Future<bool> chooseLinuxExportDirectory() async => true;
  @override
  Future<Uint8List> capturePng(GlobalKey boundaryKey,
      {double pixelRatio = 1}) async {
    captures++;
    return img.encodePng(img.Image(width: 2, height: 2));
  }

  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    saved.add(filename);
    return File('/fake-export/$filename'); // Deliberately writes nothing.
  }
}

List<double> _rectangle(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return [rect.left, rect.top, rect.right, rect.bottom];
}

Finder _key(String key) => find.byKey(ValueKey(key));
Finder _button(String label) => find
    .ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
    .first;

Future<void> _activate(WidgetTester tester, Finder finder,
    {bool long = false}) async {
  expect(finder, findsOneWidget,
      reason: 'Required shipping action did not build');
  await tester.ensureVisible(finder);
  await pumpAccessibilityTestFrames(tester);
  expect(finder.hitTestable(), findsOneWidget,
      reason: 'Required shipping action cannot be hit-tested');
  if (long) {
    await tester.longPress(finder);
  } else {
    await tester.tap(finder);
  }
  await pumpAccessibilityTestFrames(tester);
}

/// A new complete disposable host for every row. The boundary is OUTSIDE the
/// MaterialApp/Navigator, so modal Overlay entries cannot escape the image.
Future<OverlayCaptureResult> captureOverlayRow(
    WidgetTester tester, Map<String, dynamic> row) async {
  final result = OverlayCaptureResult(row);
  final inputs = row['inputs'] as Map;
  final state = row['state'] as String;
  final size = Size((inputs['width'] as num).toDouble(),
      (inputs['height'] as num).toDouble());
  final boundaryKey = GlobalKey();
  final launcherKey = GlobalKey();
  final launchFocus = FocusNode(debugLabel: 'component launcher');
  final registry = ModuleRegistry();
  final controller = FractalController(registry);
  AccessibilityService? accessibility;
  RendererSettingsService? renderer;
  HistoryProvider? history;
  final semantics = tester.ensureSemantics();
  final previous = FlutterError.onError;
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  FlutterError.onError = (details) => result.errors.add(details.toString());
  try {
    await expectNoOverflow(() async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.viewInsets = FakeViewPadding(
          bottom: (inputs['view_insets_bottom'] as num).toDouble());
      tester.binding.handleMetricsChanged();
      SharedPreferences.setMockInitialValues({
        'accessibility_reduced_motion': true,
        'debug_mode_enabled': state == 'report-notes',
        'app_theme_mode':
            AppThemeMode.values.indexWhere((t) => t.name == inputs['theme']),
        if (state == 'gpu-report')
          'renderer_backend_mode': RendererBackendMode.cpuOnly.name,
      });
      accessibility = await AccessibilityService.create();
      renderer = await RendererSettingsService.create();
      final store = await PresetStore.create();
      final historyStore = await HistoryStore.create();
      if (state == 'history-populated' || state == 'favorite-rename') {
        final entry = HistoryEntry(
          id: 'overlay-capture-history',
          moduleId: controller.module.id,
          view: controller.view,
          params: Map<String, Object>.from(controller.params),
          visitedAt: DateTime.utc(2026, 1, 1),
        );
        await historyStore.saveHistory([entry]);
        if (state == 'favorite-rename') {
          await historyStore.saveFavorites([
            entry.copyWith(name: 'Capture favorite'),
          ]);
        }
      }
      history = HistoryProvider(store: historyStore);
      if (state == 'controls-3d')
        controller.selectModule(registry.byId('mandelbulb'), animate: false);
      if (state == 'palette-last-selected') {
        final parameter = controller.module.parameters
            .singleWhere((p) => p.id == 'colorScheme');
        controller.updateParam('colorScheme', parameter.options.last.value);
      }
      if (state == 'presets-user-populated' || state == 'preset-rename') {
        await store.saveUserPreset(FractalPreset(
          id: 'overlay-capture-sample',
          moduleId: controller.module.id,
          name: 'Capture sample preset',
          params: Map<String, Object>.from(controller.params),
          view: controller.view,
          createdAt: DateTime.utc(2026, 1, 1),
        ));
      }
      final theme = switch (inputs['theme']) {
        'dark' => AppTheme.dark,
        'highContrast' => AppTheme.highContrast,
        'oled' => AppTheme.oled,
        _ => throw StateError('Unknown theme'),
      };
      final fakeExport = _ReportExportService();
      final isolated = state.startsWith('presets-') ||
          state == 'preset-rename' ||
          state.startsWith('history-') ||
          state == 'favorite-rename' ||
          state.startsWith('share-') ||
          state == 'video-options' ||
          state == 'wallpaper-options';
      final settings = state == 'theme-selector' || state == 'about-dialog';
      var cancelled = false;
      Widget component(BuildContext context) {
        if (state.startsWith('presets-') || state == 'preset-rename')
          return const PresetSheet();
        if (state.startsWith('history-') || state == 'favorite-rename')
          return const HistorySheet();
        if (state == 'wallpaper-options')
          return const WallpaperOptionsSheet(initial: WallpaperOptions());
        if (state == 'video-options') {
          return VideoExportSheet(
              initialOptions: const VideoExportOptions(),
              fractalType: 'mandelbrot',
              availableParameters: const [],
              parameterRanges: const {},
              onExport: (_) =>
                  throw StateError('Export forbidden in captures'));
        }
        if (state == 'share-preview' || state == 'share-fallback') {
          final preview = state == 'share-preview'
              ? img.encodePng(img.Image(width: 64, height: 32)
                ..clear(img.ColorRgb8(80, 40, 180)))
              : null;
          if (preview != null) expect(img.decodePng(preview), isNotNull);
          return ShareSheet(
              uri: Uri.parse(
                  'https://fractalforge.app/view?fixture=overlay-capture'),
              fractalName: 'Mandelbrot · component preview',
              previewBytes: preview,
              shareText: (_, {subject}) async =>
                  throw StateError('Share forbidden in captures'));
        }
        throw StateError('No public host for $state');
      }

      if (state == 'batch-selection') {
        throw StateError(
            'batch-selection: no shipping selection widget/launcher. '
            'PresetSheet.onBatchExport is declared but never rendered/called; '
            'BatchExportDialog._run starts export automatically. No job started. '
            'Owner must resolve requested state; no production wiring authorized.');
      }
      await tester.pumpWidget(MultiProvider(
          providers: [
            Provider.value(value: registry),
            Provider.value(value: store),
            ChangeNotifierProvider.value(value: controller),
            ChangeNotifierProvider<AccessibilityService>.value(
                value: accessibility!),
            ChangeNotifierProvider<RendererSettingsService>.value(
                value: renderer!),
            ChangeNotifierProvider<HistoryProvider>.value(value: history!),
            Provider<ExplorationStatsService?>.value(value: null),
          ],
          child: RepaintBoundary(
              key: boundaryKey,
              child: MaterialApp(
                theme: theme,
                debugShowCheckedModeBanner: false,
                locale: Locale(inputs['locale'] as String),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                // Theme.of resolves the locale's geometry styles first. Some
                // shipping partial themes leave those non-inheriting styles
                // without a family; substitute fonts only, not sizes/colors.
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    textTheme:
                        Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
                    primaryTextTheme: Theme.of(context)
                        .primaryTextTheme
                        .apply(fontFamily: 'Roboto'),
                  ),
                  child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(
                            (inputs['text_scale'] as num).toDouble()),
                        disableAnimations: true,
                        accessibleNavigation: true,
                      ),
                      child: child!),
                ),
                home: settings
                    ? const SettingsScreen()
                    : isolated
                        ? Scaffold(
                            body: Builder(
                                builder: (context) => TextButton(
                                    key: launcherKey,
                                    focusNode: launchFocus,
                                    onPressed: () => showAppBottomSheet<void>(
                                        context: context, builder: component),
                                    child:
                                        const Text('Open component fixture'))))
                        : state == 'export-progress'
                            ? Scaffold(
                                body: Builder(
                                    builder: (context) => ExportOverlay(
                                        progress: 0.5,
                                        l10n: AppLocalizations.of(context)!,
                                        onCancel: () => cancelled = true)))
                            : FractalViewerScreen(exportService: fakeExport),
              ))));
      await pumpAccessibilityTestFrames(tester);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
      final material =
          MaterialLocalizations.of(tester.element(find.byType(Scaffold).first));
      if (isolated) {
        launchFocus.requestFocus();
        await tester.pump();
        await _activate(tester, find.byKey(launcherKey));
      } else if (settings) {
        await _activate(
            tester,
            find.text(state == 'theme-selector'
                ? l10n.paramColorScheme
                : l10n.settingsAbout));
      } else if (state == 'gpu-report') {
        await _activate(tester,
            find.widgetWithText(OutlinedButton, l10n.cpuFallbackReport));
        expect(fakeExport.captures, 1);
        expect(fakeExport.saved, hasLength(2));
      } else if (state == 'palette-top' || state == 'palette-last-selected') {
        await _activate(tester, _key('viewerPaletteButton'), long: true);
      } else if (state == 'save-share' || state == 'export-options') {
        await _activate(tester, _key('viewerSaveShareButton'));
        if (state == 'export-options')
          await _activate(tester, _key('viewerOpenExportAction'));
      } else if (state == 'looper-empty' || state == 'looper-ready') {
        await _activate(tester, _key('viewerPlayButton'), long: true);
        if (state == 'looper-ready') {
          await _activate(tester, _key('looperSetAButton'));
          controller.updateZoom(2);
          await _activate(tester, _key('looperSetBButton'));
        }
      } else if (state == 'random-categories') {
        await _activate(tester, _key('viewerRandomFractalFab'), long: true);
      } else if (state != 'export-progress') {
        await _activate(tester, _key('viewerControlsButton'), long: true);
        final action = switch (state) {
          'edit-menu' => null,
          'controls-2d' || 'controls-3d' => 'viewerEditParametersAction',
          'fourier-settings' => 'viewerFourierFabOptions',
          'text-editor' => 'viewerTextOverlayFabOptions',
          'report-notes' => 'viewerReportFractalFab',
          'random-options' => 'viewerRandomOptionsAction',
          'auto-explore-settings' => 'viewerAutoExploreButtonOptions',
          'kaleidoscope-options' => 'viewerKaleidoscopeFabOptions',
          _ => throw StateError('Undeclared setup $state'),
        };
        if (action != null) await _activate(tester, _key(action));
      }
      FocusNode? focusBeforeDialog;
      if (state == 'preset-rename') {
        final rename = find.byTooltip(l10n.tooltipRenamePreset).first;
        await tester.ensureVisible(rename);
        Focus.of(tester.element(
                find.descendant(of: rename, matching: find.byType(Icon)).first))
            .requestFocus();
        await tester.pump();
        focusBeforeDialog = FocusManager.instance.primaryFocus;
        await _activate(tester, rename);
      }
      if (state == 'favorite-rename') {
        await _activate(tester, find.text(l10n.historyTabFavorites));
        await _activate(tester, find.byType(PopupMenuButton<String>).first);
        await _activate(tester, find.text(l10n.historyRename));
      }
      if (state == 'text-editor') {
        await tester.enterText(_key('viewerTextOverlayField'),
            'Fractal capture · texto de prueba');
        if (inputs['view_insets_bottom'] == 0) {
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pump();
        }
      }
      if (state == 'report-notes') {
        await tester.enterText(
            find.byType(TextFormField), 'Responsive component fixture notes');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await _activate(tester, find.text(l10n.reportTagLowPerformance));
      }
      if (state == 'share-preview') {
        final preview = find.byType(Image).last;
        await tester.runAsync(() => precacheImage(
                tester.widget<Image>(preview).image, tester.element(preview))
            .timeout(const Duration(seconds: 10)));
        await pumpAccessibilityTestFrames(tester);
      }
      final titleText = switch (state) {
        'edit-menu' => l10n.viewerEditTools,
        'controls-2d' || 'controls-3d' => l10n.controlsTitle,
        'palette-top' || 'palette-last-selected' => l10n.paramColorScheme,
        'presets-built-in' ||
        'presets-user-empty' ||
        'presets-user-populated' =>
          l10n.presetsTitle,
        'preset-rename' => l10n.renamePresetTitle,
        'history-empty' || 'history-populated' => l10n.historyTitle,
        'favorite-rename' => l10n.renameFavoriteTitle,
        'save-share' => l10n.viewerActionSectionSaveShare,
        'export-options' => l10n.exportTitle,
        'export-progress' => l10n.exporting,
        'share-preview' || 'share-fallback' => l10n.shareViewLinkTitle,
        'looper-empty' || 'looper-ready' => l10n.looperTitle,
        'wallpaper-options' => l10n.wallpaperTitle,
        'video-options' => 'Export Video',
        'fourier-settings' => l10n.fourierSettingsTitle,
        'text-editor' => l10n.textOverlayTitle,
        'report-notes' => l10n.reportDialogTitle,
        'random-options' => l10n.randomOptionsTitle,
        'random-categories' => l10n.randomCategoriesTitle,
        'auto-explore-settings' => l10n.autoExploreTitle,
        'kaleidoscope-options' => l10n.kaleidoscopeOptionsTitle,
        'theme-selector' => l10n.settingsColorTheme,
        'about-dialog' => 'Fractal Forge',
        'gpu-report' => l10n.debugReportTitle,
        _ => throw StateError('No title contract $state'),
      };
      final title = state.startsWith('history-')
          // The tab repeats the heading's label. Its geometry is not the title.
          ? find
              .descendant(
                  of: find.byType(HistorySheet), matching: find.text(titleText))
              .first
          : state == 'palette-last-selected'
              ? find.text(titleText)
              : find.text(titleText).last;
      if (state == 'palette-last-selected') {
        final scrollable = find.descendant(
            of: _key('palettePickerScroll'), matching: find.byType(Scrollable));
        await tester.scrollUntilVisible(title, -400,
            scrollable: scrollable, maxScrolls: 100);
      }
      expect(title, findsOneWidget,
          reason: '$state title must exist before capture');
      await tester.ensureVisible(title);
      await pumpAccessibilityTestFrames(tester);
      expect(title.hitTestable(), findsOneWidget,
          reason: 'Title not visible before capture');
      final surface = state.startsWith('controls-')
          ? _key('controlsHudSurface')
          : state == 'export-progress'
              ? find.byType(SingleChildScrollView).first
              : find.byType(AlertDialog).evaluate().isNotEmpty
                  ? find.descendant(
                      of: find.byType(AlertDialog).last,
                      matching: find.byWidgetPredicate(
                          (w) => w is Material && w.type == MaterialType.card))
                  : find.byType(BottomSheet).last;
      expect(surface, findsOneWidget);
      final context = tester.element(title);
      final media = MediaQuery.of(context);
      final actualTheme = Theme.of(context);
      result.measurements = {
        'surface_visible': true,
        'overlay': _rectangle(tester, surface),
        'title': _rectangle(tester, title),
        'viewport': {
          'width': media.size.width,
          'height': media.size.height,
          'dpr': media.devicePixelRatio,
          'locale': Localizations.localeOf(context).languageCode,
          'platform': defaultTargetPlatform.name,
          'text_scale': media.textScaler.scale(1),
          'view_insets_bottom':
              tester.view.viewInsets.bottom / tester.view.devicePixelRatio,
          'local_view_insets_bottom': media.viewInsets.bottom,
          'padding': [
            media.padding.left,
            media.padding.top,
            media.padding.right,
            media.padding.bottom
          ],
          'disable_animations': media.disableAnimations
        },
        'theme': {
          'requested': inputs['theme'],
          'surface': actualTheme.colorScheme.surface.toARGB32(),
          'primary': actualTheme.colorScheme.primary.toARGB32(),
          'scaffold_background': actualTheme.scaffoldBackgroundColor.toARGB32()
        },
        'content_viewports': <List<double>>[],
        'scroll_extents': <Map<String, dynamic>>[],
        'actions': <Map<String, dynamic>>[],
      };
      Future<void> photograph() async {
        await tester.pump();
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        result.png = await tester.runAsync(() async {
          final image = await boundary
              .toImage(pixelRatio: 1)
              .timeout(const Duration(seconds: 10));
          try {
            final bytes = await image
                .toByteData(format: ui.ImageByteFormat.png)
                .timeout(const Duration(seconds: 10));
            return bytes!.buffer.asUint8List();
          } finally {
            image.dispose();
          }
        });
      }

      // The named surface/title is visibly present in this image. Scroll-only
      // states are then captured at their declared content anchor, not page load.
      await photograph();
      Finder? anchor;
      if (state == 'presets-built-in')
        anchor = find.text(l10n.builtInPresets.toUpperCase());
      if (state == 'presets-user-empty') anchor = find.text(l10n.noUserPresets);
      if (state == 'presets-user-populated')
        anchor = find.text('Capture sample preset');
      if (state == 'palette-last-selected') {
        final options = controller.module.parameters
            .singleWhere((p) => p.id == 'colorScheme')
            .options;
        anchor = _key('paletteChoice${options.last.value}');
      }
      if (anchor != null) {
        if (state == 'palette-last-selected') {
          final scrollable = find.descendant(
              of: _key('palettePickerScroll'),
              matching: find.byType(Scrollable));
          await tester.scrollUntilVisible(anchor, 400,
              scrollable: scrollable, maxScrolls: 100);
        }
        await tester.ensureVisible(anchor);
        await pumpAccessibilityTestFrames(tester);
        expect(anchor.hitTestable(), findsOneWidget,
            reason: 'Declared state content not visible');
        result.measurements!['state_anchor'] = _rectangle(tester, anchor);
        await photograph();
      }
      if (state == 'share-preview') {
        final image = tester.widget<Image>(find.byType(Image).last);
        expect(image.image, isA<MemoryImage>());
        final bytes = (image.image as MemoryImage).bytes;
        expect(img.decodePng(bytes), isNotNull);
        result.measurements!['decoded_preview_size'] = overlayPngSize(bytes);
      }
      final actions = <(String, Finder)>[];
      final close = find.byTooltip(state.startsWith('controls-')
          ? l10n.semanticCloseButton
          : material.closeButtonTooltip);
      if (state == 'palette-last-selected') {
        actions.add(('Close', close));
      } else if (find.byType(AlertDialog).evaluate().isEmpty &&
          close.evaluate().isNotEmpty) {
        actions.add(('Close', close.last));
      }
      if (state == 'export-progress')
        actions.add(('Cancel', _key('cancelActiveExportButton')));
      if (state == 'export-options') {
        actions.add(('Save', _key('exportSaveButton')));
        actions.add(('Save & share (not invoked)', _key('exportShareButton')));
      }
      if (state == 'text-editor') {
        actions.add(('Cancel', _button(l10n.actionCancel)));
        actions.add(('Apply', _button(l10n.actionApply)));
      }
      if (state == 'report-notes') {
        actions.add(('Cancel', _button(l10n.buttonCancel)));
        actions.add(('Save', _button(l10n.reportDialogSave)));
      }
      if (state == 'preset-rename' || state == 'favorite-rename') {
        actions.add(('Cancel', _button(l10n.buttonCancel)));
        actions.add(('Save', _button(l10n.buttonSave)));
      }
      if (state.startsWith('history-')) {
        actions.add(('Save favorite', find.byTooltip(l10n.saveAsFavorite)));
      }
      if (state == 'share-preview' || state == 'share-fallback') {
        actions.add(('Copy (not invoked)', _button(l10n.shareViewLinkCopy)));
        actions.add(('Share (not invoked)', _button(l10n.shareViewLinkShare)));
      }
      if (state == 'video-options')
        actions.add(('Export (not invoked)', _button('Export')));
      if (state == 'wallpaper-options')
        actions.add(('Apply (not invoked)', _button(l10n.actionApply)));
      if (state == 'looper-ready')
        actions
            .add(('Export GIF (not invoked)', _key('looperExportGifButton')));
      if (state == 'theme-selector')
        actions.add(('Cancel', _button(l10n.actionCancel)));
      if (state == 'about-dialog')
        actions.add(('Close', _button(l10n.actionClose)));
      for (final (name, action) in actions) {
        if (state == 'palette-last-selected' && name == 'Close') {
          final scrollable = find.descendant(
              of: _key('palettePickerScroll'),
              matching: find.byType(Scrollable));
          await tester.scrollUntilVisible(action, -400,
              scrollable: scrollable, maxScrolls: 100);
        }
        expect(action, findsOneWidget, reason: '$name action must exist');
        await tester.ensureVisible(action);
        await pumpAccessibilityTestFrames(tester);
        final rect = tester.getRect(action);
        (result.measurements!['actions'] as List).add({
          'name': name,
          'rect': _rectangle(tester, action),
          'hit_testable': action.hitTestable().evaluate().length == 1,
          'reachable': rect.top >= -1 &&
              rect.bottom <=
                  size.height - (inputs['view_insets_bottom'] as num) + 1,
        });
      }
      for (final element in find
          .descendant(of: surface, matching: find.byType(Scrollable))
          .evaluate()) {
        final scroll = (element as StatefulElement).state as ScrollableState;
        final position = scroll.position;
        if (!position.hasContentDimensions) continue;
        (result.measurements!['content_viewports'] as List)
            .add(_rectangle(tester, find.byWidget(element.widget)));
        (result.measurements!['scroll_extents'] as List).add({
          'min': position.minScrollExtent,
          'max': position.maxScrollExtent,
          'pixels': position.pixels,
          'viewport': position.viewportDimension,
          'axis': position.axis.name,
        });
      }
      final fontFamilies = <String>{};
      for (final element in find.byType(RichText).evaluate()) {
        final text = (element.widget as RichText).text;
        final family = text.style?.fontFamily;
        if (![
          'Roboto',
          'Inter',
          'Poppins',
          'JetBrains Mono',
          'monospace',
          'MaterialIcons'
        ].contains(family)) {
          result.errors
              .add('Unbound/Ahem paragraph font: ${text.toPlainText()}');
        } else {
          fontFamilies.add(family!);
        }
      }
      result.measurements!['font_families'] = fontFamilies.toList()..sort();
      final root = semanticsRoot(tester);
      result.measurements!['semantics'] =
          buildSemanticsNarrative(traverseSemanticsTree(root));
      if (inputs['view_insets_bottom'] != 0) {
        final field = state == 'text-editor'
            ? _key('viewerTextOverlayField')
            : find.byType(TextField).last;
        await tester.ensureVisible(field);
        await tester.pump();
        final rect = tester.getRect(field);
        result.measurements!['keyboard_field_visible'] =
            field.hitTestable().evaluate().length == 1 &&
                rect.top >= 0 &&
                rect.bottom <= size.height - 300 + 1;
        result.measurements!['keyboard_field'] = _rectangle(tester, field);
        // Re-measure at the field position: actions reachable at some different
        // scroll offset are not proof they coexist above the injected IME.
        for (final action in actions.where((a) => a.$1 != 'Close')) {
          final actionRect = tester.getRect(action.$2);
          if (actionRect.bottom > size.height - 300 + 1 ||
              action.$2.hitTestable().evaluate().length != 1) {
            result.errors.add(
                'Keyboard ${action.$1} not visible alongside field: $actionRect');
          }
        }
        await photograph();
        // Restore the real pre-dialog/launcher focus; not an OS IME claim.
        await tester.binding.handlePopRoute();
        await pumpAccessibilityTestFrames(tester);
        tester.view.viewInsets = const FakeViewPadding();
        tester.binding.handleMetricsChanged();
        await tester.pump();
        result.measurements!['focus_after_dismissal'] =
            FocusManager.instance.primaryFocus?.debugLabel;
        result.measurements!['focus_before_dialog'] =
            focusBeforeDialog?.debugLabel;
        result.measurements!['dismissal_focus_restored'] =
            state == 'preset-rename'
                ? focusBeforeDialog?.hasFocus == true
                : Focus.of(tester.element(_key('fractalViewerRoot'))).hasFocus;
      }
      if (state == 'export-progress') {
        await _activate(tester, _key('cancelActiveExportButton'));
        expect(cancelled, isTrue);
      }
    }, reason: row['id'] as String);
  } catch (error, stack) {
    result.errors.add('$error\n$stack');
  } finally {
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
      Object? exception;
      while ((exception = tester.takeException()) != null) {
        result.errors.add(exception.toString());
      }
    } catch (error, stack) {
      result.errors.add('teardown: $error\n$stack');
    }
    FlutterError.onError = previous;
    debugDefaultTargetPlatformOverride = previousPlatform;
    semantics.dispose();
    history?.dispose();
    accessibility?.dispose();
    renderer?.dispose();
    controller.dispose();
    launchFocus.dispose();
    tester.view.reset();
    tester.binding.handleMetricsChanged();
  }
  return result;
}
