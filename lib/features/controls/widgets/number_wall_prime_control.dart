import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// The same exact, cancellable Apply boundary in both viewer controls surfaces.
class NumberWallPrimeControl extends StatefulWidget {
  const NumberWallPrimeControl({super.key});

  @override
  State<NumberWallPrimeControl> createState() => _NumberWallPrimeControlState();
}

class _NumberWallPrimeControlState extends State<NumberWallPrimeControl> {
  final _text = TextEditingController();
  FractalController? _owner;
  String? _committed;
  NumberWallPrimeStatus? _result;
  bool _checking = false;
  int _request = 0;
  int _budget = NumberWallPrimeValidator.defaultMaxTrialDivisions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _owner = context.read<FractalController>();
  }

  Future<void> _apply([String? quickPick]) async {
    final owner = _owner!;
    if (quickPick != null) _text.text = quickPick;
    final request = ++_request;
    setState(() {
      _checking = true;
      _result = null;
    });
    final result = await owner.applyNumberWallPrime(_text.text,
        maxTrialDivisions: _budget);
    if (!mounted || request != _request) return;
    setState(() {
      _checking = false;
      _result = result;
    });
  }

  void _cancel() {
    _request++;
    _owner?.cancelNumberWallRequest();
    setState(() {
      _checking = false;
      _result = NumberWallPrimeStatus.cancelled;
    });
  }

  @override
  void dispose() {
    if (_checking) _owner?.cancelNumberWallRequest();
    _request++;
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final value = controller.params['prime'].toString();
    if (_committed != value) {
      _committed = value;
      if (!_checking) _text.text = value;
    }
    final status = _result ?? controller.numberWallStatus;
    final message = _checking || controller.numberWallPending
        ? l10n.numberWallCheckingPrime
        : switch (status) {
            NumberWallPrimeStatus.verifiedPrime => l10n.numberWallPrimeApplied,
            NumberWallPrimeStatus.unverified => l10n.numberWallPrimeUnverified,
            NumberWallPrimeStatus.cancelled => l10n.numberWallCancelled,
            NumberWallPrimeStatus.invalid ||
            NumberWallPrimeStatus.composite =>
              l10n.numberWallPrimeInvalid,
            null => null,
          };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          key: const Key('numberWallPrimeEditor'),
          controller: _text,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.numberWallPrime,
            labelStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(),
            helperText: l10n.numberWallPrimeHint,
            helperStyle: const TextStyle(color: Colors.white70),
            helperMaxLines: 3,
            suffixIcon: IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: l10n.numberWallApplyPrime,
              onPressed: () => _apply(),
              icon: const Icon(Icons.check, color: Colors.white),
            ),
          ),
          onChanged: (_) {
            if (_checking) _cancel();
            _budget = NumberWallPrimeValidator.defaultMaxTrialDivisions;
          },
          onSubmitted: (_) => _apply(),
        ),
        Wrap(spacing: 8, children: [
          for (final prime in const ['2', '3', '5', '7', '11', '13'])
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: Colors.white),
              onPressed: () => _apply(prime),
              child: Text(prime),
            ),
          if (_checking)
            TextButton(onPressed: _cancel, child: Text(l10n.actionCancel)),
          if (status == NumberWallPrimeStatus.unverified && !_checking)
            TextButton(
                onPressed: () {
                  _budget *= 2;
                  _apply();
                },
                child: Text(l10n.numberWallContinue)),
        ]),
        if (message != null)
          Semantics(
              liveRegion: true,
              child:
                  Text(message, style: const TextStyle(color: Colors.white))),
      ]),
    );
  }
}
