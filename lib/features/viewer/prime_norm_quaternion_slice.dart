import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/prime_norm_quaternion_model.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Captures a painted quaternion slice boundary as a PNG byte buffer.
Future<Uint8List?> captureQuaternionPng(RenderRepaintBoundary boundary) async {
  if (!boundary.attached || !boundary.hasSize || boundary.size.isEmpty) {
    return null;
  }
  final image = await boundary.toImage(pixelRatio: 1);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Bounded, fixed-d companion view; deliberately separate from Julia shaders.
class PrimeNormQuaternionSliceView extends StatefulWidget {
  final VoidCallback onBack;
  final Future<void> Function(Uint8List)? onCapturedPng;
  const PrimeNormQuaternionSliceView(
      {super.key, required this.onBack, this.onCapturedPng});

  @override
  State<PrimeNormQuaternionSliceView> createState() =>
      _PrimeNormQuaternionSliceViewState();
}

class _PrimeNormQuaternionSliceViewState
    extends State<PrimeNormQuaternionSliceView> {
  PrimeNormQuaternionSlice? _slice;
  final _camera = QuaternionSliceCamera();
  final _canvasFocusNode = FocusNode(debugLabel: 'Quaternion slice projection');
  int _d = 0;
  int _generation = 0;
  IntegerQuaternion? _selected;
  bool _list = false;
  int _maxSquaredStep = 2;
  final List<IntegerQuaternion> _path = [(a: 1, b: 1, c: 0, d: 0)];
  Set<IntegerQuaternion> _component = const {};
  final _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final generation = ++_generation;
    final d = _d;
    setState(() {
      _slice = null;
      _selected = null;
      _path.clear();
      _component = const {};
    });
    late final PrimeNormQuaternionSlice result;
    try {
      result = await PrimeNormQuaternionSlice.generate(
          PrimeNormQuaternionSlice.defaultDomain,
          d: d,
          isCancelled: () => !mounted || generation != _generation);
    } on StateError {
      if (!mounted || generation != _generation) return;
      rethrow;
    }
    if (mounted && generation == _generation) {
      setState(() {
        _slice = result;
        final start = result.points.isEmpty ? null : result.points.first;
        if (start != null) _path.add(start);
        _component = start == null
            ? const {}
            : result.component(start, maxSquaredStep: _maxSquaredStep);
      });
    }
  }

  bool get _canStep {
    final slice = _slice;
    final candidate = _selected;
    return slice != null &&
        _path.isNotEmpty &&
        candidate != null &&
        !_path.contains(candidate) &&
        slice.isAdjacent(_path.last, candidate, _maxSquaredStep);
  }

  Future<void> _capture() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final boundary = _captureKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary ||
        !boundary.hasSize ||
        boundary.size.isEmpty) {
      throw StateError('Quaternion capture boundary is not ready');
    }
    final png = await captureQuaternionPng(boundary);
    if (png == null) throw StateError('Quaternion PNG encoding failed');
    await widget.onCapturedPng?.call(png);
    if (mounted) setState(() => _capturedPng = png);
  }

  Uint8List? _capturedPng;

  @override
  void dispose() {
    _generation++;
    _canvasFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slice = _slice;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, _) => Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Wrap(alignment: WrapAlignment.center, children: [
                  TextButton(
                      onPressed: widget.onBack,
                      child: Text(l10n.quaternionBack)),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                          header: true, child: Text(l10n.quaternionTitle))),
                ]),
                Semantics(
                    label: l10n.quaternionDisclosure(_d),
                    child: ExcludeSemantics(
                        child: Text(l10n.quaternionDisclosure(_d)))),
                if (_selected case final p?)
                  Semantics(
                      liveRegion: true,
                      child: Text(l10n.quaternionSelected(p.a, p.b, p.c, p.d,
                          p.a * p.a + p.b * p.b + p.c * p.c + p.d * p.d))),
                Semantics(
                    liveRegion: true,
                    child: Text(l10n.quaternionWalkState(
                        _path.length - 1,
                        _component.length,
                        _d,
                        _slice != null &&
                                _component.any((p) =>
                                    p.a.abs() == _slice!.bound ||
                                    p.b.abs() == _slice!.bound ||
                                    p.c.abs() == _slice!.bound)
                            ? l10n.quaternionBoundaryMayContinue
                            : l10n.quaternionBoundaryContained))),
                Text(l10n.quaternionStepLimit(_maxSquaredStep)),
                Wrap(alignment: WrapAlignment.center, children: [
                  TextButton(
                      onPressed: _maxSquaredStep > 1
                          ? () => setState(() {
                                _maxSquaredStep--;
                                if (_path.isNotEmpty) {
                                  _component = _slice!.component(_path.first,
                                      maxSquaredStep: _maxSquaredStep);
                                }
                              })
                          : null,
                      child: const Text('k−')),
                  TextButton(
                      onPressed: _maxSquaredStep < 16
                          ? () => setState(() {
                                _maxSquaredStep++;
                                if (_path.isNotEmpty) {
                                  _component = _slice!.component(_path.first,
                                      maxSquaredStep: _maxSquaredStep);
                                }
                              })
                          : null,
                      child: const Text('k+')),
                  TextButton(
                      onPressed: _canStep
                          ? () => setState(() => _path.add(_selected!))
                          : null,
                      child: Text(l10n.quaternionStep)),
                  TextButton(
                      onPressed: _path.length > 1
                          ? () => setState(() => _path.removeLast())
                          : null,
                      child: Text(l10n.quaternionUndo)),
                  TextButton(
                      onPressed: () => setState(() {
                            _path
                              ..clear()
                              ..add(_slice?.points.firstOrNull ??
                                  (a: 1, b: 1, c: 0, d: _d));
                          }),
                      child: Text(l10n.quaternionResetPath)),
                  TextButton(
                      onPressed: _list ? null : _capture,
                      child: Text(l10n.quaternionCapture)),
                ]),
                if (_list) Text(l10n.quaternionCaptureRequires3d),
                if (_capturedPng != null) Text(l10n.quaternionCaptured),
                Wrap(alignment: WrapAlignment.center, children: [
                  IconButton(
                      onPressed: _d > -12
                          ? () {
                              setState(() => _d--);
                              _generate();
                            }
                          : null,
                      icon: const Icon(Icons.remove),
                      tooltip: l10n.quaternionDecreaseSlice),
                  Text('d = $_d'),
                  IconButton(
                      onPressed: _d < 12
                          ? () {
                              setState(() => _d++);
                              _generate();
                            }
                          : null,
                      icon: const Icon(Icons.add),
                      tooltip: l10n.quaternionIncreaseSlice),
                  TextButton(
                      onPressed: () => setState(() => _list = !_list),
                      child: Text(_list
                          ? l10n.quaternionView3d
                          : l10n.quaternionCoordinateList)),
                  TextButton(
                      onPressed: () => setState(() {
                            _camera.yaw = 0;
                            _camera.pitch = 0;
                          }),
                      child: Text(l10n.quaternionResetView)),
                ]),
                Text(l10n.quaternionNormLegend),
              ]),
            ),
          ),
          Expanded(
            flex: 3,
            child: RepaintBoundary(
                key: _captureKey,
                child: slice == null
                    ? const Center(child: CircularProgressIndicator())
                    : _list
                        ? Semantics(
                            label: l10n.quaternionListSemantic,
                            child: ListView.builder(
                                itemCount: slice.points.length,
                                itemBuilder: (context, index) {
                                  final p = slice.points[index];
                                  return ListTile(
                                      title: Text(
                                          '(${p.a}, ${p.b}, ${p.c}, ${p.d}) · N=${p.a * p.a + p.b * p.b + p.c * p.c + p.d * p.d}'),
                                      selected: p == _selected,
                                      onTap: () =>
                                          setState(() => _selected = p));
                                }))
                        : Semantics(
                            label: l10n.quaternionPointsSemantic,
                            focusable: true,
                            child: Focus(
                                focusNode: _canvasFocusNode,
                                onKeyEvent: (node, event) {
                                  if (event is! KeyDownEvent) {
                                    return KeyEventResult.ignored;
                                  }
                                  final delta = switch (event.logicalKey) {
                                    LogicalKeyboardKey.arrowLeft =>
                                      const Offset(-.08, 0),
                                    LogicalKeyboardKey.arrowRight =>
                                      const Offset(.08, 0),
                                    LogicalKeyboardKey.arrowUp =>
                                      const Offset(0, -.08),
                                    LogicalKeyboardKey.arrowDown =>
                                      const Offset(0, .08),
                                    _ => null,
                                  };
                                  if (delta == null)
                                    return KeyEventResult.ignored;
                                  setState(
                                      () => _camera.rotate(delta.dx, delta.dy));
                                  return KeyEventResult.handled;
                                },
                                child: LayoutBuilder(
                                    builder: (context, box) => GestureDetector(
                                        onTapDown: (_) =>
                                            _canvasFocusNode.requestFocus(),
                                        onPanUpdate: (details) => setState(() =>
                                            _camera.rotate(
                                                details.delta.dx * .012,
                                                details.delta.dy * .012)),
                                        onTapUp: (details) {
                                          final p = _camera.pick(
                                              details.localPosition,
                                              slice,
                                              box.biggest,
                                              slice.bound);
                                          if (p != null) {
                                            setState(() => _selected = p);
                                          }
                                        },
                                        child: CustomPaint(
                                            size: box.biggest,
                                            painter: _QuaternionPainter(
                                                slice,
                                                _camera,
                                                _selected,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                _path.toList(),
                                                _component))))))),
          ),
        ]),
      ),
    );
  }
}

