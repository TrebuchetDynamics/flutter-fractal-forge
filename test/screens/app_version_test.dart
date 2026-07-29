import 'dart:io';

import 'package:flutter_fractals/core/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kAppVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final line = pubspec.firstWhere(
      (l) => l.startsWith('version:'),
      orElse: () => fail('pubspec.yaml has no version: line'),
    );
    final declared = line.split(':').last.trim();

    // The About dialog used to hold its own literal and fell 14 builds behind
    // pubspec. If this fails after a version bump, update lib/core/app_version.
    expect(
      kAppVersion,
      declared,
      reason: 'kAppVersion is stale — the About dialog will show the wrong '
          'version. Update lib/core/app_version.dart to $declared.',
    );
  });
}
