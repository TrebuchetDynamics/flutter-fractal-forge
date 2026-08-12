# Privacy Policy — Fractal Forge

**Effective date:** 2026-08-09
**Android package:** `com.trebuchetdynamics.fractal.forge`

Fractal Forge is designed to work offline and does not require an account.

## Data collection

The production application does **not** include advertising, remote analytics, behavioral tracking, or a remote crash-reporting SDK. It does not sell or transmit personal information to Trebuchet Dynamics.

The release Android manifest does not request Internet access. Debug and profile builds request Internet access only for Flutter development tooling such as hot reload and debugging; those permissions are not part of the production release manifest.

## Data stored on the device

Fractal Forge may store the following locally:

- application settings and accessibility preferences;
- saved fractal presets, viewing history, and exploration statistics;
- the most recently restorable viewer state;
- images, animations, or other exports that the user explicitly creates;
- temporary files required while an export is in progress.

The in-app crash reporter is local-only and keeps a bounded in-memory diagnostic buffer by default. Diagnostic information is shared only when the user explicitly chooses to export or share it.

Application-private settings are removed according to the operating system's app-data removal behavior. User-created exports remain in the selected media or file location until the user deletes them.

## Permissions and system integrations

- **Set wallpaper:** used only when the user explicitly applies a generated fractal as wallpaper.
- **Media/file access:** destinations are selected through Android media and file APIs when exporting.
- **Share sheet:** content is sent to another application only after the user invokes Share and selects a destination.
- **Deep links:** `fractalforge://` and `https://fractal.trebuchetdynamics.com/view` links can open a requested fractal state. Opening a universal link may involve the browser or operating system resolving that link before Fractal Forge receives it.

## Children and sensitive information

The application does not ask for names, contact details, precise location, payment information, health information, or other sensitive personal data. Users should avoid placing sensitive information in text overlays or files they choose to share.

## Changes and contact

Material privacy changes must be reflected in this policy and in the applicable store data-safety disclosure before release. Questions may be submitted through the repository issue tracker:

https://github.com/TrebuchetDynamics/flutter-fractal-forge/issues
