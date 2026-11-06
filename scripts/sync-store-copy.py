#!/usr/bin/env python3
"""Mirror the canonical Play listing copy into Fastlane and the English text files.

The canonical source is docs/play-store-localized-listings.json. Google Play
uploads read it directly, while Fastlane metadata and the reviewable English
files in docs/store_listing/ are maintained copies. Run this after editing the
JSON, or use --check to fail on drift.
"""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
CANONICAL = ROOT / 'docs' / 'play-store-localized-listings.json'
FASTLANE = ROOT / 'fastlane' / 'metadata' / 'android'
ENGLISH = ROOT / 'docs' / 'store_listing'
FIELDS = {
    'title': 'title.txt',
    'shortDescription': 'short_description.txt',
    'fullDescription': 'full_description.txt',
}


def targets(data):
    """Yield (path, expected text) pairs for every maintained copy."""
    for locale, listing in data['locales'].items():
        for field, filename in FIELDS.items():
            yield FASTLANE / locale / filename, listing[field].strip()
    for field, filename in FIELDS.items():
        yield ENGLISH / filename, data['locales']['en-US'][field].strip()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true',
                        help='Report drift instead of writing files')
    args = parser.parse_args(argv)

    data = json.loads(CANONICAL.read_text(encoding='utf-8'))
    drifted = []
    for path, expected in targets(data):
        actual = path.read_text(encoding='utf-8').strip() if path.exists() else None
        if actual == expected:
            continue
        if args.check:
            drifted.append(path.relative_to(ROOT))
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(expected + '\n', encoding='utf-8')

    if args.check and drifted:
        for path in drifted:
            print(f'drift: {path}', file=sys.stderr)
        return 1
    if args.check:
        print(f'{len(list(targets(data)))} listing copies match the canonical JSON')
    else:
        print(f'{len(list(targets(data)))} listing copies synced from {CANONICAL.relative_to(ROOT)}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
