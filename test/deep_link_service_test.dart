import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('DeepLinkService', () {
    group('parseIncomingLink', () {
      test('parses string payloads from platform channels', () {
        final data = DeepLinkService.parseIncomingLink(
          'fractalforge://view?type=mandelbrot&zoom=5',
        );

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, 5.0);
      });

      test('ignores malformed or non-string platform payloads', () {
        expect(DeepLinkService.parseIncomingLink(null), isNull);
        expect(DeepLinkService.parseIncomingLink(42), isNull);
        expect(DeepLinkService.parseIncomingLink(''), isNull);
        expect(
          DeepLinkService.parseIncomingLink('fractalforge://view?type=%'),
          isNull,
        );
      });
    });

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
        final uri =
            Uri.parse('https://fractalforge.app/view?type=mandelbrot&zoom=5');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, 5.0);
      });

      test('characterizes accepted deep-link route variants', () {
        final acceptedLinks = [
          'fractalforge://view?type=mandelbrot',
          'fractalforge:/view?type=mandelbrot',
          'fractalforge:view?type=mandelbrot',
          'https://fractalforge.app/view?type=mandelbrot',
          'https://www.fractalforge.app/view?type=mandelbrot',
        ];

        for (final link in acceptedLinks) {
          expect(
            DeepLinkService.parseUri(Uri.parse(link))?.type,
            'mandelbrot',
            reason: link,
          );
        }
      });

      test('rejects https universal links outside the view route', () {
        final uri = Uri.parse(
            'https://fractalforge.app/settings?type=mandelbrot&zoom=5');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('rejects duplicate recognized parameters instead of guessing', () {
        final uri = Uri.parse(
          'fractalforge://view?type=mandelbrot&type=julia&zoom=5',
        );
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('rejects duplicate optional parameters instead of truncating', () {
        final uri = Uri.parse(
          'fractalforge://view?type=mandelbrot&zoom=5&zoom=abc',
        );
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('ignores duplicate unrecognized parameters', () {
        final uri = Uri.parse(
          'fractalforge://view?type=mandelbrot&utm=a&utm=b&zoom=5',
        );
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, 5.0);
      });

      test('rejects duplicates for every generated deep-link parameter', () {
        final generated = DeepLinkService.buildUri(
          moduleId: 'julia',
          params: const {
            'iterations': 200,
            'bailout': 4.5,
            'colorScheme': 2,
            'power': 8.0,
            'juliaX': -0.7,
            'juliaY': 0.27,
          },
          view: FractalViewState(
            pan: Vector2(-0.5, 0.25),
            zoom: 5.0,
            rotation: Vector3(0.1, 0.2, 0.3),
          ),
        );

        for (final paramName in generated.queryParameters.keys) {
          final duplicated = generated.replace(
            query: '${generated.query}&$paramName=duplicate',
          );

          expect(
            DeepLinkService.parseUri(duplicated),
            isNull,
            reason: '$paramName must be part of duplicate detection',
          );
        }
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

      test('rejects unsafe module IDs before generating unreplayable links',
          () {
        expect(
          () => DeepLinkService.buildUri(
            moduleId: 'mandelbrot<script>',
            params: const {},
            view: FractalViewState.initial(),
          ),
          throwsArgumentError,
        );
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

      test('omits unsupported parameter values instead of minting fallbacks',
          () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {
            'iterations': true,
            'colorScheme': Object(),
            'bailout': 'not-a-number',
            'power': double.nan,
            'juliaX': double.infinity,
            'juliaY': false,
          },
          view: FractalViewState.initial(),
        );

        expect(uri.queryParameters.containsKey('iterations'), isFalse);
        expect(uri.queryParameters.containsKey('colorScheme'), isFalse);
        expect(uri.queryParameters.containsKey('bailout'), isFalse);
        expect(uri.queryParameters.containsKey('power'), isFalse);
        expect(uri.queryParameters.containsKey('juliaX'), isFalse);
        expect(uri.queryParameters.containsKey('juliaY'), isFalse);
      });

      test('omits out-of-range parameters instead of creating clamped links',
          () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: {
            'iterations': 10001,
            'colorScheme': -1,
            'bailout': 0.5,
            'power': 21,
            'juliaX': 10000000001,
            'juliaY': -10000000001,
          },
          view: FractalViewState.initial(),
        );

        expect(uri.queryParameters.containsKey('iterations'), isFalse);
        expect(uri.queryParameters.containsKey('colorScheme'), isFalse);
        expect(uri.queryParameters.containsKey('bailout'), isFalse);
        expect(uri.queryParameters.containsKey('power'), isFalse);
        expect(uri.queryParameters.containsKey('juliaX'), isFalse);
        expect(uri.queryParameters.containsKey('juliaY'), isFalse);
      });

      test(
          'omits invalid view values instead of throwing or minting clamped links',
          () {
        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: const {},
          view: FractalViewState(
            pan: Vector2(double.nan, 1e20),
            zoom: double.infinity,
            rotation: Vector3(double.negativeInfinity, 0.5, -1e20),
          ),
        );

        expect(uri.queryParameters.containsKey('zoom'), isFalse);
        expect(uri.queryParameters.containsKey('x'), isFalse);
        expect(uri.queryParameters.containsKey('y'), isFalse);
        expect(uri.queryParameters.containsKey('rotX'), isFalse);
        expect(uri.queryParameters['rotY'], '0.5');
        expect(uri.queryParameters.containsKey('rotZ'), isFalse);
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

      test('deep zoom round-trip preserves significant pan digits', () {
        final originalView = FractalViewState(
          pan: Vector2(-0.743643887037151, 0.13182590420533),
          zoom: 1250000000000.0,
          rotation: Vector3.zero(),
        );

        final uri = DeepLinkService.buildUri(
          moduleId: 'mandelbrot',
          params: const {},
          view: originalView,
        );

        final parsed = DeepLinkService.parseUri(uri);

        expect(parsed, isNotNull);
        expect(parsed!.x, closeTo(originalView.pan.x, 1e-15));
        expect(parsed.y, closeTo(originalView.pan.y, 1e-15));
        expect(parsed.zoom, originalView.zoom);
      });

      test('complete round-trip with all parameters preserves values', () {
        final originalView = FractalViewState(
          pan: Vector2(0.3, -0.15),
          zoom: 42.0,
          rotation: Vector3(0.5, 0.3, 0.1),
        );
        final originalParams = {
          'iterations': 500,
          'colorScheme': 3,
          'bailout': 8.0,
          'power': 8.0,
          'juliaX': -0.7,
          'juliaY': 0.27,
        };

        final uri = DeepLinkService.buildUri(
          moduleId: 'julia',
          params: originalParams,
          view: originalView,
        );

        final parsed = DeepLinkService.parseUri(uri);

        expect(parsed, isNotNull);
        expect(parsed!.type, 'julia');
        expect(parsed.zoom, closeTo(42.0, 0.001));
        expect(parsed.x, closeTo(0.3, 0.001));
        expect(parsed.y, closeTo(-0.15, 0.001));
        expect(parsed.rotX, closeTo(0.5, 0.001));
        expect(parsed.rotY, closeTo(0.3, 0.001));
        expect(parsed.rotZ, closeTo(0.1, 0.001));
        expect(parsed.iterations, 500);
        expect(parsed.colorScheme, 3);
        expect(parsed.bailout, closeTo(8.0, 0.001));
        expect(parsed.power, closeTo(8.0, 0.001));
        expect(parsed.juliaX, closeTo(-0.7, 0.001));
        expect(parsed.juliaY, closeTo(0.27, 0.001));
      });

      test('Julia constant round-trip preserves significant digits', () {
        final originalParams = {
          'juliaX': -0.743643887037151,
          'juliaY': 0.13182590420533,
        };

        final uri = DeepLinkService.buildUri(
          moduleId: 'julia',
          params: originalParams,
          view: FractalViewState.initial(),
        );

        final parsed = DeepLinkService.parseUri(uri);

        expect(parsed, isNotNull);
        expect(parsed!.juliaX, closeTo(originalParams['juliaX']!, 1e-15));
        expect(parsed.juliaY, closeTo(originalParams['juliaY']!, 1e-15));
      });
    });

    group('parameter validation — bounds clamping', () {
      test('valid deep link with all parameters is parsed correctly', () {
        final uri = Uri.parse(
          'fractalforge://view?type=mandelbulb'
          '&zoom=50&x=-1.5&y=2.3'
          '&rotX=0.5&rotY=0.3&rotZ=0.1'
          '&iterations=500&bailout=6.0&colorScheme=3'
          '&power=8&juliaX=-0.7&juliaY=0.27',
        );
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbulb');
        expect(data.zoom, closeTo(50.0, 0.001));
        expect(data.x, closeTo(-1.5, 0.001));
        expect(data.y, closeTo(2.3, 0.001));
        expect(data.rotX, closeTo(0.5, 0.001));
        expect(data.rotY, closeTo(0.3, 0.001));
        expect(data.rotZ, closeTo(0.1, 0.001));
        expect(data.iterations, 500);
        expect(data.bailout, closeTo(6.0, 0.001));
        expect(data.colorScheme, 3);
        expect(data.power, closeTo(8.0, 0.001));
        expect(data.juliaX, closeTo(-0.7, 0.001));
        expect(data.juliaY, closeTo(0.27, 0.001));
      });

      test('missing optional parameters return null (not crash)', () {
        final uri = Uri.parse('fractalforge://view?type=mandelbrot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.type, 'mandelbrot');
        expect(data.zoom, isNull);
        expect(data.x, isNull);
        expect(data.y, isNull);
        expect(data.rotX, isNull);
        expect(data.rotY, isNull);
        expect(data.rotZ, isNull);
        expect(data.iterations, isNull);
        expect(data.bailout, isNull);
        expect(data.colorScheme, isNull);
        expect(data.power, isNull);
        expect(data.juliaX, isNull);
        expect(data.juliaY, isNull);
      });

      test('malformed zoom value "abc" returns null for zoom', () {
        final uri = Uri.parse('fractalforge://view?type=mandelbrot&zoom=abc');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, isNull);
      });

      test('malformed iterations value "xyz" returns null for iterations', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&iterations=xyz');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.iterations, isNull);
      });

      test('malformed bailout value "notanumber" returns null for bailout', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&bailout=notanumber');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.bailout, isNull);
      });

      test('zoom above 1e15 is clamped to 1e15', () {
        final uri = Uri.parse(
            'fractalforge://view?type=mandelbrot&zoom=9999999999999999');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, closeTo(1e15, 1e10));
      });

      test('zoom below 0.001 is clamped to 0.001', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&zoom=0.00000001');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, closeTo(0.001, 1e-6));
      });

      test('iterations above 10000 is clamped to 10000', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&iterations=99999');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.iterations, 10000);
      });

      test('negative iterations is clamped to 1', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&iterations=-50');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.iterations, 1);
      });

      test('bailout below minimum (1.0) is clamped to 1.0', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&bailout=0.001');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.bailout, closeTo(1.0, 1e-6));
      });

      test('bailout above 1e10 is clamped to 1e10', () {
        final uri = Uri.parse(
            'fractalforge://view?type=mandelbrot&bailout=99999999999');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.bailout, closeTo(1e10, 1e6));
      });

      test('pan x beyond 1e10 is clamped to 1e10', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&x=99999999999');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.x, closeTo(1e10, 1e6));
      });

      test('pan x below -1e10 is clamped to -1e10', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&x=-99999999999');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.x, closeTo(-1e10, 1e6));
      });

      test('pan y beyond 1e10 is clamped to 1e10', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&y=50000000000');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.y, closeTo(1e10, 1e6));
      });

      test('pan y below -1e10 is clamped to -1e10', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&y=-50000000000');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.y, closeTo(-1e10, 1e6));
      });

      test('module ID with uppercase letters is rejected', () {
        final uri = Uri.parse('fractalforge://view?type=Mandelbrot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('module ID with special characters is rejected', () {
        final uri = Uri.parse('fractalforge://view?type=../etc/passwd');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('module ID with spaces is rejected', () {
        final uri = Uri.parse('fractalforge://view?type=mandel+brot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('empty type parameter is rejected', () {
        final uri = Uri.parse('fractalforge://view?type=');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('fractalforge:// URL with empty path returns null', () {
        final uri = Uri.parse('fractalforge://other?type=mandelbrot');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNull);
      });

      test('zoom of exactly 0.001 is accepted (at min boundary)', () {
        final uri = Uri.parse('fractalforge://view?type=mandelbrot&zoom=0.001');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, closeTo(0.001, 1e-9));
      });

      test('zoom of exactly 1e15 is accepted (at max boundary)', () {
        final uri = Uri.parse(
            'fractalforge://view?type=mandelbrot&zoom=1000000000000000');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, closeTo(1e15, 1e10));
      });

      test('iterations of exactly 1 is accepted (at min boundary)', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&iterations=1');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.iterations, 1);
      });

      test('iterations of exactly 10000 is accepted (at max boundary)', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&iterations=10000');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.iterations, 10000);
      });

      test('NaN string for zoom returns null', () {
        final uri = Uri.parse('fractalforge://view?type=mandelbrot&zoom=NaN');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, isNull);
      });

      test('Infinity string for zoom returns null', () {
        final uri =
            Uri.parse('fractalforge://view?type=mandelbrot&zoom=Infinity');
        final data = DeepLinkService.parseUri(uri);

        expect(data, isNotNull);
        expect(data!.zoom, isNull);
      });
    });
  });
}
