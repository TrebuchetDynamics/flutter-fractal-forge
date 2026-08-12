#!/usr/bin/env bats

@test "pre-release gate dry run includes every mandatory host and device gate" {
  run "$BATS_TEST_DIRNAME/../../scripts/pre-release-gate.sh" \
    --dry-run --device=192.0.2.1:5555 --soak-seconds=60 \
    --build-name=9.8.7 --build-number=321

  [ "$status" -eq 0 ]
  [[ "$output" == *"flutter analyze"* ]]
  [[ "$output" == *"flutter test"* ]]
  [[ "$output" == *"integration_test/flows/user_flows_test.dart"* ]]
  [[ "$output" == *"integration_test/flows/critical_journey_test.dart"* ]]
  [[ "$output" == *"integration_test/rendering/render_validation_test.dart"* ]]
  [[ "$output" == *"integration_test/performance/perf_smoke_test.dart"* ]]
  [[ "$output" == *"integration_test/accessibility/semantics_audit_test.dart"* ]]
  [[ "$output" == *"flutter build apk --release --target-platform android-x64"* ]]
  [[ "$output" == *"--android-project-arg release-abi=x86_64"* ]]
  [[ "$output" == *"--build-name=9.8.7"* ]]
  [[ "$output" == *"--build-number=321"* ]]
  [ "$(grep -c "adb -s 192.0.2.1:5555 install build/app/outputs/flutter-apk/app-release.apk" <<<"$output")" -eq 2 ]
  [[ "$output" == *"shell am start -W -n com.trebuchetdynamics.fractal.forge/.MainActivity"* ]]
  [[ "$output" == *"send-trim-memory"* ]]
  [[ "$output" == *"https://fractal.trebuchetdynamics.com/view?type=julia"* ]]
  [[ "$output" == *"uiautomator"* ]]
  [[ "$output" == *"am force-stop"* ]]
  [[ "$output" == *"svc wifi disable"* ]]
  [[ "$output" == *"preserve network state"* ]]
  [[ "$output" == *"monkey"* ]]
  [[ "$output" == *"--pct-syskeys 0"* ]]
  [[ "$output" == *"timeout --signal=INT --kill-after=10"* ]]
  [[ "$output" == *"dumpsys meminfo"* ]]
  [[ "$output" == *"dumpsys gfxinfo"* ]]
  [[ "$output" == *"dumpsys battery"* ]]
  [[ "$output" == *"dumpsys thermalservice"* ]]
  [[ "$output" == *"validate bounded PSS"* ]]
  [[ "$output" == *"validate crash/ANR count: 0"* ]]
  [[ "$output" == *"validate janky frames"* ]]
  [[ "$output" == *"validate thermal status"* ]]
}
