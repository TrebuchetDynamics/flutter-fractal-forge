part of 'fractal_renderer.dart';

/// Mixin that handles shader loading, caching, and error categorisation.
///
/// Apply to `State<FractalRenderer>`.
mixin _ShaderLoaderMixin on State<FractalRenderer> {
  static const int _maxProgramCacheEntries = 24;
  static final LinkedHashMap<String, ui.FragmentProgram> _programCache =
      LinkedHashMap<String, ui.FragmentProgram>();

  /// Maximum number of shader load retries before showing error.
  static const int _maxShaderRetries = 3;

  ui.FragmentProgram? _program;
  ui.FragmentProgram? _shaderForCachedFragment;
  ui.FragmentShader? _cachedFragmentShader;
  String? _shaderAsset;
  bool _loading = false;
  String? _shaderError;
  String? _shaderErrorDetails;
  ShaderErrorType _shaderErrorType = ShaderErrorType.unknown;
  int _shaderRetryCount = 0;
  DateTime? _shaderLoadStartedAt;
  bool _firstFrameLogged = false;

  @override
  void dispose() {
    _cachedFragmentShader = null;
    _shaderForCachedFragment = null;
    _program = null;
    super.dispose();
  }

  ui.FragmentProgram? _takeProgramFromCache(String asset) {
    final cached = _programCache.remove(asset);
    if (cached != null) {
      // Move to MRU position.
      _programCache[asset] = cached;
    }
    return cached;
  }

  void _storeProgramInCache(String asset, ui.FragmentProgram program) {
    _programCache.remove(asset);
    _programCache[asset] = program;

    while (_programCache.length > _maxProgramCacheEntries) {
      final oldestKey = _programCache.keys.first;
      _programCache.remove(oldestKey);
      if (kDebugMode) {
        debugPrint(
          '[renderer] shader_cache_evict asset=$oldestKey size=${_programCache.length}',
        );
      }
    }
  }

  /// Loads a shader with retry logic and error reporting.
  ///
  /// Attempts to load the shader up to [_maxShaderRetries] times before
  /// giving up. Reports all failures to [CrashReporter].
  Future<void> _loadShader(String asset) async {
    if (_loading) {
      return;
    }
    _loading = true;
    _shaderLoadStartedAt = DateTime.now();
    debugPrint('[renderer] shader_load_start asset=$asset');
    setState(() {
      _shaderError = null;
      _shaderErrorDetails = null;
    });

    final cached = _takeProgramFromCache(asset);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _program = cached;
          _shaderForCachedFragment = null;
          _cachedFragmentShader = null;
          _shaderAsset = asset;
          _shaderRetryCount = 0;
          _loading = false;
        });
      } else {
        _program = cached;
        _shaderForCachedFragment = null;
        _cachedFragmentShader = null;
        _shaderAsset = asset;
        _shaderRetryCount = 0;
      }
      final dt = DateTime.now()
          .difference(_shaderLoadStartedAt ?? DateTime.now())
          .inMilliseconds;
      debugPrint(
          '[renderer] shader_cache_hit asset=$asset load_ms=$dt cache_size=${_programCache.length}');
      AppLogger.instance.logState('gpu', 'Shader loaded', {
        'asset': asset,
        'compileMs': dt,
        'fromCache': true,
      });
      _loading = false;
      return;
    }

    for (var attempt = 1; attempt <= _maxShaderRetries; attempt++) {
      try {
        final program = await ui.FragmentProgram.fromAsset(asset);
        _storeProgramInCache(asset, program);
        if (mounted) {
          setState(() {
            _program = program;
            _shaderForCachedFragment = null;
            _cachedFragmentShader = null;
            _shaderAsset = asset;
            _shaderRetryCount = 0;
            _loading = false;
          });
        }
        final dt = DateTime.now()
            .difference(_shaderLoadStartedAt ?? DateTime.now())
            .inMilliseconds;
        debugPrint('[renderer] shader_load_ok asset=$asset compile_ms=$dt');
        AppLogger.instance.logState(
            'gpu', 'Shader loaded', {'asset': asset, 'compileMs': dt});
        _loading = false;
        return;
      } catch (e, stack) {
        final errorType = _categorizeShaderError(e);
        debugPrint(
            '[renderer] shader_load_fail asset=$asset attempt=$attempt type=$errorType err=$e');
        AppLogger.instance.logState(
            'gpu',
            'Shader load failed',
            {
              'asset': asset,
              'attempt': attempt,
              'type': errorType.name,
              'error': e.toString(),
            },
            level: LogLevel.error);

        // Report to crash reporter
        CrashReporter.instance.record(
          e,
          stack,
          source: 'shader_load',
          fatal: false,
          context: 'Attempt $attempt/$_maxShaderRetries for $asset',
          tags: {
            'shader_asset': asset,
            'attempt': attempt.toString(),
            'error_type': errorType.name,
          },
        );

        if (attempt < _maxShaderRetries) {
          // Wait before retrying with exponential backoff
          await Future.delayed(Duration(milliseconds: 100 * attempt));
          continue;
        }

        // Final failure
        if (mounted) {
          setState(() {
            _shaderError = _getShaderErrorMessage(e, errorType);
            _shaderErrorDetails = e.toString();
            _shaderErrorType = errorType;
            _shaderRetryCount = attempt;
          });
        }
      }
    }

    _loading = false;
  }

  /// Categorizes shader errors for better error messages.
  ShaderErrorType _categorizeShaderError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('compile') || message.contains('glsl')) {
      return ShaderErrorType.compilation;
    }
    if (message.contains('not found') || message.contains('asset')) {
      return ShaderErrorType.assetNotFound;
    }
    if (message.contains('memory') || message.contains('oom')) {
      return ShaderErrorType.outOfMemory;
    }
    if (message.contains('gpu') || message.contains('driver')) {
      return ShaderErrorType.gpuUnsupported;
    }
    return ShaderErrorType.unknown;
  }

  /// Returns a user-friendly error message based on error type.
  String _getShaderErrorMessage(Object error, ShaderErrorType type) {
    switch (type) {
      case ShaderErrorType.compilation:
        return 'Shader compilation failed. This fractal may not be compatible with your device.';
      case ShaderErrorType.assetNotFound:
        return 'Shader file not found. Please reinstall the app.';
      case ShaderErrorType.outOfMemory:
        return 'Not enough GPU memory. Try closing other apps.';
      case ShaderErrorType.gpuUnsupported:
        return 'Your GPU does not support this fractal\'s shader requirements.';
      case ShaderErrorType.unknown:
        return 'Failed to load shader: ${error.toString().length > 100 ? '${error.toString().substring(0, 100)}...' : error}';
    }
  }

  /// Retries loading the current shader.
  void _retryShaderLoad() {
    if (_shaderAsset != null ||
        context.read<FractalController>().module.shaderAsset.isNotEmpty) {
      final asset =
          _shaderAsset ?? context.read<FractalController>().module.shaderAsset;
      _loading = false; // Reset loading flag to allow retry
      _loadShader(asset);
    }
  }

  ui.FragmentShader _currentFragmentShader(ui.FragmentProgram program) {
    if (_cachedFragmentShader == null || _shaderForCachedFragment != program) {
      _cachedFragmentShader = program.fragmentShader();
      _shaderForCachedFragment = program;
    }
    return _cachedFragmentShader!;
  }
}
