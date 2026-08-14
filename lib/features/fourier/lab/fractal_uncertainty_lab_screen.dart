import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

import 'discrete_cantor_alphabet.dart';
import 'discrete_cantor_mask.dart';
import 'fractal_uncertainty_estimator.dart';

enum FractalUncertaintyPreset {
  productDust,
  sierpinskiCarpet,
  orthogonalLines,
}

class FractalUncertaintyLabScreen extends StatefulWidget {
  const FractalUncertaintyLabScreen({
    super.key,
    this.initialPreset = FractalUncertaintyPreset.productDust,
  });

  final FractalUncertaintyPreset initialPreset;

  @override
  State<FractalUncertaintyLabScreen> createState() =>
      _FractalUncertaintyLabScreenState();
}

class _FractalUncertaintyLabScreenState
    extends State<FractalUncertaintyLabScreen> {
  late FractalUncertaintyPreset _preset = widget.initialPreset;
  int _recursion = 2;
  bool _running = false;
  FractalUncertaintyEstimate? _estimate;
  Object? _error;
  Isolate? _estimateIsolate;
  ReceivePort? _estimatePort;
  int _runGeneration = 0;

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _error = null;
    });
    final generation = ++_runGeneration;
    final port = ReceivePort();
    _estimatePort = port;
    try {
      final isolate = await Isolate.spawn(
        _estimateLabIsolate,
        (port.sendPort, _preset.index, _recursion),
      );
      if (!mounted || generation != _runGeneration) {
        isolate.kill(priority: Isolate.immediate);
        return;
      }
      _estimateIsolate = isolate;
      final message = await port.first;
      if (!mounted || generation != _runGeneration) return;
      if (message is FractalUncertaintyEstimate) {
        setState(() => _estimate = message);
      } else {
        throw StateError('$message');
      }
    } catch (error) {
      if (!mounted || generation != _runGeneration) return;
      setState(() => _error = error);
    } finally {
      if (generation == _runGeneration) {
        _estimateIsolate = null;
        _estimatePort?.close();
        _estimatePort = null;
        if (mounted) setState(() => _running = false);
      }
    }
  }

  @override
  void dispose() {
    _runGeneration++;
    _estimateIsolate?.kill(priority: Isolate.immediate);
    _estimatePort?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final masks = _buildMasks(_preset, _recursion);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.uncertaintyLabTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.fourierFiniteDisclaimer,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.uncertaintyLabIntro),
          const SizedBox(height: 16),
          DropdownButtonFormField<FractalUncertaintyPreset>(
            initialValue: _preset,
            decoration: InputDecoration(labelText: l10n.uncertaintyExperiment),
            items: [
              for (final preset in FractalUncertaintyPreset.values)
                DropdownMenuItem(
                  value: preset,
                  child: Text(_presetName(preset, l10n)),
                ),
            ],
            onChanged: _running
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _preset = value;
                      _estimate = null;
                    });
                  },
          ),
          if (_preset == FractalUncertaintyPreset.orthogonalLines) ...[
            const SizedBox(height: 8),
            Text(
              l10n.uncertaintyLineObstruction,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(l10n.uncertaintyLineObstructionExplanation),
          ],
          const SizedBox(height: 16),
          Text('${l10n.uncertaintyRecursionDepth}: $_recursion'),
          Slider(
            value: _recursion.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            label: '$_recursion',
            onChanged: _running
                ? null
                : (value) => setState(() {
                      _recursion = value.round();
                      _estimate = null;
                    }),
          ),
          Text(
            '${l10n.uncertaintyBaseGrid}: ${masks.spatial.sideLength} × '
            '${masks.spatial.sideLength}',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final panels = <Widget>[
                _MaskPanel(
                  label: l10n.uncertaintySpatialMask,
                  occupiedLabel: l10n.uncertaintyOccupiedCells,
                  totalLabel: l10n.uncertaintyTotalCells,
                  mask: masks.spatial,
                ),
                _MaskPanel(
                  label: l10n.uncertaintyFourierMask,
                  occupiedLabel: l10n.uncertaintyOccupiedCells,
                  totalLabel: l10n.uncertaintyTotalCells,
                  mask: masks.spectral,
                ),
              ];
              if (constraints.maxWidth < 520) {
                return Column(
                  children: [
                    panels.first,
                    const SizedBox(height: 12),
                    panels.last,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: panels.first),
                  const SizedBox(width: 12),
                  Expanded(child: panels.last),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('runUncertaintyExperiment'),
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.calculate_rounded),
            label: Text(
              _running ? l10n.uncertaintyEstimating : l10n.uncertaintyRun,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(l10n.uncertaintyUnavailable),
            ),
          ],
          if (_estimate case final estimate?) ...[
            const SizedBox(height: 20),
            _EstimatePanel(estimate: estimate, l10n: l10n),
          ],
        ],
      ),
    );
  }
}

