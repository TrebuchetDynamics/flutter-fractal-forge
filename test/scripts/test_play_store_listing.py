import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('listing', ROOT / 'scripts/play_store_listing.py')
listing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(listing)


class FakePlay:
    def __init__(self, locales, assets, fail_upload=False):
        self.live = {'listings': [{'language': lang, **body, 'video': 'https://youtu.be/existing'} for lang, body in locales.items()], 'images': {lang: {kind: [] for kind in listing.TYPES} for lang in locales}}
        self.edits = {}
        self.commits = 0
        self.next_id = 0
        self.fail_upload = fail_upload
        self.calls = []

    def request(self, method, path, body=None, image=None):
        self.calls.append((method, path, body, image))
        if path == '/edits':
            self.next_id += 1
            key = str(self.next_id)
            self.edits[key] = copy.deepcopy(self.live)
            return {'id': key}
        parts = path.split('/')
        key = parts[2].split(':')[0]
        if path.endswith(':validate'):
            return {}
        if path.endswith(':commit'):
            self.live = self.edits.pop(key)
            self.commits += 1
            return {}
        state = self.edits[key]
        if len(parts) == 3:
            del self.edits[key]
            return {}
        if len(parts) == 4:
            return {'listings': copy.deepcopy(state['listings'])}
        locale = parts[4]
        if len(parts) == 5:
            state['listings'] = [item for item in state['listings'] if item['language'] != locale] + [{'language': locale, **body}]
            return body
        kind = parts[5]
        if method == 'DELETE':
            state['images'][locale][kind] = []
            return {}
        if method == 'POST':
            if self.fail_upload:
                raise RuntimeError('Upload failed')
            state['images'][locale][kind].append({'id': 'uploaded-' + str(len(state['images'][locale][kind])), 'url': 'https://example.invalid/image', 'sha256': listing.hashlib.sha256(image).hexdigest()})
            return {}
        return {'images': copy.deepcopy(state['images'][locale][kind])}


