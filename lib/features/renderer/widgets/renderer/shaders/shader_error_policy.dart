/// Types of shader errors for categorization and display.
enum ShaderErrorType {
  /// Shader code failed to compile on the GPU.
  compilation,

  /// The shader asset file was not found.
  assetNotFound,

  /// GPU ran out of memory.
  outOfMemory,

  /// GPU does not support required features.
  gpuUnsupported,

  /// Unknown or uncategorized error.
  unknown,
}

/// Classifies shader loading failures and provides stable user-facing copy.
class ShaderErrorPolicy {
  const ShaderErrorPolicy();

  ShaderErrorType categorize(Object error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('compile') || errorString.contains('glsl')) {
      return ShaderErrorType.compilation;
    }
    if (errorString.contains('not found') || errorString.contains('asset')) {
      return ShaderErrorType.assetNotFound;
    }
    if (errorString.contains('memory') || errorString.contains('oom')) {
      return ShaderErrorType.outOfMemory;
    }
    if (errorString.contains('gpu') || errorString.contains('driver')) {
      return ShaderErrorType.gpuUnsupported;
    }
    return ShaderErrorType.unknown;
  }

  String errorMessage(Object error, ShaderErrorType type) {
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
        final text = error.toString();
        final clipped =
            text.length > 100 ? '${text.substring(0, 100)}...' : text;
        return 'Failed to load shader: $clipped';
    }
  }

  String tipFor(ShaderErrorType type) {
    switch (type) {
      case ShaderErrorType.compilation:
        return 'This fractal\'s shader may not be compatible with your GPU. Try a simpler fractal type.';
      case ShaderErrorType.assetNotFound:
        return 'The shader file appears to be missing. Reinstalling the app may fix this issue.';
      case ShaderErrorType.outOfMemory:
        return 'Close other apps to free up GPU memory, then try again.';
      case ShaderErrorType.gpuUnsupported:
        return 'Your device\'s GPU may not support the features required by this fractal.';
      case ShaderErrorType.unknown:
        return 'If this problem persists, try restarting the app or your device.';
    }
  }
}