class _MaskPanel extends StatelessWidget {
  const _MaskPanel({
    required this.label,
    required this.occupiedLabel,
    required this.totalLabel,
    required this.mask,
  });

  final String label;
  final String occupiedLabel;
  final String totalLabel;
  final DiscreteCantorMask mask;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${mask.cardinality} $occupiedLabel, '
          '${mask.sideLength * mask.sideLength} $totalLabel',
      image: true,
      excludeSemantics: true,
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 6),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: _MaskPainter(mask)),
          ),
        ],
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  const _MaskPainter(this.mask);

  final DiscreteCantorMask mask;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF110A25));
    final cellWidth = size.width / mask.sideLength;
    final cellHeight = size.height / mask.sideLength;
    final paint = Paint()..color = const Color(0xFF8C7BFF);
    for (final cell in mask.activeCoordinates) {
      canvas.drawRect(
        Rect.fromLTWH(
          cell.x * cellWidth,
          cell.y * cellHeight,
          cellWidth,
          cellHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) =>
      oldDelegate.mask != mask;
}

class _EstimatePanel extends StatelessWidget {
  const _EstimatePanel({required this.estimate, required this.l10n});

  final FractalUncertaintyEstimate estimate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final retained = estimate.retainedEnergy * 100;
    final leakage = estimate.leakage * 100;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.uncertaintyEstimatedNorm}: '
            '${estimate.sigma.toStringAsFixed(6)}',
          ),
          Text('${l10n.uncertaintyRetainedEnergy}: '
              '${retained.toStringAsFixed(1)}%'),
          Text('${l10n.uncertaintyWorstLeakage}: '
              '${leakage.toStringAsFixed(1)}%'),
          Text(
            '${l10n.uncertaintyHilbertSchmidt}: '
            '${estimate.hilbertSchmidtBound.toStringAsFixed(6)}',
          ),
          Text(
            '${l10n.uncertaintyConvergenceResidual}: '
            '${estimate.residual.toStringAsExponential(2)}, '
            '${l10n.uncertaintyAfterIterations} ${estimate.iterations} '
            '(${estimate.converged ? l10n.uncertaintyConverged : l10n.uncertaintyNotConverged})',
          ),
          Text(l10n.uncertaintyFiniteEstimate),
        ],
      ),
    );
  }
}

void _estimateLabIsolate((SendPort, int, int) request) {
  final (sendPort, presetIndex, recursion) = request;
  try {
    final preset = FractalUncertaintyPreset.values[presetIndex];
    final masks = _buildMasks(preset, recursion);
    sendPort.send(
      FractalUncertaintyEstimator().estimate(masks.spatial, masks.spectral),
    );
  } catch (error) {
    sendPort.send('Uncertainty estimate failed: $error');
  }
}

({DiscreteCantorMask spatial, DiscreteCantorMask spectral}) _buildMasks(
  FractalUncertaintyPreset preset,
  int recursion,
) {
  late DiscreteCantorAlphabet spatial;
  late DiscreteCantorAlphabet spectral;
  switch (preset) {
    case FractalUncertaintyPreset.productDust:
      spatial = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: {0, 2},
        yDigits: {0, 2},
      );
      spectral = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: {0, 2},
        yDigits: {0, 2},
      );
    case FractalUncertaintyPreset.sierpinskiCarpet:
      spatial = DiscreteCantorAlphabet.sierpinski(base: 3);
      spectral = DiscreteCantorAlphabet.sierpinski(base: 3);
    case FractalUncertaintyPreset.orthogonalLines:
      spatial = DiscreteCantorAlphabet.horizontalLine(base: 3, y: 0);
      spectral = DiscreteCantorAlphabet.verticalLine(base: 3, x: 0);
  }
  return (
    spatial: DiscreteCantorMask.generate(spatial, recursion: recursion),
    spectral: DiscreteCantorMask.generate(spectral, recursion: recursion),
  );
}

String _presetName(
  FractalUncertaintyPreset preset,
  AppLocalizations l10n,
) =>
    switch (preset) {
      FractalUncertaintyPreset.productDust => l10n.uncertaintyProductDust,
      FractalUncertaintyPreset.sierpinskiCarpet => l10n.uncertaintySierpinski,
      FractalUncertaintyPreset.orthogonalLines =>
        l10n.uncertaintyOrthogonalLines,
    };
