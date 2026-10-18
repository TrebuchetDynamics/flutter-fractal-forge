import { readFile } from 'node:fs/promises';
import { expect, test } from 'playwright/test';

// Run after `flutter build web --release` with
// `npx playwright test test/playwright/prime-norm-quaternion.spec.mjs --project=chromium`.
test('production web quaternion companion opens, rotates, and captures a PNG', async ({ page }) => {
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

  const captureDownload = async (buttonY = 125) => {
    const downloadPromise = page.waitForEvent('download');
    await page.mouse.click(825, buttonY);
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(
      /prime_norm_quaternion_slice.*\.png$/,
    );
    const png = await readFile(await download.path());
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

  const beforeWalkExport = await captureDownload();
  expect(beforeWalkExport.width).toBeGreaterThan(0);
  expect(beforeWalkExport.height).toBeGreaterThan(0);

  // Select a plotted point; the exported artifact must include that selected state.
  await page.mouse.click(398, 844);
  await page.waitForTimeout(150);
  const selected = await page.screenshot();
  expect(selected.equals(initial)).toBe(false);
  const exported = await captureDownload(145);
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
  await page.waitForTimeout(150);
  const rotated = await page.screenshot();
  expect(rotated.equals(initial)).toBe(false);


});
