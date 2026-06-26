import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:flutter_fractals/core/services/rendering/palette_service.dart';

/// Formula IDs matching `uFormula` in escape_time_perturb_gpu.frag
const _kFormulaMandelbrot = 0;
// const _kFormulaJulia      = 1;  // handled by julia_perturb_module.dart
const _kFormulaBurningShip = 2;
const _kFormulaBuffalo = 3;
const _kFormulaTricorn = 4;
const _kFormulaCeltic = 5;
const _kFormulaMultibrot3 = 6;
const _kFormulaMultibrot4 = 7;
const _kFormulaMultibrot5 = 8;
const _kFormulaPhoenix = 9; // else-branch in shader (p = uExtra0)

/// Supported fractal IDs for generic escape-time perturbation.
const Set<String> kPerturbableEscapeTimeIds = {
  'burning_ship',
  'buffalo',
  'tricorn',
  'celtic',
  'phoenix',
  'multibrot3',
  'multibrot4',
  'multibrot5',
};

/// Maps a fractal module ID to its perturbation formula integer.
int formulaForId(String id) {
  switch (id) {
    case 'mandelbrot':
      return _kFormulaMandelbrot;
    case 'burning_ship':
      return _kFormulaBurningShip;
    case 'buffalo':
      return _kFormulaBuffalo;
    case 'tricorn':
      return _kFormulaTricorn;
    case 'celtic':
      return _kFormulaCeltic;
    case 'multibrot3':
      return _kFormulaMultibrot3;
    case 'multibrot4':
      return _kFormulaMultibrot4;
    case 'multibrot5':
      return _kFormulaMultibrot5;
    case 'phoenix':
      return _kFormulaPhoenix;
    default:
      return _kFormulaMandelbrot;
  }
}

/// Wraps any supported escape-time module with the perturbation-theory GPU
/// shader at deep zoom, extending usable zoom to ~1e30.
///
/// [standardModule] must have an id present in [kPerturbableEscapeTimeIds].
FractalModule buildEscapeTimePerturbModule(FractalModule standardModule) {
  final id = standardModule.id;
  final formula = formulaForId(id);

  // Inject the color-cycle-speed slider (G15) if not already present.
  final baseParams = standardModule.parameters;
  final hasCycleParam = baseParams.any((p) => p.id == 'colorCycleSpeed');
  final parameters = hasCycleParam
      ? baseParams
      : [...baseParams, CommonFractalParams.colorCycleSpeed()];

  return FractalModule(
    id: standardModule.id,
    displayName: standardModule.displayName,
    dimension: standardModule.dimension,
    shaderAsset: 'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
    parameters: parameters,
    defaultPreset: standardModule.defaultPreset,
    builtInPresets: standardModule.builtInPresets,
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 160)
          .clamp(4.0, 2000.0)
          .toInt();
      final bailout = readDouble(state.params, 'bailout', 4.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0.0).round();

      // Phoenix extra param: p (memory term)
      final phoenixP =
          id == 'phoenix' ? readDouble(state.params, 'phoenixP', 0.0) : 0.0;

      // G15 color cycling speed (cycles per second via uExtra1).
      final colorSpeed = readDouble(state.params, 'colorCycleSpeed', 0.0);

      ui.Image paletteTex;
      try {
        final palette = PaletteService.instance.paletteAtIndex(colorScheme);
        paletteTex = PaletteService.instance.paletteTexture(palette);
      } catch (_) {
        // PaletteService unavailable; use a 1×1 black fallback texture.
        final rec = ui.PictureRecorder();
        final canvas = ui.Canvas(rec);
        canvas.drawRect(
          const ui.Rect.fromLTWH(0, 0, 1, 1),
          ui.Paint()..color = const ui.Color(0xFF000000),
        );
        paletteTex = rec.endRecording().toImageSync(1, 1);
      }
      final orbitTex = _EscapeTimePerturbOrbitCache.instance.orbitTexture(
        moduleId: id,
        centerX: state.view.pan.x,
        centerY: state.view.pan.y,
        iterations: iterations,
        phoenixP: phoenixP,
      );

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations.toDouble());
      shader.setFloat(7, bailout);
      shader.setFloat(8, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(9, formula.toDouble());
      shader.setFloat(10, phoenixP); // uExtra0
      shader.setFloat(11, colorSpeed); // uExtra1 = color cycle speed (G15)
      shader.setFloat(12, 0.0); // uExtra2

      shader.setImageSampler(0, paletteTex);
      shader.setImageSampler(1, orbitTex);
    },
  );
}

