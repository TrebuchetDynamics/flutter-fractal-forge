import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { test, expect } from 'playwright/test';

const json = (url) => JSON.parse(fs.readFileSync(url, 'utf8'));
const manifestUrl = new URL('../fixtures/ui_overlay_capture_matrix.json', import.meta.url);
const manifest = json(manifestUrl);
const labels = Object.fromEntries(['en', 'es'].map((locale) => [locale,
  json(new URL(`../../lib/l10n/app_${locale}.arb`, import.meta.url))]));
const digest = (bytes) => createHash('sha256').update(bytes).digest('hex');
const output = process.env.UI_OVERLAY_CAPTURE_DIR;
const sample = 'Capture sample preset';
const lastPalette = 'Relief 180° Ocean'; // CommonParams.colorScheme64 / BuiltInPaletteNames
const expected = { baseline: 69, stress: 14, oled: 1 };

function selectRows(matrix) {
  assert.equal(matrix.schema, 1, 'unsupported matrix schema');
  assert.equal(new Set(matrix.states.map(({ id }) => id)).size, 32, 'state IDs');
  const enabled = new Set(matrix.states.filter(({ browser }) => browser.available).map(({ id }) => id));
  const excluded = matrix.states.filter(({ browser }) => !browser.available);
  assert.equal(enabled.size, 23, 'browser state count');
  assert.equal(excluded.length, 9, 'component-only state count');
  assert.ok(excluded.every(({ browser }) => browser.exclusion_reason), 'missing exclusion reason');
  assert.equal(new Set(matrix.rows.map(({ id }) => id)).size, matrix.rows.length, 'duplicate row ID');
  const rows = matrix.rows.filter(({ category, state }) => enabled.has(state) && category !== 'keyboard');
  for (const [category, count] of Object.entries(expected)) {
    assert.equal(rows.filter((row) => row.category === category).length, count, `${category} count`);
    assert.equal(matrix.browser_derivation[category], count, `${category} declaration`);
  }
  assert.equal(rows.length, 84, 'browser total');
  assert.equal(matrix.rows.length, 119, 'component total');
  const stateIds = new Set(matrix.states.map(({ id }) => id));
  assert.ok(matrix.rows.every(({ state }) => stateIds.has(state)), 'row references an unknown state');
  assert.equal(matrix.browser_derivation.total, 84);
  assert.equal(matrix.browser_derivation.text_scale, 1);
  const stressStates = ['controls-2d', 'presets-user-populated', 'palette-last-selected',
    'export-options', 'text-editor', 'looper-ready', 'theme-selector'];
  const tuples = rows.map(({ state, category, inputs: i }) => {
    assert.equal(i.dpr, 1);
    assert.equal(i.reduced_motion, true);
    assert.equal(i.view_insets_bottom, 0);
    assert.equal(i.large_targets, false);
    assert.deepEqual([i.locale, i.theme, i.text_scale], {
      baseline: ['en', 'dark', 1], stress: ['es', 'highContrast', 3], oled: ['en', 'oled', 1],
    }[category]);
    return `${state}:${category}:${i.width}x${i.height}`;
  });
  assert.deepEqual(tuples.sort(), [
    ...[...enabled].flatMap((state) => ['375x667', '768x1024', '1440x900'].map((size) => `${state}:baseline:${size}`)),
    ...stressStates.flatMap((state) => ['320x568', '667x375'].map((size) => `${state}:stress:${size}`)),
    'export-options:oled:375x667',
  ].sort(), 'browser viewport tuples');
  return rows.map(({ id, ...row }) => ({ ...row, componentRow: id, id: `${id}--native1x`,
    inputs: { ...row.inputs, text_scale: 1 } }));
}

