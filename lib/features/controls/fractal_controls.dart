import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalControlsSheet extends StatelessWidget {
  const FractalControlsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.controlsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...controller.module.parameters.map((param) {
              return _ParamControl(
                param: param,
                value: controller.params[param.id] ?? param.defaultValue,
                onChanged: (value) => controller.updateParam(param.id, value),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetView,
                    child: Text(l10n.resetView),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetParams,
                    child: Text(l10n.resetParams),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.randomizeParams,
                child: Text(l10n.randomize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParamControl extends StatelessWidget {
  final FractalParameter param;
  final Object value;
  final ValueChanged<Object> onChanged;

  const _ParamControl({
    required this.param,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (param.type) {
      case FractalParamType.float:
      case FractalParamType.integer:
        final v = value;
        final doubleValue = v is num ? v.toDouble() : param.min;
        final divisions = ((param.max - param.min) / param.step).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(param.label(l10n)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: doubleValue.clamp(param.min, param.max),
                    min: param.min,
                    max: param.max,
                    divisions: divisions > 0 ? divisions : null,
                    label: param.type == FractalParamType.integer
                        ? doubleValue.round().toString()
                        : doubleValue.toStringAsFixed(2),
                    semanticFormatterCallback: (v) {
                      final formatted = param.type == FractalParamType.integer
                          ? v.round().toString()
                          : v.toStringAsFixed(2);
                      return '${param.label(l10n)}: $formatted';
                    },
                    onChanged: (newValue) {
                      if (param.type == FractalParamType.integer) {
                        onChanged(newValue.round());
                      } else {
                        onChanged(double.parse(newValue.toStringAsFixed(2)));
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    param.type == FractalParamType.integer
                        ? doubleValue.round().toString()
                        : doubleValue.toStringAsFixed(2),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        );
      case FractalParamType.enumeration:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(param.label(l10n)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: param.options.map((option) {
                final selected = option.value == value;
                return ChoiceChip(
                  label: Text(option.label(l10n)),
                  selected: selected,
                  onSelected: (_) => onChanged(option.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        );
      case FractalParamType.boolean:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(param.label(l10n)),
          value: value == true,
          onChanged: (newValue) => onChanged(newValue),
        );
    }
  }
}