class ListingTests(unittest.TestCase):
    def setUp(self):
        self.locales = {'en-US': {'title': 'Fractal Forge', 'shortDescription': 'Explore art', 'fullDescription': 'Make fractal art.'}}
        data = b'test image'
        self.assets = {'phoneScreenshots': [{'data': data, 'path': 'test.png', 'sha256': listing.hashlib.sha256(data).hexdigest(), 'sha1': listing.hashlib.sha1(data).hexdigest()}]}

    def run_publish(self, api, mode):
        with tempfile.TemporaryDirectory() as root:
            listing.publish(api, self.locales, self.assets, Path(root) / 'receipt', mode)

    def test_commit_verifies_new_edit_and_preserves_video(self):
        api = FakePlay(self.locales, self.assets)
        self.run_publish(api, 'commit')
        self.assertEqual(api.commits, 1)
        self.assertEqual(api.next_id, 2)
        self.assertFalse(api.edits)
        self.assertEqual(api.live['listings'][0]['video'], 'https://youtu.be/existing')

    def test_multiple_locales_keep_screenshot_order(self):
        self.locales['es-ES'] = dict(self.locales['en-US'], title='Arte fractal')
        data = b'second image'
        self.assets['phoneScreenshots'].append({'data': data, 'path': 'second.png', 'sha256': listing.hashlib.sha256(data).hexdigest(), 'sha1': listing.hashlib.sha1(data).hexdigest()})
        api = FakePlay(self.locales, self.assets)
        self.run_publish(api, 'commit')
        listing.verify(api.live, self.locales, self.assets)
        self.assertFalse(api.edits)

    def test_dry_run_does_not_change_live_state(self):
        api = FakePlay(self.locales, self.assets)
        before = copy.deepcopy(api.live)
        self.run_publish(api, 'dry-run')
        self.assertEqual(api.live, before)
        self.assertFalse(api.edits)

    def test_upload_failure_discards_partial_edit(self):
        api = FakePlay(self.locales, self.assets, fail_upload=True)
        before = copy.deepcopy(api.live)
        with self.assertRaisesRegex(RuntimeError, 'Upload failed'):
            self.run_publish(api, 'commit')
        self.assertEqual(api.live, before)
        self.assertEqual(api.commits, 0)
        self.assertFalse(api.edits)

    def test_missing_live_locale_aborts(self):
        api = FakePlay(self.locales, self.assets)
        api.live['listings'] = []
        with self.assertRaisesRegex(ValueError, 'locales differ'):
            self.run_publish(api, 'commit')
        self.assertEqual(api.commits, 0)
        self.assertFalse(api.edits)

    def test_wrong_digest_is_rejected(self):
        api = FakePlay(self.locales, self.assets)
        api.live['images']['en-US']['phoneScreenshots'] = [{'sha256': 'wrong'}]
        with self.assertRaisesRegex(ValueError, 'digest/order'):
            listing.verify(api.live, self.locales, self.assets)

    def test_campaign_assets_and_all_metadata_copies_match(self):
        locales, assets = listing.validate(ROOT / 'docs/play-store-localized-listings.json', ROOT / 'docs/store_listing/assets.json')
        self.assertEqual(len(locales), 15)
        for locale, body in locales.items():
            for filename, field in [('title.txt', 'title'), ('short_description.txt', 'shortDescription'), ('full_description.txt', 'fullDescription')]:
                self.assertEqual((ROOT / 'fastlane/metadata/android' / locale / filename).read_text().strip(), body[field])
        self.assertGreaterEqual(len(assets['phoneScreenshots']), 4)
        self.assertEqual((ROOT / 'assets/feature-graphic.png').read_bytes(), (ROOT / 'docs/store_listing/feature_graphic.png').read_bytes())
        for filename, field in [('title.txt', 'title'), ('short_description.txt', 'shortDescription'), ('full_description.txt', 'fullDescription')]:
            self.assertEqual((ROOT / 'docs/store_listing' / filename).read_text().strip(), locales['en-US'][field])
        for body in locales.values():
            self.assertNotIn('MP4', body['fullDescription'], 'MP4 encoding is deferred; do not advertise it')

    def test_empty_and_overlong_text_rejected_before_auth(self):
        with tempfile.TemporaryDirectory() as root:
            path = Path(root) / 'copy.json'
            for bad in ['', 'a' * 31]:
                self.locales['en-US']['title'] = bad
                path.write_text(json.dumps({'locales': self.locales}))
                with self.assertRaisesRegex(ValueError, 'title'):
                    listing.validate(path, ROOT / 'docs/store_listing/assets.json')


class ImageValidationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        patcher = mock.patch.object(listing, 'ROOT', self.root)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.copy = self.root / 'copy.json'
        self.copy.write_text(json.dumps({'locales': {'en-US': dict.fromkeys(listing.FIELDS, 'Valid')}}))
        self.manifest = self.root / 'assets.json'

    def image(self, kind='icon', mode='RGBA', size=(512, 512), alpha=255, **save_args):
        image = listing.Image.new(mode, size, (12, 34, 56, 255) if mode == 'RGBA' else (12, 34, 56))
        if alpha != 255:
            image.putpixel((511, 511), (12, 34, 56, alpha))
        image.save(self.root / 'image.png', **save_args)
        self.manifest.write_text(json.dumps({'images': {kind: ['image.png']}}))

    def test_opaque_rgba_and_legacy_rgb_icons_accepted(self):
        for mode in ['RGBA', 'RGB']:
            for icon_only in [False, True]:
                with self.subTest(mode=mode, icon_only=icon_only):
                    self.image(mode=mode)
                    _, assets = listing.validate(self.copy, self.manifest, icon_only=icon_only)
                    self.assertEqual(assets['icon'][0]['data'], (self.root / 'image.png').read_bytes())

    def test_single_translucent_pixel_icon_rejected(self):
        for alpha in [0, 254]:
            self.image(alpha=alpha)
            for icon_only in [False, True]:
                with self.subTest(alpha=alpha, icon_only=icon_only), self.assertRaisesRegex(ValueError, 'opaque RGB PNG'):
                    listing.validate(self.copy, self.manifest, icon_only=icon_only)

    def test_rgb_icon_with_transparent_color_rejected(self):
        self.image(mode='RGB', transparency=(12, 34, 56))
        for icon_only in [False, True]:
            with self.subTest(icon_only=icon_only), self.assertRaisesRegex(ValueError, 'opaque RGB PNG'):
                listing.validate(self.copy, self.manifest, icon_only=icon_only)

    def test_wrong_icon_dimensions_rejected(self):
        self.image(size=(513, 512))
        for icon_only in [False, True]:
            with self.subTest(icon_only=icon_only), self.assertRaisesRegex(ValueError, 'invalid icon size'):
                listing.validate(self.copy, self.manifest, icon_only=icon_only)

    def test_oversize_opaque_icon_rejected(self):
        self.image(compress_level=0)
        self.assertGreater((self.root / 'image.png').stat().st_size, 1024 * 1024)
        for icon_only in [False, True]:
            with self.subTest(icon_only=icon_only), self.assertRaisesRegex(ValueError, 'invalid icon size'):
                listing.validate(self.copy, self.manifest, icon_only=icon_only)

    def test_non_icon_rgba_still_rejected(self):
        for kind in listing.TYPES - {'icon'}:
            with self.subTest(kind=kind):
                self.image(kind=kind, size=(1024, 500) if kind == 'featureGraphic' else (512, 512))
                with self.assertRaisesRegex(ValueError, 'opaque RGB PNG'):
                    listing.validate(self.copy, self.manifest)

    def test_icon_only_ignores_unused_local_copy_and_images(self):
        self.image()
        self.manifest.write_text(json.dumps({'images': {'icon': ['image.png'], 'phoneScreenshots': ['missing.png']}}))
        self.copy.unlink()
        locales, assets = listing.validate(self.copy, self.manifest, icon_only=True)
        self.assertEqual(locales, {})
        self.assertEqual(set(assets), {'icon'})

    def test_icon_only_requires_exactly_one_manifest_icon(self):
        for images in [{}, {'icon': []}, {'icon': ['one.png', 'two.png']}]:
            with self.subTest(images=images):
                self.manifest.write_text(json.dumps({'images': images}))
                with self.assertRaisesRegex(ValueError, 'image type/count: icon'):
                    listing.validate(self.copy, self.manifest, icon_only=True)


