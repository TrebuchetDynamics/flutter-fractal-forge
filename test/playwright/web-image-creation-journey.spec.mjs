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
  const text = {};
  while (offset < bytes.length) {
    const length = bytes.readUInt32BE(offset);
    const type = bytes.toString('ascii', offset + 4, offset + 8);
    const data = bytes.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'tEXt') {
      const separator = data.indexOf(0);
      text[data.toString('latin1', 0, separator)] = data.toString('latin1', separator + 1);
    }
    offset += length + 12;
    if (type === 'IEND') break;
  }
  const pixels = zlib.inflateSync(Buffer.concat(idat));
  const colors = new Set();
  for (let i = 1; i < pixels.length; i += 97) colors.add(pixels[i]);
  return { width, height, colors: colors.size, text };
}

async function decodedPngPixels(page, bytes, reference) {
  return page.evaluate(async ({ png, comparison }) => {
    const decode = async (base64) => {
      const pngBytes = Uint8Array.from(atob(base64), (character) => character.charCodeAt(0));
      const bitmap = await createImageBitmap(new Blob([pngBytes], { type: 'image/png' }));
      try {
        const canvas = document.createElement('canvas');
        canvas.width = bitmap.width;
        canvas.height = bitmap.height;
        const context = canvas.getContext('2d');
        context.drawImage(bitmap, 0, 0);
        return context.getImageData(0, 0, canvas.width, canvas.height);
      } finally {
        bitmap.close();
      }
    };
    const { width, height, data: rgba } = await decode(png);
    let comparisonStats;
    if (comparison) {
      const before = await decode(comparison);
      if (before.width !== width || before.height !== height) {
        throw new Error('Viewer screenshot clip dimensions changed');
      }
      let changedPixels = 0;
      let maxChannelDelta = 0;
      for (let i = 0; i < rgba.length; i += 4) {
        let delta = 0;
        for (let c = 0; c < 4; c++) delta = Math.max(delta, Math.abs(rgba[i + c] - before.data[i + c]));
        if (delta) changedPixels++;
        maxChannelDelta = Math.max(maxChannelDelta, delta);
      }
      comparisonStats = { changedPixels, maxChannelDelta };
    }
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
      width, height, colors: colors.size, transparentPixels, nonOpaquePixels,
      pixelHash: Array.from(new Uint8Array(digest), (byte) =>
        byte.toString(16).padStart(2, '0'),
      ).join(''),
      ...(comparisonStats && { comparisonStats }),
    };
  }, { png: bytes.toString('base64'), comparison: reference?.toString('base64') });
}

async function openCatalogExample(page, example) {
  // Flutter exposes the hint as the editable input's name only while empty.
  // After returning from a viewer the retained query has no hint/name; the
  // separately labelled semantics wrapper is not the editable DOM control.
  const search = page.getByRole('textbox', { disabled: false });
  await expect(search).toBeVisible();
  await search.click();
  await expect(search).toBeFocused();
  // DOM focus precedes Flutter's text-input activation. The engine creates
  // this proxy with autocorrect=off, then applies the TextField's on setting
  // when its input listener is attached; typing earlier drops the first key.
  await expect(search).toHaveAttribute('autocorrect', 'on');
  if (await search.inputValue()) await page.keyboard.press('Control+A');
  // Narrow by name before requesting 3D previews, and insert in one input
  // event instead of making the production build render each partial query.
  await page.keyboard.insertText(example.name);
  await expect(search).toHaveValue(example.name);
  await page.getByRole('button', { name: /^all dimensions$|^2D$|^3D$/i }).click();
  await page.getByRole('menuitemcheckbox', { name: new RegExp(`^${example.dimension} ·`) }).click();
  // Match the whole card identity, not another name such as Bicomplex Mandelbrot.
  const escapedName = example.name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const result = page.getByRole('switch', {
    name: new RegExp(`^(?:Approximate preview; reduced quality )?${escapedName} fractal, ${example.dimension}(?: |$)`),
  });
  await expect(result).toBeVisible();
  // Activate the accessible card without targeting a nested thumbnail button.
  await result.evaluate((node) => node.click());
  await expect(page.getByRole('button', { name: /back to catalog/i })).toBeVisible();
}

