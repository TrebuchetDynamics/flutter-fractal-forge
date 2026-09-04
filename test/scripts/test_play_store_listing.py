import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('listing', ROOT / 'scripts/play_store_listing.py')
listing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(listing)


class FakePlay:
    def __init__(self, locales, assets, fail_upload=False):
        self.live = {'listings': [{'language': lang, **body, 'video': 'https://youtu.be/existing'} for lang, body in locales.items()], 'images': {lang: {kind: [] for kind in assets} for lang in locales}}
        self.edits = {}
        self.commits = 0
        self.next_id = 0
        self.fail_upload = fail_upload

    def request(self, method, path, body=None, image=None):
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
            state['images'][locale][kind].append({'sha256': listing.hashlib.sha256(image).hexdigest()})
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


if __name__ == '__main__':
    unittest.main()
