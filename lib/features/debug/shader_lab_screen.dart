import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Diagnostic screen to isolate whether the device can render:
/// 1) plain Flutter (solid color)
/// 2) a built-in gradient shader
/// 3) a FragmentProgram (runtime_effect) shader
///
/// Also measures "dark ratio" via RenderRepaintBoundary.toImage(), same method
/// used by the GPU health check.
class ShaderLabScreen extends StatefulWidget {
  const ShaderLabScreen({super.key});

  @override
  State<ShaderLabScreen> createState() => _ShaderLabScreenState();
}

class _ShaderLabScreenState extends State<ShaderLabScreen> {
  final _keySolid = GlobalKey();
  final _keyGradient = GlobalKey();
  final _keyFrag = GlobalKey();

  ui.FragmentProgram? _program;
  Object? _loadError;

  double? _darkSolid;
  double? _darkGradient;
  double? _darkFrag;

  bool _running = false;

  @override
  void initState() {
    super.initState();
    // Delay shader load a bit; some Impeller paths behave badly at startup.
    scheduleMicrotask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      try {
        final p = await ui.FragmentProgram.fromAsset('shaders/diag_min.frag');
        if (!mounted) return;
        setState(() {
          _program = p;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _loadError = e;
        });
      }
    });
  }

  Future<double?> _measure(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderRepaintBoundary) return null;

    final img = await ro.toImage(pixelRatio: 0.05);
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;

    final bytes = data.buffer.asUint8List();
    int count = 0;
    int dark = 0;
    for (int i = 0; i + 3 < bytes.length; i += 4 * 40) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b);
      if (lum < 8) dark++;
      count++;
    }
    if (count == 0) return null;
    return dark / count;
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final s = await _measure(_keySolid);
      final g = await _measure(_keyGradient);
      final f = await _measure(_keyFrag);
      if (!mounted) return;
      setState(() {
        _darkSolid = s;
        _darkGradient = g;
        _darkFrag = f;
      });
    } catch (e) {
      // ignore; we just want best-effort results
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Widget _tile({
    required String title,
    required GlobalKey boundaryKey,
    required Widget child,
    required double? ratio,
  }) {
    final ratioText = ratio == null ? '—' : ratio.toStringAsFixed(3);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              '$title  (darkRatio: $ratioText)',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: boundaryKey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                    color: Colors.black,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shaderStatus = _loadError != null
        ? 'FragmentProgram load error: $_loadError'
        : (_program == null ? 'FragmentProgram: loading…' : 'FragmentProgram: loaded');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Shader Lab'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _running ? null : _run,
            child: Text(
              _running ? 'Running…' : 'Run test',
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                shaderStatus,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _tile(
                      title: '1) Solid color (Container)',
                      boundaryKey: _keySolid,
                      ratio: _darkSolid,
                      child: const ColoredBox(color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(height: 12),
                    _tile(
                      title: '2) Built-in LinearGradient',
                      boundaryKey: _keyGradient,
                      ratio: _darkGradient,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE11D48),
                              Color(0xFF8B5CF6),
                              Color(0xFF06B6D4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _tile(
                      title: '3) FragmentProgram (runtime_effect)',
                      boundaryKey: _keyFrag,
                      ratio: _darkFrag,
                      child: _program == null
                          ? const Center(
                              child: Text(
                                'Loading shader…',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : CustomPaint(
                              painter: _FragPainter(_program!),
                              child: const SizedBox.expand(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FragPainter extends CustomPainter {
  _FragPainter(this.program);
  final ui.FragmentProgram program;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    final paint = ui.Paint()..shader = shader;
    canvas.drawRect(ui.Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _FragPainter oldDelegate) => false;
}
