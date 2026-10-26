import { readFile, writeFile } from 'node:fs/promises';
import { expect, test } from 'playwright/test';

// Run after `flutter build web --release` with
// `npx playwright test test/playwright/prime-norm-quaternion.spec.mjs --project=chromium`.
test('production web quaternion companion opens, rotates, and captures a PNG', async ({ page, browser }, testInfo) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto('/');
  await page.waitForTimeout(3000);

  // Search and open the real catalog entry, then enter its bounded walk view.
  await page.mouse.click(350, 80);
  await page.keyboard.type('Gaussian Prime Lattice');
  await page.waitForTimeout(1500);
  await page.mouse.click(125, 450);
  await page.waitForFunction(
    () => new URL(location.href).searchParams.get('type') === 'gaussian_prime_lattice',
    { timeout: 15_000 },
  );
  const viewerFrame = await page.screenshot();
  await page.mouse.click(118, 60);
  await page.waitForTimeout(1200);
  const walkFrame = await page.screenshot();
  expect(walkFrame.equals(viewerFrame)).toBe(false);
  await page.mouse.click(1120, 252);
  await page.waitForTimeout(1200);

  const initial = await page.screenshot();
  expect(initial.equals(walkFrame)).toBe(false);
  expect(initial.subarray(0, 8).toString('hex')).toBe('89504e470d0a1a0a');
  expect(initial.readUInt32BE(16)).toBe(1280);
  expect(initial.readUInt32BE(20)).toBe(900);

  // Semantic controls bind the exported bytes to actual list/Step state, not
  // merely to a changed screenshot after an unverified canvas-coordinate tap.
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  const walk = page.locator('flt-semantics').getByText(/^Walk: \d+ steps/);
  const selectedState = page.locator('flt-semantics').getByText(/^Selected \(/);
  await expect(walk).toContainText('Walk: 0 steps');
  await expect(walk).toContainText('component 3 · fixed d=0 only');
  await expect(selectedState).toHaveCount(0);
  const beforeState = await walk.textContent();

  const captureDownload = async (name) => {
    const downloadPromise = page.waitForEvent('download');
    await page.getByRole('button', { name: 'Capture PNG', exact: true }).click();
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(
      /prime_norm_quaternion_slice.*\.png$/,
    );
    const png = await readFile(await download.path());
    await writeFile(testInfo.outputPath(`${name}.png`), png);
    expect(png.subarray(0, 8).toString('hex')).toBe('89504e470d0a1a0a');
    return page.evaluate(async (base64) => {
      const binary = atob(base64);
      const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
      const bitmap = await createImageBitmap(
        new Blob([bytes], { type: 'image/png' }),
      );
      const canvas = document.createElement('canvas');
      canvas.width = bitmap.width;
      canvas.height = bitmap.height;
      const context = canvas.getContext('2d');
      context.drawImage(bitmap, 0, 0);
      const rgba = context.getImageData(0, 0, bitmap.width, bitmap.height).data;
      bitmap.close();
      return {
        width: canvas.width,
        height: canvas.height,
        pixels: Array.from(rgba),
      };
    }, png.toString('base64'));
  };

  const beforeWalkExport = await captureDownload('before-walk');
  expect(beforeWalkExport.width).toBeGreaterThan(0);
  expect(beforeWalkExport.height).toBeGreaterThan(0);

  await page.getByRole('button', { name: 'Coordinate list', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Capture PNG', exact: true })).toBeDisabled();
  await expect(page.getByText('Switch to 3D view to capture a plot PNG.', { exact: true })).toBeVisible();
  await page.getByText('(-6, -5, -6, 0) · N=97', { exact: true }).click();
  await expect(selectedState).toHaveText('Selected (-6, -5, -6, 0) · norm 97');
  await page.getByRole('button', { name: 'Step', exact: true }).click();
  await expect(walk).toContainText('Walk: 1 steps');
  await page.getByRole('button', { name: '3D view', exact: true }).click();
  const afterState = { walk: await walk.textContent(), selected: await selectedState.textContent() };
  const selected = await page.screenshot();
  expect(selected.equals(initial)).toBe(false);
  const exported = await captureDownload('after-walk');
  await expect(walk).toHaveText(afterState.walk);
  await expect(selectedState).toHaveText(afterState.selected);
  expect(exported.width).toBe(beforeWalkExport.width);
  expect(exported.height).toBe(beforeWalkExport.height);
  expect(exported.pixels.some((channel, index) => index % 4 === 3 && channel > 0))
    .toBe(true);
  expect(exported.pixels).not.toEqual(beforeWalkExport.pixels);

  // Rotation is display-only; the exact slice disclosure remains visible in
  // the rendered frame and the capture action reports its completed snapshot.
  await page.mouse.move(640, 540);
  await page.mouse.down();
  await page.mouse.move(690, 565, { steps: 4 });
  await page.mouse.up();
  // With Flutter web semantics enabled the overlay can consume pointer pans.
  // Exercise the advertised keyboard rotation on the actual plot as well; the
  // decoded export below must change, not only the focus/hover screenshot.
  await page.getByRole('group', { name: /^Prime-norm quaternion points;/ })
    .getByRole('button').click();
  await page.keyboard.press('ArrowRight');
  await page.waitForTimeout(150);
  const rotated = await page.screenshot();
  expect(rotated.equals(selected)).toBe(false);
  await expect(walk).toHaveText(afterState.walk);
  await expect(selectedState).toHaveText(afterState.selected);
  const rotatedExport = await captureDownload('rotated');
  expect(rotatedExport.pixels).not.toEqual(exported.pixels);
  await writeFile(testInfo.outputPath('rotated-screen.png'), rotated);
  const backend = await page.evaluate(() => {
    const gl = document.createElement('canvas').getContext('webgl2');
    const debug = gl?.getExtension('WEBGL_debug_renderer_info');
    return { renderer: debug ? gl.getParameter(debug.UNMASKED_RENDERER_WEBGL) : null,
      vendor: debug ? gl.getParameter(debug.UNMASKED_VENDOR_WEBGL) : null,
      userAgent: navigator.userAgent, devicePixelRatio: window.devicePixelRatio };
  });
  await writeFile(testInfo.outputPath('state.json'), JSON.stringify({
    coverage: 'production app catalog -> Gaussian viewer -> Walk -> quaternion companion',
    url: page.url(), viewport: page.viewportSize(), backend,
    browserVersion: browser.version(), hostPlatform: process.platform,
    before: { walk: beforeState, selected: null }, after: afterState,
    rotated: { walk: await walk.textContent(), selected: await selectedState.textContent() },
    semantics: await page.locator('body').ariaSnapshot(),
  }, null, 2));
});
