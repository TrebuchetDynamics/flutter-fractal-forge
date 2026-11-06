#!/usr/bin/env python3
"""Probe public Google Play storefronts for one package.

This is the end-user view, not the Play Developer API. It reports, per country:

- HTTP status of the store page,
- whether the listing is available there,
- the "Updated on" date the page shows,
- the app version the page embeds, when the page exposes it.

The page is not an official API. Treat the result as evidence with limits:
storefront markup, consent walls, A/B tests and bot handling can change it.
The official availability (targeted countries) comes from the Developer API;
scripts/ci/play-observe.sh combines both.

Exit codes: 0 observation produced, 2 invalid arguments.
"""

from __future__ import annotations

import argparse
import html as html_module
import json
import re
import sys
import urllib.error
import urllib.request

USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)
STORE_URL = "https://play.google.com/store/apps/details?id={package}&gl={country}&hl={lang}"
DEFAULT_COUNTRIES = "US,GB,CA,DE,FR,ES,MX,BR,IN,JP,AU"

_UPDATED = re.compile(r"Updated on</div>\s*<div[^>]*>([^<]+)</div>")
_VERSION = re.compile(r'"141":\[\[\["([^"]+)"\]\]')
_NOT_FOUND = re.compile(r"<title>\s*Not Found\s*</title>", re.IGNORECASE)
_DEVICE_WARNING = re.compile(
    r"(?:not compatible with your device|may not be available on your device)",
    re.IGNORECASE,
)


def parse_storefront(body: str, http_status: int) -> dict:
    """Classify one storefront response. Pure function; used by tests."""
    if http_status == 404 or _NOT_FOUND.search(body):
        return {
            "available": False,
            "reason": "storefront returned not-found",
            "updated": None,
            "version": None,
            "device_warning": False,
        }
    if http_status != 200:
        return {
            "available": None,
            "reason": f"unexpected HTTP {http_status}",
            "updated": None,
            "version": None,
            "device_warning": False,
        }
    updated = _UPDATED.search(body)
    version = _VERSION.search(body)
    return {
        "available": True,
        "reason": None,
        "updated": html_module.unescape(updated.group(1)).strip() if updated else None,
        "version": version.group(1) if version else None,
        "device_warning": bool(_DEVICE_WARNING.search(body)),
    }


def fetch(url: str, timeout: float) -> tuple[int, str]:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return response.status, response.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode("utf-8", "replace")
    except (urllib.error.URLError, TimeoutError, OSError) as error:
        return 0, f"transport error: {error}"


def probe(package: str, country: str, lang: str, timeout: float) -> dict:
    status, body = fetch(
        STORE_URL.format(package=package, country=country, lang=lang), timeout
    )
    row = {"country": country, "http_status": status, **parse_storefront(body, status)}
    return row


def summarize(rows: list[dict], expected_version: str | None, expected_date: str | None) -> dict:
    """Split rows into propagated/pending/unavailable/error.

    Propagation means the storefront page shows the expected release date, or
    the expected version when the page exposes a version. Missing expectations
    only report availability.
    """
    propagated, pending, unavailable, errors = [], [], [], []
    for row in rows:
        country = row["country"]
        if row["available"] is False:
            unavailable.append(country)
            continue
        if row["available"] is None:
            errors.append(country)
            continue
        matches_date = not expected_date or (row.get("updated") == expected_date)
        matches_version = not expected_version or (row.get("version") == expected_version)
        if matches_date and matches_version:
            propagated.append(country)
        else:
            pending.append(
                {
                    "country": country,
                    "updated": row.get("updated"),
                    "version": row.get("version"),
                }
            )
    return {
        "propagated": propagated,
        "pending": pending,
        "unavailable": unavailable,
        "errors": errors,
        "available": len(propagated) + len(pending),
        "probed": len(rows),
    }


def infer_review(
    document: dict, expected_version: str | None, expected_date: str | None
) -> dict:
    """Infer whether the release reached storefronts. Not a review verdict."""
    summary = document.get("summary", {})
    if not expected_version and not expected_date:
        return {
            "state": "unknown",
            "basis": "no expected version or date supplied",
            "caveats": ["pass --expected-version and --expected-date to infer propagation"],
        }
    propagated = summary.get("propagated", [])
    pending = summary.get("pending", [])
    errors = summary.get("errors", [])
    if propagated and not pending and not errors:
        state = "published-to-probed-storefronts"
    elif propagated:
        state = "partially-propagated"
    else:
        state = "not-yet-visible"
    return {
        "state": state,
        "basis": {
            "propagated": len(propagated),
            "pending": len(pending),
            "errors": len(errors),
            "probed": summary.get("probed", 0),
            "expected_version": expected_version,
            "expected_updated": expected_date,
        },
        "caveats": [
            "a listed storefront means the release reached users, not that Google approved it publicly",
            "staged rollout or country targeting can hide a version in some storefronts",
            "this inference is not the Play Console review state",
        ],
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", required=True)
    parser.add_argument("--countries", default=DEFAULT_COUNTRIES)
    parser.add_argument("--lang", default="en")
    parser.add_argument("--expected-version", default=None)
    parser.add_argument("--expected-date", default=None)
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--json", action="store_true", help="emit JSON (default)")
    args = parser.parse_args(argv)

    countries = [item.strip().upper() for item in args.countries.split(",") if item.strip()]
    if not countries:
        print("no countries requested", file=sys.stderr)
        return 2
    rows = [probe(args.package, country, args.lang, args.timeout) for country in countries]
    document = {
        "package": args.package,
        "language": args.lang,
        "expected_version": args.expected_version,
        "expected_updated": args.expected_date,
        "storefronts": rows,
        "summary": summarize(rows, args.expected_version, args.expected_date),
        "review_status": "not observable through the public Play Developer API",
        "limits": [
            "storefront HTML is not an official API and can change",
            "geo/IP, consent walls, A/B tests and bot handling can alter the page",
            "a listed page does not prove installation on a specific device or account",
        ],
    }
    print(json.dumps(document, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
