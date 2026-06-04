import 'package:flutter_fractals/features/renderer/widgets/renderer/shaders/shader_error_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShaderErrorPolicy', () {
    const policy = ShaderErrorPolicy();

    test('categorizes common shader failure messages', () {
      expect(policy.categorize('GLSL compile failed'),
          ShaderErrorType.compilation);
      expect(
          policy.categorize('asset not found'), ShaderErrorType.assetNotFound);
      expect(policy.categorize('GPU memory OOM'), ShaderErrorType.outOfMemory);
      expect(policy.categorize('driver rejected shader'),
          ShaderErrorType.gpuUnsupported);
      expect(policy.categorize('unexpected failure'), ShaderErrorType.unknown);
    });

    test('keeps user-facing copy stable for loader callers', () {
      expect(
        policy.errorMessage('compile failed', ShaderErrorType.compilation),
        'Shader compilation failed. This fractal may not be compatible with your device.',
      );
      expect(
        policy.errorMessage('missing', ShaderErrorType.assetNotFound),
        'Shader file not found. Please reinstall the app.',
      );
      expect(
        policy.errorMessage('oom', ShaderErrorType.outOfMemory),
        'Not enough GPU memory. Try closing other apps.',
      );
      expect(
        policy.errorMessage('driver', ShaderErrorType.gpuUnsupported),
        'Your GPU does not support this fractal\'s shader requirements.',
      );
    });

    test('keeps recovery tips stable for display callers', () {
      expect(
        policy.tipFor(ShaderErrorType.compilation),
        'This fractal\'s shader may not be compatible with your GPU. Try a simpler fractal type.',
      );
      expect(
        policy.tipFor(ShaderErrorType.assetNotFound),
        'The shader file appears to be missing. Reinstalling the app may fix this issue.',
      );
      expect(
        policy.tipFor(ShaderErrorType.outOfMemory),
        'Close other apps to free up GPU memory, then try again.',
      );
      expect(
        policy.tipFor(ShaderErrorType.gpuUnsupported),
        'Your device\'s GPU may not support the features required by this fractal.',
      );
      expect(
        policy.tipFor(ShaderErrorType.unknown),
        'If this problem persists, try restarting the app or your device.',
      );
    });

    test('clips long unknown failure messages', () {
      final message = policy.errorMessage('x' * 120, ShaderErrorType.unknown);

      expect(message, startsWith('Failed to load shader: '));
      expect(message, endsWith('...'));
      expect(message.length, lessThan(130));
    });
  });
}
