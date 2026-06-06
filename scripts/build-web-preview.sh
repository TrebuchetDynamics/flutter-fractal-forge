#!/usr/bin/env bash
set -euo pipefail

BASE_HREF="${1:-/flutter-fractal-forge/}"

if [[ "${BASE_HREF}" != "/" && ! "${BASE_HREF}" =~ ^/.*/$ ]]; then
  echo "Base href must be '/' or start and end with '/'; got: ${BASE_HREF}" >&2
  exit 2
fi

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"
if [[ ! -x "${FLUTTER_BIN}" ]]; then
  FLUTTER_BIN="flutter"
fi

"${FLUTTER_BIN}" build web --release --no-wasm-dry-run --base-href "${BASE_HREF}"

export BASE_HREF
python3 - <<'PY'
import os
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse

root = Path('build/web')
landing = root / 'landing.html'
index = root / 'index.html'
manifest = root / 'manifest.json'

assert index.exists(), 'build/web/index.html missing'
assert landing.exists(), 'build/web/landing.html missing'
assert manifest.exists(), 'build/web/manifest.json missing'

class Parser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.images = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and attrs.get('href'):
            self.links.append(attrs['href'])
        if tag == 'img' and attrs.get('src'):
            self.images.append(
                (attrs['src'], attrs.get('width'), attrs.get('height'), attrs.get('alt'))
            )

parser = Parser()
parser.feed(landing.read_text())

for src, width, height, alt in parser.images:
    assert (root / src).exists(), f'image missing: {src}'
    assert width and height, f'image lacks dimensions: {src}'
    assert alt, f'image lacks alt text: {src}'

for href in parser.links:
    parsed = urlparse(href)
    if parsed.scheme or href.startswith('#'):
        continue
    assert (root / href).exists(), f'local link target missing: {href}'

assert 'index.html' in parser.links, 'Try web preview link missing'
assert '#download' in parser.links, 'Download anchor missing'
assert 'landing-assets/web_preview_loop.gif' in parser.links, 'Preview GIF link missing'
assert any('github.com/XelHaku/flutter-fractal-forge' in href for href in parser.links), 'GitHub link missing'

base_href = os.environ['BASE_HREF']
index_text = index.read_text()
assert f'<base href="{base_href}">' in index_text, 'unexpected Flutter base href'

print('web_preview_build_ok', {'baseHref': base_href, 'links': len(parser.links), 'images': len(parser.images)})
PY
