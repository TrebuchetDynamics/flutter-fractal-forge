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
