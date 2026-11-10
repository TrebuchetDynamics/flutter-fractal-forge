import 'dart:async';

import 'package:flutter/widgets.dart';

import '../diagnostics/app_logger_service.dart';
import 'rust_engine_adapter.dart';

/// One default-off, inert probe per Flutter owner; never mirrors viewer state.
class RustEngineProbe extends StatefulWidget {
  const RustEngineProbe({super.key, required this.child});
  final Widget child;

  @override
  State<RustEngineProbe> createState() => _RustEngineProbeState();
}

class _RustEngineProbeState extends State<RustEngineProbe> {
  RustEngineAdapter? _engine;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final engine = await RustEngineAdapter.create();
    if (engine == null) return;
    if (!mounted) {
      engine.shutdown();
      return;
    }
    _engine = engine;
    final snapshot = engine.snapshot();
    AppLogger.instance.info('engine', 'Rust engine snapshot probe', data: {
      'version': engine.version,
      'sessionId': snapshot.sessionId.toString(),
      'revision': snapshot.revision.toString(),
    });
  }

  @override
  void dispose() {
    _engine?.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
