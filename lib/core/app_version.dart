/// The app version shown in the UI.
///
/// Must match `version:` in pubspec.yaml. There is no package_info dependency,
/// so this is the single place the version is written by hand — the settings
/// About dialog previously carried its own copy and drifted 14 builds behind.
///
/// `test/screens/app_version_test.dart` reads pubspec.yaml and fails if the two
/// disagree, so a version bump that forgets this constant does not ship.
const String kAppVersion = '1.1.0+38';
