import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShaderLab disposes probe images after reading pixels', () {
    final source =
        File('lib/features/debug/shader_lab_screen.dart').readAsStringSync();
    final measure = _methodBody(source, 'Future<double?> _measure');

    expect(measure, contains('await ro.toImage'));
    expect(measure, contains('try {'));
    expect(measure, contains('finally {'));
    expect(measure, contains('img.dispose();'));
  });

  test('video capture disposes RenderRepaintBoundary images', () {
    final source = File('lib/core/services/export/video_export_service.dart')
        .readAsStringSync();

    expect(source, contains('await boundary.toImage'));
    expect(source, contains('try {'));
    expect(source, contains('finally {'));
    expect(source, contains('image.dispose();'));
  });

  test('batch export post-frame callback does not start after dispose', () {
    final source =
        File('lib/features/export/batch_export_dialog.dart').readAsStringSync();
    final init = _methodBody(source, 'void initState()');

    expect(init, contains('addPostFrameCallback'));
    expect(init, contains('if (!mounted) return;'));
    expect(init, contains('_run();'));
  });

  test('batch export checks mounted after loading user presets', () {
    final source =
        File('lib/features/export/batch_export_dialog.dart').readAsStringSync();

    expect(
      source,
      contains(
        'final user = await presetStore.loadUserPresets(controller.module.id);\n'
        '      if (!mounted) return;',
      ),
    );
  });

  test('catalog search autofocus post-frame callback checks mounted', () {
    final source = File('lib/features/catalog/fractal_catalog_screen.dart')
        .readAsStringSync();

    expect(
      source,
      contains(
        'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
        '          if (!mounted) return;\n'
        '          _focusNode.requestFocus();',
      ),
    );
  });

  test('log viewer autoscroll post-frame callback checks mounted', () {
    final source =
        File('lib/features/debug/log_viewer_screen.dart').readAsStringSync();

    expect(
      source,
      contains(
        'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
        '          if (!mounted) return;\n'
        '          if (_scroll.hasClients)',
      ),
    );
  });

  test('home initial deep-link post-frame callback checks mounted', () {
    final source =
        File('lib/features/home/home_screen.dart').readAsStringSync();

    expect(
      source,
      contains(
        'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
        '      if (!mounted) return;\n'
        '      if (!_handledInitialLink',
      ),
    );
  });

  test('palette service dispose clears cached ui images', () {
    final source = File('lib/core/services/rendering/palette_service.dart')
        .readAsStringSync();
    final dispose = _methodBody(source, 'void dispose()');

    expect(dispose, contains('invalidatePaletteTextures();'));
    expect(dispose, contains('_instance = null;'));
    expect(dispose, contains('super.dispose();'));
  });

  test('palette service create disposes replaced singleton instance', () {
    final source = File('lib/core/services/rendering/palette_service.dart')
        .readAsStringSync();

    expect(source, contains('final previous = _instance;'));
    expect(source, contains('previous.dispose();'));
    expect(source, contains('_instance = service;'));
  });

  test('CPU tile worker closes its receive port on dispose and spawn failure',
      () {
    final source = File('lib/features/renderer/cpu/cpu_tile_worker.dart')
        .readAsStringSync();
    final dispose = _methodBody(source, 'void dispose()');

    expect(source, contains('final ReceivePort _receivePort;'));
    expect(dispose, contains('_receivePort.close();'));
    expect(source, contains('receive.close();'));
  });

  test('PictureRecorder outputs dispose native Picture resources', () {
    final files = [
      'lib/core/modules/gpu_sampler_diag_module.dart',
      'lib/core/modules/julia_perturb_module.dart',
      'lib/core/modules/escape_time_perturb_module.dart',
      'lib/core/modules/builders/escape_time/builder.dart',
      'lib/core/services/rendering/palette_service.dart',
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('endRecording().toImageSync')),
          reason: path);
      if (source.contains('PictureRecorder')) {
        expect(source, contains('picture.dispose();'), reason: path);
      }
    }
  });

  test('thumbnail and icon images decode bounded previews', () {
    final batchExport =
        File('lib/features/export/batch_export_dialog.dart').readAsStringSync();
    final catalogWidgets =
        File('lib/features/catalog/widgets/catalog_widgets.dart')
            .readAsStringSync();
    final homeScreen =
        File('lib/features/home/home_screen.dart').readAsStringSync();

    expect(batchExport, contains('Image.file('));
    expect(batchExport, contains('cacheWidth: 256'));
    expect(batchExport, contains('cacheHeight: 256'));
    expect(catalogWidgets, contains('Image.asset('));
    expect(catalogWidgets, contains('cacheWidth: 256'));
    expect(catalogWidgets, contains('cacheHeight: 256'));
    expect(homeScreen, contains('cacheWidth: 64'));
    expect(homeScreen, contains('cacheHeight: 64'));
  });

  test('history provider async methods skip notify after dispose', () {
    final source =
        File('lib/features/history/history_provider.dart').readAsStringSync();
    final dispose = _methodBody(source, 'void dispose()');

    expect(source, contains('bool _disposed = false;'));
    expect(source, contains('void _notifyIfAlive()'));
    expect(dispose, contains('_disposed = true;'));
    expect(source, isNot(contains('    notifyListeners();')));
  });

  test('async ChangeNotifier services skip notify after dispose', () {
    final paths = [
      'lib/core/services/storage/exploration_stats_service.dart',
      'lib/core/services/storage/renderer_settings_service.dart',
      'lib/core/services/platform/accessibility_service.dart',
      'lib/core/services/rendering/palette_service.dart',
      'lib/core/services/rendering/animation_controller_service.dart',
      'lib/core/services/diagnostics/performance_service.dart',
      'lib/core/services/diagnostics/debug_runner_service.dart',
      'lib/core/services/diagnostics/app_logger_service.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      final dispose = _methodBody(source, 'void dispose()');

      expect(source, contains('bool _disposed = false;'), reason: path);
      expect(source, contains('void _notifyIfAlive()'), reason: path);
      expect(dispose, contains('_disposed = true;'), reason: path);
    }
  });

  test('deferred startup disposes services it creates', () {
    final source = File('lib/app/startup.dart').readAsStringSync();
    final stateDispose = _methodBody(source, 'void dispose()');
    final servicesDispose = source.substring(
      source.indexOf('class _StartupServices'),
    );

    expect(source, contains('_StartupServices? _startupServices;'));
    expect(stateDispose, contains('_disposeStartupServices();'));
    expect(servicesDispose, contains('deepLinkService?.dispose();'));
    expect(servicesDispose, contains('paletteService.dispose();'));
    expect(servicesDispose, contains('rendererSettingsService.dispose();'));
    expect(servicesDispose, contains('accessibilityService.dispose();'));
  });

  test('debug runner disposes its owned test logger', () {
    final source =
        File('lib/core/services/diagnostics/debug_runner_service.dart')
            .readAsStringSync();
    final dispose = _methodBody(source, 'void dispose()');

    expect(dispose, contains('unawaited(_logger.dispose());'));
  });

  test('app logger dispose keeps ChangeNotifier dispose synchronous', () {
    final source = File('lib/core/services/diagnostics/app_logger_service.dart')
        .readAsStringSync();
    final dispose = _methodBody(source, 'void dispose()');
    final truncate = _methodBody(source, 'Future<void> _truncateDisk()');

    expect(source, isNot(contains('Future<void> dispose()')));
    expect(dispose, contains('unawaited(_closeSink(sink));'));
    expect(truncate, contains('if (_disposed) return;'));
  });
}

String _methodBody(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: signature);

  final open = source.indexOf('{', start);
  expect(open, isNonNegative, reason: signature);

  var depth = 0;
  for (var i = open; i < source.length; i++) {
    final char = source.codeUnitAt(i);
    if (char == 123) depth++;
    if (char == 125) depth--;
    if (depth == 0) return source.substring(open, i + 1);
  }
  fail('Unterminated method body for $signature');
}