/// Singleton LRU-1 cache for reference orbit textures.
///
/// Recomputes the orbit only when the fractal type, center, or iteration
/// count changes (i.e., on every significant navigation step).
class _EscapeTimePerturbOrbitCache {
  _EscapeTimePerturbOrbitCache._();
  static final _EscapeTimePerturbOrbitCache instance =
      _EscapeTimePerturbOrbitCache._();

  String _lastKey = '';
  ui.Image? _lastImage;

  ui.Image orbitTexture({
    required String moduleId,
    required double centerX,
    required double centerY,
    required int iterations,
    double phoenixP = 0.0,
  }) {
    final key =
        '$moduleId|${centerX.toStringAsFixed(12)}|${centerY.toStringAsFixed(12)}'
        '|$iterations|${phoenixP.toStringAsFixed(8)}';

    final cached = _lastImage;
    if (key == _lastKey && cached != null) {
      return cached;
    }

    final bytes = _computeOrbit(
      moduleId: moduleId,
      centerX: centerX,
      centerY: centerY,
      iterations: iterations,
      phoenixP: phoenixP,
    );

    final totalPx = iterations * 2;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, totalPx.toDouble(), 1),
    );
    final paint = ui.Paint();
    for (int x = 0; x < totalPx; x++) {
      final i = x * 4;
      paint.color = ui.Color.fromARGB(
        bytes[i + 3],
        bytes[i + 0],
        bytes[i + 1],
        bytes[i + 2],
      );
      canvas.drawRect(ui.Rect.fromLTWH(x.toDouble(), 0, 1, 1), paint);
    }
    final image = recorder.endRecording().toImageSync(totalPx, 1);
    _lastImage?.dispose();
    _lastImage = image;
    _lastKey = key;
    return image;
  }

  /// Compute the reference orbit (from the exact center point) for the
  /// requested fractal formula and encode each z component into RGB bytes.
  ///
  /// Layout: pixel[2n] = Re(Zn) encoded, pixel[2n+1] = Im(Zn) encoded.
  Uint8List _computeOrbit({
    required String moduleId,
    required double centerX,
    required double centerY,
    required int iterations,
    double phoenixP = 0.0,
  }) {
    final totalPx = iterations * 2;
    final bytes = Uint8List(totalPx * 4);

    double zr = 0.0;
    double zi = 0.0;
    double prevZr = 0.0;
    double prevZi = 0.0;

    for (int n = 0; n < iterations; n++) {
      // Store current Z before iterating
      _encodeToRgb(zr, bytes, n * 8);
      _encodeToRgb(zi, bytes, n * 8 + 4);

      // Compute Z(n+1) = f(Z(n), c)
      final nextZ = _iterate(
        moduleId: moduleId,
        zr: zr,
        zi: zi,
        prevZr: prevZr,
        prevZi: prevZi,
        cx: centerX,
        cy: centerY,
        phoenixP: phoenixP,
      );

      prevZr = zr;
      prevZi = zi;
      zr = nextZ.$1;
      zi = nextZ.$2;

      // Early exit if escaped (shouldn't happen at deep zoom center, but safe)
      if (zr * zr + zi * zi > 1e6) break;
    }

    return bytes;
  }

  /// One iteration of the escape-time formula at the reference center.
  (double, double) _iterate({
    required String moduleId,
    required double zr,
    required double zi,
    required double prevZr,
    required double prevZi,
    required double cx,
    required double cy,
    double phoenixP = 0.0,
  }) {
    switch (moduleId) {
      case 'burning_ship':
        // Z(n+1) = (|Re(z)| + i|Im(z)|)^2 + c
        final wr = zr.abs();
        final wi = zi.abs();
        return (wr * wr - wi * wi + cx, 2.0 * wr * wi + cy);

      case 'buffalo':
        // Z(n+1) = (|Re(z^2)|, |Im(z^2)|) + c
        final re2 = zr * zr - zi * zi;
        final im2 = 2.0 * zr * zi;
        return (re2.abs() + cx, im2.abs() + cy);

      case 'tricorn':
        // Z(n+1) = conj(z)^2 + c
        return (zr * zr - zi * zi + cx, -2.0 * zr * zi + cy);

      case 'celtic':
        // Z(n+1) = (|Re(z^2)|, Im(z^2)) + c
        final re2 = zr * zr - zi * zi;
        final im2 = 2.0 * zr * zi;
        return (re2.abs() + cx, im2 + cy);

      case 'multibrot3':
        // Z(n+1) = z^3 + c
        // Re: zr^3 - 3*zr*zi^2
        // Im: 3*zr^2*zi - zi^3
        final nr3 = zr * zr * zr - 3.0 * zr * zi * zi + cx;
        final ni3 = 3.0 * zr * zr * zi - zi * zi * zi + cy;
        return (nr3, ni3);

      case 'multibrot4':
        // Z(n+1) = z^4 + c
        final zr2 = zr * zr - zi * zi;
        final zi2 = 2.0 * zr * zi;
        final nr = zr2 * zr2 - zi2 * zi2 + cx;
        final ni = 2.0 * zr2 * zi2 + cy;
        return (nr, ni);

      case 'multibrot5':
        // Z(n+1) = z^5 + c
        final zr2 = zr * zr;
        final zi2 = zi * zi;
        final nr = zr * (zr2 * zr2 - 10.0 * zr2 * zi2 + 5.0 * zi2 * zi2) + cx;
        final ni = zi * (5.0 * zr2 * zr2 - 10.0 * zr2 * zi2 + zi2 * zi2) + cy;
        return (nr, ni);

      case 'phoenix':
        // Z(n+1) = z^2 + c + p * z_prev
        final nr = zr * zr - zi * zi + cx + phoenixP * prevZr;
        final ni = 2.0 * zr * zi + cy + phoenixP * prevZi;
        return (nr, ni);

      default:
        // Fallback: standard Mandelbrot
        return (zr * zr - zi * zi + cx, 2.0 * zr * zi + cy);
    }
  }

  /// Encode a double value in [-4, 4) into three uint8 channels (RGB).
  void _encodeToRgb(double value, Uint8List out, int offset) {
    final (high, mid, low) = packPerturbOrbitComponent(value);
    out[offset + 0] = high;
    out[offset + 1] = mid;
    out[offset + 2] = low;
    out[offset + 3] = 255;
  }
}

