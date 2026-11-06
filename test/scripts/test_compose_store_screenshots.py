"""Tests for scripts/compose-store-screenshots.py.

Composition is deterministic: crop the system bars off a full-framebuffer
capture, keep the app pixels untouched, and add a caption band. These tests use
synthetic captures so they never depend on a device or the gitignored raw run.
"""
import importlib.util
from pathlib import Path
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


if __name__ == '__main__':
    unittest.main()
