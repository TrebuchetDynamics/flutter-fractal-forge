#!/usr/bin/env python3
"""Read-only, standard-library reconciliation of the retained local evidence."""
import hashlib
import json
import math
from pathlib import Path
import re
import struct
import zlib

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_tree():
    digest = hashlib.sha256()
    for folder in ['lib', 'shaders']:
        for path in sorted((ROOT / folder).rglob('*')):
            if path.is_file():
                digest.update(f'{path.relative_to(ROOT)}\0{sha(path)}\n'.encode())
    return digest.hexdigest()


def decode_png(path):
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    pos, compressed, header = 8, bytearray(), None
    while pos < len(data):
        size = struct.unpack_from('>I', data, pos)[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + size]
        assert zlib.crc32(kind + body) == struct.unpack_from('>I', data, pos + 8 + size)[0]
        if kind == b'IHDR':
            header = struct.unpack('>IIBBBBB', body)
        elif kind == b'IDAT':
            compressed.extend(body)
        pos += size + 12
        if kind == b'IEND':
            break
    assert pos == len(data)
    w, h, depth, color, compression, filtering, interlace = header
    assert (depth, color, compression, filtering, interlace) == (8, 6, 0, 0, 0)
    raw = zlib.decompress(compressed)
    stride = w * 4
    assert len(raw) == (stride + 1) * h
    result, previous = bytearray(), bytearray(stride)
    for y in range(h):
        offset = y * (stride + 1)
        method, row = raw[offset], bytearray(raw[offset + 1:offset + 1 + stride])
        assert method in range(5)
        for i in range(stride):
            a = row[i - 4] if i >= 4 else 0
            b = previous[i]
            c = previous[i - 4] if i >= 4 else 0
            p = a + b - c
            distances = [abs(p - a), abs(p - b), abs(p - c)]
            paeth = [a, b, c][distances.index(min(distances))]
            row[i] = (row[i] + [0, a, b, (a + b) // 2, paeth][method]) % 256
        result.extend(row)
        previous = row
    return w, h, result


def prime(n):
    return n >= 2 and all(n % d for d in range(2, math.isqrt(n) + 1))


def field(bound):
    return {(a, b) for a in range(-bound, bound + 1)
            for b in range(-bound, bound + 1)
            if (prime(a*a + b*b) if a and b else
                prime(abs(a or b)) and abs(a or b) % 4 == 3)}


def component(points, radius):
    found, queue = {(1, 1)}, [(1, 1)]
    offsets = [(a, b) for a in range(-4, 5) for b in range(-4, 5)
               if 0 < a*a + b*b <= radius]
    for a, b in queue:
        for da, db in offsets:
            point = a + da, b + db
            if point in points and point not in found:
                found.add(point)
                queue.append(point)
    return found


def main():
    manifest = json.loads((HERE / 'manifest.json').read_text())
    links = re.findall(r'\]\(([^)]+)\)', (HERE / 'README.md').read_text())
    for link in links:
        target = link.split('#')[0]
        if target and not target.startswith(('https://', 'http://')):
            assert (HERE / target).is_file(), link
    for path in (HERE / 'evidence').glob('*.json'):
        json.loads(path.read_text())
    for path, expected in manifest['sources'].items():
        assert sha(ROOT / path) == expected, path
    assert source_tree() == manifest['lib_shaders_tree_sha256']
    for path, expected in manifest['artifacts'].items():
        assert sha(HERE / path) == expected, path
    receipt = json.loads((HERE / 'evidence/run.json').read_text())
    assert receipt['exit_code'] == 0 and receipt['protocol_success'] is True
    assert receipt['cleanup']['remaining_pids'] == []
    assert receipt['port_range'] == [20200, 20299]
    assert receipt['listeners'] == [['tcp', '0100007F', 20200]]
    for path, expected in receipt['sha256'].items():
        assert manifest['sources'][path] == expected
    assert json.loads((HERE / 'evidence/protocol-success.json').read_text()) == {'allTestsPassed': True}

    states = json.loads((HERE / 'evidence/state.json').read_text())
    assert states['export_state_equivalent'] and states['paused_after_1300ms_equivalent']
    assert states['dimensions'] == [1280, 720]
    points = field(32)
    for name, radius in [('pre_walk', 4), ('paused_growth', 8)]:
        state = states[name]
        assert state['bound'] == 32 and state['point_count'] == len(points) == 868
        assert state['squared_step'] == radius and state['playing'] is False
        assert state['root'] == [1, 1]
        assert set(map(tuple, state['component'])) == component(points, radius)
    assert states['pre_walk']['path'] == [[1, 1]]
    assert states['pre_walk']['candidate'] is None
    assert states['paused_growth']['path'] == [[1, 1], [1, -1]]
    assert states['paused_growth']['candidate'] == [1, -1]

    telemetry = json.loads((HERE / 'evidence/telemetry.json').read_text())
    cap = field(128)
    assert telemetry['bound'] == 128 and telemetry['point_count'] == len(cap) == 9476
    for search in telemetry['searches']:
        assert search['component_size'] == len(component(cap, search['squared_step']))
    limit = 2 * 128**2
    expected_probes = 257**2 + math.isqrt(limit) - 1 + sum(
        (limit - p*p) // p + 1 for p in range(2, math.isqrt(limit) + 1) if prime(p))
    assert expected_probes == 126000
    chunks = telemetry['chunks']
    assert sum(c['probes'] for c in chunks) == expected_probes
    for chunk in chunks[:-1]:
        assert chunk['yielded'] and 0 < chunk['probes'] <= 1024
        assert chunk['probes'] == 1024 or chunk['elapsed_us'] >= 8000
    assert not chunks[-1]['yielded'] and chunks[-1]['probes'] < 1024
    assert len(telemetry['yield_wait_us']) == len(chunks) - 1
    assert telemetry['cancelled_publications'] == [] and telemetry['cancellation_yields'] == 1
    assert telemetry['backend_probe']['exit_code'] == 0
    assert 'llvmpipe' in telemetry['backend_probe']['stdout']

    before_w, before_h, before = decode_png(HERE / 'evidence/pre-walk.png')
    after_w, after_h, after = decode_png(HERE / 'evidence/paused-growth.png')
    assert (before_w, before_h, after_w, after_h) == (1280, 720, 1280, 720)
    assert all(before[i] == after[i] == 255 for i in range(3, len(before), 4))
    changed = sum(before[i:i+4] != after[i:i+4] for i in range(0, len(before), 4))
    assert changed > 0
    summary = {
        'png_dimensions': [1280, 720], 'changed_rgba_pixels': changed,
        'pre_walk_component': 632, 'paused_growth_component': 824,
        'cap_points': len(cap), 'probes': expected_probes, 'yields': len(chunks) - 1,
        'max_chunk_us': max(c['elapsed_us'] for c in chunks),
        'max_chunk_overshoot_above_8ms_us': max(0, max(c['elapsed_us'] for c in chunks) - 8000),
        'max_zero_timer_wait_us': max(telemetry['yield_wait_us']),
        'source_state_telemetry_protocol_cleanup': 'pass',
        'local_doc_links_checked': len(links),
    }
    assert summary == manifest['verification_summary']
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
