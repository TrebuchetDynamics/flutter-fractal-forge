import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'playwright/test';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');

function extractConfigIds(relativePath, constructorName) {
  const source = fs.readFileSync(path.join(repoRoot, relativePath), 'utf8');
  const pattern = new RegExp(`${constructorName}\\(\\s*id:\\s*'([^']+)'`, 'g');
  return [...source.matchAll(pattern)].map((match) => match[1]);
}

function uniqueInOrder(values) {
  const seen = new Set();
  const result = [];
  for (const value of values) {
    if (seen.has(value)) continue;
    seen.add(value);
    result.push(value);
  }
  return result;
}

function loadCatalogModuleIds() {
  const escapeTimeIds = extractConfigIds(
    'lib/core/modules/builders/escape_time_catalog.dart',
    'EscapeTimeConfig',
  );
  const raymarched3DIds = extractConfigIds(
    'lib/core/modules/builders/raymarched_3d_catalog.dart',
    'Raymarched3DConfig',
  );
  const customIds = [
    'julia',
    'julia_dual',
    'phoenix',
    'nova',
    'mandelbulb',
    'mandelbox',
    'hydrogen_orbital',
  ];

  // Mirrors ModuleRegistry release ordering closely enough for smoke coverage:
  // catalog modules, custom modules not already declared, then raymarched 3D.
  return uniqueInOrder([...escapeTimeIds, ...customIds, ...raymarched3DIds]);
}

function selectedModuleIds() {
  let ids = loadCatalogModuleIds();
  if (process.env.CATALOG_SMOKE_FILTER) {
    const filter = new RegExp(process.env.CATALOG_SMOKE_FILTER);
    ids = ids.filter((id) => filter.test(id));
  }
  if (process.env.CATALOG_SMOKE_LIMIT) {
    ids = ids.slice(0, Number(process.env.CATALOG_SMOKE_LIMIT));
  }
  return ids;
}

const ignoredConsolePatterns = [
  /^Loading from existing service worker\./,
  /^Service worker already active\./,
  /^Injecting <script> tag\./,
  /WEBGL_debug_renderer_info is deprecated/i,
  /ObjectMultiplex - orphaned data/i,
];

const interestingConsolePatterns = [
  /RuntimeEffect error/i,
  /shader.*error/i,
  /FlutterError/i,
  /EXCEPTION CAUGHT/i,
  /Another exception was thrown/i,
  /Uncaught/i,
  /TypeError/i,
  /ReferenceError/i,
  /RangeError/i,
  /Error while trying to load an asset/i,
  /Failed to load resource/i,
];

function shouldRecordConsoleMessage(message) {
  const text = message.text();
  if (ignoredConsolePatterns.some((pattern) => pattern.test(text))) {
    return false;
  }
  return message.type() === 'error' ||
    interestingConsolePatterns.some((pattern) => pattern.test(text));
}

function compactError(error) {
  return String(error?.message || error).replace(/\s+/g, ' ').slice(0, 600);
}

function formatFailureSummary(failures) {
  return failures
    .map((failure) => {
      const details = failure.errors
        .map((error) => `    - ${error.kind}: ${error.text}`)
        .join('\n');
      return `  ${failure.id}\n${details}`;
    })
    .join('\n');
}

test('every catalog fractal opens locally without browser/runtime errors', async ({ page, baseURL, browserName }, testInfo) => {
  const ids = selectedModuleIds();
  if (ids.length === 0) {
    throw new Error('Catalog smoke selected zero module IDs. Check catalog parser/filter env.');
  }

  const moduleTimeoutMs = Number(process.env.CATALOG_SMOKE_MODULE_TIMEOUT_MS || 20_000);
  const settleMs = Number(process.env.CATALOG_SMOKE_SETTLE_MS || 1_200);
  const results = [];

  for (const [index, id] of ids.entries()) {
    const result = { id, index: index + 1, errors: [] };
    const openMarker = `PLAYWRIGHT_CATALOG_SMOKE_OPENED:${id}`;
    const firstFrameMarker = `PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${id}`;

    const onConsole = (message) => {
      if (!shouldRecordConsoleMessage(message)) return;
      const location = message.location();
      result.errors.push({
        kind: `console.${message.type()}`,
        text: `${message.text()}${location.url ? ` (${location.url}:${location.lineNumber})` : ''}`,
      });
    };
    const onPageError = (error) => {
      result.errors.push({ kind: 'pageerror', text: compactError(error) });
    };
    const onRequestFailed = (request) => {
      result.errors.push({
        kind: 'requestfailed',
        text: `${request.method()} ${request.url()} ${request.failure()?.errorText || ''}`.trim(),
      });
    };
    const onResponse = (response) => {
      const status = response.status();
      if (status >= 400) {
        result.errors.push({
          kind: 'http',
          text: `${status} ${response.url()}`,
        });
      }
    };

    page.on('console', onConsole);
    page.on('pageerror', onPageError);
    page.on('requestfailed', onRequestFailed);
    page.on('response', onResponse);

    try {
      const opened = page.waitForEvent('console', {
        predicate: (message) => message.text().includes(openMarker),
        timeout: moduleTimeoutMs,
      }).catch(() => null);
      const firstFrame = page.waitForEvent('console', {
        predicate: (message) => message.text().includes(firstFrameMarker),
        timeout: moduleTimeoutMs,
      }).catch(() => null);

      await page.goto(`/?smokeModule=${encodeURIComponent(id)}&smokeIndex=${index}`, {
        waitUntil: 'domcontentloaded',
      });

      if (!(await opened)) {
        result.errors.push({
          kind: 'smoke-open',
          text: `App did not report ${openMarker} within ${moduleTimeoutMs}ms`,
        });
      }
      if (!(await firstFrame)) {
        result.errors.push({
          kind: 'first-frame',
          text: `Renderer did not report ${firstFrameMarker} within ${moduleTimeoutMs}ms`,
        });
      }

      await page.waitForTimeout(settleMs);

      const canvasCount = await page.locator('canvas').count();
      if (canvasCount === 0) {
        result.errors.push({ kind: 'canvas', text: 'No canvas elements were present after viewer opened.' });
      }
    } catch (error) {
      result.errors.push({ kind: 'test-exception', text: compactError(error) });
    } finally {
      page.off('console', onConsole);
      page.off('pageerror', onPageError);
      page.off('requestfailed', onRequestFailed);
      page.off('response', onResponse);
      results.push(result);
    }
  }

  fs.mkdirSync(path.join(repoRoot, 'test-results'), { recursive: true });
  const report = {
    browserName,
    baseURL,
    total: results.length,
    failures: results.filter((result) => result.errors.length > 0),
    results,
  };
  const reportPath = path.join(repoRoot, `test-results/catalog-smoke-${browserName}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  await testInfo.attach('catalog-smoke-results', {
    path: reportPath,
    contentType: 'application/json',
  });

  if (report.failures.length > 0) {
    throw new Error(
      `${report.failures.length}/${report.total} catalog fractals reported errors.\n` +
        `${formatFailureSummary(report.failures)}\n\nFull report: ${reportPath}`,
    );
  }
});
