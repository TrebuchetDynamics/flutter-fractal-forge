import hashlib, json, os, pathlib, subprocess, time
root = pathlib.Path.cwd()
tmp = pathlib.Path(os.environ['TMPDIR'])
command = ['autowork-run', 'timeout', '--kill-after=10s', '960', 'bash', 'scripts/run-native-integration.sh', 'integration_test/flows/user_flows_test.dart', '--timeout', '900', '--dart-define=FORCE_GPU_RENDER=true']
observations = {'command': command, 'started_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), 'applications': []}
seen = set()
with (tmp / 'native-launch.log').open('w') as log:
    process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT)
    while process.poll() is None:
        parents = {}
        for p in pathlib.Path('/proc').glob('[0-9]*/stat'):
            try:
                parents[int(p.parent.name)] = int(p.read_text().rsplit(')', 1)[1].split()[1])
            except (OSError, ValueError, IndexError):
                pass
        descendants = {process.pid}
        while True:
            new = {pid for pid, parent in parents.items() if parent in descendants} - descendants
            if not new:
                break
            descendants.update(new)
        for pid in descendants - seen:
            try:
                exe = pathlib.Path(f'/proc/{pid}/exe').resolve()
                if exe.name != 'flutter_fractals':
                    continue
                maps = pathlib.Path(f'/proc/{pid}/maps').read_text()
                if 'libflutter_linux_gtk.so' not in maps:
                    continue
                seen.add(pid)
                env = dict(entry.split('=', 1) for entry in pathlib.Path(f'/proc/{pid}/environ').read_bytes().decode().split('\0') if '=' in entry)
                selected_env = {k: v for k, v in env.items() if k in ['DISPLAY', 'XAUTHORITY', 'LIBGL_ALWAYS_SOFTWARE', 'GALLIUM_DRIVER', 'MESA_LOADER_DRIVER_OVERRIDE', 'FLUTTER_ROOT', 'PUB_CACHE', 'TMPDIR']}
                (tmp / f'app-{pid}.maps').write_text(maps)
                paths = {str(exe)} | {line.split()[-1] for line in maps.splitlines() if line.split()[-1].startswith('/')}
                libraries = {}
                for filename in sorted(paths):
                    p = pathlib.Path(filename)
                    if p.is_file():
                        libraries[filename] = {'sha256': hashlib.sha256(p.read_bytes()).hexdigest(), 'bytes': p.stat().st_size}
                observation = {'pid': pid, 'exe': str(exe), 'environment': selected_env, 'mapped_files': libraries}
                if 'DISPLAY' in env:
                    probe = subprocess.run(['glxinfo', '-B'], env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=20)
                    observation['glxinfo_exit_code'] = probe.returncode
                    (tmp / f'app-{pid}-glxinfo.txt').write_text(probe.stdout)
                observations['applications'].append(observation)
                (tmp / 'runtime-observations.json').write_text(json.dumps(observations, indent=2) + '\n')
            except (OSError, ValueError, subprocess.TimeoutExpired) as e:
                observations.setdefault('sampling_errors', []).append(str(e))
        time.sleep(.2)
observations['exit_code'] = process.returncode
observations['finished_utc'] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
(tmp / 'runtime-observations.json').write_text(json.dumps(observations, indent=2) + '\n')
print((tmp / 'native-launch.log').read_text())
print('Runtime samples:', len(observations['applications']))
raise SystemExit(process.returncode)
