"""Release dispatch regressions: no publication or network calls in tests."""
import importlib.util
from pathlib import Path
import subprocess
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

    def test_default_is_non_publishing(self):
        with patch.object(release, 'api', side_effect=AssertionError('network forbidden')):
            release.main([])

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