class _QuaternionPainter extends CustomPainter {
  final PrimeNormQuaternionSlice slice;
  final QuaternionSliceCamera camera;
  final IntegerQuaternion? selected;
  final Color color, foreground;
  final List<IntegerQuaternion> path;
  final Set<IntegerQuaternion> component;
  final double yaw, pitch;
  _QuaternionPainter(this.slice, this.camera, this.selected, this.color,
      this.foreground, this.path, this.component)
      : yaw = camera.yaw,
        pitch = camera.pitch;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final sorted = [...slice.points]..sort((a, b) => camera
        .project(a, size, slice.bound)!
        .depth
        .compareTo(camera.project(b, size, slice.bound)!.depth));
    for (var i = 1; i < path.length; i++) {
      final from = camera.project(path[i - 1], size, slice.bound)!.screen;
      final to = camera.project(path[i], size, slice.bound)!.screen;
      canvas.drawLine(
          from,
          to,
          Paint()
            ..color = color
            ..strokeWidth = 2.5);
    }
    for (final q in sorted) {
      final projection = camera.project(q, size, slice.bound)!;
      final norm = q.a * q.a + q.b * q.b + q.c * q.c + q.d * q.d;
      paint.color = q == selected || path.contains(q)
          ? color
          : component.contains(q)
              ? Color.lerp(color, foreground, .12)!
              : Color.lerp(
                  color,
                  foreground,
                  .15 +
                      .65 *
                          norm /
                          (3 * slice.bound * slice.bound + slice.d * slice.d))!;
      canvas.drawCircle(projection.screen,
          q == selected || path.contains(q) ? 6 : 3.5, paint);
    }
    final axis = Paint()
      ..color = foreground
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(16, size.height - 20), Offset(60, size.height - 20), axis);
    canvas.drawLine(
        Offset(16, size.height - 20), Offset(16, size.height - 64), axis);
  }

  @override
  bool shouldRepaint(covariant _QuaternionPainter old) =>
      old.slice != slice ||
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.selected != selected ||
      old.path != path ||
      old.component != component ||
      old.color != color;
}
