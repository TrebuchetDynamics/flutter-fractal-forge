import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('audit', ROOT / 'scripts/audit-linux-fractals.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


def view(name='default', verdict='pass', **changes):
    return dict(view=name, verdict=verdict, image='images/test.png', luminanceStdDev=30,
                dominantColorRatio=.2, edgeDensity=.1, edgeEnergy=.04, **changes)


def rendered():
    return dict(id='test', status='rendered', views=[view(), view('alternate')],
                measureStartUs=100, measureEndUs=200, requestedFrames=10)


class LinuxAuditTests(unittest.TestCase):
    def test_missing_timings_are_unmeasured_not_synthetic_sixty_fps(self):
        result = audit.critique(rendered(), [], 16.667)
        self.assertIsNone(result['performance']['rasterP95Ms'])
        self.assertEqual(result['action'], 'review')
        self.assertIn('unmeasured', ' '.join(result['critique']))

    def test_timings_exclude_other_modules_and_warmup(self):
        frames = [dict(startUs=n, rasterMs=8 if 100 <= n <= 200 else 500,
                       buildMs=2, totalMs=15) for n in range(50, 250, 10)]
        result = audit.critique(rendered(), frames, 16.667)
        self.assertEqual(result['performance']['samples'], 11)
        self.assertEqual(result['performance']['rasterP95Ms'], 8)
        self.assertEqual(result['action'], 'keep')

    def test_blank_views_require_fix_not_automatic_removal(self):
        row = rendered()
        row['views'] = [view(verdict='all-black'), view('alternate', 'blank')]
        result = audit.critique(row, [], 16.667)
        self.assertEqual(result['action'], 'fix')
        self.assertIn('failed repair', ' '.join(result['critique']))

    def test_failed_or_incomplete_capture_cannot_pass(self):
        for row in [dict(id='test', status='error'), dict(id='test', status='rendered', views=[view()])]:
            self.assertEqual(audit.critique(row, [], 16.667)['action'], 'fix')

    def test_low_color_structure_is_not_blank(self):
        row = rendered()
        row['views'][0]['dominantColorRatio'] = .98
        result = audit.critique(row, [], 16.667)
        self.assertEqual(result['action'], 'review')
        self.assertFalse(result['failures'])

    def test_report_accounts_for_missing_entries_and_escapes_content(self):
        with tempfile.TemporaryDirectory() as path:
            output = Path(path)
            report = audit.make_report(output, [dict(id='lost', name='<script>alert(1)</script>')], 16.667, {})
            self.assertEqual(report['selectedCount'], 1)
            self.assertEqual(report['recordedCount'], 0)
            self.assertEqual(report['counts'], {'fix': 1})
            suite = ET.parse(output / 'junit.xml').getroot()
            self.assertEqual(suite.attrib['tests'], '1')
            self.assertEqual(suite.attrib['failures'], '1')
            self.assertEqual(suite.find('testcase').attrib['name'], 'lost')
            self.assertIsNotNone(suite.find('testcase/failure'))
            page = (output / 'index.html').read_text()
            self.assertNotIn('<script>alert(1)</script>', page)
            self.assertIn('&lt;script&gt;', page)

    def test_partial_journal_is_recoverable(self):
        with tempfile.TemporaryDirectory() as path:
            journal = Path(path) / 'results.jsonl'
            journal.write_text(json.dumps({'id': 'done'}) + '\n{"id":')
            self.assertEqual(audit.read_jsonl(journal), [{'id': 'done'}])


class ProcessRecoveryTests(unittest.TestCase):
    def test_stalled_entry_is_recorded_and_remaining_entries_continue(self):
        import os
        import sys
        worker = '''import json, os, time
from pathlib import Path
p=Path(os.environ['FRACTAL_AUDIT_OUTPUT'])
for id in sorted(os.environ['FRACTAL_AUDIT_ONLY'].split(',')):
 (p/'active.json').write_text(json.dumps({'id':id}))
 if id=='a_stall': time.sleep(30)
 with (p/'results.jsonl').open('a') as f: f.write(json.dumps({'id':id,'status':'rendered'})+'\\n')
'''
        with tempfile.TemporaryDirectory() as path:
            output = Path(path)
            with (output / 'run.log').open('w') as log:
                audit.supervise([sys.executable, '-c', worker],
                                {**os.environ, 'FRACTAL_AUDIT_OUTPUT': path}, output,
                                {'a_stall', 'b_ok'}, .1, log)
            rows = {r['id']: r for r in audit.read_jsonl(output / 'results.jsonl')}
            self.assertEqual(rows['a_stall']['status'], 'error')
            self.assertEqual(rows['b_ok']['status'], 'rendered')

    def test_startup_failure_does_not_blame_a_fractal(self):
        import os
        import sys
        with tempfile.TemporaryDirectory() as path:
            output = Path(path)
            with (output / 'run.log').open('w') as log:
                audit.supervise([sys.executable, '-c', 'raise SystemExit(2)'],
                                os.environ.copy(), output, {'untested'}, .1, log)
            self.assertEqual(audit.read_jsonl(output / 'results.jsonl'), [])


if __name__ == '__main__':
    unittest.main()
