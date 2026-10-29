#!/usr/bin/env bash
set -euo pipefail

BASE_HREF="${1:-/flutter-fractal-forge/}"
if [[ $# -gt 0 ]]; then shift; fi

if [[ "${BASE_HREF}" != "/" && ! "${BASE_HREF}" =~ ^/.*/$ ]]; then
  echo "Base href must be '/' or start and end with '/'; got: ${BASE_HREF}" >&2
  exit 2
fi

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if ! command -v -- "${FLUTTER_BIN}" >/dev/null 2>&1; then
  echo "Configured Flutter executable is unavailable: ${FLUTTER_BIN}" >&2
  exit 127
fi

WEB_OUTPUT_DIR="${WEB_OUTPUT_DIR:-build/web}"
"${FLUTTER_BIN}" build web --release --no-wasm-dry-run --base-href "${BASE_HREF}" --output="${WEB_OUTPUT_DIR}" "$@"

export BASE_HREF WEB_OUTPUT_DIR
python3 - <<'PY'
import hashlib
import os
import re
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse

root = Path(os.environ['WEB_OUTPUT_DIR'])
landing = root / 'landing.html'
index = root / 'index.html'
manifest = root / 'manifest.json'

assert index.exists(), 'build/web/index.html missing'
assert landing.exists(), 'build/web/landing.html missing'
assert manifest.exists(), 'build/web/manifest.json missing'

main_js = root / 'main.dart.js'
bootstrap = root / 'flutter_bootstrap.js'
main_hash = hashlib.sha256(main_js.read_bytes()).hexdigest()[:12]
bootstrap_text = bootstrap.read_text()
bootstrap_text, replacements = re.subn(
    r'"mainJsPath"\s*:\s*"main[.]dart[.]js(?:[?]v=[0-9a-f]{12})?"',
    f'"mainJsPath":"main.dart.js?v={main_hash}"', bootstrap_text,
)
assert replacements, 'generated Flutter JavaScript entrypoint missing'
bootstrap.write_text(bootstrap_text)
bootstrap_hash = hashlib.sha256(bootstrap.read_bytes()).hexdigest()[:12]
index_text, replacements = re.subn(
    r'src="flutter_bootstrap[.]js(?:[?]v=[0-9a-f]{12})?"',
    f'src="flutter_bootstrap.js?v={bootstrap_hash}"', index.read_text(),
)
assert replacements == 1, 'expected one generated Flutter bootstrap script'
index.write_text(index_text)

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
assert any('github.com/TrebuchetDynamics/flutter-fractal-forge' in href for href in parser.links), 'GitHub link missing'

base_href = os.environ['BASE_HREF']
index_text = index.read_text()
assert f'<base href="{base_href}">' in index_text, 'unexpected Flutter base href'

declared_shaders = []
in_shaders = False
for line in Path('pubspec.yaml').read_text().splitlines():
    if line == '  shaders:':
        in_shaders = True
        continue
    if in_shaders and line.startswith('  ') and not line.startswith('    '):
        break
    if in_shaders and line.startswith('    - '):
        declared_shaders.append(line.split('- ', 1)[1].strip())
missing_shaders = sorted(asset for asset in set(declared_shaders)
                         if not (root / 'assets' / asset).is_file())
assert not missing_shaders, f'declared shaders missing from bundle: {missing_shaders}'
built_shaders = len(set(declared_shaders))

print('web_preview_build_ok', {'baseHref': base_href, 'links': len(parser.links), 'images': len(parser.images), 'shaders': built_shaders})
PY
