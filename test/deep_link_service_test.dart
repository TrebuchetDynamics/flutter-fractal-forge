import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('DeepLinkService', () {
    group('parseUri', () {
      test('parses basic fractalforge:// URL', () {
        final uri = Uri.parse('fractalforge://view?type=mandelbrot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
      });

      test('parses URL with zoom and pan parameters', () {
        final uri = Uri.parse(
            'fractalforge://view?type=mandelbrot&zoom=10&x=-0.5&y=0.1');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, 10.0);
        expect(data.x, -0.5);
        expect(data.y, 0.1);
      });

      test('parses URL with 3D rotation parameters', () {
        final uri = Uri.parse(
            'fractalforge://view?type=mandelbulb&rotX=0.5&rotY=0.3&rotZ=0.1');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbulb');
        expect(data.rotX, 0.5);
        expect(data.rotY, 0.3);
        expect(data.rotZ, 0.1);
      });

      test('parses URL with fractal parameters', () {
        final uri = Uri.parse(
            'fractalforge://view?type=julia&iterations=200&colorScheme=2&juliaX=-0.7&juliaY=0.27');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'julia');
        expect(data.iterations, 200);
        expect(data.colorScheme, 2);
        expect(data.juliaX, -0.7);
        expect(data.juliaY, 0.27);
      });

      test('returns null for non-fractalforge scheme', () {
        final uri = Uri.parse('https://example.com/view?type=mandelbrot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('returns null for missing type parameter', () {
        final uri = Uri.parse('fractalforge://view?zoom=10');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('parses https://fractalforge.app universal link', () {
        final uri = Uri.parse(
            'https://fractalforge.app/view?type=mandelbrot&zoom=5');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, 5.0);
      });
    });

    group('buildUri', () {
      test('builds basic URL with type only', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {},
          view: FractalViewState.initial(),
        );

        expect(uri.scheme, 'fractalforge');
        expect(uri.host, 'view');
        expect(uri.queryParameters['type'], 'mandelbrot');
      });

      test('includes zoom when not default', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {},
          view: FractalViewState(
            pan: Vector2.zero(),
            zoom: 5.0,
            rotation: Vector3.zero(),
          ),
        );

        expect(uri.queryParameters['zoom'], '5');
      });

      test('includes pan coordinates when not zero', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {},
          view: FractalViewState(
            pan: Vector2(-0.5, 0.25),
            zoom: 1.0,
            rotation: Vector3.zero(),
          ),
        );

        expect(uri.queryParameters['x'], '-0.5');
        expect(uri.queryParameters['y'], '0.25');
      });

      test('includes rotation for 3D fractals', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbulb',
          params: {},
          view: FractalViewState(
            pan: Vector2.zero(),
            zoom: 1.0,
            rotation: Vector3(0.5, 0.3, 0.1),
          ),
        );

        expect(uri.queryParameters['rotX'], '0.5');
        expect(uri.queryParameters['rotY'], '0.3');
        expect(uri.queryParameters['rotZ'], '0.1');
      });

      test('includes fractal parameters', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {
            'iterations': 200,
            'colorScheme': 2,
            'bailout': 4.5,
          },
          view: FractalViewState.initial(),
        );

        expect(uri.queryParameters['iterations'], '200');
        expect(uri.queryParameters['colorScheme'], '2');
        expect(uri.queryParameters['bailout'], '4.5');
      });

      test('omits default values for cleaner URLs', () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {},
          view: FractalViewState.initial(),
        );

        // Default values should not be included
        expect(uri.queryParameters.containsKey('zoom'), isFalse);
        expect(uri.queryParameters.containsKey('x'), isFalse);
        expect(uri.queryParameters.containsKey('y'), isFalse);
        expect(uri.queryParameters.containsKey('rotX'), isFalse);
      });
    });

    group('DeepLinkData', () {
      test('toViewState creates correct FractalViewState', () {
        final data = DeepLinkData(
          type: 'mandelbrot',
          zoom: 5.0,
          x: -0.5,
          y: 0.25,
          rotX: 0.1,
          rotY: 0.2,
          rotZ: 0.3,
        );

        final viewState = data.toViewState();

        expect(viewState.zoom, closeTo(5.0, 0.001));
        expect(viewState.pan.x, closeTo(-0.5, 0.001));
        expect(viewState.pan.y, closeTo(0.25, 0.001));
        expect(viewState.rotation.x, closeTo(0.1, 0.001));
        expect(viewState.rotation.y, closeTo(0.2, 0.001));
        expect(viewState.rotation.z, closeTo(0.3, 0.001));
      });

      test('toViewState handles null values with defaults', () {
        final data = DeepLinkData(type: 'mandelbrot');

        final viewState = data.toViewState();

        expect(viewState.zoom, 1.0);
        expect(viewState.pan.x, 0.0);
        expect(viewState.pan.y, 0.0);
        expect(viewState.rotation.x, 0.0);
        expect(viewState.rotation.y, 0.0);
        expect(viewState.rotation.z, 0.0);
      });

      test('toParams extracts fractal parameters', () {
        final data = DeepLinkData(
          type: 'mandelbrot',
          iterations: 200,
          colorScheme: 2,
          bailout: 4.5,
          power: 8.0,
        );

        final params = data.toParams();

        expect(params['iterations'], 200);
        expect(params['colorScheme'], 2);
        expect(params['bailout'], 4.5);
        expect(params['power'], 8.0);
      });

      test('toParams omits null values', () {
        final data = DeepLinkData(
          type: 'mandelbrot',
          iterations: 200,
        );

        final params = data.toParams();

        expect(params.containsKey('iterations'), isTrue);
        expect(params.containsKey('colorScheme'), isFalse);
        expect(params.containsKey('bailout'), isFalse);
      });
    });

    group('buildWebUri', () {
      test('creates https URL with fractalforge.app host', () {
        final uri = DeepLinkService.buildWebUri(
          moduleId: 'mandelbrot',
          params: {'iterations': 100},
          view: FractalViewState.initial(),
        );

        expect(uri.scheme, 'https');
        expect(uri.host, 'fractalforge.app');
        expect(uri.path, '/view');
        expect(uri.queryParameters['type'], 'mandelbrot');
        expect(uri.queryParameters['iterations'], '100');
      });
    });

    group('round-trip', () {
      test('URL can be built and parsed back to same data', () {
        final originalView = FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        );
        final originalParams = {
          'iterations': 350,
          'colorScheme': 1,
          'bailout': 4.0,
        };

        // Build URL
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: originalParams,
          view: originalView,
        );

        // Parse it back
        final parsed = DeepLinkService.parseUri(uri);

        expect(parsed, isNotNull);
        expect(parsed!.type, 'mandelbrot');
        expect(parsed.zoom, 25.0);
        expect(parsed.x, closeTo(-0.747, 0.001));
        expect(parsed.y, closeTo(0.1, 0.001));
        expect(parsed.iterations, 350);
        expect(parsed.colorScheme, 1);
      });
    });
  });
}
