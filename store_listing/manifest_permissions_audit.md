# AndroidManifest Permission Audit

Date: 2026-02-17 01:50 CST (America/Monterrey)
File audited: `android/app/src/main/AndroidManifest.xml`

## Permissions found
- **None** (`<uses-permission>` entries: 0)

## Non-permission manifest declarations retained
- Launcher/main activity
- Deep link intent filters (`fractalforge://` and `https://fractalforge.app/view`)
- Flutter embedding metadata
- Impeller metadata
- `<queries>` for `android.intent.action.PROCESS_TEXT`

## Conclusion
Manifest is now near-zero permission for a pure rendering app and aligns with Play Store principle of minimum privilege.
