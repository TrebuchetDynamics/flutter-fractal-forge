import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig, devices } from 'playwright/test';

const root = fs.realpathSync(fileURLToPath(new URL('.', import.meta.url)));
const requested = process.env.UI_OVERLAY_CAPTURE_DIR;
if (!requested || !path.isAbsolute(requested)) {
  throw new Error('UI_OVERLAY_CAPTURE_DIR must be an absolute private directory outside the checkout');
}
const target = path.resolve(requested);
const output = path.join(fs.realpathSync(path.dirname(target)), path.basename(target));
if (output === root || output.startsWith(root + path.sep) || !path.relative(output, root).startsWith('..' + path.sep)) {
  throw new Error('UI_OVERLAY_CAPTURE_DIR must be outside the checkout and cannot contain it');
}
if (!fs.existsSync(output)) fs.mkdirSync(output, { mode: 0o700 });
const stat = fs.lstatSync(output);
if (!stat.isDirectory() || stat.uid !== process.getuid() || (stat.mode & 0o777) !== 0o700) {
  throw new Error(`UI_OVERLAY_CAPTURE_DIR must be an owned mode-0700 directory, not a symlink: ${output}`);
}
if (!process.env.TEST_WORKER_INDEX && fs.readdirSync(output).length) {
  throw new Error(`UI_OVERLAY_CAPTURE_DIR is not empty; choose a fresh capture directory: ${output}`);
}
const port = process.env.PLAYWRIGHT_PORT ?? execFileSync('python3', ['-c',
  'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'],
{ encoding: 'utf8', timeout: 3000 }).trim();
if (!/^\d{1,5}$/.test(port) || Number(port) < 1 || Number(port) > 65535) {
  throw new Error('PLAYWRIGHT_PORT must be an integer from 1 to 65535');
}
for (const file of ['index.html', 'flutter_bootstrap.js', 'main.dart.js']) {
  if (!fs.statSync(path.join(root, 'build/web', file), { throwIfNoEntry: false })?.isFile()) {
    throw new Error(`Missing build/web/${file}; run the documented Flutter web smoke build first`);
  }
}
// Claim even a pre-created empty directory exclusively, before Playwright
// can initialize or remove its diagnostics subdirectory.
if (!process.env.TEST_WORKER_INDEX) {
  try {
    fs.writeFileSync(path.join(output, '.capture-run'), `${process.pid}\n`, { flag: 'wx' });
  } catch (error) {
    if (error.code !== 'EEXIST') throw error;
    throw new Error(`UI_OVERLAY_CAPTURE_DIR is already claimed; choose a fresh capture directory: ${output}`);
  }
}
process.env.PLAYWRIGHT_PORT = port;
process.env.UI_OVERLAY_CAPTURE_DIR = output;
process.env.PLAYWRIGHT_OVERLAY_AUDIT = '1';
const baseURL = `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: './test/playwright',
  testMatch: 'ui-overlays-responsive.spec.mjs',
  timeout: 120_000,
  globalTimeout: 890_000,
  expect: { timeout: 4000 },
  workers: 1,
  reporter: [['list'], ['json', { outputFile: path.join(output, 'playwright.json') }]],
  outputDir: path.join(output, 'diagnostics'),
  use: {
    baseURL,
    actionTimeout: 4000,
    navigationTimeout: 20_000,
    serviceWorkers: 'block',
    reducedMotion: 'reduce',
    colorScheme: 'dark',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'], deviceScaleFactor: 1 } }],
  webServer: {
    command: `python3 -u -m http.server ${Number(port)} --bind 127.0.0.1 --directory build/web`,
    cwd: root,
    // Wait on our child's bind message, not on a port probe that could
    // mistake a process that won the allocation race for our server.
    wait: { stdout: new RegExp(`Serving HTTP on 127\\.0\\.0\\.1 port ${Number(port)} `) },
    reuseExistingServer: false,
    timeout: 10_000,
    stderr: 'pipe',
  },
});
