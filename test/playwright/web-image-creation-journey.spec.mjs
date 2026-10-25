import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { createHash } from 'node:crypto';
import { test, expect } from 'playwright/test';

async function retainJourneyEnvironment(page, testInfo, webBundle) {
  const browser = page.context().browser();
  const environment = {
    source: process.env.APP_QUALITY_SOURCE || null,
    webBundleUrl: webBundle.url(),
    webBundleSha256: createHash('sha256')
      .update(await webBundle.body()).digest('hex'),
    browserVersion: browser.version(),
    project: testInfo.project.name,
    viewport: page.viewportSize(),
    runtime: await page.evaluate(() => ({
      locale: navigator.language,
      devicePixelRatio: window.devicePixelRatio,
    })),
  };
  if (browser.browserType().name() === 'chromium') {
    const session = await browser.newBrowserCDPSession();
    try {
      const { gpu } = await session.send('SystemInfo.getInfo');
      environment.gpu = gpu;
    } finally {
      await session.detach();
    }
  }
  const environmentPath = testInfo.outputPath('journey-environment.json');
  fs.mkdirSync(path.dirname(environmentPath), { recursive: true });
  fs.writeFileSync(environmentPath, JSON.stringify(environment, null, 2));
  await testInfo.attach('journey-environment.json', {
    path: environmentPath,
    contentType: 'application/json',
  });
}

function inspectPng(bytes) {
  expect(bytes.subarray(0, 8).toString('hex')).toBe('89504e470d0a1a0a');
  let offset = 8;
  let width = 0;
  let height = 0;
  const idat = [];
  while (offset < bytes.length) {
    const length = bytes.readUInt32BE(offset);
    const type = bytes.toString('ascii', offset + 4, offset + 8);
    const data = bytes.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
    } else if (type === 'IDAT') {
      idat.push(data);
    }
    offset += length + 12;
    if (type === 'IEND') break;
  }
  const pixels = zlib.inflateSync(Buffer.concat(idat));
  const colors = new Set();
  for (let i = 1; i < pixels.length; i += 97) colors.add(pixels[i]);
  return { width, height, colors: colors.size };
}

async function decodedPngPixels(page, bytes) {
  return page.evaluate(async (base64) => {
    const binary = atob(base64);
    const pngBytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
    const bitmap = await createImageBitmap(
      new Blob([pngBytes], { type: 'image/png' }),
    );
    try {
      const canvas = document.createElement('canvas');
      canvas.width = bitmap.width;
      canvas.height = bitmap.height;
      const context = canvas.getContext('2d');
      context.drawImage(bitmap, 0, 0);
      const rgba = context.getImageData(0, 0, canvas.width, canvas.height).data;
      const digest = await crypto.subtle.digest('SHA-256', rgba);
      return {
        width: canvas.width,
        height: canvas.height,
        pixelHash: Array.from(new Uint8Array(digest), (byte) =>
          byte.toString(16).padStart(2, '0'),
        ).join(''),
      };
    } finally {
      bitmap.close();
    }
  }, bytes.toString('base64'));
}

async function openCatalogExample(page, example) {
  const search = page.getByRole('textbox', { name: /search by name/i }).last();
  await expect(search).toBeVisible();
  await page
    .getByRole('button', {
      name: new RegExp(`${example.dimension} filter`, 'i'),
    })
    .click({ force: true });
  const searchBounds = await search.boundingBox();
  await page.mouse.click(searchBounds.x + 250, searchBounds.y + searchBounds.height / 2);
  await page.keyboard.press('Control+A');
  await page.keyboard.type(example.name);
  const result = page.locator(
    `flt-semantics[aria-label*="${example.name}"]`,
  ).first();
  await expect(result).toBeVisible();
  await result.click({ force: true });
  await expect(page.getByRole('button', { name: /back to catalog/i })).toBeVisible();
}

