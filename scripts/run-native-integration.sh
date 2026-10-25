#!/usr/bin/env bash
# Linux-only, supported integration_test host protocol; no SDK modifications.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
exec /usr/bin/python3 - "$@" <<'PY'
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import tempfile
import time

parser = argparse.ArgumentParser(description="Run an existing Linux integration_test with reserved VM ports and owned Xvfb cleanup.",
    epilog="Requires FLUTTER_ROOT (pinned SDK), resolved packages, TMPDIR and AUTOWORK_PORT_BASE. Only --dart-define=KEY=VALUE extras are accepted. Logs/receipt remain in a private TMPDIR/native-integration-* directory; no Number Walls/device qualification is implied.")
parser.add_argument('target', help='existing integration_test/...dart target')
parser.add_argument('--timeout', type=int, default=600, help='whole-run seconds, including build (1..1200; default 600)')
args, defines = parser.parse_known_args()

def refuse(message):
    parser.error(message)

allocation = os.environ.get('AUTOWORK_PORT_BASE', '')
if not re.fullmatch(r'[0-9]{1,5}', allocation) or not 1024 <= int(allocation) <= 65436:
    refuse('AUTOWORK_PORT_BASE must reserve 100 non-privileged ports within 1024..65535')
port = int(allocation)
if not 1 <= args.timeout <= 1200:
    refuse('--timeout must be 1..1200 seconds')
for value in defines:
    if not re.fullmatch(r'--dart-define=[A-Za-z_][A-Za-z_0-9]*=.*', value) or value.startswith('--dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE='):
        refuse('only --dart-define=KEY=VALUE extras are allowed; native reporting is owned by this driver')
root = Path.cwd()
target = (root / args.target).resolve()
if not target.is_relative_to(root / 'integration_test') or not target.is_file() or target.suffix != '.dart':
    refuse('target must be an existing integration_test/...dart in this checkout')
sdk = Path(os.environ.get('FLUTTER_ROOT', '/nonexistent')).resolve()
try:
    version = json.loads((sdk / 'bin/cache/flutter.version.json').read_text())
    if version['flutterVersion'] != (root / 'fdroid/flutter.version').read_text().strip():
        refuse('FLUTTER_ROOT must select the pinned fdroid/flutter.version SDK')
except (OSError, KeyError, ValueError):
    refuse('FLUTTER_ROOT must select the provisioned pinned SDK')
tmp = Path(os.environ.get('TMPDIR', '/nonexistent')).resolve()
if not tmp.is_dir():
    refuse('TMPDIR must be an existing task-private scratch directory')
# Refuse an occupied allocation; never find/kill another application's listener.
with socket.socket() as probe:
    try:
        probe.bind(('127.0.0.1', port))
    except OSError as error:
        refuse(f'reserved VM port {port} unavailable: {error}')

os.umask(0o077)
work = Path(tempfile.mkdtemp(prefix='native-integration-', dir=tmp))
env = dict(os.environ)
for key, directory in [('XDG_CONFIG_HOME', 'config'), ('XDG_CACHE_HOME', 'cache'),
                       ('XDG_DATA_HOME', 'data'), ('XDG_STATE_HOME', 'state'),
                       ('FLUTTER_TEST_OUTPUTS_DIR', 'outputs')]:
    env[key] = str(work / directory)
    Path(env[key]).mkdir()
for key in ['DART_VM_OPTIONS', 'VM_SERVICE_URL']:
    env.pop(key, None)
env['NATIVE_INTEGRATION_RESULT'] = str(work / 'protocol-success.json')
env['TMPDIR'] = str(work)
env['FLUTTER_SUPPRESS_ANALYTICS'] = 'true'
command = [str(sdk / 'bin/flutter'), 'drive', '-d', 'linux', '--debug', '--no-pub',
           '--no-dds', '--no-devtools', '--no-publish-port', '--no-keep-app-running',
           f'--device-vmservice-port={port}', f'--host-vmservice-port={port}',
           '--driver=test_driver/integration_test.dart', f'--target={target.relative_to(root)}',
           '--dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false', *defines]
