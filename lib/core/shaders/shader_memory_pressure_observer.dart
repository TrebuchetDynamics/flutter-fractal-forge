import 'package:flutter/widgets.dart';

/// Bridges Flutter/Android low-memory notifications to shader cache recovery.
class ShaderMemoryPressureObserver extends StatefulWidget {
  const ShaderMemoryPressureObserver({
    super.key,
    required this.onMemoryPressure,
    required this.child,
  });

  final VoidCallback onMemoryPressure;
  final Widget child;

  @override
  State<ShaderMemoryPressureObserver> createState() =>
      _ShaderMemoryPressureObserverState();
}

class _ShaderMemoryPressureObserverState
    extends State<ShaderMemoryPressureObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didHaveMemoryPressure() {
    widget.onMemoryPressure();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
