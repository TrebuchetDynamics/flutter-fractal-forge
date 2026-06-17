import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_engine.dart';
import 'package:flutter_fractals/features/formulas/frm/frm_parser.dart';

/// Interactive lab for the restricted Fractint-style FRM formula subset.
///
/// Type a formula (init section, `:`, iter section), render a CPU preview, and
/// see parse/eval errors. The language supports `+ - * /`, right-associative
/// `^`, complex `(re, im)` literals, function calls (`sqr`, `conj`, `exp`,
/// `sin`, …), and the variables `pixel`/`z`/`c`. Escape defaults to `|z|^2 > 4`
/// but a formula may declare its own bailout (e.g. `cabs2(z) <= 4`).
class FrmFormulaScreen extends StatefulWidget {
  const FrmFormulaScreen({super.key});

  @override
  State<FrmFormulaScreen> createState() => _FrmFormulaScreenState();
}

class _FrmFormulaScreenState extends State<FrmFormulaScreen> {
  static const int _previewSize = 320;

  static const Map<String, String> _examples = {
    'Mandelbrot':
        'Mandelbrot {\n  z = (0,0)\n  c = pixel\n:\n  z = z*z + c\n}\n',
    'Julia': 'Julia {\n  z = pixel\n  c = (-0.8, 0.156)\n:\n  z = z*z + c\n}\n',
    'Cubic': 'Cubic {\n  z = (0,0)\n  c = pixel\n:\n  z = z^3 + c\n}\n',
    'Tricorn': 'Tricorn {\n  z = (0,0)\n  c = pixel\n'
        ':\n  z = conj(z)^2 + c\n  cabs2(z) <= 4\n}\n',
  };

  late final TextEditingController _controller =
      TextEditingController(text: _examples['Mandelbrot']);

  ui.Image? _image;
  String? _error;
  bool _rendering = false;
  int _renderSeq = 0;

  @override
  void dispose() {
    _controller.dispose();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _render() async {
    final source = _controller.text;
    final seq = ++_renderSeq;
    setState(() {
      _rendering = true;
      _error = null;
    });

    try {
      // Cheap parse on the main thread first for fast, precise error feedback.
      FrmParser(source).parseFile();

      final bytes = await compute(
        renderFrmImageBytes,
        FrmRenderRequest(
          source: source,
          panX: -0.5,
          panY: 0.0,
          zoom: 0.4,
          width: _previewSize,
          height: _previewSize,
          iterations: 160,
          bailout: 2.0,
        ),
      );

      if (!mounted || seq != _renderSeq) return;
      final image = await _decodeRgba(bytes, _previewSize, _previewSize);
      if (!mounted || seq != _renderSeq) {
        image.dispose();
        return;
      }
      setState(() {
        _image?.dispose();
        _image = image;
        _rendering = false;
      });
    } catch (error) {
      if (!mounted || seq != _renderSeq) return;
      setState(() {
        _error = error is FormatException ? error.message : error.toString();
        _rendering = false;
      });
    }
  }

  Future<ui.Image> _decodeRgba(Uint8List rgba, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Formula Lab')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPreview(theme),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in _examples.entries)
                    ActionChip(
                      label: Text(entry.key),
                      onPressed: () {
                        _controller.text = entry.value;
                        _render();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 8,
                minLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'FRM formula',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _rendering ? null : _render,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Render'),
              ),
              const SizedBox(height: 12),
              Text(
                'Supports + - * / ^, functions (sqr, conj, exp, sin, …) and '
                '(re, im) literals with variables pixel / z / c. Escape '
                'defaults to |z|² > 4; add a line like cabs2(z) <= 4 to set '
                'your own.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      );
    }
    final image = _image;
    if (image == null && !_rendering) {
      return Center(
        child: Text(
          'Tap Render to preview',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (image != null) RawImage(image: image, fit: BoxFit.contain),
        if (_rendering) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
