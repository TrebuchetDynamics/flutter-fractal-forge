import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';

/// Service for pre-compiling shaders at app startup to eliminate
/// first-load jank and improve perceived performance.
///
/// Shader compilation can take 50-400ms per shader on first load,
/// causing noticeable frame drops. By warming shaders during the
/// splash screen, we ensure smooth 60fps when the user first views
/// a fractal.
class ShaderWarmingService {
  static final ShaderWarmingService _instance =
      ShaderWarmingService._internal();
  factory ShaderWarmingService() => _instance;
  ShaderWarmingService._internal();

  final AppLogger _log = AppLogger.instance;

  /// Cache of pre-compiled shader programs
  final Map<String, ui.FragmentProgram> _shaderCache = {};

  /// Whether shader warming is in progress
  bool _isWarming = false;

  /// Progress callback for UI updates
  void Function(double progress)? onProgress;

  /// Completion callback
  void Function()? onComplete;

  /// Returns true if shaders are being warmed
  bool get isWarming => _isWarming;

  /// Returns the number of cached shaders
  int get cachedCount => _shaderCache.length;

  /// Core shaders that should be warmed at startup
  /// Ordered by priority (most commonly used first)
  static const List<String> _coreShaders = [
    'shaders/mandelbrot.frag',
    'shaders/julia.frag',
    'shaders/burning_ship.frag',
    'shaders/phoenix.frag',
    'shaders/mandelbulb.frag',
    'shaders/tricorn.frag',
    'shaders/multibrot.frag',
    'shaders/celtic.frag',
    'shaders/buffalo.frag',
    'shaders/dragon.frag',
  ];

  /// Warms the core set of shaders asynchronously.
  ///
  /// Call this during app startup/splash screen. The warming process
  /// runs in parallel with other initialization tasks.
  ///
  /// [priorityCount] - Number of shaders to warm immediately (default: 5)
  /// [backgroundCount] - Number of additional shaders to warm in background (default: 5)
  Future<void> warmShaders({
    int priorityCount = 5,
    int backgroundCount = 5,
  }) async {
    if (_isWarming) return;

    _isWarming = true;
    _log.info('shader_warming', 'Starting shader warming', data: {
      'priority_count': priorityCount,
      'background_count': backgroundCount,
    });

    final stopwatch = Stopwatch()..start();

    try {
      // Warm priority shaders first (blocking)
      final priorityShaders = _coreShaders.take(priorityCount).toList();
      await _warmShaderBatch(priorityShaders, isPriority: true);

      _log.info('shader_warming', 'Priority shaders warmed', data: {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'cached': _shaderCache.length,
      });

      // Warm remaining shaders in background
      if (backgroundCount > 0) {
        final backgroundShaders =
            _coreShaders.skip(priorityCount).take(backgroundCount).toList();

        // Don't await - let this run in background
        _warmShaderBatch(backgroundShaders, isPriority: false).then((_) {
          _isWarming = false;
          onComplete?.call();
          _log.info('shader_warming', 'Background warming complete', data: {
            'total_duration_ms': stopwatch.elapsedMilliseconds,
            'total_cached': _shaderCache.length,
          });
        });
      } else {
        _isWarming = false;
        onComplete?.call();
      }
    } catch (e, stack) {
      _isWarming = false;
      _log.error('shader_warming', 'Failed to warm shaders', data: {
        'error': e.toString(),
        'stack': stack.toString(),
      });
    } finally {
      stopwatch.stop();
    }
  }

  /// Warms a batch of shaders
  Future<void> _warmShaderBatch(List<String> shaderPaths,
      {required bool isPriority}) async {
    final total = shaderPaths.length;

    for (int i = 0; i < total; i++) {
      final path = shaderPaths[i];

      if (_shaderCache.containsKey(path)) continue;

      try {
        final stopwatch = Stopwatch()..start();
        final program = await ui.FragmentProgram.fromAsset(path);
        stopwatch.stop();

        _shaderCache[path] = program;

        final progress = (i + 1) / total;
        onProgress?.call(progress);

        if (kDebugMode) {
          _log.debug('shader_warming', 'Warmed shader', data: {
            'path': path,
            'compile_ms': stopwatch.elapsedMilliseconds,
            'priority': isPriority,
          });
        }
      } catch (e) {
        _log.info('shader_warming', 'Failed to warm shader', data: {
          'path': path,
          'error': e.toString(),
        });
      }
    }
  }

  /// Gets a pre-warmed shader program, or null if not cached.
  ///
  /// Falls back to runtime compilation if not in cache.
  Future<ui.FragmentProgram?> getShader(String path) async {
    // Return cached shader if available
    if (_shaderCache.containsKey(path)) {
      return _shaderCache[path];
    }

    // Compile on-demand if not cached
    try {
      final program = await ui.FragmentProgram.fromAsset(path);
      _shaderCache[path] = program;
      return program;
    } catch (e) {
      _log.error('shader_warming', 'Failed to compile shader on-demand', data: {
        'path': path,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Clears the shader cache to free memory.
  ///
  /// Call this when the app goes to background or when
  /// memory pressure is detected.
  void clearCache() {
    _shaderCache.clear();
    _log.info('shader_warming', 'Shader cache cleared');
  }

  /// Disposes a specific shader from cache.
  void disposeShader(String path) {
    _shaderCache.remove(path);
  }
}
