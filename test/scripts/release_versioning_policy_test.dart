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
    expect(releaseScript, contains('CONFIRMED=0'));
    expect(releaseScript, contains('--dry-run'));
    expect(releaseScript, contains(r'PLAY_TRACK="${PLAY_TRACK:-internal}"'));
    expect(
      releaseScript,
      contains(r'PLAY_RELEASE_STATUS="${PLAY_RELEASE_STATUS:-draft}"'),
    );
    expect(releaseScript, contains('--publish=<version>'));
    expect(releaseScript, contains('DRY_RUN_FORCED=0'));
    expect(
      releaseScript,
      contains(
        r'if [[ -n "$PUBLISH_VERSION" && "$DRY_RUN_FORCED" -eq 0 ]]',
      ),
    );
    expect(releaseScript, contains('resolve_upcoming_android_version'));
    expect(
      releaseScript.indexOf('resolve_upcoming_android_version'),
      lessThan(releaseScript.indexOf('preflight_publish')),
    );
    expect(
      releaseScript,
      contains(
        r'[[ "$PUBLISH_VERSION" == "$RESOLVED_RELEASE_VERSION" ]]',
      ),
    );
    expect(
      releaseScript,
      contains(r'--build-name="$RESOLVED_ANDROID_VERSION"'),
    );
    expect(
      releaseScript,
      contains(r'--build-number="$RESOLVED_ANDROID_BUILD_NUMBER"'),
    );
    expect(releaseScript, contains('gh release create'));
    expect(releaseScript, contains('--draft'));
    expect(releaseScript, contains('git status --porcelain'));
    expect(releaseScript, contains('git fetch --quiet origin'));
    expect(releaseScript, contains(r'"$FLUTTER_BIN" analyze'));
    expect(releaseScript, contains(r'"$FLUTTER_BIN" test'));
    expect(releaseScript, contains('preflight_publish'));
    expect(releaseScript, contains(r'echo "$name"'));
    expect(releaseScript, isNot(contains(r'echo "${name}+${build}"')));
  });
}
