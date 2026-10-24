import { test, expect } from 'playwright/test';

const persistedViewerSession = JSON.stringify({
  schemaVersion: 1,
  moduleId: 'newton_z3',
  params: {},
  view: { pan: [0, 0], zoom: 1, rotation: [0, 0, 0] },
  transparentBackground: false,
  rotationLocked: false,
  glowEnabled: false,
  glowSigma: 0,
  glowIntensity: 0,
  fluidModeEnabled: false,
  fluidStrength: 0,
  kaleidoscopeEnabled: false,
  kaleidoscopeSectors: 6,
  kaleidoscopeMirror: false,
  kaleidoscopeRotation: 0,
  kaleidoscopeMirrorMode: 0,
  controlsVisible: true,
  fullscreenUnobtrusive: false,
  viewerActive: true,
});

test('restores the active saved viewer session on launch', async ({ page, baseURL }) => {
  await page.addInitScript((value) => {
    localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(value));
  }, persistedViewerSession);

  await page.goto(new URL('/', baseURL).toString(), {
    waitUntil: 'domcontentloaded',
  });
  const enableAccessibility = page.getByRole('button', {
    name: /enable accessibility/i,
  });
  await expect(enableAccessibility).toBeVisible();
  await page.evaluate(() =>
    document.querySelector('flt-semantics-placeholder')?.click(),
  );
  await expect(enableAccessibility).toBeHidden();

  await expect(page.getByRole('button', { name: /back to catalog/i }))
    .toBeVisible({ timeout: 30_000 });
  await expect(page.getByText(/Newton Fractal/)).toBeVisible({ timeout: 30_000 });
  await expect(page.locator('canvas').first()).toBeVisible({ timeout: 30_000 });
  const restoredSession = await page.evaluate(() => {
    const stored = localStorage.getItem('flutter.viewer_session_v1');
    return stored == null ? null : JSON.parse(JSON.parse(stored));
  });
  expect(restoredSession.moduleId).toBe('newton_z3');
  expect(restoredSession.viewerActive).toBe(true);
});
