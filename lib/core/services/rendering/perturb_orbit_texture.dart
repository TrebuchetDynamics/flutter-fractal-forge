import 'dart:typed_data';
import 'dart:ui' as ui;

/// Rasterizes encoded perturbation orbit bytes (RGBA, [totalPx] pixels) into
/// the `totalPx`×1 data texture the perturbation shader samples as `uOrbit`.
///
/// This is a DATA texture: every byte must survive rasterization exactly
/// (no anti-aliasing, blending, or color-space conversion), or the reference
/// orbit silently loses precision. The byte-exactness contract is locked by
/// `test/perturb_orbit_texture_test.dart` (software rasterizer) and
/// `integration_test/rendering/perturb_orbit_texture_gpu_test.dart` (real GPU).
///
/// One `drawVertices` call (two triangles per pixel, constant color per quad)
/// replaces the previous per-pixel `drawRect` loop, which issued up to 4,000
/// draw ops on the UI thread on every deep-zoom navigation step.
ui.Image rasterizePerturbOrbitBytes(Uint8List bytes, int totalPx) {
  final positions = _positionsFor(totalPx);
  final colors = _colorsBuffer(totalPx);
  for (int x = 0; x < totalPx; x++) {
    final i = x * 4;
    // ui.Vertices colors are ARGB32, matching Color.value encoding.
    final argb = (bytes[i + 3] << 24) |
        (bytes[i] << 16) |
        (bytes[i + 1] << 8) |
        bytes[i + 2];
    final v = x * 6;
    for (int k = 0; k < 6; k++) {
      colors[v + k] = argb;
    }
  }

  final vertices = ui.Vertices.raw(
    ui.VertexMode.triangles,
    positions,
    colors: colors,
  );

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, totalPx.toDouble(), 1),
  );
  // BlendMode.dst keeps the vertex colors untouched by the (shader-less)
  // paint; the default paint has anti-aliasing off.
  canvas.drawVertices(vertices, ui.BlendMode.dst, ui.Paint());
  final picture = recorder.endRecording();
  ui.Image image;
  try {
    image = picture.toImageSync(totalPx, 1);
  } finally {
    picture.dispose();
  }
  vertices.dispose();
  return image;
}

// Reusable geometry/color buffers: orbit textures are rebuilt every
// navigation step, and the width only changes when the iteration count does,
// so caching by size avoids ~240KB of allocations per frame.
Float32List _cachedPositions = Float32List(0);
Int32List _cachedColors = Int32List(0);

Float32List _positionsFor(int totalPx) {
  if (_cachedPositions.length == totalPx * 12) return _cachedPositions;
  final positions = Float32List(totalPx * 12);
  for (int x = 0; x < totalPx; x++) {
    final left = x.toDouble();
    final right = (x + 1).toDouble();
    final p = x * 12;
    // Two triangles covering the 1px-tall column [left, right) × [0, 1).
    positions[p] = left;
    positions[p + 1] = 0;
    positions[p + 2] = right;
    positions[p + 3] = 0;
    positions[p + 4] = left;
    positions[p + 5] = 1;
    positions[p + 6] = right;
    positions[p + 7] = 0;
    positions[p + 8] = right;
    positions[p + 9] = 1;
    positions[p + 10] = left;
    positions[p + 11] = 1;
  }
  _cachedPositions = positions;
  return positions;
}

Int32List _colorsBuffer(int totalPx) {
  if (_cachedColors.length != totalPx * 6) {
    _cachedColors = Int32List(totalPx * 6);
  }
  return _cachedColors;
}
