import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release version names follow major.minor.buildNumber', () {
    final buildScript =
        File('scripts/build-play-console.sh').readAsStringSync();
    final releaseScript = File('scripts/release.sh').readAsStringSync();
    final preReleaseGate =
        File('scripts/pre-release-gate.sh').readAsStringSync();
    final androidBuild =
        File('android/app/build.gradle.kts').readAsStringSync();

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
    expect(releaseScript, contains('--prepare=<version>'));
    expect(
      releaseScript,
      contains(
          '--prepare permits only android-build, linux, windows, and evidence'),
    );
    expect(releaseScript, contains('preflight_prepare'));
    final playUploadScript =
        File('scripts/build-upload-playstore.sh').readAsStringSync();
    expect(playUploadScript, contains('data.get("image", data).get("id", "")'));
    expect(playUploadScript, contains('images.get("images"'));
    expect(playUploadScript,
        contains('listing["title"] = os.environ["LISTING_TITLE"]'));
    expect(playUploadScript,
        contains('Committed Play listing title does not match'));
    expect(releaseScript, contains('play-store-localized-listings.json'));
    expect(releaseScript, contains(r'PLAY_LISTING_TITLE="$listing_title"'));
    expect(releaseScript, contains('PLAY_LISTINGS_JSON='));
    expect(playUploadScript, contains('PLAY_LISTINGS_JSON'));
    expect(
      releaseScript,
      contains(
        r'if [[ -n "$PUBLISH_VERSION" && "$DRY_RUN_FORCED" -eq 0 ]]',
      ),
    );
    expect(releaseScript, contains('resolve_upcoming_android_version'));
    expect(releaseScript, contains('git tag --list'));
    expect(
      releaseScript,
      contains(
        'LAST_BUILD_NUMBER.txt (which records the last local script run',
      ),
    );
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
    expect(androidBuild, contains('release-abi'));
    expect(androidBuild, contains('abiFilters.add(releaseAbi)'));
    expect(androidBuild, contains(r'.map { "**/$it/**" }'));
    expect(releaseScript, contains(r'echo "${version%%+*}"'));
    expect(releaseScript, isNot(contains(r'echo "${name}+${build}"')));
    expect(preReleaseGate, isNot(contains(r'match($0,')));
    expect(preReleaseGate, contains(r'sub(/^.*Janky frames:.*\(/'));
    expect(preReleaseGate, contains('clear stale monkey input'));
    expect(
        preReleaseGate, contains('pkill -INT -f com.android.commands.monkey'));
    expect(preReleaseGate, contains('trap cleanup_device EXIT'));
  });
}