async function openViewerMore(page) {
  // At large text scale the semantics overlay covers the rail button, so a
  // pointer click is intercepted. Invoke the node's click handler instead.
  await page.getByRole('button', { name: /^(Tools|Herramientas|More|Más)$/i })
    .evaluate((node) => node.click());
}

/// Open the parameter controls from the labelled viewer-actions sheet.
///
/// The "Parameter controls" entry is reached through Tools.
async function openParameterControls(page) {
  await openViewerMore(page);
  await page.getByRole('button', { name: /^(Parameter controls|Controles de parámetros)$/i }).click();
}

/// Expand the maths disclosure so the full legend is rendered.
async function expandMathDetails(page) {
  // The disclosure sits below the fold of the controls panel, so it must be
  // scrolled into view before Flutter reports it as stable.
  const details = page.getByRole('button', { name: /^(Formula details|Detalles de la fórmula)$/ });
  await details.first().scrollIntoViewIfNeeded();
  // Flutter web renders a semantics overlay above the tile, so invoke the
  // node's click handler instead of a pointer click.
  await details.first().evaluate((node) => node.click());
  await page.waitForTimeout(400);
}

async function exportHdPng(page, testInfo, moduleName, { transparent = false, observe } = {}) {
  // Export lives in the Save & share sheet, not in the Tools menu.
  await page.getByRole('button', { name: /^(Save & share|Guardar y compartir)$/i })
    .evaluate((node) => node.click());
  await page.getByRole('button', { name: /^(Export|Exportar)$/i }).click();

  const dialog = page.getByLabel(/^(Dialog|Cuadro de diálogo)$/);
  await expect(dialog.getByText(/^(Export|Exportar)$/)).toBeVisible();
  await page.getByRole('button', { name: /customize|personalizar/i }).click();
  const hd = page.getByRole('checkbox', { name: /^HD \(1280[×x]720\)/ });
  // On a narrow, large-text viewport the size options start below the fold.
  const viewport = page.viewportSize();
  for (let i = 0; i < 10 && (await hd.count()) === 0; i++) {
    await page.mouse.move(viewport.width / 2, viewport.height / 2);
    await page.mouse.wheel(0, 300);
    await page.waitForTimeout(200);
  }
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

  const saveButton = page.getByRole('button', { name: /save image|guardar imagen/i }).first();
  await expect(saveButton).toBeEnabled();
  const saveBounds = await saveButton.boundingBox();
  const downloadPromise = page.waitForEvent('download', { timeout: 30_000 });
  const startedAt = performance.now();
  const [download] = await Promise.all([downloadPromise, saveButton.click({ force: true })]).catch(async (error) => {
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
  const completedMs = performance.now() - startedAt;
  const bytes = fs.readFileSync(filePath);
  const png = inspectPng(bytes);
  const portrait = page.viewportSize().width < page.viewportSize().height;
  const dimensions = portrait ? [720, 1280] : [1280, 720];
  expect([png.width, png.height]).toEqual(dimensions);
  const decoded = await decodedPngPixels(page, bytes);
  expect([decoded.width, decoded.height]).toEqual(dimensions);
  if (observe) {
    observe({ completedMs, decoded, metadata: png.text });
  } else {
    expect(decoded.colors, 'download must contain actual rendered bands').toBeGreaterThan(6);
  }
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
    // Open the labeled primary control without randomizing the current rule.
    await openParameterControls(page);
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
    await openViewerMore(page);
    // The palette row's primary action cycles the colour scheme; the long-press
    // gesture that used to expose it is gone from the rail.
    const colorScheme = page.getByRole('button', { name: /^Next palette$/i });
    await colorScheme.click();
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
  await openViewerMore(page);
  await page.getByRole('button', { name: /^Next palette$/i }).click();
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
  await expandMathDetails(page);
  // The formula line and the full legend share a prefix; select the legend.
  const legend = page.getByText(/H_c\(z,w\) = \(zw\+c,z\), fixed c/);
  await expect(legend).toBeVisible();
  const legendEn = await legend.innerText();
  expect(legendEn).toContain('not proven bounded');
  expect(legendEn).toContain('F19 = 4181 = 37');
  expect(legendEn).toContain('Gold:');
  await page.screenshot({ path: testInfo.outputPath('fibonacci-en-legend.png') });
  for (const [name, parameter, expected] of [
    ['Iterations', 'iterations', 44],
    ['Julia C (Real)', 'juliaCReal', -.21],
    ['Julia C (Imag)', 'juliaCImag', .24],
  ]) {
    const slider = page.locator(`[aria-label="${name}"]`).getByRole('slider');
    await slider.scrollIntoViewIfNeeded();
    // The modal entrance temporarily disables the semantics range inputs.
    // focus() alone does not wait for actionability and can silently do nothing.
    await expect(slider).toBeEnabled();
    await slider.focus();
    await expect(slider).toBeFocused();
    await slider.press('ArrowLeft');
    await expect.poll(async () => (await saved(page)).params[parameter])
      .toBeCloseTo(expected);
  }
  await page.getByRole('button', { name: /close this dialog/i }).click({ force: true });
  // Wait for the closing modal to release its slider focus; otherwise the
  // following canvas arrow keys can still modify the last Julia parameter.
  await expect(page.getByRole('slider')).toHaveCount(0);
  // Use the supported viewer keyboard actions with semantics enabled, rather
  // than rewriting storage or dragging the accessibility overlay.
  const canvas = page.getByRole('group', { name: /^Interactive fractal canvas/ });
  await canvas.click({ position: { x: 500, y: 200 } });
  await expect(canvas).toBeFocused();
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
    await expandMathDetails(narrow);
    const spanishLegend = narrow.getByText(/H_c\(z,w\) = \(zw\+c,z\), c fijo/);
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
  const readyStatus = page.getByText(/^Ready: \d+ exact primes$/i);
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

const pilotBaseline = '059cc9783fe26bd65266c0f8c5cb3b3a244a607a';
const pilotModules = [
  { moduleId: 'mandelbrot', name: 'Mandelbrot', dimension: '2D', scheme: 1,
    shader: 'mandel_step_smooth.frag', glMarker: 'inMainBulb', alpha: true },
  { moduleId: 'burning_ship', name: 'Burning Ship', dimension: '2D', scheme: 1,
    shader: 'burning_ship_gpu.frag', glMarker: 'cpowReal', alpha: true },
  { moduleId: 'newton_z3', name: 'Newton Fractal (z³ - 1)', dimension: '2D', scheme: 2,
    shader: 'newton_z3_gpu.frag', glMarker: 'rootDistanceSq', alpha: false },
  { moduleId: 'mandelbulb', name: 'Mandelbulb', dimension: '3D', scheme: 4, legacy: 0,
    shader: 'mandelbulb.frag', glMarker: 'mandelbulbDE', alpha: true },
  { moduleId: 'mandelbox', name: 'Mandelbox', dimension: '3D', scheme: 8, legacy: 2,
    shader: 'mandelbox_3d_gpu.frag', glMarker: 'mandelboxDE', alpha: true,
    timingViewport: { width: 768, height: 540 } },
];

async function enableViewerSemantics(page) {
  const button = page.getByRole('button', { name: /enable accessibility/i });
  await expect(button).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await expect(button).toBeHidden();
}

async function readPilotSession(page) {
  return page.evaluate(() => JSON.parse(JSON.parse(
    localStorage.getItem('flutter.viewer_session_v1'))));
}

test.describe('Visual richness pilot', () => {
  test.use({ viewport: { width: 1280, height: 900 }, deviceScaleFactor: 1,
    locale: 'en-US', reducedMotion: 'reduce' });

  for (const example of pilotModules) {
    test(example.moduleId, async ({ page }, testInfo) => {
      test.setTimeout(example.timingViewport ? 1_200_000 : 600_000);
      const source = process.env.APP_QUALITY_SOURCE;
      expect(source, 'set APP_QUALITY_SOURCE to the served release source').toMatch(/^[a-f0-9]{40}(?:\+.+)?$/);
      const baseline = source === pilotBaseline;
      const observation = { source, baseline, moduleId: example.moduleId,
        rendered: false, exported: false, errors: [], screenshots: {}, exports: {} };
      const errors = observation.errors;
      const shaderResponses = [];
      page.on('response', (response) => {
        if (new URL(response.url()).pathname.endsWith(`/${example.shader}`)) shaderResponses.push(response);
      });
      page.on('pageerror', (error) => errors.push(error.message));
      page.on('crash', () => errors.push('Chromium page crashed'));
      page.on('console', (message) => {
        const text = message.text();
        if (text.includes('PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:') ||
            (message.type() === 'error' && !/WEBGL_debug_renderer_info is deprecated/i.test(text))) {
          errors.push(text);
        }
      });
      // Read-only observation at CanvasKit's WebGL boundary, not just a shader
      // request (the catalog also loads preview shaders). Do not replace draws.
      await page.addInitScript((marker) => {
        const matches = new WeakSet();
        window.__pilotLinkedShaders = [];
        for (const api of [window.WebGLRenderingContext, window.WebGL2RenderingContext]) {
          const { shaderSource, attachShader, linkProgram } = api.prototype;
          api.prototype.shaderSource = function (shader, code) {
            if (code.includes(`flutter_local_${marker}_`)) matches.add(shader);
            return shaderSource.call(this, shader, code);
          };
          const programs = new WeakMap();
          api.prototype.attachShader = function (program, shader) {
            if (matches.has(shader)) programs.set(program, shader);
            return attachShader.call(this, program, shader);
          };
          api.prototype.linkProgram = function (program) {
            linkProgram.call(this, program);
            if (programs.has(program)) {
              window.__pilotLinkedShaders.push({ marker,
                linked: this.getProgramParameter(program, this.LINK_STATUS) });
            }
          };
        }
      }, example.glMarker);
      const canvas = page.getByRole('group', { name: /^Interactive fractal canvas/ });
      const clip = { x: 128, y: 162, width: 1024, height: 576 };
      observation.screenshotClip = clip;
      const observeBackend = async () => {
        await expect.poll(() => page.evaluate(() => window.__pilotLinkedShaders),
          { message: `CanvasKit WebGL program for ${example.shader}`, timeout: 30_000 })
          .toContainEqual({ marker: example.glMarker, linked: true });
        await expect(page.getByText(/Failed to load shader|CPU fallback enabled|High precision \(CPU\)/i))
          .toHaveCount(0);
        expect(errors, 'runtime errors or a cap-10 catalog smoke build').toEqual([]);
      };
      const screenshot = async (label, compareTo) => {
        const bytes = await page.screenshot({ path: testInfo.outputPath(`${label}.png`), clip });
        const reference = compareTo && fs.readFileSync(compareTo);
        const pixels = await decodedPngPixels(page, bytes, reference);
        observation.screenshots[label] = pixels;
        if (reference) {
          // Across documents SwiftShader's composited pixels can differ by
          // one channel level in a sparse set of pixels. Keep exact RGBA
          // equality for repeated downloads, not this presentation boundary.
          expect(pixels.comparisonStats.maxChannelDelta).toBeLessThanOrEqual(1);
          expect(pixels.comparisonStats.changedPixels).toBeLessThanOrEqual(pixels.width * pixels.height / 1000);
        }
        return pixels.pixelHash;
      };
      const boot = async (navigate) => {
        const [bundle] = await Promise.all([
          page.waitForResponse((response) => new URL(response.url()).pathname === '/main.dart.js'),
          navigate(),
        ]);
        expect(bundle.ok()).toBe(true);
        await enableViewerSemantics(page);
        return bundle;
      };
      const reload = async (expected) => {
        // The root route restores the durable session, not a viewer deep link.
        await page.evaluate(() => history.replaceState(null, '', '/'));
        const bundle = await boot(() => page.reload({ waitUntil: 'domcontentloaded' }));
        expect(createHash('sha256').update(await bundle.body()).digest('hex'))
          .toBe(observation.bundleSha256);
        await expect(canvas).toBeVisible();
        await observeBackend();
        await expect.poll(() => readPilotSession(page)).toEqual(expected);
        return readPilotSession(page);
      };
      const save = async (label, state, transparent = false) => {
        expect(await readPilotSession(page)).toEqual(state);
        let result;
        await exportHdPng(page, testInfo, label, { transparent, observe: (value) => {
          result = value;
          observation.exports[label] = value;
        } });
        expect(result.metadata.UserComment).toContain(`Fractal Type: ${example.moduleId}\n`);
        expect(result.metadata.UserComment).toContain(`  colorScheme: ${state.params.colorScheme}\n`);
        const { decoded } = result;
        if (transparent && example.alpha) {
          expect(decoded.transparentPixels).toBeGreaterThan(0);
          expect(decoded.nonOpaquePixels).toBeLessThan(decoded.width * decoded.height);
        } else {
          expect(decoded.nonOpaquePixels).toBe(0);
        }
        await expect.poll(() => readPilotSession(page)).toEqual(state);
        return result;
      };
      const nextPalette = async (value) => {
        await openViewerMore(page);
        await page.getByRole('button', { name: /^Next palette$/i }).click();
        await expect.poll(async () => (await readPilotSession(page)).params.colorScheme).toBe(value);
      };
      try {
        const bundle = await boot(() => page.goto('/', { waitUntil: 'domcontentloaded' }));
        await retainJourneyEnvironment(page, testInfo, bundle);
        const environment = JSON.parse(fs.readFileSync(testInfo.outputPath('journey-environment.json')));
        observation.bundleSha256 = environment.webBundleSha256;
        await openCatalogExample(page, example);
        await expect(canvas).toBeVisible();
        await expect.poll(() => shaderResponses.some((response) => response.ok()),
          { message: `served ${example.shader}`, timeout: 30_000 }).toBe(true);
        const shader = shaderResponses.find((response) => response.ok());
        await expect.poll(async () => (await readPilotSession(page))?.moduleId).toBe(example.moduleId);
        observation.default = await readPilotSession(page);
        observation.pane = await canvas.boundingBox();
        await page.screenshot({ path: testInfo.outputPath('default-pane.png') });
        await observeBackend();
        const defaultHash = await screenshot('default');
        observation.backend = { path: 'FragmentProgram/FractalCanvas via CanvasKit WebGL', asset: shader.url(),
          assetSha256: createHash('sha256').update(await shader.body()).digest('hex'),
          linkedPrograms: await page.evaluate(() => window.__pilotLinkedShaders) };
        observation.rendered = true;
        if (baseline) {
          expect(errors).toEqual([]);
          return; // Archive the independent old build, never qualify it here.
        }

        expect(observation.default.params.colorScheme).toBe(example.scheme);
        const oldFile = path.join(process.env.APP_QUALITY_PILOT_BASELINE_DIR || '',
          path.basename(testInfo.outputDir), 'pilot-observation.json');
        expect(fs.existsSync(oldFile), `capture baseline with APP_QUALITY_SOURCE=${pilotBaseline}; missing ${oldFile}`).toBe(true);
        const old = JSON.parse(fs.readFileSync(oldFile));
        const oldEnv = JSON.parse(fs.readFileSync(path.join(path.dirname(oldFile), 'journey-environment.json')));
        expect(old).toMatchObject({ source: pilotBaseline, moduleId: example.moduleId, rendered: true, errors: [] });
        expect(old.bundleSha256).not.toBe(observation.bundleSha256);
        expect(oldEnv.source).toBe(pilotBaseline);
        expect(oldEnv.webBundleSha256).toBe(old.bundleSha256);
        expect(oldEnv.browserVersion).toBe(environment.browserVersion);
        expect(oldEnv.gpu.devices).toEqual(environment.gpu.devices);
        expect(oldEnv.viewport).toEqual(environment.viewport);
        expect(oldEnv.runtime).toEqual(environment.runtime);
        expect(old.screenshotClip).toEqual(clip);
        const oldClip = path.join(path.dirname(oldFile), 'default.png');
        expect(fs.existsSync(oldClip), `missing original baseline clip ${oldClip}`).toBe(true);
        expect((await decodedPngPixels(page, fs.readFileSync(oldClip))).pixelHash)
          .toBe(old.screenshots.default.pixelHash);

        await nextPalette(example.legacy === undefined ? example.scheme + 1 : 0);
        for (let value = 1; value <= example.legacy; value++) await nextPalette(value);
        await canvas.click({ position: { x: 500, y: 200 } });
        await expect(canvas).toBeFocused();
        await page.keyboard.press('-');
        await expect.poll(async () => (await readPilotSession(page)).view.zoom)
          .toBeCloseTo(observation.default.view.zoom / 1.2, 8);
        const edited = observation.edited = await readPilotSession(page);
        const before = await screenshot('edited-before-reload');
        expect(before).not.toBe(defaultHash);
        const beforeReload = await save('edited-before-reload', edited);
        observation.restored = await reload(edited);
        await screenshot('edited-after-reload', testInfo.outputPath('edited-before-reload.png'));
        const first = await save('edited-after-reload', edited);
        const repeat = await save('edited-repeat', edited);
        expect(first.decoded).toEqual(beforeReload.decoded);
        expect(repeat.decoded).toEqual(first.decoded);

        if (example.legacy !== undefined) {
          const timing = observation.timing = {};
          const fullViewport = page.viewportSize();
          for (const [name, selector] of [['legacy', example.legacy], ['new', example.scheme]]) {
            if (name === 'new') {
              for (let value = example.legacy + 1; value <= example.scheme; value++) {
                await nextPalette(value);
              }
            }
            const input = await readPilotSession(page);
            expect(input).toEqual({ ...edited, params: { ...edited.params,
              colorScheme: selector } });
            if (name === 'new') {
              const modernHash = await screenshot('new-selector');
              expect(modernHash).not.toBe(before);
              observation.newRestored = await reload(input);
              await screenshot('new-selector-reloaded', testInfo.outputPath('new-selector.png'));
            }
            // Keep the same pane aspect and HD output, but limit the software
            // cost of repainting the open sheets on the Mandelbox timing path.
            if (example.timingViewport) await page.setViewportSize(example.timingViewport);
            const samples = [];
            let reference = name === 'legacy' && !example.timingViewport ? first.decoded : null;
            for (let i = 0; i < 18; i++) {
              const label = `${name}-${i < 3 ? `warmup-${i + 1}` : `sample-${i - 2}`}`;
              const result = await save(label, input);
              reference ??= result.decoded;
              expect(result.decoded).toEqual(reference);
              samples.push(result.completedMs);
            }
            const measured = samples.slice(3).sort((a, b) => a - b);
            timing[name] = { state: input, viewport: page.viewportSize(),
              dimensions: [reference.width, reference.height], pixelHash: reference.pixelHash,
              warmupMs: samples.slice(0, 3), samplesMs: samples.slice(3),
              medianMs: measured[7], p95Ms: measured[14] };
            if (example.timingViewport) await page.setViewportSize(fullViewport);
          }
          expect(timing.legacy.pixelHash).not.toBe(timing.new.pixelHash);
        }
        await save('edited-transparent', await readPilotSession(page), true);

        // Replay what the old release actually saved, without using its URL or
        // inventing params, then check that the saved values still drive export.
        observation.oldSaved = old.default;
        // Seed the next document before Flutter starts, not the live viewer's
        // store: its debounced save can still commit the current session.
        await page.addInitScript((state) => {
          if (window === window.top) {
            localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(JSON.stringify(state)));
          }
        }, old.default);
        observation.oldRestored = await reload(old.default);
        await screenshot('old-state-restored', oldClip);
        const oldExport = await save('old-state-restored', old.default);
        expect(oldExport.decoded.pixelHash, 'the edited PNG must differ from the old-state PNG')
          .not.toBe(first.decoded.pixelHash);
        observation.exported = true;
      } finally {
        const file = testInfo.outputPath('pilot-observation.json');
        fs.mkdirSync(path.dirname(file), { recursive: true });
        fs.writeFileSync(file, JSON.stringify(observation, null, 2));
        await testInfo.attach('pilot-observation', { path: file, contentType: 'application/json' });
      }
      expect(errors).toEqual([]);
    });
  }
});
