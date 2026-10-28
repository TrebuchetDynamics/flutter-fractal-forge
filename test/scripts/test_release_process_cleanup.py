"""Exercise release-owned descendants, including detached browser-style children."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "scripts/run-release-command.py"


class ReleaseProcessCleanupTest(unittest.TestCase):
    def test_timeout_reaps_owned_detached_descendant_without_touching_foreign_process(self):
        self._check_cleanup(timeout=True)

    def test_exit_zero_with_leaked_descendant_is_not_a_success(self):
        self._check_cleanup(timeout=False)

    def test_exited_zombie_is_reaped_without_changing_command_verdict(self):
        for command_exit in (0, 7):
            with self.subTest(command_exit=command_exit), tempfile.TemporaryDirectory() as directory:
                pidfile = Path(directory) / 'zombie.pid'
                # Leave an already-exited child for the supervisor's subreaper.
                # Confirm Z from /proc rather than guessing an exit delay.
                code = f'''import os, pathlib, subprocess, sys, time
p = subprocess.Popen([sys.executable, '-c', 'pass'])
pathlib.Path({str(pidfile)!r}).write_text(str(p.pid))
deadline = time.monotonic() + 5
while pathlib.Path(f'/proc/{{p.pid}}/stat').read_text().rsplit(')', 1)[1].split()[0] != 'Z':
    if time.monotonic() >= deadline:
        raise RuntimeError('child did not exit')
    time.sleep(.001)
os._exit({command_exit})
'''
                result = subprocess.run(
                    [sys.executable, str(HELPER), '--timeout', '10', '--',
                     sys.executable, '-c', code], cwd=ROOT,
                    text=True, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, command_exit, result.stdout + result.stderr)
                self.assertIn('"state": "Z"', result.stderr)
                self.assertIn('remaining_pids=[]', result.stderr)
                with self.assertRaises(ProcessLookupError):
                    os.kill(int(pidfile.read_text()), 0)

    def test_zombie_leader_with_live_worker_thread_is_still_a_leak(self):
        leaf = ("import ctypes, threading, time; "
                "threading.Thread(target=lambda: time.sleep(30)).start(); "
                "ctypes.CDLL(None).pthread_exit(None)")
        with tempfile.TemporaryDirectory() as directory:
            pidfile = Path(directory) / 'threaded.pid'
            code = f'''import pathlib, subprocess, sys, time
p = subprocess.Popen([sys.executable, '-c', {leaf!r}], start_new_session=True)
pathlib.Path({str(pidfile)!r}).write_text(str(p.pid))
deadline = time.monotonic() + 5
while pathlib.Path(f'/proc/{{p.pid}}/stat').read_text().rsplit(')', 1)[1].split()[0] != 'Z':
    if time.monotonic() >= deadline:
        p.kill()
        p.wait()
        raise RuntimeError('leader did not exit')
    time.sleep(.001)
states = [(t / 'stat').read_text().rsplit(')', 1)[1].split()[0]
          for t in pathlib.Path(f'/proc/{{p.pid}}/task').iterdir()]
if not any(state != 'Z' for state in states):
    raise RuntimeError('fixture must retain a live worker thread')
'''
            result = subprocess.run(
                [sys.executable, str(HELPER), '--timeout', '10', '--',
                 sys.executable, '-c', code], cwd=ROOT,
                text=True, capture_output=True, timeout=25)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn('"command_exit": 0', result.stderr)
            self.assertIn('"state": "Z"', result.stderr)
            self.assertIn('remaining_pids=[]', result.stderr)
            with self.assertRaises(ProcessLookupError):
                os.kill(int(pidfile.read_text()), 0)

    def _check_cleanup(self, *, timeout):
        with tempfile.TemporaryDirectory() as directory:
            pidfile = Path(directory) / "owned.pid"
            foreign = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"])
            def cleanup_foreign():
                if foreign.poll() is None:
                    foreign.kill()
                foreign.wait(timeout=5)
            self.addCleanup(cleanup_foreign)
            # The leaf has a new session, like a detached browser process.
            code = ("import pathlib,subprocess,sys,time; "
                    "p=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)'],start_new_session=True); "
                    f"pathlib.Path({str(pidfile)!r}).write_text(str(p.pid)); "
                    + ("time.sleep(30)" if timeout else "sys.exit(0)"))
            result = subprocess.run([sys.executable, str(HELPER), "--timeout", "0.5", "--",
                                     sys.executable, "-c", code], cwd=ROOT,
                                    text=True, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 124 if timeout else 1, result.stdout + result.stderr)
            self.assertIn('Release command exit descendants:', result.stderr)
            self.assertTrue(pidfile.is_file(), result.stderr)
            owned = int(pidfile.read_text())
            with self.assertRaises(ProcessLookupError):
                os.kill(owned, 0)
            self.assertIsNone(foreign.poll(), "unrelated process must survive release cleanup")
            foreign.terminate()
            foreign.wait(timeout=5)


if __name__ == "__main__":
    unittest.main()
