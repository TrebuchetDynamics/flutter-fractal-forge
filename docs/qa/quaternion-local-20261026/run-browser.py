#!/usr/bin/env python3
"""Run the quaternion fixture against this checkout's owned fresh web build."""
import functools
import hashlib
import http.server
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import threading
import urllib.request

ROOT = Path(__file__).resolve().parents[3]
OUTPUT = Path(os.environ['QUATERNION_EVIDENCE_DIR']).resolve()
OUTPUT.mkdir(parents=True, exist_ok=True)
ALLOCATION = int(os.environ['AUTOWORK_PORT_BASE'])
PORT = ALLOCATION + 11
BASE = f'http://127.0.0.1:{PORT}'
assert 1024 <= PORT <= 65535
# Refuse a foreign listener. HTTPServer then owns the actual bound socket; no reuse.
with socket.socket() as probe:
    # Match HTTPServer's TIME_WAIT handling; a live listener still refuses bind.
    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    probe.bind(('127.0.0.1', PORT))

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *_):
        pass

server = http.server.ThreadingHTTPServer(
    ('127.0.0.1', PORT), functools.partial(Handler, directory=str(ROOT / 'build/web')))
thread = threading.Thread(target=server.serve_forever)
thread.start()
sha = lambda data: hashlib.sha256(data).hexdigest()
command = ['node', 'node_modules/playwright/cli.js', 'test',
           'test/playwright/prime-norm-quaternion.spec.mjs', '--project=chromium',
           '--workers=1', '--reporter=list,json', f'--output={OUTPUT / "artifacts"}']
env = dict(os.environ, PLAYWRIGHT_SKIP_WEBSERVER='1', PLAYWRIGHT_BASE_URL=BASE,
           PLAYWRIGHT_JSON_OUTPUT_FILE=str(OUTPUT / 'results.json'))
receipt = {'base_url': BASE, 'port_range': [ALLOCATION, ALLOCATION + 99],
           'foreign_listener_reuse': False, 'server_pid': os.getpid(), 'command': command,
           'fixture_sha256': sha((ROOT / 'test/playwright/prime-norm-quaternion.spec.mjs').read_bytes()),
           'environment': {key: env[key] for key in
                           ['PLAYWRIGHT_SKIP_WEBSERVER', 'PLAYWRIGHT_BASE_URL']}}
process = None
try:
    served = urllib.request.urlopen(BASE + '/main.dart.js').read()
    receipt['served_main_dart_js_sha256'] = sha(served)
    assert sha(served) == sha((ROOT / 'build/web/main.dart.js').read_bytes())
    with (OUTPUT / 'playwright.log').open('w') as log:
        process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=log,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        receipt['exit_code'] = process.wait(timeout=240)
finally:
    if process is not None:
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        process.wait(timeout=10)
    server.shutdown()
    server.server_close()
    thread.join()
    receipt['server_closed'] = not thread.is_alive()
    (OUTPUT / 'server.json').write_text(json.dumps(receipt, indent=2) + '\n')
raise SystemExit(receipt.get('exit_code', 1))
