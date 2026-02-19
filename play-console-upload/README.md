# Play Console Upload Staging

Drop app bundles here to upload.

Use:

```bash
scripts/build-play-console.sh
```

The script copies the newest signed `.aab` into this folder and writes a
matching `.sha256` checksum file.

Build number is auto-managed by the script (unless you pass `--build-number`)
using the highest known value from:

- `pubspec.yaml` (`version: x.y.z+N`)
- `android/local.properties` (`flutter.versionCode`)
- `play-console-upload/LAST_BUILD_NUMBER.txt`

The script also runs the release bundle build with `--no-pub` and applies a
temporary release-only registrant workaround so `integration_test` dev plugin
does not break Play Console `.aab` compilation.

Upload-key safety check:

- The script verifies signing cert SHA1 against:
  `android/play-upload-cert-sha1.txt`
- You can override with `--expected-sha1 ...` or disable with
  `--no-verify-sha1`
