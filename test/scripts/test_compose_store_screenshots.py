"""Tests for scripts/compose-store-screenshots.py.

Composition is deterministic: crop the system bars off a full-framebuffer
capture, keep the app pixels untouched, and add a caption band. These tests use
synthetic captures so they never depend on a device or the gitignored raw run.
"""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import unittest

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location(
    'compose', ROOT / 'scripts' / 'compose-store-screenshots.py')
compose = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compose)


def write_capture(path, size, colour):
    image = Image.new('RGB', size, colour)
    # A distinct colour in the app strip proves the crop keeps the right pixels.
    image.paste((10, 200, 30), (0, 200, size[0], size[1] - 200))
    image.save(path)
    return path


class ComposeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def campaign(self, root):
        for profile, (size, slides) in compose.CAMPAIGNS.items():
            folder = root / 'raw' / profile
            folder.mkdir(parents=True)
            for _, name, *_ in slides:
                write_capture(folder / f'{name}.png',
                              tuple(map(int, size.split('x'))), (4, 5, 6))
        return root / 'raw', root / 'out', root / 'manifest.json'

    def cli(self, raw, out, manifest):
        return subprocess.run(
            [sys.executable, str(Path(compose.__file__)), '--raw', str(raw),
             '--out', str(out), '--manifest', str(manifest)],
            capture_output=True, text=True, timeout=30)

    def snapshot(self, root):
        tree = {}
        for path in root.rglob('*'):
            mode = path.lstat().st_mode
            content = (os.readlink(path) if stat.S_ISLNK(mode) else
                       path.read_bytes() if stat.S_ISREG(mode) else None)
            tree[str(path.relative_to(root))] = (mode, content)
        return tree

    def assert_refused(self, root, raw, out, manifest, conflict):
        before = self.snapshot(root)
        result = self.cli(raw, out, manifest)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn(str(conflict), result.stderr)
        self.assertEqual(self.snapshot(root), before, result.stderr)

    def test_cli_preflights_all_inputs_before_any_writes(self):
        cases = [('phone', '02-julia', 'missing')]
        cases += [(profile, compose.CAMPAIGNS[profile][1][-1][1], problem)
                  for profile in compose.CAMPAIGNS
                  for problem in ('missing', 'undecodable', 'wrong-class')]
        for index, (profile, name, problem) in enumerate(cases):
            for prior in (False, True):
                with self.subTest(profile=profile, problem=problem, prior=prior):
                    root = self.root / f'{index}-{prior}'
                    raw, out, manifest = self.campaign(root)
                    if prior:
                        (out / 'phone').mkdir(parents=True)
                        (out / 'phone/01-mandelbrot.png').write_bytes(b'prior image')
                        manifest.write_bytes(b'prior manifest')
                    bad = raw / profile / f'{name}.png'
                    if problem == 'missing':
                        bad.unlink()
                    elif problem == 'undecodable':
                        bad.write_bytes(b'not an image')
                    else:
                        write_capture(bad, (320, 480), (1, 2, 3))
                    self.assert_refused(root, raw, out, manifest, bad)

    def test_cli_rejects_raw_aliases_and_destination_collisions(self):
        cases = ('manifest-raw', 'manifest-resolved', 'manifest-symlink',
                 'manifest-hardlink', 'image-hardlink', 'image-symlink',
                 'out-raw', 'out-symlink', 'manifest-image',
                 'manifest-image-symlink', 'manifest-image-hardlink',
                 'image-image-symlink', 'image-image-hardlink', 'manifest-parent')
        for case in cases:
            with self.subTest(case=case):
                root = self.root / case
                raw, out, manifest = self.campaign(root)
                source = raw / 'phone/01-mandelbrot.png'
                first = out / 'phone/01-mandelbrot.png'
                late = out / 'tablet/04-julia.png'
                first.parent.mkdir(parents=True)
                late.parent.mkdir(parents=True)
                first.write_bytes(b'prior image')
                manifest.write_bytes(b'prior manifest')
                conflict = source
                if case == 'manifest-raw':
                    manifest = source
                elif case == 'manifest-resolved':
                    manifest = source.parent / '..' / 'phone' / source.name
                elif case.startswith('manifest-') and case.split('-')[-1] in ('symlink', 'hardlink') and 'image' not in case:
                    manifest.unlink()
                    (manifest.symlink_to if case.endswith('symlink') else manifest.hardlink_to)(source)
                elif case.startswith('image-') and 'image-image' not in case:
                    first.unlink()
                    (first.symlink_to if case.endswith('symlink') else first.hardlink_to)(source)
                elif case.startswith('out-'):
                    if case == 'out-raw':
                        out = raw
                    else:
                        out = root / 'alias'
                        out.symlink_to(raw, target_is_directory=True)
                else:
                    conflict = first
                    if case == 'manifest-image':
                        manifest = first
                    elif case == 'manifest-parent':
                        manifest = out / 'phone'
                        conflict = manifest
                    else:
                        target = manifest if case.startswith('manifest') else late
                        if target.exists():
                            target.unlink()
                        (target.symlink_to if case.endswith('symlink') else target.hardlink_to)(first)
                hashes = {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in raw.rglob('*.png')}
                self.assert_refused(root, raw, out, manifest, conflict)
                self.assertEqual(hashes, {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in hashes})

    def test_cli_rejects_nonregular_destinations_without_opening_them(self):
        for kind in ('directory', 'fifo', 'parent-file', 'dangling-parent', 'manifest-fifo'):
            with self.subTest(kind=kind):
                root = self.root / kind
                raw, out, manifest = self.campaign(root)
                (out / 'phone').mkdir(parents=True)
                (out / 'phone/01-mandelbrot.png').write_bytes(b'prior image')
                conflict = out / 'tablet/04-julia.png'
                conflict.parent.mkdir()
                if kind == 'directory':
                    conflict.mkdir()
                elif kind == 'fifo':
                    os.mkfifo(conflict)
                elif kind == 'manifest-fifo':
                    conflict = manifest
                    os.mkfifo(conflict)
                else:
                    conflict.parent.rmdir()
                    conflict = conflict.parent
                    if kind == 'dangling-parent':
                        conflict.symlink_to(root / 'missing')
                    else:
                        conflict.write_bytes(b'not a directory')
                self.assert_refused(root, raw, out, manifest, conflict)

    def test_cli_fresh_and_repeat_preserve_pixels_and_manifest(self):
        raw, out, manifest = self.campaign(self.root)
        originals = self.snapshot(raw)
        for _ in range(2):
            result = self.cli(raw, out, manifest)
            self.assertEqual(result.returncode, 0, result.stderr)
            groups = json.loads(manifest.read_text())['groups']
            self.assertEqual(list(groups), list(compose.CAMPAIGNS))
            for profile, entries in groups.items():
                self.assertEqual(len(entries), len(compose.CAMPAIGNS[profile][1]))
                for entry, (name, raw_name, kicker, headline) in zip(entries, compose.CAMPAIGNS[profile][1]):
                    self.assertEqual(set(entry), {'file', 'raw', 'raw_sha256', 'kicker', 'headline', 'size', 'app_pixels', 'sha256'})
                    self.assertEqual(Path(entry['file']), out / profile / f'{name}.png')
                    self.assertEqual(Path(entry['raw']), raw / profile / f'{raw_name}.png')
                    self.assertEqual((entry['kicker'], entry['headline']), (kicker, headline))
                    for field, digest in [('raw', 'raw_sha256'), ('file', 'sha256')]:
                        self.assertEqual(entry[digest], hashlib.sha256(Path(entry[field]).read_bytes()).hexdigest())
                    settings = compose.PROFILES[profile]
                    with Image.open(entry['raw']) as source, Image.open(entry['file']) as delivered:
                        app = source.crop((0, settings['crop_top'], source.width, source.height - settings['crop_bottom']))
                        self.assertEqual(entry['app_pixels'], list(app.size))
                        self.assertEqual(entry['size'], list(delivered.size))
                        self.assertEqual(delivered.size, (app.width, app.height + settings['band']))
                        self.assertEqual(delivered.crop((0, settings['band'], delivered.width, delivered.height)).tobytes(), app.tobytes())
            self.assertEqual(self.snapshot(raw), originals)

    def test_phone_capture_is_trimmed_and_captioned(self):
        raw = write_capture(self.root / 'raw.png', (1080, 1920), (1, 2, 3))
        canvas, app_size = compose.compose_capture(
            raw, 'KICKER', 'Headline', 'phone')
        profile = compose.PROFILES['phone']
        self.assertEqual(canvas.size, (1080, 1920 - profile['crop_top'] - profile['crop_bottom'] + profile['band']))
        self.assertEqual(canvas.mode, 'RGB')
        self.assertEqual(app_size, (1080, 1920 - profile['crop_top'] - profile['crop_bottom']))
        # The app strip keeps its original pixels under the band.
        self.assertEqual(canvas.getpixel((540, profile['band'] + 100)), (1, 2, 3))
        self.assertEqual(canvas.getpixel((540, 10)), compose.BAND)

    def test_tablet_capture_uses_tablet_profile(self):
        raw = write_capture(self.root / 'raw.png', (1600, 2560), (1, 2, 3))
        canvas, _ = compose.compose_capture(raw, 'KICKER', 'Headline', 'tablet')
        self.assertEqual(canvas.size[0], 1600)
        self.assertEqual(canvas.size[1] > 2560, True)

    def test_rejects_capture_from_the_wrong_class(self):
        raw = write_capture(self.root / 'raw.png', (1600, 2560), (1, 2, 3))
        with self.assertRaisesRegex(ValueError, 'expected 1080x1920'):
            compose.compose_capture(raw, 'KICKER', 'Headline', 'phone')

    def test_composed_ratio_stays_inside_play_limits(self):
        for profile in compose.PROFILES:
            width = int(compose.CAMPAIGNS[profile][0].split('x')[0])
            height = int(compose.CAMPAIGNS[profile][0].split('x')[1])
            raw = write_capture(self.root / 'raw.png', (width, height), (1, 2, 3))
            canvas, _ = compose.compose_capture(raw, 'KICKER', 'Headline', profile)
            long_side, short_side = max(canvas.size), min(canvas.size)
            self.assertLessEqual(long_side, 3840)
            self.assertGreaterEqual(short_side, 320)
            self.assertLessEqual(long_side, 2 * short_side)

    def test_long_headline_shrinks_or_wraps_within_the_band(self):
        raw = write_capture(self.root / 'raw.png', (1080, 1920), (1, 2, 3))
        canvas, _ = compose.compose_capture(
            raw, 'DEEP ZOOM', 'Rotate a mathematical object slowly', 'phone')
        self.assertEqual(canvas.size[0], 1080)

    def test_manifest_records_raw_and_output_digests(self):
        profile = 'phone'
        raw_dir = self.root / 'raw' / profile
        raw_dir.mkdir(parents=True)
        for _, raw_name, _, _ in compose.CAMPAIGNS[profile][1]:
            write_capture(raw_dir / f'{raw_name}.png', (1080, 1920), (4, 5, 6))
        out = self.root / 'out'
        entries = compose.compose_campaign(self.root / 'raw', out, profile)
        self.assertEqual(len(entries), len(compose.CAMPAIGNS[profile][1]))
        for entry in entries:
            self.assertTrue((ROOT / entry['file']).exists() or Path(entry['file']).exists())
            self.assertEqual(len(entry['raw_sha256']), 64)
            self.assertEqual(len(entry['sha256']), 64)
            self.assertEqual(Path(entry['file']).name, entry['file'].split('/')[-1])
        produced = sorted(p.name for p in (out / profile).glob('*.png'))
        self.assertEqual(produced, sorted(name + '.png' for name, *_ in compose.CAMPAIGNS[profile][1]))
        late = raw_dir / f'{compose.CAMPAIGNS[profile][1][-1][1]}.png'
        for problem in ('missing', 'raw-alias'):
            with self.subTest(problem=problem):
                if problem == 'missing':
                    late.unlink()
                else:
                    write_capture(late, (1080, 1920), (4, 5, 6))
                    first = out / profile / '01-mandelbrot.png'
                    first.unlink()
                    first.hardlink_to(raw_dir / '01-mandelbrot.png')
                before = self.snapshot(self.root)
                with self.assertRaises(ValueError):
                    compose.compose_campaign(self.root / 'raw', out, profile)
                self.assertEqual(self.snapshot(self.root), before)


if __name__ == '__main__':
    unittest.main()
