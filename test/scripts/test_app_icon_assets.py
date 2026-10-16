"""Synthetic fixtures test derivation, never evidence of a genuine app capture."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts/prepare_app_icon.py'
OUTPUTS = {
    'ic_launcher.png': (1024, 'RGB'),
    'ic_launcher_foreground.png': (1024, 'RGBA'),
    'ic_launcher_512.png': (512, 'RGBA'),
    'logo_64.png': (64, 'RGB'),
    'fractal-forge-icon.png': (1024, 'RGB'),
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class IconAssetsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'synthetic.png'
        image = Image.new('RGB', (2048, 2048), '#182332')
        draw = ImageDraw.Draw(image)
        draw.rectangle((127, 257, 1100, 1500), fill='#f091ce')
        draw.ellipse((800, 500, 1900, 1700), fill='#28e8d0')
        image.save(self.source)
        self.state = self.root / 'synthetic.json'
        self.receipt = {
            'moduleId': 'f0186_zig_zag_julia',
            'shaderAsset': 'shaders/escape_time_family/core/julia_gpu.frag',
            'width': 2048, 'height': 2048, 'time': 0,
            'animationEnabled': False,
            'params': {'cReal': -0.39054, 'cImag': -0.58679},
            'view': {'panX': 0, 'panY': 0, 'zoom': 1.25},
            'capture': 'FractalRenderer RepaintBoundary.toImage(pixelRatio: 1)',
            'fixtureOnly': True,
        }
        self.state.write_text(json.dumps(self.receipt))
        self.output = self.root / 'staged'

    def run_cli(self, output=None, rotated=False):
        return subprocess.run(
            [sys.executable, str(SCRIPT), '--source', str(self.source),
             '--state', str(self.state), '--output', str(output or self.output)]
            + (['--rotate-clockwise-45'] if rotated else []),
            capture_output=True, text=True,
        )

    def check_assets(self, output):
        manifest = json.loads((output / 'fractal-forge-icon-source.json').read_text())
        self.assertEqual(manifest['source']['sha256'], digest(output / 'source.png'))
        self.assertEqual(manifest['source']['path'], 'source.png')
        self.assertEqual(manifest['sourceState'], json.loads((output / 'source-state.json').read_text()))
        self.assertEqual(manifest['sourceStateSha256'], digest(output / 'source-state.json'))
        with Image.open(output / 'source.png') as raw:
            self.assertEqual(raw.size, (2048, 2048))
            self.assertEqual(raw.convert('RGBA').getchannel('A').getextrema(), (255, 255))
            source = raw.convert('RGB')
        rotated = manifest['recipe'].get('rotationDegreesCounterclockwise', 0) == -45
        if rotated:
            expanded = source.convert('RGBA').rotate(-45, Image.Resampling.BICUBIC, expand=True)
            source = expanded.crop((727, 727, 2171, 2171)).convert('RGB')
        self.assertEqual(manifest['androidBackgroundHex'], '#%02x%02x%02x' % source.getpixel((0, 0)))
        for name, (size, mode) in OUTPUTS.items():
            with self.subTest(output=name), Image.open(output / name) as image:
                self.assertEqual(image.size, (size, size))
                self.assertEqual(image.mode, mode)
                self.assertEqual(image.convert('RGBA').getchannel('A').getextrema(), (255, 255))
                expected = source.resize((size, size), Image.Resampling.LANCZOS).convert(mode)
                self.assertEqual(image.tobytes(), expected.tobytes())
                if name == 'ic_launcher_512.png':
                    self.assertLessEqual((output / name).stat().st_size, 1024 * 1024)
                    try:
                        from PIL import ImageCms
                    except ImportError:
                        self.assertEqual(image.info.get('srgb'), 0)
                    else:
                        self.assertTrue(image.info.get('icc_profile'))
                self.assertEqual(manifest['outputs'][name]['sha256'], digest(output / name))
        with Image.open(output / 'proof.png') as proof:
            self.assertEqual(proof.size, (2304, 2656))
            for row, background in enumerate(('#f5f5f5', '#171717')):
                for column, size in enumerate((32, 48, 64, 512)):
                    x = column * 576 + 24
                    y = row * 616 + (64 if size == 512 else 56)
                    expected = source.resize((size, size), Image.Resampling.LANCZOS)
                    self.assertEqual(proof.crop((x, y, x + size, y + size)).tobytes(), expected.tobytes())
                for column in (1, 2, 3):
                    x, y = column * 576 + 24, 1424 + row * 616 + 56
                    self.assertEqual(proof.getpixel((x, y)), Image.new('RGB', (1, 1), background).getpixel((0, 0)))
                    self.assertEqual(proof.getpixel((x + 256, y + 256)), source.resize((512, 512), Image.Resampling.LANCZOS).getpixel((256, 256)))
        self.assertEqual(manifest['outputs']['proof.png']['sha256'], digest(output / 'proof.png'))
        self.assertEqual(manifest['recipe']['crop'], [727, 727, 2171, 2171] if rotated else [0, 0, 2048, 2048])
        self.assertEqual(manifest['recipe']['resampling'], 'Pillow LANCZOS')

    def test_installed_brand_assets_match_app_capture_and_platform_references(self):
        manifest = json.loads((ROOT / 'assets/fractal-forge-icon-source.json').read_text())
        source_path = ROOT / manifest['source']['path']
        self.assertEqual(digest(source_path), manifest['source']['sha256'])
        self.assertEqual(json.loads((ROOT / manifest['sourceStatePath']).read_text()), manifest['sourceState'])
        with Image.open(source_path) as raw:
            self.assertEqual(raw.size, (2048, 2048))
            source = raw.convert('RGBA').rotate(-45, Image.Resampling.BICUBIC, expand=True)
            source = source.crop((727, 727, 2171, 2171)).convert('RGB')
        for name, (size, mode) in OUTPUTS.items():
            path = ROOT / 'assets/icon' / name
            with self.subTest(asset=name), Image.open(path) as actual:
                self.assertEqual(actual.size, (size, size))
                self.assertEqual(actual.mode, mode)
                self.assertEqual(actual.convert('RGBA').getchannel('A').getextrema(), (255, 255))
                self.assertEqual(actual.tobytes(), source.resize((size, size), Image.Resampling.LANCZOS).convert(mode).tobytes())
                self.assertEqual(digest(path), manifest['outputs']['assets/icon/' + name]['sha256'])
        self.assertEqual(manifest['sourceState']['params']['juliaCReal'], -0.8)
        self.assertEqual(manifest['sourceState']['params']['juliaCImag'], 0.156)
        for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
            with Image.open(ROOT / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png') as icon:
                self.assertEqual(icon.size, (size, size))
        for directory in ['ios/Runner/Assets.xcassets/AppIcon.appiconset', 'macos/Runner/Assets.xcassets/AppIcon.appiconset']:
            contents = json.loads((ROOT / directory / 'Contents.json').read_text())
            for entry in contents['images']:
                if entry.get('filename'):
                    self.assertTrue((ROOT / directory / entry['filename']).is_file())
        for name in ['web/favicon.png', 'web/icons/Icon-192.png', 'web/icons/Icon-512.png', 'web/icons/Icon-maskable-192.png', 'web/icons/Icon-maskable-512.png', 'windows/runner/resources/app_icon.ico']:
            self.assertTrue((ROOT / name).is_file(), name)
        config = (ROOT / 'pubspec.yaml').read_text()
        self.assertIn('adaptive_icon_background: "#f300d3"', config)
        import xml.etree.ElementTree as ET
        colors = ET.parse(ROOT / 'android/app/src/main/res/values/colors.xml')
        self.assertEqual(colors.find("color[@name='ic_launcher_background']").text.lower(), '#f300d3')

    def test_cli_derives_full_image_and_preserves_hash_lineage(self):
        result = self.run_cli()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.check_assets(self.output)
        self.assertEqual((self.output / 'source.png').read_bytes(), self.source.read_bytes())
        self.assertEqual((self.output / 'source-state.json').read_bytes(), self.state.read_bytes())

    def assert_rejected(self):
        result = self.run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('error:', result.stderr)
        self.assertFalse(self.output.exists(), 'invalid inputs must not create outputs')

    def test_rotated_candidate_preserves_raw_source_and_has_no_filled_corners(self):
        result = self.run_cli(rotated=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.check_assets(self.output)
        self.assertEqual((self.output / 'source.png').read_bytes(), self.source.read_bytes())
        manifest = json.loads((self.output / 'fractal-forge-icon-source.json').read_text())
        self.assertEqual(manifest['recipe']['rotationDegreesCounterclockwise'], -45)
        self.assertEqual(manifest['recipe']['workingSize'], [1444, 1444])

    def test_reject_wrong_source_size(self):
        Image.new('RGB', (512, 512)).save(self.source)
        self.assert_rejected()

    def test_reject_transparent_source(self):
        image = Image.new('RGBA', (2048, 2048), (1, 2, 3, 255))
        image.putpixel((1900, 1800), (1, 2, 3, 254))
        image.save(self.source)
        self.assert_rejected()

    def test_reject_wrong_module(self):
        self.receipt['moduleId'] = 'another_module'
        self.state.write_text(json.dumps(self.receipt))
        self.assert_rejected()

    def test_reject_missing_state(self):
        self.state.unlink()
        self.assert_rejected()

    def test_reject_nonzero_time(self):
        self.receipt['time'] = 0.01
        self.state.write_text(json.dumps(self.receipt))
        self.assert_rejected()

    def test_reject_wrong_shader(self):
        self.receipt['shaderAsset'] = 'invented.frag'
        self.state.write_text(json.dumps(self.receipt))
        self.assert_rejected()

    def test_reject_wrong_state_dimensions(self):
        self.receipt['width'] = 1024
        self.state.write_text(json.dumps(self.receipt))
        self.assert_rejected()

    def test_reject_incomplete_capture_state(self):
        for field in ('capture', 'params', 'view', 'time', 'animationEnabled'):
            with self.subTest(field=field):
                receipt = dict(self.receipt)
                del receipt[field]
                self.state.write_text(json.dumps(receipt))
                self.assert_rejected()

    def test_reject_malformed_state(self):
        for text in ('not JSON', '[]', 'null'):
            with self.subTest(text=text):
                self.state.write_text(text)
                self.assert_rejected()

    def test_reject_input_output_aliases_without_changing_inputs(self):
        before = digest(self.source)
        self.output.mkdir()
        (self.output / 'source.png').hardlink_to(self.source)
        result = self.run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(digest(self.source), before)
        self.assertEqual(sorted(p.name for p in self.output.iterdir()), ['source.png'])

    def test_invalid_state_preserves_existing_output(self):
        self.output.mkdir()
        marker = self.output / 'ic_launcher.png'
        marker.write_bytes(b'existing artwork')
        self.receipt['time'] = 3
        self.state.write_text(json.dumps(self.receipt))
        self.assertNotEqual(self.run_cli().returncode, 0)
        self.assertEqual(marker.read_bytes(), b'existing artwork')
        self.assertEqual(list(self.output.iterdir()), [marker])

    def test_reproducible_bytes_across_runs(self):
        import time
        self.assertEqual(self.run_cli().returncode, 0)
        time.sleep(1.1)  # Cross the ICC timestamp boundary.
        other = self.root / 'repeat'
        result = self.run_cli(other)
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = {p.name: digest(p) for p in self.output.iterdir()}
        self.assertEqual(expected, {p.name: digest(p) for p in other.iterdir()})

    @unittest.skipUnless(os.environ.get('APP_ICON_STAGING_DIR'), 'APP_ICON_STAGING_DIR not set; genuine app capture not checked')
    def test_real_staged_assets(self):
        staging = Path(os.environ['APP_ICON_STAGING_DIR']).resolve()
        self.check_assets(staging)
        result = subprocess.run(
            [sys.executable, str(SCRIPT), '--source', str(staging / 'source.png'),
             '--state', str(staging / 'source-state.json'), '--output', str(self.output)]
            + (['--rotate-clockwise-45'] if json.loads((staging / 'fractal-forge-icon-source.json').read_text())['recipe'].get('rotationDegreesCounterclockwise') == -45 else []),
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for name in (*OUTPUTS, 'source.png', 'source-state.json', 'proof.png'):
            with self.subTest(output=name):
                self.assertEqual(digest(staging / name), digest(self.output / name))


if __name__ == '__main__':
    unittest.main()
