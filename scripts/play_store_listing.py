#!/usr/bin/env python3
"""Validate, stage and publish listing copy and images in a single Play edit.

Requires Python 3, Pillow and OpenSSL. The default stages then discards changes.
Credentials, backups and receipts never belong in Git.
"""
import argparse
import base64
from concurrent.futures import ThreadPoolExecutor
import hashlib
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FIELDS = {'title': 30, 'shortDescription': 80, 'fullDescription': 4000}
TYPES = {'icon', 'featureGraphic', 'phoneScreenshots', 'sevenInchScreenshots', 'tenInchScreenshots'}


def validate(listings_path, assets_path):
    locales = json.loads(Path(listings_path).read_text())['locales']
    if not locales:
        raise ValueError('No locales')
    for locale, listing in locales.items():
        if not locale or '/' in locale:
            raise ValueError(f'Invalid locale: {locale}')
        for field, limit in FIELDS.items():
            value = listing.get(field)
            if not isinstance(value, str) or not value.strip() or len(value) > limit:
                raise ValueError(f'{locale}: {field} must contain 1–{limit} characters')
    assets = {}
    for kind, paths in json.loads(Path(assets_path).read_text())['images'].items():
        if kind not in TYPES or not paths or len(paths) > (1 if kind in {'icon', 'featureGraphic'} else 8):
            raise ValueError(f'Invalid image type/count: {kind}')
        assets[kind] = []
        for relative in paths:
            path = (ROOT / relative).resolve()
            if not path.is_relative_to(ROOT):
                raise ValueError(f'Image outside repository: {relative}')
            data = path.read_bytes()
            with Image.open(io.BytesIO(data)) as im:
                im.load()
                w, h = im.size
                if im.format != 'PNG' or im.mode != 'RGB':
                    raise ValueError(f'{relative}: expected opaque RGB PNG')
                if kind == 'icon' and ((w, h) != (512, 512) or len(data) > 1024 * 1024):
                    raise ValueError(f'{relative}: invalid icon size')
                if kind == 'featureGraphic' and (w, h) != (1024, 500):
                    raise ValueError(f'{relative}: feature graphic must be 1024×500')
                if kind.endswith('Screenshots') and (min(w, h) < 320 or max(w, h) > 3840 or max(w, h) > 2 * min(w, h)):
                    raise ValueError(f'{relative}: invalid screenshot dimensions')
            assets[kind].append({'path': relative, 'data': data, 'sha256': hashlib.sha256(data).hexdigest(), 'sha1': hashlib.sha1(data).hexdigest()})
        if len({a['sha256'] for a in assets[kind]}) != len(paths):
            raise ValueError(f'{kind}: duplicate screenshots')
    return locales, assets


