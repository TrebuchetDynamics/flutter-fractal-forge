import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
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
  const offset = Number(process.env.CATALOG_SMOKE_OFFSET || 0);
  if (offset > 0) {
    ids = ids.slice(offset);
  }
  if (process.env.CATALOG_SMOKE_LIMIT) {
    ids = ids.slice(0, Number(process.env.CATALOG_SMOKE_LIMIT));
  }
  return ids;
}

const ignoredConsolePatterns = [
  /^Loading from existing service worker\./,
  /^Service worker already active\./,
  /^Exception while loading service worker:/,
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
      const warnings = failure.warnings?.length
        ? `\n    warnings:\n${failure.warnings.map((warning) => `    - ${warning.kind}: ${warning.text}`).join('\n')}`
        : '';
      return `  ${failure.id}\n${details}${warnings}`;
    })
    .join('\n');
}

function visualConfig() {
  return {
    enabled: process.env.CATALOG_SMOKE_VISUAL !== '0',
    cropInset: Number(process.env.CATALOG_SMOKE_VISUAL_CROP_INSET || 0),
    sampleStep: Math.max(1, Number(process.env.CATALOG_SMOKE_VISUAL_SAMPLE_STEP || 4)),
    minLumaStd: Number(process.env.CATALOG_SMOKE_VISUAL_MIN_LUMA_STD || 4.0),
    minEdgeDensity: Number(process.env.CATALOG_SMOKE_VISUAL_MIN_EDGE_DENSITY || 0.0025),
    minActiveRatio: Number(process.env.CATALOG_SMOKE_VISUAL_MIN_ACTIVE_RATIO || 0.003),
    minUniqueColors: Number(process.env.CATALOG_SMOKE_VISUAL_MIN_UNIQUE_COLORS || 10),
    activeColorDistance: Number(process.env.CATALOG_SMOKE_VISUAL_ACTIVE_DISTANCE || 24),
    flatTileStdThreshold: Number(process.env.CATALOG_SMOKE_VISUAL_FLAT_TILE_STD || 5),
    maxFlatTileRatio: Number(process.env.CATALOG_SMOKE_VISUAL_MAX_FLAT_TILE_RATIO || 0.96),
    strictFraming: process.env.CATALOG_SMOKE_STRICT_FRAMING === '1',
    screenshotMode: process.env.CATALOG_SMOKE_SCREENSHOTS || 'failures',
  };
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
  const signature = '89504e470d0a1a0a';
  if (buffer.subarray(0, 8).toString('hex') !== signature) {
    throw new Error('Screenshot was not a PNG');
  }

  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  const idatChunks = [];

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
      idatChunks.push(data);
    } else if (type === 'IEND') {
      break;
    }
  }

  if (bitDepth !== 8) {
    throw new Error(`Unsupported PNG bit depth ${bitDepth}; expected 8`);
  }

  const channelsByColorType = new Map([
    [0, 1], // grayscale
    [2, 3], // RGB
    [4, 2], // grayscale + alpha
    [6, 4], // RGBA
  ]);
  const channels = channelsByColorType.get(colorType);
  if (!channels) {
    throw new Error(`Unsupported PNG color type ${colorType}`);
  }

  const inflated = zlib.inflateSync(Buffer.concat(idatChunks));
  const stride = width * channels;
  const raw = Buffer.alloc(height * stride);
  let sourceOffset = 0;

  for (let y = 0; y < height; y++) {
    const filter = inflated[sourceOffset++];
    const rowOffset = y * stride;
    const previousRowOffset = (y - 1) * stride;

    for (let x = 0; x < stride; x++) {
      const value = inflated[sourceOffset++];
      const left = x >= channels ? raw[rowOffset + x - channels] : 0;
      const up = y > 0 ? raw[previousRowOffset + x] : 0;
      const upLeft = y > 0 && x >= channels ? raw[previousRowOffset + x - channels] : 0;

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
      rgba[j] = raw[i];
      rgba[j + 1] = raw[i];
      rgba[j + 2] = raw[i];
      rgba[j + 3] = 255;
    } else if (colorType === 2) {
      rgba[j] = raw[i];
      rgba[j + 1] = raw[i + 1];
      rgba[j + 2] = raw[i + 2];
      rgba[j + 3] = 255;
    } else if (colorType === 4) {
      rgba[j] = raw[i];
      rgba[j + 1] = raw[i];
      rgba[j + 2] = raw[i];
      rgba[j + 3] = raw[i + 1];
    } else {
      rgba[j] = raw[i];
      rgba[j + 1] = raw[i + 1];
      rgba[j + 2] = raw[i + 2];
      rgba[j + 3] = raw[i + 3];
    }
  }

  return { width, height, rgba };
}

