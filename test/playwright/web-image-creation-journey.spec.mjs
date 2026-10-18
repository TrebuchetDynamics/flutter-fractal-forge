import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { test, expect } from 'playwright/test';

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

  await page.goto('/', { waitUntil: 'domcontentloaded' });
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
});
