#!/usr/bin/env python3
"""Build/run the real Linux renderer, recover stalls, and rank catalog evidence."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import html
import hashlib
import json
import math
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def read_jsonl(path):
    if not path.exists():
        return []
    result = []
    for line in path.read_text().splitlines():
        try:
            result.append(json.loads(line))
        except json.JSONDecodeError:
            # A killed process can leave a partial final record.
            continue
    return result


def percentile(values, fraction):
    values = sorted(values)
    if not values:
        return None
    return values[min(len(values) - 1, max(0, math.ceil(len(values) * fraction) - 1))]


def critique(row, timings, budget):
    """Explain evidence; aesthetics are review hints, never deletion decisions."""
    views = row.get('views', [])
    failures, review = [], []
    if row.get('status') != 'rendered' or row.get('errors'):
        failures.append(row.get('error', 'Renderer reported an error; inspect run.log.'))
    if len(views) != 2:
        failures.append('Two captured views are required; coverage is incomplete.')
    blank = [v for v in views if v.get('verdict') in ('all-black', 'mostly-black', 'blank', 'transparent')]
    if blank:
        failures.append('Blank output in: ' + ', '.join(v['view'] for v in blank))
    for v in views:
        prefix = v['view'] + ': '
        if v.get('verdict') != 'pass':
            continue
        if v['luminanceStdDev'] < 10:
            review.append(prefix + 'Low luminance contrast; inspect palette separation.')
        if v['dominantColorRatio'] > 0.95:
            review.append(prefix + 'One color occupies over 95% of the view; inspect framing/detail.')
        if v['edgeDensity'] > 0.45:
            review.append(prefix + 'Dense high-frequency edges; inspect aliasing/noise at full size.')
        if v['edgeEnergy'] < 0.003:
            review.append(prefix + 'Very little spatial detail; inspect for a gradient-only rendering.')
    frames = [t for t in timings if row.get('measureStartUs', 0) <= t['startUs'] <= row.get('measureEndUs', -1)]
    raster = [f['rasterMs'] for f in frames]
    build = [f['buildMs'] for f in frames]
    p95 = percentile(raster, .95)
    performance = {
        'samples': len(frames), 'rasterP50Ms': percentile(raster, .5),
        'rasterP95Ms': p95, 'buildP95Ms': percentile(build, .95),
        'overBudgetRatio': sum(max(f['rasterMs'], f['buildMs']) > budget for f in frames) / len(frames) if frames else None,
        'frameBudgetMs': budget,
    }
    if len(frames) < max(5, row.get('requestedFrames', 20) // 2):
        review.append('Insufficient engine timing samples; performance is unmeasured, not passing.')
    elif max(p95, performance['buildP95Ms']) > budget:
        review.append(f'Frame work exceeds {budget:g} ms budget: raster p95 {p95:.2f} ms, build p95 {performance["buildP95Ms"]:.2f} ms. Retest on the same GPU before optimizing.')
    if row.get('loadMs', 0) > 2000:
        review.append(f'Renderer readiness took {row["loadMs"]:.0f} ms; inspect shader compilation/loading and rerun warm.')
    if failures:
        action = 'fix'
        if len(blank) == 2:
            review.append('Both views are blank: inspect uniforms/defaults, then consider retirement only after a failed repair and preset review.')
    else:
        action = 'review' if review else 'keep'
    return {**row, 'action': action, 'failures': failures, 'critique': review, 'performance': performance}


def make_report(output, selected, budget, metadata):
    raw = {r['id']: r for r in read_jsonl(output / 'results.jsonl')}
    timings = read_jsonl(output / 'timings.jsonl')
    rows = []
    for entry in selected:
        row = raw.get(entry['id'], {'id': entry['id'], 'status': 'missing', 'error': 'No result was recorded.'})
        rows.append({**entry, **critique(row, timings, budget)})
    # Exact coarse-luminance matches are hints, not proof of duplicate formulas.
    fingerprints = {}
    for row in rows:
        for view in row.get('views', [])[:1]:
            key = tuple(view.get('fingerprint', []))
            if view.get('verdict') == 'pass' and key:
                if key in fingerprints:
                    row['critique'].append(f'Default composition matches {fingerprints[key]} at coarse luminance resolution; compare formulas/presets before treating it as redundant.')
                    if row['action'] == 'keep':
                        row['action'] = 'review'
                else:
                    fingerprints[key] = row['id']
    rows.sort(key=lambda r: ({'fix': 0, 'review': 1, 'keep': 2}[r['action']], -(r['performance']['rasterP95Ms'] or 0), r['id']))
    counts = dict(Counter(r['action'] for r in rows))
    report = {**metadata, 'selectedCount': len(selected), 'recordedCount': sum(r['status'] != 'missing' for r in rows), 'counts': counts,
              'capturedViewCount': sum(len(r.get('views', [])) for r in rows),
              'timedCount': sum(r['performance']['samples'] >= max(5, r.get('requestedFrames', 20) // 2) for r in rows),
              'fractals': rows}
    (output / 'report.json').write_text(json.dumps(report, indent=2))
    suite = ET.Element('testsuite', name='Linux fractal audit', tests=str(len(rows)),
                       failures=str(counts.get('fix', 0)))
    for row in rows:
        case = ET.SubElement(suite, 'testcase', classname='FractalForge.Linux', name=row['id'])
        if row['failures']:
            ET.SubElement(case, 'failure', message='; '.join(row['failures'])).text = '\n'.join(row['failures'])
        ET.SubElement(case, 'system-out').text = '\n'.join(row['critique']) + '\n' + json.dumps(row['performance'])
    ET.ElementTree(suite).write(output / 'junit.xml', encoding='utf-8', xml_declaration=True)
    esc = html.escape
    cards = []
    for row in rows:
        images = ''.join(f'<a href="{esc(v["image"], quote=True)}"><img loading="lazy" src="{esc(v["image"], quote=True)}" alt="{esc(row["name"])} — {esc(v["view"])}"><span>{esc(v["view"])}</span></a>' for v in row.get('views', []))
        reasons = row['failures'] + row['critique'] or ['No measured issue in these two views. This is not a mathematical correctness certificate.']
        p = row['performance']
        timing = 'unmeasured' if p['rasterP95Ms'] is None else f'{p["rasterP95Ms"]:.2f} ms raster p95 / {p["buildP95Ms"]:.2f} ms build p95'
        cards.append(f'<article data-action="{row["action"]}" data-name="{esc(row["name"].lower() + " " + row["id"], quote=True)}"><h2>{esc(row["name"])} <small>{row["action"]}</small></h2><code>{esc(row["id"])}</code><p>{esc(timing)} · {p["samples"]} engine samples</p><div class="images">{images}</div><ul>{"".join("<li>" + esc(r) + "</li>" for r in reasons)}</ul><details><summary>Evidence and reproduction state</summary><pre>{esc(json.dumps(row, indent=2))}</pre></details></article>')
    page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Fractal Forge Linux audit</title>
<style>body{font:16px system-ui;margin:2rem auto;max-width:1120px;padding:0 1rem;background:#111318;color:#edf0f5}a{color:#a9d9ff}h1{font-size:2rem}small{font-size:1rem;color:#a9d9ff}article{border-top:1px solid #555;padding:1.5rem 0}.images{display:flex;gap:1rem;flex-wrap:wrap}.images a{display:grid;gap:.4rem}img{width:min(320px,80vw);height:auto}pre{white-space:pre-wrap;overflow-wrap:anywhere}input,select{font:inherit;padding:.6rem;margin:.5rem;color:inherit;background:#222;border:1px solid #777}li{margin:.5rem 0}[hidden]{display:none}</style>
<h1>Fractal Forge · Linux audit</h1>'''
    page += f'<p>{len(selected)} selected / {report["recordedCount"]} recorded · {report["capturedViewCount"]}/{2 * len(selected)} views · {report["timedCount"]} timed · {esc(str(counts))}</p>'
    page += '<p>Real profile-mode renderer. Two views per fractal. Visual heuristics suggest review, not beauty scores or automatic deletion. Timings describe this machine and viewport; software rendering is not a hardware GPU benchmark.</p>'
    page += f'<details><summary>Run environment</summary><pre>{esc(json.dumps(metadata, indent=2))}</pre></details>'
    page += '<label>Search <input id="search" type="search"></label><label>Action <select id="action"><option value="">All</option><option>fix</option><option>review</option><option>keep</option></select></label>'
    page += ''.join(cards)
    page += '''<script>const s=document.getElementById('search'),a=document.getElementById('action');function filter(){document.querySelectorAll('article').forEach(c=>c.hidden=!(c.dataset.name.includes(s.value.toLowerCase())&&(!a.value||c.dataset.action===a.value)));}s.addEventListener('input',filter);a.addEventListener('change',filter);</script></html>'''
    (output / 'index.html').write_text(page)
    return report


def stop(process):
    if process.poll() is None:
        os.killpg(process.pid, signal.SIGTERM)
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()


def supervise(command, env, output, ids, timeout, log):
    remaining = set(ids)
    last_status = time.monotonic()
    while remaining:
        active = output / 'active.json'
        active.unlink(missing_ok=True)
        process = subprocess.Popen(command, env={**env, 'FRACTAL_AUDIT_ONLY': ','.join(sorted(remaining))}, cwd=ROOT, stdout=log, stderr=log, start_new_session=True)
        last_progress = time.monotonic()
        previous = None
        try:
            while process.poll() is None:
                time.sleep(.5)
                progress = (active.stat().st_mtime_ns if active.exists() else 0,
                            (output / 'results.jsonl').stat().st_size if (output / 'results.jsonl').exists() else 0)
                if progress != previous:
                    previous, last_progress = progress, time.monotonic()
                if time.monotonic() - last_status >= 10:
                    done = {r['id'] for r in read_jsonl(output / 'results.jsonl')} & set(ids)
                    print(f'Audited {len(done)}/{len(ids)} fractals', flush=True)
                    last_status = time.monotonic()
                if time.monotonic() - last_progress > timeout:
                    stop(process)
                    break
        finally:
            stop(process)
        completed = {r['id'] for r in read_jsonl(output / 'results.jsonl')}
        remaining -= completed
        if not remaining:
            break
        current = json.loads(active.read_text())['id'] if active.exists() else None
        if current not in remaining:
            # Startup/infrastructure failure: do not mislabel every fractal bad.
            break
        with (output / 'results.jsonl').open('a') as journal:
            journal.write('\n' + json.dumps({'id': current, 'status': 'error', 'error': f'Linux audit process exited/stalled (code {process.returncode}); watchdog {timeout}s. Reproduce in isolation; see run.log.'}) + '\n')
        remaining.remove(current)
        print(f'Recovering after {current}; {len(remaining)} entries remain.', flush=True)


def run(args):
    if sys.platform != 'linux':
        raise ValueError('This audit runs on Linux.')
    output = Path(args.output).resolve()
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output directory must be empty; use a new path to avoid mixing measurements.')
    output.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env.update(FRACTAL_AUDIT_OUTPUT=str(output), FRACTAL_AUDIT_SIZE=str(args.size), FRACTAL_AUDIT_FRAMES=str(args.frames))
    if not args.skip_build:
        print(f'Building Linux audit app; log: {output / "build.log"}', flush=True)
        with (output / 'build.log').open('w') as build_log:
            subprocess.run(['flutter', 'build', 'linux', '--profile', '--target=integration_test/catalog/linux_fractal_audit.dart'], cwd=ROOT, stdout=build_log, stderr=subprocess.STDOUT, check=True)
    binary = ROOT / 'build/linux/x64/profile/bundle/flutter_fractals'
    if not binary.is_file():
        raise ValueError(f'Missing audit binary: {binary}')
    prefix = []
    if not env.get('DISPLAY'):
        if not shutil.which('xvfb-run'):
            raise ValueError('No DISPLAY; install xvfb and xauth for headless testing.')
        prefix = ['xvfb-run', '-a', '-s', '-screen 0 1280x1024x24']
    command = prefix + [str(binary)]
    metadata = {
        'schemaVersion': 1,
        'binarySha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
        'reusedBuild': args.skip_build,
        'startedUtc': datetime.now(timezone.utc).isoformat(), 'viewport': [args.size, args.size],
        'buildMode': 'profile', 'gitCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip()),
        'kernel': os.uname().release, 'machine': os.uname().machine,
        'softwareRenderingRequested': env.get('LIBGL_ALWAYS_SOFTWARE', ''),
        'timingNotes': 'Engine build/raster timings, warm-up excluded. p95 is descriptive with limited samples. No synthetic FPS fallback. Screenshots/readback excluded from timing interval.',
    }
    if shutil.which('glxinfo'):
        info = subprocess.run(prefix + ['glxinfo', '-B'], env=env, capture_output=True, text=True, timeout=30)
        metadata['graphics'] = info.stdout + info.stderr
    else:
        metadata['graphics'] = 'Unknown: install mesa-utils to record GL vendor/renderer.'
    with (output / 'run.log').open('w') as log:
        listing = subprocess.Popen(command, env={**env, 'FRACTAL_AUDIT_LIST_ONLY': '1'}, cwd=ROOT, stdout=log, stderr=log, start_new_session=True)
        try:
            code = listing.wait(timeout=90)
            if code:
                raise subprocess.CalledProcessError(code, command)
        finally:
            stop(listing)
        all_entries = json.loads((output / 'manifest.json').read_text())
        if not all_entries or len({e['id'] for e in all_entries}) != len(all_entries):
            raise ValueError('Catalog manifest is empty or contains duplicate IDs.')
        selected = all_entries
        if args.only:
            ids = set(args.only.split(','))
            missing = ids - {e['id'] for e in selected}
            if missing:
                raise ValueError(f'Unknown module IDs: {sorted(missing)}')
            selected = [e for e in selected if e['id'] in ids]
        if args.limit:
            selected = selected[:args.limit]
        metadata.update(catalogCount=len(all_entries), fullCatalog=len(selected) == len(all_entries))
        (output / 'run.json').write_text(json.dumps(metadata, indent=2))
        try:
            supervise(command, env, output, {e['id'] for e in selected}, args.timeout, log)
        finally:
            metadata['finishedUtc'] = datetime.now(timezone.utc).isoformat()
            report = make_report(output, selected, args.budget_ms, metadata)
    print(f'{report["recordedCount"]}/{len(selected)} recorded: {report["counts"]}\nReport: {output / "index.html"}')
    return 1 if report['counts'].get('fix') else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', default='build/fractal-audit/' + datetime.now().strftime('%Y%m%d-%H%M%S'))
    parser.add_argument('--only', help='Comma-separated registry IDs; default is ALL production fractals')
    parser.add_argument('--limit', type=int, help='Explicit smoke subset; report will mark partial coverage')
    parser.add_argument('--size', type=int, default=320)
    parser.add_argument('--frames', type=int, default=20)
    parser.add_argument('--timeout', type=int, default=120, help='Seconds without progress before process recovery')
    parser.add_argument('--budget-ms', type=float, default=16.667)
    parser.add_argument('--skip-build', action='store_true', help='Reuse the existing audit profile binary only')
    args = parser.parse_args()
    if not 64 <= args.size <= 1024 or args.frames < 10 or args.timeout < 10 or (not math.isfinite(args.budget_ms) or args.budget_ms <= 0) or (args.limit is not None and args.limit < 1):
        parser.error('Require size 64..1024, frames >=10, timeout >=10, budget >0, limit >0')
    try:
        return run(args)
    except KeyboardInterrupt:
        print('Audit interrupted; partial evidence retained in the output directory.', file=sys.stderr)
        return 130
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
