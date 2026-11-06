#!/usr/bin/env python3
"""Compose captioned Google Play screenshots from raw Android captures.

Each raw capture is the full device framebuffer (status bar at the top, system
navigation bar at the bottom). This script trims those system bars, keeps the
remaining app pixels at native scale, and places them under a brand caption
band so the listing reads at thumbnail size.

Only the caption band is added artwork: the pixels below it are the unmodified
app capture. Raw captures and their SHA256 digests are recorded in the output
manifest so the delivered images can be traced back to a device capture.

Usage:
  scripts/compose-store-screenshots.py \\
      --raw release-artifacts/store-listing-captures/<run>/ \\
      --out docs/store_listing/screenshots/
"""
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT_DIR = Path('/usr/share/fonts/truetype/dejavu')
HEADLINE_FONT = FONT_DIR / 'DejaVuSerif-Bold.ttf'
KICKER_FONT = FONT_DIR / 'DejaVuSans-Bold.ttf'

BAND = (11, 11, 20)
HEADLINE_COLOR = (247, 244, 238)
KICKER_COLOR = (142, 124, 255)
RULE_COLOR = (122, 92, 255)
HAIRLINE = (36, 29, 61)

# group -> (band height, crop top, crop bottom, headline size, kicker size)
PROFILES = {
    'phone': dict(band=240, crop_top=76, crop_bottom=96, headline=54, kicker=22,
                  margin=64, max_ratio=2.0),
    'tablet': dict(band=300, crop_top=42, crop_bottom=84, headline=76, kicker=30,
                   margin=80, max_ratio=2.0),
}

# Ordered campaigns: output basename -> (raw basename, kicker, headline)
PHONE_SLIDES = [
    ('01-mandelbrot', '01-mandelbrot', 'FRACTAL FORGE', 'Fall into the detail'),
    ('02-julia', '02-julia', '1,000+ FRACTALS', 'Every constant, a new world'),
    ('03-mandelbulb', '03-mandelbulb', '3D WORLDS', 'Rotate a mathematical object'),
    ('04-catalog', '04-catalog', 'FIND YOUR NEXT', 'Search, browse, favourite'),
    ('05-palette', '05-palette', 'COLOR', 'Palettes made yours'),
    ('06-export', '06-export', 'EXPORT', '4K images and wallpapers'),
    ('07-looper', '07-looper', 'ANIMATION', 'Turn a view into a GIF loop'),
]

TABLET_SLIDES = [
    ('01-catalog', '04-catalog', 'FIND YOUR NEXT', 'Search, browse, favourite'),
    ('02-mandelbrot', '02-mandelbrot', 'DEEP ZOOM', 'Fall into the detail'),
    ('03-mandelbulb', '03-mandelbulb', '3D WORLDS', 'Rotate a mathematical object'),
    ('04-julia', '01-julia', '1,000+ FRACTALS', 'Every constant, a new world'),
]

CAMPAIGNS = {
    'phone': ('1080x1920', PHONE_SLIDES),
    'tablet': ('1600x2560', TABLET_SLIDES),
}


def sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def _draw_spaced(draw, xy, text, font, fill, spacing):
    """Draw uppercase text with extra tracking; returns the advance width."""
    x, y = xy
    for char in text:
        draw.text((x, y), char, font=font, fill=fill)
        x += draw.textlength(char, font=font) + spacing
    return x - spacing - xy[0]


def fit_headline(draw, text, font_path, start_size, max_width, min_size):
    """Largest font size (and resulting lines) that fits max_width."""
    size = start_size
    while size >= min_size:
        font = ImageFont.truetype(str(font_path), size)
        if draw.textlength(text, font=font) <= max_width:
            return font, [text]
        words = text.split()
        if len(words) > 1:
            # Prefer a balanced two-line split once a single line no longer fits.
            best = None
            for cut in range(1, len(words)):
                first = ' '.join(words[:cut])
                second = ' '.join(words[cut:])
                widest = max(draw.textlength(first, font=font),
                             draw.textlength(second, font=font))
                if widest <= max_width and (best is None or widest < best[0]):
                    best = (widest, [first, second])
            if best is not None:
                return font, best[1]
        size -= 2
    font = ImageFont.truetype(str(font_path), min_size)
    return font, [text]


