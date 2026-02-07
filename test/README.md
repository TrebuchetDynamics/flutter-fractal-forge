# Tests

This project uses Flutter's `flutter_test` runner.

## Run all tests

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
