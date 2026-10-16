import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/gaussian_moat_plot.dart';
import 'package:flutter_fractals/features/viewer/prime_norm_quaternion_slice.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:provider/provider.dart';

class GaussianMoatMap extends StatefulWidget {
  final GlobalKey boundaryKey;
  final VoidCallback onExplore;
  final VoidCallback onExport;
  const GaussianMoatMap(
      {super.key,
      required this.boundaryKey,
      required this.onExplore,
      required this.onExport});

  @override
  State<GaussianMoatMap> createState() => _GaussianMoatMapState();
}

class _GaussianMoatMapState extends State<GaussianMoatMap> {
  FractalController? _camera;
  GaussianPrimeMap? _map;
  GaussianInteger _root = (a: 1, b: 1);
  GaussianInteger? _candidate;
  final List<GaussianInteger> _path = [(a: 1, b: 1)];
  Set<GaussianInteger> _component = const {};
  int _maxSquaredStep = 4;
  final _a = TextEditingController(text: '1');
  final _b = TextEditingController(text: '1');
  int _bound = GaussianPrimeMap.defaultBound;
  int? _pending;
  int _generation = 0;
  bool _running = false;
  bool _error = false;
  bool _invalidCoordinates = false;
  bool _controls = false;
  bool _showQuaternionSlice = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_camera != null) return;
    final registry = context.read<ModuleRegistry>();
    _camera = FractalController(registry)
      ..selectModule(registry.byId('gaussian_prime_lattice'), animate: false)
      ..resetView();
    _request(_bound);
  }

  void _request(int bound) {
    _generation++;
    _bound = bound;
    _pending = bound;
    _map = null;
    _candidate = null;
    _root = (a: 1, b: 1);
    _path
      ..clear()
      ..add(_root);
    _component = const {};
    _error = false;
    if (!_running) _generate();
  }

  Future<void> _generate() async {
    _running = true;
    while (mounted && _pending != null) {
      final bound = _pending!;
      final generation = _generation;
      _pending = null;
      try {
        final map = await GaussianPrimeMap.generate(bound,
            isCancelled: () => !mounted || generation != _generation);
        if (mounted && generation == _generation && map != null) {
          setState(() {
            _map = map;
            _refreshComponent();
          });
        }
      } catch (_) {
        if (mounted && generation == _generation) setState(() => _error = true);
      }
    }
    _running = false;
  }

  @override
  void dispose() {
    _generation++;
    _camera?.dispose();
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _select(GaussianInteger p) => setState(() {
        _candidate = p;
        _invalidCoordinates = false;
      });

  bool get _canStep {
    final map = _map;
    final candidate = _candidate;
    return map != null &&
        candidate != null &&
        !_path.contains(candidate) &&
        map.isAdjacent(_path.last, candidate, _maxSquaredStep);
  }

  void _step() {
    if (!_canStep) return;
    setState(() => _path.add(_candidate!));
  }

  void _refreshComponent() {
    final map = _map;
    if (map == null) return;
    _component = map.component(_root, maxSquaredStep: _maxSquaredStep);
  }

  String _candidateState(AppLocalizations l10n, GaussianInteger p) {
    final map = _map;
    if (map == null) return l10n.gaussianComputing;
    if (!map.contains(p)) return l10n.gaussianUncomputed;
    return map.isPrime(p) ? l10n.gaussianPrime : l10n.gaussianComposite;
  }

  Future<void> _domainSheet() async {
    var input = '$_bound';
    String? error;
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(builder: (context, update) {
              final l10n = AppLocalizations.of(context)!;
              return AppBottomSheet(children: [
                Flexible(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          TextFormField(
                              key: const Key('gaussianBoundInput'),
                              initialValue: input,
                              onChanged: (value) => input = value,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: l10n.gaussianBound,
                                  errorText: error)),
                          FilledButton(
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(48, 48)),
                              onPressed: () {
                                final value = num.tryParse(input);
                                int bound;
                                try {
                                  bound = GaussianPrimeMap.validateBound(
                                      value ?? double.nan);
                                } on ArgumentError {
                                  update(
                                      () => error = l10n.gaussianInvalidBound);
                                  return;
                                }
                                setState(() => _request(bound));
                                Navigator.of(sheetContext).pop();
                              },
                              child: Text(l10n.actionApply)),
                        ]))),
              ]);
            }));
  }

  Widget _button(String label, VoidCallback? action, {Key? key}) => TextButton(
      key: key,
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: action,
      child: Text(label));

  Widget _controlsContent(AppLocalizations l10n) => SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _button(l10n.gaussianBound, _domainSheet),
        _button('Quaternion slice',
            () => setState(() => _showQuaternionSlice = true)),
        TextField(
            key: const Key('gaussianCoordinateA'),
            controller: _a,
            decoration: const InputDecoration(labelText: 'a'),
            keyboardType: const TextInputType.numberWithOptions(signed: true)),
        TextField(
            key: const Key('gaussianCoordinateB'),
            controller: _b,
            decoration: const InputDecoration(labelText: 'b'),
            keyboardType: const TextInputType.numberWithOptions(signed: true)),
        if (_invalidCoordinates) Text(l10n.gaussianCoordinates),
        _button(l10n.gaussianSelect, () {
          final a = int.tryParse(_a.text);
          final b = int.tryParse(_b.text);
          // Bound coordinate arithmetic equally on native and JavaScript.
          if (a == null ||
              b == null ||
              a < -1000000 ||
              a > 1000000 ||
              b < -1000000 ||
              b > 1000000) {
            setState(() => _invalidCoordinates = true);
          } else {
            _select((a: a, b: b));
          }
        }),
        _button(
            l10n.gaussianSetStart,
            _candidate != null && (_map?.isPrime(_candidate!) ?? false)
                ? () => setState(() {
                      _root = _candidate!;
                      _path
                        ..clear()
                        ..add(_root);
                      _refreshComponent();
                    })
                : null),
        Text('${l10n.gaussianStepLimit}: $_maxSquaredStep'),
        Wrap(children: [
          _button(
              'K−',
              _maxSquaredStep > 1
                  ? () => setState(() {
                        _maxSquaredStep--;
                        _refreshComponent();
                      })
                  : null),
          _button(
              'K+',
              _maxSquaredStep < 16
                  ? () => setState(() {
                        _maxSquaredStep++;
                        _refreshComponent();
                      })
                  : null),
        ]),
        _button(l10n.resetView, () => _camera!.resetView()),
        _button(
            l10n.gaussianZoomIn,
            () => _camera!
                .updateZoom((_camera!.view.zoom * 1.2).clamp(0.01, 1e6))),
        _button(
            l10n.gaussianZoomOut,
            () => _camera!
                .updateZoom((_camera!.view.zoom / 1.2).clamp(0.01, 1e6))),
        _button(
            l10n.gaussianAbout,
            () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AppBottomSheet(children: [
                      Flexible(
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Text(l10n.gaussianMath)))
                    ]))),
        Text(l10n.gaussianUnavailable),
        Text(l10n.gaussianMapOnly),
      ]));

  Widget _plot() => LayoutBuilder(builder: (context, constraints) {
        final view = context.watch<FractalController>().view;
        final map = _map;
        final colors = Theme.of(context).colorScheme;
        return FractalRenderer(
          animationEnabled: false,
          showRendererIndicator: false,
          onPlotTap: map == null
              ? null
              : (details) {
                  final transform =
                      GaussianMapTransform(constraints.biggest, view, _bound);
                  final lattice = transform.toLattice(details.localPosition);
                  if (lattice.dx.abs() <= 1000000 &&
                      lattice.dy.abs() <= 1000000) {
                    _select(transform.pick(details.localPosition));
                  }
                },
          overrideChild: RepaintBoundary(
              key: widget.boundaryKey,
              child: CustomPaint(
                  key: const Key('gaussianMoatPlot'),
                  painter: map == null
                      ? null
                      : GaussianMoatPainter(
                          map: map,
                          view: view,
                          root: _root,
                          candidate: _candidate,
                          path: _path,
                          component: _component,
                          foreground: colors.onSurface,
                          background: colors.surface,
                          highlight: colors.primary),
                  child: const SizedBox.expand())),
        );
      });

  @override
  Widget build(BuildContext context) {
    if (_showQuaternionSlice) {
      return PrimeNormQuaternionSliceView(
          onBack: () => setState(() => _showQuaternionSlice = false));
    }
    final l10n = AppLocalizations.of(context)!;
    final p = _candidate;
    final status =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        _button(l10n.tabExplore, widget.onExplore),
        Text(l10n.gaussianWalk, style: Theme.of(context).textTheme.titleMedium),
        if (Navigator.of(context).canPop())
          _button(l10n.viewerBackToCatalog, () => Navigator.of(context).pop()),
      ]),
      Text(l10n.gaussianDomain(_bound)),
      Semantics(
          liveRegion: true,
          child: Text(_error
              ? l10n.gaussianError
              : _map == null
                  ? l10n.gaussianComputing
                  : l10n.gaussianReady(_map!.points.length))),
      Text(l10n.gaussianRoot(_root.a, _root.b, _path.length - 1)),
      Text(l10n.gaussianPathState(
          _path.length - 1,
          _component.length,
          _component.any((p) => p.a.abs() == _bound || p.b.abs() == _bound)
              ? l10n.gaussianBoundaryUnknown
              : l10n.gaussianBoundaryContained)),
      if (p != null)
        Text(l10n.gaussianCandidate(
            p.a, p.b, p.a * p.a + p.b * p.b, _candidateState(l10n, p))),
    ]);
    return ChangeNotifierProvider.value(
        value: _camera!,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 768 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3;
            final controls = FractalControlsHud(
                onClose: wide ? null : () => setState(() => _controls = false),
                content: _controlsContent(l10n));
            final plot = _plot();
            return Stack(children: [
              Column(children: [
                ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: constraints.maxHeight * 0.45),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: status)),
                Expanded(
                    child: wide
                        ? Row(children: [
                            Expanded(child: plot),
                            SizedBox(width: 300, child: controls)
                          ])
                        : plot),
                Wrap(alignment: WrapAlignment.center, children: [
                  _button(l10n.gaussianStep, _canStep ? _step : null),
                  _button(
                      l10n.gaussianUndo,
                      _path.length > 1
                          ? () => setState(() => _path.removeLast())
                          : null),
                  _button(
                      l10n.gaussianResetPath,
                      () => setState(() {
                            _path
                              ..clear()
                              ..add(_root);
                          })),
                  if (!wide)
                    _button(l10n.controlsTitle,
                        () => setState(() => _controls = !_controls)),
                  _button(
                      l10n.exportTitle, _map == null ? null : widget.onExport),
                ]),
              ]),
              if (!wide && _controls)
                Positioned.fill(
                    child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: controls)),
            ]);
          }),
        ));
  }
}