async function exportHdPng(page, testInfo, moduleName) {
  await page.getByRole('button', { name: /viewer actions/i }).click();
  await page.getByRole('menuitem', { name: /export/i }).click();

  await expect(page.getByText('Export', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: /customize/i }).click();
  await page.getByRole('checkbox', { name: /HD \(1280[×x]720\)/ }).click({ force: true });
  await expect(page.getByText(/1280\s*[×x]\s*720/)).toBeVisible();

  const downloadPromise = page.waitForEvent('download', { timeout: 30_000 });
  const saveButton = page.getByRole('button', { name: /save image/i }).first();
  const saveBounds = await saveButton.boundingBox();
  await saveButton.click({ force: true });
  const download = await downloadPromise.catch(async (error) => {
    const diagnostics = await page.evaluate((bounds) => ({
      downloads: window.__journeyDownloads ?? [],
      clicks: window.__journeyClicks ?? [],
      bodyText: document.body.innerText.slice(-1500),
      saveBounds: bounds,
      browserMessages: window.__journeyConsole ?? [],
    }), saveBounds);
    throw new Error(`${error.message}; browser export diagnostics: ${JSON.stringify(diagnostics)}`);
  });
  expect(download.suggestedFilename()).toMatch(/\.png$/i);

  const filePath = testInfo.outputPath(`${moduleName}-edited.png`);
  await download.saveAs(filePath);
  const png = inspectPng(fs.readFileSync(filePath));
  expect(png.width).toBe(1280);
  expect(png.height).toBe(720);
  expect(png.colors, 'download must contain rendered image data').toBeGreaterThan(10);
  return filePath;
}

test(
  '2D and 3D catalog journeys export edited, mathematical HD PNGs',
  async ({ page }, testInfo) => {
  const browserErrors = [];
  await page.addInitScript(() => {
    window.__journeyDownloads = [];
    window.__journeyClicks = [];
    document.addEventListener('click', (event) => {
      const target = event.target;
      window.__journeyClicks.push({
        tag: target?.tagName,
        text: target?.textContent?.trim().slice(0, 100),
        aria: target?.getAttribute?.('aria-label'),
        x: event.clientX,
        y: event.clientY,
      });
    }, true);
    window.__journeyConsole = [];
    const log = console.log;
    console.log = (...args) => {
      window.__journeyConsole.push(args.map(String).join(' '));
      log.apply(console, args);
    };
    const error = console.error;
    console.error = (...args) => {
      window.__journeyConsole.push(args.map(String).join(' '));
      error.apply(console, args);
    };
    const click = HTMLAnchorElement.prototype.click;
    HTMLAnchorElement.prototype.click = function () {
      window.__journeyDownloads.push({ href: this.href, download: this.download });
      return click.call(this);
    };
  });
  page.on('pageerror', (error) => browserErrors.push(error.message));
  page.on('console', (message) => {
    const expectedWebGlDeprecation =
      /WEBGL_debug_renderer_info is deprecated/i.test(message.text());
    if (message.type() === 'error' && !expectedWebGlDeprecation) {
      browserErrors.push(message.text());
    }
  });

  const [webBundle] = await Promise.all([
    page.waitForResponse((response) =>
      new URL(response.url()).pathname.endsWith('/main.dart.js')),
    page.goto('/', { waitUntil: 'domcontentloaded' }),
  ]);
  // Flutter positions its semantics activator outside the viewport, so a
  // normal Playwright locator click cannot reach it. Wait for Flutter to
  // render it, invoke its DOM click handler, then use accessible controls.
  const enableAccessibility = page.getByRole('button', { name: /enable accessibility/i });
  await expect(enableAccessibility).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await expect(enableAccessibility).toBeHidden();

  const examples = [
    {
      name: 'Mandelbrot',
      moduleId: 'mandelbrot',
      dimension: '2D',
      formula: 'z(n+1) = z(n)^2 + c; z(0) = 0',
      qualification: /Source-reviewed recurrence/,
    },
    {
      name: 'Mandelbulb',
      moduleId: 'mandelbulb',
      dimension: '3D',
      formula: 'Unverified formula: this renderer has not been mathematically reviewed',
      qualification: /Unverified identity/,
    },
  ];
  for (const [index, example] of examples.entries()) {
    if (index > 0) {
      await page.getByRole('button', { name: /back to catalog/i }).click({ force: true });
    }
    await openCatalogExample(page, example);
    await expect(page.locator('canvas').first()).toBeVisible({ timeout: 30_000 });
    // Long-press the viewer's tune control to open its controls and current
    // mathematics disclosure; a short press would randomize parameters.
    const tune = page.getByRole('button', {
      name: /randomize.*controls|randomize with controls/i,
    });
    await tune.hover();
    await page.mouse.down();
    await page.waitForTimeout(900);
    await page.mouse.up();
    await expect(page.getByText(/current rule \/ formula/i)).toBeVisible();
    await expect(page.getByText(example.formula, { exact: true })).toBeVisible();
    await expect(page.getByText(example.qualification).first()).toBeVisible();

    const closeControls = page.getByRole('button', { name: /close this dialog/i });
    const closeBounds = await closeControls.boundingBox();
    await page.mouse.click(
      closeBounds.x + closeBounds.width / 2,
      closeBounds.y + closeBounds.height / 2,
    );
    await expect(page.getByText(/current rule \/ formula/i)).toBeHidden();
    // Change the color scheme through its visible viewer control, then verify
    // that the edit is persisted before export.
    const originalState = await page.evaluate(() => localStorage.getItem('flutter.viewer_session_v1'));
    const colorScheme = page.getByRole('button', { name: /color scheme/i });
    await colorScheme.click({ force: true });
    await expect
      .poll(() => page.evaluate(() => localStorage.getItem('flutter.viewer_session_v1')))
      .not.toBe(originalState);
    const stateBeforeExport = await page.evaluate(() => localStorage.getItem('flutter.viewer_session_v1'));
    const savedViewerState = JSON.parse(JSON.parse(stateBeforeExport));
    expect(savedViewerState.moduleId).toBe(example.moduleId);
    expect(stateBeforeExport).not.toBe(originalState);

    await exportHdPng(page, testInfo, example.name.toLowerCase());
    const stateAfterExport = await page.evaluate(() => localStorage.getItem('flutter.viewer_session_v1'));
    expect(stateAfterExport).toBe(stateBeforeExport);

  }

  expect(browserErrors).toEqual([]);
  expect(fs.existsSync(testInfo.outputPath('mandelbrot-edited.png'))).toBe(true);
  expect(fs.existsSync(testInfo.outputPath('mandelbulb-edited.png'))).toBe(true);
  await retainJourneyEnvironment(page, testInfo, webBundle);
});

