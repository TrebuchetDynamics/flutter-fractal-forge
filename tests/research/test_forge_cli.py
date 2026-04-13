import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
FORGE = REPO_ROOT / "scripts" / "research" / "forge.py"


def _run(*args):
    return subprocess.run(
        [sys.executable, str(FORGE), *args],
        capture_output=True,
        text=True,
        cwd=REPO_ROOT,
    )


def test_forge_help_succeeds():
    result = _run("--help")
    assert result.returncode == 0
    assert "forge" in result.stdout.lower()


def test_forge_lists_subcommands():
    result = _run("--help")
    for subcommand in ("doctor", "retrofit"):
        assert subcommand in result.stdout


def test_forge_unknown_subcommand_errors():
    result = _run("nonexistent")
    assert result.returncode != 0