function pixelAt(image, x, y) {
  const offset = (y * image.width + x) * 4;
  return [
    image.rgba[offset],
    image.rgba[offset + 1],
    image.rgba[offset + 2],
    image.rgba[offset + 3],
  ];
}

function luma([r, g, b]) {
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function colorDistance(a, b) {
  const dr = a[0] - b[0];
  const dg = a[1] - b[1];
  const db = a[2] - b[2];
  return Math.sqrt(dr * dr + dg * dg + db * db);
}

function cropBounds(image, config) {
  const insetX = Math.floor(image.width * config.cropInset);
  const insetY = Math.floor(image.height * config.cropInset);
  return {
    x0: Math.min(insetX, Math.floor(image.width / 3)),
    y0: Math.min(insetY, Math.floor(image.height / 3)),
    x1: Math.max(image.width - insetX, Math.ceil((image.width * 2) / 3)),
    y1: Math.max(image.height - insetY, Math.ceil((image.height * 2) / 3)),
  };
}

function estimateBackground(samples) {
  const borderSamples = samples.filter((sample) => sample.border);
  const source = borderSamples.length > 0 ? borderSamples : samples;
  const sum = source.reduce(
    (acc, sample) => {
      acc[0] += sample.color[0];
      acc[1] += sample.color[1];
      acc[2] += sample.color[2];
      return acc;
    },
    [0, 0, 0],
  );
  return sum.map((value) => value / Math.max(1, source.length));
}

function analyzeImage(image, config) {
  const bounds = cropBounds(image, config);
  const step = config.sampleStep;
  const borderWidth = Math.max(step * 2, Math.floor(Math.min(bounds.x1 - bounds.x0, bounds.y1 - bounds.y0) * 0.08));
  const samples = [];

  for (let y = bounds.y0; y < bounds.y1; y += step) {
    for (let x = bounds.x0; x < bounds.x1; x += step) {
      const color = pixelAt(image, x, y);
      if (color[3] < 8) continue;
      const border = x < bounds.x0 + borderWidth || x >= bounds.x1 - borderWidth ||
        y < bounds.y0 + borderWidth || y >= bounds.y1 - borderWidth;
      samples.push({ x, y, color, border, luma: luma(color) });
    }
  }

  if (samples.length === 0) {
    return {
      width: image.width,
      height: image.height,
      crop: bounds,
      sampleCount: 0,
      lumaMean: 0,
      lumaStd: 0,
      activeRatio: 0,
      borderActiveRatio: 0,
      edgeDensity: 0,
      edgeMean: 0,
      uniqueColors: 0,
      flatTileRatio: 1,
    };
  }

  const background = estimateBackground(samples);
  const lumaMean = samples.reduce((sum, sample) => sum + sample.luma, 0) / samples.length;
  const lumaVariance = samples.reduce((sum, sample) => {
    const delta = sample.luma - lumaMean;
    return sum + delta * delta;
  }, 0) / samples.length;
  const lumaStd = Math.sqrt(lumaVariance);

  let active = 0;
  let borderActive = 0;
  let borderTotal = 0;
  const unique = new Set();
  for (const sample of samples) {
    const dist = colorDistance(sample.color, background);
    const isActive = dist >= config.activeColorDistance;
    if (isActive) active++;
    if (sample.border) {
      borderTotal++;
      if (isActive) borderActive++;
    }
    unique.add(`${sample.color[0] >> 4},${sample.color[1] >> 4},${sample.color[2] >> 4}`);
  }

  let edgePairs = 0;
  let edgeHits = 0;
  let edgeSum = 0;
  for (let y = bounds.y0; y < bounds.y1 - step; y += step) {
    for (let x = bounds.x0; x < bounds.x1 - step; x += step) {
      const here = pixelAt(image, x, y);
      const right = pixelAt(image, x + step, y);
      const down = pixelAt(image, x, y + step);
      const d1 = colorDistance(here, right);
      const d2 = colorDistance(here, down);
      edgePairs += 2;
      edgeSum += d1 + d2;
      if (d1 >= config.activeColorDistance) edgeHits++;
      if (d2 >= config.activeColorDistance) edgeHits++;
    }
  }

  const tiles = 8;
  let flatTiles = 0;
  let tileCount = 0;
  for (let ty = 0; ty < tiles; ty++) {
    for (let tx = 0; tx < tiles; tx++) {
      const tx0 = Math.floor(bounds.x0 + ((bounds.x1 - bounds.x0) * tx) / tiles);
      const tx1 = Math.floor(bounds.x0 + ((bounds.x1 - bounds.x0) * (tx + 1)) / tiles);
      const ty0 = Math.floor(bounds.y0 + ((bounds.y1 - bounds.y0) * ty) / tiles);
      const ty1 = Math.floor(bounds.y0 + ((bounds.y1 - bounds.y0) * (ty + 1)) / tiles);
      const tileLumas = [];
      for (let y = ty0; y < ty1; y += step * 2) {
        for (let x = tx0; x < tx1; x += step * 2) {
          tileLumas.push(luma(pixelAt(image, x, y)));
        }
      }
      if (tileLumas.length === 0) continue;
      const mean = tileLumas.reduce((sum, value) => sum + value, 0) / tileLumas.length;
      const variance = tileLumas.reduce((sum, value) => {
        const delta = value - mean;
        return sum + delta * delta;
      }, 0) / tileLumas.length;
      if (Math.sqrt(variance) < config.flatTileStdThreshold) flatTiles++;
      tileCount++;
    }
  }

  return {
    width: image.width,
    height: image.height,
    crop: bounds,
    sampleCount: samples.length,
    background: background.map((value) => Number(value.toFixed(1))),
    lumaMean: Number(lumaMean.toFixed(2)),
    lumaStd: Number(lumaStd.toFixed(2)),
    activeRatio: Number((active / samples.length).toFixed(4)),
    borderActiveRatio: Number((borderActive / Math.max(1, borderTotal)).toFixed(4)),
    edgeDensity: Number((edgeHits / Math.max(1, edgePairs)).toFixed(4)),
    edgeMean: Number((edgeSum / Math.max(1, edgePairs)).toFixed(2)),
    uniqueColors: unique.size,
    flatTileRatio: Number((flatTiles / Math.max(1, tileCount)).toFixed(4)),
  };
}

function visualFindings(metrics, config) {
  const errors = [];
  const warnings = [];
  const blankLike = metrics.lumaStd < config.minLumaStd &&
    metrics.edgeDensity < config.minEdgeDensity &&
    metrics.activeRatio < config.minActiveRatio &&
    metrics.uniqueColors < config.minUniqueColors;
  if (blankLike) {
    errors.push({
      kind: 'visual-blank',
      text: `Rendered crop is blank/flat: lumaStd=${metrics.lumaStd}, edgeDensity=${metrics.edgeDensity}, activeRatio=${metrics.activeRatio}, uniqueColors=${metrics.uniqueColors}`,
    });
  }

  const lowDetail = metrics.flatTileRatio > config.maxFlatTileRatio &&
    metrics.lumaStd < config.minLumaStd * 1.5 &&
    metrics.edgeDensity < config.minEdgeDensity * 2.0;
  if (lowDetail && !blankLike) {
    errors.push({
      kind: 'visual-low-detail',
      text: `Rendered crop has too little detail: flatTileRatio=${metrics.flatTileRatio}, lumaStd=${metrics.lumaStd}, edgeDensity=${metrics.edgeDensity}`,
    });
  }

  const frameSuspect = metrics.activeRatio > 0.92 &&
    metrics.borderActiveRatio > 0.9 &&
    metrics.edgeDensity < Math.max(0.01, config.minEdgeDensity * 3.0);
  if (frameSuspect) {
    const finding = {
      kind: 'visual-framing',
      text: `Possible over-zoom/clipped framing: activeRatio=${metrics.activeRatio}, borderActiveRatio=${metrics.borderActiveRatio}, edgeDensity=${metrics.edgeDensity}`,
    };
    if (config.strictFraming) errors.push(finding);
    else warnings.push(finding);
  }

  return { errors, warnings };
}

async function largestCanvasClip(page) {
  return page.locator('canvas').evaluateAll((canvases) => {
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const boxes = canvases
      .map((canvas, index) => {
        const rect = canvas.getBoundingClientRect();
        const x = Math.max(0, rect.left);
        const y = Math.max(0, rect.top);
        const width = Math.min(viewportWidth, rect.right) - x;
        const height = Math.min(viewportHeight, rect.bottom) - y;
        return { index, x, y, width, height, area: width * height };
      })
      .filter((box) => box.width >= 16 && box.height >= 16 && box.area > 0)
      .sort((a, b) => b.area - a.area);
    if (boxes.length === 0) return null;
    const box = boxes[0];
    return {
      x: Math.floor(box.x),
      y: Math.floor(box.y),
      width: Math.floor(box.width),
      height: Math.floor(box.height),
    };
  });
}

function safeFileName(id) {
  return id.replace(/[^a-zA-Z0-9_.-]+/g, '_');
}

async function captureAndAnalyze(page, result, browserName, config) {
  const clip = await largestCanvasClip(page);
  if (!clip) {
    result.errors.push({ kind: 'visual-canvas', text: 'No visible canvas clip was available for screenshot analysis.' });
    return null;
  }

  const png = await page.screenshot({ clip, animations: 'disabled', timeout: 30_000 });
  const image = decodePng(png);
  const metrics = analyzeImage(image, config);
  result.visual = { clip, metrics };

  const findings = visualFindings(metrics, config);
  result.errors.push(...findings.errors);
  result.warnings.push(...findings.warnings);

  const shouldSave = config.screenshotMode === 'all' ||
    (config.screenshotMode === 'failures' && (findings.errors.length > 0 || findings.warnings.length > 0));
  let screenshotPath = null;
  if (shouldSave) {
    const dir = path.join(repoRoot, 'test/results', `catalog-smoke-visual-${browserName}`);
    fs.mkdirSync(dir, { recursive: true });
    screenshotPath = path.join(dir, `${String(result.index).padStart(3, '0')}-${safeFileName(result.id)}.png`);
    fs.writeFileSync(screenshotPath, png);
    result.visual.screenshot = path.relative(repoRoot, screenshotPath);
  }
  return screenshotPath;
}

function writeVisualGallery(browserName, report) {
  const rows = report.results.filter((result) => result.visual?.screenshot);
  if (rows.length === 0) return null;
  const galleryPath = path.join(repoRoot, 'test/results', `catalog-smoke-visual-${browserName}.html`);
  const cards = rows.map((result) => {
    const metrics = result.visual.metrics;
    const status = result.errors.length > 0 ? 'FAIL' : result.warnings.length > 0 ? 'WARN' : 'OK';
    const issues = [...result.errors, ...result.warnings]
      .map((finding) => `<li><strong>${finding.kind}</strong>: ${finding.text}</li>`)
      .join('');
    return `<article class="card ${status.toLowerCase()}">
      <h2>${result.index}. ${result.id} <span>${status}</span></h2>
      <img src="../${result.visual.screenshot}" alt="${result.id} Playwright screenshot">
      <pre>${JSON.stringify(metrics, null, 2)}</pre>
      <ul>${issues}</ul>
    </article>`;
  }).join('\n');
  fs.writeFileSync(galleryPath, `<!doctype html>
<html><head><meta charset="utf-8"><title>Catalog smoke visual report - ${browserName}</title>
<style>
body{font-family:system-ui,sans-serif;background:#111;color:#eee;margin:24px}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:16px}.card{background:#1b1b1b;border:1px solid #444;border-radius:12px;padding:12px}.fail{border-color:#f66}.warn{border-color:#fc3}.ok{border-color:#3c6}img{width:100%;height:auto;background:#000;border-radius:8px}pre{white-space:pre-wrap;font-size:11px;color:#ccc}span{float:right}</style>
</head><body><h1>Catalog smoke visual report - ${browserName}</h1><p>${report.total} modules, ${report.failures.length} failures, ${report.warnings.length} warnings</p><section class="grid">${cards}</section></body></html>`);
  return galleryPath;
}

test('every catalog fractal opens locally without browser/runtime errors', async ({ context, baseURL, browserName }, testInfo) => {
  const ids = selectedModuleIds();
  if (ids.length === 0) {
    throw new Error('Catalog smoke selected zero module IDs. Check catalog parser/filter env.');
  }

  const config = visualConfig();
  const moduleTimeoutMs = Number(process.env.CATALOG_SMOKE_MODULE_TIMEOUT_MS || 20_000);
  const settleMs = Number(process.env.CATALOG_SMOKE_SETTLE_MS || 1_200);
  const runId = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
  const results = [];
  testInfo.setTimeout(Math.max(testInfo.timeout, ids.length * (moduleTimeoutMs + settleMs + 8_000)));

  for (const [index, id] of ids.entries()) {
    const result = { id, index: index + 1, errors: [], warnings: [] };
    const openMarker = `PLAYWRIGHT_CATALOG_SMOKE_OPENED:${id}`;
    const firstFrameMarker = `PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${id}`;
    const page = await context.newPage();
    let openedSeen = false;
    let firstFrameSeen = false;

    const onConsole = (message) => {
      const text = message.text();
      if (text.includes(openMarker)) openedSeen = true;
      if (text.includes(firstFrameMarker)) firstFrameSeen = true;
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
      console.log(`[catalog-smoke] ${index + 1}/${ids.length} ${id}`);
      const targetUrl = new URL(
        `/?smokeModule=${encodeURIComponent(id)}&smokeIndex=${index}&smokeRun=${runId}`,
        baseURL,
      ).toString();
      await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });

      const [opened, firstFrame] = await Promise.all([
        openedSeen
          ? Promise.resolve(true)
          : page.waitForEvent('console', {
              predicate: (message) => message.text().includes(openMarker),
              timeout: moduleTimeoutMs,
            }).then(() => true).catch(() => false),
        firstFrameSeen
          ? Promise.resolve(true)
          : page.waitForEvent('console', {
              predicate: (message) => message.text().includes(firstFrameMarker),
              timeout: moduleTimeoutMs,
            }).then(() => true).catch(() => false),
      ]);

      if (!opened) {
        result.errors.push({
          kind: 'smoke-open',
          text: `App did not report ${openMarker} within ${moduleTimeoutMs}ms after navigation`,
        });
      }
      if (!firstFrame) {
        result.errors.push({
          kind: 'first-frame',
          text: `Renderer did not report ${firstFrameMarker} within ${moduleTimeoutMs}ms after navigation`,
        });
      }

      await page.waitForTimeout(settleMs);

      const canvasCount = await page.locator('canvas').count();
      if (canvasCount === 0) {
        result.errors.push({ kind: 'canvas', text: 'No canvas elements were present after viewer opened.' });
      } else if (config.enabled) {
        await captureAndAnalyze(page, result, browserName, config);
      }
    } catch (error) {
      result.errors.push({ kind: 'test-exception', text: compactError(error) });
    } finally {
      page.off('console', onConsole);
      page.off('pageerror', onPageError);
      page.off('requestfailed', onRequestFailed);
      page.off('response', onResponse);
      await page.close({ runBeforeUnload: false }).catch(() => {});
      results.push(result);
    }
  }

  fs.mkdirSync(path.join(repoRoot, 'test/results'), { recursive: true });
  const report = {
    browserName,
    baseURL,
    runId,
    visual: config,
    total: results.length,
    failures: results.filter((result) => result.errors.length > 0),
    warnings: results.filter((result) => result.warnings.length > 0),
    results,
  };
  const reportPath = path.join(repoRoot, `test/results/catalog-smoke-${browserName}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  const galleryPath = writeVisualGallery(browserName, report);
  await testInfo.attach('catalog-smoke-results', {
    path: reportPath,
    contentType: 'application/json',
  });
  if (galleryPath) {
    await testInfo.attach('catalog-smoke-visual-gallery', {
      path: galleryPath,
      contentType: 'text/html',
    });
  }

  if (report.failures.length > 0) {
    throw new Error(
      `${report.failures.length}/${report.total} catalog fractals reported errors. ` +
        `${report.warnings.length} visual framing warnings.\n` +
        `${formatFailureSummary(report.failures)}\n\nFull report: ${reportPath}`,
    );
  }
});
