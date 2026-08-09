import 'package:package_info_plus/package_info_plus.dart';

/// The app version shown in the UI.
///
/// Must match `version:` in pubspec.yaml and serves as a deterministic fallback
/// when installed package metadata is unavailable.
///
/// `test/screens/app_version_test.dart` reads pubspec.yaml and fails if the two
/// disagree, so a version bump that forgets this constant does not ship.
const String kAppVersion = '1.1.0+38';

/// Returns the metadata embedded in the installed package.
///
/// Release builds display what Android/iOS/desktop actually installed rather
/// than trusting a second handwritten version string.
Future<String> installedAppVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final version = info.version.trim();
    final build = info.buildNumber.trim();
    if (version.isEmpty) return kAppVersion;
    return build.isEmpty ? version : '$version+$build';
  } catch (_) {
    return kAppVersion;
  }
}
