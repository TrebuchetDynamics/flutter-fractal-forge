import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

bool isNumberWallColor(String id) =>
    const {'foregroundColor', 'zeroColor', 'backgroundColor'}.contains(id);

/// A colour swatch opens an explicit RGB editor, rather than an integer slider.
/// Palette selection/editing continues to use the ordinary palette controls.
class NumberWallColorControl extends StatelessWidget {
  const NumberWallColorControl(
      {super.key,
      required this.param,
      required this.value,
      required this.onChanged});
  final FractalParameter param;
  final Object value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rgb = (value as num).toInt();
    return Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 12,
          leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: Color(0xff000000 | rgb),
                  border: Border.all(color: Colors.white54))),
          title: Text(param.label(l10n)),
          subtitle:
              Text('#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}'),
          onTap: () async {
            var text = rgb.toRadixString(16).padLeft(6, '0');
            final form = GlobalKey<FormState>();
            final result = await showDialog<int>(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(param.label(l10n)),
                      content: Form(
                          key: form,
                          child: TextFormField(
                            initialValue: text,
                            onChanged: (value) => text = value,
                            autofocus: true,
                            maxLength: 6,
                            decoration: InputDecoration(
                                labelText: l10n.numberWallColorHex),
                            validator: (value) => RegExp(r'^[0-9a-fA-F]{6}$')
                                    .hasMatch(value ?? '')
                                ? null
                                : l10n.numberWallColorHex,
                          )),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.actionCancel)),
                        TextButton(
                            onPressed: () {
                              if (form.currentState!.validate())
                                Navigator.pop(
                                    context, int.parse(text, radix: 16));
                            },
                            child: Text(l10n.actionApply)),
                      ],
                    ));
            if (result != null && context.mounted) onChanged(result);
          },
        ));
  }
}

class NumberWallRandomizationControls extends StatelessWidget {
  const NumberWallRandomizationControls({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final seed = (controller.params['randomSeed'] as num?)?.toInt() ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.numberWallUnsupportedTools),
      const SizedBox(height: 8),
      Text('${l10n.numberWallSeed}: $seed'),
      Wrap(spacing: 8, children: [
        TextButton.icon(
            icon: const Icon(Icons.undo),
            label: Text(l10n.numberWallUndo),
            onPressed: controller.canUndoNumberWallRandomization
                ? controller.undoNumberWallRandomization
                : null),
        TextButton.icon(
            icon: const Icon(Icons.replay),
            label: Text(l10n.numberWallReplay),
            onPressed: controller.numberWallPending
                ? null
                : () => controller.randomizeNumberWall(seed: seed)),
      ]),
    ]);
  }
}
