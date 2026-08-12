part of '../fractal_renderer.dart';

/// Mixin that handles shader loading, caching, and error categorisation.
///
/// Apply to `State<FractalRenderer>`.
mixin _ShaderLoaderMixin on State<FractalRenderer> {
  static const int _maxProgramCacheEntries = 256;
  static final LinkedHashMap<String, ui.FragmentProgram> _programCache =
      LinkedHashMap<String, ui.FragmentProgram>();
  static final Map<String, Future<ui.FragmentProgram>> _programLoads = {};
  static final ShaderLoadEpoch _programLoadEpoch = ShaderLoadEpoch();

  static void clearProgramCache() {
    _programLoadEpoch.invalidate();
    _programCache.clear();
    _programLoads.clear();
  }

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
    _disposeCachedFragmentShader();
    _program = null;
    super.dispose();
  }

  void _disposeCachedFragmentShader() {
    final shader = _cachedFragmentShader;
    if (shader != null) {
      _rendererShaderCache.release(shader);
    }
    _cachedFragmentShader = null;
    _shaderForCachedFragment = null;
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
      AppLogger.instance.debug('gpu', 'Shader program cache eviction', data: {
        'asset': oldestKey,
        'size': _programCache.length,
      });
    }
  }

  void _setLoadedProgram(String asset, ui.FragmentProgram program) {
    _disposeCachedFragmentShader();
    _program = program;
    _shaderAsset = asset;
    _shaderRetryCount = 0;
    _loading = false;
  }

  void clearStaleShader() {
    _program = null;
    _disposeCachedFragmentShader();
  }

  Future<ui.FragmentProgram> _loadProgramFromAsset(String asset) {
    final existing = _programLoads[asset];
    if (existing != null) return existing;

    late final Future<ui.FragmentProgram> load;
    load = ui.FragmentProgram.fromAsset(asset).whenComplete(() {
      if (identical(_programLoads[asset], load)) {
        _programLoads.remove(asset);
      }
    });
    _programLoads[asset] = load;
    return load;
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
      AppLogger.instance.logState('gpu', 'Shader loaded', {
        'asset': asset,
        'compileMs': dt,
        'fromCache': true,
      });
      return;
    }

    _loading = true;
    AppLogger.instance.debug(
      'gpu',
      'Shader load started',
      data: {'asset': asset},
    );
    clearStaleShader();
    _shaderAsset = asset;
    _shaderError = null;
    _shaderErrorDetails = null;
    _firstFrameLogged = false;

    for (var attempt = 1; attempt <= _maxShaderRetries; attempt++) {
      try {
        final loadEpoch = _programLoadEpoch.capture();
        final program = await _loadProgramFromAsset(asset);
        if (!_programLoadEpoch.isCurrent(loadEpoch)) {
          _loading = false;
          if (mounted) {
            setState(() {});
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_loading && _program == null) {
                _loadShader(asset);
              }
            });
          }
          return;
        }
        _storeProgramInCache(asset, program);
        if (mounted) {
          setState(() => _setLoadedProgram(asset, program));
        }
        final dt = DateTime.now()
            .difference(_shaderLoadStartedAt ?? DateTime.now())
            .inMilliseconds;
        AppLogger.instance.logState(
            'gpu', 'Shader loaded', {'asset': asset, 'compileMs': dt});
        _loading = false;
        return;
      } catch (e, stack) {
        final errorType = _shaderErrorPolicy.categorize(e);
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
      _disposeCachedFragmentShader();
      final asset = _shaderAsset;
      assert(asset != null);
      _cachedFragmentShader = _rendererShaderCache.acquire(
        '$asset#${identityHashCode(program)}',
        program.fragmentShader,
      );
      _shaderForCachedFragment = program;
    }
    return _cachedFragmentShader!;
  }
}
