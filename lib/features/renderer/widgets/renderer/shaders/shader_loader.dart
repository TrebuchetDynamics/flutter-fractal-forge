part of '../fractal_renderer.dart';

/// Mixin that handles shader loading, caching, and error categorisation.
///
/// Apply to `State<FractalRenderer>`.
mixin _ShaderLoaderMixin on State<FractalRenderer> {
  static const int _maxProgramCacheEntries = 256;
  static final LinkedHashMap<String, ui.FragmentProgram> _programCache =
      LinkedHashMap<String, ui.FragmentProgram>();
  static final Map<String, Future<ui.FragmentProgram>> _programLoads = {};

  /// Maximum number of shader load retries before showing error.
  static const int _maxShaderRetries = 3;
  static const ShaderErrorPolicy _shaderErrorPolicy = ShaderErrorPolicy();

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

  void _setLoadedProgram(String asset, ui.FragmentProgram program) {
    _program = program;
    _shaderForCachedFragment = null;
    _cachedFragmentShader = null;
    _shaderAsset = asset;
    _shaderRetryCount = 0;
    _loading = false;
  }

  void clearStaleShader() {
    _program = null;
    _shaderForCachedFragment = null;
    _cachedFragmentShader = null;
  }

  Future<ui.FragmentProgram> _loadProgramFromAsset(String asset) {
    return _programLoads.putIfAbsent(asset, () async {
      try {
        return await ui.FragmentProgram.fromAsset(asset);
      } finally {
        _programLoads.remove(asset);
      }
    });
  }

  /// Loads a shader with retry logic and error reporting.
  ///
  /// Attempts to load the shader up to [_maxShaderRetries] times before
  /// giving up. Reports all failures to [CrashReporter].
  Future<void> _loadShader(String asset) async {
    if (_shaderAsset == asset && _program != null && _shaderError == null) {
      return;
    }
    if (_loading) {
      return;
    }
    _shaderLoadStartedAt = DateTime.now();

    final cached = _takeProgramFromCache(asset);
    if (cached != null) {
      _setLoadedProgram(asset, cached);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      final dt = DateTime.now()
          .difference(_shaderLoadStartedAt ?? DateTime.now())
          .inMilliseconds;
      if (kDebugMode)
        debugPrint(
            '[renderer] shader_cache_hit asset=$asset load_ms=$dt cache_size=${_programCache.length}');
      AppLogger.instance.logState('gpu', 'Shader loaded', {
        'asset': asset,
        'compileMs': dt,
        'fromCache': true,
      });
      return;
    }

    _loading = true;
    if (kDebugMode) debugPrint('[renderer] shader_load_start asset=$asset');
    clearStaleShader();
    _shaderAsset = asset;
    _shaderError = null;
    _shaderErrorDetails = null;
    _firstFrameLogged = false;

    for (var attempt = 1; attempt <= _maxShaderRetries; attempt++) {
      try {
        final program = await _loadProgramFromAsset(asset);
        _storeProgramInCache(asset, program);
        if (mounted) {
          setState(() => _setLoadedProgram(asset, program));
        }
        final dt = DateTime.now()
            .difference(_shaderLoadStartedAt ?? DateTime.now())
            .inMilliseconds;
        if (kDebugMode)
          debugPrint('[renderer] shader_load_ok asset=$asset compile_ms=$dt');
        AppLogger.instance.logState(
            'gpu', 'Shader loaded', {'asset': asset, 'compileMs': dt});
        _loading = false;
        return;
      } catch (e, stack) {
        final errorType = _shaderErrorPolicy.categorize(e);
        if (kDebugMode)
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
        CrashReporter.instanceOrNull?.record(
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
            _shaderError = _shaderErrorPolicy.errorMessage(e, errorType);
            _shaderErrorDetails = e.toString();
            _shaderErrorType = errorType;
            _shaderRetryCount = attempt;
          });
        }
      }
    }

    _loading = false;
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
