import 'number_wall_parity_fixtures.dart';

void main() {
  final report = runNumberWallParityFixtures();
  if (report.fixtureCount != 971) {
    throw StateError(
        'Expected 971 parity fixtures, got ${report.fixtureCount}');
  }
  if (report.fingerprint != numberWallParityExpectedFingerprint) {
    throw StateError(
      'Unexpected parity fingerprint: ${report.fingerprint}',
    );
  }
  print(
    'NUMBER_WALL_PARITY_OK|${report.fixtureCount}|${report.fingerprint}',
  );
}
