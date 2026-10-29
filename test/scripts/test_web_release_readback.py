import hashlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest
from unittest import mock
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('web_release_readback', ROOT / 'scripts/release_platform_lanes.py')
RELEASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RELEASE)


class WebReleaseReadbackTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.identity = {'version': '1.1.113', 'build_number': '113', 'commit': 'a' * 40}
        self.files = {
            'index.html': b'<html>qualified app</html>',
            'main.dart.js': b'compiled application',
            'assets/data.bin': b'qualified asset',
            '.well-known/assetlinks.json': b'[]',
            '_headers.txt': b'an ordinary public file',
        }
        self.control = (b'/\n  Cache-Control: public, max-age=0, must-revalidate\n'
                        b'/index.html\n  Cache-Control: public, max-age=0, must-revalidate\n'
                        b'/main.dart.js\n  Cache-Control: public, max-age=300, must-revalidate\n'
                        b'/assets/*\n  Cache-Control: public, max-age=31536000, immutable\n'
                        b'/.well-known/assetlinks.json\n  Content-Type: application/json\n')
        self.headers = {
            '/': {'cache-control': 'public, max-age=0, must-revalidate'},
            '/index.html': {'cache-control': 'public, max-age=0, must-revalidate'},
            '/main.dart.js': {'cache-control': 'public, max-age=300, must-revalidate'},
            '/assets/data.bin': {'cache-control': 'public, max-age=31536000, immutable'},
            '/.well-known/assetlinks.json': {'content-type': 'application/json'},
        }
        self.live = dict(self.files)
        self.redirect_index = False
        self.foreign_redirect = False
        self.requests = []
        self.urls = []
        self.production_fault = None
        self.root_fault = None

    def archive(self, *, include_control=True, tamper_control=False):
        files = {**self.files, **({'_headers': self.control} if include_control else {})}
        expected = {**self.identity, 'files': {name: hashlib.sha256(value).hexdigest()
                                             for name, value in files.items()}}
        archive = self.root / 'web.tar.gz'
        with tarfile.open(archive, 'w:gz') as bundle:
            for name, value in {**files, 'release-identity.json': json.dumps(expected).encode()}.items():
                if name == '_headers' and tamper_control:
                    value = b'/\n  Cache-Control: public, max-age=14400\n'
                entry = tarfile.TarInfo('web/' + name)
                entry.size = len(value)
                bundle.addfile(entry, io.BytesIO(value))
        self.expected = expected
        self.lane = {'status': 'verified', 'identity': self.identity,
                     'artifacts': [{'path': str(archive), 'sha256': RELEASE.sha256_file(archive)}]}
        return self.lane

    def remote(self, command, **kwargs):
        if command[0] == 'wrangler':
            return subprocess.CompletedProcess(command, 0, stdout=json.dumps([{
                'Id': 'deployment-fixture', 'Environment': 'Production', 'Branch': 'main',
                'Source': self.identity['commit'][:7], 'Deployment': 'https://fixture.pages.dev',
            }]), stderr='')
        self.assertEqual(command[0], 'curl')
        url = command[-1]
        name = urlsplit(url).path
        self.requests.append(name)
        self.urls.append(url)
        production = urlsplit(url).hostname == 'fractal.trebuchetdynamics.com'
        final_url = url
        if name == '/release-identity.json':
            observed = {**self.expected, 'commit': 'b' * 40} if production and self.production_fault == 'identity' else self.expected
            body = json.dumps(observed).encode()
        elif name == '/':
            body = b'tampered root page' if self.root_fault == 'bytes' else self.live['index.html']
        elif name == '/_headers':
            body = self.files['index.html']  # Cloudflare serves its SPA fallback, not the control file.
        else:
            body = self.live.get(name.lstrip('/'), b'not found')
        if name == '/index.html' and self.redirect_index:
            if not any(option in command for option in ('-L', '--location', '-fLsS')):
                return subprocess.CompletedProcess(command, 22, stdout=b'', stderr=b'HTTP 308')
            final_url = urlsplit(url)._replace(path='/', query='').geturl()
        if self.foreign_redirect and name == '/main.dart.js':
            final_url = 'https://foreign.invalid/main.dart.js'
        if '--dump-header' in command:
            destination = Path(command[command.index('--dump-header') + 1])
            headers = ({'cache-control': 'public, max-age=14400, must-revalidate'}
                       if ((production and self.production_fault == 'cache' and name == '/main.dart.js')
                           or (name == '/' and self.root_fault == 'cache'))
                       else self.headers.get(name, {}))
            header_lines = [f'{key}: {value}' for key, value in headers.items()]
            destination.write_text('HTTP/2 200\r\n' + '\r\n'.join(header_lines) + '\r\n\r\n')
        if '--write-out' in command:
            body += command[command.index('--write-out') + 1].replace('%{url_effective}', final_url).encode()
        return subprocess.CompletedProcess(command, 0,
                                           stdout=body.decode() if kwargs.get('text') else body,
                                           stderr='' if kwargs.get('text') else b'')

    def readback(self):
        with mock.patch.object(RELEASE.subprocess, 'run', side_effect=self.remote):
            return RELEASE._web_readback(self.lane, None)

    def test_consumed_control_file_is_verified_by_its_actual_response_policy(self):
        self.archive()
        result = self.readback()
        self.assertTrue(result and result.get('found'), result)
        self.assertNotIn('/_headers', self.requests)
        self.assertEqual(result['verified_file_count'], 5)
        self.assertEqual(result['verified_control_files'], ['_headers'])
        self.assertEqual(result['verified_response_policy_count'], 5)

    def test_canonical_production_site_is_checked_as_well_as_the_deployment_url(self):
        self.archive()
        result = self.readback()
        self.assertTrue(result and result.get('found'), result)
        self.assertEqual({urlsplit(url).hostname for url in self.urls},
                         {'fixture.pages.dev', 'fractal.trebuchetdynamics.com'})

    def test_matching_deployment_does_not_hide_a_stale_or_misconfigured_public_site(self):
        for fault in ('identity', 'cache'):
            with self.subTest(fault=fault):
                self.archive()
                self.production_fault = fault
                result = self.readback()
                self.assertFalse(result and result.get('found'), result)
                self.assertTrue(result and result.get('conflict'), result)

    def test_root_route_is_verified_even_when_index_html_returns_without_a_redirect(self):
        self.archive()
        result = self.readback()
        self.assertTrue(result and result.get('found'), result)
        roots = [urlsplit(url).hostname for url in self.urls if urlsplit(url).path == '/']
        self.assertEqual(set(roots), {'fixture.pages.dev', 'fractal.trebuchetdynamics.com'})

    def test_wrong_root_bytes_or_cache_headers_cannot_hide_behind_a_valid_index_file(self):
        for fault in ('bytes', 'cache'):
            with self.subTest(fault=fault):
                self.archive()
                self.root_fault = fault
                result = self.readback()
                self.assertFalse(result and result.get('found'), result)
                self.assertTrue(result and result.get('conflict'), result)

    def test_confirmed_existing_deployment_does_not_trigger_another_upload(self):
        self.archive()
        with mock.patch.object(RELEASE.subprocess, 'run', side_effect=self.remote):
            with mock.patch.object(RELEASE, '_web_write', side_effect=AssertionError('duplicate upload')):
                result = RELEASE.publish_once(self.lane, RELEASE._web_write, RELEASE._web_readback)
        self.assertEqual(result['publication'], 'published')
        self.assertEqual(result['publication_reason'], 'existing write confirmed before retry')

    def test_normal_same_origin_index_redirect_does_not_corrupt_byte_verification(self):
        self.archive(include_control=False)
        self.redirect_index = True
        result = self.readback()
        self.assertTrue(result and result.get('found'), result)

    def test_cross_origin_redirect_cannot_supply_a_verified_release_asset(self):
        self.archive(include_control=False)
        self.foreign_redirect = True
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)

    def test_wrong_or_missing_cache_policy_keeps_publication_blocked(self):
        for value in ('public, max-age=14400, must-revalidate', None):
            with self.subTest(value=value):
                self.archive()
                self.headers['/main.dart.js'] = {} if value is None else {'cache-control': value}
                result = self.readback()
                self.assertFalse(result and result.get('found'), result)
                self.assertTrue(result and result.get('conflict'), result)
                self.assertIn('cache-control', result.get('publication_reason', ''))

    def test_wildcard_asset_cache_policy_is_checked_too(self):
        self.archive()
        self.headers['/assets/data.bin']['cache-control'] = 'public, max-age=14400'
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)
        self.assertIn('assets/data.bin', result.get('publication_reason', ''))

    def test_header_order_and_case_do_not_change_cache_control_meaning(self):
        self.archive()
        self.headers['/main.dart.js']['Cache-Control'] = self.headers['/main.dart.js'].pop('cache-control')
        self.headers['/main.dart.js']['Cache-Control'] = 'MUST-REVALIDATE, max-age=300, PUBLIC'
        result = self.readback()
        self.assertTrue(result and result.get('found'), result)

    def test_wrong_content_type_cannot_pass_even_when_asset_bytes_match(self):
        self.archive()
        self.headers['/.well-known/assetlinks.json']['content-type'] = 'text/html'
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)
        self.assertIn('content-type', result.get('publication_reason', ''))

    def test_deployment_configuration_hash_must_match_the_qualified_manifest(self):
        self.archive(tamper_control=True)
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)

    def test_uninterpreted_header_directives_do_not_silently_pass(self):
        self.control += b'  !Content-Security-Policy\n'
        self.archive()
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)

    def test_ordinary_underscore_file_remains_hash_checked(self):
        self.archive()
        self.live['_headers.txt'] = b'tampered ordinary asset'
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)
        self.assertIn('_headers.txt', result.get('publication_reason', ''))

    def test_tampered_application_bytes_still_fail_closed(self):
        self.archive()
        self.live['main.dart.js'] = b'tampered app'
        result = self.readback()
        self.assertFalse(result and result.get('found'), result)
        self.assertIn('main.dart.js', result.get('publication_reason', ''))


class WebEntrypointCacheTests(unittest.TestCase):
    def test_entrypoints_explicitly_require_revalidation_despite_a_proxy_ttl_floor(self):
        files = dict.fromkeys([
            'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'flutter.js',
            'assets/example', 'icons/example.png', 'landing-assets/example.png',
            '.well-known/assetlinks.json',
        ], '0' * 64)
        policy = RELEASE._web_header_policy((ROOT / 'web/_headers').read_bytes(), files)
        for name in ('flutter_bootstrap.js', 'main.dart.js'):
            with self.subTest(entrypoint=name):
                directives = {part.strip().lower()
                              for part in policy[name]['cache-control'].split(',')}
                self.assertTrue({'no-cache', 'no-store'} & directives,
                                'Entrypoints must not rely on a max-age that the zone minimum can raise')


if __name__ == '__main__':
    unittest.main()
