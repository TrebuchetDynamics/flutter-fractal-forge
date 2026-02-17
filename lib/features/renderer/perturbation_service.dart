import 'dart:ui' as ui;

import 'perturbation_controller.dart';

class PerturbationService {
  List<(double, double)>? _orbit;
  ui.Image? _orbitTexture;

  double _lastCRefRe = double.nan;
  double _lastCRefIm = double.nan;
  int _lastMaxIter = 0;
  double _lastBailout = double.nan;

  ui.Image? get orbitTexture => _orbitTexture;
  bool get isReady => _orbitTexture != null;
  List<(double, double)>? get orbit => _orbit;

  bool update({
    required double cRefRe,
    required double cRefIm,
    required int maxIter,
    required double bailout,
  }) {
    final centerChanged =
        (cRefRe - _lastCRefRe).abs() > 1e-15 ||
        (cRefIm - _lastCRefIm).abs() > 1e-15;
    final iterChanged = (maxIter - _lastMaxIter).abs() > 10;
    final bailoutChanged = (bailout - _lastBailout).abs() > 1e-12;

    if (!centerChanged && !iterChanged && !bailoutChanged && _orbitTexture != null) {
      return false;
    }

    _lastCRefRe = cRefRe;
    _lastCRefIm = cRefIm;
    _lastMaxIter = maxIter;
    _lastBailout = bailout;

    final orbit = computeReferenceOrbit(
      cRefRe: cRefRe,
      cRefIm: cRefIm,
      maxIter: maxIter,
      bailout: bailout,
    );

    if (orbit == null || orbit.isEmpty) {
      return false;
    }

    _orbitTexture?.dispose();
    _orbitTexture = encodeOrbitTexture(orbit);
    _orbit = orbit;
    return true;
  }

  void dispose() {
    _orbitTexture?.dispose();
    _orbitTexture = null;
    _orbit = null;
  }
}
