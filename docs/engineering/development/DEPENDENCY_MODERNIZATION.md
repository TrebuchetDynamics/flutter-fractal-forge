# Dependency modernization plan

Generated while implementing the technical-audit quick wins. Evidence command:

```bash
/home/xel/flutter/bin/flutter pub outdated --json
```

## Current priority

| Package | Current | Resolvable/latest | Risk | Recommended slice |
| --- | ---: | ---: | --- | --- |
| `share_plus` | 7.2.2 | 13.2.0 | High: export/share UX depends on this plugin and v13 has a newer share API surface. | Isolate share calls behind a project wrapper, then upgrade with export and log-sharing tests. |
| `shared_preferences` | 2.2.3 | 2.5.5 | Medium: many stores/services use test mocks; plugin update should be broad but mechanical. | Upgrade after fast-lane export/render tests are green; run all preference-backed service/widget tests. |
| `path_provider` | 2.1.4 | 2.1.6 | Low: patch update, used by export/log/video/report services. | Patch upgrade with export/log/video/report tests. |
| `image` | 4.7.2 | 4.9.1 | Medium: export encoding and wallpaper transforms rely on image codecs. | Upgrade separately with `test/export_service_test.dart`, batch/video export tests, and sample encoded output checks. |
| `flutter_lints` | 4.0.0 | 6.0.0 | Medium: analyzer rules may create repo-wide cleanup. | Defer until product/runtime plugin upgrades are complete. |
| `vector_math` | 2.2.0 | 2.4.0 latest, 2.2.0 resolvable | Low: math-heavy app, but current SDK constraints do not resolve newer release. | Defer until Flutter/Dart SDK constraints allow it; run renderer/controller tests after upgrade. |

## Share plugin wrapper target

Direct share plugin usage is isolated to `lib/core/services/share_service.dart`.

Existing app-owned call sites:

- `lib/core/services/export_service.dart` shares saved exports through `AppShareService.shareFile`.
- `lib/features/debug/log_viewer_screen.dart` shares log files through `AppShareService.shareFile`.
- `lib/features/viewer/export/viewer_export_overlay.dart` shares viewer metadata/text through `AppShareService.shareText`.

When upgrading `share_plus`, keep the API change local to the wrapper and preserve the already-tested export feedback contract: sharing failures must not rewrite a completed save as an export failure.

## Validation gates per upgrade

Minimum gate after any dependency slice:

```bash
/home/xel/flutter/bin/flutter analyze
/home/xel/flutter/bin/flutter test \
  test/export_service_test.dart \
  test/export_options_sheet_widget_test.dart \
  test/share_service_boundary_test.dart \
  test/features/viewer/viewer_export_feedback_test.dart \
  test/video_export_service_test.dart \
  test/batch_export_service_test.dart
```

For `shared_preferences`, additionally run the preference-backed service/widget tests listed by:

```bash
rg -l "shared_preferences" test
```

For `image`, inspect at least one PNG and one JPG encoded result via `test/export_service_test.dart`; add a regression fixture before changing codec behavior.