/// Packs an orbit component in `[-4, 4)` into the `(high, mid, low)` RGB bytes
/// the perturbation shader reads back.
///
/// The shader (escape_time_perturb_gpu.frag) decodes the three channels —
/// sampled as `r, g, b` in `[0, 1]` (= byte / 255) — as:
///   value = (r + g/256 + b/65536) * 8 - 4
/// i.e. `r` is the coarse value and `g`, `b` refine it by successive `1/256`
/// steps. This is a 24-bit fixed point over the [-4, 4) range (~7.2 decimal
/// digits, resolution ~5e-7).
///
/// Alpha is deliberately left at 255: the orbit image is built with
/// `toImageSync`, which premultiplies, so orbit data in the alpha channel would
/// scale RGB. The packing MUST match the decode — see the round-trip
/// characterization test.
///
/// History: an earlier 16-bit integer packing (`scaled >> 8 / scaled & 0xFF`)
/// did not match the `r + g/256` decode and degraded the reference orbit to ~8
/// effective bits; this 3-channel fixed point fixes that and adds a byte of
/// precision (the B channel was previously unused).
(int high, int mid, int low) packPerturbOrbitComponent(double value) {
  final clamped = value.clamp(-4.0, 3.999999).toDouble();
  final normalized = ((clamped + 4.0) / 8.0).clamp(0.0, 1.0);
  final s0 = normalized * 255.0; // value in coarse-channel (high-byte) units
  var high = s0.floor();
  final s1 = (s0 - high) * 256.0;
  var mid = s1.floor();
  var low = ((s1 - mid) * 256.0).round();
  // Propagate rounding carries upward.
  if (low > 255) {
    low -= 256;
    mid += 1;
  }
  if (mid > 255) {
    mid -= 256;
    high += 1;
  }
  high = high.clamp(0, 255).toInt();
  mid = mid.clamp(0, 255).toInt();
  low = low.clamp(0, 255).toInt();
  return (high, mid, low);
}

/// Inverse of [packPerturbOrbitComponent], mirroring the shader decode exactly
/// (`r, g, b` are the sampled channels in `[0, 1]`). Exposed so the round-trip
/// contract can be tested against the GPU's formula without a GPU.
double decodePerturbOrbitComponent(int high, int mid, int low) {
  final r = high / 255.0;
  final g = mid / 255.0;
  final b = low / 255.0;
  return r * 8.0 - 4.0 + g / 256.0 * 8.0 + b / 65536.0 * 8.0;
}
