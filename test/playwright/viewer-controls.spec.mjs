import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';
import { test } from 'playwright/test';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');

const randomModulePool = [
  'mandelbrot',
  'julia',
  'burning_ship',
  'tricorn',
  'phoenix',
  'mandelbulb',
];

function selectedModules() {
  if (process.env.VIEWER_CONTROL_FRACTALS) {
    return process.env.VIEWER_CONTROL_FRACTALS
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean);
  }
  const count = Number(process.env.VIEWER_CONTROL_FRACTAL_COUNT || 3);
  return [...randomModulePool]
    .sort(() => Math.random() - 0.5)
    .slice(0, Math.max(1, Math.min(count, randomModulePool.length)));
}

function safeFileName(id) {
  return id.replace(/[^a-zA-Z0-9_.-]+/g, '_');
}

function compactError(error) {
  return String(error?.message || error).replace(/\s+/g, ' ').slice(0, 600);
}

const controllerMarkerPrefix = 'PLAYWRIGHT_FRACTAL_CONTROLLER:';

function parseControllerMarker(message) {
  const text = message.text();
  const index = text.indexOf(controllerMarkerPrefix);
  if (index < 0) return null;
  try {
    return JSON.parse(text.slice(index + controllerMarkerPrefix.length));
  } catch (_) {
    return null;
  }
}

async function performAndRequireMarker(result, page, label, matcher, action, timeout = 5_000) {
  const markerPromise = page.waitForEvent('console', {
    predicate: (message) => {
      const marker = parseControllerMarker(message);
      return marker != null && matcher(marker);
    },
    timeout,
  }).then(parseControllerMarker).catch(() => null);

  await action();
  const marker = await markerPromise;
  if (marker == null) {
    result.errors.push({
      kind: 'missing-controller-marker',
      text: `${label} did not emit an expected controller marker`,
    });
    return null;
  }
  result.markers.push({ label, marker });
  return marker;
}

async function performAndRecordOptionalMarker(result, page, label, matcher, action, timeout = 2_000) {
  const markerPromise = page.waitForEvent('console', {
    predicate: (message) => {
      const marker = parseControllerMarker(message);
      return marker != null && matcher(marker);
    },
    timeout,
  }).then(parseControllerMarker).catch(() => null);

  await action();
  const marker = await markerPromise;
  if (marker == null) {
    result.warnings.push({
      kind: 'optional-controller-marker',
      text: `${label} did not emit a controller marker; screenshot retained for manual review`,
    });
  } else {
    result.markers.push({ label, marker });
  }
  return marker;
}

function paethPredictor(left, up, upLeft) {
  const p = left + up - upLeft;
  const pa = Math.abs(p - left);
  const pb = Math.abs(p - up);
  const pc = Math.abs(p - upLeft);
  if (pa <= pb && pa <= pc) return left;
  if (pb <= pc) return up;
  return upLeft;
}

