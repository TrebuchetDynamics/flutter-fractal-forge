#!/usr/bin/env python3
"""Submit one immutable, all-platform GitLab release pipeline."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def api(endpoint, payload=None):
    cli = os.environ.get('GLAB_BIN') or shutil.which('glab')
    if not cli and Path('/tmp/glab-install/bin/glab').is_file():
        cli = '/tmp/glab-install/bin/glab'
    if not cli:
        raise RuntimeError('Install glab and log in to gitlab.com, or set GLAB_BIN')
    command = [cli, 'api', endpoint, '--hostname', 'gitlab.com']
    if payload is not None:
        command += ['--method', 'POST', '--header', 'Content-Type: application/json', '--input', '-']
    result = subprocess.run(command, input=json.dumps(payload) if payload is not None else None,
                            capture_output=True, text=True)
    if result.returncode:
        # Never echo credential-bearing CLI diagnostics.
        raise RuntimeError(f'GitLab API request failed: {endpoint}; check glab authentication/access')
    return json.loads(result.stdout)


def watch(project, pipeline, sha, timeout, interval=15):
    started = time.monotonic()
    failures = 0
    while time.monotonic() - started < timeout:
        try:
            state = api(f'projects/{project}/pipelines/{pipeline}')
        except RuntimeError:
            failures += 1
            if failures >= 4:
                raise RuntimeError('Could not read pipeline after 4 attempts')
            time.sleep(interval)
            continue
        failures = 0
        if state.get('sha') != sha:
            raise RuntimeError('Pipeline commit mismatch')
        status = state['status']
        print(f"[release] Pipeline {pipeline}: {status}", flush=True)
        if status == 'success':
            return
        if status in {'failed', 'canceled', 'skipped', 'manual'}:
            raise RuntimeError(f'Pipeline stopped: {status}; inspect {state["web_url"]}')
        time.sleep(interval)
    raise RuntimeError('Wait timed out; pipeline remains on GitLab. Open its URL to inspect runners/jobs.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', nargs='?', choices=['all'], default='all')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--prepare', metavar='X.Y.Z', help='Build and verify all platforms without publication')
    mode.add_argument('--publish', metavar='X.Y.Z', help='Build, verify, then publish all platforms')
    parser.add_argument('--build-number', type=int)
    parser.add_argument('--dry-run', action='store_true', help='Print plan without network access or builds')
    parser.add_argument('--no-wait', action='store_true')
    parser.add_argument('--timeout', type=int, default=14400, help='Maximum seconds to wait (default 4 hours)')
    parser.add_argument('--project', default=os.environ.get('GITLAB_RELEASE_PROJECT', 'tamez.jm/flutter-fractal-forge'))
    args = parser.parse_args(argv)
    version = args.publish or args.prepare
    if version and not re.fullmatch(r'[0-9]+\.[0-9]+\.[1-9][0-9]*', version):
        parser.error('Version must be X.Y.BUILD, with a positive build number')
    build = args.build_number if args.build_number is not None else (int(version.rsplit('.', 1)[1]) if version else None)
    if version and (build < 1 or str(build) != version.rsplit('.', 1)[1]):
        parser.error('Version patch and build number must match')
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    sha = git('rev-parse', 'HEAD')
    mode_name = 'publish' if args.publish else 'prepare'
    print(f'[release] GitLab {args.project}: {mode_name} {version or "<version>"} at {sha}', flush=True)
    print('[release] validate → Android device gate + Android/F-Droid/Linux/Windows/macOS/iOS/web builds'
          ' → F-Droid scan + verified evidence' +
          (' → GitLab release + GitHub draft + Cloudflare + Play' if args.publish else ' (no publication)'), flush=True)
    print('[release] Apple archives are unsigned; Apple signing/store submission and F-Droid acceptance remain external.', flush=True)
    if args.dry_run or not version:
        print('[release] DRY RUN. Execute with --prepare=X.Y.Z or --publish=X.Y.Z.')
        return
    if git('status', '--porcelain'):
        raise RuntimeError('Commit all release changes first; working tree must be clean')
    branch = git('symbolic-ref', '--quiet', '--short', 'HEAD')
    marker = dict(line.split('=', 1) for line in (ROOT / 'fdroid/version.properties').read_text().splitlines()
                  if line and not line.startswith('#'))
    if marker.get('versionName') != version or marker.get('versionCode') != str(build):
        raise RuntimeError('Commit fdroid/version.properties with the requested version/build first')
    project = quote(args.project, safe='')
    remote = api(f'projects/{project}/repository/branches/{quote(branch, safe="")}')
    if remote['commit']['id'] != sha:
        raise RuntimeError(f'Push this commit/branch to GitLab project {args.project} first')
    if not remote.get('protected'):
        raise RuntimeError('Release pipelines require a protected GitLab branch')
    payload = {'ref': branch, 'variables': [{'key': key, 'value': value} for key, value in {
        'RELEASE_MODE': mode_name, 'RELEASE_VERSION': version,
        'RELEASE_BUILD_NUMBER': str(build), 'RELEASE_COMMIT': sha,
    }.items()]}
    # Never retry POST: an ambiguous response must not produce duplicate releases.
    pipeline = api(f'projects/{project}/pipeline', payload)
    print(f'[release] {pipeline["web_url"]}', flush=True)
    if pipeline['sha'] != sha:
        raise RuntimeError('Branch moved during dispatch; CI identity gate will reject this pipeline')
    if not args.no_wait:
        watch(project, pipeline['id'], sha, args.timeout)


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f'[release] ERROR: {error}', file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print('[release] Stopped watching; pipeline continues on GitLab.', file=sys.stderr)
        sys.exit(130)
