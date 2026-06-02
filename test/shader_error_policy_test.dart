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

    test('keeps user-facing copy stable for loader and display callers', () {
      expect(
        policy.errorMessage('compile failed', ShaderErrorType.compilation),
        'Shader compilation failed. This fractal may not be compatible with your device.',
      );
      expect(
        policy.tipFor(ShaderErrorType.assetNotFound),
        'The shader file appears to be missing. Reinstalling the app may fix this issue.',
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
