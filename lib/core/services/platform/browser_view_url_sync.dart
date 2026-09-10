import 'dart:async';

import 'package:flutter/services.dart';

/// Keeps the current history entry shareable without recording every gesture.
/// The viewer owns this object; native viewers do not create one.
class BrowserViewUrlSync {
  BrowserViewUrlSync({required this.readUri});

  final Uri Function() readUri;
  Timer? _timer;
  Uri? _lastUri;
  bool _disposed = false;

  void schedule() {
    if (_disposed) return;
    // Throttle rather than debounce so continuously animated parameters still
    // reach the address bar. Two writes/second also avoids History API limits.
    _timer ??= Timer(const Duration(milliseconds: 500), () {
      _timer = null;
      final state = readUri();
      final uri = Uri(path: '/', query: state.query);
      if (uri == _lastUri) return;
      _lastUri = uri;
      unawaited(
          SystemNavigator.routeInformationUpdated(uri: uri, replace: true));
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    unawaited(SystemNavigator.routeInformationUpdated(
      uri: Uri(path: '/'),
      replace: true,
    ));
  }
}
