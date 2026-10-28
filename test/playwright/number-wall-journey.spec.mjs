import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { test, expect } from 'playwright/test';

// Run native first. These are actual native matrices/colours, not a second JS
// implementation of the determinant algorithm or an injected renderer.
const nativeDirectory = process.env.NUMBER_WALL_NATIVE_ARTIFACTS ||
  'test/results/number-wall-native';
const sources = ['signedPagoda', 'rook', 'thueMorse', 'rudinShapiro', 'fibonacci', 'squares'];
test.use({ viewport: { width: 1280, height: 900 }, launchOptions: { chromiumSandbox: true,
  ...(process.env.NUMBER_WALL_CHROMIUM ? { executablePath: process.env.NUMBER_WALL_CHROMIUM } : {}) } });
const sessionKey = 'flutter.viewer_session_v1';
const presetsKey = 'flutter.user_presets_number_wall';
const largePrime = '170141183460469231731687303715884105727';
const preset = (record, name, prime) => ({
  id: name, moduleId: 'number_wall', name,
  params: { ...record.params, prime },
  view: { panX: 0, panY: 0, zoom: 1, rotX: 0, rotY: 0, rotZ: 0 },
  createdAt: '2026-01-01T00:00:00.000', isBuiltIn: false, thumbnailPath: null,
});

