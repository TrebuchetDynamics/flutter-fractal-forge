#!/usr/bin/env python3
"""Read back the source-bound QUAL-EXPORT-REPAIR-01 packet; never launch an app."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

from PIL import Image

packet = Path(__file__).resolve().parent
root = packet.parents[2]
evidence = packet / 'evidence'
manifest = json.loads((packet / 'manifest.json').read_text())


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def unpack(path):
    return gzip.decompress(path.read_bytes())


for name, expected in manifest['files'].items():
    path = evidence / name
    assert path.stat().st_size == expected['bytes'], name
    assert sha(path) == expected['sha256'], name
    if 'uncompressed_sha256' in expected:
        assert hashlib.sha256(unpack(path)).hexdigest() == expected['uncompressed_sha256'], name

inputs = json.loads((evidence / 'source-inputs.json').read_text())
assert inputs['baseline'] == manifest['source_baseline']
for name, expected in inputs['files'].items():
    assert sha(root / name) == expected, f'tested source drift: {name}'
code_paths = ['integration_test/helpers/ui_test_helpers.dart',
              'test/fractal/fractal_catalog_screen_widget_test.dart']
patch = subprocess.check_output(
    ['git', 'diff', inputs['baseline'], '--', *code_paths], cwd=root)
assert patch == unpack(evidence / 'candidate.patch.gz')
fixture = 'integration_test/flows/user_flows_test.dart'
baseline_fixture = subprocess.check_output(
    ['git', 'show', f'{inputs["baseline"]}:{fixture}'], cwd=root)
assert hashlib.sha256(baseline_fixture).hexdigest() == inputs['files'][fixture]

for phase, expected_exit, success in [('before', 1, False), ('after', 0, True)]:
    receipt = json.loads((evidence / phase / 'run.json').read_text())
    assert receipt['revision'] == inputs['baseline']
    assert receipt['exit_code'] == expected_exit
    assert receipt['protocol_success'] is success
    assert receipt['cleanup']['remaining_pids'] == []
    assert receipt['port_range'] == [20200, 20299]
    assert receipt['listeners'] == [['tcp', '0100007F', 20200]]
    assert receipt['sdk']['flutterVersion'] == '3.44.6'
    assert receipt['sdk']['dartSdkVersion'] == '3.12.2'
    for name, expected in receipt['sha256'].items():
        assert sha(root / name) == expected, name
assert json.loads((evidence / 'after/protocol-success.json').read_text()) == {
    'allTestsPassed': True}
terminal = (evidence / 'after/outputs/flutter_driver_commands_0.log.txt').read_text()
assert '{"result":"true","failureDetails":[]}' in terminal
before = unpack(evidence / 'before/driver.log.txt.gz').decode()
assert 'after requested=Mandelbulb text=Mandelbrot focus=false bindingSame=true' in before
red = unpack(evidence / 'regression-red-native-input.log.txt.gz').decode()
assert "Expected: 'Mandelbulb'" in red and "Actual: 'Mandelbrot'" in red

runtime = json.loads((evidence / 'runtime-observations.json').read_text())
assert runtime['exit_code'] == 0 and len(runtime['applications']) == 1
application = runtime['applications'][0]
assert application['glxinfo_exit_code'] == 0
assert any('libflutter_linux_gtk.so' in p for p in application['mapped_files'])
gl = unpack(evidence / f'after/app-{application["pid"]}-glxinfo.txt.gz').decode()
assert 'llvmpipe (LLVM 20.1.2, 256 bits)' in gl and 'Accelerated: no' in gl

assert {a['module'] for a in manifest['artifacts']} == {'mandelbrot', 'mandelbulb'}
for artifact in manifest['artifacts']:
    with Image.open(evidence / artifact['path']) as image:
        image.load()
        assert list(image.size) == artifact['dimensions'] == [1280, 720]
        rgba = image.convert('RGBA')
        assert hashlib.sha256(rgba.tobytes()).hexdigest() == artifact['decoded_rgba_sha256']
        samples = [rgba.getpixel((x, y)) for y in range(0, 720, 4) for x in range(0, 1280, 4)]
        colors = len({p[:3] for p in samples})
        assert colors == artifact['sample_distinct_rgb'] and colors > 16
        assert len(samples) == artifact['sample_count'] == 57600
        assert sum(p[:3] != (0, 0, 0) for p in samples) == artifact['sample_nonblack']
        assert list(rgba.getchannel('A').getextrema()) == artifact['alpha_extrema'] == [255, 255]
    state = json.loads((evidence / artifact['state_path']).read_text())
    assert state == artifact['state']
    assert state['viewport'] == [1280, 900]
    assert state['preset']['moduleId'] == artifact['module']
    print(f'{artifact["module"]}: 1280x720; {colors} sampled RGB colors; PNG/state/hash verified')

for target in re.findall(r'\]\(([^)]+)\)', (packet / 'README.md').read_text()):
    if '://' not in target:
        assert (packet / target.split('#')[0]).exists(), target
print(f'PASS: {len(manifest["files"])} retained files; {len(inputs["files"])} source inputs; '
      'official success; allocated listener; empty cleanup; README links')
