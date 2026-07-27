# AndroidManifest Permission Audit

Date: 2026-07-26
File audited: `android/app/src/main/AndroidManifest.xml`

## Permissions found

- `android.permission.SET_WALLPAPER` — requested so a rendered fractal can be
  applied as the device wallpaper. Nothing is read from the device.

No other `<uses-permission>` entries. In particular the app declares no
camera, microphone, location, contacts, media or storage permissions.

## Non-permission manifest declarations retained

- Launcher/main activity
- Deep link intent filters (`fractalforge://` and
  `https://fractal.trebuchetdynamics.com`)
- Flutter embedding metadata
- Impeller metadata
- `<queries>` for `android.intent.action.PROCESS_TEXT`

## Conclusion

The manifest holds a single permission tied to one user-initiated action, and
aligns with the Play Store principle of minimum privilege.

## Keeping this accurate

This file is a point-in-time record and had drifted before: it previously
reported zero permissions after `SET_WALLPAPER` was added, and named a deep
link host the app no longer uses.

The claim that matters to users is enforced automatically rather than here.
`test/modules/readme_catalog_claims_test.dart` derives the declared permission
set from the manifest and fails if the store listing or the privacy policy
advertises a capability the app cannot use. Re-check this document when the
manifest changes; trust the test for the public-facing claim.
