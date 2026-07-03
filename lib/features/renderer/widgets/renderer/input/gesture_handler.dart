part of '../fractal_renderer.dart';

/// Mixin that handles all gesture input for the fractal renderer.
///
/// Provides pan, zoom, rotate, double-tap, two-finger-tap, fling, and
/// context-menu gestures. Apply alongside `TickerProviderStateMixin`.
mixin _GestureHandlerMixin on State<FractalRenderer> {
  // Gesture tuning constants
  static const double _kMinZoom = RendererGestureViewBounds.minZoom;
  static const double _kMaxZoom = RendererGestureViewBounds.maxZoom;
  static const double _kPanMin = RendererGestureViewBounds.minPan;
  static const double _kPanMax = RendererGestureViewBounds.maxPan;
  static const double _kRubberBandStrength =
      RendererGestureViewBounds.defaultRubberBandStrength;
  static const double _kTiltMaxRadians = 67.5 * math.pi / 180.0;
  // Raised from 0.06 → 0.12 rad: fingers are never perfectly parallel during
  // pinch, so the old threshold triggered accidental rotation too easily.
  static const double _kIntentionalRotationThreshold = 0.12;
  static const int _kRawDoubleTapMaxGapMs = 280;
  static const double _kRawDoubleTapMaxDistancePx = 28.0;

  // Momentum controllers for smooth deceleration
  late AnimationController _zoomMomentumController;
  late AnimationController _panMomentumController;
  double _zoomVelocity = 0.0;
  Offset _panVelocity = Offset.zero;
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  // Gesture anchors so interactions feel 1:1 with fingers.
  double _startZoom = 1.0;
  Vector2 _startPan = Vector2.zero();
  Offset _startFocalPoint = Offset.zero;
  double _startRotationZ = 0.0;
  double _startTiltX = 0.0;

  // Raw pointer tracking for two-finger-tap and wheel gestures.
  final Map<int, Offset> _activePointers = <int, Offset>{};
  final Map<int, Offset> _twoFingerTapDownPositions = <int, Offset>{};
  DateTime? _twoFingerTapStartedAt;
  bool _twoFingerTapCandidate = false;
  bool _isTilting = false;
  bool _rotationGestureActive = false;
  Offset? _doubleTapDownLocal;
  DateTime? _lastRawTapAt;
  Offset? _lastRawTapPos;
  DateTime? _lastDoubleTapTriggeredAt;
  bool _deferUserInteractionEndToAnimation = false;
  Offset _fluidPointerLocal = Offset.zero;
  bool _fluidPointerActive = false;

  // Velocity history for Google Maps-style fling
  static const int _velHistorySize = 5;
  final List<({Offset pos, int ms})> _velHistory = [];

  AnimationController? _zoomAnimation;

  void _stopGestureAnimations() {
    _zoomMomentumController.stop();
    _panMomentumController.stop();
    _zoomAnimation?.stop();
    _zoomVelocity = 0.0;
    _panVelocity = Offset.zero;
    _deferUserInteractionEndToAnimation = false;
  }

  @override
  void initState() {
    super.initState();

    // Momentum controllers for smooth deceleration.
    // Cast to TickerProvider — the using class always mixes in
    // TickerProviderStateMixin, but we can't express that in the on-clause
    // without triggering a conflicting-generic-interfaces error.
    final vsync = this as TickerProvider;
    _zoomMomentumController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    )..addListener(_applyZoomMomentum);

    _panMomentumController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    )..addListener(_applyPanMomentum);
  }

  @override
  void dispose() {
    _zoomMomentumController.removeListener(_applyZoomMomentum);
    _panMomentumController.removeListener(_applyPanMomentum);

    _zoomMomentumController.dispose();
    _panMomentumController.dispose();
    _zoomAnimation?.dispose();

    super.dispose();
  }

  void _applyZoomMomentum() {
    if (!mounted) return;
    if (!_zoomMomentumController.isAnimating) return;

    final controller = context.read<FractalController>();
    final view = controller.view;

    // Google Maps spec: zoom friction 0.92 per frame
    _zoomVelocity = _zoomVelocity * 0.92;

    // Stop threshold: 0.0001 zoom levels/ms
    if (_zoomVelocity.abs() < 0.0001) {
      _zoomMomentumController.stop();
      _zoomVelocity = 0.0;
      return;
    }

    // Apply zoom velocity (in zoom levels)
    final proposedZoom = view.zoom * math.pow(2, _zoomVelocity * 0.016);
    final boundedZoom =
        _rubberBand(proposedZoom.toDouble(), _kMinZoom, _kMaxZoom);
    final hitZoomBoundary =
        boundedZoom <= _kMinZoom || boundedZoom >= _kMaxZoom;
    if (hitZoomBoundary) {
      _zoomVelocity *= 0.5;
    }
    controller.updateView(
      view.copyWith(zoom: boundedZoom),
      adaptIterationsForZoom: true,
    );
  }

  void _applyPanMomentum() {
    if (!mounted) return;
    if (!_panMomentumController.isAnimating) return;

    final controller = context.read<FractalController>();
    final view = controller.view;
    final module = controller.module;

    // Google Maps spec: friction 0.95 per frame at 60fps
    _panVelocity = _panVelocity * 0.95;

    // Stop threshold: 0.1 px/frame
    if (_panVelocity.distance < 0.1) {
      _panMomentumController.stop();
      _panVelocity = Offset.zero;
      return;
    }

    if (module.dimension == FractalDimension.threeD) {
      controller.updateView(
        view.copyWith(
          rotation: _bounded3DRotation(
            view.rotation +
                Vector3(_panVelocity.dy * 0.0008, _panVelocity.dx * 0.0008, 0),
          ),
        ),
      );
    } else {
      // Map pixel velocity to world coordinates through the SAME transform the
      // interactive drag uses (_screenDeltaToWorldDelta), so fling momentum
      // continues in the direction the finger released.
      final renderBox = context.findRenderObject() as RenderBox?;
      final size = renderBox?.size;
      final scalePx = (size == null)
          ? 1.0
          : math.max(1.0, math.min(size.width, size.height));
      final worldDelta = _screenDeltaToWorldDelta(
        deltaPx: _panVelocity,
        scalePx: scalePx,
        rotationZ: _screenMappingRotationZFor2d(view.rotation.z),
        zoom: view.zoom,
      );
      final nextPan = Vector2(
        view.pan.x - worldDelta.x,
        view.pan.y - worldDelta.y,
      );
      final boundedPan = Vector2(
        _rubberBand(nextPan.x, _kPanMin, _kPanMax),
        _rubberBand(nextPan.y, _kPanMin, _kPanMax),
      );
      if (boundedPan.x != nextPan.x || boundedPan.y != nextPan.y) {
        _panVelocity *= 0.5;
      }
      controller.updateView(view.copyWith(pan: boundedPan));
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.onUserInteractionStart != null) {
      widget.onUserInteractionStart!.call();
    } else {
      widget.onUserInteraction?.call();
    }

    _zoomMomentumController.stop();
    _panMomentumController.stop();

    _lastScale = 1.0;
    _lastRotation = 0.0;

    _zoomVelocity = 0.0;
    _panVelocity = Offset.zero;
    _velHistory.clear();

    final controller = context.read<FractalController>();
    final renderBox = context.findRenderObject() as RenderBox?;
    final localFocal = (renderBox != null)
        ? renderBox.globalToLocal(details.focalPoint)
        : details.focalPoint;

    _startZoom = controller.view.zoom;
    _startPan = controller.view.pan;
    _startFocalPoint = localFocal;
    _startRotationZ = controller.view.rotation.z;
    _startTiltX = controller.view.rotation.x;
    _isTilting = false;
    _rotationGestureActive = false;
    _deferUserInteractionEndToAnimation = false;

    if (details.pointerCount == 1) {
      AppLogger.instance.debug('gesture', 'pan_start', data: {
        'x': localFocal.dx.toStringAsFixed(1),
        'y': localFocal.dy.toStringAsFixed(1),
      });
    } else {
      AppLogger.instance.debug('gesture', 'zoom_start', data: {
        'scale': _startZoom.toStringAsExponential(3),
        'pointers': details.pointerCount,
      });
    }
  }

  double _rubberBand(double value, double min, double max,
      {double strength = _kRubberBandStrength}) {
    return RendererGestureViewBounds.rubberBand(
      value,
      min,
      max,
      strength: strength,
    );
  }

  Offset _normalizedPoint(Offset p, Size size, double scalePx) {
    return (p - Offset(size.width / 2, size.height / 2)) / scalePx;
  }

  Vector2 _rotateInv2d(Offset value, double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector2(
      value.dx * cosA + value.dy * sinA,
      -value.dx * sinA + value.dy * cosA,
    );
  }

  Vector3 _bounded3DRotation(Vector3 rotation) {
    return Vector3(
      rotation.x.clamp(-_kTiltMaxRadians, _kTiltMaxRadians).toDouble(),
      rotation.y,
      rotation.z,
    );
  }

  double _screenMappingRotationZFor2d(double _) {
    // 2D FragmentShaders currently sample FlutterFragCoord directly; view.rotZ
    // is stored for deep links/UI, but it does not rotate the rendered image.
    // Keep pan math aligned with what users see on screen.
    return 0.0;
  }

  Vector2 _screenDeltaToWorldDelta({
    required Offset deltaPx,
    required double scalePx,
    required double rotationZ,
    required double zoom,
  }) {
    final rawDx = deltaPx.dx / scalePx;
    final rawDy = deltaPx.dy / scalePx;
    final cosR = math.cos(rotationZ);
    final sinR = math.sin(rotationZ);
    final safeZoom = math.max(1e-9, zoom);
    return Vector2(
      (rawDx * cosR + rawDy * sinR) / safeZoom,
      (-rawDx * sinR + rawDy * cosR) / safeZoom,
    );
  }

  void _applyZoomAroundFocal({
    required FractalController controller,
    required double targetZoom,
    required Offset focalPoint,
    double? explicitRotationZ,
  }) {
    final view = controller.view;
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    final zoom = _rubberBand(targetZoom, _kMinZoom, _kMaxZoom);

    var nextPan = view.pan;
    if (size != null) {
      final scalePx = math.max(1.0, math.min(size.width, size.height));
      final n = _normalizedPoint(focalPoint, size, scalePx);
      final rawRotationZ = explicitRotationZ ?? view.rotation.z;
      final rotationZ = controller.module.dimension == FractalDimension.threeD
          ? rawRotationZ
          : _screenMappingRotationZFor2d(rawRotationZ);
      final oldWorldDelta = _rotateInv2d(n, rotationZ) / view.zoom;
      final newWorldDelta = _rotateInv2d(n, rotationZ) / zoom;
      final worldX = view.pan.x + oldWorldDelta.x;
      final worldY = view.pan.y + oldWorldDelta.y;
      nextPan = Vector2(
        _rubberBand(worldX - newWorldDelta.x, _kPanMin, _kPanMax),
        _rubberBand(worldY - newWorldDelta.y, _kPanMin, _kPanMax),
      );
    }

    controller.updateView(
      view.copyWith(pan: nextPan, zoom: zoom),
      adaptIterationsForZoom: true,
    );
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final controller = context.read<FractalController>();
    final view = controller.view;
    final module = controller.module;
    final rotationLocked = controller.rotationLocked;

    // Try to map screen pixels to fractal "world" units based on the shader's
    // coordinate transform:
    //   uv = (frag - 0.5*res)/scale
    //   c  = uv/zoom + center
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    final scalePx =
        (size == null) ? 1.0 : math.max(1.0, math.min(size.width, size.height));
    final localFocal = (renderBox != null)
        ? renderBox.globalToLocal(details.focalPoint)
        : details.focalPoint;

    // --- 1 finger: pan (2D) or rotate (3D) ---
    if (details.pointerCount == 1) {
      if (module.dimension == FractalDimension.threeD) {
        if (!rotationLocked) {
          // Use incremental deltas to avoid jumps when pointer count changes.
          final d = details.focalPointDelta;
          controller.updateView(
            view.copyWith(
              rotation: _bounded3DRotation(
                view.rotation + Vector3(d.dy * 0.0009, d.dx * 0.0009, 0),
              ),
            ),
          );
        }
      } else {
        // Use incremental deltas to avoid large jumps after pinch→pan handoff.
        final worldDelta = _screenDeltaToWorldDelta(
          deltaPx: details.focalPointDelta,
          scalePx: scalePx,
          rotationZ: _screenMappingRotationZFor2d(view.rotation.z),
          zoom: view.zoom,
        );
        controller.updateView(
          view.copyWith(
            pan: Vector2(
              _rubberBand(view.pan.x - worldDelta.x, _kPanMin, _kPanMax),
              _rubberBand(view.pan.y - worldDelta.y, _kPanMin, _kPanMax),
            ),
          ),
        );
      }

      // Track velocity history for Google Maps fling.
      final now = DateTime.now().millisecondsSinceEpoch;
      _velHistory.add((pos: localFocal, ms: now));
      if (_velHistory.length > _velHistorySize) _velHistory.removeAt(0);

      return;
    }

    // --- 2+ fingers: pinch zoom + rotate + tilt ---
    final newZoom =
        _rubberBand(_startZoom * details.scale, _kMinZoom, _kMaxZoom);

    var nextPan = view.pan;
    var nextRotation = view.rotation;

    if (size != null && details.pointerCount >= 2) {
      final verticalDelta = localFocal.dy - _startFocalPoint.dy;
      final horizontalDelta = localFocal.dx - _startFocalPoint.dx;
      final rotationDeltaFromStart = details.rotation;
      final isVerticalSwipe =
          verticalDelta.abs() > (horizontalDelta.abs() * 1.25);
      final isStablePinch = (details.scale - 1.0).abs() < 0.08;
      final isStableRotate = rotationDeltaFromStart.abs() < 0.08;

      if (!_isTilting && isVerticalSwipe && isStablePinch && isStableRotate) {
        _isTilting = true;
      }

      if (_isTilting) {
        final tilt =
            (_startTiltX + (verticalDelta * 0.01)).clamp(0.0, _kTiltMaxRadians);
        nextRotation = Vector3(tilt, nextRotation.y, nextRotation.z);
      }
    }

    if (!rotationLocked &&
        !_rotationGestureActive &&
        details.rotation.abs() > _kIntentionalRotationThreshold) {
      _rotationGestureActive = true;
    }
    final effectiveRotationDelta =
        (!rotationLocked && _rotationGestureActive) ? details.rotation : 0.0;
    final newRotationZ = _startRotationZ + effectiveRotationDelta;

    if (size != null && module.dimension != FractalDimension.threeD) {
      // Keep the world point under the midpoint fixed while zooming/rotating.
      final startN = _normalizedPoint(_startFocalPoint, size, scalePx);
      final curN = _normalizedPoint(localFocal, size, scalePx);

      final startRotationZ = _screenMappingRotationZFor2d(_startRotationZ);
      final currentRotationZ = _screenMappingRotationZFor2d(newRotationZ);
      final worldAtStart =
          _rotateInv2d(startN, startRotationZ) / _startZoom + _startPan;
      final newCenter =
          worldAtStart - (_rotateInv2d(curN, currentRotationZ) / newZoom);

      nextPan = Vector2(
        _rubberBand(newCenter.x, _kPanMin, _kPanMax),
        _rubberBand(newCenter.y, _kPanMin, _kPanMax),
      );
      nextRotation = Vector3(nextRotation.x, nextRotation.y, newRotationZ);
    } else if (!rotationLocked &&
        module.dimension == FractalDimension.threeD &&
        details.rotation != 0.0) {
      final rotationDelta = details.rotation - _lastRotation;
      nextRotation = nextRotation + Vector3(0, 0, rotationDelta);
      _lastRotation = details.rotation;
    }

    controller.updateView(
      view.copyWith(pan: nextPan, zoom: newZoom, rotation: nextRotation),
      adaptIterationsForZoom: true,
    );

    // Track zoom velocity in zoom levels per ms (logarithmic)
    final scaleChange = details.scale / _lastScale;
    if (scaleChange > 0) {
      final zoomLevelChange = math.log(scaleChange) / math.ln2; // log2(scale)
      _zoomVelocity = zoomLevelChange / 16; // per frame, convert to per-ms
    }
    _lastScale = details.scale;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_deferUserInteractionEndToAnimation) {
      if (widget.onUserInteractionEnd != null) {
        widget.onUserInteractionEnd!.call();
      } else {
        widget.onUserInteraction?.call();
      }
    }

    if (_isTilting) {
      _isTilting = false;
      _velHistory.clear();
      _zoomVelocity = 0.0;
      return;
    }

    final controller = context.read<FractalController>();
    if (_activePointers.isEmpty || _activePointers.length == 1) {
      // Pan end: log final position and delta from start
      final endFocal =
          _velHistory.isNotEmpty ? _velHistory.last.pos : _startFocalPoint;
      final dx = endFocal.dx - _startFocalPoint.dx;
      final dy = endFocal.dy - _startFocalPoint.dy;
      AppLogger.instance.debug('gesture', 'pan_end', data: {
        'x': endFocal.dx.toStringAsFixed(1),
        'y': endFocal.dy.toStringAsFixed(1),
        'dx': dx.toStringAsFixed(1),
        'dy': dy.toStringAsFixed(1),
      });
    } else {
      // Zoom end: log final scale and zoom level
      AppLogger.instance.debug('gesture', 'zoom_end', data: {
        'zoom': controller.view.zoom.toStringAsExponential(3),
        'scale': _lastScale.toStringAsFixed(3),
      });
    }

    // Google Maps fling: compute velocity from history buffer
    // Spec: fling threshold = 0.3 px/ms = ~5 px/frame at 60fps
    if (_velHistory.length >= 2) {
      final newest = _velHistory.last;
      final oldest = _velHistory.first;
      final dt = (newest.ms - oldest.ms).toDouble();
      if (dt > 0) {
        final vx = (newest.pos.dx - oldest.pos.dx) / dt * 16; // px/frame
        final vy = (newest.pos.dy - oldest.pos.dy) / dt * 16;
        _panVelocity = Offset(vx, vy);
        // Only fling if fast enough: 5 px/frame (equiv to 0.3 px/ms)
        if (_panVelocity.distance > 5.0) {
          _panMomentumController.duration = const Duration(seconds: 2);
          _panMomentumController.forward(from: 0);
        }
      }
    }
    _velHistory.clear();

    // Zoom momentum - spec threshold 0.01 zoom levels/ms
    if (_zoomVelocity.abs() > 0.01) {
      _zoomMomentumController.duration = const Duration(seconds: 2);
      _zoomMomentumController.forward(from: 0);
    }
  }

  void _onDoubleTap([Offset? tapPosition]) {
    // Stop any momentum so it doesn't fight the animation.
    _zoomMomentumController.stop();
    _panMomentumController.stop();

    final controller = context.read<FractalController>();
    final view = controller.view;
    final currentZoom = view.zoom;
    final targetZoom = (currentZoom * 2.0).clamp(_kMinZoom, _kMaxZoom);

    // Compute target pan once so the tapped world-point stays fixed on screen.
    // world_point = pan + rotated(n) / zoom  (must be equal before and after)
    // => targetPan = pan + rotated(n) * (1/currentZoom - 1/targetZoom)
    Vector2 targetPan = view.pan;
    if (tapPosition != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      final size = renderBox?.size;
      if (size != null) {
        final scalePx = math.max(1.0, math.min(size.width, size.height));
        final n = _normalizedPoint(tapPosition, size, scalePx);
        final rotationZ = controller.module.dimension == FractalDimension.threeD
            ? view.rotation.z
            : _screenMappingRotationZFor2d(view.rotation.z);
        final rotated = _rotateInv2d(n, rotationZ);
        targetPan = Vector2(
          _rubberBand(
              view.pan.x + rotated.x / currentZoom - rotated.x / targetZoom,
              _kPanMin,
              _kPanMax),
          _rubberBand(
              view.pan.y + rotated.y / currentZoom - rotated.y / targetZoom,
              _kPanMin,
              _kPanMax),
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
          '[gesture] double_tap trigger tap=$tapPosition zoom=$currentZoom'
          ' target=$targetZoom targetPan=$targetPan');
    }

    AppLogger.instance.debug('gesture', 'double_tap', data: {
      if (tapPosition != null) 'x': tapPosition.dx.toStringAsFixed(1),
      if (tapPosition != null) 'y': tapPosition.dy.toStringAsFixed(1),
      'zoom': currentZoom.toStringAsExponential(3),
    });

    _deferUserInteractionEndToAnimation = true;
    if (widget.onUserInteractionStart != null) {
      widget.onUserInteractionStart!.call();
    } else {
      widget.onUserInteraction?.call();
    }
    _animatePanZoomTo(
      startPan: view.pan,
      targetPan: targetPan,
      fromZoom: currentZoom,
      toZoom: targetZoom,
      onCompleted: () {
        // A later continuous gesture (which clears this flag in _onScaleStart)
        // or a newer deferred animation now owns the interaction end. Suppress
        // this stale completion so auto-explore doesn't resume mid-gesture and
        // fight the user's drag/pinch.
        if (!_deferUserInteractionEndToAnimation) return;
        _deferUserInteractionEndToAnimation = false;
        if (widget.onUserInteractionEnd != null) {
          widget.onUserInteractionEnd!.call();
        } else {
          widget.onUserInteraction?.call();
        }
      },
    );
    HapticFeedback.mediumImpact();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    _doubleTapDownLocal = (renderBox != null)
        ? renderBox.globalToLocal(details.globalPosition)
        : details.localPosition;
  }

  void _triggerDoubleTapAt(Offset? localPosition) {
    final now = DateTime.now();
    final last = _lastDoubleTapTriggeredAt;
    if (last != null && now.difference(last).inMilliseconds < 120) {
      return;
    }
    _lastDoubleTapTriggeredAt = now;
    _onDoubleTap(localPosition);
  }

  void _onDoubleTapGesture() {
    if (kDebugMode) {
      debugPrint('[gesture] detector_double_tap local=$_doubleTapDownLocal');
    }
    _triggerDoubleTapAt(_doubleTapDownLocal);
    _doubleTapDownLocal = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    _fluidPointerLocal = event.localPosition;
    _fluidPointerActive = true;

    if (_activePointers.length > 1) {
      _lastRawTapAt = null;
      _lastRawTapPos = null;
    }

    if (_activePointers.length == 2) {
      _twoFingerTapCandidate = true;
      _twoFingerTapStartedAt = DateTime.now();
      _twoFingerTapDownPositions
        ..clear()
        ..addAll(_activePointers);
    } else if (_activePointers.length > 2) {
      _twoFingerTapCandidate = false;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    _fluidPointerLocal = event.localPosition;
    _fluidPointerActive = true;
    if (!_twoFingerTapCandidate) return;

    final origin = _twoFingerTapDownPositions[event.pointer];
    if (origin != null && (event.localPosition - origin).distance > 18.0) {
      _twoFingerTapCandidate = false;
    }
  }

  void _onPointerUp(PointerEvent event) {
    _fluidPointerLocal = event.localPosition;
    _fluidPointerActive = _activePointers.length > 1;
    // Check two-finger tap FIRST (before removing pointer)
    // This prevents single-finger logic from running when second finger lifts
    final twoFingerTap = RendererTwoFingerTapDecision.evaluate(
      isPointerUp: event is PointerUpEvent,
      candidate: _twoFingerTapCandidate,
      activePointerCount: _activePointers.length,
      elapsed: _twoFingerTapStartedAt == null
          ? null
          : DateTime.now().difference(_twoFingerTapStartedAt!),
      activePositions: _activePointers.values,
    );
    final midpoint = twoFingerTap.midpoint;
    if (midpoint != null) {
      final controller = context.read<FractalController>();
      final zoom = controller.view.zoom;
      _deferUserInteractionEndToAnimation = true;
      if (widget.onUserInteractionStart != null) {
        widget.onUserInteractionStart!.call();
      } else {
        widget.onUserInteraction?.call();
      }
      _animateZoomTo(
        zoom,
        (zoom * 0.5).clamp(_kMinZoom, _kMaxZoom),
        focalPoint: midpoint,
        onCompleted: () {
          // See _triggerDoubleTapAt: ignore a stale deferred end once a later
          // gesture or animation has taken ownership, so auto-explore never
          // resumes in the middle of an ongoing gesture.
          if (!_deferUserInteractionEndToAnimation) return;
          _deferUserInteractionEndToAnimation = false;
          if (widget.onUserInteractionEnd != null) {
            widget.onUserInteractionEnd!.call();
          } else {
            widget.onUserInteraction?.call();
          }
        },
      );
      HapticFeedback.lightImpact();
    }

    // Check single-finger double-tap (only when 1 finger remains)
    if (_activePointers.length == 1 && event is PointerUpEvent) {
      final now = DateTime.now();
      final prevAt = _lastRawTapAt;
      final prevPos = _lastRawTapPos;

      if (prevAt != null && prevPos != null) {
        final dtMs = now.difference(prevAt).inMilliseconds;
        final distPx = (event.localPosition - prevPos).distance;
        if (dtMs <= _kRawDoubleTapMaxGapMs &&
            distPx <= _kRawDoubleTapMaxDistancePx) {
          _triggerDoubleTapAt(event.localPosition);
          _lastRawTapAt = null;
          _lastRawTapPos = null;
        } else {
          _lastRawTapAt = now;
          _lastRawTapPos = event.localPosition;
        }
      } else {
        _lastRawTapAt = now;
        _lastRawTapPos = event.localPosition;
      }
    }

    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) {
      _twoFingerTapCandidate = false;
      _twoFingerTapDownPositions.clear();
      _twoFingerTapStartedAt = null;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final controller = context.read<FractalController>();
    final factor = math.exp(-event.scrollDelta.dy * 0.001);
    final targetZoom = controller.view.zoom * factor;
    _applyZoomAroundFocal(
      controller: controller,
      targetZoom: targetZoom,
      focalPoint: event.localPosition,
    );
    widget.onUserInteraction?.call();
  }

  void _animateZoomTo(
    double from,
    double to, {
    Offset? focalPoint,
    VoidCallback? onCompleted,
  }) {
    final controller = context.read<FractalController>();

    _zoomAnimation?.dispose();
    _zoomAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this as TickerProvider,
    );

    final tween = Tween<double>(begin: from, end: to);
    final curve =
        CurvedAnimation(parent: _zoomAnimation!, curve: Curves.easeOutCubic);
    _zoomAnimation!.addListener(() {
      final zoom = tween.transform(curve.value);
      if (focalPoint == null) {
        controller.updateView(
          controller.view.copyWith(zoom: zoom),
          adaptIterationsForZoom: true,
        );
      } else {
        _applyZoomAroundFocal(
          controller: controller,
          targetZoom: zoom,
          focalPoint: focalPoint,
        );
      }
    });
    if (onCompleted != null) {
      _zoomAnimation!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          onCompleted();
        }
      });
    }

    unawaited(_zoomAnimation!.forward());
  }

  /// Animates pan and zoom simultaneously from start values to target values.
  /// Simpler and more reliable than the incremental focal-point approach for
  /// gestures where the target is known up-front (e.g. double-tap).
  void _animatePanZoomTo({
    required Vector2 startPan,
    required Vector2 targetPan,
    required double fromZoom,
    required double toZoom,
    VoidCallback? onCompleted,
  }) {
    final controller = context.read<FractalController>();

    _zoomAnimation?.dispose();
    _zoomAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this as TickerProvider,
    );

    final curve =
        CurvedAnimation(parent: _zoomAnimation!, curve: Curves.easeOutCubic);
    _zoomAnimation!.addListener(() {
      final t = curve.value;
      controller.updateView(
        controller.view.copyWith(
          pan: Vector2(
            startPan.x + (targetPan.x - startPan.x) * t,
            startPan.y + (targetPan.y - startPan.y) * t,
          ),
          zoom: fromZoom + (toZoom - fromZoom) * t,
        ),
        adaptIterationsForZoom: true,
      );
    });
    if (onCompleted != null) {
      _zoomAnimation!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          onCompleted();
        }
      });
    }

    unawaited(_zoomAnimation!.forward());
  }

  void _onLongPress(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    AppLogger.instance.debug('gesture', 'long_press', data: {
      'x': details.localPosition.dx.toStringAsFixed(1),
      'y': details.localPosition.dy.toStringAsFixed(1),
    });
    _showContextMenu(details.globalPosition);
  }

  /// Desktop mouse equivalent of [_onLongPress]: right-click opens the same
  /// context menu, matching the conventional desktop affordance instead of
  /// requiring a click-and-hold.
  void _onSecondaryTap(TapUpDetails details) {
    AppLogger.instance.debug('gesture', 'secondary_tap', data: {
      'x': details.localPosition.dx.toStringAsFixed(1),
      'y': details.localPosition.dy.toStringAsFixed(1),
    });
    _showContextMenu(details.globalPosition);
  }

  /// Called when user taps the left (Mandelbrot) panel of the julia_dual module.
  /// Converts screen position to Mandelbrot complex coords and updates Julia seed.
  void _onJuliaDualTap(Offset localPos, FractalController controller) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    // Only respond to taps on the left (Mandelbrot) panel.
    if (localPos.dx >= size.width * 0.5) return;

    final view = controller.view;
    // Mirror the dual-panel shader's coordinate mapping exactly:
    //   halfW = uResolution.x * 0.5
    //   scale = min(halfW, uResolution.y)
    //   uv    = (fragCoord - vec2(halfW*0.5, uResolution.y*0.5)) / scale
    final halfW = size.width * 0.5;
    final scale = halfW < size.height ? halfW : size.height;
    final uvX = (localPos.dx - halfW * 0.5) / scale;
    final uvY = (localPos.dy - size.height * 0.5) / scale;

    // Apply zoom and pan to get fractal coordinates.
    final fracX = uvX / view.zoom + view.pan.x;
    final fracY = uvY / view.zoom + view.pan.y;

    controller.updateParam('juliaCReal', fracX.clamp(-2.0, 2.0));
    controller.updateParam('juliaCImag', fracY.clamp(-2.0, 2.0));
  }

  void _showContextMenu(Offset position) {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'reset',
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuResetView),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'controls',
          child: Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuOpenControls),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'presets',
          child: Row(
            children: [
              const Icon(Icons.bookmark_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuOpenPresets),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'randomize',
          child: Row(
            children: [
              const Icon(Icons.shuffle_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuRandomize),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              const Icon(Icons.download_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuExport),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'reset':
          controller.resetView();
          HapticFeedback.mediumImpact();
          break;
        case 'controls':
          widget.onOpenControls?.call();
          break;
        case 'presets':
          widget.onOpenPresets?.call();
          break;
        case 'randomize':
          controller.randomizeParams();
          HapticFeedback.mediumImpact();
          break;
        case 'export':
          widget.onOpenExport?.call();
          break;
      }
    });
  }
}