// Update reconciliation after each case, so a worker failure or global deadline
// cannot turn the unexecuted tail into success. A fresh output per run is required.
function report(rows, metadata, record) {
  const file = path.join(output, 'captures.json');
  const previous = fs.existsSync(file) ? json(file) : null;
  const byId = new Map(previous?.captures.map((row) => [row.id, row]));
  if (record) byId.set(record.id, record);
  const captures = rows.map(({ id, inputs, state, componentRow }) => byId.get(id) ?? {
    id, state, inputs, componentRow, status: 'missing', documentOverflow: null, internalLayout: null,
    error: 'Case not completed; check the invocation log and Playwright diagnostics.',
  });
  const componentOnlyStates = manifest.states.filter(({ browser }) => !browser.available)
    .map(({ id, browser }) => ({ id, reason: browser.exclusion_reason }));
  const componentOnlyRows = manifest.rows.filter(({ state, category }) =>
    componentOnlyStates.some(({ id }) => id === state) || category === 'stress' || category === 'keyboard')
    .map(({ id, state, category }) => ({ id, reason: componentOnlyStates.find((s) => s.id === state)?.reason ??
      (category === 'stress' ? 'Synthetic 3× text, not browser native1x' : 'Synthetic keyboard inset; no browser IME evidence') }));
  const count = (status) => captures.filter((row) => row.status === status).length;
  const counts = { expected: rows.length, captured: captures.filter((row) => row.png).length,
    passed: count('passed'), failed: count('failed'), missing: count('missing'),
    componentOnlyStates: componentOnlyStates.length, componentOnlyRows: componentOnlyRows.length };
  const layoutQualified = Boolean(metadata.buildSource) && counts.passed === counts.expected;
  fs.writeFileSync(`${file}.tmp`, JSON.stringify({ schema: 1, metadata, counts, layoutQualified,
    captures, componentOnlyStates, componentOnlyRows }, null, 2) + '\n');
  fs.renameSync(`${file}.tmp`, file);
  fs.writeFileSync(path.join(output, 'report.md'), [
    '# Responsive Flutter web overlay audit', '', `Local browser layout evidence complete: **${layoutQualified}**`,
    '', 'This flag covers the automated checks only; inspect painted content separately.',
    'No physical-device, hardware-GPU, IME or accessibility qualification.',
    ...(metadata.buildSource ? [] : ['Build source unknown; record APP_QUALITY_SOURCE when building the audited bundle.']), '',
    ...Object.entries(counts).map(([key, value]) => `- ${key}: ${value}`), '',
    '| Browser row | Verdict | PNG / first error |', '| --- | --- | --- |',
    ...captures.map((row) => `| ${row.id} | ${row.status} | ${row.png?.path ?? '—'} ${row.error?.split('\n')[0].replaceAll('|', '/') ?? ''} |`),
    '', '## Component-only coverage', '', ...componentOnlyRows.map(({ id, reason }) => `- ${id}: ${reason}`), '',
    'Details: `captures.json` (runtime identity, boxes, overflow, errors); `playwright.json` and `diagnostics/` (test failures).', '',
  ].join('\n'));
}

function controls(page, strings) {
  const name = (key) => strings[key] ?? key;
  const button = (key) => page.getByRole('button', { name: name(key), exact: true });
  const text = (key) => page.locator('flt-semantics-host').getByText(name(key), { exact: true });
  const starts = (role, key) => page.getByRole(role, { name: new RegExp(`^${name(key).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?:\\s|$)`) });
  return { name, button, text, starts };
}

async function enableSemantics(page) {
  const activator = page.locator('flt-semantics-placeholder');
  await expect(activator).toBeVisible({ timeout: 15_000 });
  // Flutter renders this activator outside the viewport (existing journey pattern).
  await activator.evaluate((node) => node.click());
  await expect(activator).toBeHidden();
}

const prefs = (page, key) => page.evaluate((name) => JSON.parse(localStorage.getItem(`flutter.${name}`)), key);
async function viewerState(page) {
  const saved = JSON.parse(await prefs(page, 'viewer_session_v1'));
  assert.ok(saved?.moduleId, 'No persisted viewer session');
  return { moduleId: saved.moduleId, params: saved.params, view: saved.view };
}

async function readyViewer(page, row, observation, metadata) {
  const module = row.state === 'controls-3d' ? 'mandelbulb' : 'mandelbrot';
  const query = row.state === 'palette-last-selected' ? '&colorScheme=63' : '';
  const marker = `PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${module}`;
  const frame = page.waitForEvent('console', { predicate: (message) => message.text().includes(marker), timeout: 20_000 });
  const bundle = page.waitForResponse((response) => new URL(response.url()).pathname === '/main.dart.js',
    { timeout: 20_000 });
  const [, response] = await Promise.all([frame, bundle,
    page.goto(`/?smokeModule=${module}${query}`, { waitUntil: 'domcontentloaded' })]);
  assert.equal(response.status(), 200, 'Smoke bundle response');
  observation.bundleSha256 = digest(await response.body());
  assert.equal(observation.bundleSha256, metadata.bundleSha256, 'Served smoke bundle differs from build/web/main.dart.js');
  observation.readyMarker = marker;
  await enableSemantics(page);
}