def token(key_path):
    key = json.loads(Path(key_path).read_text())
    def b64(data):
        return base64.urlsafe_b64encode(data).rstrip(b'=')
    now = int(time.time())
    claims = {'iss': key['client_email'], 'scope': 'https://www.googleapis.com/auth/androidpublisher', 'aud': 'https://oauth2.googleapis.com/token', 'iat': now, 'exp': now + 3600}
    signing = b64(b'{"alg":"RS256","typ":"JWT"}') + b'.' + b64(json.dumps(claims).encode())
    with tempfile.NamedTemporaryFile(mode='w') as pem:
        pem.write(key['private_key']); pem.flush()
        signature = subprocess.check_output(['openssl', 'dgst', '-sha256', '-sign', pem.name, '-binary'], input=signing)
    data = urllib.parse.urlencode({'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'assertion': (signing + b'.' + b64(signature)).decode()}).encode()
    with urllib.request.urlopen(urllib.request.Request(claims['aud'], data=data), timeout=60) as response:
        return json.load(response)['access_token']


class Play:
    def __init__(self, package, access_token):
        self.base = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/' + urllib.parse.quote(package, safe='')
        self.access_token = access_token

    def request(self, method, path, body=None, image=None):
        url = self.base + path
        headers = {'Authorization': 'Bearer ' + self.access_token}
        if image is not None:
            url = url.replace('/androidpublisher/v3/', '/upload/androidpublisher/v3/') + '?uploadType=media'
            data = image
            headers['Content-Type'] = 'image/png'
        else:
            data = json.dumps(body).encode() if body is not None else None
            headers['Content-Type'] = 'application/json; charset=utf-8'
        for attempt in range(3):
            try:
                with urllib.request.urlopen(urllib.request.Request(url, data=data, headers=headers, method=method), timeout=90) as response:
                    raw = response.read()
                    return json.loads(raw) if raw else {}
            except urllib.error.HTTPError as error:
                # Retry only idempotent operations; an upload/commit may have succeeded.
                if method in {'GET', 'PUT', 'DELETE'} and error.code in {429, 500, 502, 503, 504} and attempt < 2:
                    time.sleep(2 ** attempt)
                    continue
                raise RuntimeError(f'{method} {path}: HTTP {error.code}: {error.read().decode()[:1000]}') from None


def snapshot(api, edit, kinds):
    base = f'/edits/{edit}'
    listings = api.request('GET', base + '/listings').get('listings', [])
    def locale_images(item):
        locale = item['language']
        return locale, {kind: api.request('GET', base + '/listings/' + locale + '/' + kind).get('images', []) for kind in kinds}
    with ThreadPoolExecutor(max_workers=4) as pool:
        images = dict(pool.map(locale_images, listings))
    return {'listings': listings, 'images': images}


def verify(state, locales, assets):
    current = {item['language']: item for item in state['listings']}
    if set(current) != set(locales):
        raise ValueError('Live and local locales differ; explicitly reconcile locale coverage first')
    for locale, listing in locales.items():
        for field in FIELDS:
            if current[locale].get(field) != listing[field]:
                raise ValueError(f'{locale}: readback mismatch for {field}')
        for kind, expected in assets.items():
            actual = state['images'][locale][kind]
            if len(actual) != len(expected):
                raise ValueError(f'{locale}/{kind}: image count mismatch')
            for remote, local in zip(actual, expected):
                algorithm = 'sha256' if remote.get('sha256') else 'sha1'
                if remote.get(algorithm) != local[algorithm]:
                    raise ValueError(f'{locale}/{kind}: image digest/order mismatch')


def publish(api, locales, assets, directory, mode):
    directory.mkdir(parents=True, exist_ok=False)
    def save(name, value):
        (directory / name).write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')
    edit = api.request('POST', '/edits', {})['id']
    committed = False
    try:
        before = snapshot(api, edit, assets)
        save('before.json', before)
        if mode == 'audit':
            return
        existing = {item['language']: item for item in before['listings']}
        if set(existing) != set(locales):
            raise ValueError('Live and local locales differ; refusing incomplete update')
        def stage_locale(item):
            locale, listing = item
            path = f'/edits/{edit}/listings/{locale}'
            body = {field: listing[field] for field in FIELDS}
            if existing[locale].get('video'):
                body['video'] = existing[locale]['video']
            api.request('PUT', path, body)
            for kind, images in assets.items():
                api.request('DELETE', path + '/' + kind)
                for asset in images:
                    api.request('POST', path + '/' + kind, image=asset['data'])
            print(f'Staged {locale}', flush=True)
        # Different locales are independent; preserve image order within each.
        # The executor waits for all workers before edit cleanup on any failure.
        with ThreadPoolExecutor(max_workers=4) as pool:
            list(pool.map(stage_locale, locales.items()))
        staged = snapshot(api, edit, assets)
        verify(staged, locales, assets)
        save('staged.json', staged)
        api.request('POST', f'/edits/{edit}:validate')
        if mode == 'commit':
            api.request('POST', f'/edits/{edit}:commit')
            committed = True
            # A fresh edit reads the committed state, not the staged payload.
            check = api.request('POST', '/edits', {})['id']
            try:
                after = snapshot(api, check, assets)
                save('after.json', after)
                verify(after, locales, assets)
            finally:
                api.request('DELETE', '/edits/' + check)
        save('receipt.json', {'mode': mode, 'committed': committed, 'verified': True, 'locales': list(locales), 'assets': {kind: [{k: v for k, v in a.items() if k != 'data'} for a in images] for kind, images in assets.items()}})
    finally:
        if not committed:
            api.request('DELETE', '/edits/' + edit)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    for flag in ['validate-only', 'audit', 'dry-run', 'commit']:
        group.add_argument('--' + flag, action='store_true')
    args = parser.parse_args()
    listings = os.environ.get('PLAY_LOCALIZED_LISTINGS_JSON', str(ROOT / 'docs/play-store-localized-listings.json'))
    manifest = os.environ.get('PLAY_LISTING_ASSETS_JSON', str(ROOT / 'docs/store_listing/assets.json'))
    locales, assets = validate(listings, manifest)
    print(f'Validated {len(locales)} locales, {sum(map(len, assets.values()))} images', flush=True)
    if args.validate_only:
        return
    package = os.environ.get('PLAY_PACKAGE_NAME', 'com.trebuchetdynamics.fractal.forge')
    credentials = os.environ.get('PLAY_SERVICE_ACCOUNT_JSON', str(ROOT / 'play-console-upload/play-service-account.json'))
    mode = 'commit' if args.commit else 'audit' if args.audit else 'dry-run'
    directory = ROOT / 'release-artifacts/store-listing' / (time.strftime('%Y%m%d-%H%M%S') + '-' + str(os.getpid()))
    publish(Play(package, token(credentials)), locales, assets, directory, mode)
    print(f'{mode}: complete. Evidence: {directory}')


if __name__ == '__main__':
    main()
