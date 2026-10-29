import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// A silent, bounded parameter loop. Manual edits always take ownership.
class BreathingController extends ChangeNotifier {
  BreathingController({required this.controller, required this.canAnimate}) {
    _moduleId = controller.module.id;
    controller.addListener(_onControllerChanged);
  }

  // These shaders repurpose fractional-step bailout as a discrete order.
  static const _discreteBailoutModules = {
    'mandelbrot_stripe_avg',
    'chebyshev',
    'legendre',
    'laguerre',
    'hermite',
  };

  // Whole-step float schemas also encode shader enums, masks and loop counts.
  static final _nonShapeControls = RegExp(
    r'iteration|step|sample|epsilon|tolerance|precision|detail|quality|resolution|camera|speed|time',
    caseSensitive: false,
  );

  final FractalController controller;
  final bool Function() canAnimate;
  late String _moduleId;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Map<String, Object> _expectedParams = const {};
  Map<String, double> _base = const {};
  bool _applying = false;

  bool get isPlaying => _timer != null;

  Iterable<FractalParameter> get _parameters =>
      controller.module.parameters.where(
        (parameter) =>
            parameter.type == FractalParamType.float &&
            parameter.min.isFinite &&
            parameter.max.isFinite &&
            parameter.max > parameter.min &&
            (parameter.max - parameter.min).isFinite &&
            parameter.step.isFinite &&
            parameter.step > 0 &&
            parameter.step < 1 &&
            !_nonShapeControls.hasMatch(parameter.id) &&
            !(parameter.id == 'bailout' &&
                _discreteBailoutModules.contains(controller.module.id)) &&
            controller.params[parameter.id] is num &&
            (controller.params[parameter.id] as num).isFinite,
      );

  bool get canPlay =>
      controller.module.id != 'number_wall' && _parameters.isNotEmpty;

  void play() {
    if (isPlaying || !canPlay || !canAnimate()) return;
    if (_base.isEmpty || !mapEquals(_expectedParams, controller.params)) {
      _base = {
        for (final parameter in _parameters)
          parameter.id: (controller.params[parameter.id] as num).toDouble(),
      };
      _elapsed = Duration.zero;
    }
    _expectedParams = Map.of(controller.params);
    final start = _elapsed;
    _timer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!canAnimate()) {
        pause();
        return;
      }
      _elapsed = start + Duration(milliseconds: timer.tick * 33);
      final phase = (_elapsed.inMicroseconds % 8000000) / 8000000 * 2 * math.pi;
      final next = Map<String, Object>.of(controller.params);
      for (final parameter in _parameters) {
        final base = _base[parameter.id]!;
        final amplitude = (parameter.max - parameter.min) * 0.04;
        final low = math.max(parameter.min, base - amplitude);
        final high = math.min(parameter.max, base + amplitude);
        final radius = (high - low) / 2;
        if (radius <= 0) continue;
        final center = low + radius;
        final initialPhase = math.asin(((base - center) / radius).clamp(-1, 1));
        next[parameter.id] = (center + radius * math.sin(initialPhase + phase))
            .clamp(parameter.min, parameter.max);
      }
      _expectedParams = next;
      _applying = true;
      try {
        unawaited(controller.loadState(
          params: next,
          view: controller.view,
          transparentBackground: controller.transparentBackground,
        ));
      } finally {
        _applying = false;
      }
    });
    notifyListeners();
  }

  void pause() {
    if (!isPlaying) return;
    _timer!.cancel();
    _timer = null;
    notifyListeners();
  }

  void _onControllerChanged() {
    if (_applying) return;
    if (_moduleId != controller.module.id ||
        !mapEquals(_expectedParams, controller.params)) {
      _moduleId = controller.module.id;
      _base = const {};
      _elapsed = Duration.zero;
      pause();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    _timer?.cancel();
    super.dispose();
  }
}
