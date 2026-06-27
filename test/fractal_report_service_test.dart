import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('exposes required study tags and portable default directory name', () {
    expect(FractalReportService.defaultIssuesSubdirectory, 'fractal-reports');
    expect(
      FractalReportService.defaultTags,
      containsAll(const [
        'Low performance',
        'Low deep zoom',
        'No image',
        'Bad initial coordinates',
        'Bad initial params',
        'Removal Candidate',
        'Bad Thumbnail',
        'Is does not look the correct fractal',
        'NO shader',
      ]),
    );
  });

  test('uses issue directory from environment when provided', () async {
    final dir = Directory.systemTemp.createTempSync('fractal_issues_env_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final file = await FractalReportService(
      environment: {FractalReportService.issuesDirectoryEnv: dir.path},
    ).save(
      moduleId: 'mandelbrot',
      moduleName: 'Mandelbrot',
      tags: const ['No image'],
      params: const {},
      view: FractalViewState(
        pan: Vector2.zero(),
        zoom: 1,
        rotation: Vector3.zero(),
      ),
      shareUrl: 'https://example.com',
    );

    expect(file.path, startsWith(dir.path));
  });

  test('saves tagged fractal report JSON', () async {
    final dir = Directory.systemTemp.createTempSync('fractal_issues_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final file = await FractalReportService(issuesDirectory: dir.path).save(
      moduleId: 'mandelbrot',
      moduleName: 'Mandelbrot',
      tags: const ['No image', 'Low performance'],
      params: const {'iterations': 200, 'colorScheme': 3},
      view: FractalViewState(
        pan: Vector2(-0.75, 0.1),
        zoom: 42,
        rotation: Vector3.zero(),
      ),
      shareUrl: 'https://fractal.trebuchetdynamics.com/view?type=mandelbrot',
      notes: 'black frame',
      visualState: const {'glowEnabled': true},
      now: DateTime.utc(2026, 6, 26, 12, 0),
    );

    expect(file.path, contains('2026-06-26T12-00-00-000Z_mandelbrot.json'));
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['moduleId'], 'mandelbrot');
    expect(json['tags'], contains('No image'));
    expect(json['shareUrl'], contains('fractal.trebuchetdynamics.com'));
    expect((json['view']! as Map)['zoom'], 42);
  });
}
