"""Exercise the real web builder validation; replace only the Flutter SDK build."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class WebPreviewBuildTests(unittest.TestCase):
    def build_fixture(self, directory):
        output = directory / 'custom web output'
        shutil.copytree(ROOT / 'web', output)
        index = output / 'index.html'
        index.write_text(index.read_text().replace('$FLUTTER_BASE_HREF', '/'))
        (output / 'main.dart.js').write_text('compiled fixture')
        (output / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}')
        paths = []
        active = False
        for line in (ROOT / 'pubspec.yaml').read_text().splitlines():
            if line == '  shaders:':
                active = True
                continue
            if active and line.startswith('  ') and not line.startswith('    '):
                break
            if active and line.startswith('    - '):
                path = output / 'assets' / line[6:]
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'compiled shader fixture')
                paths.append(path)
        self.assertTrue(paths)
        flutter = directory / 'flutter'
        flutter.write_text('#!/bin/sh\nexit 0\n')
        flutter.chmod(0o755)
        return output, paths, flutter

    def invoke(self, output, flutter, extra_env=None):
        env = {**os.environ, **(extra_env or {}), 'WEB_OUTPUT_DIR': str(output), 'FLUTTER_BIN': str(flutter)}
        return subprocess.run(['bash', str(ROOT / 'scripts/build-web-preview.sh'), '/'],
                              cwd=ROOT, env=env, text=True, capture_output=True, timeout=30)

    def sdk_selection(self, directory):
        tools = directory / 'bin'
        tools.mkdir()
        log = directory / 'selected-sdk'
        for name, marker in [('flutter-reviewed', 'reviewed'), ('flutter', 'fallback')]:
            tool = tools / name
            tool.write_text('#!/bin/sh\nprintf %s ' + marker + ' > "$FLUTTER_SELECTION_LOG"\nexit 0\n')
            tool.chmod(0o755)
        return log, {'PATH': str(tools) + os.pathsep + os.environ.get('PATH', ''),
                     'FLUTTER_SELECTION_LOG': str(log)}

    def test_path_named_flutter_selection_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            output, _, _ = self.build_fixture(directory)
            log, env = self.sdk_selection(directory)
            result = self.invoke(output, 'flutter-reviewed', env)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(log.read_text(), 'reviewed')

    def test_missing_selected_sdk_does_not_silently_use_another_flutter(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            output, _, _ = self.build_fixture(directory)
            log, env = self.sdk_selection(directory)
            result = self.invoke(output, 'flutter-selected-but-missing', env)
            self.assertNotEqual(result.returncode, 0, result.stdout)
            self.assertFalse(log.exists())

    def test_every_declared_shader_path_is_valid_even_outside_the_shaders_directory(self):
        with tempfile.TemporaryDirectory() as temporary:
            output, paths, flutter = self.build_fixture(Path(temporary))
            self.assertTrue(any(not path.is_relative_to(output / 'assets/shaders') for path in paths))
            result = self.invoke(output, flutter)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_unlisted_extra_shaders_cannot_hide_a_missing_declared_shader(self):
        with tempfile.TemporaryDirectory() as temporary:
            output, paths, flutter = self.build_fixture(Path(temporary))
            paths[0].unlink()
            # The old aggregate >=count check passed despite a missing real asset.
            for number in range(3):
                extra = output / f'assets/shaders/extra-{number}.frag'
                extra.parent.mkdir(parents=True, exist_ok=True)
                extra.write_bytes(b'unlisted fixture')
            result = self.invoke(output, flutter)
            self.assertNotEqual(result.returncode, 0, result.stdout)

    def test_repeat_postprocessing_keeps_content_addressed_entrypoints_valid(self):
        with tempfile.TemporaryDirectory() as temporary:
            output, _, flutter = self.build_fixture(Path(temporary))
            first = self.invoke(output, flutter)
            self.assertEqual(first.returncode, 0, first.stdout + first.stderr)
            original = ((output / 'index.html').read_bytes(), (output / 'flutter_bootstrap.js').read_bytes())
            second = self.invoke(output, flutter)
            self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
            self.assertEqual(original, ((output / 'index.html').read_bytes(), (output / 'flutter_bootstrap.js').read_bytes()))


if __name__ == '__main__':
    unittest.main()
