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

test('explicit smoke module wins over an active persisted viewer session', async ({ page, baseURL }) => {
  await page.addInitScript((value) => {
    localStorage.setItem('flutter.viewer_session_v1', JSON.stringify(value));
  }, persistedViewerSession);

  const opened = page.waitForEvent('console', {
    predicate: (message) => message.text().includes('PLAYWRIGHT_CATALOG_SMOKE_OPENED:mandelbrot'),
    timeout: 30_000,
  });
  const firstFrame = page.waitForEvent('console', {
    predicate: (message) => message.text().includes('PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:mandelbrot'),
    timeout: 30_000,
  });
  await page.goto(new URL('/?smokeModule=mandelbrot', baseURL).toString(), {
    waitUntil: 'domcontentloaded',
  });

  await Promise.all([opened, firstFrame]);
  await expect(page.locator('canvas').first()).toBeVisible();
});
