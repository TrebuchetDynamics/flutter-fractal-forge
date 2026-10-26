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
      const colors = new Set();
      let transparentPixels = 0;
      let nonOpaquePixels = 0;
      for (let i = 0; i < rgba.length; i += 4) {
        if (i % 68 === 0) colors.add(`${rgba[i]},${rgba[i + 1]},${rgba[i + 2]}`);
        if (rgba[i + 3] === 0) transparentPixels++;
        if (rgba[i + 3] < 255) nonOpaquePixels++;
      }
      return {
        width: canvas.width,
        height: canvas.height,
        colors: colors.size,
        transparentPixels,
        nonOpaquePixels,
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
  await page.getByRole('button', { name: /^all dimensions$|^2D$|^3D$/i }).click();
  await page.getByRole('menuitemcheckbox', { name: new RegExp(`^${example.dimension} ·`) }).click();
  const search = page.getByRole('textbox', { name: /^Name, formula or family$/i });
  await expect(search).toBeVisible();
  await search.click();
  await expect(search).toBeFocused();
  // DOM focus precedes Flutter's text-input activation. The engine creates
  // this proxy with autocorrect=off, then applies the TextField's on setting
  // when its input listener is attached; typing earlier drops the first key.
  await expect(search).toHaveAttribute('autocorrect', 'on');
  await search.press('Control+A');
  await search.pressSequentially(example.name, { delay: 50 });
  await expect(search).toHaveValue(example.name);
  const result = page.locator(
    `flt-semantics[aria-label*="${example.name}"]`,
  ).first();
  await expect(result).toBeVisible();
  await result.click({ force: true });
  await expect(page.getByRole('button', { name: /back to catalog/i })).toBeVisible();
}