// Flutter paints its scrollables on CanvasKit. Use wheel gestures anchored
// to a visible semantic child; scrolling the DOM cannot reveal Flutter slivers.
async function reveal(page, target, anchor, { delta = 290, action = true, minHeight = 0 } = {}) {
  await expect(anchor).toBeInViewport();
  const { x, y, width, height } = await anchor.boundingBox();
  await page.mouse.move(x + width / 2, y + height / 2);
  await expect.poll(async () => {
    try {
      await expect(target).toBeInViewport({ ratio: 0.98, timeout: 250 });
      if (minHeight && ((await target.boundingBox())?.height ?? 0) < minHeight) {
        await page.mouse.wheel(0, delta);
        return false;
      }
      if (action) await target.click({ trial: true, timeout: 350 });
      return true;
    } catch {
      await page.mouse.wheel(0, delta);
      return false;
    }
  }, { message: 'Target is reachable through the visible Flutter scroll surface', timeout: 4500 }).toBe(true);
}

async function activateByKey(action) {
  await expect(action).toBeEnabled();
  await action.focus();
  await expect(action).toBeFocused();
  await action.press('Enter');
}

async function openSurface(page, row, c) {
  const { button: b, text: t, starts } = c;
  const close = b('semanticCloseButton').or(page.getByRole('button', { name: /^(Close|Cerrar)$/ }));
  const surface = (title, { marker = t(title), dismiss = close, actions = [], anchor = marker, ...rest } = {}) =>
    ({ title: t(title), titleLabel: c.name(title), marker, dismiss, actions, anchor, ...rest });
  const tools = () => b('viewerMoreTools').click();
  const tool = async (key) => {
    await tools();
    const action = b(key);
    if (row.inputs.height < 500) await reveal(page, action, b('controlsTitle'));
    await action.click();
  };
  const save = () => b('viewerActionSectionSaveShare').click();
  const long = (key) => b(key).click({ delay: 650 });
  switch (row.state) {
    case 'edit-menu':
      await tools();
      return surface('viewerEditTools', { marker: b('controlsTitle') });
    case 'controls-2d':
    case 'controls-3d':
      await tool('controlsTitle');
      return surface('controlsTitle', { marker: t('mathCurrentRule'),
        title: page.getByRole('group', { name: new RegExp(`^${c.name('semanticFractalCanvas')} .* ${c.name('controlsTitle')}$`) }),
        mergedTitle: true });
    case 'palette-top':
      await tool('viewerActionSettingsPalette');
      return surface('paramColorScheme', { marker: b('colorFire') });
    case 'palette-last-selected': {
      await tool('viewerActionSettingsPalette');
      const selected = b(lastPalette);
      await expect(selected).toHaveAttribute('aria-current', 'true');
      return surface('paramColorScheme', { marker: selected, anchor: selected, terminalFirst: true });
    }
    case 'presets-built-in':
    case 'presets-user-empty':
    case 'presets-user-populated':
    case 'preset-rename':
    case 'batch-selection': {
      await starts('group', 'semanticFractalCanvas').click({ button: 'right' });
      await page.getByRole('menuitem', { name: c.name('contextMenuOpenPresets'), exact: true }).click();
      await expect(t('presetsTitle')).toBeVisible();
      if (row.state === 'batch-selection') {
        await expect(b('batchExportAllPresets')).toHaveCount(0);
        throw new Error('Batch selection is not shipped on web: ViewerDialogs passes onBatchExport=null (kIsWeb); no job started.');
      }
      if (row.state === 'preset-rename') {
        const rename = starts('button', 'tooltipRenamePreset');
        await reveal(page, rename, page.getByRole('heading', { name: c.name('builtInPresets').toUpperCase(), exact: true }));
        await rename.click();
        return surface('renamePresetTitle', { marker: page.getByRole('textbox', { disabled: false }),
          dismiss: b('buttonCancel'), actions: [b('buttonSave')], parentDismiss: close, parentAnchor: b(sample) });
      }
      const builtIn = page.getByRole('heading', { name: c.name('builtInPresets').toUpperCase(), exact: true });
      const marker = row.state === 'presets-built-in' ? builtIn :
        row.state === 'presets-user-empty' ? t('noUserPresets') : b(sample);
      return surface('presetsTitle', { marker, anchor: page.getByRole('heading', {
        name: c.name('savePreset').toUpperCase(), exact: true }), scrollMarker: row.state !== 'presets-built-in',
      // CanvasKit can expose only a sliver of the card as an in-viewport box.
      // Scroll until its trailing control is fully reachable without editing it.
      scrollProbe: row.state === 'presets-user-populated' ? starts('button', 'tooltipRenamePreset') : null });
    }
    case 'save-share':
      await save();
      return surface('viewerActionSectionSaveShare', { marker: b('tooltipExport') });
    case 'export-options':
      await save();
      await b('tooltipExport').click();
      return surface('exportTitle', { marker: b('exportActionSaveImage').first(),
        actions: [b('exportActionSaveImage').first()], disabledAction: b('exportActionSaveAndShare').first() });
    case 'share-preview':
      await save();
      await b('shareLinkAction').click();
      return surface('shareViewLinkTitle', { marker: page.getByRole('img', { name: 'Mandelbrot', exact: true }),
        actions: [b('shareViewLinkCopy'), b('shareViewLinkShare')] });
    case 'looper-empty':
    case 'looper-ready': {
      await long('tooltipPlayLooper');
      if (row.state === 'looper-empty') return surface('looperTitle', { marker: t('looperSetStartHint') });
      await activateByKey(b('looperSetA'));
      await activateByKey(b('looperSetB'));
      return surface('looperTitle', { marker: t(c.name('looperReadyStatus').replace('{count}', '2')),
        actions: [b('looperExportGif')], scrollActions: true });
    }
    case 'fourier-settings':
      await tool('viewerActionSettingsFourier');
      return surface('fourierSettingsTitle');
    case 'text-editor':
      await tool('viewerActionSettingsText');
      return surface('textOverlayTitle', { marker: b('actionApply'), actions: [b('actionCancel')], dismiss: close });
    case 'random-options':
      await tool('randomOptionsTitle');
      return surface('randomOptionsTitle');
    case 'random-categories': {
      // A held semantic pointer click fires the primary (randomizing) action
      // in this browser. Try the advertised secondary shortcut without tapping.
      const random = b('tooltipRandomFractal');
      for (let step = 0; step < 12 && !(await random.evaluate((node) => node === document.activeElement)); step++) {
        await page.keyboard.press('Tab');
      }
      await expect(random, 'Reach the Random Fractal secondary action by keyboard').toBeFocused();
      await page.keyboard.press('Shift+Enter');
      return surface('randomCategoriesTitle', { marker: page.getByRole('checkbox', { checked: true }).first() });
    }
    case 'auto-explore-settings':
      await tool('viewerActionSettingsExplore');
      return surface('autoExploreTitle');
    case 'kaleidoscope-options':
      await tool('viewerActionSettingsKaleidoscope');
      return surface('kaleidoscopeOptionsTitle');
    case 'theme-selector': {
      await starts('button', 'paramColorScheme').click();
      const dark = starts('button', 'settingsThemeDark');
      const marker = row.inputs.theme === 'highContrast' ? starts('button', 'settingsThemeHighContrast') : dark;
      return surface('settingsColorTheme', { actions: [b('actionCancel')], marker, anchor: dark,
        scrollMarker: row.inputs.theme === 'highContrast', scrollActions: true, selected: true });
    }
    case 'about-dialog':
      await starts('button', 'settingsAbout').click();
      return surface('Fractal Forge', { marker: t('settingsAboutBlurb'), dismiss: b('actionClose') });
    default:
      throw new Error(`No browser journey for ${row.state}`);
  }
}

