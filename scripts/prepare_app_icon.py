#!/usr/bin/env python3
"""Stage full-image derivatives of a production Zig-Zag Julia capture.

The receipt is validated, not independent proof of GPU/capture authenticity.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import struct

from PIL import Image, ImageDraw, PngImagePlugin

OUTPUTS = {
    'ic_launcher.png': (1024, 'RGB'),
    'ic_launcher_foreground.png': (1024, 'RGBA'),
    'ic_launcher_512.png': (512, 'RGBA'),
    'logo_64.png': (64, 'RGB'),
    'fractal-forge-icon.png': (1024, 'RGB'),
}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def make_proof(source, path):
    # Native-size cells: labels and padding never rescale the image previews.
    sizes = (32, 48, 64, 512)
    shapes = ('square', 'circle', 'squircle', 'rounded-square')
    sheet = Image.new('RGB', (2304, 1424), '#808080')
    draw = ImageDraw.Draw(sheet)
    for row, background in enumerate(('#f5f5f5', '#171717')):
        for column, size in enumerate(sizes):
            x, y = column * 576, row * 616
            draw.rectangle((x, y, x + 575, y + 615), fill=background)
            ink = '#111111' if row == 0 else '#ffffff'
            draw.text((x + 12, y + 8), f'{size}px native | light' if row == 0 else f'{size}px native | dark', fill=ink)
            image = source.resize((size, size), Image.Resampling.LANCZOS)
            for index, shape in enumerate(shapes):
                # 512px masks each get a separate full-sized cell below.
                if size == 512 and index:
                    continue
                px = x + 24 + (index % 2) * 160 if size != 512 else x + 24
                py = y + 56 + (index // 2) * 160 if size != 512 else y + 64
                mask = proof_mask(size, shape)
                sheet.paste(image, (px, py), mask)
                draw.text((px, py + size + 8), shape, fill=ink)
    draw.text((12, 1250), 'Adaptive full layer (108dp): centered 66dp safe circle; guide only, not an output mask', fill='white')
    preview = source.resize((144, 144), Image.Resampling.LANCZOS)
    sheet.paste(preview, (12, 1272))
    radius = 144 * 66 / 108 / 2
    draw.ellipse((84-radius, 1344-radius, 84+radius, 1344+radius), outline='white', width=2)
    # Large mask views retain exactly 512 native image pixels on both surfaces.
    large = Image.new('RGB', (2304, 2656), '#808080')
    large.paste(sheet, (0, 0))
    draw = ImageDraw.Draw(large)
    image = source.resize((512, 512), Image.Resampling.LANCZOS)
    for row, background in enumerate(('#f5f5f5', '#171717')):
        for column, shape in enumerate(shapes):
            x, y = column * 576, 1424 + row * 616
            draw.rectangle((x, y, x + 575, y + 615), fill=background)
            draw.text((x + 24, y + 12), f'512px native | {shape}', fill='#111111' if row == 0 else 'white')
            large.paste(image, (x + 24, y + 56), proof_mask(512, shape))
    large.save(path)


def proof_mask(size, shape):
    mask = Image.new('L', (size, size), 255 if shape == 'square' else 0)
    draw = ImageDraw.Draw(mask)
    if shape == 'circle':
        draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    elif shape == 'rounded-square':
        draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=size / 5, fill=255)
    elif shape == 'squircle':
        mask.putdata([255 if abs((2*x+1)/size-1)**4 + abs((2*y+1)/size-1)**4 <= 1 else 0
                      for y in range(size) for x in range(size)])
    return mask


def prepare(source, state_path, output, rotate_clockwise_45=False):
    source, state_path, output = Path(source), Path(state_path), Path(output)
    state = json.loads(state_path.read_text())
    if not isinstance(state, dict) or state.get('moduleId') != 'f0186_zig_zag_julia':
        raise ValueError('state must identify f0186_zig_zag_julia')
    if state.get('shaderAsset') != 'shaders/escape_time_family/core/julia_gpu.frag':
        raise ValueError('state must identify the production Julia shader')
    if (state.get('width'), state.get('height')) != (2048, 2048):
        raise ValueError('state dimensions must be 2048x2048')
    if type(state.get('time')) not in (int, float) or state['time'] != 0 or state.get('animationEnabled') is not False:
        raise ValueError('state must freeze animation at time 0')
    if (not isinstance(state.get('params'), dict) or not state['params']
            or not isinstance(state.get('view'), dict) or not state['view']
            or state.get('capture') != 'FractalRenderer RepaintBoundary.toImage(pixelRatio: 1)'):
        raise ValueError('state must include production capture procedure, params and view')
    with Image.open(source) as raw:
        if raw.format != 'PNG' or raw.size != (2048, 2048):
            raise ValueError('source must be a 2048x2048 PNG')
        if raw.convert('RGBA').getchannel('A').getextrema() != (255, 255):
            raise ValueError('source pixels must be fully opaque')
        image = raw.convert('RGB')
    crop = [0, 0, 2048, 2048]
    if rotate_clockwise_45:
        rotated = image.convert('RGBA').rotate(-45, Image.Resampling.BICUBIC, expand=True)
        # Inscribed crop excludes interpolation/fill pixels at rotated corners.
        crop = [727, 727, 2171, 2171]
        working = rotated.crop(crop)
        if working.getchannel('A').getextrema() != (255, 255):
            raise ValueError('rotated crop contains non-source corner pixels')
        image = working.convert('RGB')
    names = [*OUTPUTS, 'source.png', 'source-state.json', 'proof.png', 'fractal-forge-icon-source.json']
    for name in names:
        target = output / name
        for original in (source, state_path):
            if target.resolve() == original.resolve() or (target.exists() and target.samefile(original)):
                raise ValueError('output must not overwrite either input (including aliases)')
        if target.is_symlink():
            raise ValueError('output files must not be symlinks')
    try:
        from PIL import ImageCms
    except ImportError:
        profile = None
    else:
        profile = bytearray(ImageCms.ImageCmsProfile(ImageCms.createProfile('sRGB')).tobytes())
        # LittleCMS stamps creation time; fix it to keep identical runs byte-reproducible.
        profile[24:36] = struct.pack('>6H', 2000, 1, 1, 0, 0, 0)
        profile = bytes(profile)
    output.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, output / 'source.png')
    shutil.copyfile(state_path, output / 'source-state.json')
    for name, (size, mode) in OUTPUTS.items():
        resized = image.resize((size, size), Image.Resampling.LANCZOS).convert(mode)
        options = {}
        if name == 'ic_launcher_512.png':
            if profile:
                options['icc_profile'] = profile
            else:
                info = PngImagePlugin.PngInfo()
                info.add(b'sRGB', b'\x00')
                options['pnginfo'] = info
        resized.save(output / name, **options)
    make_proof(image, output / 'proof.png')
    manifest = {
        'source': {'path': 'source.png', 'sha256': sha256(output / 'source.png')},
        'sourceStatePath': 'source-state.json',
        'sourceStateSha256': sha256(output / 'source-state.json'),
        'sourceState': state,
        'androidBackgroundHex': '#%02x%02x%02x' % image.getpixel((0, 0)),
        'androidBackgroundSample': [0, 0],
        'recipe': {
            'crop': crop, 'resampling': 'Pillow LANCZOS',
            'rotationDegreesCounterclockwise': -45 if rotate_clockwise_45 else 0,
            'rotationResampling': 'Pillow BICUBIC, expand=True' if rotate_clockwise_45 else None,
            'workingSize': list(image.size),
            'geometry': 'Recorded rotation/crop, then uniform downsampling; no padding, recoloring or extraction',
            'adaptiveForeground': 'Opaque full image; mask and 66/108 safe-circle guide only in proof.png',
            'proofMasks': 'circle; superellipse exponent 4 squircle; rounded-square radius 20%',
            'playColorSpace': 'sRGB ICC' if profile else 'PNG sRGB chunk',
        },
        'outputs': {name: {'sha256': sha256(output / name), 'width': size, 'height': size, 'mode': mode}
                    for name, (size, mode) in OUTPUTS.items()},
    }
    manifest['outputs']['proof.png'] = {'sha256': sha256(output / 'proof.png')}
    (output / 'fractal-forge-icon-source.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--state', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--rotate-clockwise-45', action='store_true', help='Rotate the genuine capture clockwise and crop away unsupported corners before downsampling.')
    args = parser.parse_args()
    try:
        prepare(args.source, args.state, args.output, args.rotate_clockwise_45)
    except (OSError, ValueError) as error:
        parser.exit(2, f'error: {error}\n')


if __name__ == '__main__':
    main()