function decodePng(buffer) {
  if (buffer.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') {
    throw new Error('Screenshot was not a PNG');
  }
  let offset = 8;
  let width = 0;
  let height = 0;
  let colorType = 0;
  let bitDepth = 0;
  const idats = [];
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.subarray(offset + 4, offset + 8).toString('ascii');
    const data = buffer.subarray(offset + 8, offset + 8 + length);
    offset += 12 + length;
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
    } else if (type === 'IDAT') {
      idats.push(data);
    } else if (type === 'IEND') {
      break;
    }
  }
  if (bitDepth !== 8) throw new Error(`Unsupported PNG bit depth ${bitDepth}`);
  const channels = new Map([[0, 1], [2, 3], [4, 2], [6, 4]]).get(colorType);
  if (!channels) throw new Error(`Unsupported PNG color type ${colorType}`);

  const inflated = zlib.inflateSync(Buffer.concat(idats));
  const stride = width * channels;
  const raw = Buffer.alloc(height * stride);
  let sourceOffset = 0;
  for (let y = 0; y < height; y++) {
    const filter = inflated[sourceOffset++];
    const rowOffset = y * stride;
    const prevOffset = (y - 1) * stride;
    for (let x = 0; x < stride; x++) {
      const value = inflated[sourceOffset++];
      const left = x >= channels ? raw[rowOffset + x - channels] : 0;
      const up = y > 0 ? raw[prevOffset + x] : 0;
      const upLeft = y > 0 && x >= channels ? raw[prevOffset + x - channels] : 0;
      if (filter === 0) raw[rowOffset + x] = value;
      else if (filter === 1) raw[rowOffset + x] = (value + left) & 255;
      else if (filter === 2) raw[rowOffset + x] = (value + up) & 255;
      else if (filter === 3) raw[rowOffset + x] = (value + Math.floor((left + up) / 2)) & 255;
      else if (filter === 4) raw[rowOffset + x] = (value + paethPredictor(left, up, upLeft)) & 255;
      else throw new Error(`Unsupported PNG filter ${filter}`);
    }
  }

  const rgba = new Uint8ClampedArray(width * height * 4);
  for (let i = 0, j = 0; i < raw.length; i += channels, j += 4) {
    if (colorType === 0) {
      rgba[j] = raw[i]; rgba[j + 1] = raw[i]; rgba[j + 2] = raw[i]; rgba[j + 3] = 255;
    } else if (colorType === 2) {
      rgba[j] = raw[i]; rgba[j + 1] = raw[i + 1]; rgba[j + 2] = raw[i + 2]; rgba[j + 3] = 255;
    } else if (colorType === 4) {
      rgba[j] = raw[i]; rgba[j + 1] = raw[i]; rgba[j + 2] = raw[i]; rgba[j + 3] = raw[i + 1];
    } else {
      rgba[j] = raw[i]; rgba[j + 1] = raw[i + 1]; rgba[j + 2] = raw[i + 2]; rgba[j + 3] = raw[i + 3];
    }
  }
  return { width, height, rgba };
}

function meanPixelDiff(aBuffer, bBuffer, step = 6) {
  const a = decodePng(aBuffer);
  const b = decodePng(bBuffer);
  if (a.width !== b.width || a.height !== b.height) return Infinity;
  let total = 0;
  let count = 0;
  for (let y = 0; y < a.height; y += step) {
    for (let x = 0; x < a.width; x += step) {
      const offset = (y * a.width + x) * 4;
      total += Math.abs(a.rgba[offset] - b.rgba[offset]);
      total += Math.abs(a.rgba[offset + 1] - b.rgba[offset + 1]);
      total += Math.abs(a.rgba[offset + 2] - b.rgba[offset + 2]);
      count += 3;
    }
  }
  return total / Math.max(1, count);
}

function fabPoint(page, name) {
  const viewport = page.viewportSize() || { width: 1280, height: 900 };
  // Landscape viewer order: random, randomize, color, export, text,
  // looper, kaleidoscope, music, fullscreen.
  const index = {
    random: 0,
    randomize: 1,
    color: 2,
    export: 3,
    text: 4,
    looper: 5,
    kaleidoscope: 6,
    music: 7,
    fullscreen: 8,
  }[name];
  if (index == null) throw new Error(`Unknown FAB ${name}`);
  const spacing = 56;
  return {
    x: viewport.width / 2 - ((9 - 1) * spacing) / 2 + index * spacing,
    y: viewport.height - 44,
  };
}

async function clickFab(page, name) {
  const point = fabPoint(page, name);
  await page.mouse.click(point.x, point.y);
}

async function longPressFab(page, name) {
  const point = fabPoint(page, name);
  await page.mouse.move(point.x, point.y);
  await page.mouse.down();
  await page.waitForTimeout(850);
  await page.mouse.up();
}

async function clickExportMenuItem(page, item) {
  const viewport = page.viewportSize() || { width: 1280, height: 900 };
  const yFromBottomByItem = { export: 140, share: 100, wallpaper: 60 }[item];
  if (yFromBottomByItem == null) throw new Error(`Unknown export menu item ${item}`);
  await page.mouse.click(viewport.width - 140, viewport.height - yFromBottomByItem);
}

