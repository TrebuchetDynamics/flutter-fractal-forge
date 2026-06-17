import { defineConfig, devices } from 'playwright/test';

const port = Number(process.env.PLAYWRIGHT_PORT || 4173);
const baseURL = process.env.PLAYWRIGHT_BASE_URL || `http://127.0.0.1:${port}`;
const useBundledWebServer = process.env.PLAYWRIGHT_SKIP_WEBSERVER !== '1' &&
  !process.env.PLAYWRIGHT_BASE_URL;

export default defineConfig({
  testDir: './test/playwright',
  timeout: 20 * 60 * 1000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  workers: 1,
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test/results/playwright-results.json' }],
  ],
  outputDir: './test/results',
  use: {
    baseURL,
    viewport: { width: 1280, height: 900 },
    actionTimeout: 10_000,
    navigationTimeout: 30_000,
    serviceWorkers: 'block',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],
  webServer: useBundledWebServer
    ? {
        command: `python3 -m http.server ${port} --bind 127.0.0.1 --directory build/web`,
        url: baseURL,
        reuseExistingServer: true,
        timeout: 10_000,
      }
    : undefined,
});
