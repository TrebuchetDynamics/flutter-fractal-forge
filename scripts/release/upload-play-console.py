#!/usr/bin/env python3
"""Upload a signed AAB to Google Play Console via the Android Publisher API.

Usage:
    scripts/release/upload-play-console.py [options]

Options:
    --aab PATH          AAB to upload (default: latest in play-console-upload/)
    --track TRACK       Release track: internal | alpha | beta | production
                        (default: internal)
    --key PATH          Service account JSON key
                        (default: android/play-service-account.json)
    --release-notes TXT Human-readable release notes (optional)
    --promote-from SRC  Promote existing release from SRC track instead of
                        uploading a new AAB (e.g. --promote-from internal)
    --dry-run           Validate inputs and auth without committing the release
"""

import argparse
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACKAGE_NAME = "com.trebuchetdynamics.fractal.forge"
DEFAULT_KEY = ROOT / "android" / "play-service-account.json"
DEFAULT_UPLOAD_DIR = ROOT / "play-console-upload"
VALID_TRACKS = ("internal", "alpha", "beta", "production")


def die(msg):
    print(f"[upload-play] ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def log(msg):
    print(f"[upload-play] {msg}")


def find_latest_aab(upload_dir: Path) -> Path:
    aabs = sorted(upload_dir.glob("*.aab"), key=lambda p: p.stat().st_mtime)
    if not aabs:
        die(f"No .aab files found in {upload_dir}")
    return aabs[-1]


def build_service(key_path: Path):
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
    except ImportError:
        die(
            "Missing dependencies. Run:\n"
            "  pip install google-api-python-client google-auth"
        )

    creds = service_account.Credentials.from_service_account_file(
        str(key_path),
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    return build("androidpublisher", "v3", credentials=creds, cache_discovery=False)


def open_edit(service, package):
    result = service.edits().insert(body={}, packageName=package).execute()
    return result["id"]


def upload_aab(service, package, edit_id, aab_path: Path):
    from googleapiclient.http import MediaFileUpload

    log(f"Uploading {aab_path.name} ({aab_path.stat().st_size // 1_000_000} MB)…")
    media = MediaFileUpload(
        str(aab_path),
        mimetype="application/octet-stream",
        resumable=True,
    )
    response = (
        service.edits()
        .bundles()
        .upload(
            packageName=package,
            editId=edit_id,
            media_body=media,
        )
        .execute()
    )
    version_code = response["versionCode"]
    log(f"Uploaded — versionCode={version_code}")
    return version_code


def set_track(service, package, edit_id, track, version_codes, release_notes=None):
    release = {"status": "completed", "versionCodes": [str(v) for v in version_codes]}
    if release_notes:
        release["releaseNotes"] = [{"language": "en-US", "text": release_notes[:500]}]

    service.edits().tracks().update(
        packageName=package,
        editId=edit_id,
        track=track,
        body={"releases": [release]},
    ).execute()
    log(f"Track '{track}' updated with versionCodes={version_codes}")


def promote(service, package, edit_id, from_track, to_track, release_notes=None):
    src = (
        service.edits()
        .tracks()
        .get(packageName=package, editId=edit_id, track=from_track)
        .execute()
    )
    releases = src.get("releases", [])
    completed = [r for r in releases if r.get("status") == "completed"]
    if not completed:
        die(f"No completed release found on track '{from_track}'")
    latest = completed[-1]
    version_codes = latest.get("versionCodes", [])
    log(f"Promoting versionCodes={version_codes} from '{from_track}' → '{to_track}'")
    set_track(service, package, edit_id, to_track, version_codes, release_notes)


def commit_edit(service, package, edit_id):
    service.edits().commit(packageName=package, editId=edit_id).execute()
    log("Edit committed — release is live on track.")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--aab", type=Path, help="AAB file to upload")
    parser.add_argument("--track", default="internal", choices=VALID_TRACKS)
    parser.add_argument("--key", type=Path, default=DEFAULT_KEY)
    parser.add_argument("--release-notes", default="")
    parser.add_argument("--promote-from", metavar="SRC_TRACK", choices=VALID_TRACKS)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Validate key
    if not args.key.exists():
        die(
            f"Service account key not found: {args.key}\n"
            "  1. Create a service account in Google Cloud Console\n"
            "  2. Grant it 'Release manager' in Play Console → Setup → API access\n"
            "  3. Download the JSON key and save it to android/play-service-account.json"
        )

    # Resolve AAB
    if not args.promote_from:
        aab = args.aab or find_latest_aab(DEFAULT_UPLOAD_DIR)
        if not aab.exists():
            die(f"AAB not found: {aab}")
        log(f"AAB: {aab}")

    log(f"Track: {args.track}")
    if args.dry_run:
        log("Dry-run: auth check only — no changes will be committed")

    service = build_service(args.key)
    log("Authenticated with Google Play Developer API")

    edit_id = open_edit(service, PACKAGE_NAME)
    log(f"Edit opened: {edit_id}")

    if args.dry_run:
        # Discard edit — don't commit anything
        service.edits().delete(packageName=PACKAGE_NAME, editId=edit_id).execute()
        log("Dry-run complete — auth OK, edit discarded.")
        return

    if args.promote_from:
        promote(service, PACKAGE_NAME, edit_id, args.promote_from, args.track, args.release_notes)
    else:
        version_code = upload_aab(service, PACKAGE_NAME, edit_id, aab)
        set_track(service, PACKAGE_NAME, edit_id, args.track, [version_code], args.release_notes)

    commit_edit(service, PACKAGE_NAME)


if __name__ == "__main__":
    main()