function yFromBottom(page, distance) {
  const viewport = page.viewportSize() || { width: 1280, height: 720 };
  return viewport.height - distance;
}

async function saveScreenshot(page, dir, step, label) {
  const fileName = `${String(step).padStart(2, '0')}-${safeFileName(label)}.png`;
  const filePath = path.join(dir, fileName);
  const buffer = await page.screenshot({ path: filePath, animations: 'disabled', timeout: 30_000 });
  return { filePath, relPath: path.relative(repoRoot, filePath), buffer };
}

async function waitForSmokeOpen(page, id, timeout = 20_000) {
  const openMarker = `PLAYWRIGHT_CATALOG_SMOKE_OPENED:${id}`;
  const frameMarker = `PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${id}`;
  let opened = false;
  let firstFrame = false;
  const listener = (message) => {
    const text = message.text();
    if (text.includes(openMarker)) opened = true;
    if (text.includes(frameMarker)) firstFrame = true;
  };
  page.on('console', listener);
  try {
    await Promise.all([
      page.waitForEvent('console', {
        predicate: (message) => message.text().includes(openMarker),
        timeout,
      }).then(() => { opened = true; }).catch(() => {}),
      page.waitForEvent('console', {
        predicate: (message) => message.text().includes(frameMarker),
        timeout,
      }).then(() => { firstFrame = true; }).catch(() => {}),
    ]);
  } finally {
    page.off('console', listener);
  }
  return { opened, firstFrame };
}

async function requireChanged(result, before, after, label, minDiff = 0.8) {
  const diff = meanPixelDiff(before.buffer, after.buffer);
  result.diffs.push({ label, diff: Number(diff.toFixed(3)) });
  if (diff < minDiff) {
    result.errors.push({
      kind: 'ui-no-visual-change',
      text: `${label} changed screenshot by only ${diff.toFixed(3)} mean RGB units; expected >= ${minDiff}`,
    });
  }
}