def compose_capture(raw_path, kicker, headline, profile):
    raw = Image.open(raw_path).convert('RGB')
    width, height = raw.size
    expected = CAMPAIGNS[profile][0]
    if f'{width}x{height}' != expected:
        raise ValueError(f'{raw_path}: expected {expected} capture, got {width}x{height}')
    top, bottom = PROFILES[profile]['crop_top'], PROFILES[profile]['crop_bottom']
    if top + bottom >= height // 3:
        raise ValueError(f'{raw_path}: crop trims too much of the app capture')
    app = raw.crop((0, top, width, height - bottom))

    band = PROFILES[profile]['band']
    canvas = Image.new('RGB', (width, app.height + band), BAND)
    canvas.paste(app, (0, band))

    draw = ImageDraw.Draw(canvas)
    margin = PROFILES[profile]['margin']
    kicker_font = ImageFont.truetype(str(KICKER_FONT), PROFILES[profile]['kicker'])
    max_width = width - 2 * margin

    font, lines = fit_headline(
        draw, headline, HEADLINE_FONT, PROFILES[profile]['headline'],
        max_width, max(28, PROFILES[profile]['headline'] - 24))
    line_height = int(font.size * 1.18)
    kicker_size = PROFILES[profile]['kicker']
    gap = 26
    block_height = kicker_size + gap + len(lines) * line_height
    kicker_y = max(margin - 12, (band - block_height) // 2)
    rule_w = 8
    rule_h = kicker_size + 6
    draw.rectangle([margin, kicker_y + 2, margin + rule_w, kicker_y + 2 + rule_h], fill=RULE_COLOR)
    _draw_spaced(draw, (margin + rule_w + 20, kicker_y), kicker, kicker_font,
                 KICKER_COLOR, spacing=5)
    headline_y = kicker_y + kicker_size + gap
    for index, line in enumerate(lines):
        draw.text((margin, headline_y + index * line_height), line,
                  font=font, fill=HEADLINE_COLOR)

    bottom_of_text = headline_y + len(lines) * line_height
    if bottom_of_text > band - 12:
        raise ValueError(
            f'{raw_path}: caption needs {bottom_of_text}px but band is {band}px')

    draw.rectangle([0, band - 2, width, band - 1], fill=HAIRLINE)
    ratio = max(canvas.size) / min(canvas.size)
    if ratio > PROFILES[profile]['max_ratio']:
        raise ValueError(f'{raw_path}: composed aspect ratio {ratio:.3f} exceeds Play limits')
    return canvas, app.size


def compose_campaign(raw_dir, out_dir, profile):
    raw_dir = Path(raw_dir) / profile
    out_dir = Path(out_dir) / profile
    out_dir.mkdir(parents=True, exist_ok=True)
    entries = []
    for name, raw_name, kicker, headline in CAMPAIGNS[profile][1]:
        raw_path = raw_dir / f'{raw_name}.png'
        if not raw_path.exists():
            raise FileNotFoundError(f'missing raw capture: {raw_path}')
        canvas, app_size = compose_capture(raw_path, kicker, headline, profile)
        out_path = out_dir / f'{name}.png'
        canvas.save(out_path, format='PNG', optimize=True)

        def display(path):
            return str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)

        entries.append({
            'file': display(out_path),
            'raw': display(raw_path),
            'raw_sha256': sha256(raw_path),
            'kicker': kicker,
            'headline': headline,
            'size': list(canvas.size),
            'app_pixels': list(app_size),
            'sha256': sha256(out_path),
        })
        print(f'{profile}/{name}: {canvas.size[0]}x{canvas.size[1]}')
    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--raw', required=True, help='Directory holding phone/ and tablet/ raw captures')
    parser.add_argument('--out', default=str(ROOT / 'docs/store_listing/screenshots'))
    parser.add_argument('--manifest', default=str(ROOT / 'docs/store_listing/screenshot_captures.json'))
    args = parser.parse_args()

    manifest = {'source': 'Composed by scripts/compose-store-screenshots.py from full-framebuffer '
                          'Android captures; only the caption band is added, the app pixels are unchanged',
                'groups': {}}
    for profile in CAMPAIGNS:
        manifest['groups'][profile] = compose_campaign(args.raw, args.out, profile)
    Path(args.manifest).write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'manifest: {args.manifest}')


if __name__ == '__main__':
    main()
