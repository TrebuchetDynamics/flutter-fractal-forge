# Play Console Upload Staging

Drop app bundles here to upload.

Use:

```bash
scripts/build-play-console.sh
```

The script copies the newest signed `.aab` into this folder and writes a
matching `.sha256` checksum file.

Version is auto-managed by the script:

- build number is auto-managed from `pubspec.yaml` `+N` and `play-console-upload/LAST_BUILD_NUMBER.txt`
- version name defaults to `<pubspec major>.<pubspec minor>.<build number>`, e.g. `1.1.0+38` with build `58` builds as `1.1.58`
- pass `--build-name x.y.z` to override
- run `scripts/build-play-console.sh --print-version --skip-pub-get` to preview the computed values without building

Build number behavior:

- First build uses `pubspec.yaml` `+N` exactly.
- Later builds increment from `LAST_BUILD_NUMBER.txt`.

The script also runs the release bundle build with `--no-pub` and applies a
temporary release-only registrant workaround so `integration_test` dev plugin
does not break Play Console `.aab` compilation.

Upload-key safety check:

- The script verifies signing cert SHA1 against:
  `android/play-upload-cert-sha1.txt`
- You can override with `--expected-sha1 ...` or disable with
  `--no-verify-sha1`
- Signing files (`android/key.properties`, `*.jks`, `*.keystore`, `*.p12`,
  `*.pfx`, `*.pem`) must stay private and are ignored by git.
