"""Release dispatch regressions: no publication or network calls in tests."""
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('gitlab_release', ROOT / 'scripts/gitlab_release.py')
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class GitLabReleaseTest(unittest.TestCase):
    def test_dry_run_never_uses_api(self):
        with patch.object(release, 'api', side_effect=AssertionError('network forbidden')):
            release.main(['all', '--publish=1.1.105', '--dry-run'])

    def test_default_prepares_and_dispatches_full_release(self):
        sha = 'a' * 40
        # Metadata is prepared by the helper; use the current marker for this
        # dispatch-only test so it does not edit the user's checkout.
        marker = dict(line.split('=', 1) for line in (ROOT / 'fdroid/version.properties').read_text().splitlines()
                      if line and not line.startswith('#'))
        version = marker['versionName']
        def fake_git(*args):
            return {('rev-parse', 'HEAD'): sha, ('status', '--porcelain'): '',
                    ('symbolic-ref', '--quiet', '--short', 'HEAD'): 'main'}[args]
        with patch.object(release, 'git', side_effect=fake_git), \
             patch.object(release, 'automatic_release', return_value=version) as prepare, \
             patch.object(release, 'api', side_effect=[{'commit': {'id': sha}, 'protected': True},
                               {'sha': sha, 'id': 42, 'web_url': 'url'}]) as api, \
             patch.object(release, 'watch') as watch:
            release.main([])
            prepare.assert_called_once()
            payload = api.call_args.args[1]
            self.assertIn({'key': 'RELEASE_MODE', 'value': 'publish'}, payload['variables'])
            watch.assert_called_once()

    def test_next_patch_uses_numeric_tags_and_reuses_prepared_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'fdroid').mkdir()
            (root / 'fdroid/version.properties').write_text('versionName=1.1.104\nversionCode=104\n')
            with patch.object(release, 'ROOT', root), patch.object(release, 'git', return_value='v1.1.99\nv1.1.104\nv9.9.9-beta'):
                self.assertEqual(release.next_version(), ('1.1.105', 'v1.1.104'))
                (root / 'fdroid/version.properties').write_text('versionName=1.1.105\nversionCode=105\n')
                self.assertEqual(release.next_version(), ('1.1.105', 'v1.1.104'))

    def test_metadata_is_committed_and_retry_does_not_increment(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'fdroid').mkdir()
            (root / 'fdroid/version.properties').write_text('versionName=1.1.104\nversionCode=104\n')
            (root / 'CHANGELOG.md').write_text('# Changelog\n\n## [Unreleased]\n\n## [1.1.104]\n')
            with patch.object(release, 'ROOT', root):
                release.git('init', '-q')
                release.git('config', 'user.name', 'Release test')
                release.git('config', 'user.email', 'test@example.com')
                release.git('add', '.')
                release.git('commit', '-qm', 'Initial release')
                release.git('tag', 'v1.1.104')
                (root / 'app.txt').write_text('change')
                release.git('add', 'app.txt')
                release.git('commit', '-qm', 'Improve catalog scrolling')
                release.prepare_metadata('1.1.105', 'v1.1.104')
                head = release.git('rev-parse', 'HEAD')
                notes = root / 'fastlane/metadata/android/en-US/changelogs/105.txt'
                self.assertIn('Improve catalog scrolling', notes.read_text())
                self.assertLessEqual(len(notes.read_text()), 500)
                self.assertEqual(release.git('status', '--porcelain'), '')
                self.assertEqual(release.next_version()[0], '1.1.105')
                release.prepare_metadata('1.1.105', 'v1.1.104')
                self.assertEqual(release.git('rev-parse', 'HEAD'), head)

    def test_automatic_flow_fetches_before_preparing_and_pushes_both_hosts(self):
        calls = []
        def fake_git(*args):
            calls.append(args)
            if args[:3] == ('remote', 'get-url', 'gitlab'):
                return 'https://gitlab.com/trebuchetdynamics/flutter-fractal-forge.git'
            return ''
        with patch.object(release, 'api', return_value={'protected': True}), \
             patch.object(release, 'git', side_effect=fake_git), \
             patch.object(release, 'glab_binary', return_value='/tmp/glab'), \
             patch.object(release, 'next_version', return_value=('1.1.105', 'v1.1.104')), \
             patch.object(release, 'prepare_metadata', side_effect=lambda *args: calls.append(('metadata', *args))):
            self.assertEqual(release.automatic_release('trebuchetdynamics%2Fflutter-fractal-forge', 'main'), '1.1.105')
        metadata_index = next(i for i, call in enumerate(calls) if call[0] == 'metadata')
        self.assertEqual(sum('fetch' in call for call in calls[:metadata_index]), 2)
        pushes = [call for call in calls[metadata_index:] if 'push' in call]
        self.assertEqual(len(pushes), 2)
        self.assertIn('origin', pushes[0])
        self.assertIn('gitlab', pushes[1])
        self.assertIn('ci.skip', pushes[1])
        self.assertFalse(any('--force' in call for call in calls))

    def test_behind_remote_stops_before_metadata_or_push(self):
        def fake_git(*args):
            if args[:2] == ('remote', 'get-url'):
                return 'https://gitlab.com/trebuchetdynamics/flutter-fractal-forge.git'
            if args[0] == 'merge-base':
                raise subprocess.CalledProcessError(1, ['git', *args])
            return ''
        with patch.object(release, 'api', return_value={'protected': True}), \
             patch.object(release, 'git', side_effect=fake_git) as git, \
             patch.object(release, 'glab_binary', return_value='/tmp/glab'), \
             patch.object(release, 'prepare_metadata') as metadata:
            with self.assertRaisesRegex(RuntimeError, 'synchronize the branch'):
                release.automatic_release('trebuchetdynamics%2Fflutter-fractal-forge', 'main')
            metadata.assert_not_called()
            self.assertFalse(any('push' in call.args for call in git.call_args_list))

    def test_invalid_identity_fails_before_network(self):
        with patch.object(release, 'api', side_effect=AssertionError('network forbidden')):
            for args in [['--publish=1.1.105', '--build-number=104'], ['--publish=../105']]:
                with self.assertRaises(SystemExit):
                    release.main(args)

    def test_watcher_recovers_from_transient_failures(self):
        with patch.object(release, 'api', side_effect=[RuntimeError(), RuntimeError(),
                          {'sha': 'abc', 'status': 'success'}]) as api:
            release.watch('project', 12, 'abc', 1, interval=0)
            self.assertEqual(api.call_count, 3)

    def test_watcher_stops_after_four_api_failures(self):
        with patch.object(release, 'api', side_effect=RuntimeError()) as api:
            with self.assertRaisesRegex(RuntimeError, 'after 4 attempts'):
                release.watch('project', 12, 'abc', 1, interval=0)
            self.assertEqual(api.call_count, 4)

    def test_watcher_rejects_wrong_commit(self):
        with patch.object(release, 'api', return_value={'sha': 'other', 'status': 'success'}):
            with self.assertRaisesRegex(RuntimeError, 'commit mismatch'):
                release.watch('project', 12, 'abc', 1, interval=0)

    def test_failed_or_manual_pipeline_is_not_success(self):
        for status in ['failed', 'canceled', 'manual', 'skipped']:
            with patch.object(release, 'api', return_value={'sha': 'abc', 'status': status, 'web_url': 'url'}):
                with self.assertRaisesRegex(RuntimeError, status):
                    release.watch('project', 12, 'abc', 1, interval=0)

    def test_dispatch_binds_exact_commit_and_never_retries_post(self):
        marker = dict(line.split('=', 1) for line in (ROOT / 'fdroid/version.properties').read_text().splitlines()
                      if line and not line.startswith('#'))
        version = marker['versionName']
        sha = 'a' * 40
        def fake_git(*args):
            return {('rev-parse', 'HEAD'): sha, ('status', '--porcelain'): '',
                    ('symbolic-ref', '--quiet', '--short', 'HEAD'): 'main'}[args]
        with patch.object(release, 'git', side_effect=fake_git):
            with patch.object(release, 'api', side_effect=[{'commit': {'id': sha}, 'protected': True},
                              {'sha': sha, 'id': 42, 'web_url': 'https://gitlab.com/pipeline/42'}]) as api:
                release.main(['--prepare=' + version, '--no-wait'])
                self.assertEqual(api.call_count, 2)
                payload = api.call_args.args[1]
                self.assertEqual(payload['ref'], 'main')
                self.assertIn({'key': 'RELEASE_COMMIT', 'value': sha}, payload['variables'])
                self.assertIn({'key': 'RELEASE_MODE', 'value': 'prepare'}, payload['variables'])
            for remote in [{'commit': {'id': 'b' * 40}, 'protected': True},
                           {'commit': {'id': sha}, 'protected': False}]:
                with patch.object(release, 'api', return_value=remote) as api:
                    with self.assertRaises(RuntimeError):
                        release.main(['--publish=' + version, '--no-wait'])
                    self.assertEqual(api.call_count, 1)

    def test_identity_rejects_local_execution(self):
        result = subprocess.run(['env', '-u', 'GITLAB_CI', 'bash', 'scripts/ci/identity.sh'],
                                cwd=ROOT, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('protected GitLab ref', result.stderr)


if __name__ == '__main__':
    unittest.main()
