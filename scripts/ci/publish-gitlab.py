#!/usr/bin/env python3
"""Publish only manifest-verified files to GitLab's package registry and release."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from urllib.error import HTTPError
from urllib.parse import quote
from urllib.request import Request, urlopen

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from generate_release_evidence import snapshot_asset_paths, sha256_file


def request(url, method='GET', payload=None):
    headers = {'JOB-TOKEN': os.environ['CI_JOB_TOKEN']}
    body = None
    if payload is not None:
        body = json.dumps(payload).encode()
        headers['Content-Type'] = 'application/json'
    with urlopen(Request(url, data=body, headers=headers, method=method), timeout=60) as response:
        return json.load(response)


def main():
    subprocess.run(['bash', 'scripts/ci/identity.sh'], check=True)
    version, build, commit = (os.environ[key] for key in
                              ('RELEASE_VERSION', 'RELEASE_BUILD_NUMBER', 'RELEASE_COMMIT'))
    base = f"{os.environ['CI_API_V4_URL']}/projects/{os.environ['CI_PROJECT_ID']}"
    release_url = f'{base}/releases/v{version}'
    try:
        existing = request(release_url)
        if existing['commit']['id'] != commit:
            raise RuntimeError('Existing GitLab release points to a different commit')
    except HTTPError as error:
        if error.code != 404:
            raise
        existing = None
    with tempfile.TemporaryDirectory() as directory:
        assets = snapshot_asset_paths(Path('release-artifacts/evidence/release-manifest.json'),
                                      Path(directory) / 'snapshot', expected_version=version,
                                      expected_build_number=build, expected_commit=commit)
        links = []
        for asset in assets:
            # Content-addressed URLs make retries immutable, even before a release exists.
            digest = sha256_file(asset)
            package_url = f'{base}/packages/generic/fractal-forge/{version}/{digest}-{quote(asset.name, safe="")}'
            # curl streams large binaries without loading them into memory. Token is
            # passed through a private temporary config, not command-line arguments.
            config = Path(directory) / 'curl.conf'
            config.write_text('header = "JOB-TOKEN: ' + os.environ['CI_JOB_TOKEN'] + '"\n')
            config.chmod(0o600)
            subprocess.run(['curl', '--fail', '--silent', '--show-error', '--config', str(config),
                            '--upload-file', str(asset), package_url], check=True, stdout=subprocess.DEVNULL)
            links.append({'name': asset.name, 'url': package_url, 'link_type': 'package'})
        payload = {'name': f'Fractal Forge {version}', 'tag_name': f'v{version}', 'ref': commit,
                   'description': f'Built and verified in {os.environ["CI_PIPELINE_URL"]}.\n\n'
                   'Android, Linux, Windows and web packages; unsigned macOS/iOS archives. '
                   'Apple signing/notarization and store submission are still required. '
                   'F-Droid metadata is provided for the official review/build process.',
                   'assets': {'links': links}}
        if existing:
            old = {item['name']: item['url'] for item in existing['assets']['links']}
            if old != {item['name']: item['url'] for item in links}:
                raise RuntimeError('Existing GitLab release asset set differs; refusing to replace it')
            print('Existing GitLab release matches verified assets')
        else:
            result = request(f'{base}/releases', 'POST', payload)
            print(result['_links']['self'])


if __name__ == '__main__':
    main()