async function runControlJourney(page, baseURL, id, browserName, testInfo) {
  const result = { id, errors: [], warnings: [], screenshots: [], diffs: [], markers: [] };
  const dir = path.join(repoRoot, 'test/results', `viewer-controls-${browserName}`, safeFileName(id));
  fs.mkdirSync(dir, { recursive: true });

  const consoleErrors = [];
  const onConsole = (message) => {
    const text = message.text();
    if (message.type() === 'error' && !/Failed to load resource/.test(text)) {
      consoleErrors.push(text);
    }
  };
  page.on('console', onConsole);

  try {
    const targetUrl = new URL(`/?smokeModule=${encodeURIComponent(id)}&controlRun=${Date.now().toString(36)}`, baseURL).toString();
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
    const smoke = await waitForSmokeOpen(page, id);
    if (!smoke.opened) result.errors.push({ kind: 'smoke-open', text: `Did not see open marker for ${id}` });
    if (!smoke.firstFrame) result.errors.push({ kind: 'first-frame', text: `Did not see first-frame marker for ${id}` });
    await page.waitForTimeout(700);

    const canvasCount = await page.locator('canvas').count();
    if (canvasCount === 0) result.errors.push({ kind: 'canvas', text: 'No canvas found in viewer.' });

    const initial = await saveScreenshot(page, dir, 1, 'viewer-initial');
    result.screenshots.push(initial.relPath);
    const viewport = page.viewportSize() || { width: 1280, height: 720 };
    await page.mouse.click(viewport.width / 2, viewport.height / 2);

    await performAndRequireMarker(
      result,
      page,
      'keyboard zoom in',
      (marker) => marker.category === 'zoom',
      async () => {
        for (let i = 0; i < 5; i++) await page.keyboard.press('=');
      },
    );
    await page.waitForTimeout(500);
    const zoomed = await saveScreenshot(page, dir, 2, 'keyboard-zoom-in');
    result.screenshots.push(zoomed.relPath);
    await requireChanged(result, initial, zoomed, 'keyboard zoom in visual delta', 0);

    await performAndRequireMarker(
      result,
      page,
      'keyboard pan',
      (marker) => marker.category === 'pan',
      async () => {
        for (let i = 0; i < 4; i++) await page.keyboard.press('ArrowRight');
        for (let i = 0; i < 4; i++) await page.keyboard.press('ArrowDown');
      },
    );
    await page.waitForTimeout(500);
    const panned = await saveScreenshot(page, dir, 3, 'keyboard-pan');
    result.screenshots.push(panned.relPath);
    await requireChanged(result, zoomed, panned, 'keyboard pan visual delta', 0);

    await performAndRequireMarker(
      result,
      page,
      'keyboard reset view',
      (marker) => marker.category === 'reset' && /Reset view/i.test(marker.message || ''),
      async () => { await page.keyboard.press('r'); },
    );
    await page.waitForTimeout(500);
    const reset = await saveScreenshot(page, dir, 4, 'keyboard-reset-view');
    result.screenshots.push(reset.relPath);

    await clickFab(page, 'fullscreen');
    await page.waitForTimeout(500);
    const fullscreen = await saveScreenshot(page, dir, 5, 'fullscreen-unobtrusive');
    result.screenshots.push(fullscreen.relPath);
    await requireChanged(result, reset, fullscreen, 'fullscreen FAB hides chrome', 0.35);

    // Fullscreen exit FAB uses the same bottom-right safe-area position as
    // the viewer's normal fullscreen control.
    await page.mouse.click(viewport.width - 40, viewport.height - 44);
    await page.waitForTimeout(500);
    const restored = await saveScreenshot(page, dir, 6, 'ui-restored');
    result.screenshots.push(restored.relPath);
    await requireChanged(result, fullscreen, restored, 'restore UI', 0.05);

    await longPressFab(page, 'randomize');
    await page.waitForTimeout(600);
    const controls = await saveScreenshot(page, dir, 7, 'controls-hud');
    result.screenshots.push(controls.relPath);
    await requireChanged(result, restored, controls, 'randomize long-press opens controls HUD', 1.2);
    await page.mouse.click(viewport.width - 44, viewport.height - viewport.height * 0.42 + 28);
    await page.waitForTimeout(500);
    const afterControls = await saveScreenshot(page, dir, 8, 'controls-closed');
    result.screenshots.push(afterControls.relPath);
    await requireChanged(result, controls, afterControls, 'controls HUD close', 0.5);

    // Reset and preset actions now live in their dedicated sheets/HUD; the
    // viewer no longer exposes the old reset/iterations/presets FAB column.

    await performAndRequireMarker(
      result,
      page,
      'color cycle FAB',
      (marker) => marker.category === 'paramUpdate' && /colorScheme/i.test(marker.message || ''),
      async () => { await clickFab(page, 'color'); },
    );

    await longPressFab(page, 'color');
    await page.waitForTimeout(700);
    const palette = await saveScreenshot(page, dir, 10, 'palette-picker');
    result.screenshots.push(palette.relPath);
    await requireChanged(result, afterControls, palette, 'color long-press opens palette picker', 0.2);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);

    await performAndRequireMarker(
      result,
      page,
      'kaleidoscope FAB',
      (marker) => marker.category === 'kaleidoscopeEnabled',
      async () => { await clickFab(page, 'kaleidoscope'); },
    );

    await performAndRequireMarker(
      result,
      page,
      'randomize FAB',
      (marker) => marker.category === 'randomize',
      async () => { await clickFab(page, 'randomize'); },
    );
    await page.waitForTimeout(600);
    const randomized = await saveScreenshot(page, dir, 11, 'randomize-fab');
    result.screenshots.push(randomized.relPath);

    await clickFab(page, 'looper');
    await page.waitForTimeout(700);
    const looper = await saveScreenshot(page, dir, 12, 'looper-sheet');
    result.screenshots.push(looper.relPath);
    await requireChanged(result, randomized, looper, 'looper FAB opens sheet', 0.2);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);

    await clickFab(page, 'export');
    await page.waitForTimeout(500);
    const exportMenu = await saveScreenshot(page, dir, 13, 'export-menu');
    result.screenshots.push(exportMenu.relPath);
    await requireChanged(result, randomized, exportMenu, 'export FAB opens menu', 0.2);

    await clickExportMenuItem(page, 'export');
    await page.waitForTimeout(900);
    const exportSheet = await saveScreenshot(page, dir, 14, 'export-sheet');
    result.screenshots.push(exportSheet.relPath);
    await requireChanged(result, exportMenu, exportSheet, 'export menu opens export sheet', 0.2);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);

    await clickFab(page, 'export');
    await page.waitForTimeout(500);
    await clickExportMenuItem(page, 'wallpaper');
    await page.waitForTimeout(900);
    const wallpaperSheet = await saveScreenshot(page, dir, 15, 'wallpaper-sheet');
    result.screenshots.push(wallpaperSheet.relPath);
    await requireChanged(result, randomized, wallpaperSheet, 'export menu opens wallpaper sheet', 0.2);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);

    await clickFab(page, 'export');
    await page.waitForTimeout(500);
    await clickExportMenuItem(page, 'share');
    await page.waitForTimeout(900);
    const shareAttempt = await saveScreenshot(page, dir, 16, 'share-menu-item');
    result.screenshots.push(shareAttempt.relPath);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);

    await performAndRecordOptionalMarker(
      result,
      page,
      'random fractal FAB',
      (marker) => marker.category === 'moduleSwitch',
      async () => { await clickFab(page, 'random'); },
      8_000,
    );
    await page.waitForTimeout(800);
    const randomFab = await saveScreenshot(page, dir, 17, 'random-fractal-fab');
    result.screenshots.push(randomFab.relPath);
    await requireChanged(result, shareAttempt, randomFab, 'random fractal FAB visual delta', 0);

    if (consoleErrors.length > 0) {
      result.errors.push({ kind: 'console.error', text: consoleErrors.join(' | ').slice(0, 800) });
    }
  } catch (error) {
    result.errors.push({ kind: 'test-exception', text: compactError(error) });
  } finally {
    page.off('console', onConsole);
  }

  for (const screenshot of result.screenshots) {
    await testInfo.attach(`${id}-${path.basename(screenshot)}`, {
      path: path.join(repoRoot, screenshot),
      contentType: 'image/png',
    });
  }
  return result;
}