async function png(page, id) {
  const filename = `${id}.png`;
  const bytes = await page.screenshot({ animations: 'disabled', timeout: 5000 });
  assert.equal(bytes.subarray(0, 16).toString('hex'), '89504e470d0a1a0a0000000d49484452');
  const decoded = await page.evaluate(async (source) => {
    const bitmap = await createImageBitmap(new Blob([Uint8Array.from(atob(source), (c) => c.charCodeAt(0))], { type: 'image/png' }));
    const size = { width: bitmap.width, height: bitmap.height };
    bitmap.close();
    return size;
  }, bytes.toString('base64'));
  assert.deepEqual(decoded, { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20) });
  assert.deepEqual(decoded, page.viewportSize());
  fs.writeFileSync(path.join(output, filename), bytes, { flag: 'wx' });
  return { path: filename, ...decoded, sha256: digest(bytes) };
}

async function capture(page, browser, row, result, metadata) {
  const { width, height, locale, theme } = row.inputs;
  const c = controls(page, labels[locale]);
  page.on('pageerror', (error) => result.errors.push({ kind: 'page', text: error.message }));
  page.on('console', (message) => {
    if (message.text().includes('backend_decision')) result.appBackend = message.text();
    if (message.type() === 'error') result.errors.push({ kind: 'console', text: message.text() });
  });
  page.on('requestfailed', (request) => result.errors.push({ kind: 'requestfailed', url: request.url(), text: request.failure()?.errorText }));
  page.on('response', (response) => {
    if (response.status() >= 400) result.errors.push({ kind: 'http', url: response.url(), text: String(response.status()) });
  });
  await page.setViewportSize({ width, height });
  await page.emulateMedia({ reducedMotion: 'reduce' });
  if (['presets-user-populated', 'preset-rename'].includes(row.state)) {
    // PresetStorageSlot / FractalPreset.toJson / shared_preferences_web.
    await page.addInitScript((name) => localStorage.setItem('flutter.user_presets_mandelbrot', JSON.stringify(JSON.stringify([
      { id: 'overlay-capture-sample', name, moduleId: 'mandelbrot', params: { iterations: 100 },
        createdAt: '2026-01-01T00:00:00.000Z' },
    ]))), sample);
  }
  const settings = ['theme-selector', 'about-dialog'].includes(row.state);
  const back = c.starts('button', 'viewerBackToCatalog');
  const viewer = c.starts('group', 'semanticFractalCanvas');
  await readyViewer(page, row, result, metadata);
  const settingsButton = c.button('tabSettings');
  if (settings || theme !== 'dark') {
    await back.click();
    await settingsButton.click();
    if (theme !== 'dark') {
      await c.starts('button', 'paramColorScheme').click();
      const option = c.starts('button', theme === 'oled' ? 'settingsThemeOled' : 'settingsThemeHighContrast');
      await reveal(page, option, c.starts('button', 'settingsThemeDark'));
      await option.click();
      await expect.poll(() => prefs(page, 'app_theme_mode')).toBe(theme === 'oled' ? 1 : 2);
    }
    if (!settings) await readyViewer(page, row, result, metadata);
  }
  const before = settings ? null : await viewerState(page);
  const actualTheme = ['dark', 'oled', 'highContrast'][await prefs(page, 'app_theme_mode') ?? 0];
  assert.equal(actualTheme, theme);
  const session = await browser.newBrowserCDPSession();
  try {
    const { gpu } = await session.send('SystemInfo.getInfo');
    result.browser = { version: browser.version(), glRenderer: gpu.auxAttributes?.glRenderer ?? null };
  } finally {
    await session.detach();
  }
  const metrics = await page.evaluate(() => ({
    width: innerWidth, height: innerHeight, dpr: devicePixelRatio, locale: navigator.language,
    rootFont: getComputedStyle(document.documentElement).fontSize,
    reducedMotion: matchMedia('(prefers-reduced-motion: reduce)').matches,
    clientWidth: document.documentElement.clientWidth, scrollWidth: document.documentElement.scrollWidth,
    fontResources: performance.getEntriesByType('resource').map((entry) => entry.name)
      .filter((url) => /\.(woff2?|ttf|otf)(\?|$)|\/canvaskit\//i.test(url)),
  }));
  // The pinned Flutter web engine derives native scale from <html> font size / 16
  // (findBrowserTextScaleFactor); this is not a measurement of individual painted text.
  result.runtime = { ...metrics, appLocale: null, appTheme: actualTheme, textScale: metrics.rootFont === '16px' ? 1 : null };
  assert.deepEqual([metrics.width, metrics.height, metrics.dpr, result.runtime.textScale, metrics.reducedMotion],
    [width, height, 1, 1, true]);
  const surface = await openSurface(page, row, c);
  const checkBounds = (box, label) => {
    const tolerance = manifest.rounding_tolerance;
    assert.ok(box && box.width > 0 && box.height > 0 && box.x >= -tolerance && box.y >= -tolerance &&
      box.x + box.width <= width + tolerance && box.y + box.height <= height + tolerance,
    `${label} bounds are missing or clipped by the viewport: ${JSON.stringify(box)}`);
  };
  result.internalLayout = { title: null, marker: null, actions: [], focusAfterDismiss: null };
  if (!surface.terminalFirst) {
    await expect(surface.dismiss).toBeVisible();
    await expect(surface.title).toBeInViewport();
    result.title = surface.titleLabel;
    result.internalLayout.title = await surface.title.boundingBox();
    result.internalLayout.titleBoxKind = surface.mergedTitle ? 'merged viewer semantics group' : 'title node';
    if (surface.scrollMarker) {
      result.topPng = await png(page, `${row.id}--top`);
      await reveal(page, surface.scrollProbe ?? surface.marker, surface.anchor, {
        action: Boolean(surface.scrollProbe), minHeight: surface.scrollProbe ? 48 - manifest.rounding_tolerance : 0,
      });
      if (surface.scrollProbe) {
        const box = await surface.scrollProbe.boundingBox();
        checkBounds(box, 'Scroll reachability probe');
        result.internalLayout.scrollProbe = { label: await surface.scrollProbe.ariaSnapshot(), box };
        const card = await surface.marker.boundingBox();
        checkBounds(card, 'Preset card');
        await page.mouse.move(card.x + card.width / 4, card.y + card.height / 2); // Leave the rename tooltip.
      }
    }
  }
  await expect(surface.marker).toBeInViewport();
  if (surface.selected) await expect(surface.marker).toHaveAttribute('aria-current', 'true');
  const overlayWidths = await page.evaluate(() => ({ clientWidth: document.documentElement.clientWidth,
    scrollWidth: document.documentElement.scrollWidth }));
  Object.assign(result.runtime, overlayWidths);
  result.documentOverflow = overlayWidths.scrollWidth - overlayWidths.clientWidth > manifest.rounding_tolerance;
  result.internalLayout.marker = await surface.marker.boundingBox();
  result.marker = await surface.marker.ariaSnapshot();
  result.png = await png(page, row.id);
  if (surface.terminalFirst) {
    await reveal(page, surface.dismiss, surface.anchor, { delta: -10_000 });
    await expect(surface.title).toBeVisible();
    result.title = surface.titleLabel;
    result.internalLayout.title = await surface.title.boundingBox();
    result.internalLayout.titleBoxKind = surface.mergedTitle ? 'merged viewer semantics group' : 'title node';
    result.topPng = await png(page, `${row.id}--top`);
  }
  result.runtime.appLocale = locale; // Exact shipping localized surface matched above.
  if (!surface.mergedTitle) checkBounds(result.internalLayout.title, 'Title');
  checkBounds(result.internalLayout.marker, 'Surface marker');
  if (surface.disabledAction) {
    await expect(surface.disabledAction).toBeDisabled();
    await expect(surface.disabledAction).toBeInViewport();
    result.internalLayout.disabledAction = { label: await surface.disabledAction.ariaSnapshot(),
      box: await surface.disabledAction.boundingBox(), reason: 'Save & share is intentionally disabled on web' };
    checkBounds(result.internalLayout.disabledAction.box, 'Disabled action');
  }
  if (surface.scrollMarker && !surface.scrollActions) {
    await reveal(page, surface.dismiss, surface.marker, { delta: -10_000 });
  }
  const reachErrors = [];
  for (const action of [...surface.actions, surface.dismiss]) {
    if (surface.scrollActions && action !== surface.dismiss) {
      await reveal(page, action, surface.marker, { action: false });
      result.terminalPng = await png(page, `${row.id}--terminal`);
    }
    if (surface.scrollActions && action === surface.dismiss) {
      await reveal(page, surface.dismiss, surface.actions[0], { delta: -10_000, action: false });
    }
    const observation = { label: await action.ariaSnapshot({ timeout: 1000 }), box: null };
    result.internalLayout.actions.push(observation);
    await expect(action).toBeInViewport({ ratio: 0.98 });
    observation.box = await action.boundingBox();
    try {
      await action.click({ trial: true, timeout: 1500 });
    } catch (error) {
      observation.pointerError = error.message;
      reachErrors.push(error);
    }
    checkBounds(observation.box, 'Action');
  }
  if (result.internalLayout.actions.at(-1).pointerError) await page.keyboard.press('Escape');
  else await surface.dismiss.click();
  await expect(row.state === 'save-share' ? surface.marker : surface.title).toBeHidden();
  if (surface.parentDismiss) {
    await reveal(page, surface.parentDismiss, surface.parentAnchor, { delta: -10_000 });
    await surface.parentDismiss.click();
  }
  if (settings) {
    await expect(c.starts('button', 'paramColorScheme')).toBeVisible();
  } else {
    await expect(back).toBeVisible();
    await expect(viewer).toBeFocused();
    await expect.poll(() => viewerState(page)).toEqual(before);
  }
  result.internalLayout.focusAfterDismiss = await page.evaluate(() => ({
    tag: document.activeElement?.tagName, label: document.activeElement?.getAttribute('aria-label'),
  }));
  if (reachErrors.length) throw reachErrors[0];
  assert.equal(result.documentOverflow, false, 'Document horizontal overflow >1px');
  assert.deepEqual(result.errors, [], 'Browser console/page/resource errors');
}

if (output && process.env.PLAYWRIGHT_OVERLAY_AUDIT === '1') {
  const rows = selectRows(manifest);
  const metadata = {
    checkoutSource: execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8', timeout: 3000 }).trim(),
    // The caller records this at build time; HEAD only identifies the capture checkout.
    buildSource: /^[a-f0-9]{40}$/.test(process.env.APP_QUALITY_SOURCE ?? '') ? process.env.APP_QUALITY_SOURCE : null,
    manifestSha256: digest(fs.readFileSync(manifestUrl)),
    bundleSha256: fs.existsSync('build/web/main.dart.js') ? digest(fs.readFileSync('build/web/main.dart.js')) : null,
    loopback: `http://127.0.0.1:${process.env.PLAYWRIGHT_PORT}`,
    playwright: '1.59.1',
    appDeclaredFonts: ['Poppins', 'Inter', 'JetBrains Mono'], // AppTypography
    flutterPin: fs.readFileSync('fdroid/flutter.version', 'utf8').trim(),
    renderer: 'release JS / CanvasKit; smoke GPU iteration cap 10 (build command in test plan)',
  };
  test('case selection and negative guards', () => {
    assert.throws(() => selectRows({ ...manifest, schema: 0 }), /schema/);
    assert.throws(() => selectRows({ ...manifest, rows: manifest.rows.slice(1) }), /baseline count/);
    assert.throws(() => selectRows({ ...manifest, rows: [...manifest.rows, manifest.rows[0]] }), /duplicate row ID/);
    report(rows, metadata);
  });
  for (const row of rows) {
    test.describe(row.id, () => {
      test.use({ locale: row.inputs.locale === 'es' ? 'es-ES' : 'en-US' });
      test('capture actual overlay', async ({ page, browser }, testInfo) => {
        const { id, inputs, state, componentRow } = row;
        const result = { id, inputs, state, componentRow, status: 'failed', documentOverflow: null,
          internalLayout: null, runtime: null, png: null, errors: [] };
        try {
          await capture(page, browser, row, result, metadata);
          result.status = 'passed';
        } catch (error) {
          result.error = error.message.replace(/\x1b\[[0-9;]*m/g, '');
          const snapshot = await page.locator('body').ariaSnapshot({ timeout: 1000 }).catch(() => null);
          if (snapshot) await testInfo.attach('semantics.txt', { body: snapshot, contentType: 'text/plain' });
          throw error;
        } finally {
          report(rows, metadata, result);
        }
      });
    });
  }
}
