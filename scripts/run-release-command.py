#!/usr/bin/env python3
"""Bound one release qualification command and reap only its owned descendants.

A separate Linux subreaper keeps detached browser/native children from escaping a
plain subprocess.run timeout. Existing release HTTP servers are not owned here.
"""
import argparse
import ctypes
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


def snapshot():
    result = {}
    for path in Path('/proc').glob('[0-9]*/stat'):
        try:
            fields = path.read_text().rsplit(')', 1)[1].split()
            result[int(path.parent.name)] = (int(fields[1]), fields[19])
        except (OSError, ValueError, IndexError):
            pass
    return result


def descendants(rows, excluded):
    parents = {os.getpid()}
    found = {}
    while True:
        added = {pid: start for pid, (ppid, start) in rows.items()
                 if ppid in parents and pid not in excluded and pid not in found}
        if not added:
            return found
        found.update(added)
        parents.update(added)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--timeout', required=True, type=float)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    if (sys.platform != 'linux' or not hasattr(os, 'pidfd_open') or
            not hasattr(signal, 'pidfd_send_signal') or not command or not 0 < args.timeout <= 3600):
        parser.error('requires Linux pidfd support, a command and a timeout within (0, 3600]')
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(36, 1, 0, 0, 0) != 0:  # PR_SET_CHILD_SUBREAPER, scoped to this helper.
        raise OSError(ctypes.get_errno(), 'cannot enable release-owned child reaping')
    baseline = set(descendants(snapshot(), set()))
    owned = {}
    interrupted = 0

    def on_signal(number, frame):
        nonlocal interrupted
        interrupted = number
    for number in (signal.SIGINT, signal.SIGTERM):
        signal.signal(number, on_signal)
    process = None
    code = 1
    leaked = False
    try:
        process = subprocess.Popen(command, start_new_session=True)
        deadline = time.monotonic() + args.timeout
        while True:
            owned.update(descendants(snapshot(), baseline))
            status = process.poll()
            if status is not None:
                code = status if status >= 0 else 128 - status
                break
            if interrupted:
                code = 128 + interrupted
                break
            if time.monotonic() >= deadline:
                code = 124
                break
            time.sleep(.05)
    except OSError as error:
        print(f'Release command unavailable: {error}', file=sys.stderr)
    finally:
        if process is not None:
            rows = snapshot()
            owned.update(descendants(rows, baseline))
            leaked = any(pid in rows and rows[pid][1] == start for pid, start in owned.items())
            for sig in (signal.SIGTERM, signal.SIGKILL):
                deadline = time.monotonic() + 5
                signalled = set()
                while True:
                    process.poll()
                    rows = snapshot()
                    owned.update(descendants(rows, baseline))
                    remaining = {pid: start for pid, start in owned.items()
                                 if pid in rows and rows[pid][1] == start}
                    for pid, start in remaining.items():
                        # Start-time identity avoids signalling a recycled foreign PID.
                        if (pid, start) not in signalled:
                            try:
                                fd = os.pidfd_open(pid)
                                try:
                                    current = snapshot().get(pid)
                                    if current and current[1] == start:
                                        signal.pidfd_send_signal(fd, sig)
                                finally:
                                    os.close(fd)
                            except ProcessLookupError:
                                pass
                            signalled.add((pid, start))
                        try:
                            os.waitpid(pid, os.WNOHANG)
                        except ChildProcessError:
                            pass  # Still parented by another owned process.
                    if not remaining or time.monotonic() >= deadline:
                        break
                    time.sleep(.05)
            process.poll()
            rows = snapshot()
            remaining = [pid for pid, start in owned.items() if pid in rows and rows[pid][1] == start]
            if remaining or (code == 0 and leaked):
                code = code or 1
            print(f'Release command cleanup: remaining_pids={remaining}; exit={code}', file=sys.stderr)
    return code


if __name__ == '__main__':
    sys.exit(main())
