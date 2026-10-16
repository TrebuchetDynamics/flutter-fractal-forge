import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/prime_norm_quaternion_model.dart';

/// Bounded, fixed-d companion view; deliberately separate from Julia shaders.
class PrimeNormQuaternionSliceView extends StatefulWidget {
  final VoidCallback onBack;
  const PrimeNormQuaternionSliceView({super.key, required this.onBack});

  @override
  State<PrimeNormQuaternionSliceView> createState() =>
      _PrimeNormQuaternionSliceViewState();
}

class _PrimeNormQuaternionSliceViewState
    extends State<PrimeNormQuaternionSliceView> {
  PrimeNormQuaternionSlice? _slice;
  final _camera = QuaternionSliceCamera();
  int _d = 0;
  IntegerQuaternion? _selected;
  bool _list = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final result = await PrimeNormQuaternionSlice.generate(
        PrimeNormQuaternionSlice.defaultDomain,
        d: _d);
    if (mounted)
      setState(() {
        _slice = result;
        _selected = null;
      });
  }

  @override
  Widget build(BuildContext context) {
    final slice = _slice;
    return SafeArea(
        child: Column(children: [
      Wrap(alignment: WrapAlignment.center, children: [
        TextButton(
            onPressed: widget.onBack,
            child: const Text('Back to Gaussian map')),
        const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Prime-norm quaternion slice · fixed-d slice only')),
      ]),
      Text(
          'Integer points (a,b,c,d), −6 ≤ a,b,c ≤ 6 · d = $_d · N(q)=a²+b²+c²+d² is ordinary prime'),
      if (_selected case final p?)
        Text(
            'Selected (${p.a}, ${p.b}, ${p.c}, ${p.d}) · norm ${p.a * p.a + p.b * p.b + p.c * p.c + p.d * p.d}'),
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
                        onPanUpdate: (details) => setState(() => _camera.rotate(
                            details.delta.dx * .012, details.delta.dy * .012)),
                        onTapDown: (details) {
                          final p = _camera.pick(details.localPosition, slice,
                              box.biggest, slice.bound);
                          if (p != null) setState(() => _selected = p);
                        },
                        child: CustomPaint(
                            size: box.biggest,
                            painter: _QuaternionPainter(
                                slice,
                                _camera,
                                _selected,
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.onSurface)))),
      ),
    ]));
  }
}

class _QuaternionPainter extends CustomPainter {
  final PrimeNormQuaternionSlice slice;
  final QuaternionSliceCamera camera;
  final IntegerQuaternion? selected;
  final Color color, foreground;
  _QuaternionPainter(
      this.slice, this.camera, this.selected, this.color, this.foreground);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final sorted = [...slice.points]..sort((a, b) => camera
        .project(a, size, slice.bound)!
        .depth
        .compareTo(camera.project(b, size, slice.bound)!.depth));
    for (final q in sorted) {
      final projection = camera.project(q, size, slice.bound)!;
      paint.color = q == selected
          ? color
          : Color.lerp(
              color,
              foreground,
              .25 +
                  (projection.depth + slice.bound * 1.5)
                          .clamp(0, slice.bound * 3) /
                      (slice.bound * 3) *
                      .55)!;
      canvas.drawCircle(projection.screen, q == selected ? 6 : 3.5, paint);
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
      old.color != color;
}
