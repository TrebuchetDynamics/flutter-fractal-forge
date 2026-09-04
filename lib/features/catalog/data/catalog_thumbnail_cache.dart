import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';

/// Renders each catalog thumbnail's pixels once and reuses them everywhere.
///
/// This is the real cache behind the catalog's runtime thumbnail pipeline.
/// Previously every visible runtime thumbnail spun up a fresh
/// [FractalController] + GPU [FractalRenderer] and re-rendered from scratch on
/// every scroll-in / rebuild, and nothing survived across app launches.
///
/// Design:
///  * A render *signature* (catalogId + effective render caps + schema
///    version) keys every entry, so changing how thumbnails are rendered
///    invalidates stale cached images instead of serving them.
///  * In-memory PNG bytes make scroll-back / filter instant within a session.
///  * A best-effort on-disk cache (app support directory, web-guarded) lets
///    second and later launches skip GPU thumbnail rendering entirely.
///
/// This intentionally does NOT re-introduce bundled assets/catalog_thumbs/
/// PNGs (see assets/AGENTS.md); it is a runtime-produced cache, not bundled
/// artwork.
/// Thumbnail shapes that produce incompatible framing and cached pixels.
enum CatalogThumbnailLayout { square, gridPortrait, gridWide }

/// One cached file on disk, used for prune decisions.
class DiskEntry {
  final String path;
  final DateTime modified;

  const DiskEntry(this.path, this.modified);
}

class CatalogThumbnailCache {
  CatalogThumbnailCache._();

  /// Shared quality profile used by both the renderer and cache signature.
  /// These modest bounds preserve thumbnail detail without approaching the
  /// substantially heavier full-viewer settings.
  static const int targetWidth = 384;
  static const int maxIterations = kIsWeb ? 24 : 40;
  static const int maxColorCount = 24;

  /// Sparse point-orbit modules need a denser, curated thumbnail profile while
  /// the rest of the catalog retains the inexpensive shared cap.
  static int maxIterationsFor(String catalogId) =>
      catalogId == 'core.barnsley_fern' ? (kIsWeb ? 64 : 120) : maxIterations;

  static ({double centerX, double centerY, double zoom})? viewOverrideFor(
    String catalogId,
  ) =>
      catalogId == 'core.barnsley_fern'
          ? (centerX: 0.0, centerY: 0.5, zoom: 1.0)
          : null;

  /// Bump when thumbnail rendering changes (resolution, caps, palette logic)
  /// so existing on-disk artifacts are keyed apart instead of served stale.
  static const int _schemaVersion = 2;

  static const String _dirName = 'catalog_thumbs';

  /// Upper bound on cached PNG files kept on disk. The catalog has ~1000
  /// modules; only a render-signature change (schema bump) adds a second
  /// generation of files, and the oldest generation is pruned away here
  /// instead of accumulating forever.
  static const int _maxDiskEntries = 1200;

  /// Prune at most every N stores so the directory listing stays amortized.
  static const int _pruneInterval = 64;
  static int _storesSincePrune = 0;

  /// A viewport-and-scroll-buffer-sized working set avoids retaining PNGs for
  /// all ~1000 catalog entries in RAM; native evictions remain on disk.
  static const int _maxMemoryEntries = 256;

  /// signature -> PNG bytes, ordered least-recently-used to most-recently-used.
  static final LinkedHashMap<String, Uint8List> _memory =
      LinkedHashMap<String, Uint8List>();

  /// Disk is a production-only optimization. In automated tests the
  /// path_provider platform channel never answers, which would park pending
  /// futures forever; tests exercise the in-memory layer instead.
  static bool get _diskEnabled =>
      !kIsWeb && !RuntimeModeService.isAutomatedTest;

  /// Whether callers should wait briefly for a native warm-cache lookup before
  /// mounting a GPU renderer. Web and tests have no persistent cache layer.
  static bool get usesPersistentStorage => _diskEnabled;

  /// Deterministic key for a thumbnail's pixels. Must be identical at check
  /// time and store time for the same rendered entry.
  static String renderSignature({
    required String catalogId,
    required int maxIterations,
    required int maxColorCount,
    required int? paletteIndex,
    required int width,
    required int height,
    CatalogThumbnailLayout layout = CatalogThumbnailLayout.square,
  }) {
    final raw = <String>[
      catalogId,
      'schema=$_schemaVersion',
      'maxIter=$maxIterations',
      'maxColors=$maxColorCount',
      'palette=$paletteIndex',
      'size=$width|$height',
      'layout=${layout.name}',
    ].join('|');
    return '$catalogId-${_fnv1a(raw).toRadixString(36)}';
  }

