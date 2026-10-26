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
            self.assertTrue(pidfile.is_file(), result.stderr)
            owned = int(pidfile.read_text())
            with self.assertRaises(ProcessLookupError):
                os.kill(owned, 0)
            self.assertIsNone(foreign.poll(), "unrelated process must survive release cleanup")
            foreign.terminate()
            foreign.wait(timeout=5)


if __name__ == "__main__":
    unittest.main()