class IconOnlyTests(unittest.TestCase):
    def setUp(self):
        # Synthetic server state only; no network or publication evidence.
        self.locales = {'en-US': dict.fromkeys(listing.FIELDS, 'Stale local copy')}
        data = b'selected local B icon'
        self.assets = {'icon': [{'data': data, 'path': 'selected-B.png', 'sha256': listing.hashlib.sha256(data).hexdigest(), 'sha1': listing.hashlib.sha1(data).hexdigest()}]}
        live_locales = {lang: dict.fromkeys(listing.FIELDS, 'Live ' + lang) for lang in ['en-US', 'es-ES']}
        self.api = FakePlay(live_locales, self.assets)
        for index, item in enumerate(self.api.live['listings']):
            item['video'] = '' if index else 'https://youtu.be/live'
            item['serverMetadata'] = {'preserve': True}
        for lang, groups in self.api.live['images'].items():
            for kind in listing.TYPES:
                groups[kind] = [{'id': f'{lang}-{kind}-{i}', 'sha256': f'old-{i}', 'sha1': f'old-sha1-{i}', 'url': f'https://example.invalid/{i}'} for i in range(1 if kind == 'icon' else 2)]
        self.before = copy.deepcopy(self.api.live)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name) / 'receipt'

    def publish(self, mode='commit'):
        listing.publish(self.api, self.locales, self.assets, self.directory, mode, icon_only=True)

    def assert_scope(self, mode):
        for method, path, body, image in self.api.calls:
            if method == 'GET':
                self.assertIn('/listings', path)
            elif method == 'POST' and path == '/edits':
                self.assertEqual(body, {})
            elif method == 'POST' and path.endswith((':validate', ':commit')):
                self.assertNotEqual(mode, 'audit')
            elif method == 'DELETE' and len(path.split('/')) == 3:
                pass
            else:
                self.assertNotEqual(mode, 'audit')
                self.assertIn(method, {'DELETE', 'POST'})
                self.assertTrue(path.endswith('/icon'), (method, path))
                if method == 'POST':
                    self.assertEqual(image, self.assets['icon'][0]['data'])

    def test_commit_all_live_locales_and_full_preservation(self):
        self.publish()
        listing.verify_preserved(self.api.live, self.before)
        listing.verify(self.api.live, {x['language']: x for x in self.before['listings']}, self.assets)
        self.assertEqual(self.api.commits, 1)
        self.assertEqual(self.api.next_id, 2)
        self.assertFalse(self.api.edits)
        self.assert_scope('commit')
        receipt = json.loads((self.directory / 'receipt.json').read_text())
        self.assertEqual(receipt['scope'], 'icon-only')
        self.assertEqual(set(receipt['locales']), {'en-US', 'es-ES'})
        self.assertTrue(receipt['verified'])
        self.assertEqual(receipt['assets']['icon'][0]['sha256'], self.assets['icon'][0]['sha256'])
        for filename in ['before.json', 'staged.json', 'after.json']:
            state = json.loads((self.directory / filename).read_text())
            listing.verify_preserved(state, self.before)
            self.assertEqual(set(state['images']), {'en-US', 'es-ES'})
            for groups in state['images'].values():
                self.assertEqual(set(groups), listing.TYPES)

    def test_dry_run_preserves_live_and_discards_edit(self):
        self.publish('dry-run')
        self.assertEqual(self.api.live, self.before)
        self.assertEqual(self.api.commits, 0)
        self.assertFalse(self.api.edits)
        self.assert_scope('dry-run')
        self.assertTrue((self.directory / 'staged.json').exists())
        receipt = json.loads((self.directory / 'receipt.json').read_text())
        self.assertEqual(receipt['scope'], 'icon-only')
        self.assertFalse(receipt['committed'])
        self.assertEqual(set(receipt['locales']), {'en-US', 'es-ES'})

    def test_audit_only_snapshots_all_groups_and_live_locales(self):
        self.publish('audit')
        self.assertEqual(self.api.live, self.before)
        self.assertFalse(self.api.edits)
        self.assert_scope('audit')
        self.assertEqual(json.loads((self.directory / 'before.json').read_text()), self.before)
        receipt = json.loads((self.directory / 'receipt.json').read_text())
        self.assertEqual(receipt['scope'], 'icon-only')
        self.assertEqual(set(receipt['locales']), {'en-US', 'es-ES'})

    def test_upload_failure_discards_partial_edit_without_retry(self):
        self.api.fail_upload = True
        with self.assertRaisesRegex(RuntimeError, 'Upload failed'):
            self.publish()
        self.assertEqual(self.api.live, self.before)
        self.assertEqual(self.api.commits, 0)
        self.assertFalse(self.api.edits)
        uploads = [path for method, path, _, _ in self.api.calls if method == 'POST' and path.endswith('/icon')]
        self.assertEqual(len(uploads), len(set(uploads)))
        self.assert_scope('commit')

    def test_rejects_non_icon_payload_before_opening_edit(self):
        for assets in [{}, {'icon': []}, {'icon': self.assets['icon'] * 2}, {**self.assets, 'phoneScreenshots': []}]:
            with self.subTest(assets=assets), self.assertRaisesRegex(ValueError, 'exactly one icon'):
                listing.publish(self.api, {}, assets, self.directory, 'commit', icon_only=True)
        self.assertEqual(self.api.calls, [])

    def test_empty_live_locale_set_aborts_and_cleans_up(self):
        self.api.live = {'listings': [], 'images': {}}
        with self.assertRaisesRegex(ValueError, 'unique live locales'):
            self.publish()
        self.assertFalse(self.api.edits)
        self.assertEqual(self.api.commits, 0)

    def test_staged_and_fresh_readback_drift_fail_without_success_receipt(self):
        mutations = {
            'text': lambda state: state['listings'][0].update(title='Changed remotely'),
            'video': lambda state: state['listings'][0].update(video='Changed remotely'),
            'locale': lambda state: state['listings'].pop(),
            'image_id': lambda state: state['images']['en-US']['phoneScreenshots'][0].update(id='Changed'),
            'image_digest': lambda state: state['images']['en-US']['phoneScreenshots'][0].update(sha256='Changed'),
            'image_order': lambda state: state['images']['en-US']['phoneScreenshots'].reverse(),
            'icon_digest': lambda state: state['images']['en-US']['icon'][0].update(sha256='Wrong icon'),
            'icon_count': lambda state: state['images']['en-US']['icon'].clear(),
        }
        for phase in [2, 3]:
            for name, mutate in mutations.items():
                with self.subTest(phase=phase, mutation=name):
                    self.api.live = copy.deepcopy(self.before)
                    self.api.commits = 0
                    self.directory = Path(self.temp.name) / f'{phase}-{name}'
                    original = self.api.request
                    reads = 0

                    def request(method, path, body=None, image=None):
                        nonlocal reads
                        if method == 'GET' and path.endswith('/listings'):
                            reads += 1
                            if reads == phase:
                                mutate(self.api.edits[path.split('/')[2]])
                        return original(method, path, body, image)

                    with mock.patch.object(self.api, 'request', side_effect=request):
                        with self.assertRaisesRegex(ValueError, 'mismatch'):
                            self.publish()
                    self.assertFalse(self.api.edits)
                    self.assertEqual(self.api.commits, 0 if phase == 2 else 1)
                    if phase == 2:
                        self.assertEqual(self.api.live, self.before)
                    self.assertFalse((self.directory / 'receipt.json').exists())
                    self.assert_scope('commit')

    def test_validation_failure_discards_edit(self):
        original = self.api.request

        def request(method, path, body=None, image=None):
            if path.endswith(':validate'):
                raise RuntimeError('Validation failed')
            return original(method, path, body, image)

        with mock.patch.object(self.api, 'request', side_effect=request):
            with self.assertRaisesRegex(RuntimeError, 'Validation failed'):
                self.publish()
        self.assertFalse(self.api.edits)
        self.assertEqual(self.api.live, self.before)
        self.assertEqual(self.api.commits, 0)

    def test_cli_icon_only_modes_and_default(self):
        for mode in ['validate-only', 'audit', 'dry-run', 'commit', None]:
            with self.subTest(mode=mode):
                args = ['play_store_listing.py', '--icon-only'] + (['--' + mode] if mode else [])
                with mock.patch('sys.argv', args), mock.patch.object(listing, 'validate', return_value=({}, self.assets)) as validate, mock.patch.object(listing, 'token', return_value='fake') as token, mock.patch.object(listing, 'Play', return_value=self.api), mock.patch.object(listing, 'publish') as publish:
                    listing.main()
                self.assertTrue(validate.call_args.kwargs['icon_only'])
                if mode == 'validate-only':
                    token.assert_not_called()
                    publish.assert_not_called()
                else:
                    self.assertEqual(publish.call_args.args[4], mode or 'dry-run')
                    self.assertTrue(publish.call_args.kwargs['icon_only'])


if __name__ == '__main__':
    unittest.main()