  /// Signature for a module's thumbnail, mirroring the caps the runtime
  /// thumbnail controller applies (iterations, color count, palette). The
  /// controller setup in the catalog widgets and this helper MUST stay in
  /// sync: if one changes how a thumbnail is rendered, so must the other
  /// (or bump [_schemaVersion] to invalidate everything).
  static String renderSignatureForModule(
    String catalogId,
    FractalModule module, {
    int width = targetWidth,
    int height = targetWidth,
    CatalogThumbnailLayout layout = CatalogThumbnailLayout.square,
  }) {
    int? paletteIndex;
    for (final param in module.parameters) {
      if (param.id != 'colorScheme') continue;
      final min = param.min.ceil();
      final max = param.max.floor();
      final range = (max - min + 1).clamp(1, CommonFractalParams.paletteCount);
      paletteIndex = min + (_stableHash(catalogId) % range);
    }
    return renderSignature(
      catalogId: catalogId,
      maxIterations: maxIterationsFor(catalogId),
      maxColorCount: maxColorCount,
      paletteIndex: paletteIndex,
      width: width,
      height: height,
      layout: layout,
    );
  }

  static int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  static int _fnv1a(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  // ---------------------------------------------------------------------------
  // Memory
  // ---------------------------------------------------------------------------

  static Uint8List? inMemory(String signature) {
    final bytes = _memory.remove(signature);
    if (bytes == null || !_looksLikePng(bytes)) return null;
    _memory[signature] = bytes;
    return bytes;
  }

  // ---------------------------------------------------------------------------
  // Disk (web-guarded, best-effort)
  // ---------------------------------------------------------------------------

  static Future<Uint8List?> diskBytes(String signature) async {
    if (!_diskEnabled) return null;
    try {
      final file = await _fileFor(signature);
      if (file == null || !await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (_looksLikePng(bytes)) return bytes;
      await file.delete();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Best-effort: memory is authoritative; disk write is fire-and-forget.
  static Future<void> store(String signature, Uint8List png) async {
    _memory.remove(signature);
    _memory[signature] = png;
    while (_memory.length > _maxMemoryEntries) {
      _memory.remove(_memory.keys.first);
    }
    if (!_diskEnabled) return;
    try {
      final file = await _fileFor(signature);
      if (file != null) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png, flush: true);
      }
      _storesSincePrune++;
      if (_storesSincePrune >= _pruneInterval && file != null) {
        _storesSincePrune = 0;
        await _pruneDiskCache(file);
      }
    } catch (_) {
      // Disk is best-effort; in-memory still holds the entry.
    }
  }

  /// Removes a bad or obsolete entry from both cache layers.
  static Future<void> evict(String signature) async {
    _memory.remove(signature);
    if (!_diskEnabled) return;
    try {
      final file = await _fileFor(signature);
      if (file != null && await file.exists()) await file.delete();
    } catch (_) {
      // Eviction is best-effort; dropping memory still permits a rerender.
    }
  }

  /// Deletes the oldest cached files beyond [_maxDiskEntries]. The decision
  /// lives in [diskPruneVictims] so it is unit-testable without a real
  /// filesystem; this method only performs the best-effort I/O.
  static Future<void> _pruneDiskCache(File justStored) async {
    try {
      final dir = justStored.parent;
      final entries = <DiskEntry>[];
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final stat = await entity.stat();
        entries.add(DiskEntry(entity.path, stat.modified));
      }
      for (final victim in diskPruneVictims(entries)) {
        await File(victim.path).delete();
      }
    } catch (_) {
      // Pruning is best-effort; a failed prune only costs disk space.
    }
  }

  /// Chooses which cached files to delete so at most [_maxDiskEntries]
  /// remain: keeps the most recently modified entries and returns the
  /// oldest as victims. Ties break on path for determinism.
  static List<DiskEntry> diskPruneVictims(
    List<DiskEntry> entries, {
    int cap = _maxDiskEntries,
  }) {
    if (entries.length <= cap) return const [];
    final sorted = entries.toList()
      ..sort((a, b) {
        final byTime = a.modified.compareTo(b.modified);
        if (byTime != 0) return byTime;
        return a.path.compareTo(b.path);
      });
    return sorted.take(entries.length - cap).toList();
  }

  static Future<File?> _fileFor(String signature) async {
    if (!_diskEnabled) return null;
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dir = Directory('${supportDir.path}/$_dirName');
      return File('${dir.path}/$signature.png');
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ui.Image <-> PNG helpers
  // ---------------------------------------------------------------------------

  static bool _looksLikePng(Uint8List bytes) {
    if (bytes.length < 24) return false;
    const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return bytes[8] == 0 &&
        bytes[9] == 0 &&
        bytes[10] == 0 &&
        bytes[11] == 13 &&
        bytes[12] == 73 &&
        bytes[13] == 72 &&
        bytes[14] == 68 &&
        bytes[15] == 82;
  }

  static Future<Uint8List?> encodePng(ui.Image image) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  static Future<void> clearForTesting() async {
    _memory.clear();
    _storesSincePrune = 0;
  }
}
