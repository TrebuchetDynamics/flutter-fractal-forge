// Captures clean, chrome-free, high-resolution marketing stills of the Featured
// Launch Set using curated deep-link coordinates.
//
// Each still opens the in-app chrome-free capture route
// (?smokeModule=<id>&capture=1&<coords>), which hides every overlay and applies
// the framing/params from test/playwright/launch-stills.coords.json, then
// screenshots the bare fractal canvas at a square, high-DPI viewport.
//
// Build the web bundle with PLAYWRIGHT_CATALOG_SMOKE=true first (the wrapper
// script scripts/capture-launch-stills.sh does this for you).
//
// Env knobs:
//   LAUNCH_STILLS_SIZE       square viewport size in CSS px (default 1080)
//   LAUNCH_STILLS_SCALE      device pixel ratio for crispness (default 2)
//   LAUNCH_STILLS_FILTER     regex to select a subset of ids
//   LAUNCH_STILLS_SETTLE_MS  ms to let shaders converge before capture (3000)
//   LAUNCH_STILLS_COORDS     path to the coords JSON (default colocated file)
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'playwright/test';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');

const SIZE = Number(process.env.LAUNCH_STILLS_SIZE || 1080);
const SCALE = Number(process.env.LAUNCH_STILLS_SCALE || 2);
const SETTLE_MS = Number(process.env.LAUNCH_STILLS_SETTLE_MS || 3000);
const COORDS_PATH = process.env.LAUNCH_STILLS_COORDS ||
  path.join(__dirname, 'launch-stills.coords.json');

// One square, high-DPI context for every still so the captured PNG is crisp.
test.use({ viewport: { width: SIZE, height: SIZE }, deviceScaleFactor: SCALE });

function loadStills() {
  const config = JSON.parse(fs.readFileSync(COORDS_PATH, 'utf8'));
  let stills = config.stills || [];
  if (process.env.LAUNCH_STILLS_FILTER) {
    const filter = new RegExp(process.env.LAUNCH_STILLS_FILTER);
    stills = stills.filter((still) => filter.test(still.id));
  }
  return stills;
}

function buildUrl(baseURL, still) {
  const url = new URL('/', baseURL);
  url.searchParams.set('smokeModule', still.id);
  url.searchParams.set('capture', '1');
  for (const [key, value] of Object.entries(still.query || {})) {
    url.searchParams.set(key, String(value));
  }
  return url.toString();
}

async function largestCanvasClip(page) {
  return page.locator('canvas').evaluateAll((canvases) => {
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const boxes = canvases
      .map((canvas) => {
        const rect = canvas.getBoundingClientRect();
        const x = Math.max(0, rect.left);
        const y = Math.max(0, rect.top);
        const width = Math.min(vw, rect.right) - x;
        const height = Math.min(vh, rect.bottom) - y;
        return { x, y, width, height, area: width * height };
      })
      .filter((box) => box.width >= 16 && box.height >= 16 && box.area > 0)
      .sort((a, b) => b.area - a.area);
    if (boxes.length === 0) return null;
    const box = boxes[0];
    return {
      x: Math.floor(box.x),
      y: Math.floor(box.y),
      width: Math.floor(box.width),
      height: Math.floor(box.height),
    };
  });
}

test('capture featured launch set stills', async ({ page, baseURL, browserName }, testInfo) => {
  const stills = loadStills();
  if (stills.length === 0) {
    throw new Error('launch-stills selected zero ids — check coords JSON / filter.');
  }
  const moduleTimeoutMs = Number(process.env.LAUNCH_STILLS_MODULE_TIMEOUT_MS || 25_000);
  testInfo.setTimeout(Math.max(testInfo.timeout, stills.length * (moduleTimeoutMs + SETTLE_MS + 10_000)));

  const outDir = path.join(repoRoot, 'test/results', 'launch-stills');
  fs.mkdirSync(outDir, { recursive: true });

  const manifest = [];

  for (const [index, still] of stills.entries()) {
    const id = still.id;
    const openMarker = `PLAYWRIGHT_CATALOG_SMOKE_OPENED:${id}`;
    const firstFrameMarker = `PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${id}`;
    let openedSeen = false;
    let firstFrameSeen = false;
    const onConsole = (message) => {
      const text = message.text();
      if (text.includes(openMarker)) openedSeen = true;
      if (text.includes(firstFrameMarker)) firstFrameSeen = true;
    };
    page.on('console', onConsole);

    const entry = { id, family: still.family, caption: still.caption, query: still.query || {} };
    try {
      const url = buildUrl(baseURL, still);
      entry.url = url;
      console.log(`[launch-stills] ${index + 1}/${stills.length} ${id}`);
      await page.goto(url, { waitUntil: 'domcontentloaded' });

      const opened = openedSeen
        ? true
        : await page.waitForEvent('console', {
            predicate: (m) => m.text().includes(openMarker),
            timeout: moduleTimeoutMs,
          }).then(() => true).catch(() => false);
      const firstFrame = firstFrameSeen
        ? true
        : await page.waitForEvent('console', {
            predicate: (m) => m.text().includes(firstFrameMarker),
            timeout: moduleTimeoutMs,
          }).then(() => true).catch(() => false);
      entry.opened = opened;
      entry.firstFrame = firstFrame;

      // Let the shader converge (deep iterations, palette animation settle).
      await page.waitForTimeout(SETTLE_MS);

      const clip = await largestCanvasClip(page);
      if (!clip) {
        entry.error = 'no canvas clip available';
        continue;
      }
      entry.clip = clip;
      entry.devicePixels = { width: clip.width * SCALE, height: clip.height * SCALE };

      const file = path.join(outDir, `${id}.png`);
      await page.screenshot({ path: file, clip, animations: 'disabled', timeout: 30_000 });
      entry.file = path.relative(repoRoot, file);
    } catch (error) {
      entry.error = String(error?.message || error).replace(/\s+/g, ' ').slice(0, 400);
    } finally {
      page.off('console', onConsole);
      manifest.push(entry);
    }
  }

  const manifestPath = path.join(outDir, 'manifest.json');
  fs.writeFileSync(
    manifestPath,
    JSON.stringify(
      { browserName, baseURL, size: SIZE, scale: SCALE, settleMs: SETTLE_MS, stills: manifest },
      null,
      2,
    ),
  );
  await testInfo.attach('launch-stills-manifest', { path: manifestPath, contentType: 'application/json' });

  const captured = manifest.filter((e) => e.file).length;
  const failed = manifest.filter((e) => !e.file);
  console.log(`[launch-stills] captured ${captured}/${manifest.length} → ${path.relative(repoRoot, outDir)}/`);
  for (const e of failed) {
    console.log(`[launch-stills] MISSING ${e.id}: ${e.error || 'no file'} (opened=${e.opened}, firstFrame=${e.firstFrame})`);
  }
});
