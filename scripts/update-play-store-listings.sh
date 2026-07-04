#!/usr/bin/env bash
set -euo pipefail

# Update Google Play Store listing text for every existing locale.
# Usage:
#   scripts/update-play-store-listings.sh [--commit]
#
# Default is dry-run: authenticate, create a temporary Play edit, verify live
# locales are covered by docs/play-store-localized-listings.json, then delete
# the edit without changing Play Console state.
#
# Env:
#   PLAY_PACKAGE_NAME                  default: com.trebuchetdynamics.fractal.forge
#   PLAY_SERVICE_ACCOUNT_JSON          default: play-console-upload/play-service-account.json
#   PLAY_LOCALIZED_LISTINGS_JSON       default: docs/play-store-localized-listings.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

PACKAGE_NAME="${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}"
KEY_JSON="${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
LISTINGS_JSON="${PLAY_LOCALIZED_LISTINGS_JSON:-docs/play-store-localized-listings.json}"
COMMIT=false
TMP_FILES=()

log() { echo "[update-play-store-listings] $*"; }
die() { echo "[update-play-store-listings] ERROR: $*" >&2; exit 1; }
cleanup() { rm -f "${TMP_FILES[@]:-}"; }
trap cleanup EXIT

for arg in "$@"; do
  case "$arg" in
    --commit) COMMIT=true ;;
    --dry-run) COMMIT=false ;;
    --help|-h)
      sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) die "unknown argument: $arg" ;;
  esac
done

need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found"; }
json_field() { python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"; }
b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }
request() {
  local body status
  body="$(mktemp)"; TMP_FILES+=("$body")
  status="$(curl -sS -w '%{http_code}' -o "$body" "$@")" || {
    cat "$body" >&2
    die "curl failed"
  }
  if [[ ! "$status" =~ ^2 ]]; then
    cat "$body" >&2
    die "HTTP $status"
  fi
  cat "$body"
}

[[ -f "$KEY_JSON" ]] || die "Missing service account JSON: $KEY_JSON"
[[ -f "$LISTINGS_JSON" ]] || die "Missing listings JSON: $LISTINGS_JSON"
need curl
need openssl
need python3

log "Validating localized listing lengths..."
python3 - "$LISTINGS_JSON" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding='utf-8'))
locales = data.get('locales') or {}
if not locales:
    raise SystemExit('no locales in listings JSON')
for locale, listing in sorted(locales.items()):
    title = listing.get('title', '')
    short = listing.get('shortDescription', '')
    full = listing.get('fullDescription', '')
    if len(title) > 50:
        raise SystemExit(f'{locale}: title too long ({len(title)} > 50)')
    if len(short) > 80:
        raise SystemExit(f'{locale}: shortDescription too long ({len(short)} > 80)')
    if len(full) > 4000:
        raise SystemExit(f'{locale}: fullDescription too long ({len(full)} > 4000)')
print(f'validated {len(locales)} local listing(s)')
PY

KEY_FILE="$(mktemp)"; TMP_FILES+=("$KEY_FILE")
python3 - "$KEY_JSON" "$KEY_FILE" <<'PY'
import json, sys
src, dst = sys.argv[1:3]
data = json.load(open(src, encoding='utf-8'))
open(dst, 'w', encoding='utf-8').write(data['private_key'])
PY
CLIENT_EMAIL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["client_email"])' "$KEY_JSON")"
chmod 600 "$KEY_FILE"

NOW="$(date +%s)"
EXP="$((NOW + 3600))"
HEADER='{"alg":"RS256","typ":"JWT"}'
PAYLOAD="$(python3 - <<PY
import json
print(json.dumps({
  'iss': '$CLIENT_EMAIL',
  'scope': 'https://www.googleapis.com/auth/androidpublisher',
  'aud': 'https://oauth2.googleapis.com/token',
  'iat': $NOW,
  'exp': $EXP,
}, separators=(',', ':')))
PY
)"
SIGNING_INPUT="$(printf '%s' "$HEADER" | b64url).$(printf '%s' "$PAYLOAD" | b64url)"
SIGNATURE="$(printf '%s' "$SIGNING_INPUT" | openssl dgst -sha256 -sign "$KEY_FILE" -binary | b64url)"
ASSERTION="$SIGNING_INPUT.$SIGNATURE"