test('all viewer FAB icons and actions are operable and screenshot-covered', async ({ context, baseURL, browserName }, testInfo) => {
  const modules = selectedModules();
  testInfo.setTimeout(Math.max(testInfo.timeout, modules.length * 90_000));
  const results = [];

  for (const id of modules) {
    const page = await context.newPage();
    try {
      results.push(await runControlJourney(page, baseURL, id, browserName, testInfo));
    } finally {
      await page.close({ runBeforeUnload: false }).catch(() => {});
    }
  }

  fs.mkdirSync(path.join(repoRoot, 'test/results'), { recursive: true });
  const report = {
    browserName,
    modules,
    total: results.length,
    failures: results.filter((result) => result.errors.length > 0),
    results,
  };
  const reportPath = path.join(repoRoot, `test/results/viewer-controls-${browserName}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  await testInfo.attach('viewer-controls-results', {
    path: reportPath,
    contentType: 'application/json',
  });

  if (report.failures.length > 0) {
    const summary = report.failures.map((failure) => {
      const details = failure.errors.map((error) => `    - ${error.kind}: ${error.text}`).join('\n');
      return `  ${failure.id}\n${details}`;
    }).join('\n');
    throw new Error(`${report.failures.length}/${report.total} viewer control journeys failed.\n${summary}\n\nFull report: ${reportPath}`);
  }
});
