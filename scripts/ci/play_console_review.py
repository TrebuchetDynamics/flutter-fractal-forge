#!/usr/bin/env python3
"""Read a Google Play Console publishing/review state from a page or fixture.

Google publishes no app-review API. The only direct source is the Play Console
page for the app (Developer account session) or the review email. This helper
parses a Console page and reports the review phrase it finds. It is opt-in,
unofficial and fragile:

- Play Console is a scripted app. The state may arrive by XHR and be missing from
  the plain HTTP response. Use the rendered DOM (browser "Save page") or pass
  the URL with an authorized session cookie file.
- Cookie files are read-only input. Never commit, print or log their contents.
- The page layout and wording can change without notice. Re-check the parser
  fixtures when the Console changes.

Usage:
  play_console_review.py --html saved-publishing.html [--url URL]
  play_console_review.py --url https://play.google.com/console/... --cookies cookies.txt

Exit codes: 0 state found, 1 page read but no known review phrase, 2 bad input.
"""

from __future__ import annotations

import argparse
import datetime
import json
import re
import sys
import urllib.error
import urllib.request

USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)

# Ordered from most specific to most generic. Each entry is (state, pattern).
STATES = [
    ("rejected", re.compile(r"\b(?:rejected|denied|removed for policy)\b", re.I)),
    ("changes_in_review", re.compile(r"\bchanges? in review\b", re.I)),
    ("in_review", re.compile(r"\bin review\b", re.I)),
    ("not_yet_reviewed", re.compile(r"\bnot yet reviewed\b", re.I)),
    ("ready_to_publish", re.compile(r"\bready to publish\b", re.I)),
    ("approved", re.compile(r"\b(?:approved|review complete[d]?)\b", re.I)),
    ("published", re.compile(r"\bpublished\b", re.I)),
]


def classify(page: str) -> dict:
    """Return the first known review state and a short context string."""
    for state, pattern in STATES:
        match = pattern.search(page)
        if match:
            start = max(0, match.start() - 80)
            context = re.sub(r"\s+", " ", page[start:match.end() + 80]).strip()
            return {"state": state, "matched": match.group(0), "context": context}
    return {"state": "unknown", "matched": None, "context": None}


def netscape_cookies(path: str) -> str:
    """Build a Cookie header from a Netscape cookie file. Never echo it."""
    pairs = []
    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            if line.startswith("#") or not line.strip():
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) >= 7 and parts[5] and parts[6]:
                pairs.append(f"{parts[5]}={parts[6]}")
    return "; ".join(pairs)


def fetch(url: str, cookies: str | None, timeout: float) -> tuple[int, str]:
    headers = {"User-Agent": USER_AGENT, "Accept-Language": "en-US,en;q=0.9"}
    if cookies:
        headers["Cookie"] = cookies
    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return response.status, response.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode("utf-8", "replace")
    except (urllib.error.URLError, TimeoutError, OSError) as error:
        return 0, f"transport error: {error}"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--html", help="saved Console page (rendered DOM)")
    source.add_argument("--url", help="Play Console page URL")
    parser.add_argument("--cookies", help="Netscape cookie file for --url")
    parser.add_argument("--timeout", type=float, default=45.0)
    args = parser.parse_args(argv)

    status = None
    if args.html:
        page = open(args.html, encoding="utf-8", errors="replace").read()
    else:
        cookies = netscape_cookies(args.cookies) if args.cookies else None
        status, page = fetch(args.url, cookies, args.timeout)
        if status == 0:
            print(page, file=sys.stderr)
            return 2
        if status in (401, 403, 302):
            print(
                f"Console returned HTTP {status}; the session cookie is missing or expired",
                file=sys.stderr,
            )
            return 2

    result = classify(page)
    document = {
        "source": "console" if args.url else "console-html",
        "url": args.url,
        "http_status": status,
        "state": result["state"],
        "matched": result["matched"],
        "context": result["context"],
        "observed_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(
            timespec="seconds"
        ),
        "limits": [
            "unofficial Play Console page, not a supported API",
            "the state can be missing from the HTTP response when the Console renders it by XHR",
            "wording and layout can change without notice",
            "use only an authorized developer session; never commit or print cookies",
        ],
    }
    print(json.dumps(document, indent=2, sort_keys=True))
    return 0 if result["state"] != "unknown" else 1


if __name__ == "__main__":
    raise SystemExit(main())
