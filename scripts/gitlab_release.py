#!/usr/bin/env python3
"""Submit one immutable, all-platform GitLab release pipeline."""
import argparse
import datetime as dt
import json
import os
from pathlib import Path
import re
import shutil
import shlex
import subprocess
import sys
import time
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def glab_binary():
    cli = os.environ.get('GLAB_BIN') or shutil.which('glab')
    if not cli and Path('/tmp/glab-install/bin/glab').is_file():
        cli = '/tmp/glab-install/bin/glab'
    if not cli:
        raise RuntimeError('Install glab and log in to gitlab.com, or set GLAB_BIN')
    return cli


def api(endpoint, payload=None):
    cli = glab_binary()
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


def next_version():
    """Reuse an unpublished prepared marker; otherwise increment the latest patch."""
    tags = [(tuple(map(int, tag[1:].split('.'))), tag)
            for tag in git('tag', '--list').splitlines()
            if re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+', tag)]
    marker = dict(line.split('=', 1) for line in (ROOT / 'fdroid/version.properties').read_text().splitlines()
                  if line and not line.startswith('#'))
    current = tuple(map(int, marker['versionName'].split('.')))
    if str(current[2]) != marker['versionCode']:
        raise RuntimeError('F-Droid version marker has inconsistent version/build values')
    latest, tag = max(tags) if tags else (current, None)
    target = current if current > latest else (*latest[:2], latest[2] + 1)
    return '.'.join(map(str, target)), tag


def prepare_metadata(version, previous_tag):
    """Commit only release metadata; existing authored notes are preserved."""
    build = version.rsplit('.', 1)[1]
    marker = ROOT / 'fdroid/version.properties'
    original = marker.read_text()
    updated = re.sub(r'^versionName=.*$', f'versionName={version}', original, flags=re.M)
    updated = re.sub(r'^versionCode=.*$', f'versionCode={build}', updated, flags=re.M)
    changes = []
    if updated != original:
        marker.write_text(updated)
        changes.append(marker.relative_to(ROOT).as_posix())
    history = git('log', '--format=%s', f'{previous_tag}..HEAD' if previous_tag else 'HEAD', '-20')
    subjects = [line for line in history.splitlines() if not line.startswith('chore(release):')]
    notes = '\n'.join('- ' + line for line in subjects) or '- Release packaging update'
    store_notes = ROOT / f'fastlane/metadata/android/en-US/changelogs/{build}.txt'
    if not store_notes.exists():
        store_notes.parent.mkdir(parents=True, exist_ok=True)
        store_notes.write_text(notes[:499].rstrip() + '\n')
        changes.append(store_notes.relative_to(ROOT).as_posix())
    changelog = ROOT / 'CHANGELOG.md'
    text = changelog.read_text()
    if not re.search(r'^## \[' + re.escape(version) + r'\]', text, re.M):
        section = f'## [{version}] - {dt.date.today().isoformat()}\n\n{notes}\n\n'
        position = re.search(r'^## \[(?!Unreleased\])', text, re.M)
        index = position.start() if position else len(text)
        changelog.write_text(text[:index] + section + text[index:])
        changes.append('CHANGELOG.md')
    if changes:
        git('add', '--', *changes)
        git('commit', '-m', f'chore(release): prepare {version}', '--', *changes)


def automatic_release(project, branch):
    """Refresh tags, prepare the next release and synchronize both source hosts."""
    remote = api(f'projects/{project}/repository/branches/{quote(branch, safe="")}')
    if not remote.get('protected'):
        raise RuntimeError('Release pipelines require a protected GitLab branch')
    # Both named remotes are checked before creating any release commit.
    gitlab_url = git('remote', 'get-url', 'gitlab')
    expected_path = project.replace('%2F', '/')
    if not (gitlab_url.rstrip('/').removesuffix('.git').endswith('gitlab.com/' + expected_path)
            or gitlab_url.rstrip('/').removesuffix('.git').endswith('gitlab.com:' + expected_path)):
        raise RuntimeError('The gitlab remote does not match --project')
    helper = '!'+shlex.quote(glab_binary())+' auth git-credential'
    git('fetch', '--tags', 'origin', branch)
    git('-c', 'credential.helper=', '-c', 'credential.helper='+helper, 'fetch', '--tags', 'gitlab', branch)
    for ref in ('origin/' + branch, 'gitlab/' + branch):
        try:
            git('merge-base', '--is-ancestor', ref, 'HEAD')
        except subprocess.CalledProcessError:
            raise RuntimeError(f'{ref} contains changes absent locally; synchronize the branch first') from None
    version, previous_tag = next_version()
    print(f'[release] Preparing next release {version}', flush=True)
    prepare_metadata(version, previous_tag)
    git('push', 'origin', f'HEAD:refs/heads/{branch}')
    # Skip the redundant push pipeline; the API pipeline below runs every check.
    git('-c', 'credential.helper=', '-c', 'credential.helper='+helper,
        'push', '-o', 'ci.skip', 'gitlab', f'HEAD:refs/heads/{branch}')
    return version


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', nargs='?', choices=['all'], default='all')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--prepare', nargs='?', const='auto', metavar='X.Y.Z', help='Prepare next patch and verify all platforms without publication')
    mode.add_argument('--publish', nargs='?', const='auto', metavar='X.Y.Z', help='Full release (default); optionally select an explicit prepared version')
    parser.add_argument('--build-number', type=int)
    parser.add_argument('--dry-run', action='store_true', help='Print plan without network access or builds')
    parser.add_argument('--no-wait', action='store_true')
    parser.add_argument('--timeout', type=int, default=14400, help='Maximum seconds to wait (default 4 hours)')
    parser.add_argument('--project', default=os.environ.get('GITLAB_RELEASE_PROJECT', 'trebuchetdynamics/flutter-fractal-forge'))
    args = parser.parse_args(argv)
    version = args.publish or args.prepare or 'auto'
    automatic = version == 'auto'
    if not automatic and not re.fullmatch(r'[0-9]+\.[0-9]+\.[1-9][0-9]*', version):
        parser.error('Version must be X.Y.BUILD, with a positive build number')
    build = args.build_number if args.build_number is not None else (int(version.rsplit('.', 1)[1]) if not automatic else None)
    if not automatic and (build < 1 or str(build) != version.rsplit('.', 1)[1]):
        parser.error('Version patch and build number must match')
    if automatic and args.build_number is not None:
        parser.error('--build-number requires an explicit version')
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    mode_name = 'prepare' if args.prepare else 'publish'
    project = quote(args.project, safe='')
    if automatic:
        if args.dry_run:
            version, _ = next_version()
        else:
            if git('status', '--porcelain'):
                raise RuntimeError('Commit app changes first; release metadata is committed automatically')
            branch = git('symbolic-ref', '--quiet', '--short', 'HEAD')
            version = automatic_release(project, branch)
        build = int(version.rsplit('.', 1)[1])
    sha = git('rev-parse', 'HEAD')
    print(f'[release] GitLab {args.project}: {mode_name} {version or "<version>"} at {sha}', flush=True)
    print('[release] validate → Android device gate + Android/F-Droid/Linux/Windows/macOS/iOS/web builds'
          ' → F-Droid scan + verified evidence' +
          (' → GitLab release + GitHub draft + Cloudflare + Play' if mode_name == 'publish' else ' (no publication)'), flush=True)
    print('[release] Apple archives are unsigned; Apple signing/store submission and F-Droid acceptance remain external.', flush=True)
    if args.dry_run:
        print('[release] DRY RUN: cached tags only; no edits, commits, pushes, builds or publication.')
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
