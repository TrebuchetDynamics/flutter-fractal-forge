#!/usr/bin/env bash
# Shared Google Play (Android Publisher v3) helpers. Source this file; it does
# not run anything on its own.
#
# Safety contract: every helper here is read-only apart from opening and
# deleting its own throwaway edit. Uploading, committing and listing changes
# stay in scripts/build-upload-playstore.sh, which is the only writer.
#
# Credentials come from PLAY_SERVICE_ACCOUNT_JSON and are never echoed; the
# decoded private key lives in a private temporary file that is removed again
# as soon as the token is minted.

PLAY_API_BASE="https://androidpublisher.googleapis.com/androidpublisher/v3/applications"

play_require_tools() {
  local tool
  for tool in curl openssl python3; do
    command -v "$tool" >/dev/null 2>&1 || {
      echo "required tool unavailable: $tool" >&2
      return 2
    }
  done
}

play_key_json() {
  printf '%s\n' "${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
}

play_package_name() {
  printf '%s\n' "${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}"
}

play_track() {
  printf '%s\n' "${PLAY_TRACK:-production}"
}

play_api_url() {
  printf '%s/%s' "$PLAY_API_BASE" "$(play_package_name)"
}

_b64url() {
  openssl base64 -A | tr '+/' '-_' | tr -d '='
}

# Echo a bearer token for the configured service account.
play_access_token() {
  local key_json key_file client_email now header payload signature assertion
  local token_response access_token
  play_require_tools || return 2
  key_json="$(play_key_json)"
  [[ -f "$key_json" ]] || {
    echo "Play service account JSON unavailable: $key_json" >&2
    return 2
  }
  key_file="$(mktemp)" || return 2
  python3 - "$key_json" "$key_file" <<'PY' || { rm -f "$key_file"; echo "Play service account JSON is not readable" >&2; return 2; }
import json, pathlib, sys
pathlib.Path(sys.argv[2]).write_text(json.load(open(sys.argv[1], encoding="utf-8"))["private_key"])
PY
  chmod 600 "$key_file" 2>/dev/null || true
  client_email="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8")).get("client_email", ""))' "$key_json" 2>/dev/null)"
  if [[ -z "$client_email" ]]; then
    rm -f "$key_file"
    echo "Play service account client_email missing" >&2
    return 2
  fi
  now="$(date +%s)"
  header="$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | _b64url)"
  payload="$(CLIENT_EMAIL="$client_email" NOW="$now" python3 - <<'PY'
import base64, json, os
body = {"iss": os.environ["CLIENT_EMAIL"],
        "scope": "https://www.googleapis.com/auth/androidpublisher",
        "aud": "https://oauth2.googleapis.com/token",
        "iat": int(os.environ["NOW"]), "exp": int(os.environ["NOW"]) + 3600}
print(base64.urlsafe_b64encode(json.dumps(body, separators=(",", ":")).encode()).decode().rstrip("="))
PY
)"
  if ! signature="$(printf '%s' "$header.$payload" | openssl dgst -sha256 -sign "$key_file" -binary | _b64url)"; then
    rm -f "$key_file"
    echo "could not sign the Play service-account assertion" >&2
    return 2
  fi
  rm -f "$key_file"
  assertion="$header.$payload.$signature"
  if ! token_response="$(curl -fsS -X POST 'https://oauth2.googleapis.com/token' \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
      --data-urlencode "assertion=$assertion")"; then
    echo "could not exchange the Play service-account assertion for a token" >&2
    return 2
  fi
  access_token="$(printf '%s' "$token_response" | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])' 2>/dev/null)" || {
    echo "Play token response did not contain access_token" >&2
    return 2
  }
  printf '%s\n' "$access_token"
}

# Echo a fresh edit id for token $1.
play_open_edit() {
  local token="$1"
  [[ -n "$token" ]] || { echo "play_open_edit requires a token" >&2; return 2; }
  curl -fsS -X POST -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' -d '{}' "$(play_api_url)/edits" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'
}

# Delete edit $2 with token $1; failures are not fatal because edits expire.
play_discard_edit() {
  local token="$1" edit="$2"
  [[ -n "$token" && -n "$edit" ]] || return 0
  curl -fsS -X DELETE -H "Authorization: Bearer $token" "$(play_api_url)/edits/$edit" >/dev/null 2>&1 || true
}

# Echo the JSON resource at /edits/<edit><suffix> with token $1.
play_get() {
  local token="$1" edit="$2" suffix="$3"
  [[ -n "$token" && -n "$edit" ]] || { echo "play_get requires a token and edit" >&2; return 2; }
  curl -fsS -H "Authorization: Bearer $token" "$(play_api_url)/edits/$edit$suffix"
}
