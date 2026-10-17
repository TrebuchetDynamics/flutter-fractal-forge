import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/models/prime_norm_quaternion_model.dart';

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
  final ValueChanged<Uint8List>? onCapturedPng;
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
    if (mounted) {
      setState(() => _capturedPng = png);
      widget.onCapturedPng?.call(png);
    }
  }

  Uint8List? _capturedPng;

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slice = _slice;
    return RepaintBoundary(
        key: _captureKey,
        child: SafeArea(
            child: Column(children: [
          Wrap(alignment: WrapAlignment.center, children: [
            TextButton(
                onPressed: widget.onBack,
                child: const Text('Back to Gaussian map')),
            const Padding(
                padding: EdgeInsets.all(12),
                child:
                    Text('Prime-norm quaternion slice · fixed-d slice only')),
          ]),
          Text(
              'Integer points (a,b,c,d), −6 ≤ a,b,c ≤ 6 · d = $_d · N(q)=a²+b²+c²+d² is ordinary prime'),
          if (_selected case final p?)
            Text(
                'Selected (${p.a}, ${p.b}, ${p.c}, ${p.d}) · norm ${p.a * p.a + p.b * p.b + p.c * p.c + p.d * p.d}'),
          Text(
              'Walk: ${_path.length - 1} steps · component ${_component.length} · fixed d=$_d only · ${_slice != null && _component.any((p) => p.a.abs() == _slice!.bound || p.b.abs() == _slice!.bound || p.c.abs() == _slice!.bound) ? 'boundary may continue' : 'boundary contained'}'),
          Text('Squared step limit: $_maxSquaredStep'),
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
                child: const Text('Step')),
            TextButton(
                onPressed: _path.length > 1
                    ? () => setState(() => _path.removeLast())
                    : null,
                child: const Text('Undo step')),
            TextButton(
                onPressed: () => setState(() {
                      _path
                        ..clear()
                        ..add(_slice?.points.firstOrNull ??
                            (a: 1, b: 1, c: 0, d: _d));
                    }),
                child: const Text('Reset path')),
            TextButton(onPressed: _capture, child: const Text('Capture PNG')),
          ]),
          if (_capturedPng != null) const Text('Captured fixed-d view as PNG'),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: _d > -12
                    ? () {
                        setState(() => _d--);
                        _generate();
                      }
                    : null,
                icon: const Icon(Icons.remove),
                tooltip: 'Decrease fixed d'),
            Text('d = $_d'),
            IconButton(
                onPressed: _d < 12
                    ? () {
                        setState(() => _d++);
                        _generate();
                      }
                    : null,
                icon: const Icon(Icons.add),
                tooltip: 'Increase fixed d'),
            TextButton(
                onPressed: () => setState(() => _list = !_list),
                child: Text(_list ? '3D view' : 'Coordinate list')),
            TextButton(
                onPressed: () => setState(() {
                      _camera.yaw = 0;
                      _camera.pitch = 0;
                    }),
                child: const Text('Reset view')),
          ]),
          const Text(
              'Norm legend: prime norm points · camera rotation changes projection, not membership'),
          Expanded(
            child: slice == null
                ? const Center(child: CircularProgressIndicator())
                : _list
                    ? ListView.builder(
                        itemCount: slice.points.length,
                        itemBuilder: (context, index) {
                          final p = slice.points[index];
                          return ListTile(
                              title: Text(
                                  '(${p.a}, ${p.b}, ${p.c}, ${p.d}) · N=${p.a * p.a + p.b * p.b + p.c * p.c + p.d * p.d}'),
                              selected: p == _selected,
                              onTap: () => setState(() => _selected = p));
                        })
                    : LayoutBuilder(
                        builder: (context, box) => GestureDetector(
                            onPanUpdate: (details) => setState(() =>
                                _camera.rotate(details.delta.dx * .012,
                                    details.delta.dy * .012)),
                            onTapUp: (details) {
                              final p = _camera.pick(details.localPosition,
                                  slice, box.biggest, slice.bound);
                              if (p != null) setState(() => _selected = p);
                            },
                            child: CustomPaint(
                                size: box.biggest,
                                painter: _QuaternionPainter(
                                    slice,
                                    _camera,
                                    _selected,
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.onSurface,
                                    _path.toList(),
                                    _component)))),
          ),
        ])));
  }
}

class _QuaternionPainter extends CustomPainter {
  final PrimeNormQuaternionSlice slice;
  final QuaternionSliceCamera camera;
  final IntegerQuaternion? selected;
  final Color color, foreground;
  final List<IntegerQuaternion> path;
  final Set<IntegerQuaternion> component;
  _QuaternionPainter(this.slice, this.camera, this.selected, this.color,
      this.foreground, this.path, this.component);
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
      old.camera.yaw != camera.yaw ||
      old.camera.pitch != camera.pitch ||
      old.selected != selected ||
      old.path != path ||
      old.component != component ||
      old.color != color;
}
