import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { chromium } from 'playwright';

const expected = 'NUMBER_WALL_PARITY_OK|971|196b53dc';
const scriptPath = process.argv[2];
if (!scriptPath) {
  throw new Error('Usage: node number-wall-model-parity.mjs <compiled-js>');
}
const resolvedScriptPath = resolve(scriptPath);
const script = await readFile(resolvedScriptPath);
const executablePath = process.env.CHROME_EXECUTABLE ?? '/usr/bin/chromium';

let browser;
try {
  browser = await chromium.launch({
    executablePath,
    headless: true,
    chromiumSandbox: true,
    timeout: 15000,
  });
  const page = await browser.newPage();
  let resolveMarker;
  let rejectMarker;
  const markerPromise = new Promise((resolvePromise, rejectPromise) => {
    resolveMarker = resolvePromise;
    rejectMarker = rejectPromise;
  });
  page.on('console', (message) => {
    const text = message.text();
    if (text.startsWith('NUMBER_WALL_PARITY_OK|')) resolveMarker(text);
  });
  page.on('pageerror', (error) => {
    console.error(`Chromium page error: ${error.stack ?? error.message}`);
    rejectMarker(error);
  });

  await page.goto('about:blank');
  await page.addScriptTag({ path: resolvedScriptPath });
  let timer;
  const marker = await Promise.race([
    markerPromise,
    new Promise((_, reject) => {
      timer = setTimeout(
        () => reject(new Error('Timed out waiting 15000ms for parity result')),
        15000,
      );
    }),
  ]).finally(() => clearTimeout(timer));
  if (marker !== expected) {
    throw new Error(`Unexpected browser parity result: ${marker}`);
  }

  console.log(
    JSON.stringify({
      result: 'pass',
      backend: 'Chromium via Playwright; chromiumSandbox=true; local script injection; no server',
      browserVersion: browser.version(),
      executablePath,
      fixtureCount: 971,
      fixtureFingerprint: '196b53dc',
      compiledJsSha256: createHash('sha256').update(script).digest('hex'),
    }),
  );
} finally {
  if (browser) await browser.close();
}