async function exportHdPng(page, testInfo, moduleName, { transparent = false } = {}) {
  await page.getByRole('button', { name: /viewer actions|acciones del visor/i }).click();
  await page.getByRole('menuitem', { name: /export/i }).click();

  await expect(page.getByText(/^(Export|Exportar)$/)).toBeVisible();
  await page.getByRole('button', { name: /customize|personalizar/i }).click();
  const hd = page.getByRole('checkbox', { name: /^HD \(1280[×x]720\)/ });
  await hd.focus();
  await hd.press('Space');
  await expect(hd).toBeChecked();
  if (transparent) {
    await page.getByRole('button', { name: /advanced options|opciones avanzadas/i }).click();
    const alpha = page.getByRole('switch', { name: /transparent background|fondo transparente/i });
    await alpha.focus();
    await alpha.press('Space');
    await expect(alpha).toBeChecked();
  }

  const downloadPromise = page.waitForEvent('download', { timeout: 30_000 });
  const saveButton = page.getByRole('button', { name: /save image|guardar imagen/i }).first();
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
  const portrait = page.viewportSize().width < page.viewportSize().height;
  expect([png.width, png.height]).toEqual(portrait ? [720, 1280] : [1280, 720]);
  const decoded = await decodedPngPixels(page, fs.readFileSync(filePath));
  expect(decoded.colors, 'download must contain actual rendered bands').toBeGreaterThan(6);
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

test('Fibonacci catalog edits restore and export the same finite experiment', async ({ page, browser }, testInfo) => {
  test.setTimeout(180_000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  const [webBundle] = await Promise.all([
    page.waitForResponse((response) => new URL(response.url()).pathname.endsWith('/main.dart.js')),
    page.goto('/', { waitUntil: 'domcontentloaded' }),
  ]);
  const enable = async (target) => {
    await expect(target.getByRole('button', { name: /enable accessibility/i })).toBeVisible({ timeout: 30_000 });
    await target.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await expect(target.getByRole('button', { name: /back to catalog|volver al catálogo/i })).toBeVisible();
  };
  // The first boot is the catalog, not a seeded viewer route.
  await expect(page.getByRole('button', { name: /enable accessibility/i })).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await openCatalogExample(page, { name: 'Fibonacci prime-degree Julia', dimension: '2D' });
  const saved = (target) => target.evaluate(() => JSON.parse(JSON.parse(
    localStorage.getItem('flutter.viewer_session_v1'))));
  await expect.poll(async () => (await saved(page))?.moduleId).toBe('fibonacci_complex_julia');
  expect((await saved(page)).params).toMatchObject({ iterations: 45, juliaCReal: -.2, juliaCImag: .25, bailout: 4 });
  await page.mouse.click(80, 200, { button: 'right' });
  await page.getByRole('menuitem', { name: /open controls/i }).click();
  const legend = page.getByText(/H_c\(z,w\) = \(zw\+c,z\)/);
  await expect(legend).toBeVisible();
  const legendEn = await legend.innerText();
  expect(legendEn).toContain('not proven bounded');
  expect(legendEn).toContain('F19 = 4181 = 37');
  expect(legendEn).toContain('Gold:');
  await page.screenshot({ path: testInfo.outputPath('fibonacci-en-legend.png') });
  for (const name of ['Iterations', 'Julia C (Real)', 'Julia C (Imag)']) {
    const slider = page.locator(`[aria-label="${name}"]`).getByRole('slider');
    await slider.scrollIntoViewIfNeeded();
    await slider.focus();
    await page.keyboard.press('ArrowLeft');
  }
  await page.getByRole('button', { name: /close this dialog/i }).click({ force: true });
  // Use the supported viewer keyboard actions with semantics enabled, rather
  // than rewriting storage or dragging the accessibility overlay.
  await page.getByRole('group', { name: /^Interactive fractal canvas/ }).click({ position: { x: 500, y: 200 }, force: true });
  await page.keyboard.press('ArrowRight');
  await page.keyboard.press('ArrowDown');
  await page.keyboard.press('-');
  await expect.poll(async () => (await saved(page)).view.zoom).not.toBe(1);
  const edited = await saved(page);
  expect(edited.params.iterations).toBe(44);
  expect(edited.params.juliaCReal).toBeCloseTo(-.21);
  expect(edited.params.juliaCImag).toBeCloseTo(.24);
  expect(edited.view.pan).not.toEqual([0, 0]);
  const first = await exportHdPng(page, testInfo, 'fibonacci-en-before-reload');
  const firstPixels = await decodedPngPixels(page, fs.readFileSync(first));
  await page.evaluate(() => history.replaceState(null, '', '/'));
  await page.reload({ waitUntil: 'domcontentloaded' });
  await enable(page);
  expect((await saved(page)).params).toEqual(edited.params);
  expect((await saved(page)).view).toEqual(edited.view);
  const second = await exportHdPng(page, testInfo, 'fibonacci-en-after-reload');
  const secondPixels = await decodedPngPixels(page, fs.readFileSync(second));
  expect(secondPixels).toEqual(firstPixels);
  expect(firstPixels.nonOpaquePixels).toBe(0);
  const alphaFile = await exportHdPng(page, testInfo, 'fibonacci-en-transparent', { transparent: true });
  const alphaPixels = await decodedPngPixels(page, fs.readFileSync(alphaFile));
  expect(alphaPixels.transparentPixels).toBeGreaterThan(0);
  expect(alphaPixels.transparentPixels).toBeLessThan(alphaPixels.width * alphaPixels.height);
  expect((await saved(page)).params).toEqual(edited.params);
  expect((await saved(page)).view).toEqual(edited.view);
  await retainJourneyEnvironment(page, testInfo, webBundle);

  // Replay the actual persisted EN session in a fresh ES browser profile.
  // Flutter derives web text scale from the root element's computed font size.
  const spanish = await browser.newContext({ locale: 'es-ES',
    viewport: { width: 320, height: 900 }, baseURL: testInfo.project.use.baseURL,
    reducedMotion: 'reduce', contrast: 'more' });
  let spanishObservation;
  try {
    await spanish.addInitScript((state) => {
      localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(JSON.stringify(state)));
      localStorage.setItem('flutter.accessibility_high_contrast', 'true');
      document.addEventListener('DOMContentLoaded', () => {
        document.documentElement.style.fontSize = '24px';
      });
    }, edited);
    const narrow = await spanish.newPage();
    narrow.on('pageerror', (error) => errors.push(error.message));
    await narrow.goto('/', { waitUntil: 'domcontentloaded' });
    await enable(narrow);
    fs.writeFileSync(testInfo.outputPath('fibonacci-es-initial-state.json'), JSON.stringify(await saved(narrow), null, 2));
    await narrow.screenshot({ path: testInfo.outputPath('fibonacci-es-initial.png') });
    fs.writeFileSync(testInfo.outputPath('fibonacci-es-initial-semantics.txt'), await narrow.locator('body').ariaSnapshot());
    await narrow.mouse.click(80, 200, { button: 'right' });
    await narrow.getByRole('menuitem', { name: /abrir controles/i }).click();
    const spanishLegend = narrow.getByText(/H_c\(z,w\) = \(zw\+c,z\)/);
    await spanishLegend.scrollIntoViewIfNeeded();
    await expect(spanishLegend).toBeVisible();
    const legendEs = await spanishLegend.innerText();
    expect(legendEs).toContain('no demuestra acotación');
    expect(legendEs).toContain('Dorado:');
    expect(legendEs).toContain('F19 = 4181 = 37');
    await narrow.screenshot({ path: testInfo.outputPath('fibonacci-es-narrow-large-contrast.png') });
    await narrow.getByRole('button', { name: /cerrar.*diálogo/i }).click({ force: true });
    const file = await exportHdPng(narrow, testInfo, 'fibonacci-es-restored');
    const pixels = await decodedPngPixels(narrow, fs.readFileSync(file));
    const restored = await saved(narrow);
    expect(pixels.nonOpaquePixels).toBe(0);
    expect(restored.params).toEqual(edited.params);
    expect(restored.view).toEqual(edited.view);
    // A narrow viewport changes the capture's aspect; compare same-state
    // repeats on that viewport, not a stretched desktop image.
    const repeated = await exportHdPng(narrow, testInfo, 'fibonacci-es-repeated');
    expect(await decodedPngPixels(narrow, fs.readFileSync(repeated))).toEqual(pixels);
    spanishObservation = { legend: legendEs, restored, pixels,
      runtime: await narrow.evaluate(() => ({ locale: navigator.language,
        rootFontPx: getComputedStyle(document.documentElement).fontSize,
        highContrast: localStorage.getItem('flutter.accessibility_high_contrast'),
        prefersContrast: matchMedia('(prefers-contrast: more)').matches })) };
    expect(spanishObservation.runtime.rootFontPx).toBe('24px');
  } finally {
    await spanish.close();
  }
  expect(errors).toEqual([]);
  const observation = { defaults: { c: [-.2, .25], N: 45, bailout: 4 },
    legendEn, edited, firstPixels, secondPixels, alphaPixels, spanish: spanishObservation,
    errors, limits: ['Android/human qualification not run',
      'CPU transparency refusal has focused native export checks; no browser CPU-alpha parity claim'] };
  fs.writeFileSync(testInfo.outputPath('fibonacci-observation.json'), JSON.stringify(observation, null, 2));
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
