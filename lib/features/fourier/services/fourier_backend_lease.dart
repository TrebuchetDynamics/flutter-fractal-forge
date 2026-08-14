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
    late final FourierAnalysisBackend backend;
    try {
      backend = await factory();
    } catch (error, stackTrace) {
      // An obsolete activation is allowed to finish failing, but it must not
      // tear down a newer on→off→on session through the viewer's catch path.
      if (generation != _generation || !isActive()) return null;
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (generation == _generation && isActive()) return backend;
    await backend.close();
    return null;
  }
}
