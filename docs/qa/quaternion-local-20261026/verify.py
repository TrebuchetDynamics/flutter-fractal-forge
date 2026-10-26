#!/usr/bin/env python3
"""Read-only independent PNG/state/source/protocol verification (existing Pillow)."""
import gzip
import hashlib
import itertools
import json
import math
from pathlib import Path
import re

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sha = lambda data: hashlib.sha256(data).hexdigest()
load = lambda path: json.loads(path.read_text())


def png_metrics(path):
    with Image.open(path) as source:
        assert source.format == 'PNG'
        source.load()  # Actually inflate/decode, not just inspect an IHDR.
        image = source.convert('RGBA')
    pixels = list(image.getdata())
    visible = sum(pixel[3] > 0 for pixel in pixels)
    assert image.width > 0 and image.height > 0 and visible > 100
    assert len(set(pixels)) > 16, f'blank/constant plot: {path}'
    return image, {'width': image.width, 'height': image.height,
                   'rgba_sha256': sha(image.tobytes()),
                   'visible_pixels': visible, 'distinct_rgba': len(set(pixels))}


def changed(first, second):
    assert first.size == second.size, 'different capture boundaries are not walk evidence'
    count = sum(a != b for a, b in zip(first.getdata(), second.getdata()))
    assert count > 0, 'walk/rotation did not change actual plot pixels'
    return count


def prime(value):
    return value >= 2 and all(value % divisor for divisor in range(2, math.isqrt(value) + 1))


def verify():
    manifest = load(HERE / 'manifest.json')
    for name, digest in manifest['artifacts'].items():
        assert sha((HERE / name).read_bytes()) == digest, f'artifact drift: {name}'
    for name, digest in load(HERE / 'evidence/source-inputs.json').items():
        assert sha((ROOT / name).read_bytes()) == digest, f'tested source drift: {name}'

    native = HERE / 'evidence/native'
    receipt = load(native / 'run.json')
    assert receipt['exit_code'] == 0 and receipt['protocol_success'] is True
    assert receipt['cleanup']['remaining_pids'] == []
    assert load(native / 'protocol-success.json') == {'allTestsPassed': True}
    protocol = (native / 'flutter_driver_commands_0.log').read_text()
    assert '"result":"true","failureDetails":[]' in protocol
    assert receipt['listeners'] == [['tcp', '0100007F', receipt['port_range'][0]]]
    assert receipt['port_range'] == manifest['allocation']
    sources = load(HERE / 'evidence/source-inputs.json')
    for name, digest in receipt['sha256'].items():
        assert sources[name] == digest
    log = gzip.decompress((native / 'driver.log.gz').read_bytes()).decode()
    assert '00:04 +2: All tests passed!' in log or re.search(r'\+2: All tests passed!', log)
    assert '--dart-define=FORCE_GPU_RENDER=true' in receipt['command']

    state = load(native / 'state.json')
    before, after = state['before'], state['after']
    assert before['d'] == after['d'] == 0 and before['bound'] == after['bound'] == 6
    points = {(*point, 0) for point in itertools.product(range(-6, 7), repeat=3)
              if prime(sum(value * value for value in point))}
    assert len(points) == before['pointCount'] == after['pointCount'] == 572
    root = (-6, -6, -5, 0)
    selected = (-6, -5, -6, 0)
    component, queue = {root}, [root]
    for point in queue:
        for candidate in points - component:
            if sum((a - b) ** 2 for a, b in zip(point, candidate)) <= 2:
                component.add(candidate)
                queue.append(candidate)
    assert len(component) == 3
    assert {tuple(p) for p in before['component']} == component
    assert {tuple(p) for p in after['component']} == component
    assert before['path'] == [list(root)] and before['selected'] is None
    assert after['path'] == [list(root), list(selected)] and after['selected'] == list(selected)
    assert (before['yaw'], before['pitch']) == (after['yaw'], after['pitch'])
    assert before['yaw'] != 0 and before['pitch'] != 0

    measured = {}
    for platform in ['native', 'browser']:
        folder = HERE / 'evidence' / platform
        images = {}
        for name in ['before-walk', 'after-walk'] + (['rotated'] if platform == 'browser' else []):
            images[name], measured[f'{platform}/{name}'] = png_metrics(folder / f'{name}.png')
        difference = changed(images['before-walk'], images['after-walk'])
        assert difference == manifest['differences'][f'{platform}_walk_pixels']
        if platform == 'browser':
            assert changed(images['after-walk'], images['rotated']) == manifest['differences']['browser_rotation_pixels']
    assert measured == manifest['pngs']

    browser = HERE / 'evidence/browser'
    server, web = load(browser / 'server.json'), load(browser / 'state.json')
    assert server['exit_code'] == 0 and server['server_closed'] is True
    assert server['foreign_listener_reuse'] is False
    assert server['port_range'] == manifest['allocation']
    assert server['base_url'] == f'http://127.0.0.1:{manifest["allocation"][0] + 11}'
    assert server['environment'] == {'PLAYWRIGHT_SKIP_WEBSERVER': '1',
                                      'PLAYWRIGHT_BASE_URL': server['base_url']}
    assert server['fixture_sha256'] == sources['test/playwright/prime-norm-quaternion.spec.mjs']
    assert server['served_main_dart_js_sha256'] == manifest['builds']['web']['main.dart.js']
    stats = load(browser / 'results.json')['stats']
    assert stats['expected'] == 1 and stats['unexpected'] == stats['skipped'] == stats['flaky'] == 0
    assert web['viewport'] == {'width': 1280, 'height': 900}
    assert web['before']['walk'].startswith('Walk: 0 steps · component 3 · fixed d=0 only')
    assert web['before']['selected'] is None
    assert web['after']['walk'].startswith('Walk: 1 steps · component 3 · fixed d=0 only')
    assert web['after']['selected'] == 'Selected (-6, -5, -6, 0) · norm 97'
    assert web['rotated'] == web['after']
    assert '?type=gaussian_prime_lattice&' in web['url']
    assert web['url'].startswith(server['base_url'])
    for target in re.findall(r'\]\(([^)]+)\)', (HERE / 'README.md').read_text()):
        if '://' not in target:
            assert (HERE / target.split('#')[0]).exists(), target
    print(json.dumps({'pngs': measured, 'differences': manifest['differences'],
                      'native_protocol': True, 'native_remaining_pids': [],
                      'chromium_tests': stats['expected'], 'source_and_artifacts': 'match'}, indent=2))


if __name__ == '__main__':
    verify()
