import { test, expect } from 'playwright/test';

// Legacy SharedPreferences formats: session/presets are JSON strings inside
// the web preference envelope; string-list favorites have only one envelope.
const session = {
  schemaVersion: 1, moduleId: 'newton_z3',
  params: { iterations: 80, relaxation: 0.75, colorScheme: 2 },
  view: { pan: [0.125, -0.25], zoom: 1.5, rotation: [0, 0, 0] },
  transparentBackground: false, rotationLocked: false,
  glowEnabled: false, glowSigma: 0, glowIntensity: 0,
  fluidModeEnabled: false, fluidStrength: 0,
  kaleidoscopeEnabled: false, kaleidoscopeSectors: 6,
  kaleidoscopeMirror: false, kaleidoscopeRotation: 0, kaleidoscopeMirrorMode: 0,
  controlsVisible: false, fullscreenUnobtrusive: false, viewerActive: true,
};
const preset = {
  id: 'legacy-newton-preset', moduleId: 'newton_z3', name: 'Legacy Newton view',
  params: { iterations: 96, relaxation: 1.25, colorScheme: 3 },
  view: { panX: -0.375, panY: 0.125, zoom: 2.25, rotX: 0, rotY: 0, rotZ: 0 },
  createdAt: '2026-01-01T00:00:00.000', isBuiltIn: false, thumbnailPath: null,
};

async function enableAccessibility(page) {
  const enable = page.getByRole('button', { name: /enable accessibility/i });
  await expect(enable).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await expect(enable).toBeHidden();
}

async function savedSession(page) {
  return page.evaluate(() => JSON.parse(JSON.parse(localStorage.getItem('flutter.viewer_session_v1'))));
}

async function expectNewton(page) {
  await expect(page.getByRole('button', { name: /back to catalog/i })).toBeVisible();
  await expect(page.getByRole('group', { name: /Interactive fractal canvas Newton Fractal/ })).toBeVisible();
  await expect(page.locator('canvas').first()).toBeVisible();
}

async function applyLegacyPreset(page) {
  await page.getByRole('group', { name: /Interactive fractal canvas Newton Fractal/ })
    .click({ button: 'right', position: { x: 300, y: 250 }, force: true });
  await page.getByRole('menuitem', { name: /open presets/i }).click({ force: true });
  const savedPreset = page.getByRole('group', { name: preset.name, exact: true });
  await expect(savedPreset).toBeVisible();
  await savedPreset.click({ position: { x: 30, y: 24 }, force: true });
  await expect.poll(async () => (await savedSession(page)).params.relaxation).toBe(1.25);
  const applied = await savedSession(page);
  expect(applied.moduleId).toBe(preset.moduleId);
  expect(applied.params).toMatchObject(preset.params);
  expect(applied.view).toEqual({ pan: [-0.375, 0.125], zoom: 2.25, rotation: [0, 0, 0] });
}

test('production restores legacy saved sessions, edits, favorites and usable presets', async ({ page }, testInfo) => {
  test.setTimeout(120_000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.addInitScript(({ session, preset }) => {
    // Seed once, never overwrite the app's edits when the page reloads.
    if (localStorage.getItem('saved-session-fixture-seeded')) return;
    localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(JSON.stringify(session)));
    localStorage.setItem('flutter.catalog_favorite_ids', JSON.stringify(['core.newton_z3']));
    localStorage.setItem('flutter.user_presets_newton_z3', JSON.stringify(JSON.stringify([preset])));
    localStorage.setItem('saved-session-fixture-seeded', 'true');
  }, { session, preset });

  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await enableAccessibility(page);
  await expectNewton(page);
  // UI edits force a fresh snapshot of the restored controller, not a read
  // of the seed left untouched in localStorage.
  await page.getByRole('button', { name: /^More$/i }).click();
  await page.getByRole('button', { name: /^Color Scheme\. Long press for palette$/i }).click();
  await expect.poll(async () => (await savedSession(page)).params.colorScheme).not.toBe(2);
  const colorEdited = await savedSession(page);
  expect(colorEdited.moduleId).toBe('newton_z3');
  expect(colorEdited.params).toMatchObject({ iterations: 80, relaxation: 0.75 });
  expect(colorEdited.view).toEqual(session.view);
  await page.mouse.move(400, 300);
  await page.mouse.wheel(0, -300);
  await expect.poll(async () => (await savedSession(page)).view.zoom).not.toBe(1.5);
  const edited = await savedSession(page);

  // Reload the app entry point: a previously generated share URL is a
  // separate explicit state input and must not mask session restoration.
  await page.evaluate(() => history.replaceState(null, '', '/'));
  await page.reload({ waitUntil: 'domcontentloaded' });
  await enableAccessibility(page);
  await expectNewton(page);
  // A second UI edit proves the reload restored the edited controller values.
  await page.getByRole('button', { name: /^More$/i }).click();
  await page.getByRole('button', { name: /^Color Scheme\. Long press for palette$/i }).click();
  await expect.poll(async () => (await savedSession(page)).params.colorScheme).not.toBe(edited.params.colorScheme);
  const restored = await savedSession(page);
  expect(restored.params).toEqual({ ...edited.params, colorScheme: edited.params.colorScheme + 1 });
  expect(restored.view).toEqual(edited.view);
  expect(restored.moduleId).toBe(edited.moduleId);
  await applyLegacyPreset(page);

  await page.getByRole('button', { name: /back to catalog/i }).click({ force: true });
  await page.getByRole('button', { name: /favorites filter/i }).click({ force: true });
  const favorite = page.locator('flt-semantics[aria-label*="Newton Fractal"]').first();
  await expect(favorite).toBeVisible();
  await favorite.click({ force: true });
  await expectNewton(page);
  await applyLegacyPreset(page);
  const retained = await page.evaluate(() => ({
    favorites: JSON.parse(localStorage.getItem('flutter.catalog_favorite_ids')),
    presets: JSON.parse(JSON.parse(localStorage.getItem('flutter.user_presets_newton_z3'))),
  }));
  expect(retained.favorites).toEqual(['core.newton_z3']);
  expect(retained.presets).toEqual([preset]);
  expect(errors).toEqual([]);
  await testInfo.attach('saved-data-observation.json', {
    body: Buffer.from(JSON.stringify({ seeded: session, edited, restored, retained }, null, 2)),
    contentType: 'application/json',
  });
});
