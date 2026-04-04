part of 'fractal_renderer.dart';

/// Mixin that handles all gesture input for the fractal renderer.
///
/// Provides pan, zoom, rotate, double-tap, two-finger-tap, fling, and
/// context-menu gestures. Apply alongside `TickerProviderStateMixin`.
mixin _GestureHandlerMixin on State<FractalRenderer> {
  // Gesture tuning constants
  static const double _kMinZoom = 1e-10;
  static const double _kMaxZoom = 1e10;
  static const double _kPanMin = -3.0;
  static const double _kPanMax = 3.0;
  static const double _kRubberBandStrength = 0.5;
  static const double _kTiltMaxRadians = 67.5 * math.pi / 180.0;
  // Raised from 0.06 → 0.12 rad: fingers are never perfectly parallel during
  // pinch, so the old threshold triggered accidental rotation too easily.
  static const double _kIntentionalRotationThreshold = 0.12;
  // If scale deviates this much BEFORE rotation threshold is reached, the
  // gesture is classified as zoom/pan and rotation is locked out entirely.
  static const double _kIntentionalZoomThreshold = 0.05;

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
  // True once scale deviates significantly; prevents rotation from activating
  // mid-pinch (the root cause of the "rotation during zoom/pan" bug).
  bool _zoomPanGestureActive = false;
  Offset? _doubleTapDownLocal;
  DateTime? _lastRawTapAt;
  Offset? _lastRawTapPos;
  DateTime? _lastDoubleTapTriggeredAt;
  bool _deferUserInteractionEndToAnimation = false;

  // Velocity history for Google Maps-style fling
  static const int _velHistorySize = 5;
  final List<({Offset pos, int ms})> _velHistory = [];

  AnimationController? _zoomAnimation;

  @override
  void initState() {
    super.initState();

    // Momentum controllers for smooth deceleration.
    // Cast to TickerProvider — the using class always mixes in
    // TickerProviderStateMixin, but we can't express that in the on-clause
    // without triggering a conflicting-generic-interfaces error.
    final vsync = this as TickerProvider;
    _zoomMomentumController = AnimationController(
      duration: AppAnimations.viewerPan,
      vsync: vsync,
    )..addListener(_applyZoomMomentum);

    _panMomentumController = AnimationController(
      duration: AppAnimations.slower,
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
    _zoomVelocity = _zoomVelocity * PhysicsConstants.zoomFriction;

    // Stop threshold: 0.0001 zoom levels/ms
    if (_zoomVelocity.abs() < PhysicsConstants.zoomVelocityThreshold) {
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
    controller.updateZoom(boundedZoom);
  }

  void _applyPanMomentum() {
    if (!mounted) return;
    if (!_panMomentumController.isAnimating) return;

    final controller = context.read<FractalController>();
    final view = controller.view;
    final module = controller.module;

    // Google Maps spec: friction 0.95 per frame at 60fps
    _panVelocity = _panVelocity * PhysicsConstants.panFriction;

    // Stop threshold: 0.1 px/frame
    if (_panVelocity.distance < PhysicsConstants.panVelocityThreshold) {
      _panMomentumController.stop();
      _panVelocity = Offset.zero;
      return;
    }

    if (module.dimension == FractalDimension.threeD) {
      controller.updateRotation(
        view.rotation +
            Vector3(_panVelocity.dy * 0.0008, _panVelocity.dx * 0.0008, 0),
      );
    } else {
      // Map pixel velocity to world coordinates with precision safeguards
      final renderBox = context.findRenderObject() as RenderBox?;
      final size = renderBox?.size;
      final scalePx = (size == null)
          ? 1.0
          : math.max(1.0, math.min(size.width, size.height));

      // Use precision-aware zoom handling
      final zoom = view.zoom;
      double worldDeltaX;
      double worldDeltaY;

      if (zoom > _kHighZoomThreshold) {
        // High zoom: use reciprocal for better precision
        final invZoom = 1.0 / zoom.clamp(1e-12, _kMaxSafeZoom);
        worldDeltaX = (_panVelocity.dx / scalePx) * invZoom;
        worldDeltaY = (_panVelocity.dy / scalePx) * invZoom;
      } else {
        // Normal zoom: direct division is safe
        final safeZoom = math.max(1e-12, zoom);
        worldDeltaX = (_panVelocity.dx / scalePx) / safeZoom;
        worldDeltaY = (_panVelocity.dy / scalePx) / safeZoom;
      }

      final nextPan = Vector2(
        view.pan.x - worldDeltaX,
        view.pan.y - worldDeltaY,
      );
      final boundedPan = Vector2(
        _rubberBand(nextPan.x, _kPanMin, _kPanMax),
        _rubberBand(nextPan.y, _kPanMin, _kPanMax),
      );
      if (boundedPan.x != nextPan.x || boundedPan.y != nextPan.y) {
        _panVelocity *= 0.5;
      }
      controller.updatePan(boundedPan);
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
    _zoomPanGestureActive = false;
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
    if (value < min) return min + (value - min) * strength;
    if (value > max) return max + (value - max) * strength;
    return value;
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

  /// Precision threshold for switching to logarithmic coordinate transformation.
  /// Above this zoom level, direct division loses too much precision.
  static const double _kHighZoomThreshold = 1e6;

  /// Maximum zoom for safe direct division before precision loss.
  static const double _kMaxSafeZoom = 1e12;

  /// Converts screen pixel delta to world coordinate delta with precision
  /// safeguards for high zoom levels.
  ///
  /// At normal zoom levels, this uses direct division by zoom.
  /// At high zoom (>1e6), uses logarithmic scaling to maintain precision.
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

    // For high zoom, use precision-aware transformation
    if (zoom > _kHighZoomThreshold) {
      // Use logarithmic scaling: worldDelta = screenDelta / zoom
      // At high zoom, compute as: screenDelta * (1/zoom) with extra precision
      // Use reciprocal to maintain precision: 1/zoom is more precise when zoom is large
      final invZoom = 1.0 / zoom.clamp(1e-12, _kMaxSafeZoom);
      return Vector2(
        (rawDx * cosR + rawDy * sinR) * invZoom,
        (-rawDx * sinR + rawDy * cosR) * invZoom,
      );
    }

    // Normal zoom: direct division is safe
    final safeZoom = math.max(1e-12, zoom);
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

    if (size != null) {
      final scalePx = math.max(1.0, math.min(size.width, size.height));
      final n = _normalizedPoint(focalPoint, size, scalePx);
      final rotationZ = explicitRotationZ ?? view.rotation.z;

      // Use precision-aware division for world delta calculations
      final rotatedN = _rotateInv2d(n, rotationZ);
      double oldWorldDeltaX, oldWorldDeltaY;
      double newWorldDeltaX, newWorldDeltaY;

      if (view.zoom > _kHighZoomThreshold) {
        final invOldZoom = 1.0 / view.zoom.clamp(1e-12, _kMaxSafeZoom);
        oldWorldDeltaX = rotatedN.x * invOldZoom;
        oldWorldDeltaY = rotatedN.y * invOldZoom;
      } else {
        final safeOldZoom = math.max(1e-12, view.zoom);
        oldWorldDeltaX = rotatedN.x / safeOldZoom;
        oldWorldDeltaY = rotatedN.y / safeOldZoom;
      }

      if (zoom > _kHighZoomThreshold) {
        final invNewZoom = 1.0 / zoom.clamp(1e-12, _kMaxSafeZoom);
        newWorldDeltaX = rotatedN.x * invNewZoom;
        newWorldDeltaY = rotatedN.y * invNewZoom;
      } else {
        final safeNewZoom = math.max(1e-12, zoom);
        newWorldDeltaX = rotatedN.x / safeNewZoom;
        newWorldDeltaY = rotatedN.y / safeNewZoom;
      }

      final worldX = view.pan.x + oldWorldDeltaX;
      final worldY = view.pan.y + oldWorldDeltaY;
      controller.updatePan(Vector2(
        _rubberBand(worldX - newWorldDeltaX, _kPanMin, _kPanMax),
        _rubberBand(worldY - newWorldDeltaY, _kPanMin, _kPanMax),
      ));
    }

    controller.updateZoom(zoom);
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
          controller.updateRotation(
            view.rotation + Vector3(d.dy * 0.0009, d.dx * 0.0009, 0),
          );
        }
      } else {
        // Use incremental deltas to avoid large jumps after pinch→pan handoff.
        final worldDelta = _screenDeltaToWorldDelta(
          deltaPx: details.focalPointDelta,
          scalePx: scalePx,
          rotationZ: view.rotation.z,
          zoom: view.zoom,
        );
        controller.updatePan(
          Vector2(
            _rubberBand(view.pan.x - worldDelta.x, _kPanMin, _kPanMax),
            _rubberBand(view.pan.y - worldDelta.y, _kPanMin, _kPanMax),
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
        controller
            .updateRotation(Vector3(tilt, view.rotation.y, view.rotation.z));
      }
    }

    // If scale deviates significantly BEFORE rotation threshold is reached,
    // classify this gesture as zoom/pan and block rotation for its lifetime.
    if (!_rotationGestureActive &&
        !_zoomPanGestureActive &&
        (details.scale - 1.0).abs() > _kIntentionalZoomThreshold) {
      _zoomPanGestureActive = true;
    }

    if (!rotationLocked &&
        !_rotationGestureActive &&
        !_zoomPanGestureActive &&
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

      // Use precision-aware calculations for world coordinates
      final rotatedStartN = _rotateInv2d(startN, _startRotationZ);
      final rotatedCurN = _rotateInv2d(curN, newRotationZ);

      double startWorldX, startWorldY;
      double curWorldX, curWorldY;

      if (_startZoom > _kHighZoomThreshold) {
        final invStartZoom = 1.0 / _startZoom.clamp(1e-12, _kMaxSafeZoom);
        startWorldX = rotatedStartN.x * invStartZoom;
        startWorldY = rotatedStartN.y * invStartZoom;
      } else {
        final safeStartZoom = math.max(1e-12, _startZoom);
        startWorldX = rotatedStartN.x / safeStartZoom;
        startWorldY = rotatedStartN.y / safeStartZoom;
      }

      if (newZoom > _kHighZoomThreshold) {
        final invNewZoom = 1.0 / newZoom.clamp(1e-12, _kMaxSafeZoom);
        curWorldX = rotatedCurN.x * invNewZoom;
        curWorldY = rotatedCurN.y * invNewZoom;
      } else {
        final safeNewZoom = math.max(1e-12, newZoom);
        curWorldX = rotatedCurN.x / safeNewZoom;
        curWorldY = rotatedCurN.y / safeNewZoom;
      }

      final worldAtStart = Vector2(
        startWorldX + _startPan.x,
        startWorldY + _startPan.y,
      );
      final newCenter = Vector2(
        worldAtStart.x - curWorldX,
        worldAtStart.y - curWorldY,
      );

      controller.updatePan(Vector2(
        _rubberBand(newCenter.x, _kPanMin, _kPanMax),
        _rubberBand(newCenter.y, _kPanMin, _kPanMax),
      ));

      controller.updateRotation(
          Vector3(view.rotation.x, view.rotation.y, newRotationZ));
    } else if (!rotationLocked &&
        module.dimension == FractalDimension.threeD &&
        details.rotation != 0.0) {
      final rotationDelta = details.rotation - _lastRotation;
      controller.updateRotation(view.rotation + Vector3(0, 0, rotationDelta));
      _lastRotation = details.rotation;
    }

    controller.updateZoom(newZoom);

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
        final rotated = _rotateInv2d(n, view.rotation.z);

        // Use precision-aware zoom calculations
        double currentWorldDeltaX, currentWorldDeltaY;
        double targetWorldDeltaX, targetWorldDeltaY;

        if (currentZoom > _kHighZoomThreshold) {
          final invCurrentZoom = 1.0 / currentZoom.clamp(1e-12, _kMaxSafeZoom);
          currentWorldDeltaX = rotated.x * invCurrentZoom;
          currentWorldDeltaY = rotated.y * invCurrentZoom;
        } else {
          final safeCurrentZoom = math.max(1e-12, currentZoom);
          currentWorldDeltaX = rotated.x / safeCurrentZoom;
          currentWorldDeltaY = rotated.y / safeCurrentZoom;
        }

        if (targetZoom > _kHighZoomThreshold) {
          final invTargetZoom = 1.0 / targetZoom.clamp(1e-12, _kMaxSafeZoom);
          targetWorldDeltaX = rotated.x * invTargetZoom;
          targetWorldDeltaY = rotated.y * invTargetZoom;
        } else {
          final safeTargetZoom = math.max(1e-12, targetZoom);
          targetWorldDeltaX = rotated.x / safeTargetZoom;
          targetWorldDeltaY = rotated.y / safeTargetZoom;
        }

        targetPan = Vector2(
          _rubberBand(view.pan.x + currentWorldDeltaX - targetWorldDeltaX,
              _kPanMin, _kPanMax),
          _rubberBand(view.pan.y + currentWorldDeltaY - targetWorldDeltaY,
              _kPanMin, _kPanMax),
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
    if (!_twoFingerTapCandidate) return;

    final origin = _twoFingerTapDownPositions[event.pointer];
    if (origin != null && (event.localPosition - origin).distance > 18.0) {
      _twoFingerTapCandidate = false;
    }
  }

  void _onPointerUp(PointerEvent event) {
    // Check two-finger tap FIRST (before removing pointer)
    // This prevents single-finger logic from running when second finger lifts
    if (_twoFingerTapCandidate && _activePointers.length == 2) {
      final elapsedMs = DateTime.now()
          .difference(_twoFingerTapStartedAt ?? DateTime.now())
          .inMilliseconds;
      if (elapsedMs <= 220) {
        final points = _activePointers.values.toList(growable: false);
        final midpoint = Offset(
          (points[0].dx + points[1].dx) / 2.0,
          (points[0].dy + points[1].dy) / 2.0,
        );
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
    }

    // Check single-finger double-tap (only when 1 finger remains)
    if (_activePointers.length == 1 && event is PointerUpEvent) {
      final now = DateTime.now();
      final prevAt = _lastRawTapAt;
      final prevPos = _lastRawTapPos;

      if (prevAt != null && prevPos != null) {
        final dtMs = now.difference(prevAt).inMilliseconds;
        final distPx = (event.localPosition - prevPos).distance;
        if (dtMs <= PhysicsConstants.doubleTapMaxGapMs &&
            distPx <= PhysicsConstants.doubleTapMaxDistancePx) {
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
      duration: AppAnimations.quickTransition,
      vsync: this as TickerProvider,
    );

    final tween = Tween<double>(begin: from, end: to);
    final curve =
        CurvedAnimation(parent: _zoomAnimation!, curve: Curves.easeOutCubic);
    _zoomAnimation!.addListener(() {
      final zoom = tween.transform(curve.value);
      if (focalPoint == null) {
        controller.updateZoom(zoom);
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
      duration: AppAnimations.quickTransition,
      vsync: this as TickerProvider,
    );

    final curve =
        CurvedAnimation(parent: _zoomAnimation!, curve: Curves.easeOutCubic);
    _zoomAnimation!.addListener(() {
      final t = curve.value;
      controller.updateZoom(fromZoom + (toZoom - fromZoom) * t);
      controller.updatePan(Vector2(
        startPan.x + (targetPan.x - startPan.x) * t,
        startPan.y + (targetPan.y - startPan.y) * t,
      ));
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

    // Apply zoom and pan to get fractal coordinates with precision safeguards.
    final zoom = view.zoom;
    final double fracX, fracY;
    if (zoom > _kHighZoomThreshold) {
      // Use reciprocal for better precision at high zoom
      final invZoom = 1.0 / zoom.clamp(1e-12, _kMaxSafeZoom);
      fracX = uvX * invZoom + view.pan.x;
      fracY = uvY * invZoom + view.pan.y;
    } else {
      final safeZoom = math.max(1e-12, zoom);
      fracX = uvX / safeZoom + view.pan.x;
      fracY = uvY / safeZoom + view.pan.y;
    }

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