test('sine sphere restores edits and exports a reduced-motion frozen PNG', async ({ page }, testInfo) => {
  test.setTimeout(180_000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  const session = {
    schemaVersion: 1, moduleId: 'recursive_sine_sphere',
    params: { depth: 2, strength: 0.65, radius: 1.2, phase: 0.4,
      steps: 256, colorScheme: 2, animate: true },
    view: { pan: [0.15, -0.1], zoom: 1.05, rotation: [0.45, -0.2, 0.1] },
    transparentBackground: false, rotationLocked: false,
    glowEnabled: false, glowSigma: 1, glowIntensity: 0.35,
    fluidModeEnabled: false, fluidStrength: 1,
    kaleidoscopeEnabled: false, kaleidoscopeSectors: 6,
    kaleidoscopeMirror: false, kaleidoscopeRotation: 0, kaleidoscopeMirrorMode: 0,
    controlsVisible: false, fullscreenUnobtrusive: false, viewerActive: true,
  };
  await page.addInitScript((seed) => {
    if (localStorage.getItem('sine-sphere-seeded')) return;
    localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(JSON.stringify(seed)));
    localStorage.setItem('sine-sphere-seeded', 'true');
  }, session);
  const [webBundle] = await Promise.all([
    page.waitForResponse((response) => new URL(response.url()).pathname.endsWith('/main.dart.js')),
    page.goto('/', { waitUntil: 'domcontentloaded' }),
  ]);
  const enable = async () => {
    const button = page.getByRole('button', { name: /enable accessibility/i });
    await expect(button).toBeVisible({ timeout: 30_000 });
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await expect(button).toBeHidden();
    await expect(page.getByRole('button', { name: /back to catalog/i })).toBeVisible();
  };
  const saved = () => page.evaluate(() => JSON.parse(JSON.parse(
    localStorage.getItem('flutter.viewer_session_v1'))));
  await enable();
  const clip = { x: 260, y: 200, width: 600, height: 400 };
  const screenshotHash = async (name) => {
    const bytes = await page.screenshot({ path: testInfo.outputPath(`${name}.png`), clip });
    return (await decodedPngPixels(page, bytes)).pixelHash;
  };
  await page.waitForTimeout(800);
  const animated = await screenshotHash('sine-animated-a');
  await page.waitForTimeout(800);
  expect(await screenshotHash('sine-animated-b')).not.toBe(animated);

  // Exercise an actual visible edit, then process restoration rather than just
  // reading the initial seed back from storage.
  await page.getByRole('button', { name: /color scheme/i }).click({ force: true });
  await expect.poll(async () => (await saved()).params.colorScheme).not.toBe(2);
  const edited = await saved();
  expect(edited.params).toMatchObject({ ...session.params, colorScheme: 3 });
  expect(edited.view).toEqual(session.view);
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.waitForTimeout(800);
  const editedPixels = await screenshotHash('sine-edited-before-reload');
  await page.evaluate(() => history.replaceState(null, '', '/'));
  await page.reload({ waitUntil: 'domcontentloaded' });
  await enable();
  await page.waitForTimeout(800);
  const frozen = await screenshotHash('sine-frozen-a');
  expect(frozen, 'restored renderer must reproduce the edited geometry/palette').toBe(editedPixels);
  await page.waitForTimeout(800);
  expect(await screenshotHash('sine-frozen-b')).toBe(frozen);
  const beforeExport = await saved();
  expect(beforeExport.params).toEqual(edited.params);
  expect(beforeExport.view).toEqual(edited.view);
  const first = await exportHdPng(page, testInfo, 'sine-sphere-frozen-a');
  const second = await exportHdPng(page, testInfo, 'sine-sphere-frozen-b');
  const firstPixels = await decodedPngPixels(page, fs.readFileSync(first));
  const secondPixels = await decodedPngPixels(page, fs.readFileSync(second));
  expect(firstPixels.pixelHash).toBe(secondPixels.pixelHash);
  expect(await saved()).toEqual(beforeExport);
  expect(errors).toEqual([]);
  await retainJourneyEnvironment(page, testInfo, webBundle);
  await testInfo.attach('sine-sphere-browser-observation.json', {
    body: Buffer.from(JSON.stringify({ seeded: session, edited, restored: beforeExport,
      restoredPixelsEqual: true, frozenScreenshotsEqual: true,
      firstPixels, secondPixels, errors }, null, 2)),
    contentType: 'application/json',
  });
});

