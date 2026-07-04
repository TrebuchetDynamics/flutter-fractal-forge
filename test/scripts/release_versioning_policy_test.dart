import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release version names follow major.minor.buildNumber', () {
    final buildScript =
        File('scripts/build-play-console.sh').readAsStringSync();
    final releaseScript = File('scripts/release.sh').readAsStringSync();

    expect(buildScript, contains('version_name_from_build_number'));
    expect(buildScript, contains('1.1.0+38 and build number 58 => 1.1.58'));
    expect(buildScript, contains('--print-version'));
    expect(buildScript, contains(r'versionName=$USED_VERSION_NAME'));
    expect(buildScript.indexOf('resolve_versions'),
        lessThan(buildScript.indexOf('command -v flutter')));
    expect(buildScript, contains('major.minor + build'));
    expect(releaseScript, contains('CONFIRMED=1'));
    expect(releaseScript, contains('--dry-run'));
    expect(releaseScript, contains(r'echo "$name"'));
    expect(releaseScript, isNot(contains(r'echo "${name}+${build}"')));
  });
}