async function enableSemantics(page) {
  const enable = page.getByRole('button', { name: /enable accessibility/i });
  await expect(enable).toBeVisible({ timeout: 60_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await expect(enable).toBeHidden();
}

async function savedSession(page) {
  return page.evaluate((key) => JSON.parse(JSON.parse(localStorage.getItem(key))), sessionKey);
}

// Opening the HUD moves the module title to its parent semantics group.
const wallCanvas = (page) => page.getByRole('group', { name: /^Interactive fractal canvas/ });

async function ready(page) {
  // When a retained-grid status replaces the visual backend text, the exact
  // backend remains on the renderer's accessible group (not an announcement).
  const backend = /^Exact integer field · (GPU|Canvas) display/;
  await expect(wallCanvas(page).getByRole('button', { name: backend })
    .or(wallCanvas(page).getByRole('group', { name: backend })))
    .toBeVisible({ timeout: 120_000 });
  await expect(wallCanvas(page).getByText('Computing exact finite-field wall…'))
    .toBeHidden({ timeout: 120_000 });
}

async function observeRetainedParams(page, params) {
  const start = Date.now();
  let samples = 0;
  // Deliberate post-cancel observation, not a readiness sleep. Do not issue a
  // newer request/export (which would advance ownership) during this interval.
  while (Date.now() - start < 2000) {
    expect((await savedSession(page)).params).toEqual(params);
    samples++;
    await page.waitForTimeout(100);
  }
  return { staleGuardMs: Date.now() - start, samples };
}

async function applyStoredPreset(page, name) {
  await page.getByRole('group', { name: /Interactive fractal canvas Number Walls/ })
    .click({ button: 'right', position: { x: 600, y: 300 }, force: true });
  await page.getByRole('menuitem', { name: /open presets/i }).click({ force: true });
  await page.mouse.move(600, 700);
  await page.mouse.wheel(0, 2000);
  const card = page.getByRole('group', { name, exact: true });
  await expect(card).toBeInViewport();
  await card.click({ position: { x: 30, y: 24 }, force: true });
}

async function compareVisibleCells(page, testInfo, name, record, view = record.view) {
  await ready(page);
  const bounds = await page.getByRole('group', { name: /Interactive fractal canvas Number Walls/ }).boundingBox();
  const screenshot = await page.screenshot({ path: testInfo.outputPath(`${name}-viewer.png`) });
  const visible = await page.evaluate(async ({ base64, record, bounds, view }) => {
    const bitmap = await createImageBitmap(new Blob([
      Uint8Array.from(atob(base64), (c) => c.charCodeAt(0))], { type: 'image/png' }));
    try {
      const canvas = document.createElement('canvas');
      canvas.width = bitmap.width; canvas.height = bitmap.height;
      const ctx = canvas.getContext('2d'); ctx.drawImage(bitmap, 0, 0);
      const data = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
      const samples = [];
      // Central, unobscured cells: exclude backend text, inspector and FABs.
      for (let row = Math.ceil(record.matrix.length * .15); row < record.matrix.length * .35; row++) {
        for (let col = 2; col < record.matrix[0].length * .7; col++) {
          const width = bounds.width * Math.min(16, Math.max(.25, view.zoom));
          const height = bounds.height * Math.min(16, Math.max(.25, view.zoom));
          const x = Math.floor(bounds.x + bounds.width / 2 * (1 + view.pan[0]) - width / 2 + (col + .5) * width / record.matrix[0].length);
          const y = Math.floor(bounds.y + bounds.height / 2 * (1 + view.pan[1]) - height / 2 + (row + .5) * height / record.matrix.length);
          if (x < 0 || y < 0 || x >= canvas.width || y >= canvas.height) continue;
          const i = (y * canvas.width + x) * 4;
          const argb = ((data[i + 3] << 24) | (data[i] << 16) | (data[i + 1] << 8) | data[i + 2]) >>> 0;
          const expected = record.colors[record.matrix[row][col]];
          const matches = [0, 8, 16, 24].every((shift) =>
            Math.abs(((argb >>> shift) & 255) - ((expected >>> shift) & 255)) <= (shift === 24 ? 0 : 1));
          samples.push({ row, col, actual: argb, expected, matches });
        }
      }
      return samples;
    } finally { bitmap.close(); }
  }, { base64: screenshot.toString('base64'), record, bounds, view });
  expect(visible.length).toBeGreaterThanOrEqual(
    Math.min(100, Math.floor(record.matrix.length * record.matrix[0].length / 8)));
  expect(visible.filter((p) => !p.matches), `${name}: real viewer cells (RGB tolerance 1 LSB)`).toEqual([]);
  fs.writeFileSync(testInfo.outputPath(`${name}-viewer-samples.json`), JSON.stringify({ view, samples: visible }));
}

async function exportAndCompare(page, testInfo, name, record) {
  await compareVisibleCells(page, testInfo, name, record);
  await page.getByRole('button', { name: /^More$/i }).click();
  await page.getByRole('button', { name: /export/i }).click();
  await page.getByRole('button', { name: /customize/i }).click();
  const hd = page.getByRole('checkbox', { name: /HD \(1280[×x]720\)/ });
  // Flutter's canvas sheet can still be animating after its semantics appear.
  // Observe the selected state before Save instead of racing a forced click.
  await expect(async () => {
    if (!await hd.isChecked()) await hd.click({ force: true });
    await expect(hd).toBeChecked({ timeout: 1000 });
  }).toPass({ timeout: 10_000 });
  const downloadPromise = page.waitForEvent('download', { timeout: 60_000 });
  await page.getByRole('button', { name: /save image/i }).first().click({ force: true });
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/\.png$/i);
  const file = testInfo.outputPath(`${name}.png`);
  await download.saveAs(file);
  // A browser image decoder unfilters/decompresses real downloaded PNG bytes.
  // Compare every cell, not just the PNG header or compressed byte diversity.
  const decoded = await page.evaluate(async ({ base64, record }) => {
    const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
    const bitmap = await createImageBitmap(new Blob([bytes], { type: 'image/png' }));
    try {
      const canvas = document.createElement('canvas');
      canvas.width = bitmap.width; canvas.height = bitmap.height;
      const context = canvas.getContext('2d');
      context.drawImage(bitmap, 0, 0);
      const rgba = context.getImageData(0, 0, canvas.width, canvas.height).data;
      const rows = record.matrix.length, columns = record.matrix[0].length;
      const reverse = new Map(Object.entries(record.colors).map(([v, c]) => [c >>> 0, v]));
      if (reverse.size !== Object.keys(record.colors).length) throw Error('Ambiguous residue colours');
      const matrix = Array.from({ length: rows }, (_, row) =>
        Array.from({ length: columns }, (_, col) => {
          const x = Math.floor((col + .5) * canvas.width / columns);
          const y = Math.floor((row + .5) * canvas.height / rows);
          const i = (y * canvas.width + x) * 4;
          const color = ((rgba[i + 3] << 24) | (rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2]) >>> 0;
          const candidates = [...reverse.entries()].filter(([expected]) =>
            [0, 8, 16, 24].every((shift) =>
              Math.abs(((color >>> shift) & 255) - ((expected >>> shift) & 255)) <= (shift === 24 ? 0 : 1)));
          if (candidates.length !== 1) throw Error(`Cell ${row},${col}: ${candidates.length} residue matches`);
          return candidates[0][1];
        }));
      return { width: bitmap.width, height: bitmap.height, matrix };
    } finally { bitmap.close(); }
  }, { base64: fs.readFileSync(file).toString('base64'), record });
  expect([decoded.width, decoded.height]).toEqual([1280, 720]);
  expect(decoded.matrix).toEqual(record.matrix);
  fs.writeFileSync(testInfo.outputPath(`${name}-matrix.json`), JSON.stringify(decoded));
  return createHash('sha256').update(fs.readFileSync(file)).digest('hex');
}

test('Number Walls native/browser artwork, replay and download journey', async ({ page, browser }, testInfo) => {
  test.setTimeout(15 * 60_000);
  const records = Object.fromEntries([...sources, 'replay-97', 'styled-97'].map((name) => [name,
    JSON.parse(fs.readFileSync(path.join(nativeDirectory, `${name}.json`), 'utf8'))]));
  const replay = records['replay-97'];
  await page.addInitScript(({ key, values }) => {
    if (localStorage.getItem('number-wall-import-seeded')) return;
    localStorage.setItem(key, JSON.stringify(JSON.stringify(values)));
    localStorage.setItem('number-wall-import-seeded', 'true');
  }, { key: presetsKey, values: [
    preset(replay, 'Composite replay', '561'),
    preset(replay, 'Unfinished replay', largePrime),
    preset(replay, 'Verified replay 97', '97'),
    { ...preset(records.squares, 'Worst grid', '2'), params: {
      ...records.squares.params, rows: 64, columns: 256 } },
  ] });
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  const [bundle] = await Promise.all([
    page.waitForResponse((r) => new URL(r.url()).pathname.endsWith('/main.dart.js')),
    page.goto('/', { waitUntil: 'domcontentloaded' }),
  ]);
  await enableSemantics(page);
  const search = page.getByRole('textbox', { name: /search by name/i }).last();
  await expect(search).toBeVisible();
  const searchBounds = await search.boundingBox();
  await page.mouse.click(searchBounds.x + 250, searchBounds.y + searchBounds.height / 2);
  await page.keyboard.press('Control+A');
  await page.keyboard.type('Number Walls');
  const card = page.locator('flt-semantics[aria-label*="Number Walls"]').first();
  await expect(card).toBeVisible();
  await expect(page.getByText('Computing exact finite-field wall…', { exact: true }))
    .toBeHidden({ timeout: 120_000 });
  await page.screenshot({ path: testInfo.outputPath('catalog-en.png') });
  const start = Date.now();
  await card.click({ force: true });
  await ready(page);
  const measurements = [{ job: 'catalog-default', elapsedMs: Date.now() - start }];
  const memorySamples = [];
  const sampleMemory = async (job) => memorySamples.push({ job,
    ...await page.evaluate(() => ({
      usedJsHeapBytes: performance.memory?.usedJSHeapSize ?? null,
      totalJsHeapBytes: performance.memory?.totalJSHeapSize ?? null,
    })) });
  await sampleMemory('default');
  expect((await savedSession(page)).params).toMatchObject(records.signedPagoda.params);
  const hashes = {};
  hashes.signedPagoda = await exportAndCompare(page, testInfo, 'signedPagoda', records.signedPagoda);

  for (const name of sources.slice(1)) {
    console.log(`Number Walls: selecting ${name}`);
    await page.getByRole('group', { name: /Interactive fractal canvas Number Walls/ })
      .click({ button: 'right', position: { x: 600, y: 300 }, force: true });
    await page.getByRole('menuitem', { name: /open controls/i }).click({ force: true });
    const label = { rook: 'Rook', thueMorse: 'Thue–Morse',
      rudinShapiro: 'Rudin–Shapiro', fibonacci: 'Fibonacci', squares: 'Squares' }[name];
    const option = page.getByRole('checkbox', { name: label, exact: true });
    await expect(async () => {
      if (!await option.isVisible()) {
        await page.mouse.move(600, 750);
        await page.mouse.wheel(0, 120);
      }
      await expect(option).toBeInViewport({ timeout: 500 });
    }).toPass({ timeout: 15_000 });
    const clock = Date.now();
    await option.click({ force: true });
    await expect.poll(async () => (await savedSession(page)).params.source,
      { timeout: 120_000 }).toBe(name);
    await ready(page);
    await page.getByRole('button', { name: /close this dialog/i }).click({ force: true });
    measurements.push({ job: name, elapsedMs: Date.now() - clock });
    await sampleMemory(name);
    hashes[name] = await exportAndCompare(page, testInfo, name, records[name]);
    console.log(`Number Walls: ${name} matrix and PNG match`);
  }

  // Imported persisted JSON is applied through the real preset cards.
  // Rejected candidates must not replace the currently committed grid.
  const committed = await savedSession(page);
  console.log('Number Walls: stored-preset replay checks');
  for (const [name, status] of [
    ['Composite replay', 'Invalid prime modulus; previous exact wall retained.'],
    ['Unfinished replay', 'Modulus unverified; previous exact wall retained.'],
  ]) {
    const clock = Date.now();
    await applyStoredPreset(page, name);
    await expect(wallCanvas(page).getByText(status)).toBeVisible({ timeout: 120_000 });
    expect((await savedSession(page)).params).toEqual(committed.params);
    measurements.push({ job: name, elapsedMs: Date.now() - clock });
    await page.screenshot({ path: testInfo.outputPath(`${name.replaceAll(' ', '-')}.png`) });
    await exportAndCompare(page, testInfo, name.replaceAll(' ', '-'), records.squares);
  }
  const applyVerifiedReplay = async () => {
    await applyStoredPreset(page, 'Verified replay 97');
    await expect.poll(async () => (await savedSession(page)).params,
      { timeout: 120_000 }).toEqual(replay.params);
    await ready(page);
  };
  await applyVerifiedReplay();
  hashes['replay-97'] = await exportAndCompare(page, testInfo, 'replay-97', replay);
  // Flutter's accessible canvas activation selects its centre cell.
  await wallCanvas(page).click({ force: true });
  await expect(wallCanvas(page).getByText(
    new RegExp(`Cell m=2, n=72, p=97, residue=${replay.matrix[2][8]}\\.`)))
    .toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('inspector-en.png') });

  // Completed worst-budget computation, then a second request cancelled by a
  // real newer camera edit. The recorded time includes UI/reconstruction.
  let clock = Date.now();
  await applyStoredPreset(page, 'Worst grid');
  await expect.poll(async () => (await savedSession(page)).params,
    { timeout: 120_000 }).toMatchObject({ rows: 64, columns: 256 });
  await ready(page);
  measurements.push({ job: 'completed-zero-window-256x64', elapsedMs: Date.now() - clock });
  await sampleMemory('completed-zero-window-256x64');
  await applyVerifiedReplay();
  const beforeCancel = await savedSession(page);
  clock = Date.now();
  await applyStoredPreset(page, 'Worst grid');
  await expect(wallCanvas(page).getByText('Computing exact finite-field wall…')).toBeVisible();
  await page.mouse.move(500, 350);
  await page.mouse.wheel(0, -100);
  await expect(wallCanvas(page).getByText('Check cancelled; previous wall retained.', { exact: true })).toBeVisible();
  expect((await savedSession(page)).params).toEqual(beforeCancel.params);
  const cancelFeedbackMs = Date.now() - clock;
  const cancelledView = (await savedSession(page)).view;
  expect(cancelledView.zoom).not.toBe(beforeCancel.view.zoom);
  const zeroGuard = await observeRetainedParams(page, beforeCancel.params);
  await compareVisibleCells(page, testInfo, 'cancelled-worst', replay, cancelledView);
  measurements.push({ job: 'cancel-zero-window-256x64', cancelFeedbackMs, ...zeroGuard });
  await applyVerifiedReplay();

  // A real UI edit, durable reload and same-state PNG, not seed-only readback.
  await page.getByRole('button', { name: /^More$/i }).click();
  await page.getByRole('button', { name: /^Color Scheme\. Long press for palette$/i }).click();
  await expect.poll(async () => (await savedSession(page)).params.colorScheme).not.toBe(replay.params.colorScheme);
  const styled = await savedSession(page);
  await page.goto('/');
  await enableSemantics(page);
  await ready(page);
  expect((await savedSession(page)).params).toEqual(styled.params);
  hashes['styled-97'] = await exportAndCompare(page, testInfo, 'styled-97', records['styled-97']);
  await page.getByRole('group', { name: /Interactive fractal canvas Number Walls/ })
    .click({ button: 'right', position: { x: 600, y: 300 }, force: true });
  await page.getByRole('menuitem', { name: 'Randomize', exact: true }).click({ force: true });
  await ready(page);
  await page.getByRole('group', { name: /Interactive fractal canvas Number Walls/ })
    .click({ button: 'right', position: { x: 600, y: 300 }, force: true });
  await page.getByRole('menuitem', { name: /open controls/i }).click({ force: true });
  await page.mouse.move(250, 750);
  await page.mouse.wheel(0, 3000);
  const undo = page.getByRole('button', { name: /undo randomization/i });
  await expect(undo).toBeInViewport();
  // Flutter's scroll semantics overlay intercepts pointer hit-testing here.
  // Activate the exposed accessibility action, not a guessed canvas position.
  await undo.dispatchEvent('click');
  await expect.poll(async () => (await savedSession(page)).params).toEqual(styled.params);
  await page.screenshot({ path: testInfo.outputPath('controls-en.png') });
  // Prime verification remains cancellable through its actual UI action.
  await page.mouse.wheel(0, -4000);
  const editor = page.getByRole('textbox', { name: /prime modulus/i });
  await expect(async () => {
    if (!await editor.isVisible()) {
      await page.mouse.move(600, 750);
      await page.mouse.wheel(0, 120);
    }
    await expect(editor).toBeInViewport({ timeout: 500 });
  }).toPass({ timeout: 15_000 });
  await editor.focus();
  await expect(editor).toBeFocused();
  // Wait for Flutter's activated input listener before replacing the old prime.
  await expect(editor).toHaveAttribute('autocorrect', 'on');
  await editor.press('Control+A');
  await editor.pressSequentially(largePrime, { delay: 20 });
  await expect(editor).toHaveValue(largePrime);
  clock = Date.now();
  // The scroll semantics intercept pointer hits here, as for Undo above.
  // Activate the exposed UI actions rather than guessing canvas coordinates.
  const applyPrime = page.getByRole('button', { name: /apply verified prime/i });
  await expect(applyPrime).toBeVisible();
  await expect(applyPrime).toBeEnabled();
  await applyPrime.dispatchEvent('click');
  const cancelPrime = page.getByRole('button', { name: 'Cancel', exact: true });
  await expect(cancelPrime).toBeVisible();
  await expect(cancelPrime).toBeEnabled();
  await cancelPrime.dispatchEvent('click');
  await expect(wallCanvas(page).getByText('Check cancelled; previous wall retained.', { exact: true })).toBeVisible();
  expect((await savedSession(page)).params).toEqual(styled.params);
  const largeFeedbackMs = Date.now() - clock;
  const largeGuard = await observeRetainedParams(page, styled.params);
  measurements.push({ job: 'cancel-large-prime', cancelFeedbackMs: largeFeedbackMs, ...largeGuard });
  await page.getByRole('button', { name: /close this dialog/i }).click({ force: true });
  await exportAndCompare(page, testInfo, 'after-cancel', records['styled-97']);

  const spanish = await browser.newContext({ locale: 'es-ES', viewport: { width: 320, height: 900 } });
  try {
    await spanish.addInitScript(({ key, state }) => {
      localStorage.setItem(key, JSON.stringify(JSON.stringify(state)));
      localStorage.setItem('flutter.accessibility_high_contrast', 'true');
    }, { key: sessionKey, state: styled });
    const narrow = await spanish.newPage();
    await narrow.goto(new URL('/', page.url()).href);
    await enableSemantics(narrow);
    await expect(narrow.locator('flt-semantics').getByText(/Campo entero exacto/)).toBeVisible({ timeout: 120_000 });
    await narrow.screenshot({ path: testInfo.outputPath('narrow-es-high-contrast.png') });
  } finally { await spanish.close(); }

  const environment = {
    source: process.env.NUMBER_WALL_SOURCE || null,
    bundleSha256: createHash('sha256').update(await bundle.body()).digest('hex'),
    browser: browser.version(), project: testInfo.project.name,
    viewport: page.viewportSize(), measurements, memorySamples, pngSha256: hashes,
    memoryLimitations: 'JS heap counters are observations, not process/GPU memory or leak certification.',
    visualStates: [
      { name: 'desktop-en', viewport: [1280, 900], locale: 'en', textScale: 1, highContrast: false },
      { name: 'narrow-es-high-contrast', viewport: [320, 900], locale: 'es-ES', textScale: 1, highContrast: true },
    ],
    runtime: await page.evaluate(() => ({ locale: navigator.language, dpr: devicePixelRatio,
      memory: performance.memory ? { used: performance.memory.usedJSHeapSize,
        total: performance.memory.totalJSHeapSize, limit: performance.memory.jsHeapSizeLimit } : null })),
  };
  if (browser.browserType().name() === 'chromium') {
    const cdp = await browser.newBrowserCDPSession();
    environment.gpu = (await cdp.send('SystemInfo.getInfo')).gpu;
    await cdp.detach();
  }
  expect(errors).toEqual([]);
  fs.writeFileSync(testInfo.outputPath('environment.json'), JSON.stringify(environment, null, 2));
});
