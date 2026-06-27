import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:path_provider/path_provider.dart';

class FractalReportService {
  static const defaultIssuesSubdirectory = 'fractal-reports';
  static const issuesDirectoryEnv = 'FRACTAL_FORGE_ISSUES_DIR';

  static const defaultTags = [
    'Low performance',
    'Low deep zoom',
    'Low Detail',
    'No image',
    'Bad initial coordinates',
    'Bad initial params',
    'Randomize bad results',
    'Removal Candidate',
    'Bad Thumbnail',
    'Is does not look the correct fractal',
    'NO shader',
    'Other',
  ];

  const FractalReportService({this.issuesDirectory, this.environment});

  final String? issuesDirectory;
  final Map<String, String>? environment;

  Future<File> save({
    required String moduleId,
    required String moduleName,
    required List<String> tags,
    required Map<String, Object> params,
    required FractalViewState view,
    required String shareUrl,
    String notes = '',
    Map<String, Object?> visualState = const {},
    DateTime? now,
  }) async {
    final createdAt = (now ?? DateTime.now()).toUtc();
    final dir = await _resolveIssuesDirectory();
    await dir.create(recursive: true);

    final file =
        File('${dir.path}/${_stamp(createdAt)}_${_safe(moduleId)}.json');
    final payload = {
      'createdAt': createdAt.toIso8601String(),
      'moduleId': moduleId,
      'moduleName': moduleName,
      'tags': tags,
      'notes': notes.trim(),
      'shareUrl': shareUrl,
      'params': params,
      'view': {
        'zoom': view.zoom,
        'x': view.pan.x,
        'y': view.pan.y,
        'rotX': view.rotation.x,
        'rotY': view.rotation.y,
        'rotZ': view.rotation.z,
      },
      'visualState': visualState,
    };
    await file.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(payload)}\n');
    return file;
  }

  Future<Directory> _resolveIssuesDirectory() async {
    final explicitDirectory = issuesDirectory;
    if (explicitDirectory != null) return Directory(explicitDirectory);

    final envDirectory =
        (environment ?? Platform.environment)[issuesDirectoryEnv]?.trim();
    if (envDirectory != null && envDirectory.isNotEmpty) {
      return Directory(envDirectory);
    }

    try {
      final supportDir = await getApplicationSupportDirectory();
      return Directory('${supportDir.path}/$defaultIssuesSubdirectory');
    } catch (_) {
      return Directory(
          '${Directory.systemTemp.path}/$defaultIssuesSubdirectory');
    }
  }

  static String _stamp(DateTime value) => value
      .toUtc()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.]'), '-')
      .replaceAll('Z', 'Z');

  static String _safe(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
}
