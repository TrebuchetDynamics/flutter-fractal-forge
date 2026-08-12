import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/shaders/shader_memory_pressure_observer.dart';
import 'package:flutter_fractals/core/shaders/shader_load_epoch.dart';
import 'package:flutter_fractals/core/shaders/shader_resource_cache.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('memory pressure invalidates shader loads already in flight', () {
    final epoch = ShaderLoadEpoch();
    final inFlightEpoch = epoch.capture();

    epoch.invalidate();

    expect(epoch.isCurrent(inFlightEpoch), isFalse);
    expect(epoch.isCurrent(epoch.capture()), isTrue);
  });

  test('evicts the least recently used released shader and disposes it', () {
    final disposed = <_FakeShader>[];
    final cache = ShaderResourceCache<_FakeShader>(
      maximumSize: 2,
      disposeResource: disposed.add,
    );

    final first = cache.acquire('first', () => _FakeShader('first'));
    cache.release(first);
    final second = cache.acquire('second', () => _FakeShader('second'));
    cache.release(second);

    final reusedFirst =
        cache.acquire('first', () => _FakeShader('replacement'));
    cache.release(reusedFirst);
    final third = cache.acquire('third', () => _FakeShader('third'));
    cache.release(third);

    expect(reusedFirst, same(first));
    expect(disposed, [second]);
    expect(cache.metrics.size, 2);
    expect(cache.metrics.evictions, 1);
    expect(cache.metrics.lastClearReason, isNull);
  });

  test('memory pressure clears idle shaders and defers active disposal', () {
    final disposed = <_FakeShader>[];
    final cache = ShaderResourceCache<_FakeShader>(
      maximumSize: 2,
      disposeResource: disposed.add,
    );

    final idle = cache.acquire('idle', () => _FakeShader('idle'));
    cache.release(idle);
    final painting = cache.acquire('painting', () => _FakeShader('painting'));

    cache.clear(ShaderCacheClearReason.memoryPressure);

    expect(disposed, [idle]);
    expect(cache.metrics.size, 0);
    expect(
      cache.metrics.lastClearReason,
      ShaderCacheClearReason.memoryPressure,
    );

    cache.release(painting);
    expect(disposed, [idle, painting]);
    expect(cache.metrics.size, 0);
  });

  testWidgets('memory pressure observer forwards Flutter lifecycle signal', (
    tester,
  ) async {
    var pressureSignals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ShaderMemoryPressureObserver(
          onMemoryPressure: () => pressureSignals++,
          child: const SizedBox(),
        ),
      ),
    );

    tester.binding.handleMemoryPressure();
    await tester.pump();

    expect(pressureSignals, 1);
  });

  test('renderer exposes memory-pressure cache metrics', () {
    FractalRenderer.clearShaderCacheForMemoryPressure();

    expect(
      FractalRenderer.shaderCacheMetrics.lastClearReason,
      ShaderCacheClearReason.memoryPressure,
    );
  });

  test('Android trim-memory callback is forwarded to Flutter embedding', () {
    final source = File(
      'android/app/src/main/kotlin/com/fractals/flutter_fractals/MainActivity.kt',
    ).readAsStringSync();

    expect(source, contains('override fun onTrimMemory(level: Int)'));
    expect(source, contains('super.onTrimMemory(level)'));
  });

  test('app shell connects lifecycle pressure to the renderer cache', () {
    final source = File('lib/app/flutter_fractals_app.dart').readAsStringSync();

    expect(source, contains('ShaderMemoryPressureObserver('));
    expect(
      source,
      contains(
        'onMemoryPressure: FractalRenderer.clearShaderCacheForMemoryPressure',
      ),
    );
  });
}

class _FakeShader {
  const _FakeShader(this.name);

  final String name;

  @override
  String toString() => name;
}
