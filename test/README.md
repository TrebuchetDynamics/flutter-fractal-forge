# Tests

This project uses Flutter's `flutter_test` runner.

## Fast safety lane

Use this lane for ordinary PR feedback before running the larger generated catalog and integration suites:

```bash
flutter analyze
flutter test \
  test/precision_ladder_policy_test.dart \
  test/backend_policy_comprehensive_test.dart \
  test/fractal_controller_behavior_test.dart \
  test/export_service_test.dart \
  test/export_options_sheet_widget_test.dart \
  test/share_service_boundary_test.dart \
  test/viewer_export_session_test.dart \
  test/features/viewer/viewer_export_feedback_test.dart \
  test/catalog_id_integrity_test.dart \
  test/modules/generated_module_contract_test.dart \
  test/modules/escape_time_uniform_contract_test.dart \
  test/modules/escape_time_shader_manifest_test.dart \
  test/shader_web_compat_test.dart
```

## Full local test suite

Run the full suite before release candidates or broad renderer/catalog changes. Generated module smoke coverage is consolidated in one contract test to keep startup overhead down.

```bash
flutter test
```

## Run a single test file

```bash
flutter test test/fractal_controller_behavior_test.dart
```

## Helpful notes

- Widget tests that touch persistence typically use:

  ```dart
  SharedPreferences.setMockInitialValues({});
  ```

  so they don't read/write real device storage.
- Some tests call:

  ```dart
  TestWidgetsFlutterBinding.ensureInitialized();
  ```

  to ensure Flutter bindings are available when using plugins like
  `shared_preferences`.