launch = ['xvfb-run', '-a', '-s', '-screen 0 1280x800x24 -nolisten tcp', *command]
receipt = {'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
           'sha256': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                      for p in [target, root / 'test_driver/integration_test.dart', root / 'scripts/run-native-integration.sh']},
           'sdk': version, 'command': launch, 'port_range': [port, port + 99],
           'listeners': [], 'protocol_success': False}
print(f'Native integration evidence: {work}', flush=True)
# Reap orphaned grandchildren after killing our process group, not host processes.
if ctypes.CDLL(None, use_errno=True).prctl(36, 1, 0, 0, 0) != 0:  # PR_SET_CHILD_SUBREAPER
    raise OSError(ctypes.get_errno(), 'cannot enable owned-child reaping')
interrupted = 0

def on_signal(number, frame):
    global interrupted
    interrupted = number

for number in [signal.SIGINT, signal.SIGTERM]:
    signal.signal(number, on_signal)

def members(group):
    result = []
    for path in Path('/proc').glob('[0-9]*/stat'):
        try:
            fields = path.read_text().rsplit(')', 1)[1].split()
            if int(fields[2]) == group:
                result.append(int(path.parent.name))
        except (OSError, ValueError, IndexError):
            pass  # Process exited during the snapshot.
    return result

def listeners(pids):
    inodes = set()
    for pid in pids:
        for fd in Path(f'/proc/{pid}/fd').glob('*'):
            try:
                link = fd.readlink().as_posix()
                if link.startswith('socket:['):
                    inodes.add(link[8:-1])
            except OSError:
                pass
    found = set()
    for name in ['tcp', 'tcp6']:
        for line in Path(f'/proc/net/{name}').read_text().splitlines()[1:]:
            fields = line.split()
            if fields[3] == '0A' and fields[9] in inodes:
                address, raw_port = fields[1].split(':')
                found.add((name, address, int(raw_port, 16)))
    return found

code = 1
process = None
try:
    with (work / 'driver.log').open('w') as log:
        process = subprocess.Popen(launch, env=env, stdin=subprocess.DEVNULL,
                                   stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        receipt['process_group'] = process.pid
        deadline = time.monotonic() + args.timeout
        observed = set()
        while True:
            observed.update(listeners(members(process.pid)))
            receipt['listeners'] = sorted(observed)
            if any(item != ('tcp', '0100007F', port) for item in observed):
                receipt['reason'] = 'owned listener outside reserved IPv4 loopback VM endpoint'
                break
            if interrupted:
                code = 128 + interrupted
                receipt['reason'] = f'signal {interrupted}'
                break
            if time.monotonic() >= deadline:
                code = 124
                receipt['reason'] = 'whole-run timeout'
                break
            if process.poll() is not None:
                code = process.returncode if process.returncode >= 0 else 128 - process.returncode
                receipt['reason'] = 'driver exited'
                break
            time.sleep(.1)
except OSError as error:
    receipt['reason'] = str(error)
finally:
    if process is not None:
        # The group was created by this invocation; never use pkill/name matching.
        for sig in [signal.SIGTERM, signal.SIGKILL]:
            try:
                os.killpg(process.pid, sig)
            except ProcessLookupError:
                pass
            deadline = time.monotonic() + 2
            while time.monotonic() < deadline:
                process.poll()
                try:
                    while os.waitpid(-1, os.WNOHANG)[0]:
                        pass
                except ChildProcessError:
                    pass
                if not members(process.pid):
                    break
                time.sleep(.05)
        remaining = members(process.pid)
        receipt['cleanup'] = {'remaining_pids': remaining}
        if remaining:
            code = code or 1
    else:
        receipt['cleanup'] = {'remaining_pids': []}
    try:
        receipt['protocol_success'] = json.loads(Path(env['NATIVE_INTEGRATION_RESULT']).read_text()) == {'allTestsPassed': True}
    except (OSError, ValueError):
        pass
    if code == 0 and not receipt['protocol_success']:
        code = 1
        receipt['reason'] = 'missing official integrationDriver success response'
    receipt['exit_code'] = code
    (work / 'run.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(f'Native integration exit {code}; cleanup remaining: {receipt["cleanup"]["remaining_pids"]}', flush=True)
sys.exit(code)
PY
