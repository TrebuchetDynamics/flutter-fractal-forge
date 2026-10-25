"""Public CLI regressions; the fake replaces only the expensive SDK process."""
import json
import os
from pathlib import Path
import signal
import subprocess
import time

import pytest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/run-native-integration.sh"
TARGET = "integration_test/flows/double_tap_anchor_test.dart"


@pytest.fixture
def driver_env(tmp_path):
    sdk = tmp_path / "sdk"
    (sdk / "bin/cache").mkdir(parents=True)
    (sdk / "bin/cache/flutter.version.json").write_text(
        '{"flutterVersion":"3.44.6","frameworkRevision":"fake"}'
    )
    flutter = sdk / "bin/flutter"
    flutter.write_text("""#!/usr/bin/python3
import json, os, pathlib, signal, subprocess, sys, time
out = pathlib.Path(os.environ['FLUTTER_TEST_OUTPUTS_DIR'])
(out / 'invocation.json').write_text(json.dumps({'args':sys.argv[1:], 'env':dict(os.environ)}))
mode = os.environ.get('FAKE_MODE', 'success')
if mode == 'hang':
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    child = subprocess.Popen(['/usr/bin/sleep', '300'])
    (out / 'child.pid').write_text(str(child.pid))
    while True: time.sleep(.1)
if mode == 'success':
    pathlib.Path(os.environ['NATIVE_INTEGRATION_RESULT']).write_text('{"allTestsPassed":true}')
print('All tests passed.', flush=True)  # App output alone must never qualify.
sys.exit(7 if mode == 'fail' else 0)
""")
    flutter.chmod(0o755)
    xvfb = tmp_path / "xvfb-run"
    xvfb.write_text('#!/bin/bash\nshift 3\nexec "$@"\n')
    xvfb.chmod(0o755)
    env = dict(os.environ, FLUTTER_ROOT=str(sdk), TMPDIR=str(tmp_path),
               AUTOWORK_PORT_BASE=os.environ.get('AUTOWORK_PORT_BASE', '20000'),
               PATH=f"{tmp_path}:/usr/bin:{os.environ['PATH']}")
    return env


def run(env, *args):
    return subprocess.run(["bash", str(SCRIPT), TARGET, *args], env=env,
                          cwd=ROOT, text=True, capture_output=True, timeout=20)


def receipt(env):
    paths = list(Path(env['TMPDIR']).glob('native-integration-*/run.json'))
    assert len(paths) == 1
    return paths[0], json.loads(paths[0].read_text())


@pytest.mark.parametrize('allocation', [None, '', '0', '-1', 'abc', '65500', '20200;true'])
def test_refuses_invalid_allocation_before_launch(driver_env, allocation):
    if allocation is None:
        driver_env.pop('AUTOWORK_PORT_BASE', None)
    else:
        driver_env['AUTOWORK_PORT_BASE'] = allocation
    result = run(driver_env)
    assert result.returncode != 0
    assert 'AUTOWORK_PORT_BASE' in result.stderr
    assert not list(Path(driver_env['TMPDIR']).glob('native-integration-*'))


def test_supported_command_and_private_outputs(driver_env):
    result = run(driver_env, '--dart-define=FORCE_GPU_RENDER=true')
    assert result.returncode == 0, result.stderr
    path, data = receipt(driver_env)
    invocation = json.loads((path.parent / 'outputs/invocation.json').read_text())
    args = invocation['args']
    port = str(int(driver_env['AUTOWORK_PORT_BASE']))
    for arg in ['drive', '-d', 'linux', '--no-pub', '--no-dds', '--no-devtools',
                f'--host-vmservice-port={port}', f'--device-vmservice-port={port}',
                '--dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false',
                '--driver=test_driver/integration_test.dart', f'--target={TARGET}',
                '--dart-define=FORCE_GPU_RENDER=true']:
        assert arg in args
    assert path.parent.stat().st_mode & 0o777 == 0o700
    for key in ['XDG_CONFIG_HOME', 'XDG_CACHE_HOME', 'XDG_DATA_HOME', 'FLUTTER_TEST_OUTPUTS_DIR']:
        assert Path(invocation['env'][key]).is_relative_to(path.parent)
    assert data['protocol_success'] is True
    assert data['cleanup']['remaining_pids'] == []


@pytest.mark.parametrize('mode, code', [('fail', 7), ('missing', 1)])
def test_nonzero_or_missing_protocol_is_not_success(driver_env, mode, code):
    driver_env['FAKE_MODE'] = mode
    result = run(driver_env)
    assert result.returncode == code
    path, data = receipt(driver_env)
    assert 'All tests passed.' in (path.parent / 'driver.log').read_text()
    assert data['exit_code'] == code
    assert data['protocol_success'] is False


@pytest.mark.parametrize('stop', ['timeout', 'signal'])
def test_owned_cleanup_on_timeout_or_signal(driver_env, stop):
    driver_env['FAKE_MODE'] = 'hang'
    unrelated = subprocess.Popen(['/usr/bin/sleep', '300'])
    process = subprocess.Popen(['bash', str(SCRIPT), TARGET, '--timeout',
                                '1' if stop == 'timeout' else '15'],
                               env=driver_env, cwd=ROOT, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, text=True)
    try:
        deadline = time.monotonic() + 10
        while not list(Path(driver_env['TMPDIR']).glob('native-integration-*/outputs/child.pid')):
            assert process.poll() is None
            assert time.monotonic() < deadline
            time.sleep(.02)
        if stop == 'signal':
            process.send_signal(signal.SIGTERM)
        stdout, stderr = process.communicate(timeout=15)
        assert process.returncode == (124 if stop == 'timeout' else 143), (stdout, stderr)
        path, data = receipt(driver_env)
        child = int((path.parent / 'outputs/child.pid').read_text())
        assert not Path(f'/proc/{child}').exists()
        assert data['cleanup']['remaining_pids'] == []
        assert (path.parent / 'driver.log').exists()
        assert unrelated.poll() is None
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
        unrelated.terminate()
        unrelated.wait()
