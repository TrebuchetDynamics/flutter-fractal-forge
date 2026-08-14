import 'fourier_analysis_controller.dart';

/// Owns asynchronous Fourier backend activation across rapid mode changes.
///
/// A backend that finishes spawning after its activation was invalidated is
/// closed before it can be installed by the viewer.
final class FourierBackendLease {
  int _generation = 0;

  int begin() => ++_generation;

  void invalidate() {
    _generation++;
  }

  Future<FourierAnalysisBackend?> acquire({
    required int generation,
    required Future<FourierAnalysisBackend> Function() factory,
    required bool Function() isActive,
  }) async {
    final backend = await factory();
    if (generation != _generation || !isActive()) {
      await backend.close();
      return null;
    }
    return backend;
  }
}
