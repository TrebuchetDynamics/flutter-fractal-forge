import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_codec.dart'
    as codec;
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart'
    as legacy;
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('stateless codec and legacy facade preserve the same link contract', () {
    // The old import must expose the very same DTO, not a wrapper or copy.
    expect(legacy.DeepLinkData, codec.DeepLinkData);
    for (final row in [
      (
        link: 'fractalforge://view?type=julia&zoom=1e-9'
            '&x=-0.743643887037151&juliaX=-0.7&iterations=120.5',
        expected: const codec.DeepLinkData(
          type: 'julia',
          zoom: 1e-9,
          x: -0.743643887037151,
          juliaX: -0.7,
          iterations: 121,
        ),
        browserOnly: false,
      ),
      (
        link: 'https://fractalforge.app/view/?t=julia&z=7'
            '&param.custom=0.125&param.enabled=true&param.label=%22blue%22',
        expected: const codec.DeepLinkData(
          type: 'julia',
          zoom: 7,
          extraParams: {'custom': 0.125, 'enabled': true, 'label': 'blue'},
        ),
        browserOnly: false,
      ),
      (
        link: 'http://localhost:8880/?type=julia&zoom=7',
        expected: const codec.DeepLinkData(type: 'julia', zoom: 7),
        browserOnly: true,
      ),
      (
        link: 'fractalforge:view?type=julia&zoom=NaN&iterations=99999&p=!',
        expected: const codec.DeepLinkData(type: 'julia', iterations: 10000),
        browserOnly: false,
      ),
      (
        link: 'fractalforge://view?type=julia&zoom=5&zoom=abc',
        expected: null,
        browserOnly: false,
      ),
      (
        link: 'fractalforge://view?type=julia&t=julia',
        expected: null,
        browserOnly: false,
      ),
      (
        link: 'fractalforge://view?type=%',
        expected: null,
        browserOnly: false,
      ),
    ]) {
      final uri = Uri.parse(row.link);
      for (final parse in [
        codec.DeepLinkCodec.parseIncomingLink,
        legacy.DeepLinkService.parseIncomingLink,
      ]) {
        _expectData(parse(row.link), row.browserOnly ? null : row.expected);
        expect(parse(row.link, validFractalTypes: ['mandelbrot']), isNull);
        expect(parse(42), isNull);
      }
      for (final parse in [
        codec.DeepLinkCodec.parseUri,
        legacy.DeepLinkService.parseUri,
      ]) {
        _expectData(parse(uri), row.browserOnly ? null : row.expected);
        expect(parse(uri, validFractalTypes: ['mandelbrot']), isNull);
      }
      for (final parse in [
        codec.DeepLinkCodec.parseBrowserUri,
        legacy.DeepLinkService.parseBrowserUri,
      ]) {
        _expectData(parse(uri), row.expected);
      }
    }

    final view = FractalViewState(
      pan: Vector2(-0.743643887037151, 0.13182590420533),
      zoom: 1e9,
      rotation: Vector3.zero(),
    );
    const camera = 'zoom=1000000000&x=-0.743643887037151&y=0.13182590420533';
    const compactCamera =
        'z=1000000000&x=-0.743643887037151&y=0.13182590420533';
    const params = <String, Object>{
      'custom': 0.125,
      'enabled': true,
      'label': 'blue'
    };
    // Literal JSON {"custom":0.125,"enabled":true,"label":"blue"}, base64url.
    const payload =
        'eyJjdXN0b20iOjAuMTI1LCJlbmFibGVkIjp0cnVlLCJsYWJlbCI6ImJsdWUifQ';
    for (final build in [
      codec.DeepLinkCodec.buildUri,
      legacy.DeepLinkService.buildUri,
    ]) {
      expect(
        build(moduleId: 'julia', params: params, view: view).toString(),
        'fractalforge://view?type=julia&$camera&p=$payload',
      );
    }
    for (final build in [
      codec.DeepLinkCodec.buildWebUri,
      legacy.DeepLinkService.buildWebUri,
    ]) {
      expect(
        build(moduleId: 'julia', params: params, view: view).toString(),
        'https://fractal.trebuchetdynamics.com/?t=julia&$compactCamera&p=$payload',
      );
      expect(
        build(moduleId: 'julia', params: params, view: view, readable: true)
            .toString(),
        'https://fractal.trebuchetdynamics.com/?type=julia&$camera'
        '&param.custom=0.125&param.enabled=true&param.label=%22blue%22',
      );
      final restored = codec.DeepLinkCodec.parseUri(
        build(
          moduleId: 'julia',
          params: params,
          view: FractalViewState.initial(),
          includeDefaults: true,
        ),
      )!;
      expect(restored.toParams(), params);
      expect(restored.toViewState().zoom, 1);
      expect(restored.transparentBackground, isFalse);
      expect(restored.kaleidoscopeMirror, isTrue);
    }
  });
}

void _expectData(codec.DeepLinkData? actual, codec.DeepLinkData? expected) {
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isA<legacy.DeepLinkData>());
  expect(actual.toString(), expected.toString());
  expect(actual!.toParams(), expected.toParams());
  expect(actual.toViewState().zoom, expected.toViewState().zoom);
  expect(actual.toViewState().pan, expected.toViewState().pan);
  expect(actual.toViewState().rotation, expected.toViewState().rotation);
}