log "Requesting Google access token..."
TOKEN_RESPONSE="$(request -X POST 'https://oauth2.googleapis.com/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
  --data-urlencode "assertion=$ASSERTION")"
ACCESS_TOKEN="$(printf '%s' "$TOKEN_RESPONSE" | json_field access_token)"

API="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$PACKAGE_NAME"
AUTH=(-H "Authorization: Bearer $ACCESS_TOKEN")

log "Creating Play edit for $PACKAGE_NAME..."
EDIT_RESPONSE="$(request -X POST "${AUTH[@]}" -H 'Content-Type: application/json' -d '{}' "$API/edits")"
EDIT_ID="$(printf '%s' "$EDIT_RESPONSE" | json_field id)"
log "Edit id: $EDIT_ID"

CURRENT_LISTINGS="$(mktemp)"; TMP_FILES+=("$CURRENT_LISTINGS")
request -X GET "${AUTH[@]}" "$API/edits/$EDIT_ID/listings" > "$CURRENT_LISTINGS"

PLAN="$(mktemp)"; TMP_FILES+=("$PLAN")
python3 - "$LISTINGS_JSON" "$CURRENT_LISTINGS" "$PLAN" <<'PY'
import json, sys
local_path, current_path, plan_path = sys.argv[1:4]
local = json.load(open(local_path, encoding='utf-8'))['locales']
current = json.load(open(current_path, encoding='utf-8')).get('listings', [])
if not current:
    raise SystemExit('Play API returned no existing listings; refusing to choose locales blindly')
missing = [item.get('language') for item in current if item.get('language') not in local]
if missing:
    raise SystemExit('missing local copy for Play locale(s): ' + ', '.join(missing))
plan = []
for item in current:
    locale = item['language']
    listing = dict(local[locale])
    if item.get('video'):
        listing['video'] = item['video']
    plan.append({'locale': locale, 'body': listing})
json.dump(plan, open(plan_path, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(f'will update {len(plan)} Play locale(s): ' + ', '.join(p['locale'] for p in plan))
for p in plan:
    b = p['body']
    print(f"{p['locale']}: title={len(b['title'])}, short={len(b['shortDescription'])}, full={len(b['fullDescription'])}")
PY

python3 - "$PLAN" <<'PY'
import json, pathlib, sys
plan = json.load(open(sys.argv[1], encoding='utf-8'))
base = pathlib.Path('/tmp/play-listing-payloads')
base.mkdir(exist_ok=True)
for item in plan:
    path = base / f"{item['locale']}.json"
    path.write_text(json.dumps(item['body'], ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    item['payloadPath'] = str(path)
json.dump(plan, open(sys.argv[1], 'w', encoding='utf-8'), ensure_ascii=False)
PY

log "Uploading listing text to edit..."
python3 - "$PLAN" <<'PY' > /tmp/play-listing-locales.txt
import json, sys
for item in json.load(open(sys.argv[1], encoding='utf-8')):
    print(item['locale'], item['payloadPath'])
PY
while read -r locale payload; do
  [[ -n "$locale" ]] || continue
  request -X PUT "${AUTH[@]}" -H 'Content-Type: application/json; charset=utf-8' \
    --data-binary "@$payload" "$API/edits/$EDIT_ID/listings/$locale" >/dev/null
  log "Updated locale in edit: $locale"
done < /tmp/play-listing-locales.txt

if [[ "$COMMIT" == true ]]; then
  log "Committing Play edit..."
  request -X POST "${AUTH[@]}" "$API/edits/$EDIT_ID:commit" >/dev/null
  log "Committed listing update for $PACKAGE_NAME"
else
  log "Dry run; deleting edit without commit. Re-run with --commit to apply."
  request -X DELETE "${AUTH[@]}" "$API/edits/$EDIT_ID" >/dev/null || true
fi
