import 'dart:async';

/// Cancelable debounce contract for catalog search input.
///
/// A search edit should publish only after [delay] has elapsed without a newer
/// edit. Keeping this behavior behind a small helper makes the timing contract
/// testable instead of relying on stacked [Future.delayed] callbacks.
final class CatalogSearchDebouncer {
  final Duration delay;
  Timer? _timer;

  CatalogSearchDebouncer({
    this.delay = const Duration(milliseconds: 300),
  });

  void schedule(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