test('Gaussian catalog walk exports a frozen paused PNG', async ({ page }, testInfo) => {
  const browserErrors = [];
  page.on('pageerror', (error) => browserErrors.push(error.message));
  page.on('console', (message) => {
    if (message.type() === 'error' &&
        !/WEBGL_debug_renderer_info is deprecated/i.test(message.text())) {
      browserErrors.push(message.text());
    }
  });
  await page.setViewportSize({ width: 1280, height: 900 });
  const [webBundle] = await Promise.all([
    page.waitForResponse((response) =>
      new URL(response.url()).pathname.endsWith('/main.dart.js')),
    page.goto('/', { waitUntil: 'domcontentloaded' }),
  ]);
  const enableAccessibility = page.getByRole('button', { name: /enable accessibility/i });
  await expect(enableAccessibility).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await expect(enableAccessibility).toBeHidden();

  await openCatalogExample(page, {
    name: 'Gaussian Prime Lattice',
    dimension: '2D',
  });
  const generationStartedAt = await page.evaluate(() => performance.now());
  await page.getByRole('button', { name: /^Walk$/i }).click({ force: true });
  const readyStatus = page
    .getByRole('group', { name: 'Controls' })
    .getByText(/Ready: .* exact primes/i);
  await expect(readyStatus).toBeVisible({ timeout: 30_000 });
  const browserObservation = await page.evaluate((startedAt) => ({
    domainHalfWidth: 32,
    generationToReadyMs: performance.now() - startedAt,
    jsHeapUsedBytes: performance.memory?.usedJSHeapSize ?? null,
  }), generationStartedAt);
  const readyText = await readyStatus.innerText();
  browserObservation.exactPointCount = Number(readyText.match(/Ready: (\d+) exact primes/i)?.[1]);
  await expect(page.getByText(/boundary/i).first()).toBeVisible();

  const saveGaussianPng = async (name) => {
    const exportButton = page.getByRole('button', { name: /^Export$/i }).last();
    await exportButton.focus();
    await page.keyboard.press('Enter');
    await expect(page.getByText('Export', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: /customize/i }).click();
    await page.getByRole('checkbox', { name: /HD \(1280[×x]720\)/ }).click({ force: true });
    await expect(page.getByText(/1280\s*[×x]\s*720/)).toBeVisible();
    const downloadPromise = page.waitForEvent('download', { timeout: 30_000 });
    await page.getByRole('button', { name: /save image/i }).first().click({ force: true });
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(/\.png$/i);
    const file = testInfo.outputPath(name);
    await download.saveAs(file);
    const pngBytes = fs.readFileSync(file);
    const decoded = inspectPng(pngBytes);
    expect(decoded.width).toBe(1280);
    expect(decoded.height).toBe(720);
    expect(decoded.colors).toBeGreaterThan(10);
    const raster = await decodedPngPixels(page, pngBytes);
    expect(raster.width).toBe(1280);
    expect(raster.height).toBe(720);
    return { ...decoded, pixelHash: raster.pixelHash };
  };

  const beforeWalk = await saveGaussianPng('gaussian-before-walk.png');
  for (const [name, value] of [['a', '1'], ['b', '-1']]) {
    const field = page.getByRole('textbox', { name });
    const bounds = await field.boundingBox();
    await page.mouse.click(
      bounds.x + bounds.width / 2,
      bounds.y + bounds.height / 2,
    );
    await page.keyboard.press('Home');
    await page.keyboard.press('Shift+End');
    await page.keyboard.type(value);
    await expect(field).toHaveValue(value);
  }
  await page.getByRole('button', { name: /select candidate/i }).click({ force: true });
  await expect(page.getByText(/Candidate: \(1, -1\)/)).toBeVisible();
  const stepButton = page.getByRole('button', { name: /step to candidate/i });
  await stepButton.focus();
  await page.keyboard.press('Enter');
  await expect(page.getByText(/Path: 1 steps/)).toBeVisible();
  await page.getByRole('button', { name: /play radius growth/i }).click({ force: true });
  await expect(page.getByRole('button', { name: /pause radius growth/i })).toBeVisible();
  await page.waitForTimeout(650);
  await page.getByRole('button', { name: /pause radius growth/i }).click({ force: true });
  await expect(page.getByRole('button', { name: /play radius growth/i })).toBeVisible();
  await page.getByRole('button', { name: /step to candidate/i }).focus();
  await page.keyboard.press('Enter');
  await expect(page.getByText(/Path: 1 steps/)).toBeVisible();

  const paused = await saveGaussianPng('gaussian-paused-walk.png');
  browserObservation.componentSize = Number(
    (await page.getByText(/Path: 1 steps/).innerText()).match(/component: (\d+) primes/i)?.[1],
  );
  browserObservation.pausedJsHeapUsedBytes = await page.evaluate(
    () => performance.memory?.usedJSHeapSize ?? null,
  );
  browserObservation.decodedPng = { width: paused.width, height: paused.height };
  browserObservation.browserErrors = browserErrors;
  await retainJourneyEnvironment(page, testInfo, webBundle);
  await testInfo.attach('gaussian-browser-observation.json', {
    body: Buffer.from(JSON.stringify(browserObservation, null, 2)),
    contentType: 'application/json',
  });
  console.log(`Gaussian browser observation: ${JSON.stringify(browserObservation)}`);
  expect(paused.pixelHash).not.toBe(beforeWalk.pixelHash);
  expect(browserErrors).toEqual([]);
  expect(fs.existsSync(testInfo.outputPath('gaussian-paused-walk.png'))).toBe(true);
});
